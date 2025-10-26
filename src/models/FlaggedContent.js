const mongoose = require('mongoose');

const flaggedContentSchema = new mongoose.Schema(
  {
    contentType: {
      type: String,
      enum: ['listing', 'review', 'user_profile', 'message', 'image'],
      required: true,
    },
    contentId: {
      type: mongoose.Schema.Types.ObjectId,
      required: true,
    },
    contentOwner: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    reportedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    reason: {
      type: String,
      enum: [
        'inappropriate_content',
        'spam',
        'fraud',
        'false_information',
        'harassment',
        'violence',
        'hate_speech',
        'copyright',
        'privacy_violation',
        'other'
      ],
      required: true,
    },
    description: {
      type: String,
      required: true,
      maxlength: 1000,
    },
    evidence: [{
      type: String, // URLs to screenshots/images
    }],
    priority: {
      type: String,
      enum: ['low', 'medium', 'high', 'critical'],
      default: 'medium',
    },
    status: {
      type: String,
      enum: ['pending', 'under_review', 'action_taken', 'dismissed', 'escalated'],
      default: 'pending',
    },
    reviewedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
    },
    reviewNotes: {
      type: String,
    },
    action: {
      type: String,
      enum: ['none', 'warning_sent', 'content_removed', 'user_suspended', 'account_terminated'],
    },
    actionDetails: {
      type: String,
    },
    reviewedAt: {
      type: Date,
    },
  },
  {
    timestamps: true,
  }
);

// Indexes
flaggedContentSchema.index({ contentType: 1, contentId: 1 });
flaggedContentSchema.index({ status: 1 });
flaggedContentSchema.index({ priority: 1 });
flaggedContentSchema.index({ reportedBy: 1 });
flaggedContentSchema.index({ createdAt: -1 });

module.exports = mongoose.model('FlaggedContent', flaggedContentSchema);






