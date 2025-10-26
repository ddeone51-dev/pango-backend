const mongoose = require('mongoose');

const paymentSchema = new mongoose.Schema({
  // Basic payment info
  amount: {
    type: Number,
    required: true,
    min: 0
  },
  currency: {
    type: String,
    default: 'TZS',
    enum: ['TZS', 'KES', 'UGX']
  },
  
  // User and listing info
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  listingId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Listing',
    required: true
  },
  bookingId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Booking',
    required: true
  },
  
  // Pesapal specific fields
  pesapalOrderTrackingId: {
    type: String,
    unique: true,
    sparse: true
  },
  pesapalMerchantReference: {
    type: String,
    required: true,
    unique: true
  },
  pesapalTransactionId: {
    type: String,
    sparse: true
  },
  
  // Payment status
  status: {
    type: String,
    enum: ['PENDING', 'COMPLETED', 'FAILED', 'CANCELLED'],
    default: 'PENDING'
  },
  
  // Payment method
  paymentMethod: {
    type: String,
    enum: ['M-PESA', 'TIGO_PESA', 'AIRTEL_MONEY', 'VISA', 'MASTERCARD', 'BANK_TRANSFER'],
    required: true
  },
  
  // Payment details
  customerPhone: {
    type: String,
    required: true
  },
  customerEmail: {
    type: String,
    required: true
  },
  customerFirstName: {
    type: String,
    required: true
  },
  customerLastName: {
    type: String,
    required: true
  },
  
  // Timestamps
  paymentDate: {
    type: Date,
    default: Date.now
  },
  completedAt: {
    type: Date
  },
  
  // Pesapal callback data
  pesapalCallbackData: {
    type: mongoose.Schema.Types.Mixed
  }
}, {
  timestamps: true
});

// Indexes for better performance
paymentSchema.index({ userId: 1 });
paymentSchema.index({ listingId: 1 });
paymentSchema.index({ status: 1 });
paymentSchema.index({ pesapalOrderTrackingId: 1 });
paymentSchema.index({ pesapalMerchantReference: 1 });

// Virtual for formatted amount
paymentSchema.virtual('formattedAmount').get(function() {
  return new Intl.NumberFormat('en-TZ', {
    style: 'currency',
    currency: this.currency
  }).format(this.amount);
});

module.exports = mongoose.model('Payment', paymentSchema);

