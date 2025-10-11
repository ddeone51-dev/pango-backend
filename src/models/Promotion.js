const mongoose = require('mongoose');

const promotionSchema = new mongoose.Schema(
  {
    code: {
      type: String,
      required: true,
      uppercase: true,
      trim: true,
    },
    name: {
      type: String,
      required: true,
    },
    description: {
      type: String,
    },
    type: {
      type: String,
      enum: ['percentage', 'fixed_amount', 'free_nights'],
      required: true,
    },
    value: {
      type: Number,
      required: true,
    },
    minBookingAmount: {
      type: Number,
      default: 0,
    },
    maxDiscount: {
      type: Number,
    },
    applicableTo: {
      type: String,
      enum: ['all', 'new_users', 'specific_users', 'specific_listings', 'specific_categories'],
      default: 'all',
    },
    targetUsers: [{
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
    }],
    targetListings: [{
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Listing',
    }],
    targetCategories: [{
      type: String,
      enum: ['apartment', 'house', 'villa', 'cottage', 'studio', 'penthouse', 'bungalow', 'guesthouse', 'resort'],
    }],
    usageLimit: {
      total: {
        type: Number,
        default: null, // null means unlimited
      },
      perUser: {
        type: Number,
        default: 1,
      },
    },
    usageCount: {
      type: Number,
      default: 0,
    },
    validFrom: {
      type: Date,
      required: true,
    },
    validUntil: {
      type: Date,
      required: true,
    },
    status: {
      type: String,
      enum: ['active', 'inactive', 'expired', 'depleted'],
      default: 'active',
    },
    usedBy: [{
      user: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
      },
      booking: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Booking',
      },
      discountAmount: Number,
      usedAt: {
        type: Date,
        default: Date.now,
      },
    }],
    createdBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    metadata: {
      campaign: String,
      source: String,
    },
  },
  {
    timestamps: true,
  }
);

// Indexes
promotionSchema.index({ code: 1 }, { unique: true });
promotionSchema.index({ status: 1 });
promotionSchema.index({ validFrom: 1, validUntil: 1 });

module.exports = mongoose.model('Promotion', promotionSchema);

