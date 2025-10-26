const axios = require('axios');
const logger = require('../utils/logger');

class PesapalService {
  constructor() {
    // Pesapal API URLs - CRITICAL: /api suffix is required
    this.sandboxUrl = 'https://cybqa.pesapal.com/pesapalv3/api';
    this.productionUrl = 'https://www.pesapal.com/api';
    
    // Environment variables
    this.consumerKey = process.env.PESAPAL_CONSUMER_KEY;
    this.consumerSecret = process.env.PESAPAL_CONSUMER_SECRET;
    this.isProduction = process.env.NODE_ENV === 'production';
    
    // Current API URL based on environment
    this.baseUrl = this.isProduction ? this.productionUrl : this.sandboxUrl;
    
    // Callback URLs
    this.ipnUrl = process.env.PESAPAL_IPN_URL || `${process.env.BASE_URL}/api/v1/payments/pesapal/ipn`;
    this.callbackUrl = process.env.PESAPAL_CALLBACK_URL || `${process.env.BASE_URL}/api/v1/payments/pesapal/callback`;
  }

  /**
   * Generate Pesapal authentication token
   */
  async getAuthToken() {
    try {
      const authUrl = `${this.baseUrl}/Auth/RequestToken`;
      
      const payload = {
        consumer_key: this.consumerKey,
        consumer_secret: this.consumerSecret
      };

      logger.info('Requesting Pesapal auth token...');

      const response = await axios.post(authUrl, payload, {
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'User-Agent': 'Pango/1.0'
        }
      });

      if (response.data && response.data.token) {
        logger.info('✅ Pesapal auth successful');
        return response.data.token;
      }
      
      throw new Error('Failed to get authentication token');
    } catch (error) {
      logger.error('❌ Pesapal auth error:', error.response?.data || error.message);
      throw new Error(`Pesapal authentication failed: ${error.message}`);
    }
  }

  /**
   * Register IPN (Instant Payment Notification) URL
   * IMPORTANT: Register fresh IPN for each order as per best practices
   */
  async registerIPN(token, url) {
    try {
      const ipnUrl = `${this.baseUrl}/URLSetup/RegisterIPN`;
      
      const payload = {
        url: url || this.ipnUrl,
        ipn_notification_type: 'POST' // Changed to POST as per guide
      };

      logger.info('Registering IPN URL:', payload.url);

      const response = await axios.post(ipnUrl, payload, {
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`,
          'User-Agent': 'Pango/1.0'
        }
      });

      if (response.data && response.data.ipn_id) {
        logger.info('✅ IPN registered:', response.data.ipn_id);
        return response.data.ipn_id;
      }

      throw new Error('Failed to register IPN - no ipn_id received');
    } catch (error) {
      logger.error('❌ Pesapal IPN registration error:', error.response?.data || error.message);
      throw new Error(`IPN registration failed: ${error.message}`);
    }
  }

  /**
   * Submit payment order to Pesapal
   * Following best practices from guide
   */
  async submitOrder(paymentData) {
    try {
      // Step 1: Get authentication token
      const token = await this.getAuthToken();
      
      // Add small delay for rate limiting
      await new Promise(resolve => setTimeout(resolve, 1000));
      
      // Step 2: Register IPN for this order (fresh IPN each time)
      const ipnId = await this.registerIPN(token);
      
      // Add small delay
      await new Promise(resolve => setTimeout(resolve, 1000));
      
      // Step 3: Generate simple merchant reference (keep it short and simple)
      const merchantReference = `PANG${Date.now()}`;
      
      // Step 4: Prepare order data (use null for optional fields as per best practices)
      const orderData = {
        id: merchantReference,
        currency: paymentData.currency || 'TZS',
        amount: paymentData.amount,
        description: 'Pango Booking', // Keep description simple
        callback_url: this.callbackUrl,
        notification_id: ipnId,
        billing_address: {
          phone_number: paymentData.customerPhone || null,
          email_address: paymentData.customerEmail,
          country_code: 'TZ',
          first_name: paymentData.customerFirstName || 'Customer',
          last_name: paymentData.customerLastName || 'User',
          line_1: null, // Use null for optional fields
          line_2: null,
          city: null,
          state: null,
          postal_code: null,
          zip_code: null
        }
      };

      logger.info('Submitting order to Pesapal:', merchantReference);

      const submitOrderUrl = `${this.baseUrl}/Transactions/SubmitOrderRequest`;
      
      const response = await axios.post(submitOrderUrl, orderData, {
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`,
          'User-Agent': 'Pango/1.0'
        }
      });

      if (!response.data || !response.data.redirect_url) {
        throw new Error('No redirect URL received from Pesapal');
      }

      logger.info('✅ Order submitted successfully:', response.data.order_tracking_id);

      return {
        orderTrackingId: response.data.order_tracking_id,
        merchantReference: merchantReference,
        redirectUrl: response.data.redirect_url,
        ipnId: ipnId
      };
      
    } catch (error) {
      logger.error('❌ Pesapal submit order error:', error.response?.data || error.message);
      throw new Error(`Order submission failed: ${error.message}`);
    }
  }

  /**
   * Get payment status from Pesapal
   */
  async getPaymentStatus(orderTrackingId) {
    try {
      const token = await this.getAuthToken();
      const statusUrl = `${this.baseUrl}/Transactions/GetTransactionStatus?orderTrackingId=${orderTrackingId}`;
      
      const response = await axios.get(statusUrl, {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Accept': 'application/json'
        }
      });

      return response.data;
    } catch (error) {
      logger.error('Pesapal status check error:', error.response?.data || error.message);
      throw new Error(`Status check failed: ${error.message}`);
    }
  }

  /**
   * Validate Pesapal callback
   */
  validateCallback(orderTrackingId, orderMerchantReference) {
    // Validate that the callback contains expected data
    if (!orderTrackingId || !orderMerchantReference) {
      return false;
    }
    
    // Additional validation can be added here
    return true;
  }

  /**
   * Process successful payment
   */
  async processSuccessfulPayment(paymentData) {
    try {
      // This would typically update your database
      // Mark payment as completed, update booking status, etc.
      logger.info('Processing successful payment:', paymentData);
      
      return {
        success: true,
        message: 'Payment processed successfully'
      };
    } catch (error) {
      logger.error('Payment processing error:', error);
      throw new Error('Failed to process payment');
    }
  }
}

module.exports = new PesapalService();
