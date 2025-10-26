const express = require('express');
const {
  createBooking,
  getBookings,
  getBooking,
  confirmBooking,
  paymentConfirmBooking,
  cancelBooking,
  getUpcomingBookings,
  getPastBookings,
} = require('../controllers/bookingController');
const { protect } = require('../middleware/auth');

const router = express.Router();

// Clear all bookings endpoint (for development/testing)
router.delete('/clear-all', async (req, res) => {
  try {
    const Booking = require('../models/Booking');
    const deletedCount = await Booking.deleteMany({});
    
    res.status(200).json({
      success: true,
      message: `Cleared ${deletedCount.deletedCount} bookings`,
      deletedCount: deletedCount.deletedCount
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to clear bookings',
      error: error.message
    });
  }
});

// Payment confirmation endpoint (public - called by webhooks)
router.put('/:id/payment-confirm', paymentConfirmBooking);

router.use(protect);

router.route('/')
  .get(getBookings)
  .post(createBooking);

router.get('/upcoming', getUpcomingBookings);
router.get('/past', getPastBookings);

router.route('/:id')
  .get(getBooking);

router.put('/:id/confirm', confirmBooking);
router.put('/:id/cancel', cancelBooking);

module.exports = router;






















