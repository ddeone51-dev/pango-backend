const PDFDocument = require('pdfkit');
const User = require('../models/User');
const Listing = require('../models/Listing');
const Booking = require('../models/Booking');
const Payment = require('../models/Payment');
const { AppError } = require('../middleware/errorHandler');
const logger = require('../utils/logger');

const buildName = (profile = {}, fallback = '') => {
  const first = profile.firstName || '';
  const last = profile.lastName || '';
  const full = `${first} ${last}`.trim();
  return full || fallback || '';
};

const extractListingTitle = (listing) => {
  if (!listing) return '';
  if (typeof listing === 'string') return listing;
  if (listing.title) {
    if (typeof listing.title === 'string') return listing.title;
    return listing.title.en || listing.title.sw || '';
  }
  return listing.name || '';
};

const csvEscape = (value) => {
  if (value === null || value === undefined) return '';
  const stringValue = value instanceof Date ? value.toISOString() : value.toString();
  if (stringValue.includes('"') || stringValue.includes(',') || stringValue.includes('\n')) {
    return `"${stringValue.replace(/"/g, '""')}"`;
  }
  return stringValue;
};

const buildPaymentDataset = async ({ statusUpper, methodUpper, searchRegex }) => {
  const paymentQuery = {};
  if (statusUpper) paymentQuery.status = statusUpper;
  if (methodUpper) paymentQuery.paymentMethod = methodUpper;
  if (searchRegex) {
    paymentQuery.$or = [
      { customerEmail: searchRegex },
      { customerPhone: searchRegex },
      { pesapalMerchantReference: searchRegex },
      { pesapalOrderTrackingId: searchRegex },
      { paymentMethod: searchRegex },
    ];
  }

  const bookingQuery = {};
  if (methodUpper) {
    bookingQuery['payment.method'] = methodUpper.toLowerCase();
  } else {
    bookingQuery['payment.method'] = 'zenopay';
  }
  if (statusUpper) bookingQuery['payment.status'] = statusUpper.toLowerCase();
  if (searchRegex) {
    bookingQuery.$or = [
      { 'guestDetails.email': searchRegex },
      { 'guestDetails.phoneNumber': searchRegex },
      { orderId: searchRegex },
      { 'payment.transactionId': searchRegex },
    ];
  }

  const [paymentDocs, bookingDocs] = await Promise.all([
    Payment.find(paymentQuery)
      .populate('userId', 'email phoneNumber profile.firstName profile.lastName')
      .populate('listingId', 'title location.city name')
      .populate('bookingId', 'status checkInDate checkOutDate'),
    Booking.find(bookingQuery)
      .populate('guestId', 'email phoneNumber profile.firstName profile.lastName')
      .populate('listingId', 'title location.city name')
      .select('pricing payment guestDetails listingId createdAt updatedAt orderId status'),
  ]);

  const paymentTransactions = paymentDocs.map((doc) => {
    const plain = doc.toObject({ virtuals: true });
    const user = plain.userId || {};
    const listing = plain.listingId || {};
    const customerName = buildName(user.profile, '');
    const customerEmail = plain.customerEmail || user.email || null;
    const customerPhone = plain.customerPhone || user.phoneNumber || null;
    const listingTitle = extractListingTitle(listing);

    return {
      id: plain._id.toString(),
      source: 'payment',
      amount: plain.amount || 0,
      currency: plain.currency || 'TZS',
      status: (plain.status || 'UNKNOWN').toString().toUpperCase(),
      paymentMethod: (plain.paymentMethod || 'UNKNOWN').toString().toUpperCase(),
      customerName,
      customerEmail,
      customerPhone,
      createdAt: plain.createdAt,
      completedAt: plain.completedAt,
      merchantReference: plain.pesapalMerchantReference || '',
      orderTrackingId: plain.pesapalOrderTrackingId || '',
      transactionId: plain.pesapalTransactionId || '',
      user,
      listing,
      listingTitle,
      booking: plain.bookingId || null,
    };
  });

  const bookingTransactions = bookingDocs.map((doc) => {
    const plain = doc.toObject({ virtuals: true });
    const guest = plain.guestId || {};
    const guestDetails = plain.guestDetails || {};
    const listing = plain.listingId || {};
    const customerName = buildName(guest.profile, guestDetails.fullName || '');
    const customerEmail = guestDetails.email || guest.email || null;
    const customerPhone = guestDetails.phoneNumber || guest.phoneNumber || null;
    const listingTitle = extractListingTitle(listing);
    const paymentInfo = plain.payment || {};

    return {
      id: `BOOKING-${plain._id}`,
      source: 'booking',
      amount: plain.pricing?.total || 0,
      currency: plain.pricing?.currency || 'TZS',
      status: (paymentInfo.status || 'PENDING').toString().toUpperCase(),
      paymentMethod: (paymentInfo.method || 'ZENOPAY').toString().toUpperCase(),
      customerName,
      customerEmail,
      customerPhone,
      createdAt: plain.createdAt,
      completedAt: paymentInfo.paidAt || null,
      merchantReference: plain.orderId || '',
      orderTrackingId: paymentInfo.orderId || plain.orderId || '',
      transactionId: paymentInfo.transactionId || '',
      user: guest,
      listing,
      listingTitle,
      booking: { _id: plain._id, status: plain.status },
    };
  }).filter((transaction) => {
    if (!methodUpper) return true;
    return transaction.paymentMethod === methodUpper;
  });

  const combinedTransactions = [...paymentTransactions, ...bookingTransactions]
    .sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));

  const stats = combinedTransactions.reduce((acc, tx) => {
    const amount = tx.amount || 0;
    const statusKey = tx.status || 'UNKNOWN';

    acc.totalAmount += amount;
    acc.totalCount += 1;

    if (statusKey === 'COMPLETED') {
      acc.completedAmount += amount;
      acc.completedCount += 1;
    } else if (statusKey === 'PENDING') {
      acc.pendingAmount += amount;
      acc.pendingCount += 1;
    } else if (statusKey === 'FAILED' || statusKey === 'CANCELLED') {
      acc.failedAmount += amount;
      acc.failedCount += 1;
    }

    acc.breakdown[statusKey] = acc.breakdown[statusKey] || { count: 0, amount: 0 };
    acc.breakdown[statusKey].count += 1;
    acc.breakdown[statusKey].amount += amount;

    return acc;
  }, {
    totalAmount: 0,
    totalCount: 0,
    completedAmount: 0,
    pendingAmount: 0,
    failedAmount: 0,
    completedCount: 0,
    pendingCount: 0,
    failedCount: 0,
    breakdown: {},
  });

  return { transactions: combinedTransactions, stats };
};

// @desc    Get dashboard statistics
// @route   GET /api/v1/admin/dashboard/stats
// @access  Admin
exports.getDashboardStats = async (req, res, next) => {
  try {
    // Get date ranges
    const now = new Date();
    const thisMonth = new Date(now.getFullYear(), now.getMonth(), 1);
    const lastMonth = new Date(now.getFullYear(), now.getMonth() - 1, 1);
    const thisYear = new Date(now.getFullYear(), 0, 1);

    // Total counts
    const [
      totalUsers,
      totalHosts,
      totalGuests,
      totalListings,
      totalBookings,
      activeListings,
      pendingListings,
    ] = await Promise.all([
      User.countDocuments(),
      User.countDocuments({ role: 'host' }),
      User.countDocuments({ role: 'guest' }),
      Listing.countDocuments(),
      Booking.countDocuments(),
      Listing.countDocuments({ available: true }),
      Listing.countDocuments({ status: 'pending' }),
    ]);

    // Monthly stats
    const [usersThisMonth, bookingsThisMonth, listingsThisMonth] = await Promise.all([
      User.countDocuments({ createdAt: { $gte: thisMonth } }),
      Booking.countDocuments({ createdAt: { $gte: thisMonth } }),
      Listing.countDocuments({ createdAt: { $gte: thisMonth } }),
    ]);

    // Revenue calculation
    const revenueAggregation = await Booking.aggregate([
      {
        $match: {
          status: { $in: ['confirmed', 'completed'] },
          'payment.status': 'completed',
        },
      },
      {
        $group: {
          _id: null,
          totalRevenue: { $sum: '$pricing.total' },
          thisMonthRevenue: {
            $sum: {
              $cond: [{ $gte: ['$createdAt', thisMonth] }, '$pricing.total', 0],
            },
          },
          lastMonthRevenue: {
            $sum: {
              $cond: [
                {
                  $and: [
                    { $gte: ['$createdAt', lastMonth] },
                    { $lt: ['$createdAt', thisMonth] },
                  ],
                },
                '$pricing.total',
                0,
              ],
            },
          },
          thisYearRevenue: {
            $sum: {
              $cond: [{ $gte: ['$createdAt', thisYear] }, '$pricing.total', 0],
            },
          },
        },
      },
    ]);

    const revenue = revenueAggregation[0] || {
      totalRevenue: 0,
      thisMonthRevenue: 0,
      lastMonthRevenue: 0,
      thisYearRevenue: 0,
    };

    // Calculate growth percentages
    const userGrowth =
      totalUsers > usersThisMonth
        ? ((usersThisMonth / (totalUsers - usersThisMonth)) * 100).toFixed(1)
        : 0;
    const bookingGrowth =
      totalBookings > bookingsThisMonth
        ? ((bookingsThisMonth / (totalBookings - bookingsThisMonth)) * 100).toFixed(1)
        : 0;
    const revenueGrowth =
      revenue.lastMonthRevenue > 0
        ? (
            ((revenue.thisMonthRevenue - revenue.lastMonthRevenue) /
              revenue.lastMonthRevenue) *
            100
          ).toFixed(1)
        : 0;

    // Top listings by bookings
    const topListings = await Booking.aggregate([
      { $match: { status: { $in: ['confirmed', 'completed'] } } },
      { $group: { _id: '$listingId', bookingCount: { $sum: 1 } } },
      { $sort: { bookingCount: -1 } },
      { $limit: 5 },
      {
        $lookup: {
          from: 'listings',
          localField: '_id',
          foreignField: '_id',
          as: 'listing',
        },
      },
      { $unwind: '$listing' },
      {
        $project: {
          _id: 1,
          bookingCount: 1,
          title: '$listing.title',
          city: '$listing.location.city',
        },
      },
    ]);

    // Recent activities
    const recentUsers = await User.find()
      .sort({ createdAt: -1 })
      .limit(5)
      .select('email profile.firstName profile.lastName role createdAt');

    const recentBookingsDocs = await Booking.find()
      .sort({ createdAt: -1 })
      .limit(5)
      .populate('guestId', 'email profile.firstName profile.lastName')
      .populate('listingId', 'title location.city');
    const recentBookings = recentBookingsDocs.map((booking) => {
      const plain = booking.toObject();
      return {
        ...plain,
        userId: plain.guestId,
        totalAmount: plain.pricing?.total || 0,
        paymentStatus: plain.payment?.status || 'pending',
      };
    });

    // Booking status breakdown
    const bookingsByStatus = await Booking.aggregate([
      {
        $group: {
          _id: '$status',
          count: { $sum: 1 },
        },
      },
    ]);

    res.status(200).json({
      success: true,
      data: {
        overview: {
          totalUsers,
          totalHosts,
          totalGuests,
          totalListings,
          activeListings,
          pendingListings,
          totalBookings,
          totalRevenue: revenue.totalRevenue,
          thisYearRevenue: revenue.thisYearRevenue,
        },
        thisMonth: {
          newUsers: usersThisMonth,
          newBookings: bookingsThisMonth,
          newListings: listingsThisMonth,
          revenue: revenue.thisMonthRevenue,
        },
        growth: {
          users: parseFloat(userGrowth),
          bookings: parseFloat(bookingGrowth),
          revenue: parseFloat(revenueGrowth),
        },
        topListings,
        recentUsers,
        recentBookings,
        bookingsByStatus,
      },
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get chart data for dashboard
// @route   GET /api/v1/admin/dashboard/charts
// @access  Admin
exports.getChartData = async (req, res, next) => {
  try {
    const { period = '7days' } = req.query;

    let startDate;
    const now = new Date();

    switch (period) {
      case '7days':
        startDate = new Date(now.setDate(now.getDate() - 7));
        break;
      case '30days':
        startDate = new Date(now.setDate(now.getDate() - 30));
        break;
      case '6months':
        startDate = new Date(now.setMonth(now.getMonth() - 6));
        break;
      case '1year':
        startDate = new Date(now.setFullYear(now.getFullYear() - 1));
        break;
      default:
        startDate = new Date(now.setDate(now.getDate() - 7));
    }

    // Users over time
    const usersOverTime = await User.aggregate([
      { $match: { createdAt: { $gte: startDate } } },
      {
        $group: {
          _id: { $dateToString: { format: '%Y-%m-%d', date: '$createdAt' } },
          count: { $sum: 1 },
        },
      },
      { $sort: { _id: 1 } },
    ]);

    // Bookings over time
    const bookingsOverTime = await Booking.aggregate([
      { $match: { createdAt: { $gte: startDate } } },
      {
        $group: {
          _id: { $dateToString: { format: '%Y-%m-%d', date: '$createdAt' } },
          count: { $sum: 1 },
        },
      },
      { $sort: { _id: 1 } },
    ]);

    // Revenue over time
    const revenueOverTime = await Booking.aggregate([
      {
        $match: {
          createdAt: { $gte: startDate },
          'payment.status': 'completed',
        },
      },
      {
        $group: {
          _id: { $dateToString: { format: '%Y-%m-%d', date: '$createdAt' } },
          revenue: { $sum: '$pricing.total' },
        },
      },
      { $sort: { _id: 1 } },
    ]);

    res.status(200).json({
      success: true,
      data: {
        usersOverTime,
        bookingsOverTime,
        revenueOverTime,
      },
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get all users with pagination and filters
// @route   GET /api/v1/admin/users
// @access  Admin
exports.getAllUsers = async (req, res, next) => {
  try {
    const {
      page = 1,
      limit = 10,
      role,
      search,
      sort = '-createdAt',
      hostStatus,
    } = req.query;

    const query = {};

    if (role) {
      query.role = role;
    }

    if (hostStatus) {
      query.hostStatus = hostStatus;
    }

    if (search) {
      query.$or = [
        { email: { $regex: search, $options: 'i' } },
        { 'profile.firstName': { $regex: search, $options: 'i' } },
        { 'profile.lastName': { $regex: search, $options: 'i' } },
        { phoneNumber: { $regex: search, $options: 'i' } },
      ];
    }

    const total = await User.countDocuments(query);
    const users = await User.find(query)
      .sort(sort)
      .limit(limit * 1)
      .skip((page - 1) * limit)
      .select('-password');

    res.status(200).json({
      success: true,
      count: users.length,
      total,
      pages: Math.ceil(total / limit),
      currentPage: parseInt(page),
      data: users,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get host requests with pagination and filters
// @route   GET /api/v1/admin/hosts
// @access  Admin
exports.getHostRequests = async (req, res, next) => {
  try {
    const {
      page = 1,
      limit = 10,
      status,
      search,
      sort = '-createdAt',
    } = req.query;

    const query = { role: 'host' };

    if (status) {
      query.hostStatus = status;
    }

    if (search) {
      query.$or = [
        { email: { $regex: search, $options: 'i' } },
        { phoneNumber: { $regex: search, $options: 'i' } },
        { 'profile.firstName': { $regex: search, $options: 'i' } },
        { 'profile.lastName': { $regex: search, $options: 'i' } },
      ];
    }

    const total = await User.countDocuments(query);
    const hosts = await User.find(query)
      .sort(sort)
      .skip((page - 1) * limit)
      .limit(limit * 1)
      .select('-password');

    res.status(200).json({
      success: true,
      data: hosts,
      pagination: {
        page: parseInt(page, 10),
        limit: parseInt(limit, 10),
        total,
        pages: Math.ceil(total / limit),
      },
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Update host status
// @route   PUT /api/v1/admin/hosts/:id/status
// @access  Admin
exports.updateHostStatus = async (req, res, next) => {
  try {
    const { status } = req.body;
    const validStatuses = ['pending', 'approved', 'rejected'];

    if (!validStatuses.includes(status)) {
      return next(new AppError('Invalid host status', 400));
    }

    const user = await User.findById(req.params.id);

    if (!user || user.role !== 'host') {
      return next(new AppError('Host not found', 404));
    }

    user.hostStatus = status;
    if (status === 'approved') {
      user.role = 'host';
    } else if (status === 'pending') {
      user.role = 'host';
    }

    await user.save({ validateBeforeSave: false });

    logger.info(`Admin updated host ${user.email} status to ${status}`);

    res.status(200).json({
      success: true,
      data: user,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get single user
// @route   GET /api/v1/admin/users/:id
// @access  Admin
exports.getUser = async (req, res, next) => {
  try {
    const user = await User.findById(req.params.id).select('-password');

    if (!user) {
      return next(new AppError('User not found', 404));
    }

    // Get user's listings if host
    let listings = [];
    if (user.role === 'host') {
      listings = await Listing.find({ hostId: user._id });
    }

    // Get user's bookings
    const bookings = await Booking.find({ guestId: user._id })
      .populate('listingId', 'title location.city')
      .populate('guestId', 'email profile.firstName profile.lastName')
      .sort('-createdAt')
      .limit(10);

    res.status(200).json({
      success: true,
      data: {
        user,
        listings,
        bookings: bookings.map((booking) => {
          const plain = booking.toObject();
          return {
            ...plain,
            userId: plain.guestId,
            totalAmount: plain.pricing?.total || 0,
            paymentStatus: plain.payment?.status || 'pending',
          };
        }),
      },
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Update user
// @route   PUT /api/v1/admin/users/:id
// @access  Admin
exports.updateUser = async (req, res, next) => {
  try {
    const { role, isActive, isVerified } = req.body;

    const updateData = {};
    if (role) updateData.role = role;
    if (isActive !== undefined) updateData.isActive = isActive;
    if (isVerified !== undefined) updateData.isVerified = isVerified;

    if (role) {
      if (role === 'host') {
        updateData.hostStatus = 'pending';
      } else if (role !== 'admin') {
        updateData.hostStatus = 'not_requested';
      }
    }

    const user = await User.findByIdAndUpdate(req.params.id, updateData, {
      new: true,
      runValidators: true,
    }).select('-password');

    if (!user) {
      return next(new AppError('User not found', 404));
    }

    logger.info(`Admin updated user ${user._id}: ${JSON.stringify(updateData)}`);

    res.status(200).json({
      success: true,
      data: user,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Delete user
// @route   DELETE /api/v1/admin/users/:id
// @access  Admin
exports.deleteUser = async (req, res, next) => {
  try {
    const user = await User.findById(req.params.id);

    if (!user) {
      return next(new AppError('User not found', 404));
    }

    // Delete user's listings if host
    if (user.role === 'host') {
      await Listing.deleteMany({ hostId: user._id });
    }

    // Delete user's bookings
    await Booking.deleteMany({ guestId: user._id });

    await user.deleteOne();

    logger.info(`Admin deleted user ${req.params.id}`);

    res.status(200).json({
      success: true,
      message: 'User deleted successfully',
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get all listings with pagination and filters
// @route   GET /api/v1/admin/listings
// @access  Admin
exports.getAllListings = async (req, res, next) => {
  try {
    const {
      page = 1,
      limit = 10,
      status,
      search,
      sort = '-createdAt',
    } = req.query;

    const query = {};

    if (status) {
      query.status = status;
    }

    if (search) {
      query.$or = [
        { title: { $regex: search, $options: 'i' } },
        { description: { $regex: search, $options: 'i' } },
        { 'location.city': { $regex: search, $options: 'i' } },
      ];
    }

    const total = await Listing.countDocuments(query);
    const listings = await Listing.find(query)
      .populate('hostId', 'email profile.firstName profile.lastName')
      .sort(sort)
      .limit(limit * 1)
      .skip((page - 1) * limit);

    res.status(200).json({
      success: true,
      count: listings.length,
      total,
      pages: Math.ceil(total / limit),
      currentPage: parseInt(page),
      data: listings,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Approve/reject listing
// @route   PUT /api/v1/admin/listings/:id/status
// @access  Admin
exports.updateListingStatus = async (req, res, next) => {
  try {
    const { status } = req.body;

    if (!['approved', 'rejected', 'pending'].includes(status)) {
      return next(new AppError('Invalid status', 400));
    }

    const listing = await Listing.findByIdAndUpdate(
      req.params.id,
      { status },
      { new: true, runValidators: true }
    );

    if (!listing) {
      return next(new AppError('Listing not found', 404));
    }

    logger.info(`Admin updated listing ${listing._id} status to ${status}`);

    res.status(200).json({
      success: true,
      data: listing,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Delete listing
// @route   DELETE /api/v1/admin/listings/:id
// @access  Admin
exports.deleteListing = async (req, res, next) => {
  try {
    const listing = await Listing.findById(req.params.id);

    if (!listing) {
      return next(new AppError('Listing not found', 404));
    }

    // Delete related bookings
    await Booking.deleteMany({ listingId: listing._id });

    await listing.deleteOne();

    logger.info(`Admin deleted listing ${req.params.id}`);

    res.status(200).json({
      success: true,
      message: 'Listing deleted successfully',
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get all bookings with pagination and filters
// @route   GET /api/v1/admin/bookings
// @access  Admin
exports.getAllBookings = async (req, res, next) => {
  try {
    const {
      page = 1,
      limit = 10,
      status,
      paymentStatus,
      sort = '-createdAt',
    } = req.query;

    const query = {};

    if (status) {
      query.status = status;
    }

    if (paymentStatus) {
      query['payment.status'] = paymentStatus.toLowerCase();
    }

    const total = await Booking.countDocuments(query);
    const bookingsDocs = await Booking.find(query)
      .populate('guestId', 'email profile.firstName profile.lastName phoneNumber')
      .populate('hostId', 'email profile.firstName profile.lastName phoneNumber')
      .populate('listingId', 'title location.city')
      .sort(sort)
      .limit(limit * 1)
      .skip((page - 1) * limit);

    const bookings = bookingsDocs.map((booking) => {
      const plain = booking.toObject();
      return {
        ...plain,
        userId: plain.guestId,
        totalAmount: plain.pricing?.total || 0,
        currency: plain.pricing?.currency || 'TZS',
        paymentStatus: plain.payment?.status || 'pending',
        paymentMethod: plain.payment?.method || 'unknown',
        checkIn: plain.checkInDate,
        checkOut: plain.checkOutDate,
      };
    });

    res.status(200).json({
      success: true,
      count: bookings.length,
      total,
      pages: Math.ceil(total / limit),
      currentPage: parseInt(page),
      data: bookings,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get payment transactions with stats
// @route   GET /api/v1/admin/payments/transactions
// @access  Admin
exports.getPaymentTransactions = async (req, res, next) => {
  try {
    const {
      page = 1,
      limit = 20,
      status,
      method,
      search,
    } = req.query;

    const limitNum = Math.max(parseInt(limit, 10) || 20, 1);
    const pageNum = Math.max(parseInt(page, 10) || 1, 1);
    const statusUpper = status ? status.toUpperCase() : '';
    const methodUpper = method ? method.toUpperCase() : '';
    const searchRegex = search ? new RegExp(search, 'i') : null;

    const { transactions, stats } = await buildPaymentDataset({
      statusUpper,
      methodUpper,
      searchRegex,
    });

    const total = transactions.length;
    const pages = Math.ceil(total / limitNum) || 1;
    const startIndex = (pageNum - 1) * limitNum;
    const paginatedTransactions = transactions.slice(startIndex, startIndex + limitNum);

    res.status(200).json({
      success: true,
      data: {
        transactions: paginatedTransactions,
        pagination: {
          page: pageNum,
          limit: limitNum,
          total,
          pages,
        },
        stats,
      },
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Export payment transactions as CSV
// @route   GET /api/v1/admin/payments/export
// @access  Admin
exports.exportPaymentTransactions = async (req, res, next) => {
  try {
    const { status, method, search } = req.query;
    const statusUpper = status ? status.toUpperCase() : '';
    const methodUpper = method ? method.toUpperCase() : '';
    const searchRegex = search ? new RegExp(search, 'i') : null;

    const { transactions } = await buildPaymentDataset({
      statusUpper,
      methodUpper,
      searchRegex,
    });

    const header = [
      'ID',
      'Source',
      'Status',
      'Amount',
      'Currency',
      'Method',
      'Customer Name',
      'Customer Email',
      'Customer Phone',
      'Booking ID',
      'Listing',
      'Created At',
      'Completed At',
      'Reference',
      'Order Tracking',
      'Transaction ID',
    ];

    const rows = transactions.map((tx) => {
      const bookingId = tx.booking?._id || tx.booking || '';
      const listingTitle = tx.listingTitle || extractListingTitle(tx.listing);
      return [
        tx.id,
        tx.source,
        tx.status,
        tx.amount,
        tx.currency,
        tx.paymentMethod,
        tx.customerName || '',
        tx.customerEmail || '',
        tx.customerPhone || '',
        bookingId,
        listingTitle || '',
        tx.createdAt ? new Date(tx.createdAt).toISOString() : '',
        tx.completedAt ? new Date(tx.completedAt).toISOString() : '',
        tx.merchantReference || '',
        tx.orderTrackingId || '',
        tx.transactionId || '',
      ];
    });

    const csvContent = [
      header.map(csvEscape).join(','),
      ...rows.map((row) => row.map(csvEscape).join(',')),
    ].join('\n');

    res.setHeader('Content-Type', 'text/csv');
    res.setHeader(
      'Content-Disposition',
      `attachment; filename="payments-export-${new Date().toISOString().split('T')[0]}.csv"`
    );
    res.status(200).send(csvContent);
  } catch (error) {
    next(error);
  }
};

// @desc    Export payment transactions as PDF
// @route   GET /api/v1/admin/payments/export-pdf
// @access  Admin
exports.exportPaymentTransactionsPdf = async (req, res, next) => {
  try {
    const { status, method, search } = req.query;
    const statusUpper = status ? status.toUpperCase() : '';
    const methodUpper = method ? method.toUpperCase() : '';
    const searchRegex = search ? new RegExp(search, 'i') : null;

    const { transactions, stats } = await buildPaymentDataset({
      statusUpper,
      methodUpper,
      searchRegex,
    });

    res.setHeader('Content-Type', 'application/pdf');
    res.setHeader(
      'Content-Disposition',
      `attachment; filename="payments-report-${new Date().toISOString().split('T')[0]}.pdf"`,
    );

    const doc = new PDFDocument({ margin: 36, size: 'A4' });
    doc.pipe(res);

    doc.fontSize(20).text('Homie Payments Report', { align: 'center' });
    doc.moveDown(0.5);
    doc.fontSize(10).fillColor('#666666')
      .text(`Generated: ${new Date().toLocaleString()}`, { align: 'center' });
    doc.moveDown(1.5);
    doc.fillColor('#000000');

    doc.fontSize(12).text('Summary', { underline: true });
    doc.moveDown(0.4);
    doc.fontSize(10);
    doc.text(`Total Transactions: ${stats.totalCount}`);
    doc.text(`Total Volume: TZS ${stats.totalAmount.toLocaleString()}`);
    doc.text(`Completed: ${stats.completedCount} (TZS ${stats.completedAmount.toLocaleString()})`);
    doc.text(`Pending: ${stats.pendingCount} (TZS ${stats.pendingAmount.toLocaleString()})`);
    doc.text(`Failed/Cancelled: ${stats.failedCount} (TZS ${stats.failedAmount.toLocaleString()})`);
    doc.moveDown();

    const tableTop = doc.y + 10;
    const tableWidth = doc.page.width - doc.options.margin * 2;
    const columnWidths = {
      REF: tableWidth * 0.13,
      CUSTOMER: tableWidth * 0.25,
      AMOUNT: tableWidth * 0.12,
      METHOD: tableWidth * 0.12,
      STATUS: tableWidth * 0.1,
      CREATED: tableWidth * 0.14,
      BOOKING: tableWidth * 0.14,
    };
    const columns = ['REF', 'CUSTOMER', 'AMOUNT', 'METHOD', 'STATUS', 'CREATED', 'BOOKING'];

    const drawRow = (row, y, isHeader = false) => {
      const x = doc.x;
      doc.font(isHeader ? 'Helvetica-Bold' : 'Helvetica');
      doc.fontSize(isHeader ? 10 : 9);
      doc.fillColor('#000000');
      let currentX = x;

      row.forEach((cell, idx) => {
        const key = columns[idx];
        const maxWidth = columnWidths[key] - 4;
        const text = cell ?? '';
        const widthMeasure = doc.widthOfString(text, { width: maxWidth });
        const textX = currentX + (columnWidths[key] - widthMeasure) / 2;
        doc.text(text, textX, y, {
          width: maxWidth,
          height: 16,
          align: 'center',
          ellipsis: true,
        });
        currentX += columnWidths[key];
      });
    };

    drawRow(columns, tableTop, true);

    const drawDivider = (y, color = '#e0e0e0') => {
      doc.moveTo(doc.x, y)
        .lineTo(doc.x + tableWidth, y)
        .strokeColor(color)
        .stroke();
    };

    drawDivider(tableTop + 16, '#bfbfbf');

    let rowY = tableTop + 22;

    const ensureSpace = () => {
      if (rowY > doc.page.height - doc.page.margins.bottom - 40) {
        doc.addPage();
        rowY = doc.y;
        drawRow(columns, rowY, true);
        drawDivider(rowY + 16, '#bfbfbf');
        rowY += 22;
      }
    };

    transactions.forEach((tx, index) => {
      ensureSpace();
      const bookingId = tx.booking?._id || tx.booking || '';
      const ref = tx.merchantReference || tx.transactionId || bookingId || tx.id;
      const customer = [
        tx.customerName,
        tx.customerEmail,
        tx.customerPhone,
      ].filter(Boolean).join('\n');
      const amount = `TZS ${Number(tx.amount || 0).toLocaleString()}`;
      const created = tx.createdAt ? new Date(tx.createdAt).toLocaleString() : '';
      const bookingLabel = bookingId
        ? `#${bookingId.toString().substring(0, 10).toUpperCase()}`
        : '';

      drawRow(
        [
          ref ? ref.toString().substring(0, 16) : '',
          customer || 'N/A',
          amount,
          (tx.paymentMethod || 'N/A').replace(/_/g, ' '),
          tx.status || 'UNKNOWN',
          created,
          bookingLabel,
        ],
        rowY,
      );

      const dividerColor = index % 2 === 0 ? '#f0f0f0' : '#e6e6e6';
      drawDivider(rowY + 18, dividerColor);
      rowY += 24;
    });

    doc.end();
  } catch (error) {
    next(error);
  }
};

// @desc    Update booking status
// @route   PUT /api/v1/admin/bookings/:id/status
// @access  Admin
exports.updateBookingStatus = async (req, res, next) => {
  try {
    const { status } = req.body;

    const validStatuses = ['pending', 'confirmed', 'cancelled', 'completed'];
    if (!validStatuses.includes(status)) {
      return next(new AppError('Invalid status', 400));
    }

    const booking = await Booking.findByIdAndUpdate(
      req.params.id,
      { status },
      { new: true, runValidators: true }
    );

    if (!booking) {
      return next(new AppError('Booking not found', 404));
    }

    logger.info(`Admin updated booking ${booking._id} status to ${status}`);

    res.status(200).json({
      success: true,
      data: booking,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Generate reports
// @route   GET /api/v1/admin/reports
// @access  Admin
exports.generateReports = async (req, res, next) => {
  try {
    const { type, startDate, endDate } = req.query;

    const dateQuery = {};
    if (startDate && endDate) {
      dateQuery.createdAt = {
        $gte: new Date(startDate),
        $lte: new Date(endDate),
      };
    }

    let reportData = {};

    switch (type) {
      case 'financial':
        reportData = await Booking.aggregate([
          { $match: { ...dateQuery, paymentStatus: 'paid' } },
          {
            $group: {
              _id: null,
              totalRevenue: { $sum: '$totalAmount' },
              totalBookings: { $sum: 1 },
              averageBookingValue: { $avg: '$totalAmount' },
            },
          },
        ]);
        break;

      case 'user-engagement':
        const [newUsers, activeUsers, totalBookings] = await Promise.all([
          User.countDocuments(dateQuery),
          User.countDocuments({ ...dateQuery, isActive: true }),
          Booking.countDocuments(dateQuery),
        ]);
        reportData = { newUsers, activeUsers, totalBookings };
        break;

      case 'property-performance':
        reportData = await Listing.aggregate([
          { $match: dateQuery },
          {
            $lookup: {
              from: 'bookings',
              localField: '_id',
              foreignField: 'listingId',
              as: 'bookings',
            },
          },
          {
            $project: {
              title: 1,
              city: '$location.city',
              bookingCount: { $size: '$bookings' },
              totalRevenue: {
                $sum: {
                  $map: {
                    input: '$bookings',
                    as: 'booking',
                    in: '$$booking.totalAmount',
                  },
                },
              },
            },
          },
          { $sort: { bookingCount: -1 } },
          { $limit: 20 },
        ]);
        break;

      default:
        return next(new AppError('Invalid report type', 400));
    }

    res.status(200).json({
      success: true,
      type,
      period: { startDate, endDate },
      data: reportData,
    });
  } catch (error) {
    next(error);
  }
};







