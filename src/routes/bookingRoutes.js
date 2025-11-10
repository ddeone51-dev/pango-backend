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
  downloadReceipt,
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

// Fix booking ownership endpoint (for development/testing)
router.put('/fix-ownership', async (req, res) => {
  try {
    const Booking = require('../models/Booking');
    const User = require('../models/User');
    
    // Find the booking
    const booking = await Booking.findById('68fe9fafaeb5fcdc89722827');
    if (!booking) {
      return res.status(404).json({
        success: false,
        message: 'Booking not found'
      });
    }
    
    // Find the user with email ddeone52@gmail.com (from your logs)
    let user = await User.findOne({ email: 'ddeone52@gmail.com' });
    if (!user) {
      // Create the user if it doesn't exist
      user = new User({
        email: 'ddeone52@gmail.com',
        password: 'temp123', // temporary password
        profile: {
          firstName: 'Ddeone',
          lastName: 'Mwita'
        },
        phoneNumber: '+255767310875',
        role: 'guest',
        isEmailVerified: true
      });
      await user.save();
    }
    
    // Update booking to belong to this user
    booking.guestId = user._id;
    await booking.save();
    
    res.status(200).json({
      success: true,
      message: 'Booking ownership fixed',
      bookingId: booking._id,
      guestId: user._id,
      guestEmail: user.email
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fix booking ownership',
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

router.get('/:id/receipt', downloadReceipt);

router.route('/:id')
  .get(getBooking);

router.put('/:id/confirm', confirmBooking);
router.put('/:id/cancel', cancelBooking);

module.exports = router;






















