const express = require('express');
const router = express.Router();
const {
  getTransactions,
  getPaymentAnalytics,
  processRefund,
  getPendingPayouts,
  completePayout,
} = require('../controllers/paymentController');
const { protect } = require('../middleware/auth');
const { protectAdmin } = require('../middleware/adminAuth');

// All routes require authentication and admin role
router.use(protect, protectAdmin);

router.get('/transactions', getTransactions);
router.get('/analytics', getPaymentAnalytics);
router.post('/transactions/:id/refund', processRefund);
router.get('/payouts', getPendingPayouts);
router.post('/payouts/:hostId/complete', completePayout);

module.exports = router;

