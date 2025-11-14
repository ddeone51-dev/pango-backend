const express = require('express');
const {
  registerDeviceToken,
  removeDeviceToken,
  updateNotificationPreferences,
  getNotificationPreferences,
  sendTestNotification,
} = require('../controllers/pushNotificationController');
const { protect } = require('../middleware/auth');

const router = express.Router();

// All routes require authentication
router.use(protect);

// Device token management
router.post('/register-token', registerDeviceToken);
router.delete('/remove-token', removeDeviceToken);

// Notification preferences
router.get('/preferences', getNotificationPreferences);
router.put('/preferences', updateNotificationPreferences);

// Test notification
router.post('/test', sendTestNotification);

module.exports = router;





