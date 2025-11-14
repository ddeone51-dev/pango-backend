const Listing = require('../models/Listing');
const User = require('../models/User');
const { AppError } = require('../middleware/errorHandler');
const logger = require('../utils/logger');

// @desc    Get all listings with filters
// @route   GET /api/v1/listings
// @access  Public
exports.getListings = async (req, res, next) => {
  try {
    const {
      location,
      lat,
      lng,
      radius,
      checkIn,
      checkOut,
      guests,
      propertyType,
      minPrice,
      maxPrice,
      amenities,
      page = 1,
      limit = 20,
      sort = 'createdAt',
    } = req.query;

    // Build query
    const query = { status: 'active' };

    // Location filter
    if (location) {
      query.$or = [
        { 'location.region': new RegExp(location, 'i') },
        { 'location.city': new RegExp(location, 'i') },
      ];
    }

    // Geospatial search
    if (lat && lng) {
      const radiusInKm = radius || 10;
      query['location.coordinates'] = {
        $near: {
          $geometry: {
            type: 'Point',
            coordinates: [parseFloat(lng), parseFloat(lat)],
          },
          $maxDistance: radiusInKm * 1000, // Convert to meters
        },
      };
    }

    // Property type filter
    if (propertyType) {
      query.propertyType = propertyType;
    }

    // Price range filter
    if (minPrice || maxPrice) {
      query['pricing.basePrice'] = {};
      if (minPrice) query['pricing.basePrice'].$gte = parseFloat(minPrice);
      if (maxPrice) query['pricing.basePrice'].$lte = parseFloat(maxPrice);
    }

    // Amenities filter
    if (amenities) {
      const amenitiesArray = amenities.split(',');
      query.amenities = { $all: amenitiesArray };
    }

    // Guest capacity filter
    if (guests) {
      query['capacity.guests'] = { $gte: parseInt(guests) };
    }

    // Sort options
    let sortOption;
    switch (sort) {
      case 'price_asc':
        sortOption = { 'pricing.basePrice': 1 };
        break;
      case 'price_desc':
        sortOption = { 'pricing.basePrice': -1 };
        break;
      case 'rating':
        sortOption = { 'rating.average': -1 };
        break;
      case 'newest':
        sortOption = { createdAt: -1 };
        break;
      default:
        sortOption = { createdAt: -1 };
    }

    // Pagination
    const skip = (page - 1) * limit;

    // Execute query
    const listings = await Listing.find(query)
      .sort(sortOption)
      .skip(skip)
      .limit(parseInt(limit));

    // Get total count
    const total = await Listing.countDocuments(query);

    res.status(200).json({
      success: true,
      data: {
        listings,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total,
          pages: Math.ceil(total / limit),
        },
      },
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get single listing
// @route   GET /api/v1/listings/:id
// @access  Public
exports.getListing = async (req, res, next) => {
  try {
    const listing = await Listing.findById(req.params.id);

    if (!listing) {
      return next(new AppError('Listing not found', 404));
    }

    // Increment views
    listing.views += 1;
    await listing.save({ validateBeforeSave: false });

    res.status(200).json({
      success: true,
      data: listing,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Create new listing
// @route   POST /api/v1/listings
// @access  Private (Host)
exports.createListing = async (req, res, next) => {
  try {
    const user = await User.findById(req.user.id);

    if (!user) {
      return next(new AppError('User not found', 404));
    }

    if (user.role !== 'host') {
      return next(new AppError('Only hosts can create listings', 403));
    }

    if (user.hostStatus !== 'approved') {
      return next(new AppError('Your host account is not approved yet. Please wait for admin approval.', 403));
    }

    // Add host ID from logged in user
    req.body.hostId = req.user.id;

    const listing = await Listing.create(req.body);

    logger.info(`New listing created: ${listing._id} by ${req.user.email}`);

    res.status(201).json({
      success: true,
      data: listing,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Update listing
// @route   PUT /api/v1/listings/:id
// @access  Private (Host)
exports.updateListing = async (req, res, next) => {
  try {
    let listing = await Listing.findById(req.params.id);

    if (!listing) {
      return next(new AppError('Listing not found', 404));
    }

    // Make sure user is listing owner
    if (listing.hostId.toString() !== req.user.id && req.user.role !== 'admin') {
      return next(new AppError('Not authorized to update this listing', 401));
    }

    listing = await Listing.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true,
    });

    res.status(200).json({
      success: true,
      data: listing,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Delete listing
// @route   DELETE /api/v1/listings/:id
// @access  Private (Host)
exports.deleteListing = async (req, res, next) => {
  try {
    const listing = await Listing.findById(req.params.id);

    if (!listing) {
      return next(new AppError('Listing not found', 404));
    }

    // Make sure user is listing owner
    if (listing.hostId.toString() !== req.user.id && req.user.role !== 'admin') {
      return next(new AppError('Not authorized to delete this listing', 401));
    }

    await listing.deleteOne();

    res.status(200).json({
      success: true,
      message: 'Listing deleted successfully',
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get featured listings
// @route   GET /api/v1/listings/featured
// @access  Public
exports.getFeaturedListings = async (req, res, next) => {
  try {
    const listings = await Listing.find({
      status: 'active',
      featured: true,
    })
      .sort({ 'rating.average': -1 })
      .limit(10);

    res.status(200).json({
      success: true,
      data: listings,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get nearby listings based on user location
// @route   GET /api/v1/listings/nearby
// @access  Public
exports.getNearbyListings = async (req, res, next) => {
  try {
    const { lat, lng, radius = 50 } = req.query; // radius in km, default 50km

    if (!lat || !lng) {
      return res.status(400).json({
        success: false,
        message: 'Please provide latitude and longitude',
      });
    }

    // Convert radius from km to meters for MongoDB
    const radiusInMeters = parseFloat(radius) * 1000;

    const listings = await Listing.find({
      status: 'active',
      'location.coordinates': {
        $near: {
          $geometry: {
            type: 'Point',
            coordinates: [parseFloat(lng), parseFloat(lat)],
          },
          $maxDistance: radiusInMeters,
        },
      },
    })
      .limit(10);

    res.status(200).json({
      success: true,
      data: listings,
      count: listings.length,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get host's listings
// @route   GET /api/v1/listings/host/:hostId
// @access  Public
exports.getHostListings = async (req, res, next) => {
  try {
    const listings = await Listing.find({
      hostId: req.params.hostId,
      status: { $in: ['active', 'inactive'] },
    });

    res.status(200).json({
      success: true,
      data: listings,
    });
  } catch (error) {
    next(error);
  }
};

// Get booked dates for a listing
exports.getBookedDates = async (req, res, next) => {
  try {
    const Booking = require('../models/Booking');
    const listingId = req.params.id;

    // Consider bookings that block availability
    const blockingStatuses = ['confirmed', 'pending', 'in_progress'];
    const bookings = await Booking.find({
      listingId,
      status: { $in: blockingStatuses },
    }).select('checkInDate checkOutDate');

    // Return as date ranges (ISO strings)
    const ranges = bookings.map(b => ({
      start: b.checkInDate.toISOString(),
      end: b.checkOutDate.toISOString(),
    }));

    res.status(200).json({ success: true, data: ranges });
  } catch (e) {
    next(e);
  }
};

exports.blockListingDates = async (req, res, next) => {
  try {
    const { startDate, endDate, reason } = req.body;
    if (!startDate || !endDate) {
      return next(new AppError('Start and end dates are required', 400));
    }

    const start = new Date(startDate);
    const end = new Date(endDate);

    if (Number.isNaN(start.getTime()) || Number.isNaN(end.getTime())) {
      return next(new AppError('Invalid date format', 400));
    }

    if (end <= start) {
      return next(new AppError('End date must be after start date', 400));
    }

    const listing = await Listing.findOne({
      _id: req.params.id,
      hostId: req.user.id,
    });

    if (!listing) {
      return next(new AppError('Listing not found', 404));
    }

    const Booking = require('../models/Booking');
    const blockingStatuses = ['pending', 'confirmed', 'in_progress', 'awaiting_arrival_confirmation'];
    const overlappingBooking = await Booking.findOne({
      listingId: listing._id,
      status: { $in: blockingStatuses },
      $or: [
        {
          checkInDate: { $lt: end },
          checkOutDate: { $gt: start },
        },
      ],
    });

    if (overlappingBooking) {
      return next(new AppError('Cannot block dates that overlap existing bookings', 400));
    }

    const overlapsBlocked = (listing.blockedDates || []).some((block) => (
      start < block.end && end > block.start
    ));

    if (overlapsBlocked) {
      return next(new AppError('Dates overlap with an existing blocked range', 400));
    }

    listing.blockedDates.push({
      start,
      end,
      reason,
      createdBy: req.user.id,
    });

    await listing.save();

    res.status(200).json({
      success: true,
      data: listing.blockedDates.map((block) => ({
        id: block._id,
        start: block.start,
        end: block.end,
        reason: block.reason,
        createdAt: block.createdAt,
      })),
    });
  } catch (error) {
    next(error);
  }
};

exports.unblockListingDate = async (req, res, next) => {
  try {
    const { id, blockId } = req.params;

    const listing = await Listing.findOne({
      _id: id,
      hostId: req.user.id,
    });

    if (!listing) {
      return next(new AppError('Listing not found', 404));
    }

    const index = (listing.blockedDates || []).findIndex(
      (block) => block._id.toString() === blockId,
    );

    if (index === -1) {
      return next(new AppError('Blocked date not found', 404));
    }

    listing.blockedDates.splice(index, 1);
    await listing.save();

    res.status(200).json({
      success: true,
      data: listing.blockedDates.map((block) => ({
        id: block._id,
        start: block.start,
        end: block.end,
        reason: block.reason,
        createdAt: block.createdAt,
      })),
    });
  } catch (error) {
    next(error);
  }
};






