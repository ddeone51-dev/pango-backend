const express = require('express');
const { body, validationResult } = require('express-validator');
const {
  initiatePayment,
  handleCallback,
  handleIPN,
  getPaymentStatus,
  getPaymentHistory
} = require('../controllers/paymentController');
const auth = require('../middleware/auth');

const router = express.Router();

// Simple health to verify payments router is mounted in production
router.get('/health', (req, res) => {
  res.status(200).json({ success: true, message: 'payments router up' });
});

// Validation handler
const handleValidationErrors = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({
      success: false,
      message: 'Validation failed',
      errors: errors.array()
    });
  }
  next();
};

// Validation middleware
const validatePaymentInitiation = [
  body('listingId').isMongoId().withMessage('Valid listing ID is required'),
  body('bookingId').isMongoId().withMessage('Valid booking ID is required'),
  body('paymentMethod').isIn(['M-PESA', 'TIGO_PESA', 'AIRTEL_MONEY', 'VISA', 'MASTERCARD', 'BANK_TRANSFER'])
    .withMessage('Valid payment method is required'),
  body('customerPhone').isMobilePhone('any').withMessage('Valid phone number is required'),
  body('customerEmail').isEmail().withMessage('Valid email is required'),
  body('customerFirstName').optional().isString().isLength({ min: 1, max: 50 }),
  body('customerLastName').optional().isString().isLength({ min: 1, max: 50 }),
  body('customerAddress').optional().isString().isLength({ max: 200 }),
  body('customerCity').optional().isString().isLength({ max: 50 }),
  body('customerRegion').optional().isString().isLength({ max: 50 })
];

/**
 * @route   POST /api/v1/payments/initiate
 * @desc    Initiate Pesapal payment
 * @access  Private
 */
// Temporarily commented out to fix server startup
// router.post('/initiate', auth, ...validatePaymentInitiation, handleValidationErrors, initiatePayment);

/**
 * @route   GET /api/v1/payments/pesapal/callback
 * @desc    Handle Pesapal payment callback
 * @access  Public (Pesapal calls this)
 */
router.get('/pesapal/callback', handleCallback);

/**
 * @route   POST /api/v1/payments/pesapal/ipn
 * @desc    Handle Pesapal IPN (Instant Payment Notification)
 * @access  Public (Pesapal calls this)
 */
router.post('/pesapal/ipn', handleIPN);

/**
 * @route   POST /api/v1/payments/zenopay-webhook
 * @desc    Handle ZenoPay webhook notifications
 * @access  Public (ZenoPay calls this)
 */
router.post('/zenopay-webhook', async (req, res) => {
  try {
    const { order_id, payment_status, reference, metadata } = req.body;
    
    console.log('ZenoPay Webhook received:', {
      order_id,
      payment_status,
      reference,
      metadata
    });
    
    // Update booking status based on payment_status
    if (payment_status === 'COMPLETED') {
      // Find booking by orderId and update payment status
      const Booking = require('../models/Booking');
      const booking = await Booking.findOne({ orderId: order_id });
      
      if (booking) {
        booking.payment.status = 'completed';
        if (reference) booking.payment.transactionId = reference;
        booking.status = 'confirmed';
        booking.payment.paidAt = new Date();
        await booking.save();
        
        console.log(`✅ Booking ${booking._id} payment completed`);
      } else {
        console.log(`⚠️ No booking found for order ${order_id}`);
      }
    }
    
    res.status(200).json({ success: true, message: 'Webhook processed successfully' });
  } catch (error) {
    console.error('ZenoPay webhook error:', error);
    res.status(500).json({ success: false, message: 'Webhook processing failed' });
  }
});

/**
 * @route   GET /api/v1/payments/:paymentId/status
 * @desc    Get payment status
 * @access  Private
 */
// router.get('/:paymentId/status', auth, getPaymentStatus);

/**
 * @route   GET /api/v1/payments/history
 * @desc    Get user's payment history
 * @access  Private
 */
// router.get('/history', auth, getPaymentHistory);

module.exports = router;