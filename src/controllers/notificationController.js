const AppNotification = require('../models/AppNotification');
const User = require('../models/User');
const AuditLog = require('../models/AuditLog');
const { AppError } = require('../middleware/errorHandler');

// @desc    Get all notifications
// @route   GET /api/v1/admin/notifications
// @access  Private/Admin
exports.getNotifications = async (req, res, next) => {
  try {
    const {
      page = 1,
      limit = 20,
      type,
      status,
      recipientType,
      channel,
    } = req.query;

    const query = {};
    if (type) query.type = type;
    if (status) query.status = status;
    if (recipientType) query.recipientType = recipientType;
    if (channel) query.channel = channel;

    const skip = (parseInt(page) - 1) * parseInt(limit);

    const notifications = await AppNotification.find(query)
      .populate('recipient', 'email profile.firstName profile.lastName')
      .populate('createdBy', 'profile.firstName profile.lastName')
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(parseInt(limit));

    const total = await AppNotification.countDocuments(query);

    res.status(200).json({
      success: true,
      data: {
        notifications,
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

// @desc    Send broadcast notification
// @route   POST /api/v1/admin/notifications/broadcast
// @access  Private/Admin
exports.sendBroadcastNotification = async (req, res, next) => {
  try {
    const {
      title,
      message,
      recipientType,
      segment,
      channel,
      priority,
      actionUrl,
      imageUrl,
      scheduledFor,
    } = req.body;

    let recipients = [];

    // Determine recipients based on type
    if (recipientType === 'all') {
      recipients = await User.find({ status: 'active' }).select('_id');
    } else if (recipientType === 'hosts') {
      recipients = await User.find({ role: 'host', status: 'active' }).select('_id');
    } else if (recipientType === 'guests') {
      recipients = await User.find({ role: 'guest', status: 'active' }).select('_id');
    } else if (recipientType === 'segment') {
      // Apply segment logic
      const query = { status: 'active' };
      if (segment === 'new_users') {
        const thirtyDaysAgo = new Date();
        thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
        query.createdAt = { $gte: thirtyDaysAgo };
      } else if (segment === 'inactive_users') {
        const sixtyDaysAgo = new Date();
        sixtyDaysAgo.setDate(sixtyDaysAgo.getDate() - 60);
        query.lastLogin = { $lt: sixtyDaysAgo };
      }
      recipients = await User.find(query).select('_id');
    }

    // Create notifications
    const notificationPromises = recipients.map((recipient) =>
      AppNotification.create({
        recipient: recipient._id,
        recipientType,
        segment,
        type: 'system_announcement',
        title,
        message,
        channel,
        priority: priority || 'normal',
        actionUrl,
        imageUrl,
        scheduledFor: scheduledFor ? new Date(scheduledFor) : undefined,
        createdBy: req.user.id,
      })
    );

    await Promise.all(notificationPromises);

    await AuditLog.create({
      action: 'notification_sent',
      performedBy: req.user.id,
      targetModel: 'AppNotification',
      description: `Sent broadcast notification to ${recipients.length} users`,
      category: 'system',
      metadata: { recipientType, segment, recipientCount: recipients.length },
    });

    res.status(201).json({
      success: true,
      message: `Notification sent to ${recipients.length} users`,
      data: {
        recipientCount: recipients.length,
      },
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Send notification to specific user
// @route   POST /api/v1/admin/notifications/send
// @access  Private/Admin
exports.sendNotification = async (req, res, next) => {
  try {
    const {
      userId,
      type,
      title,
      message,
      channel,
      priority,
      actionUrl,
      data,
    } = req.body;

    const notification = await AppNotification.create({
      recipient: userId,
      recipientType: 'user',
      type,
      title,
      message,
      channel: channel || 'in_app',
      priority: priority || 'normal',
      actionUrl,
      data,
      createdBy: req.user.id,
    });

    await AuditLog.create({
      action: 'notification_sent',
      performedBy: req.user.id,
      targetModel: 'AppNotification',
      targetId: notification._id,
      description: `Sent notification to user`,
      category: 'system',
    });

    res.status(201).json({
      success: true,
      data: notification,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get notification statistics
// @route   GET /api/v1/admin/notifications/stats
// @access  Private/Admin
exports.getNotificationStats = async (req, res, next) => {
  try {
    const { period = '30d' } = req.query;

    let startDate = new Date();
    if (period === '7d') startDate.setDate(startDate.getDate() - 7);
    else if (period === '30d') startDate.setDate(startDate.getDate() - 30);
    else if (period === '90d') startDate.setDate(startDate.getDate() - 90);

    const stats = await AppNotification.aggregate([
      {
        $match: { createdAt: { $gte: startDate } },
      },
      {
        $facet: {
          totalNotifications: [{ $count: 'count' }],
          byStatus: [
            { $group: { _id: '$status', count: { $sum: 1 } } },
          ],
          byChannel: [
            { $group: { _id: '$channel', count: { $sum: 1 } } },
          ],
          byType: [
            { $group: { _id: '$type', count: { $sum: 1 } } },
          ],
          deliveryRate: [
            {
              $group: {
                _id: null,
                total: { $sum: 1 },
                delivered: {
                  $sum: { $cond: [{ $eq: ['$status', 'delivered'] }, 1, 0] },
                },
              },
            },
            {
              $project: {
                rate: {
                  $multiply: [{ $divide: ['$delivered', '$total'] }, 100],
                },
              },
            },
          ],
          readRate: [
            {
              $group: {
                _id: null,
                total: { $sum: 1 },
                read: {
                  $sum: { $cond: ['$isRead', 1, 0] },
                },
              },
            },
            {
              $project: {
                rate: {
                  $multiply: [{ $divide: ['$read', '$total'] }, 100],
                },
              },
            },
          ],
        },
      },
    ]);

    res.status(200).json({
      success: true,
      data: stats[0],
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Delete notification
// @route   DELETE /api/v1/admin/notifications/:id
// @access  Private/Admin
exports.deleteNotification = async (req, res, next) => {
  try {
    const notification = await AppNotification.findById(req.params.id);

    if (!notification) {
      return next(new AppError('Notification not found', 404));
    }

    await notification.remove();

    res.status(200).json({
      success: true,
      message: 'Notification deleted successfully',
    });
  } catch (error) {
    next(error);
  }
};





