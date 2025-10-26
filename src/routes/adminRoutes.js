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
router.delete('/users/:id', deleteUser);

// Listing management routes
router.get('/listings', getAllListings);
router.put('/listings/:id/status', updateListingStatus);
router.delete('/listings/:id', deleteListing);

// Booking management routes
router.get('/bookings', getAllBookings);
router.put('/bookings/:id/status', updateBookingStatus);

// Reports
router.get('/reports', generateReports);

// Push Notifications
router.post('/notifications/broadcast', sendBroadcastNotification);

module.exports = router;







