const mongoose = require('mongoose');

const BookingSchema = new mongoose.Schema({
  listingId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Listing',
    required: true,
  },
  guestId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  hostId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  checkInDate: {
    type: Date,
    required: [true, 'Please provide check-in date'],
  },
  checkOutDate: {
    type: Date,
    required: [true, 'Please provide check-out date'],
  },
  numberOfGuests: {
    type: Number,
    required: true,
    min: 1,
  },
  pricing: {
    nightlyRate: {
      type: Number,
      required: true,
    },
    numberOfNights: {
      type: Number,
      required: true,
    },
    subtotal: {
      type: Number,
      required: true,
    },
    cleaningFee: {
      type: Number,
      default: 0,
    },
    serviceFee: {
      type: Number,
      default: 0,
    },
    taxes: {
      type: Number,
      default: 0,
    },
    total: {
      type: Number,
      required: true,
    },
    currency: {
      type: String,
      default: 'TZS',
    },
  },
  status: {
    type: String,
    enum: [
      'pending',
      'confirmed',
      'cancelled_by_guest',
      'cancelled_by_host',
      'completed',
      'in_progress',
      'refunded'
    ],
    default: 'pending',
  },
  payment: {
    method: {
      type: String,
      enum: ['zenopay'],
      required: true,
    },
    transactionId: String,
    orderId: String, // ZenoPay order ID
    status: {
      type: String,
      enum: ['pending', 'completed', 'failed', 'refunded'],
      default: 'pending',
    },
    paidAt: Date,
  },
  guestDetails: {
    fullName: {
      type: String,
      required: true,
    },
    phoneNumber: {
      type: String,
      required: true,
    },
    email: {
      type: String,
      required: true,
    },
    numberOfAdults: {
      type: Number,
      default: 1,
    },
    numberOfChildren: {
      type: Number,
      default: 0,
    },
    specialRequests: String,
  },
  cancellation: {
    cancelledBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
    },
    cancelledAt: Date,
    reason: String,
    refundAmount: Number,
  },
  checkInConfirmed: {
    type: Boolean,
    default: false,
  },
  checkOutConfirmed: {
    type: Boolean,
    default: false,
  },
}, {
  timestamps: true,
});

// Indexes
BookingSchema.index({ listingId: 1 });
BookingSchema.index({ guestId: 1 });
BookingSchema.index({ hostId: 1 });
BookingSchema.index({ status: 1 });
BookingSchema.index({ checkInDate: 1 });
BookingSchema.index({ checkOutDate: 1 });
BookingSchema.index({ createdAt: -1 });

// Validate check-out is after check-in
BookingSchema.pre('save', function(next) {
  if (this.checkOutDate <= this.checkInDate) {
    next(new Error('Check-out date must be after check-in date'));
  }
  next();
});

// Calculate number of nights
BookingSchema.pre('save', function(next) {
  const oneDay = 24 * 60 * 60 * 1000;
  this.pricing.numberOfNights = Math.round(
    Math.abs((this.checkOutDate - this.checkInDate) / oneDay)
  );
  next();
});

module.exports = mongoose.model('Booking', BookingSchema);





