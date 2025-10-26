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

// Payment confirmation endpoint (public - called by webhooks)
router.put('/:id/payment-confirm', paymentConfirmBooking);

module.exports = router;






















