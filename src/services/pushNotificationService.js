const admin = require('firebase-admin');
const User = require('../models/User');

// Initialize Firebase Admin (should be done once in server.js)
// This is a placeholder - actual initialization happens in server.js
let firebaseApp = null;

try {
  firebaseApp = admin.app();
} catch (e) {
  // Will be initialized in server.js
  console.log('Firebase Admin not yet initialized');
}

/**
 * Push Notification Service
 * Handles sending push notifications via Firebase Cloud Messaging (FCM)
 */
class PushNotificationService {
  /**
   * Send push notification to a single user
   * @param {String} userId - User ID to send notification to
   * @param {Object} notification - Notification data
   */
  async sendToUser(userId, notification) {
    try {
      const user = await User.findById(userId);
      
      if (!user || !user.deviceTokens || user.deviceTokens.length === 0) {
        console.log(`No device tokens found for user ${userId}`);
        return { success: false, reason: 'No device tokens' };
      }

      // Check if user has push notifications enabled
      if (!user.preferences?.notifications?.push) {
        console.log(`Push notifications disabled for user ${userId}`);
        return { success: false, reason: 'Push notifications disabled' };
      }

      const message = {
        notification: {
          title: notification.title,
          body: notification.body,
        },
        data: {
          type: notification.type || 'general',
          ...notification.data,
        },
        android: {
          priority: 'high',
          notification: {
            sound: 'default',
            channelId: 'pango_notifications',
            priority: 'high',
          },
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
              badge: 1,
            },
          },
        },
        tokens: user.deviceTokens,
      };

      const response = await admin.messaging().sendEachForMultitoken(message);
      
      // Remove invalid tokens
      const invalidTokens = [];
      response.responses.forEach((resp, idx) => {
        if (!resp.success) {
          invalidTokens.push(user.deviceTokens[idx]);
        }
      });

      if (invalidTokens.length > 0) {
        await User.findByIdAndUpdate(userId, {
          $pull: { deviceTokens: { $in: invalidTokens } },
        });
      }

      return {
        success: response.successCount > 0,
        successCount: response.successCount,
        failureCount: response.failureCount,
      };
    } catch (error) {
      console.error('Error sending push notification:', error);
      return { success: false, error: error.message };
    }
  }

  /**
   * Send push notification to multiple users
   * @param {Array} userIds - Array of user IDs
   * @param {Object} notification - Notification data
   */
  async sendToMultipleUsers(userIds, notification) {
    const results = await Promise.all(
      userIds.map(userId => this.sendToUser(userId, notification))
    );
    
    const successCount = results.filter(r => r.success).length;
    return {
      success: successCount > 0,
      totalUsers: userIds.length,
      successCount,
      failureCount: userIds.length - successCount,
    };
  }

  /**
   * Send notification about new booking
   */
  async sendBookingConfirmation(booking) {
    const notification = {
      title: 'Booking Confirmed! 🎉',
      body: `Your booking at ${booking.listingId.title.en} is confirmed for ${new Date(booking.checkInDate).toLocaleDateString()}.`,
      type: 'booking_confirmed',
      data: {
        bookingId: booking._id.toString(),
        listingId: booking.listingId._id.toString(),
        screen: 'BookingDetail',
      },
    };

    return await this.sendToUser(booking.guestId.toString(), notification);
  }

  /**
   * Notify host about new booking request
   */
  async sendNewBookingToHost(booking) {
    const notification = {
      title: 'New Booking Request 📬',
      body: `You have a new booking request for ${booking.listingId.title.en}.`,
      type: 'new_booking',
      data: {
        bookingId: booking._id.toString(),
        listingId: booking.listingId._id.toString(),
        screen: 'HostBookings',
      },
    };

    return await this.sendToUser(booking.hostId.toString(), notification);
  }

  /**
   * Notify guest about booking cancellation
   */
  async sendBookingCancellation(booking, cancelledBy) {
    const notification = {
      title: 'Booking Cancelled',
      body: `Your booking at ${booking.listingId.title.en} has been cancelled${cancelledBy === 'host' ? ' by the host' : ''}.`,
      type: 'booking_cancelled',
      data: {
        bookingId: booking._id.toString(),
        listingId: booking.listingId._id.toString(),
        screen: 'BookingDetail',
      },
    };

    return await this.sendToUser(booking.guestId.toString(), notification);
  }

  /**
   * Remind guest about upcoming check-in
   */
  async sendCheckInReminder(booking) {
    const notification = {
      title: 'Check-in Tomorrow! 🏠',
      body: `Your check-in at ${booking.listingId.title.en} is tomorrow. Have a great stay!`,
      type: 'checkin_reminder',
      data: {
        bookingId: booking._id.toString(),
        listingId: booking.listingId._id.toString(),
        screen: 'BookingDetail',
      },
    };

    return await this.sendToUser(booking.guestId.toString(), notification);
  }

  /**
   * Request review after checkout
   */
  async sendReviewRequest(booking) {
    const notification = {
      title: 'How was your stay? ⭐',
      body: `Share your experience at ${booking.listingId.title.en} with other travelers.`,
      type: 'review_request',
      data: {
        bookingId: booking._id.toString(),
        listingId: booking.listingId._id.toString(),
        screen: 'WriteReview',
      },
    };

    return await this.sendToUser(booking.guestId.toString(), notification);
  }

  /**
   * Notify about new review
   */
  async sendNewReviewNotification(review, recipientId) {
    const isHost = review.reviewType === 'guest_to_host';
    
    const notification = {
      title: 'New Review Received ⭐',
      body: isHost 
        ? `You received a ${review.ratings.overall}-star review for your property!`
        : `You received a review from your host.`,
      type: 'new_review',
      data: {
        reviewId: review._id.toString(),
        listingId: review.listingId.toString(),
        screen: isHost ? 'ListingReviews' : 'MyReviews',
      },
    };

    return await this.sendToUser(recipientId, notification);
  }

  /**
   * Notify about host response to review
   */
  async sendReviewResponseNotification(review) {
    const notification = {
      title: 'Host Responded to Your Review 💬',
      body: 'The host has responded to your review.',
      type: 'review_response',
      data: {
        reviewId: review._id.toString(),
        listingId: review.listingId.toString(),
        screen: 'ReviewDetail',
      },
    };

    return await this.sendToUser(review.authorId.toString(), notification);
  }

  /**
   * Send payment confirmation
   */
  async sendPaymentConfirmation(booking, amount) {
    const notification = {
      title: 'Payment Successful ✅',
      body: `Payment of ${amount} TZS confirmed for your booking.`,
      type: 'payment_confirmed',
      data: {
        bookingId: booking._id.toString(),
        screen: 'BookingDetail',
      },
    };

    return await this.sendToUser(booking.guestId.toString(), notification);
  }

  /**
   * Send price drop notification for favorited listing
   */
  async sendPriceDropNotification(userId, listing, oldPrice, newPrice) {
    const discount = Math.round(((oldPrice - newPrice) / oldPrice) * 100);
    
    const notification = {
      title: `Price Drop Alert! 💰`,
      body: `${listing.title.en} is now ${discount}% off! Book before it's gone.`,
      type: 'price_drop',
      data: {
        listingId: listing._id.toString(),
        screen: 'ListingDetail',
      },
    };

    return await this.sendToUser(userId, notification);
  }

  /**
   * Send special offer notification
   */
  async sendSpecialOffer(userId, offer) {
    const notification = {
      title: offer.title || 'Special Offer! 🎁',
      body: offer.message,
      type: 'special_offer',
      data: {
        offerId: offer._id?.toString(),
        screen: 'Offers',
        ...offer.data,
      },
    };

    return await this.sendToUser(userId, notification);
  }

  /**
   * Broadcast notification to all users
   */
  async sendBroadcast(notification) {
    try {
      // Get all users with push notifications enabled
      const users = await User.find({
        'preferences.notifications.push': true,
        deviceTokens: { $exists: true, $ne: [] },
      }).select('deviceTokens');

      const allTokens = users.reduce((acc, user) => {
        return acc.concat(user.deviceTokens);
      }, []);

      if (allTokens.length === 0) {
        return { success: false, reason: 'No users to notify' };
      }

      // FCM allows max 500 tokens per request
      const batches = [];
      for (let i = 0; i < allTokens.length; i += 500) {
        batches.push(allTokens.slice(i, i + 500));
      }

      let totalSuccess = 0;
      let totalFailure = 0;

      for (const batch of batches) {
        const message = {
          notification: {
            title: notification.title,
            body: notification.body,
          },
          data: {
            type: notification.type || 'general',
            ...notification.data,
          },
          tokens: batch,
        };

        const response = await admin.messaging().sendEachForMultitoken(message);
        totalSuccess += response.successCount;
        totalFailure += response.failureCount;
      }

      return {
        success: true,
        totalTokens: allTokens.length,
        successCount: totalSuccess,
        failureCount: totalFailure,
      };
    } catch (error) {
      console.error('Error sending broadcast notification:', error);
      return { success: false, error: error.message };
    }
  }
}

module.exports = new PushNotificationService();




