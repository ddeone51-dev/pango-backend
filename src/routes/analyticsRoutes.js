const express = require('express');
const router = express.Router();
const {
  getAdvancedAnalytics,
  getRevenueAnalytics,
  getUserBehaviorAnalytics,
} = require('../controllers/analyticsController');
const { protect } = require('../middleware/auth');
const { protectAdmin } = require('../middleware/adminAuth');

// All routes require authentication and admin role
router.use(protect, protectAdmin);

router.get('/dashboard', getAdvancedAnalytics);
router.get('/revenue', getRevenueAnalytics);
router.get('/user-behavior', getUserBehaviorAnalytics);

module.exports = router;

