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



