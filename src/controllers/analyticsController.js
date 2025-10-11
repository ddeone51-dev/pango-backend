const Transaction = require('../models/Transaction');
const Booking = require('../models/Booking');
const Listing = require('../models/Listing');
const User = require('../models/User');
const Review = require('../models/Review');

// @desc    Get advanced analytics dashboard
// @route   GET /api/v1/admin/analytics/dashboard
// @access  Private/Admin
exports.getAdvancedAnalytics = async (req, res, next) => {
  try {
    const { period = '30d' } = req.query;

    let startDate = new Date();
    if (period === '7d') startDate.setDate(startDate.getDate() - 7);
    else if (period === '30d') startDate.setDate(startDate.getDate() - 30);
    else if (period === '90d') startDate.setDate(startDate.getDate() - 90);
    else if (period === '1y') startDate.setFullYear(startDate.getFullYear() - 1);

    // Revenue analytics
    const revenueAnalytics = await Transaction.aggregate([
      {
        $match: {
          createdAt: { $gte: startDate },
          status: 'completed',
          type: 'booking',
        },
      },
      {
        $group: {
          _id: {
            $dateToString: { format: '%Y-%m-%d', date: '$createdAt' },
          },
          totalRevenue: { $sum: '$amount' },
          platformFee: { $sum: '$platformFee' },
          hostPayout: { $sum: '$hostPayout' },
          bookings: { $sum: 1 },
        },
      },
      { $sort: { _id: 1 } },
    ]);

    // Booking trends
    const bookingTrends = await Booking.aggregate([
      {
        $match: { createdAt: { $gte: startDate } },
      },
      {
        $group: {
          _id: {
            date: { $dateToString: { format: '%Y-%m-%d', date: '$createdAt' } },
            status: '$status',
          },
          count: { $sum: 1 },
        },
      },
      { $sort: { '_id.date': 1 } },
    ]);

    // User growth
    const userGrowth = await User.aggregate([
      {
        $match: { createdAt: { $gte: startDate } },
      },
      {
        $group: {
          _id: {
            date: { $dateToString: { format: '%Y-%m-%d', date: '$createdAt' } },
            role: '$role',
          },
          count: { $sum: 1 },
        },
      },
      { $sort: { '_id.date': 1 } },
    ]);

    // Popular locations
    const popularLocations = await Booking.aggregate([
      {
        $match: {
          createdAt: { $gte: startDate },
          status: { $in: ['confirmed', 'completed'] },
        },
      },
      {
        $lookup: {
          from: 'listings',
          localField: 'listing',
          foreignField: '_id',
          as: 'listingInfo',
        },
      },
      { $unwind: '$listingInfo' },
      {
        $group: {
          _id: {
            city: '$listingInfo.location.city',
            region: '$listingInfo.location.region',
          },
          bookings: { $sum: 1 },
          revenue: { $sum: '$totalPrice' },
        },
      },
      { $sort: { bookings: -1 } },
      { $limit: 10 },
    ]);

    // Property type performance
    const propertyTypePerformance = await Booking.aggregate([
      {
        $match: {
          createdAt: { $gte: startDate },
          status: { $in: ['confirmed', 'completed'] },
        },
      },
      {
        $lookup: {
          from: 'listings',
          localField: 'listing',
          foreignField: '_id',
          as: 'listingInfo',
        },
      },
      { $unwind: '$listingInfo' },
      {
        $group: {
          _id: '$listingInfo.type',
          bookings: { $sum: 1 },
          revenue: { $sum: '$totalPrice' },
          avgPrice: { $avg: '$totalPrice' },
        },
      },
      { $sort: { revenue: -1 } },
    ]);

    // Occupancy rates
    const occupancyRates = await Listing.aggregate([
      {
        $lookup: {
          from: 'bookings',
          let: { listingId: '$_id' },
          pipeline: [
            {
              $match: {
                $expr: { $eq: ['$listing', '$$listingId'] },
                createdAt: { $gte: startDate },
                status: { $in: ['confirmed', 'completed'] },
              },
            },
            {
              $project: {
                nights: {
                  $divide: [
                    { $subtract: ['$checkOut', '$checkIn'] },
                    1000 * 60 * 60 * 24,
                  ],
                },
              },
            },
          ],
          as: 'bookings',
        },
      },
      {
        $project: {
          title: 1,
          location: 1,
          type: 1,
          bookedNights: { $sum: '$bookings.nights' },
          totalNights: {
            $divide: [
              { $subtract: [new Date(), startDate] },
              1000 * 60 * 60 * 24,
            ],
          },
        },
      },
      {
        $project: {
          title: 1,
          location: 1,
          type: 1,
          occupancyRate: {
            $multiply: [
              { $divide: ['$bookedNights', '$totalNights'] },
              100,
            ],
          },
        },
      },
      { $sort: { occupancyRate: -1 } },
      { $limit: 10 },
    ]);

    // Average ratings trend
    const ratingsTrend = await Review.aggregate([
      {
        $match: { createdAt: { $gte: startDate } },
      },
      {
        $group: {
          _id: {
            $dateToString: { format: '%Y-%m-%d', date: '$createdAt' },
          },
          avgRating: { $avg: '$rating' },
          count: { $sum: 1 },
        },
      },
      { $sort: { _id: 1 } },
    ]);

    // Top performing hosts
    const topHosts = await Transaction.aggregate([
      {
        $match: {
          createdAt: { $gte: startDate },
          status: 'completed',
          type: 'booking',
        },
      },
      {
        $group: {
          _id: '$host',
          totalRevenue: { $sum: '$amount' },
          totalPayout: { $sum: '$hostPayout' },
          bookings: { $sum: 1 },
        },
      },
      { $sort: { totalRevenue: -1 } },
      { $limit: 10 },
      {
        $lookup: {
          from: 'users',
          localField: '_id',
          foreignField: '_id',
          as: 'hostInfo',
        },
      },
      { $unwind: '$hostInfo' },
    ]);

    res.status(200).json({
      success: true,
      data: {
        revenueAnalytics,
        bookingTrends,
        userGrowth,
        popularLocations,
        propertyTypePerformance,
        occupancyRates,
        ratingsTrend,
        topHosts,
      },
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get revenue analytics
// @route   GET /api/v1/admin/analytics/revenue
// @access  Private/Admin
exports.getRevenueAnalytics = async (req, res, next) => {
  try {
    const { period = '30d', groupBy = 'day' } = req.query;

    let startDate = new Date();
    let dateFormat = '%Y-%m-%d';

    if (period === '7d') {
      startDate.setDate(startDate.getDate() - 7);
    } else if (period === '30d') {
      startDate.setDate(startDate.getDate() - 30);
    } else if (period === '90d') {
      startDate.setDate(startDate.getDate() - 90);
    } else if (period === '1y') {
      startDate.setFullYear(startDate.getFullYear() - 1);
      if (groupBy === 'month') dateFormat = '%Y-%m';
    }

    const revenueData = await Transaction.aggregate([
      {
        $match: {
          createdAt: { $gte: startDate },
          status: 'completed',
        },
      },
      {
        $group: {
          _id: {
            $dateToString: { format: dateFormat, date: '$createdAt' },
          },
          totalRevenue: { $sum: '$amount' },
          platformFee: { $sum: '$platformFee' },
          hostPayout: { $sum: '$hostPayout' },
          refunds: {
            $sum: { $cond: [{ $eq: ['$type', 'refund'] }, '$amount', 0] },
          },
          transactions: { $sum: 1 },
        },
      },
      { $sort: { _id: 1 } },
    ]);

    // Calculate totals
    const totals = await Transaction.aggregate([
      {
        $match: {
          createdAt: { $gte: startDate },
          status: 'completed',
        },
      },
      {
        $group: {
          _id: null,
          totalRevenue: { $sum: '$amount' },
          totalPlatformFee: { $sum: '$platformFee' },
          totalHostPayout: { $sum: '$hostPayout' },
          avgTransaction: { $avg: '$amount' },
          totalTransactions: { $sum: 1 },
        },
      },
    ]);

    res.status(200).json({
      success: true,
      data: {
        revenueData,
        totals: totals[0] || {},
      },
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get user behavior analytics
// @route   GET /api/v1/admin/analytics/user-behavior
// @access  Private/Admin
exports.getUserBehaviorAnalytics = async (req, res, next) => {
  try {
    const { period = '30d' } = req.query;

    let startDate = new Date();
    if (period === '7d') startDate.setDate(startDate.getDate() - 7);
    else if (period === '30d') startDate.setDate(startDate.getDate() - 30);
    else if (period === '90d') startDate.setDate(startDate.getDate() - 90);

    // User activity
    const activeUsers = await User.aggregate([
      {
        $match: {
          lastLogin: { $gte: startDate },
        },
      },
      {
        $group: {
          _id: '$role',
          count: { $sum: 1 },
        },
      },
    ]);

    // Booking behavior
    const bookingBehavior = await Booking.aggregate([
      {
        $match: { createdAt: { $gte: startDate } },
      },
      {
        $group: {
          _id: '$user',
          bookings: { $sum: 1 },
          totalSpent: { $sum: '$totalPrice' },
          avgBookingValue: { $avg: '$totalPrice' },
        },
      },
      {
        $group: {
          _id: null,
          avgBookingsPerUser: { $avg: '$bookings' },
          avgSpendPerUser: { $avg: '$totalSpent' },
          avgBookingValue: { $avg: '$avgBookingValue' },
        },
      },
    ]);

    // Conversion rates
    const conversionData = await User.aggregate([
      {
        $match: { createdAt: { $gte: startDate } },
      },
      {
        $lookup: {
          from: 'bookings',
          localField: '_id',
          foreignField: 'user',
          as: 'bookings',
        },
      },
      {
        $project: {
          hasBooked: { $gt: [{ $size: '$bookings' }, 0] },
        },
      },
      {
        $group: {
          _id: null,
          totalUsers: { $sum: 1 },
          usersWithBookings: { $sum: { $cond: ['$hasBooked', 1, 0] } },
        },
      },
      {
        $project: {
          conversionRate: {
            $multiply: [
              { $divide: ['$usersWithBookings', '$totalUsers'] },
              100,
            ],
          },
        },
      },
    ]);

    res.status(200).json({
      success: true,
      data: {
        activeUsers,
        bookingBehavior: bookingBehavior[0] || {},
        conversionData: conversionData[0] || {},
      },
    });
  } catch (error) {
    next(error);
  }
};

