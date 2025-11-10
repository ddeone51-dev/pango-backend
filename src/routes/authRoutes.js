const express = require('express');
const {
  register,
  login,
  logout,
  getMe,
  forgotPassword,
  resetPassword,
  verifyEmail,
  sendPhoneVerificationCode,
  verifyPhone,
  sendEmailVerificationCode,
  requestHostRole,
} = require('../controllers/authController');
const { protect } = require('../middleware/auth');

const router = express.Router();

router.post('/register', register);
router.post('/login', login);
router.post('/logout', protect, logout);
router.get('/me', protect, getMe);
router.post('/request-host', protect, requestHostRole);
router.post('/forgot-password', forgotPassword);
router.post('/reset-password/:resetToken', resetPassword);
router.post('/verify-email', verifyEmail);
router.post('/send-phone-code', sendPhoneVerificationCode);
router.post('/verify-phone', verifyPhone);
router.post('/send-email-code', sendEmailVerificationCode);

module.exports = router;







