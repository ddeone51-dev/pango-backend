const express = require('express');
const router = express.Router();
const {
  getFlaggedContent,
  reviewFlaggedContent,
  getReviewsForModeration,
  toggleReviewVisibility,
  deleteReview,
  getModerationStats,
} = require('../controllers/contentModerationController');
const { protect } = require('../middleware/auth');
const { protectAdmin } = require('../middleware/adminAuth');

// All routes require authentication and admin role
router.use(protect, protectAdmin);

router.get('/flagged', getFlaggedContent);
router.put('/flagged/:id/review', reviewFlaggedContent);
router.get('/reviews', getReviewsForModeration);
router.put('/reviews/:id/toggle-visibility', toggleReviewVisibility);
router.delete('/reviews/:id', deleteReview);
router.get('/stats', getModerationStats);

module.exports = router;

