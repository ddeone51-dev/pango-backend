const express = require('express');
const {
  getDashboardStats,
  getChartData,
  getAllUsers,
  getUser,
  updateUser,
  deleteUser,
  getAllListings,
  updateListingStatus,
  deleteListing,
  getAllBookings,
  updateBookingStatus,
  generateReports,
  getPaymentTransactions,
  exportPaymentTransactions,
  exportPaymentTransactionsPdf,
  getHostRequests,
  updateHostStatus,
  getHostPayoutSettings,
  updatePayoutVerification,
  verifyUserEmail,
  verifyUserPhone,
} = require('../controllers/adminController');
const { sendBroadcastNotification } = require('../controllers/pushNotificationController');
const { protectAdmin } = require('../middleware/adminAuth');

const router = express.Router();

// Protect all admin routes
router.use(protectAdmin);

// Dashboard routes
router.get('/dashboard/stats', getDashboardStats);
router.get('/dashboard/charts', getChartData);

// User management routes
router.get('/users', getAllUsers);
router.get('/users/:id', getUser);
router.put('/users/:id', updateUser);
router.put('/users/:id/verify-email', verifyUserEmail);
router.put('/users/:id/verify-phone', verifyUserPhone);
router.delete('/users/:id', deleteUser);

// Listing management routes
router.get('/listings', getAllListings);
router.put('/listings/:id/status', updateListingStatus);
router.delete('/listings/:id', deleteListing);

// Host management routes
router.get('/hosts/payout-settings', getHostPayoutSettings);
router.put('/hosts/:id/payout-verify', updatePayoutVerification);
router.get('/hosts', getHostRequests);
router.put('/hosts/:id/status', updateHostStatus);

// Booking management routes
router.get('/bookings', getAllBookings);
router.put('/bookings/:id/status', updateBookingStatus);

// Payments routes
router.get('/payments/transactions', getPaymentTransactions);
router.get('/payments/export', exportPaymentTransactions);
router.get('/payments/export-pdf', exportPaymentTransactionsPdf);

// Reports
router.get('/reports', generateReports);

// Push Notifications
router.post('/notifications/broadcast', sendBroadcastNotification);

module.exports = router;







