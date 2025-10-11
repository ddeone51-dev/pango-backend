const express = require('express');
const router = express.Router();
const {
  getDisputes,
  getDispute,
  assignDispute,
  addMessage,
  resolveDispute,
  closeDispute,
} = require('../controllers/disputeController');
const { protect } = require('../middleware/auth');
const { protectAdmin } = require('../middleware/adminAuth');

// All routes require authentication and admin role
router.use(protect, protectAdmin);

router.get('/', getDisputes);
router.get('/:id', getDispute);
router.put('/:id/assign', assignDispute);
router.post('/:id/messages', addMessage);
router.put('/:id/resolve', resolveDispute);
router.put('/:id/close', closeDispute);

module.exports = router;

