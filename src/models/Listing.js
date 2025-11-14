const mongoose = require('mongoose');

const ListingSchema = new mongoose.Schema({
  hostId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  title: {
    en: {
      type: String,
      required: [true, 'Please provide a title in English'],
      trim: true,
      maxlength: 100,
    },
    sw: {
      type: String,
      required: [true, 'Please provide a title in Swahili'],
      trim: true,
      maxlength: 100,
    },
  },
  description: {
    en: {
      type: String,
      required: [true, 'Please provide a description in English'],
      maxlength: 2000,
    },
    sw: {
      type: String,
      required: [true, 'Please provide a description in Swahili'],
      maxlength: 2000,
    },
  },
  propertyType: {
    type: String,
    required: true,
    enum: [
      'apartment', 'house', 'villa', 'guesthouse',
      'hotel', 'resort', 'cottage', 'bungalow', 'studio'
    ],
  },
  location: {
    address: {
      type: String,
      required: true,
    },
    region: {
      type: String,
      required: true,
      enum: [
        'Dar es Salaam', 'Arusha', 'Dodoma', 'Mwanza',
        'Mbeya', 'Tanga', 'Zanzibar', 'Kilimanjaro',
        'Morogoro', 'Pwani', 'Other'
      ],
    },
    city: {
      type: String,
      required: true,
    },
    district: String,
    coordinates: {
      type: {
        type: String,
        enum: ['Point'],
        required: true,
      },
      coordinates: {
        type: [Number],
        required: true,
      },
    },
    nearbyLandmarks: [String],
  },
  pricing: {
    basePrice: {
      type: Number,
      required: [true, 'Please provide a base price'],
      min: 0,
    },
    currency: {
      type: String,
      default: 'TZS',
    },
    cleaningFee: {
      type: Number,
      default: 0,
    },
    serviceFee: {
      type: Number,
      default: 0,
    },
    weeklyDiscount: {
      type: Number,
      default: 0,
      min: 0,
      max: 100,
    },
    monthlyDiscount: {
      type: Number,
      default: 0,
      min: 0,
      max: 100,
    },
    extraGuestFee: {
      type: Number,
      default: 0,
    },
  },
  capacity: {
    guests: {
      type: Number,
      required: true,
      min: 1,
    },
    bedrooms: {
      type: Number,
      required: true,
      min: 0,
    },
    beds: {
      type: Number,
      required: true,
      min: 1,
    },
    bathrooms: {
      type: Number,
      required: true,
      min: 1,
    },
  },
  amenities: [{
    type: String,
    enum: [
      'wifi', 'parking', 'kitchen', 'air_conditioning', 'heating',
      'tv', 'pool', 'gym', 'security', 'generator', 'water_tank',
      'washer', 'dryer', 'workspace', 'breakfast', 'pet_friendly',
      'family_friendly', 'accessible', 'smoking_allowed', 'mosquito_nets'
    ],
  }],
  images: [{
    url: {
      type: String,
      required: true,
    },
    caption: String,
    order: {
      type: Number,
      default: 0,
    },
  }],
  houseRules: {
    checkIn: {
      type: String,
      default: '14:00',
    },
    checkOut: {
      type: String,
      default: '11:00',
    },
    customRules: {
      en: [String],
      sw: [String],
    },
  },
  availability: {
    minNights: {
      type: Number,
      default: 1,
      min: 1,
    },
    maxNights: {
      type: Number,
      default: 365,
    },
    instantBooking: {
      type: Boolean,
      default: false,
    },
  },
  blockedDates: {
    type: [{
      start: {
        type: Date,
        required: true,
      },
      end: {
        type: Date,
        required: true,
      },
      reason: {
        type: String,
        trim: true,
      },
      createdAt: {
        type: Date,
        default: Date.now,
      },
      createdBy: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
      },
    }],
    default: [],
  },
  rating: {
    average: {
      type: Number,
      default: 0,
      min: 0,
      max: 5,
    },
    count: {
      type: Number,
      default: 0,
    },
    breakdown: {
      cleanliness: { type: Number, default: 0 },
      accuracy: { type: Number, default: 0 },
      communication: { type: Number, default: 0 },
      location: { type: Number, default: 0 },
      checkIn: { type: Number, default: 0 },
      value: { type: Number, default: 0 },
    },
  },
  status: {
    type: String,
    enum: ['draft', 'active', 'inactive', 'suspended'],
    default: 'draft',
  },
  views: {
    type: Number,
    default: 0,
  },
  bookingsCount: {
    type: Number,
    default: 0,
  },
  featured: {
    type: Boolean,
    default: false,
  },
  verifiedByAdmin: {
    type: Boolean,
    default: false,
  },
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true },
});

// Create geospatial index
ListingSchema.index({ 'location.coordinates': '2dsphere' });

// Create text index for search
ListingSchema.index({
  'title.en': 'text',
  'title.sw': 'text',
  'description.en': 'text',
  'description.sw': 'text',
});

// Additional indexes
ListingSchema.index({ hostId: 1 });
ListingSchema.index({ 'location.region': 1 });
ListingSchema.index({ propertyType: 1 });
ListingSchema.index({ 'pricing.basePrice': 1 });
ListingSchema.index({ 'rating.average': -1 });
ListingSchema.index({ status: 1 });
ListingSchema.index({ createdAt: -1 });

// Populate host info
ListingSchema.pre(/^find/, function(next) {
  this.populate({
    path: 'hostId',
    select: 'profile.firstName profile.lastName profile.profilePicture rating isEmailVerified isPhoneVerified',
  });
  next();
});

module.exports = mongoose.model('Listing', ListingSchema);





