const crypto = require('crypto');
const User = require('../models/User');
const { AppError } = require('../middleware/errorHandler');
const logger = require('../utils/logger');
const smsService = require('../services/smsService');
const emailService = require('../services/emailService');

// @desc    Register user
// @route   POST /api/v1/auth/register
// @access  Public
exports.register = async (req, res, next) => {
  try {
    const { email, phoneNumber, password, firstName, lastName, role } = req.body;

    // Create user
    const normalizedRole = role === 'admin' ? 'guest' : (role || 'guest');
    const user = await User.create({
      email,
      phoneNumber,
      password,
      role: normalizedRole,
      hostStatus: normalizedRole === 'host' ? 'pending' : 'not_requested',
      profile: {
        firstName,
        lastName,
      },
    });

    // Generate token
    const token = user.getSignedJwtToken();

    // Remove password from response
    user.password = undefined;

    logger.info(`New user registered: ${user.email}`);

    res.status(201).json({
      success: true,
      data: {
        user,
        token,
      },
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Login user
// @route   POST /api/v1/auth/login
// @access  Public
exports.login = async (req, res, next) => {
  try {
    const { email, phoneNumber, password } = req.body;

    // Validate credentials
    if ((!email && !phoneNumber) || !password) {
      return next(new AppError('Please provide email/phone and password', 400));
    }

    // Find user by email OR phone number
    let user;
    if (email) {
      user = await User.findOne({ email }).select('+password');
    } else if (phoneNumber) {
      user = await User.findOne({ phoneNumber }).select('+password');
    }

    if (!user) {
      return next(new AppError('Invalid credentials', 401));
    }

    // Check if password matches
    const isMatch = await user.matchPassword(password);

    if (!isMatch) {
      return next(new AppError('Invalid credentials', 401));
    }

    // Update last login
    user.lastLogin = Date.now();
    await user.save({ validateBeforeSave: false });

    // Generate token
    const token = user.getSignedJwtToken();

    // Remove password from response
    user.password = undefined;

    logger.info(`User logged in: ${email || phoneNumber}`);

    res.status(200).json({
      success: true,
      data: {
        user,
        token,
      },
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Logout user
// @route   POST /api/v1/auth/logout
// @access  Private
exports.logout = async (req, res, next) => {
  try {
    // In a stateless JWT system, logout is handled client-side by removing the token
    // Here we can add the token to a blacklist if needed

    res.status(200).json({
      success: true,
      message: 'Logged out successfully',
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get current logged in user
// @route   GET /api/v1/auth/me
// @access  Private
exports.getMe = async (req, res, next) => {
  try {
    const user = await User.findById(req.user.id);

    res.status(200).json({
      success: true,
      data: user,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Request host role
// @route   POST /api/v1/auth/request-host
// @access  Private
exports.requestHostRole = async (req, res, next) => {
  try {
    const user = await User.findById(req.user.id);

    if (!user) {
      return next(new AppError('User not found', 404));
    }

    if (user.role === 'admin') {
      return next(new AppError('Admins cannot request host privileges', 400));
    }

    if (user.hostStatus === 'approved') {
      return res.status(200).json({
        success: true,
        message: 'You are already an approved host.',
        data: user,
      });
    }

    user.role = 'host';
    user.hostStatus = 'pending';

    await user.save({ validateBeforeSave: false });

    logger.info(`User ${user.email} requested host role`);

    res.status(200).json({
      success: true,
      message: 'Host request submitted. An admin will review your application shortly.',
      data: user,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Forgot password
// @route   POST /api/v1/auth/forgot-password
// @access  Public
exports.forgotPassword = async (req, res, next) => {
  try {
    const user = await User.findOne({ email: req.body.email });

    if (!user) {
      return next(new AppError('There is no user with that email', 404));
    }

    // Generate reset token
    const resetToken = crypto.randomBytes(20).toString('hex');

    // Hash token and set to resetPasswordToken field
    user.resetPasswordToken = crypto
      .createHash('sha256')
      .update(resetToken)
      .digest('hex');

    // Set expire
    user.resetPasswordExpire = Date.now() + 10 * 60 * 1000; // 10 minutes

    await user.save({ validateBeforeSave: false });

    // TODO: Send email with reset token
    // For now, return the token in development
    const response = {
      success: true,
      message: 'Reset token sent to email',
    };

    if (process.env.NODE_ENV === 'development') {
      response.resetToken = resetToken;
    }

    res.status(200).json(response);
  } catch (error) {
    next(error);
  }
};

// @desc    Reset password
// @route   POST /api/v1/auth/reset-password/:resetToken
// @access  Public
exports.resetPassword = async (req, res, next) => {
  try {
    // Get hashed token
    const resetPasswordToken = crypto
      .createHash('sha256')
      .update(req.params.resetToken)
      .digest('hex');

    const user = await User.findOne({
      resetPasswordToken,
      resetPasswordExpire: { $gt: Date.now() },
    });

    if (!user) {
      return next(new AppError('Invalid or expired token', 400));
    }

    // Set new password
    user.password = req.body.password;
    user.resetPasswordToken = undefined;
    user.resetPasswordExpire = undefined;
    await user.save();

    // Generate token
    const token = user.getSignedJwtToken();

    res.status(200).json({
      success: true,
      data: {
        token,
      },
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Verify email
// @route   POST /api/v1/auth/verify-email
// @access  Public
exports.verifyEmail = async (req, res, next) => {
  try {
    const { token } = req.body;

    const user = await User.findOne({
      emailVerificationToken: token,
      emailVerificationExpire: { $gt: Date.now() },
    });

    if (!user) {
      return next(new AppError('Invalid or expired verification token', 400));
    }

    user.isEmailVerified = true;
    user.emailVerificationToken = undefined;
    user.emailVerificationExpire = undefined;
    await user.save({ validateBeforeSave: false });

    res.status(200).json({
      success: true,
      message: 'Email verified successfully',
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Send phone verification code
// @route   POST /api/v1/auth/send-phone-code
// @access  Public
exports.sendPhoneVerificationCode = async (req, res, next) => {
  try {
    const { phoneNumber } = req.body;

    if (!phoneNumber) {
      return next(new AppError('Please provide phone number', 400));
    }

    const user = await User.findOne({ phoneNumber });

    if (!user) {
      return next(new AppError('User not found with this phone number', 404));
    }

    // Generate 6-digit code
    const code = user.generatePhoneVerificationCode();
    await user.save({ validateBeforeSave: false });

    // Send SMS with verification code
    try {
      await smsService.sendVerificationCode(phoneNumber, code);
      logger.info(`Phone verification code sent to ${phoneNumber}`);
    } catch (smsError) {
      logger.error(`SMS sending failed, but code is logged: ${smsError.message}`);
      // Continue anyway - code is still valid and logged
    }

    res.status(200).json({
      success: true,
      message: 'Verification code sent to your phone',
      // In development, return code for easy testing
      code: process.env.NODE_ENV === 'development' ? code : undefined,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Verify phone with code
// @route   POST /api/v1/auth/verify-phone
// @access  Public
exports.verifyPhone = async (req, res, next) => {
  try {
    const { phoneNumber, code } = req.body;

    if (!phoneNumber || !code) {
      return next(new AppError('Please provide phone number and verification code', 400));
    }

    const user = await User.findOne({
      phoneNumber,
      phoneVerificationCode: code,
      phoneVerificationExpire: { $gt: Date.now() },
    });

    if (!user) {
      return next(new AppError('Invalid or expired verification code', 400));
    }

    // Verify phone
    user.isPhoneVerified = true;
    user.phoneVerificationCode = undefined;
    user.phoneVerificationExpire = undefined;
    await user.save({ validateBeforeSave: false });

    logger.info(`Phone verified for user: ${phoneNumber}`);

    res.status(200).json({
      success: true,
      message: 'Phone number verified successfully',
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Send email verification code
// @route   POST /api/v1/auth/send-email-code
// @access  Public
exports.sendEmailVerificationCode = async (req, res, next) => {
  try {
    const { email } = req.body;

    if (!email) {
      return next(new AppError('Please provide email address', 400));
    }

    const user = await User.findOne({ email });

    if (!user) {
      return next(new AppError('User not found with this email', 404));
    }

    // Generate verification token
    const token = user.generateEmailVerificationToken();
    await user.save({ validateBeforeSave: false });

    // Send email with verification token
    try {
      await emailService.sendVerificationEmail(email, token, user.profile.firstName);
      logger.info(`Email verification sent to ${email}`);
    } catch (emailError) {
      logger.error(`Email sending failed, but token is logged: ${emailError.message}`);
      // Continue anyway - token is still valid and logged
    }

    res.status(200).json({
      success: true,
      message: 'Verification code sent to your email',
      // In development, return token for easy testing
      token: process.env.NODE_ENV === 'development' ? token : undefined,
    });
  } catch (error) {
    next(error);
  }
};





