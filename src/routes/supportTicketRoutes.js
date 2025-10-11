const express = require('express');
const router = express.Router();
const {
  getTickets,
  getTicket,
  assignTicket,
  replyToTicket,
  addInternalNote,
  updateTicket,
  resolveTicket,
  getTicketStats,
} = require('../controllers/supportTicketController');
const { protect } = require('../middleware/auth');
const { protectAdmin } = require('../middleware/adminAuth');

// All routes require authentication and admin role
router.use(protect, protectAdmin);

router.get('/', getTickets);
router.get('/stats', getTicketStats);
router.get('/:id', getTicket);
router.put('/:id', updateTicket);
router.put('/:id/assign', assignTicket);
router.post('/:id/reply', replyToTicket);
router.post('/:id/notes', addInternalNote);
router.put('/:id/resolve', resolveTicket);

module.exports = router;

