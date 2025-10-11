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
} = require('../controllers/listingController');
const { protect, authorize } = require('../middleware/auth');

const router = express.Router();

router.route('/')
  .get(getListings)
  .post(protect, authorize('host', 'admin'), createListing);

router.get('/featured', getFeaturedListings);
router.get('/nearby', getNearbyListings);
router.get('/host/:hostId', getHostListings);

router.route('/:id')
  .get(getListing)
  .put(protect, authorize('host', 'admin'), updateListing)
  .delete(protect, authorize('host', 'admin'), deleteListing);

module.exports = router;






