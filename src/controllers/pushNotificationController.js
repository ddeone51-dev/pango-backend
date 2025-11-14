const pushNotificationService = require('../services/pushNotificationService');
const User = require('../models/User');

// @desc    Register device token for push notifications
// @route   POST /api/notifications/register-token
// @access  Private
exports.registerDeviceToken = async (req, res) => {
  try {
    const { token } = req.body;

    if (!token) {
      return res.status(400).json({
        success: false,
        message: 'Device token is required',
      });
    }

    // Add token to user's device tokens if not already present
    const user = await User.findById(req.user._id);
    
    if (!user.deviceTokens.includes(token)) {
      user.deviceTokens.push(token);
      await user.save();
    }

    res.status(200).json({
      success: true,
      message: 'Device token registered successfully',
    });
  } catch (error) {
    console.error('Error registering device token:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while registering device token',
      error: error.message,
    });
  }
};

// @desc    Remove device token
// @route   DELETE /api/notifications/remove-token
// @access  Private
exports.removeDeviceToken = async (req, res) => {
  try {
    const { token } = req.body;

    if (!token) {
      return res.status(400).json({
        success: false,
        message: 'Device token is required',
      });
    }

    await User.findByIdAndUpdate(req.user._id, {
      $pull: { deviceTokens: token },
    });

    res.status(200).json({
      success: true,
      message: 'Device token removed successfully',
    });
  } catch (error) {
    console.error('Error removing device token:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while removing device token',
      error: error.message,
    });
  }
};

// @desc    Update notification preferences
// @route   PUT /api/notifications/preferences
// @access  Private
exports.updateNotificationPreferences = async (req, res) => {
  try {
    const { push, email, sms } = req.body;

    const updateData = {};
    if (push !== undefined) updateData['preferences.notifications.push'] = push;
    if (email !== undefined) updateData['preferences.notifications.email'] = email;
    if (sms !== undefined) updateData['preferences.notifications.sms'] = sms;

    const user = await User.findByIdAndUpdate(
      req.user._id,
      { $set: updateData },
      { new: true }
    ).select('preferences.notifications');

    res.status(200).json({
      success: true,
      data: user.preferences.notifications,
    });
  } catch (error) {
    console.error('Error updating notification preferences:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while updating preferences',
      error: error.message,
    });
  }
};

// @desc    Get notification preferences
// @route   GET /api/notifications/preferences
// @access  Private
exports.getNotificationPreferences = async (req, res) => {
  try {
    const user = await User.findById(req.user._id).select('preferences.notifications');

    res.status(200).json({
      success: true,
      data: user.preferences.notifications,
    });
  } catch (error) {
    console.error('Error fetching notification preferences:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching preferences',
      error: error.message,
    });
  }
};

// @desc    Send test notification
// @route   POST /api/notifications/test
// @access  Private
exports.sendTestNotification = async (req, res) => {
  try {
    const result = await pushNotificationService.sendToUser(req.user._id.toString(), {
      title: 'Test Notification from Pango',
      body: 'If you see this, push notifications are working! 🎉',
      type: 'test',
      data: {},
    });

    if (result.success) {
      res.status(200).json({
        success: true,
        message: 'Test notification sent successfully',
        data: result,
      });
    } else {
      res.status(400).json({
        success: false,
        message: 'Failed to send test notification',
        reason: result.reason || result.error,
      });
    }
  } catch (error) {
    console.error('Error sending test notification:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while sending test notification',
      error: error.message,
    });
  }
};

// @desc    Send broadcast notification (Admin only)
// @route   POST /api/admin/notifications/broadcast
// @access  Private/Admin
exports.sendBroadcastNotification = async (req, res) => {
  try {
    const { title, body, type, data } = req.body;

    if (!title || !body) {
      return res.status(400).json({
        success: false,
        message: 'Title and body are required',
      });
    }

    const result = await pushNotificationService.sendBroadcast({
      title,
      body,
      type: type || 'announcement',
      data: data || {},
    });

    res.status(200).json({
      success: true,
      message: 'Broadcast notification sent',
      data: result,
    });
  } catch (error) {
    console.error('Error sending broadcast notification:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while sending broadcast',
      error: error.message,
    });
  }
};

module.exports = exports;





