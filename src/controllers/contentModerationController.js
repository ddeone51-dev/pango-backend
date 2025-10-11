const FlaggedContent = require('../models/FlaggedContent');
const Review = require('../models/Review');
const Listing = require('../models/Listing');
const User = require('../models/User');
const AuditLog = require('../models/AuditLog');
const AppNotification = require('../models/AppNotification');
const { AppError } = require('../middleware/errorHandler');

// @desc    Get all flagged content
// @route   GET /api/v1/admin/moderation/flagged
// @access  Private/Admin
exports.getFlaggedContent = async (req, res, next) => {
  try {
    const {
      page = 1,
      limit = 20,
      status,
      contentType,
      priority,
      reason,
    } = req.query;

    const query = {};
    if (status) query.status = status;
    if (contentType) query.contentType = contentType;
    if (priority) query.priority = priority;
    if (reason) query.reason = reason;

    const skip = (parseInt(page) - 1) * parseInt(limit);

    const flaggedItems = await FlaggedContent.find(query)
      .populate('contentOwner', 'email profile.firstName profile.lastName')
      .populate('reportedBy', 'email profile.firstName profile.lastName')
      .populate('reviewedBy', 'profile.firstName profile.lastName')
      .sort({ priority: -1, createdAt: -1 })
      .skip(skip)
      .limit(parseInt(limit));

    const total = await FlaggedContent.countDocuments(query);

    // Get statistics
    const stats = await FlaggedContent.aggregate([
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
        flaggedItems,
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

// @desc    Review flagged content
// @route   PUT /api/v1/admin/moderation/flagged/:id/review
// @access  Private/Admin
exports.reviewFlaggedContent = async (req, res, next) => {
  try {
    const { action, reviewNotes, actionDetails } = req.body;

    const flaggedItem = await FlaggedContent.findById(req.params.id);

    if (!flaggedItem) {
      return next(new AppError('Flagged content not found', 404));
    }

    flaggedItem.status = action === 'dismiss' ? 'dismissed' : 'action_taken';
    flaggedItem.action = action;
    flaggedItem.reviewNotes = reviewNotes;
    flaggedItem.actionDetails = actionDetails;
    flaggedItem.reviewedBy = req.user.id;
    flaggedItem.reviewedAt = new Date();

    await flaggedItem.save();

    // Take appropriate action
    if (action === 'content_removed') {
      if (flaggedItem.contentType === 'listing') {
        await Listing.findByIdAndUpdate(flaggedItem.contentId, {
          status: 'removed',
        });
      } else if (flaggedItem.contentType === 'review') {
        await Review.findByIdAndUpdate(flaggedItem.contentId, {
          isHidden: true,
        });
      }
    } else if (action === 'user_suspended') {
      await User.findByIdAndUpdate(flaggedItem.contentOwner, {
        status: 'suspended',
        suspendedUntil: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000), // 30 days
      });

      // Notify user
      await AppNotification.create({
        recipient: flaggedItem.contentOwner,
        type: 'account_update',
        title: 'Account Suspended',
        message: 'Your account has been suspended due to policy violations',
        priority: 'high',
      });
    } else if (action === 'warning_sent') {
      await AppNotification.create({
        recipient: flaggedItem.contentOwner,
        type: 'account_update',
        title: 'Content Policy Warning',
        message: actionDetails || 'Your content has violated our policies',
        priority: 'high',
      });
    }

    // Log action
    await AuditLog.create({
      action: 'content_moderated',
      performedBy: req.user.id,
      targetModel: 'FlaggedContent',
      targetId: flaggedItem._id,
      description: `Reviewed flagged ${flaggedItem.contentType}: ${action}`,
      category: 'content_management',
      severity: action === 'user_suspended' || action === 'account_terminated' ? 'critical' : 'medium',
      metadata: { action, contentType: flaggedItem.contentType },
    });

    res.status(200).json({
      success: true,
      data: flaggedItem,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get all reviews for moderation
// @route   GET /api/v1/admin/moderation/reviews
// @access  Private/Admin
exports.getReviewsForModeration = async (req, res, next) => {
  try {
    const { page = 1, limit = 20, rating, flagged } = req.query;

    const query = {};
    if (rating) query.rating = parseInt(rating);
    if (flagged === 'true') query.isFlagged = true;

    const skip = (parseInt(page) - 1) * parseInt(limit);

    const reviews = await Review.find(query)
      .populate('user', 'email profile.firstName profile.lastName')
      .populate('listing', 'title location')
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(parseInt(limit));

    const total = await Review.countDocuments(query);

    res.status(200).json({
      success: true,
      data: {
        reviews,
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

// @desc    Hide/unhide review
// @route   PUT /api/v1/admin/moderation/reviews/:id/toggle-visibility
// @access  Private/Admin
exports.toggleReviewVisibility = async (req, res, next) => {
  try {
    const review = await Review.findById(req.params.id);

    if (!review) {
      return next(new AppError('Review not found', 404));
    }

    review.isHidden = !review.isHidden;
    await review.save();

    await AuditLog.create({
      action: 'review_moderated',
      performedBy: req.user.id,
      targetModel: 'Review',
      targetId: review._id,
      description: `${review.isHidden ? 'Hidden' : 'Unhidden'} review`,
      category: 'content_management',
    });

    res.status(200).json({
      success: true,
      data: review,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Delete review
// @route   DELETE /api/v1/admin/moderation/reviews/:id
// @access  Private/Admin
exports.deleteReview = async (req, res, next) => {
  try {
    const review = await Review.findById(req.params.id);

    if (!review) {
      return next(new AppError('Review not found', 404));
    }

    await review.remove();

    await AuditLog.create({
      action: 'review_deleted',
      performedBy: req.user.id,
      targetModel: 'Review',
      targetId: review._id,
      description: 'Deleted review',
      category: 'content_management',
      severity: 'high',
    });

    res.status(200).json({
      success: true,
      message: 'Review deleted successfully',
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get moderation statistics
// @route   GET /api/v1/admin/moderation/stats
// @access  Private/Admin
exports.getModerationStats = async (req, res, next) => {
  try {
    const { period = '30d' } = req.query;

    let startDate = new Date();
    if (period === '7d') startDate.setDate(startDate.getDate() - 7);
    else if (period === '30d') startDate.setDate(startDate.getDate() - 30);
    else if (period === '90d') startDate.setDate(startDate.getDate() - 90);

    const flaggedStats = await FlaggedContent.aggregate([
      {
        $match: { createdAt: { $gte: startDate } },
      },
      {
        $facet: {
          byContentType: [
            { $group: { _id: '$contentType', count: { $sum: 1 } } },
          ],
          byReason: [
            { $group: { _id: '$reason', count: { $sum: 1 } } },
          ],
          byAction: [
            { $group: { _id: '$action', count: { $sum: 1 } } },
          ],
          pending: [
            {
              $match: { status: 'pending' },
            },
            { $count: 'count' },
          ],
        },
      },
    ]);

    res.status(200).json({
      success: true,
      data: flaggedStats[0],
    });
  } catch (error) {
    next(error);
  }
};

