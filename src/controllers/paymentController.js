const Transaction = require('../models/Transaction');
const Booking = require('../models/Booking');
const User = require('../models/User');
const AuditLog = require('../models/AuditLog');
const { AppError } = require('../middleware/errorHandler');

// @desc    Get all transactions with filters
// @route   GET /api/v1/admin/payments/transactions
// @access  Private/Admin
exports.getTransactions = async (req, res, next) => {
  try {
    const {
      page = 1,
      limit = 20,
      status,
      type,
      paymentMethod,
      startDate,
      endDate,
      search,
    } = req.query;

    const query = {};

    if (status) query.status = status;
    if (type) query.type = type;
    if (paymentMethod) query.paymentMethod = paymentMethod;
    
    if (startDate || endDate) {
      query.createdAt = {};
      if (startDate) query.createdAt.$gte = new Date(startDate);
      if (endDate) query.createdAt.$lte = new Date(endDate);
    }

    const skip = (parseInt(page) - 1) * parseInt(limit);

    const transactions = await Transaction.find(query)
      .populate('user', 'email profile.firstName profile.lastName')
      .populate('host', 'email profile.firstName profile.lastName')
      .populate('listing', 'title location')
      .populate('booking', 'checkIn checkOut')
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(parseInt(limit));

    const total = await Transaction.countDocuments(query);

    // Calculate statistics
    const stats = await Transaction.aggregate([
      { $match: query },
      {
        $group: {
          _id: null,
          totalAmount: { $sum: '$amount' },
          totalPlatformFee: { $sum: '$platformFee' },
          totalRefunded: { $sum: '$refundedAmount' },
          avgTransaction: { $avg: '$amount' },
        },
      },
    ]);

    res.status(200).json({
      success: true,
      data: {
        transactions,
        stats: stats[0] || {},
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total,
          pages: Math.ceil(total / parseInt(limit)),
        },
      },
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get payment analytics
// @route   GET /api/v1/admin/payments/analytics
// @access  Private/Admin
exports.getPaymentAnalytics = async (req, res, next) => {
  try {
    const { period = '30d' } = req.query;

    let startDate = new Date();
    if (period === '7d') {
      startDate.setDate(startDate.getDate() - 7);
    } else if (period === '30d') {
      startDate.setDate(startDate.getDate() - 30);
    } else if (period === '90d') {
      startDate.setDate(startDate.getDate() - 90);
    } else if (period === '1y') {
      startDate.setFullYear(startDate.getFullYear() - 1);
    }

    // Revenue over time
    const revenueByDay = await Transaction.aggregate([
      {
        $match: {
          createdAt: { $gte: startDate },
          status: 'completed',
        },
      },
      {
        $group: {
          _id: {
            $dateToString: { format: '%Y-%m-%d', date: '$createdAt' },
          },
          revenue: { $sum: '$amount' },
          platformFee: { $sum: '$platformFee' },
          count: { $sum: 1 },
        },
      },
      { $sort: { _id: 1 } },
    ]);

    // Payment method distribution
    const paymentMethods = await Transaction.aggregate([
      {
        $match: {
          createdAt: { $gte: startDate },
          status: 'completed',
        },
      },
      {
        $group: {
          _id: '$paymentMethod',
          count: { $sum: 1 },
          amount: { $sum: '$amount' },
        },
      },
    ]);

    // Transaction status distribution
    const statusDistribution = await Transaction.aggregate([
      {
        $match: { createdAt: { $gte: startDate } },
      },
      {
        $group: {
          _id: '$status',
          count: { $sum: 1 },
          amount: { $sum: '$amount' },
        },
      },
    ]);

    // Top earning hosts
    const topHosts = await Transaction.aggregate([
      {
        $match: {
          createdAt: { $gte: startDate },
          status: 'completed',
        },
      },
      {
        $group: {
          _id: '$host',
          earnings: { $sum: '$hostPayout' },
          transactions: { $sum: 1 },
        },
      },
      { $sort: { earnings: -1 } },
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
        revenueByDay,
        paymentMethods,
        statusDistribution,
        topHosts,
      },
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Process refund
// @route   POST /api/v1/admin/payments/:id/refund
// @access  Private/Admin
exports.processRefund = async (req, res, next) => {
  try {
    const { amount, reason } = req.body;
    const transaction = await Transaction.findById(req.params.id);

    if (!transaction) {
      return next(new AppError('Transaction not found', 404));
    }

    if (transaction.status !== 'completed') {
      return next(new AppError('Can only refund completed transactions', 400));
    }

    if (amount > transaction.amount - transaction.refundedAmount) {
      return next(new AppError('Refund amount exceeds available amount', 400));
    }

    // Create refund transaction
    const refundTransaction = await Transaction.create({
      booking: transaction.booking,
      user: transaction.user,
      host: transaction.host,
      listing: transaction.listing,
      amount: -amount,
      platformFee: 0,
      hostPayout: -amount,
      type: 'refund',
      status: 'completed',
      paymentMethod: transaction.paymentMethod,
      description: `Refund for transaction ${transaction.transactionId}`,
      refundReason: reason,
      processedAt: new Date(),
    });

    // Update original transaction
    transaction.refundedAmount += amount;
    if (transaction.refundedAmount >= transaction.amount) {
      transaction.status = 'refunded';
    }
    await transaction.save();

    // Log action
    await AuditLog.create({
      action: 'refund_issued',
      performedBy: req.user.id,
      targetModel: 'Transaction',
      targetId: transaction._id,
      description: `Refunded ${amount} TZS for transaction ${transaction.transactionId}`,
      category: 'financial',
      severity: 'high',
      metadata: { reason, amount },
    });

    res.status(200).json({
      success: true,
      data: {
        refundTransaction,
        originalTransaction: transaction,
      },
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get pending payouts
// @route   GET /api/v1/admin/payments/payouts
// @access  Private/Admin
exports.getPendingPayouts = async (req, res, next) => {
  try {
    const pendingPayouts = await Transaction.aggregate([
      {
        $match: {
          status: 'completed',
          type: 'booking',
        },
      },
      {
        $group: {
          _id: '$host',
          totalPayout: { $sum: '$hostPayout' },
          transactions: { $sum: 1 },
        },
      },
      {
        $lookup: {
          from: 'users',
          localField: '_id',
          foreignField: '_id',
          as: 'hostInfo',
        },
      },
      { $unwind: '$hostInfo' },
      { $sort: { totalPayout: -1 } },
    ]);

    res.status(200).json({
      success: true,
      data: pendingPayouts,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Mark payout as completed
// @route   POST /api/v1/admin/payments/payouts/:hostId/complete
// @access  Private/Admin
exports.completePayout = async (req, res, next) => {
  try {
    const { amount, paymentReference } = req.body;
    const hostId = req.params.hostId;

    // Create payout transaction
    const payoutTransaction = await Transaction.create({
      user: hostId,
      host: hostId,
      amount: -amount,
      platformFee: 0,
      hostPayout: -amount,
      type: 'payout',
      status: 'completed',
      paymentMethod: 'bank_transfer',
      providerReference: paymentReference,
      description: `Payout to host`,
      processedAt: new Date(),
    });

    // Log action
    await AuditLog.create({
      action: 'payout_completed',
      performedBy: req.user.id,
      targetModel: 'Transaction',
      targetId: payoutTransaction._id,
      description: `Processed payout of ${amount} TZS to host`,
      category: 'financial',
      severity: 'high',
      metadata: { hostId, amount, paymentReference },
    });

    res.status(200).json({
      success: true,
      data: payoutTransaction,
    });
  } catch (error) {
    next(error);
  }
};





