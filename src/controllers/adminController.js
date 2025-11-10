const User = require('../models/User');
const Listing = require('../models/Listing');
const Booking = require('../models/Booking');
const { AppError } = require('../middleware/errorHandler');
const logger = require('../utils/logger');

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
    } = req.query;

    const query = {};

    if (role) {
      query.role = role;
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







