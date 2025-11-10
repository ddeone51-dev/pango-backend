const express = require('express');
const {
  getListings,
  getListing,
  createListing,
  updateListing,
  deleteListing,
  getFeaturedListings,
  getNearbyListings,
  getHostListings,
  getBookedDates,
  blockListingDates,
  unblockListingDate,
} = require('../controllers/listingController');
const { protect, authorize } = require('../middleware/auth');

const router = express.Router();

router.route('/')
  .get(getListings)
  .post(protect, authorize('host', 'admin'), createListing);

router.get('/featured', getFeaturedListings);
router.get('/nearby', getNearbyListings);
router.get('/host/:hostId', getHostListings);

// Booked date ranges for a listing (prevent overlapping bookings)
router.get('/:id/booked-dates', getBookedDates);
router.post('/:id/availability/block', protect, authorize('host', 'admin'), blockListingDates);
router.delete('/:id/availability/block/:blockId', protect, authorize('host', 'admin'), unblockListingDate);

router.route('/:id')
  .get(getListing)
  .put(protect, authorize('host', 'admin'), updateListing)
  .delete(protect, authorize('host', 'admin'), deleteListing);

module.exports = router;






