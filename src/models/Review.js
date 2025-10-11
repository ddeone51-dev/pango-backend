const mongoose = require('mongoose');

const ReviewSchema = new mongoose.Schema({
  bookingId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Booking',
    required: true,
  },
  listingId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Listing',
    required: true,
  },
  authorId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  revieweeId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  reviewType: {
    type: String,
    enum: ['guest_to_host', 'host_to_guest'],
    required: true,
  },
  ratings: {
    overall: {
      type: Number,
      required: true,
      min: 1,
      max: 5,
    },
    cleanliness: {
      type: Number,
      min: 1,
      max: 5,
    },
    accuracy: {
      type: Number,
      min: 1,
      max: 5,
    },
    communication: {
      type: Number,
      min: 1,
      max: 5,
    },
    location: {
      type: Number,
      min: 1,
      max: 5,
    },
    checkIn: {
      type: Number,
      min: 1,
      max: 5,
    },
    value: {
      type: Number,
      min: 1,
      max: 5,
    },
  },
  comment: {
    en: String,
    sw: String,
  },
  response: {
    text: String,
    respondedAt: Date,
  },
  photos: [String],
  status: {
    type: String,
    enum: ['published', 'hidden', 'flagged'],
    default: 'published',
  },
  helpful: {
    count: {
      type: Number,
      default: 0,
    },
    users: [{
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
    }],
  },
}, {
  timestamps: true,
});

// Indexes
ReviewSchema.index({ listingId: 1 });
ReviewSchema.index({ authorId: 1 });
ReviewSchema.index({ revieweeId: 1 });
ReviewSchema.index({ bookingId: 1 }, { unique: true });

module.exports = mongoose.model('Review', ReviewSchema);





