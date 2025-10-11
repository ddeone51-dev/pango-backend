const mongoose = require('mongoose');

const NotificationSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  type: {
    type: String,
    enum: [
      'booking_confirmed',
      'booking_cancelled',
      'payment_received',
      'review_received',
      'message_received',
      'listing_approved',
      'payout_processed',
      'reminder',
    ],
    required: true,
  },
  title: {
    en: {
      type: String,
      required: true,
    },
    sw: {
      type: String,
      required: true,
    },
  },
  message: {
    en: {
      type: String,
      required: true,
    },
    sw: {
      type: String,
      required: true,
    },
  },
  data: {
    type: mongoose.Schema.Types.Mixed,
  },
  read: {
    type: Boolean,
    default: false,
  },
  sentAt: {
    type: Date,
    default: Date.now,
  },
  readAt: Date,
}, {
  timestamps: true,
});

// Indexes
NotificationSchema.index({ userId: 1, createdAt: -1 });
NotificationSchema.index({ read: 1 });

module.exports = mongoose.model('Notification', NotificationSchema);





