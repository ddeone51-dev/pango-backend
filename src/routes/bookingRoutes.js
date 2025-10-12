const express = require('express');
const {
  createBooking,
  getBookings,
  getBooking,
  confirmBooking,
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

module.exports = router;












