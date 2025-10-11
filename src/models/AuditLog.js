const mongoose = require('mongoose');

const auditLogSchema = new mongoose.Schema(
  {
    action: {
      type: String,
      required: true,
      enum: [
        'user_created', 'user_updated', 'user_deleted', 'user_suspended', 'user_activated',
        'listing_created', 'listing_updated', 'listing_deleted', 'listing_approved', 'listing_rejected',
        'booking_created', 'booking_updated', 'booking_cancelled',
        'payment_processed', 'refund_issued', 'payout_completed',
        'dispute_opened', 'dispute_resolved', 'dispute_closed',
        'ticket_created', 'ticket_resolved', 'ticket_closed',
        'promotion_created', 'promotion_updated', 'promotion_deleted',
        'review_moderated', 'review_deleted',
        'settings_updated', 'admin_login', 'admin_logout',
        'content_flagged', 'content_approved', 'content_rejected',
        'notification_sent', 'email_sent',
        'other'
      ],
    },
    performedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    targetModel: {
      type: String,
      enum: ['User', 'Listing', 'Booking', 'Transaction', 'Dispute', 'SupportTicket', 'Promotion', 'Review', 'Settings'],
    },
    targetId: {
      type: mongoose.Schema.Types.ObjectId,
    },
    targetName: {
      type: String,
    },
    description: {
      type: String,
      required: true,
    },
    changes: {
      before: {
        type: Map,
        of: mongoose.Schema.Types.Mixed,
      },
      after: {
        type: Map,
        of: mongoose.Schema.Types.Mixed,
      },
    },
    ipAddress: {
      type: String,
    },
    userAgent: {
      type: String,
    },
    severity: {
      type: String,
      enum: ['low', 'medium', 'high', 'critical'],
      default: 'low',
    },
    category: {
      type: String,
      enum: ['user_management', 'content_management', 'financial', 'security', 'system', 'support'],
      required: true,
    },
    metadata: {
      type: Map,
      of: mongoose.Schema.Types.Mixed,
    },
  },
  {
    timestamps: true,
  }
);

// Indexes
auditLogSchema.index({ performedBy: 1 });
auditLogSchema.index({ action: 1 });
auditLogSchema.index({ targetModel: 1, targetId: 1 });
auditLogSchema.index({ category: 1 });
auditLogSchema.index({ severity: 1 });
auditLogSchema.index({ createdAt: -1 });

// TTL index - auto-delete logs older than 1 year
auditLogSchema.index({ createdAt: 1 }, { expireAfterSeconds: 31536000 });

module.exports = mongoose.model('AuditLog', auditLogSchema);

