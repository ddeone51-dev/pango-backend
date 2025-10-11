const mongoose = require('mongoose');

const supportTicketSchema = new mongoose.Schema(
  {
    ticketNumber: {
      type: String,
      required: true,
    },
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    category: {
      type: String,
      enum: [
        'account',
        'booking',
        'payment',
        'technical',
        'listing',
        'verification',
        'cancellation',
        'complaint',
        'feature_request',
        'other'
      ],
      required: true,
    },
    priority: {
      type: String,
      enum: ['low', 'medium', 'high', 'urgent'],
      default: 'medium',
    },
    status: {
      type: String,
      enum: ['open', 'in_progress', 'waiting_for_customer', 'resolved', 'closed'],
      default: 'open',
    },
    subject: {
      type: String,
      required: true,
      maxlength: 200,
    },
    description: {
      type: String,
      required: true,
      maxlength: 2000,
    },
    attachments: [{
      filename: String,
      url: String,
      uploadedAt: {
        type: Date,
        default: Date.now,
      },
    }],
    messages: [{
      sender: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true,
      },
      message: {
        type: String,
        required: true,
      },
      isStaffReply: {
        type: Boolean,
        default: false,
      },
      timestamp: {
        type: Date,
        default: Date.now,
      },
    }],
    assignedTo: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
    },
    relatedBooking: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Booking',
    },
    relatedListing: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Listing',
    },
    satisfaction: {
      rating: {
        type: Number,
        min: 1,
        max: 5,
      },
      feedback: String,
      ratedAt: Date,
    },
    resolvedAt: {
      type: Date,
    },
    closedAt: {
      type: Date,
    },
    tags: [String],
    internalNotes: [{
      note: String,
      addedBy: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
      },
      addedAt: {
        type: Date,
        default: Date.now,
      },
    }],
  },
  {
    timestamps: true,
  }
);

// Auto-generate ticket number
supportTicketSchema.pre('save', async function(next) {
  if (!this.ticketNumber) {
    const count = await mongoose.model('SupportTicket').countDocuments();
    this.ticketNumber = `TKT-${String(count + 1).padStart(6, '0')}`;
  }
  next();
});

// Indexes
supportTicketSchema.index({ ticketNumber: 1 }, { unique: true });
supportTicketSchema.index({ user: 1 });
supportTicketSchema.index({ status: 1 });
supportTicketSchema.index({ priority: 1 });
supportTicketSchema.index({ assignedTo: 1 });
supportTicketSchema.index({ category: 1 });
supportTicketSchema.index({ createdAt: -1 });

module.exports = mongoose.model('SupportTicket', supportTicketSchema);

