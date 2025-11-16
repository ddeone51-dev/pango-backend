const express = require('express');
const {
  createReview,
  getListingReviews,
  getMyReviews,
  getReviewsAboutMe,
  respondToReview,
  markHelpful,
  getEligibleBookings,
  deleteReview,
} = require('../controllers/reviewController');
const { protect } = require('../middleware/auth');

const router = express.Router();

// Public routes
router.get('/listing/:listingId', getListingReviews);

// Protected routes (require authentication)
router.use(protect);

router.post('/', createReview);
router.get('/my-reviews', getMyReviews);
router.get('/about-me', getReviewsAboutMe);
router.get('/eligible-bookings', getEligibleBookings);
router.put('/:id/respond', respondToReview);
router.put('/:id/helpful', markHelpful);
router.delete('/:id', deleteReview);

module.exports = router;






