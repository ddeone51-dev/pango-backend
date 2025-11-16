const express = require('express');
const { protect } = require('../middleware/auth');
const User = require('../models/User');
const { AppError } = require('../middleware/errorHandler');

const router = express.Router();

router.use(protect);

// @desc    Update user profile
// @route   PUT /api/v1/users/profile
// @access  Private
router.put('/profile', async (req, res, next) => {
  try {
    const fieldsToUpdate = {
      'profile.firstName': req.body.firstName,
      'profile.lastName': req.body.lastName,
      'profile.bio': req.body.bio,
      'profile.dateOfBirth': req.body.dateOfBirth,
      'profile.gender': req.body.gender,
      'profile.nationality': req.body.nationality,
      'profile.languages': req.body.languages,
      'contactInfo.whatsappNumber': req.body.whatsappNumber,
      'contactInfo.alternateEmail': req.body.alternateEmail,
    };

    // Remove undefined fields
    Object.keys(fieldsToUpdate).forEach(key => 
      fieldsToUpdate[key] === undefined && delete fieldsToUpdate[key]
    );

    const user = await User.findByIdAndUpdate(
      req.user.id,
      fieldsToUpdate,
      {
        new: true,
        runValidators: true,
      }
    );

    res.status(200).json({
      success: true,
      data: user,
    });
  } catch (error) {
    next(error);
  }
});

// @desc    Get host payout settings
// @route   GET /api/v1/users/payout-settings
// @access  Private (Host)
router.get('/payout-settings', async (req, res, next) => {
  try {
    if (req.user.role !== 'host') {
      return next(new AppError('Only hosts can access payout settings', 403));
    }

    const user = await User.findById(req.user.id).select('payoutSettings hostStatus');

    res.status(200).json({
      success: true,
      data: user?.payoutSettings || {},
    });
  } catch (error) {
    next(error);
  }
});

// @desc    Update host payout settings
// @route   PUT /api/v1/users/payout-settings
// @access  Private (Host)
router.put('/payout-settings', async (req, res, next) => {
  try {
    if (req.user.role !== 'host') {
      return next(new AppError('Only hosts can update payout settings', 403));
    }

    if (req.user.hostStatus !== 'approved') {
      return next(new AppError('Host must be approved before adding payout details', 403));
    }

    const { method, bankAccount, mobileMoney, preferredCurrency = 'TZS' } = req.body;

    if (!method || !['bank_account', 'mobile_money'].includes(method)) {
      return next(new AppError('Invalid payout method', 400));
    }

    const payoutSettings = {
      method,
      preferredCurrency,
      isSetupComplete: true,
      verified: req.user.payoutSettings?.verified || false,
      lastUpdatedAt: new Date(),
    };

    if (method === 'bank_account') {
      if (!bankAccount) {
        return next(new AppError('Bank account details are required', 400));
      }
      const requiredFields = ['accountName', 'accountNumber', 'bankName'];
      const missing = requiredFields.filter((field) => !bankAccount[field]);
      if (missing.length) {
        return next(new AppError(`Missing bank account fields: ${missing.join(', ')}`, 400));
      }
      payoutSettings.bankAccount = {
        accountName: bankAccount.accountName?.trim(),
        accountNumber: bankAccount.accountNumber?.trim(),
        bankName: bankAccount.bankName?.trim(),
        branchName: bankAccount.branchName?.trim() || '',
        swiftCode: bankAccount.swiftCode?.trim() || '',
      };
    } else if (method === 'mobile_money') {
      if (!mobileMoney) {
        return next(new AppError('Mobile money details are required', 400));
      }
      if (!mobileMoney.phoneNumber || !mobileMoney.provider) {
        return next(new AppError('Mobile money provider and phone number are required', 400));
      }
      payoutSettings.mobileMoney = {
        accountName: mobileMoney.accountName?.trim() || '',
        phoneNumber: mobileMoney.phoneNumber?.trim(),
        provider: mobileMoney.provider?.trim(),
      };
    }

    const updatedUser = await User.findByIdAndUpdate(
      req.user.id,
      { payoutSettings },
      { new: true, runValidators: true },
    ).select('payoutSettings email profile');

    req.user.payoutSettings = updatedUser.payoutSettings;

    // Debug logging
    const logger = require('../utils/logger');
    logger.info(`Payout settings saved for user: ${updatedUser.email}`, {
      method: payoutSettings.method,
      isSetupComplete: payoutSettings.isSetupComplete,
      hasBankAccount: !!payoutSettings.bankAccount,
      hasMobileMoney: !!payoutSettings.mobileMoney,
    });

    res.status(200).json({
      success: true,
      data: updatedUser.payoutSettings,
      message: 'Payout settings saved successfully',
    });
  } catch (error) {
    next(error);
  }
});

// @desc    Update user role (admin only)
// @route   PUT /api/v1/users/update-role
// @access  Private
router.put('/update-role', async (req, res, next) => {
  try {
    const { role } = req.body;
    
    if (!role) {
      return next(new AppError('Role is required', 400));
    }

    const user = await User.findByIdAndUpdate(
      req.user.id,
      { role },
      {
        new: true,
        runValidators: true,
      }
    );

    res.status(200).json({
      success: true,
      data: user,
      message: 'Role updated successfully'
    });
  } catch (error) {
    next(error);
  }
});

// IMPORTANT: Specific routes must come BEFORE generic /:id route

// @desc    Get saved listings
// @route   GET /api/v1/users/saved-listings
// @access  Private
router.get('/saved-listings', async (req, res, next) => {
  try {
    const user = await User.findById(req.user.id).populate('savedListings');

    res.status(200).json({
      success: true,
      data: user.savedListings,
    });
  } catch (error) {
    next(error);
  }
});

// @desc    Save listing
// @route   POST /api/v1/users/saved-listings/:listingId
// @access  Private
router.post('/saved-listings/:listingId', async (req, res, next) => {
  try {
    const user = await User.findById(req.user.id);

    if (!user.savedListings.includes(req.params.listingId)) {
      user.savedListings.push(req.params.listingId);
      await user.save();
    }

    res.status(200).json({
      success: true,
      message: 'Listing saved successfully',
    });
  } catch (error) {
    next(error);
  }
});

// @desc    Remove saved listing
// @route   DELETE /api/v1/users/saved-listings/:listingId
// @access  Private
router.delete('/saved-listings/:listingId', async (req, res, next) => {
  try {
    const user = await User.findById(req.user.id);

    user.savedListings = user.savedListings.filter(
      id => id.toString() !== req.params.listingId
    );
    await user.save();

    res.status(200).json({
      success: true,
      message: 'Listing removed from saved',
    });
  } catch (error) {
    next(error);
  }
});

// @desc    Get user by ID
// @route   GET /api/v1/users/:id
// @access  Private
router.get('/:id', async (req, res, next) => {
  try {
    const user = await User.findById(req.params.id).select('-password');

    if (!user) {
      return next(new AppError('User not found', 404));
    }

    res.status(200).json({
      success: true,
      data: user,
    });
  } catch (error) {
    next(error);
  }
});

module.exports = router;



