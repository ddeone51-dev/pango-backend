const express = require('express');
const { protect } = require('../middleware/auth');
const User = require('../models/User');
const Notification = require('../models/Notification');
const { AppError } = require('../middleware/errorHandler');

const router = express.Router();

router.use(protect);

// @desc    Update user profile
// @route   PUT /api/v1/users/profile
// @access  Private
router.put('/profile', async (req, res, next) => {
  try {
    const fieldsToUpdate = {
      'profile.firstName': req.body.firstName,
      'profile.lastName': req.body.lastName,
      'profile.bio': req.body.bio,
      'profile.dateOfBirth': req.body.dateOfBirth,
      'profile.gender': req.body.gender,
      'profile.nationality': req.body.nationality,
      'profile.languages': req.body.languages,
      'contactInfo.whatsappNumber': req.body.whatsappNumber,
      'contactInfo.alternateEmail': req.body.alternateEmail,
    };

    // Remove undefined fields
    Object.keys(fieldsToUpdate).forEach(key => 
      fieldsToUpdate[key] === undefined && delete fieldsToUpdate[key]
    );

    const user = await User.findByIdAndUpdate(
      req.user.id,
      fieldsToUpdate,
      {
        new: true,
        runValidators: true,
      }
    );

    res.status(200).json({
      success: true,
      data: user,
    });
  } catch (error) {
    next(error);
  }
});

// @desc    Get host payout settings
// @route   GET /api/v1/users/payout-settings
// @access  Private (Host)
router.get('/payout-settings', async (req, res, next) => {
  try {
    if (req.user.role !== 'host') {
      return next(new AppError('Only hosts can access payout settings', 403));
    }

    const user = await User.findById(req.user.id).select('payoutSettings hostStatus');
    const payoutSettings = user?.payoutSettings || {};
    
    // Calculate cooldown information
    let canUpdate = true;
    let daysUntilNextUpdate = 0;
    let nextUpdateDate = null;
    
    if (payoutSettings.lastUpdatedAt) {
      const lastUpdate = new Date(payoutSettings.lastUpdatedAt);
      const now = new Date();
      const daysSinceUpdate = (now - lastUpdate) / (1000 * 60 * 60 * 24);
      const cooldownDays = 2;
      
      if (daysSinceUpdate < cooldownDays) {
        canUpdate = false;
        daysUntilNextUpdate = (cooldownDays - daysSinceUpdate).toFixed(1);
        nextUpdateDate = new Date(lastUpdate.getTime() + (cooldownDays * 24 * 60 * 60 * 1000));
      }
    }

    res.status(200).json({
      success: true,
      data: {
        ...payoutSettings,
        canUpdate,
        daysUntilNextUpdate: canUpdate ? 0 : parseFloat(daysUntilNextUpdate),
        nextUpdateDate: nextUpdateDate ? nextUpdateDate.toISOString() : null,
      },
    });
  } catch (error) {
    next(error);
  }
});

// @desc    Update host payout settings
// @route   PUT /api/v1/users/payout-settings
// @access  Private (Host)
router.put('/payout-settings', async (req, res, next) => {
  try {
    if (req.user.role !== 'host') {
      return next(new AppError('Only hosts can update payout settings', 403));
    }

    if (req.user.hostStatus !== 'approved') {
      return next(new AppError('Host must be approved before adding payout details', 403));
    }

    // Check 2-day cooldown period for security
    const existingPayout = req.user.payoutSettings;
    if (existingPayout?.lastUpdatedAt) {
      const lastUpdate = new Date(existingPayout.lastUpdatedAt);
      const now = new Date();
      const daysSinceUpdate = (now - lastUpdate) / (1000 * 60 * 60 * 24);
      const cooldownDays = 2;
      
      if (daysSinceUpdate < cooldownDays) {
        const remainingDays = (cooldownDays - daysSinceUpdate).toFixed(1);
        return next(new AppError(
          `Payout settings can only be updated once every ${cooldownDays} days for security reasons. Please wait ${remainingDays} more day(s) before updating again.`,
          400
        ));
      }
    }

    const { method, bankAccount, mobileMoney, preferredCurrency = 'TZS' } = req.body;

    if (!method || !['bank_account', 'mobile_money'].includes(method)) {
      return next(new AppError('Invalid payout method', 400));
    }

    const payoutSettings = {
      method,
      preferredCurrency,
      isSetupComplete: true,
      verified: false, // Reset verification when payout details are updated
      lastUpdatedAt: new Date(),
    };

    if (method === 'bank_account') {
      if (!bankAccount) {
        return next(new AppError('Bank account details are required', 400));
      }
      const requiredFields = ['accountName', 'accountNumber', 'bankName'];
      const missing = requiredFields.filter((field) => !bankAccount[field]);
      if (missing.length) {
        return next(new AppError(`Missing bank account fields: ${missing.join(', ')}`, 400));
      }
      payoutSettings.bankAccount = {
        accountName: bankAccount.accountName?.trim(),
        accountNumber: bankAccount.accountNumber?.trim(),
        bankName: bankAccount.bankName?.trim(),
        branchName: bankAccount.branchName?.trim() || '',
        swiftCode: bankAccount.swiftCode?.trim() || '',
      };
    } else if (method === 'mobile_money') {
      if (!mobileMoney) {
        return next(new AppError('Mobile money details are required', 400));
      }
      if (!mobileMoney.phoneNumber || !mobileMoney.provider) {
        return next(new AppError('Mobile money provider and phone number are required', 400));
      }
      payoutSettings.mobileMoney = {
        accountName: mobileMoney.accountName?.trim() || '',
        phoneNumber: mobileMoney.phoneNumber?.trim(),
        provider: mobileMoney.provider?.trim(),
      };
    }

    const updatedUser = await User.findByIdAndUpdate(
      req.user.id,
      { payoutSettings },
      { new: true, runValidators: true },
    ).select('payoutSettings email profile');

    req.user.payoutSettings = updatedUser.payoutSettings;

    // Debug logging
    const logger = require('../utils/logger');
    logger.info(`Payout settings saved for user: ${updatedUser.email}`, {
      method: payoutSettings.method,
      isSetupComplete: payoutSettings.isSetupComplete,
      hasBankAccount: !!payoutSettings.bankAccount,
      hasMobileMoney: !!payoutSettings.mobileMoney,
    });

    res.status(200).json({
      success: true,
      data: updatedUser.payoutSettings,
      message: 'Payout settings saved successfully',
    });
  } catch (error) {
    next(error);
  }
});

// @desc    Update user role (admin only)
// @route   PUT /api/v1/users/update-role
// @access  Private
router.put('/update-role', async (req, res, next) => {
  try {
    const { role } = req.body;
    
    if (!role) {
      return next(new AppError('Role is required', 400));
    }

    const user = await User.findByIdAndUpdate(
      req.user.id,
      { role },
      {
        new: true,
        runValidators: true,
      }
    );

    res.status(200).json({
      success: true,
      data: user,
      message: 'Role updated successfully'
    });
  } catch (error) {
    next(error);
  }
});

// IMPORTANT: Specific routes must come BEFORE generic /:id route

// ============================================
// NOTIFICATION ROUTES
// ============================================

// @desc    Register FCM token for push notifications
// @route   POST /api/v1/users/notifications/register-token
// @access  Private
router.post('/notifications/register-token', async (req, res, next) => {
  try {
    const { token } = req.body;

    if (!token) {
      return next(new AppError('FCM token is required', 400));
    }

    const user = await User.findById(req.user.id);
    
    // Add token to deviceTokens array if not already present
    if (!user.deviceTokens || !Array.isArray(user.deviceTokens)) {
      user.deviceTokens = [];
    }
    
    if (!user.deviceTokens.includes(token)) {
      user.deviceTokens.push(token);
      await user.save();
    }

    res.status(200).json({
      success: true,
      message: 'Token registered successfully',
    });
  } catch (error) {
    next(error);
  }
});

// @desc    Remove FCM token
// @route   DELETE /api/v1/users/notifications/remove-token
// @access  Private
router.delete('/notifications/remove-token', async (req, res, next) => {
  try {
    const { token } = req.body;

    if (!token) {
      return next(new AppError('FCM token is required', 400));
    }

    const user = await User.findById(req.user.id);
    
    if (user.deviceTokens && Array.isArray(user.deviceTokens)) {
      user.deviceTokens = user.deviceTokens.filter(t => t !== token);
      await user.save();
    }

    res.status(200).json({
      success: true,
      message: 'Token removed successfully',
    });
  } catch (error) {
    next(error);
  }
});

// @desc    Get user notifications
// @route   GET /api/v1/users/notifications
// @access  Private
router.get('/notifications', async (req, res, next) => {
  try {
    const { page = 1, limit = 20, unreadOnly = false } = req.query;
    const skip = (parseInt(page) - 1) * parseInt(limit);

    const query = { userId: req.user.id };
    if (unreadOnly === 'true') {
      query.read = false;
    }

    const notifications = await Notification.find(query)
      .sort('-createdAt')
      .skip(skip)
      .limit(parseInt(limit));

    const total = await Notification.countDocuments(query);
    const unreadCount = await Notification.countDocuments({ userId: req.user.id, read: false });

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
        unreadCount,
      },
    });
  } catch (error) {
    next(error);
  }
});

// @desc    Mark notification as read
// @route   PUT /api/v1/users/notifications/:id/read
// @access  Private
router.put('/notifications/:id/read', async (req, res, next) => {
  try {
    const notification = await Notification.findOne({
      _id: req.params.id,
      userId: req.user.id,
    });

    if (!notification) {
      return next(new AppError('Notification not found', 404));
    }

    notification.read = true;
    notification.readAt = new Date();
    await notification.save();

    res.status(200).json({
      success: true,
      message: 'Notification marked as read',
    });
  } catch (error) {
    next(error);
  }
});

// @desc    Mark all notifications as read
// @route   PUT /api/v1/users/notifications/read-all
// @access  Private
router.put('/notifications/read-all', async (req, res, next) => {
  try {
    await Notification.updateMany(
      { userId: req.user.id, read: false },
      { read: true, readAt: new Date() }
    );

    res.status(200).json({
      success: true,
      message: 'All notifications marked as read',
    });
  } catch (error) {
    next(error);
  }
});

// @desc    Get notification preferences
// @route   GET /api/v1/users/notifications/preferences
// @access  Private
router.get('/notifications/preferences', async (req, res, next) => {
  try {
    const user = await User.findById(req.user.id).select('preferences.notifications');
    
    res.status(200).json({
      success: true,
      data: user.preferences?.notifications || {
        push: true,
        email: true,
        sms: false,
      },
    });
  } catch (error) {
    next(error);
  }
});

// @desc    Update notification preferences
// @route   PUT /api/v1/users/notifications/preferences
// @access  Private
router.put('/notifications/preferences', async (req, res, next) => {
  try {
    const { push, email, sms } = req.body;

    const updateData = {};
    if (push !== undefined) updateData['preferences.notifications.push'] = push;
    if (email !== undefined) updateData['preferences.notifications.email'] = email;
    if (sms !== undefined) updateData['preferences.notifications.sms'] = sms;

    const user = await User.findByIdAndUpdate(
      req.user.id,
      { $set: updateData },
      { new: true, runValidators: true }
    ).select('preferences.notifications');

    res.status(200).json({
      success: true,
      data: user.preferences?.notifications,
      message: 'Preferences updated successfully',
    });
  } catch (error) {
    next(error);
  }
});

// @desc    Send test notification
// @route   POST /api/v1/users/notifications/test
// @access  Private
router.post('/notifications/test', async (req, res, next) => {
  try {
    const user = await User.findById(req.user.id);
    const language = user.preferences?.language || 'en';

    // Create test notification
    const notification = await Notification.create({
      userId: req.user.id,
      type: 'reminder',
      title: {
        en: 'Test Notification',
        sw: 'Ujumbe wa Jaribio',
      },
      message: {
        en: 'This is a test notification to verify your notification settings are working correctly.',
        sw: 'Huu ni ujumbe wa jaribio ili kuthibitisha mipangilio yako ya arifa inafanya kazi vizuri.',
      },
      data: {
        screen: 'Home',
      },
    });

    // Send push notification if enabled and token exists
    if (user.preferences?.notifications?.push && user.deviceTokens && user.deviceTokens.length > 0) {
      try {
        const pushNotificationService = require('../services/pushNotificationService');
        await pushNotificationService.sendToUser(req.user.id, {
          title: notification.title[language],
          body: notification.message[language],
          type: notification.type,
          data: {
            notificationId: notification._id.toString(),
            screen: 'Home',
          },
        });
      } catch (pushError) {
        console.error('Failed to send push notification:', pushError);
        // Continue even if push fails
      }
    }

    res.status(200).json({
      success: true,
      message: 'Test notification sent successfully',
      data: notification,
    });
  } catch (error) {
    next(error);
  }
});

// ============================================
// END NOTIFICATION ROUTES
// ============================================

// ============================================
// PRIVACY & SECURITY ROUTES
// ============================================

// @desc    Change password
// @route   PUT /api/v1/users/change-password
// @access  Private
router.put('/change-password', async (req, res, next) => {
  try {
    const { currentPassword, newPassword } = req.body;

    if (!currentPassword || !newPassword) {
      return next(new AppError('Current password and new password are required', 400));
    }

    if (newPassword.length < 6) {
      return next(new AppError('Password must be at least 6 characters', 400));
    }

    const user = await User.findById(req.user.id).select('+password');

    // Check current password
    const isMatch = await user.matchPassword(currentPassword);
    if (!isMatch) {
      return next(new AppError('Current password is incorrect', 401));
    }

    // Update password
    user.password = newPassword;
    await user.save();

    const logger = require('../utils/logger');
    logger.info(`Password changed for user: ${user.email}`);

    res.status(200).json({
      success: true,
      message: 'Password changed successfully',
    });
  } catch (error) {
    next(error);
  }
});

// @desc    Download user data
// @route   GET /api/v1/users/download-data
// @access  Private
router.get('/download-data', async (req, res, next) => {
  try {
    const user = await User.findById(req.user.id)
      .populate('savedListings')
      .select('-password');

    // Get user's bookings
    const Booking = require('../models/Booking');
    const bookings = await Booking.find({ guestId: req.user.id })
      .populate('listingId', 'title location pricing')
      .select('-guestDetails');

    // Get user's listings (if host)
    const Listing = require('../models/Listing');
    const listings = user.role === 'host' 
      ? await Listing.find({ hostId: req.user.id })
      : [];

    // Get user's notifications
    const notifications = await Notification.find({ userId: req.user.id })
      .sort('-createdAt')
      .limit(100);

    // Compile user data
    const userData = {
      profile: {
        email: user.email,
        phoneNumber: user.phoneNumber,
        role: user.role,
        accountStatus: user.accountStatus,
        createdAt: user.createdAt,
        lastLogin: user.lastLogin,
        profile: user.profile,
        preferences: user.preferences,
      },
      bookings: bookings.map(b => ({
        id: b._id,
        listing: b.listingId,
        checkIn: b.checkInDate,
        checkOut: b.checkOutDate,
        status: b.status,
        totalAmount: b.pricing?.total,
        createdAt: b.createdAt,
      })),
      listings: listings.map(l => ({
        id: l._id,
        title: l.title,
        location: l.location,
        pricing: l.pricing,
        status: l.status,
        createdAt: l.createdAt,
      })),
      savedListings: user.savedListings,
      notifications: notifications.map(n => ({
        id: n._id,
        type: n.type,
        title: n.title,
        message: n.message,
        read: n.read,
        createdAt: n.createdAt,
      })),
      exportedAt: new Date().toISOString(),
    };

    // In production, you might want to:
    // 1. Generate a downloadable file (JSON/CSV)
    // 2. Store it temporarily
    // 3. Send download link via email
    // For now, return the data directly

    res.status(200).json({
      success: true,
      message: 'Your data export is ready. A download link has been sent to your email.',
      data: userData,
    });
  } catch (error) {
    next(error);
  }
});

// @desc    Delete user account
// @route   DELETE /api/v1/users/account
// @access  Private
router.delete('/account', async (req, res, next) => {
  try {
    const user = await User.findById(req.user.id);

    if (!user) {
      return next(new AppError('User not found', 404));
    }

    // Soft delete: Mark account as deleted instead of actually deleting
    user.accountStatus = 'deleted';
    user.email = `deleted_${user._id}_${Date.now()}@deleted.local`;
    user.phoneNumber = `deleted_${user._id}_${Date.now()}`;
    await user.save({ validateBeforeSave: false });

    // Optionally, you can also:
    // - Delete associated listings
    // - Cancel active bookings
    // - Remove from all saved listings
    // - Delete notifications

    const logger = require('../utils/logger');
    logger.info(`Account deleted for user: ${user._id}`);

    res.status(200).json({
      success: true,
      message: 'Your account has been deleted successfully',
    });
  } catch (error) {
    next(error);
  }
});

// @desc    Get privacy settings
// @route   GET /api/v1/users/privacy-settings
// @access  Private
router.get('/privacy-settings', async (req, res, next) => {
  try {
    const user = await User.findById(req.user.id).select('preferences.privacy');

    const privacySettings = user.preferences?.privacy || {
      profileVisibility: true,
      locationSharing: false,
      analyticsTracking: true,
    };

    res.status(200).json({
      success: true,
      data: privacySettings,
    });
  } catch (error) {
    next(error);
  }
});

// @desc    Update privacy settings
// @route   PUT /api/v1/users/privacy-settings
// @access  Private
router.put('/privacy-settings', async (req, res, next) => {
  try {
    const { profileVisibility, locationSharing, analyticsTracking } = req.body;

    const updateData = {};
    if (profileVisibility !== undefined) {
      updateData['preferences.privacy.profileVisibility'] = profileVisibility;
    }
    if (locationSharing !== undefined) {
      updateData['preferences.privacy.locationSharing'] = locationSharing;
    }
    if (analyticsTracking !== undefined) {
      updateData['preferences.privacy.analyticsTracking'] = analyticsTracking;
    }

    const user = await User.findByIdAndUpdate(
      req.user.id,
      { $set: updateData },
      { new: true, runValidators: true }
    ).select('preferences.privacy');

    res.status(200).json({
      success: true,
      data: user.preferences?.privacy,
      message: 'Privacy settings updated successfully',
    });
  } catch (error) {
    next(error);
  }
});

// @desc    Get security activity
// @route   GET /api/v1/users/security-activity
// @access  Private
router.get('/security-activity', async (req, res, next) => {
  try {
    // Get recent login activity
    const user = await User.findById(req.user.id).select('lastLogin createdAt');

    // Get recent password changes (could be stored in audit log)
    // For now, return basic activity
    const activity = [
      {
        type: 'login',
        description: 'Successful login',
        timestamp: user.lastLogin || user.createdAt,
        device: 'Unknown',
      },
      {
        type: 'account_created',
        description: 'Account created',
        timestamp: user.createdAt,
        device: 'Unknown',
      },
    ];

    res.status(200).json({
      success: true,
      data: activity,
    });
  } catch (error) {
    next(error);
  }
});

// ============================================
// END PRIVACY & SECURITY ROUTES
// ============================================

// ============================================
// SUPPORT ROUTES
// ============================================

// @desc    Contact support
// @route   POST /api/v1/users/support/contact
// @access  Private
router.post('/support/contact', async (req, res, next) => {
  try {
    const { subject, message, topic } = req.body;

    if (!subject || !message) {
      return next(new AppError('Subject and message are required', 400));
    }

    // Map topic to category
    const topicToCategory = {
      general: 'other',
      booking: 'booking',
      payment: 'payment',
      hosting: 'listing',
      technical: 'technical',
    };

    const category = topicToCategory[topic] || 'other';

    // Create support ticket
    const SupportTicket = require('../models/SupportTicket');
    const ticket = await SupportTicket.create({
      user: req.user.id,
      category,
      subject: subject.trim(),
      description: message.trim(),
      priority: 'medium',
      status: 'open',
      messages: [{
        sender: req.user.id,
        message: message.trim(),
        isStaffReply: false,
      }],
    });

    // Send notification to admins (optional)
    // You can add notification logic here

    const logger = require('../utils/logger');
    logger.info(`Support ticket created: ${ticket.ticketNumber} by user: ${req.user.email}`);

    res.status(201).json({
      success: true,
      message: 'Your support request has been submitted successfully',
      data: {
        ticketNumber: ticket.ticketNumber,
        ticketId: ticket._id,
      },
    });
  } catch (error) {
    next(error);
  }
});

// @desc    Get user's support tickets
// @route   GET /api/v1/users/support/tickets
// @access  Private
router.get('/support/tickets', async (req, res, next) => {
  try {
    const { page = 1, limit = 20, status } = req.query;
    const skip = (parseInt(page) - 1) * parseInt(limit);

    const query = { user: req.user.id };
    if (status) {
      query.status = status;
    }

    const SupportTicket = require('../models/SupportTicket');
    const tickets = await SupportTicket.find(query)
      .sort('-createdAt')
      .skip(skip)
      .limit(parseInt(limit))
      .select('ticketNumber subject category status priority createdAt updatedAt');

    const total = await SupportTicket.countDocuments(query);

    res.status(200).json({
      success: true,
      data: {
        tickets,
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
});

// @desc    Get single support ticket
// @route   GET /api/v1/users/support/tickets/:id
// @access  Private
router.get('/support/tickets/:id', async (req, res, next) => {
  try {
    const SupportTicket = require('../models/SupportTicket');
    const ticket = await SupportTicket.findOne({
      _id: req.params.id,
      user: req.user.id,
    }).populate('messages.sender', 'profile.firstName profile.lastName email');

    if (!ticket) {
      return next(new AppError('Support ticket not found', 404));
    }

    res.status(200).json({
      success: true,
      data: ticket,
    });
  } catch (error) {
    next(error);
  }
});

// ============================================
// END SUPPORT ROUTES
// ============================================

// @desc    Get saved listings
// @route   GET /api/v1/users/saved-listings
// @access  Private
router.get('/saved-listings', async (req, res, next) => {
  try {
    const user = await User.findById(req.user.id).populate('savedListings');

    res.status(200).json({
      success: true,
      data: user.savedListings,
    });
  } catch (error) {
    next(error);
  }
});

// @desc    Save listing
// @route   POST /api/v1/users/saved-listings/:listingId
// @access  Private
router.post('/saved-listings/:listingId', async (req, res, next) => {
  try {
    const user = await User.findById(req.user.id);

    if (!user.savedListings.includes(req.params.listingId)) {
      user.savedListings.push(req.params.listingId);
      await user.save();
    }

    res.status(200).json({
      success: true,
      message: 'Listing saved successfully',
    });
  } catch (error) {
    next(error);
  }
});

// @desc    Remove saved listing
// @route   DELETE /api/v1/users/saved-listings/:listingId
// @access  Private
router.delete('/saved-listings/:listingId', async (req, res, next) => {
  try {
    const user = await User.findById(req.user.id);

    user.savedListings = user.savedListings.filter(
      id => id.toString() !== req.params.listingId
    );
    await user.save();

    res.status(200).json({
      success: true,
      message: 'Listing removed from saved',
    });
  } catch (error) {
    next(error);
  }
});

// @desc    Get user by ID
// @route   GET /api/v1/users/:id
// @access  Private
router.get('/:id', async (req, res, next) => {
  try {
    const user = await User.findById(req.params.id).select('-password');

    if (!user) {
      return next(new AppError('User not found', 404));
    }

    res.status(200).json({
      success: true,
      data: user,
    });
  } catch (error) {
    next(error);
  }
});

module.exports = router;



