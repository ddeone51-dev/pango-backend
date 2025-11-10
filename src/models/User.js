const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const UserSchema = new mongoose.Schema({
  email: {
    type: String,
    required: [true, 'Please provide an email'],
    unique: true,
    lowercase: true,
    trim: true,
    match: [
      /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/,
      'Please provide a valid email',
    ],
  },
  phoneNumber: {
    type: String,
    required: [true, 'Please provide a phone number'],
    unique: true,
    match: [/^\+255\d{9}$/, 'Please provide a valid Tanzanian phone number'],
  },
  password: {
    type: String,
    required: [true, 'Please provide a password'],
    minlength: 8,
    select: false,
  },
  role: {
    type: String,
    enum: ['guest', 'host', 'admin'],
    default: 'guest',
  },
  hostStatus: {
    type: String,
    enum: ['not_requested', 'pending', 'approved', 'rejected'],
    default: 'not_requested',
  },
  profile: {
    firstName: {
      type: String,
      required: [true, 'Please provide first name'],
      trim: true,
    },
    lastName: {
      type: String,
      required: [true, 'Please provide last name'],
      trim: true,
    },
    profilePicture: {
      type: String,
      default: null,
    },
    bio: {
      type: String,
      maxlength: 500,
    },
    dateOfBirth: Date,
    gender: {
      type: String,
      enum: ['male', 'female', 'other', 'prefer_not_to_say'],
    },
    nationality: String,
    languages: [String],
    governmentId: {
      type: {
        type: String,
        enum: ['nida', 'passport', 'driving_license'],
      },
      number: String,
      verified: {
        type: Boolean,
        default: false,
      },
    },
  },
  contactInfo: {
    phoneNumber: String,
    whatsappNumber: String,
    alternateEmail: String,
  },
  preferences: {
    language: {
      type: String,
      enum: ['sw', 'en'],
      default: 'sw',
    },
    currency: {
      type: String,
      default: 'TZS',
    },
    notifications: {
      email: {
        type: Boolean,
        default: true,
      },
      push: {
        type: Boolean,
        default: true,
      },
      sms: {
        type: Boolean,
        default: false,
      },
    },
  },
  savedListings: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Listing',
  }],
  deviceTokens: [String],
  isEmailVerified: {
    type: Boolean,
    default: false,
  },
  isPhoneVerified: {
    type: Boolean,
    default: false,
  },
  accountStatus: {
    type: String,
    enum: ['active', 'suspended', 'deleted'],
    default: 'active',
  },
  emailVerificationToken: String,
  emailVerificationExpire: Date,
  phoneVerificationCode: String,
  phoneVerificationExpire: Date,
  resetPasswordToken: String,
  resetPasswordExpire: Date,
  lastLogin: Date,
}, {
  timestamps: true,
});

// Encrypt password before saving
UserSchema.pre('save', async function(next) {
  if (!this.isModified('password')) {
    next();
  }

  const salt = await bcrypt.genSalt(10);
  this.password = await bcrypt.hash(this.password, salt);
});

// Maintain host status when role changes
UserSchema.pre('save', function(next) {
  if (this.isModified('role')) {
    if (this.role === 'host') {
      if (this.hostStatus === 'not_requested') {
        this.hostStatus = 'pending';
      }
    } else if (this.role !== 'admin') {
      this.hostStatus = 'not_requested';
    }
  }
  next();
});

// Match password
UserSchema.methods.matchPassword = async function(enteredPassword) {
  return await bcrypt.compare(enteredPassword, this.password);
};

// Generate JWT token
UserSchema.methods.getSignedJwtToken = function() {
  return jwt.sign({ id: this._id }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRE,
  });
};

// Generate 6-digit phone verification code
UserSchema.methods.generatePhoneVerificationCode = function() {
  const code = Math.floor(100000 + Math.random() * 900000).toString();
  this.phoneVerificationCode = code;
  this.phoneVerificationExpire = Date.now() + 10 * 60 * 1000; // 10 minutes
  return code;
};

// Generate email verification token
UserSchema.methods.generateEmailVerificationToken = function() {
  const token = Math.random().toString(36).substring(2, 15) + Math.random().toString(36).substring(2, 15);
  this.emailVerificationToken = token;
  this.emailVerificationExpire = Date.now() + 24 * 60 * 60 * 1000; // 24 hours
  return token;
};

// Virtual for full name
UserSchema.virtual('fullName').get(function() {
  return `${this.profile.firstName} ${this.profile.lastName}`;
});

module.exports = mongoose.model('User', UserSchema);





