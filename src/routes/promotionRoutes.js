const express = require('express');
const router = express.Router();
const {
  getPromotions,
  getPromotion,
  createPromotion,
  updatePromotion,
  deletePromotion,
  getPromotionStats,
  togglePromotionStatus,
} = require('../controllers/promotionController');
const { protect } = require('../middleware/auth');
const { protectAdmin } = require('../middleware/adminAuth');

// All routes require authentication and admin role
router.use(protect, protectAdmin);

router.get('/', getPromotions);
router.get('/stats', getPromotionStats);
router.post('/', createPromotion);
router.get('/:id', getPromotion);
router.put('/:id', updatePromotion);
router.delete('/:id', deletePromotion);
router.put('/:id/toggle-status', togglePromotionStatus);

module.exports = router;

