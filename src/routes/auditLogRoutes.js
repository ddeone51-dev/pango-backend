const express = require('express');
const router = express.Router();
const {
  getAuditLogs,
  getAuditLog,
  getAuditLogStats,
  exportAuditLogs,
} = require('../controllers/auditLogController');
const { protect } = require('../middleware/auth');
const { protectAdmin } = require('../middleware/adminAuth');

// All routes require authentication and admin role
router.use(protect, protectAdmin);

router.get('/', getAuditLogs);
router.get('/stats', getAuditLogStats);
router.get('/export', exportAuditLogs);
router.get('/:id', getAuditLog);

module.exports = router;

