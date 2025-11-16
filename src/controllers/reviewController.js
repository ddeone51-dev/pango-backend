const Review = require('../models/Review');
const Booking = require('../models/Booking');
const Listing = require('../models/Listing');
const User = require('../models/User');

// @desc    Create a review for a completed booking
// @route   POST /api/reviews
// @access  Private (authenticated users only)
exports.createReview = async (req, res) => {
  try {
    const {
      bookingId,
      ratings,
      comment,
      photos = [],
    } = req.body;

    // Verify the booking exists and is completed
    const booking = await Booking.findById(bookingId);
    
    if (!booking) {
      return res.status(404).json({
        success: false,
        message: 'Booking not found',
      });
    }

    // Check if user is authorized (must be guest or host from the booking)
    const isGuest = booking.guestId.toString() === req.user._id.toString();
    const isHost = booking.hostId.toString() === req.user._id.toString();

    if (!isGuest && !isHost) {
      return res.status(403).json({
        success: false,
        message: 'You are not authorized to review this booking',
      });
    }

    // Check if booking is completed
    if (booking.status !== 'completed') {
      return res.status(400).json({
        success: false,
        message: 'You can only review completed bookings',
      });
    }

    // Check if review already exists for this booking
    const existingReview = await Review.findOne({ bookingId });
    if (existingReview) {
      return res.status(400).json({
        success: false,
        message: 'You have already reviewed this booking',
      });
    }

    // Determine review type and reviewee
    const reviewType = isGuest ? 'guest_to_host' : 'host_to_guest';
    const revieweeId = isGuest ? booking.hostId : booking.guestId;

    // Create the review
    const review = await Review.create({
      bookingId,
      listingId: booking.listingId,
      authorId: req.user._id,
      revieweeId,
      reviewType,
      ratings,
      comment,
      photos,
      status: 'published',
    });

    // Update listing ratings if it's a guest review
    if (reviewType === 'guest_to_host') {
      await updateListingRatings(booking.listingId);
    }

    // Populate review with author details
    await review.populate('authorId', 'profile.firstName profile.lastName profile.profilePicture');

    res.status(201).json({
      success: true,
      data: review,
    });
  } catch (error) {
    console.error('Error creating review:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while creating review',
      error: error.message,
    });
  }
};

// @desc    Get reviews for a listing
// @route   GET /api/reviews/listing/:listingId
// @access  Public
exports.getListingReviews = async (req, res) => {
  try {
    const { listingId } = req.params;
    const { page = 1, limit = 10, sort = '-createdAt' } = req.query;

    const reviews = await Review.find({
      listingId,
      reviewType: 'guest_to_host',
      status: 'published',
    })
      .populate('authorId', 'profile.firstName profile.lastName profile.profilePicture')
      .sort(sort)
      .limit(limit * 1)
      .skip((page - 1) * limit)
      .exec();

    const count = await Review.countDocuments({
      listingId,
      reviewType: 'guest_to_host',
      status: 'published',
    });

    res.status(200).json({
      success: true,
      data: reviews,
      totalPages: Math.ceil(count / limit),
      currentPage: page,
      total: count,
    });
  } catch (error) {
    console.error('Error fetching listing reviews:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching reviews',
      error: error.message,
    });
  }
};

// @desc    Get user's reviews (as author)
// @route   GET /api/reviews/my-reviews
// @access  Private
exports.getMyReviews = async (req, res) => {
  try {
    const reviews = await Review.find({ authorId: req.user._id })
      .populate('listingId', 'title images')
      .populate('revieweeId', 'profile.firstName profile.lastName')
      .sort('-createdAt');

    res.status(200).json({
      success: true,
      data: reviews,
    });
  } catch (error) {
    console.error('Error fetching user reviews:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching reviews',
      error: error.message,
    });
  }
};

// @desc    Get reviews about a user
// @route   GET /api/reviews/about-me
// @access  Private
exports.getReviewsAboutMe = async (req, res) => {
  try {
    const reviews = await Review.find({ revieweeId: req.user._id })
      .populate('authorId', 'profile.firstName profile.lastName profile.profilePicture')
      .populate('listingId', 'title images')
      .sort('-createdAt');

    res.status(200).json({
      success: true,
      data: reviews,
    });
  } catch (error) {
    console.error('Error fetching reviews about user:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching reviews',
      error: error.message,
    });
  }
};

// @desc    Add a response to a review (host only)
// @route   PUT /api/reviews/:id/respond
// @access  Private
exports.respondToReview = async (req, res) => {
  try {
    const { text } = req.body;

    const review = await Review.findById(req.params.id);

    if (!review) {
      return res.status(404).json({
        success: false,
        message: 'Review not found',
      });
    }

    // Only the reviewee can respond
    if (review.revieweeId.toString() !== req.user._id.toString()) {
      return res.status(403).json({
        success: false,
        message: 'You are not authorized to respond to this review',
      });
    }

    review.response = {
      text,
      respondedAt: Date.now(),
    };

    await review.save();

    res.status(200).json({
      success: true,
      data: review,
    });
  } catch (error) {
    console.error('Error responding to review:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while responding to review',
      error: error.message,
    });
  }
};

// @desc    Mark review as helpful
// @route   PUT /api/reviews/:id/helpful
// @access  Private
exports.markHelpful = async (req, res) => {
  try {
    const review = await Review.findById(req.params.id);

    if (!review) {
      return res.status(404).json({
        success: false,
        message: 'Review not found',
      });
    }

    // Check if user already marked as helpful
    const alreadyMarked = review.helpful.users.includes(req.user._id);

    if (alreadyMarked) {
      // Remove from helpful
      review.helpful.users = review.helpful.users.filter(
        userId => userId.toString() !== req.user._id.toString()
      );
      review.helpful.count = Math.max(0, review.helpful.count - 1);
    } else {
      // Add to helpful
      review.helpful.users.push(req.user._id);
      review.helpful.count += 1;
    }

    await review.save();

    res.status(200).json({
      success: true,
      data: review,
    });
  } catch (error) {
    console.error('Error marking review as helpful:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while marking review as helpful',
      error: error.message,
    });
  }
};

// @desc    Get bookings eligible for review
// @route   GET /api/reviews/eligible-bookings
// @access  Private
exports.getEligibleBookings = async (req, res) => {
  try {
    // Find completed bookings for the user (as guest or host)
    const bookings = await Booking.find({
      $or: [{ guestId: req.user._id }, { hostId: req.user._id }],
      status: 'completed',
    })
      .populate('listingId', 'title images')
      .sort('-checkOutDate');

    // Check which bookings have been reviewed
    const bookingIds = bookings.map(b => b._id);
    const existingReviews = await Review.find({
      bookingId: { $in: bookingIds },
      authorId: req.user._id,
    });

    const reviewedBookingIds = new Set(
      existingReviews.map(r => r.bookingId.toString())
    );

    // Filter out already reviewed bookings
    const eligibleBookings = bookings.filter(
      booking => !reviewedBookingIds.has(booking._id.toString())
    );

    res.status(200).json({
      success: true,
      data: eligibleBookings,
    });
  } catch (error) {
    console.error('Error fetching eligible bookings:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching eligible bookings',
      error: error.message,
    });
  }
};

// @desc    Delete a review (author or admin only)
// @route   DELETE /api/reviews/:id
// @access  Private
exports.deleteReview = async (req, res) => {
  try {
    const review = await Review.findById(req.params.id);

    if (!review) {
      return res.status(404).json({
        success: false,
        message: 'Review not found',
      });
    }

    // Check authorization
    const isAuthor = review.authorId.toString() === req.user._id.toString();
    const isAdmin = req.user.role === 'admin';

    if (!isAuthor && !isAdmin) {
      return res.status(403).json({
        success: false,
        message: 'You are not authorized to delete this review',
      });
    }

    const listingId = review.listingId;
    await review.deleteOne();

    // Update listing ratings if it was a guest review
    if (review.reviewType === 'guest_to_host') {
      await updateListingRatings(listingId);
    }

    res.status(200).json({
      success: true,
      message: 'Review deleted successfully',
    });
  } catch (error) {
    console.error('Error deleting review:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while deleting review',
      error: error.message,
    });
  }
};

// Helper function to update listing ratings
async function updateListingRatings(listingId) {
  try {
    const reviews = await Review.find({
      listingId,
      reviewType: 'guest_to_host',
      status: 'published',
    });

    if (reviews.length === 0) {
      await Listing.findByIdAndUpdate(listingId, {
        'rating.average': 0,
        'rating.count': 0,
        'rating.breakdown': {
          cleanliness: 0,
          accuracy: 0,
          communication: 0,
          location: 0,
          checkIn: 0,
          value: 0,
        },
      });
      return;
    }

    // Calculate averages
    const totals = {
      overall: 0,
      cleanliness: 0,
      accuracy: 0,
      communication: 0,
      location: 0,
      checkIn: 0,
      value: 0,
    };

    const counts = {
      cleanliness: 0,
      accuracy: 0,
      communication: 0,
      location: 0,
      checkIn: 0,
      value: 0,
    };

    reviews.forEach(review => {
      totals.overall += review.ratings.overall;
      
      if (review.ratings.cleanliness) {
        totals.cleanliness += review.ratings.cleanliness;
        counts.cleanliness++;
      }
      if (review.ratings.accuracy) {
        totals.accuracy += review.ratings.accuracy;
        counts.accuracy++;
      }
      if (review.ratings.communication) {
        totals.communication += review.ratings.communication;
        counts.communication++;
      }
      if (review.ratings.location) {
        totals.location += review.ratings.location;
        counts.location++;
      }
      if (review.ratings.checkIn) {
        totals.checkIn += review.ratings.checkIn;
        counts.checkIn++;
      }
      if (review.ratings.value) {
        totals.value += review.ratings.value;
        counts.value++;
      }
    });

    const average = (totals.overall / reviews.length).toFixed(2);

    const breakdown = {
      cleanliness: counts.cleanliness > 0 ? (totals.cleanliness / counts.cleanliness).toFixed(2) : 0,
      accuracy: counts.accuracy > 0 ? (totals.accuracy / counts.accuracy).toFixed(2) : 0,
      communication: counts.communication > 0 ? (totals.communication / counts.communication).toFixed(2) : 0,
      location: counts.location > 0 ? (totals.location / counts.location).toFixed(2) : 0,
      checkIn: counts.checkIn > 0 ? (totals.checkIn / counts.checkIn).toFixed(2) : 0,
      value: counts.value > 0 ? (totals.value / counts.value).toFixed(2) : 0,
    };

    await Listing.findByIdAndUpdate(listingId, {
      'rating.average': parseFloat(average),
      'rating.count': reviews.length,
      'rating.breakdown': breakdown,
    });

  } catch (error) {
    console.error('Error updating listing ratings:', error);
  }
}

module.exports = exports;






