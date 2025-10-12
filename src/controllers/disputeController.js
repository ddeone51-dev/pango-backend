const Dispute = require('../models/Dispute');
const Booking = require('../models/Booking');
const AuditLog = require('../models/AuditLog');
const AppNotification = require('../models/AppNotification');
const { AppError } = require('../middleware/errorHandler');

// @desc    Get all disputes
// @route   GET /api/v1/admin/disputes
// @access  Private/Admin
exports.getDisputes = async (req, res, next) => {
  try {
    const {
      page = 1,
      limit = 20,
      status,
      priority,
      type,
      assignedTo,
    } = req.query;

    const query = {};
    if (status) query.status = status;
    if (priority) query.priority = priority;
    if (type) query.type = type;
    if (assignedTo) query.assignedTo = assignedTo;

    const skip = (parseInt(page) - 1) * parseInt(limit);

    const disputes = await Dispute.find(query)
      .populate('initiatedBy', 'email profile.firstName profile.lastName')
      .populate('againstUser', 'email profile.firstName profile.lastName')
      .populate('booking')
      .populate('listing', 'title location')
      .populate('assignedTo', 'profile.firstName profile.lastName')
      .sort({ priority: -1, createdAt: -1 })
      .skip(skip)
      .limit(parseInt(limit));

    const total = await Dispute.countDocuments(query);

    // Get statistics
    const stats = await Dispute.aggregate([
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
        disputes,
        stats,
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

// @desc    Get single dispute
// @route   GET /api/v1/admin/disputes/:id
// @access  Private/Admin
exports.getDispute = async (req, res, next) => {
  try {
    const dispute = await Dispute.findById(req.params.id)
      .populate('initiatedBy', 'email profile phoneNumber')
      .populate('againstUser', 'email profile phoneNumber')
      .populate('booking')
      .populate('listing')
      .populate('assignedTo', 'profile')
      .populate('messages.sender', 'profile.firstName profile.lastName')
      .populate('resolution.resolvedBy', 'profile.firstName profile.lastName');

    if (!dispute) {
      return next(new AppError('Dispute not found', 404));
    }

    res.status(200).json({
      success: true,
      data: dispute,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Assign dispute to admin
// @route   PUT /api/v1/admin/disputes/:id/assign
// @access  Private/Admin
exports.assignDispute = async (req, res, next) => {
  try {
    const { adminId } = req.body;
    
    const dispute = await Dispute.findByIdAndUpdate(
      req.params.id,
      {
        assignedTo: adminId || req.user.id,
        status: 'investigating',
      },
      { new: true }
    );

    if (!dispute) {
      return next(new AppError('Dispute not found', 404));
    }

    await AuditLog.create({
      action: 'dispute_assigned',
      performedBy: req.user.id,
      targetModel: 'Dispute',
      targetId: dispute._id,
      description: `Assigned dispute ${dispute.subject} to admin`,
      category: 'support',
    });

    res.status(200).json({
      success: true,
      data: dispute,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Add message to dispute
// @route   POST /api/v1/admin/disputes/:id/messages
// @access  Private/Admin
exports.addMessage = async (req, res, next) => {
  try {
    const { message } = req.body;

    const dispute = await Dispute.findById(req.params.id);

    if (!dispute) {
      return next(new AppError('Dispute not found', 404));
    }

    dispute.messages.push({
      sender: req.user.id,
      message,
      isAdminMessage: true,
    });

    await dispute.save();

    // Send notification to both parties
    await AppNotification.create({
      recipient: dispute.initiatedBy,
      type: 'dispute_update',
      title: 'Dispute Update',
      message: 'Admin has responded to your dispute',
      data: { disputeId: dispute._id },
    });

    res.status(200).json({
      success: true,
      data: dispute,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Resolve dispute
// @route   PUT /api/v1/admin/disputes/:id/resolve
// @access  Private/Admin
exports.resolveDispute = async (req, res, next) => {
  try {
    const { decision, explanation, refundAmount } = req.body;

    const dispute = await Dispute.findById(req.params.id);

    if (!dispute) {
      return next(new AppError('Dispute not found', 404));
    }

    dispute.resolution = {
      decision,
      explanation,
      refundAmount: refundAmount || 0,
      resolvedBy: req.user.id,
      resolvedAt: new Date(),
    };
    dispute.status = 'resolved';

    await dispute.save();

    // Notify all parties
    await AppNotification.create({
      recipient: dispute.initiatedBy,
      type: 'dispute_resolved',
      title: 'Dispute Resolved',
      message: `Your dispute has been resolved: ${decision}`,
      data: { disputeId: dispute._id, decision },
    });

    await AppNotification.create({
      recipient: dispute.againstUser,
      type: 'dispute_resolved',
      title: 'Dispute Resolved',
      message: `The dispute against you has been resolved: ${decision}`,
      data: { disputeId: dispute._id, decision },
    });

    await AuditLog.create({
      action: 'dispute_resolved',
      performedBy: req.user.id,
      targetModel: 'Dispute',
      targetId: dispute._id,
      description: `Resolved dispute with decision: ${decision}`,
      category: 'support',
      severity: 'high',
      metadata: { decision, refundAmount },
    });

    res.status(200).json({
      success: true,
      data: dispute,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Close dispute
// @route   PUT /api/v1/admin/disputes/:id/close
// @access  Private/Admin
exports.closeDispute = async (req, res, next) => {
  try {
    const dispute = await Dispute.findByIdAndUpdate(
      req.params.id,
      {
        status: 'closed',
        closedAt: new Date(),
      },
      { new: true }
    );

    if (!dispute) {
      return next(new AppError('Dispute not found', 404));
    }

    await AuditLog.create({
      action: 'dispute_closed',
      performedBy: req.user.id,
      targetModel: 'Dispute',
      targetId: dispute._id,
      description: `Closed dispute ${dispute.subject}`,
      category: 'support',
    });

    res.status(200).json({
      success: true,
      data: dispute,
    });
  } catch (error) {
    next(error);
  }
};





