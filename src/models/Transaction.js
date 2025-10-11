const mongoose = require('mongoose');

const transactionSchema = new mongoose.Schema(
  {
    booking: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Booking',
      required: true,
    },
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    host: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    listing: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Listing',
      required: true,
    },
    amount: {
      type: Number,
      required: true,
    },
    platformFee: {
      type: Number,
      default: 0,
    },
    hostPayout: {
      type: Number,
      required: true,
    },
    currency: {
      type: String,
      default: 'TZS',
    },
    type: {
      type: String,
      enum: ['booking', 'refund', 'payout', 'cancellation_fee'],
      required: true,
    },
    status: {
      type: String,
      enum: ['pending', 'completed', 'failed', 'refunded', 'cancelled'],
      default: 'pending',
    },
    paymentMethod: {
      type: String,
      enum: ['mobile_money', 'card', 'bank_transfer', 'cash'],
      required: true,
    },
    paymentProvider: {
      type: String,
      enum: ['mpesa', 'tigopesa', 'airtel_money', 'stripe', 'manual'],
    },
    transactionId: {
      type: String,
      unique: true,
      sparse: true,
    },
    providerReference: {
      type: String,
    },
    description: {
      type: String,
    },
    refundedAmount: {
      type: Number,
      default: 0,
    },
    refundReason: {
      type: String,
    },
    refundedAt: {
      type: Date,
    },
    processedAt: {
      type: Date,
    },
    failureReason: {
      type: String,
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
transactionSchema.index({ booking: 1 });
transactionSchema.index({ user: 1 });
transactionSchema.index({ host: 1 });
transactionSchema.index({ status: 1 });
transactionSchema.index({ type: 1 });
transactionSchema.index({ createdAt: -1 });

module.exports = mongoose.model('Transaction', transactionSchema);

