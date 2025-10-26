const Payment = require('../models/Payment');
const Booking = require('../models/Booking');
const Listing = require('../models/Listing');
const User = require('../models/User');
const pesapalService = require('../services/pesapalService');
const logger = require('../utils/logger');

/**
 * Initiate Pesapal payment
 */
const initiatePayment = async (req, res) => {
  try {
    const { 
      listingId, 
      bookingId, 
      paymentMethod, 
      customerPhone, 
      customerEmail,
      customerFirstName,
      customerLastName,
      customerAddress,
      customerCity,
      customerRegion
    } = req.body;

    const userId = req.user.id;

    // Validate required fields
    if (!listingId || !bookingId || !paymentMethod || !customerPhone || !customerEmail) {
      return res.status(400).json({
        success: false,
        message: 'Missing required payment information'
      });
    }

    // Get booking details
    const booking = await Booking.findById(bookingId).populate('listingId');
    if (!booking) {
      return res.status(404).json({
        success: false,
        message: 'Booking not found'
      });
    }

    // Verify booking belongs to user
    if (booking.userId.toString() !== userId) {
      return res.status(403).json({
        success: false,
        message: 'Unauthorized access to booking'
      });
    }

    // Calculate payment amount
    const amount = booking.totalAmount;
    
    // Check if payment already exists
    const existingPayment = await Payment.findOne({ 
      bookingId,
      status: { $in: ['PENDING', 'COMPLETED'] }
    });

    if (existingPayment) {
      return res.status(400).json({
        success: false,
        message: 'Payment already exists for this booking',
        paymentId: existingPayment._id
      });
    }

    // Create payment record
    const payment = new Payment({
      amount,
      currency: 'TZS',
      userId,
      listingId,
      bookingId,
      paymentMethod,
      customerPhone,
      customerEmail,
      customerFirstName: customerFirstName || 'Customer',
      customerLastName: customerLastName || '',
      status: 'PENDING'
    });

    await payment.save();

    // Prepare payment data for Pesapal
    const paymentData = {
      amount: amount,
      currency: 'TZS',
      description: `Pango booking for ${booking.listingId.title}`,
      customerPhone,
      customerEmail,
      customerFirstName: customerFirstName || 'Customer',
      customerLastName: customerLastName || '',
      customerAddress,
      customerCity,
      customerRegion
    };

    // Submit to Pesapal
    const pesapalResponse = await pesapalService.submitOrder(paymentData);

    // Update payment with Pesapal details
    payment.pesapalOrderTrackingId = pesapalResponse.orderTrackingId;
    payment.pesapalMerchantReference = pesapalResponse.merchantReference;
    await payment.save();

    res.status(200).json({
      success: true,
      message: 'Payment initiated successfully',
      data: {
        paymentId: payment._id,
        orderTrackingId: pesapalResponse.orderTrackingId,
        merchantReference: pesapalResponse.merchantReference,
        redirectUrl: pesapalResponse.redirectUrl,
        amount: payment.formattedAmount
      }
    });

  } catch (error) {
    logger.error('Payment initiation error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to initiate payment',
      error: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
};

/**
 * Handle Pesapal callback
 */
const handleCallback = async (req, res) => {
  try {
    const { OrderTrackingId, OrderMerchantReference, OrderNotificationType } = req.query;

    logger.info('Pesapal callback received:', {
      OrderTrackingId,
      OrderMerchantReference,
      OrderNotificationType
    });

    // Validate callback
    if (!pesapalService.validateCallback(OrderTrackingId, OrderMerchantReference)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid callback data'
      });
    }

    // Find payment record
    const payment = await Payment.findOne({ 
      pesapalMerchantReference: OrderMerchantReference 
    });

    if (!payment) {
      logger.error('Payment not found for merchant reference:', OrderMerchantReference);
      return res.status(404).json({
        success: false,
        message: 'Payment not found'
      });
    }

    // Get payment status from Pesapal
    const statusResponse = await pesapalService.getPaymentStatus(OrderTrackingId);
    
    // Update payment status
    payment.pesapalCallbackData = statusResponse;
    payment.pesapalTransactionId = OrderTrackingId;

    if (statusResponse.payment_status_description === 'COMPLETED') {
      payment.status = 'COMPLETED';
      payment.completedAt = new Date();
      
      // Update booking status
      await Booking.findByIdAndUpdate(payment.bookingId, {
        status: 'CONFIRMED',
        paymentStatus: 'PAID'
      });

      // Process successful payment
      await pesapalService.processSuccessfulPayment(payment);
    } else if (statusResponse.payment_status_description === 'FAILED') {
      payment.status = 'FAILED';
    }

    await payment.save();

    // Redirect to frontend with status
    const redirectUrl = `${process.env.FRONTEND_URL}/payment/result?status=${payment.status}&paymentId=${payment._id}`;
    res.redirect(redirectUrl);

  } catch (error) {
    logger.error('Payment callback error:', error);
    res.status(500).json({
      success: false,
      message: 'Callback processing failed'
    });
  }
};

/**
 * Handle IPN (Instant Payment Notification)
 * Changed to POST as per best practices
 */
const handleIPN = async (req, res) => {
  try {
    logger.info('=== PESAPAL IPN RECEIVED ===');
    logger.info('Timestamp:', new Date().toISOString());
    logger.info('Headers:', req.headers);
    logger.info('Body:', req.body);
    logger.info('Query:', req.query);
    logger.info('===============================');

    // Pesapal sends data in body for POST
    const { OrderTrackingId, OrderMerchantReference, PaymentStatus, OrderNotificationType } = req.body;

    if (!OrderTrackingId || !OrderMerchantReference) {
      logger.error('Invalid IPN data - missing required fields');
      return res.status(400).json({ 
        success: false, 
        message: 'Invalid IPN data' 
      });
    }

    // Find and update payment
    const payment = await Payment.findOne({ 
      pesapalMerchantReference: OrderMerchantReference 
    });

    if (payment) {
      // Get updated status from Pesapal
      const statusResponse = await pesapalService.getPaymentStatus(OrderTrackingId);
      
      payment.pesapalCallbackData = statusResponse;
      payment.pesapalTransactionId = OrderTrackingId;
      
      if (statusResponse.payment_status_description === 'COMPLETED' && payment.status !== 'COMPLETED') {
        payment.status = 'COMPLETED';
        payment.completedAt = new Date();
        
        logger.info('✅ Payment completed:', OrderMerchantReference);
        
        // Update booking
        await Booking.findByIdAndUpdate(payment.bookingId, {
          status: 'CONFIRMED',
          paymentStatus: 'PAID'
        });
      }
      
      await payment.save();
      logger.info('Payment record updated successfully');
    } else {
      logger.warn('Payment not found for merchant reference:', OrderMerchantReference);
    }

    res.status(200).json({ success: true, message: 'IPN received' });

  } catch (error) {
    logger.error('❌ IPN processing error:', error);
    res.status(500).json({
      success: false,
      message: 'IPN processing failed'
    });
  }
};

/**
 * Get payment status
 */
const getPaymentStatus = async (req, res) => {
  try {
    const { paymentId } = req.params;
    const userId = req.user.id;

    const payment = await Payment.findOne({ 
      _id: paymentId, 
      userId 
    }).populate('listingId bookingId');

    if (!payment) {
      return res.status(404).json({
        success: false,
        message: 'Payment not found'
      });
    }

    // If payment is still pending, check with Pesapal
    if (payment.status === 'PENDING' && payment.pesapalOrderTrackingId) {
      try {
        const statusResponse = await pesapalService.getPaymentStatus(payment.pesapalOrderTrackingId);
        
        if (statusResponse.payment_status_description === 'COMPLETED' && payment.status !== 'COMPLETED') {
          payment.status = 'COMPLETED';
          payment.completedAt = new Date();
          await payment.save();
        }
      } catch (error) {
        logger.error('Status check error:', error);
      }
    }

    res.status(200).json({
      success: true,
      data: payment
    });

  } catch (error) {
    logger.error('Get payment status error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get payment status'
    });
  }
};

/**
 * Get user's payment history
 */
const getPaymentHistory = async (req, res) => {
  try {
    const userId = req.user.id;
    const { page = 1, limit = 10 } = req.query;

    const payments = await Payment.find({ userId })
      .populate('listingId bookingId')
      .sort({ createdAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit);

    const total = await Payment.countDocuments({ userId });

    res.status(200).json({
      success: true,
      data: {
        payments,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total,
          pages: Math.ceil(total / limit)
        }
      }
    });

  } catch (error) {
    logger.error('Get payment history error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get payment history'
    });
  }
};

module.exports = {
  initiatePayment,
  handleCallback,
  handleIPN,
  getPaymentStatus,
  getPaymentHistory
};