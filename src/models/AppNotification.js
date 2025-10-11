const mongoose = require('mongoose');

const appNotificationSchema = new mongoose.Schema(
  {
    recipient: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
    },
    recipientType: {
      type: String,
      enum: ['user', 'all', 'hosts', 'guests', 'segment'],
      default: 'user',
    },
    segment: {
      type: String,
      enum: ['new_users', 'active_hosts', 'inactive_users', 'premium_users'],
    },
    type: {
      type: String,
      enum: [
        'booking_confirmed', 'booking_cancelled', 'booking_reminder',
        'payment_received', 'payment_failed', 'payout_processed',
        'review_received', 'review_reminder',
        'listing_approved', 'listing_rejected',
        'message_received',
        'dispute_opened', 'dispute_resolved',
        'ticket_response',
        'promotion_available',
        'system_announcement',
        'account_update',
        'verification_required',
        'other'
      ],
      required: true,
    },
    title: {
      type: String,
      required: true,
    },
    message: {
      type: String,
      required: true,
    },
    data: {
      type: Map,
      of: mongoose.Schema.Types.Mixed,
    },
    channel: {
      type: String,
      enum: ['push', 'email', 'sms', 'in_app'],
      default: 'in_app',
    },
    priority: {
      type: String,
      enum: ['low', 'normal', 'high'],
      default: 'normal',
    },
    status: {
      type: String,
      enum: ['pending', 'sent', 'delivered', 'failed', 'read'],
      default: 'pending',
    },
    isRead: {
      type: Boolean,
      default: false,
    },
    readAt: {
      type: Date,
    },
    sentAt: {
      type: Date,
    },
    deliveredAt: {
      type: Date,
    },
    failureReason: {
      type: String,
    },
    actionUrl: {
      type: String,
    },
    imageUrl: {
      type: String,
    },
    expiresAt: {
      type: Date,
    },
    scheduledFor: {
      type: Date,
    },
    createdBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
    },
  },
  {
    timestamps: true,
  }
);

// Indexes
appNotificationSchema.index({ recipient: 1, isRead: 1 });
appNotificationSchema.index({ status: 1 });
appNotificationSchema.index({ type: 1 });
appNotificationSchema.index({ scheduledFor: 1 });
appNotificationSchema.index({ createdAt: -1 });

// TTL index - auto-delete read notifications older than 90 days
appNotificationSchema.index(
  { createdAt: 1 },
  { expireAfterSeconds: 7776000, partialFilterExpression: { isRead: true } }
);

module.exports = mongoose.model('AppNotification', appNotificationSchema);

