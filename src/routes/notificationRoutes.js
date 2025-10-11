const express = require('express');
const router = express.Router();
const {
  getNotifications,
  sendBroadcastNotification,
  sendNotification,
  getNotificationStats,
  deleteNotification,
} = require('../controllers/notificationController');
const { protect } = require('../middleware/auth');
const { protectAdmin } = require('../middleware/adminAuth');

// All routes require authentication and admin role
router.use(protect, protectAdmin);

router.get('/', getNotifications);
router.post('/broadcast', sendBroadcastNotification);
router.post('/send', sendNotification);
router.get('/stats', getNotificationStats);
router.delete('/:id', deleteNotification);

module.exports = router;

