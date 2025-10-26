const axios = require('axios');
const logger = require('../utils/logger');

class PaymentService {
  constructor() {
    this.secretKey = process.env.FLUTTERWAVE_SECRET_KEY;
    this.baseUrl = 'https://api.flutterwave.com/v3';
  }

  /**
   * Verify payment transaction with Flutterwave
   * @param {string} transactionId - Flutterwave transaction ID
   * @returns {Promise<Object>} - Verification result
   */
  async verifyTransaction(transactionId) {
    try {
      const response = await axios.get(
        `${this.baseUrl}/transactions/${transactionId}/verify`,
        {
          headers: {
            'Authorization': `Bearer ${this.secretKey}`,
            'Content-Type': 'application/json',
          },
        }
      );

      if (response.data.status === 'success') {
        const data = response.data.data;
        
        return {
          success: true,
          amount: data.amount,
          currency: data.currency,
          transactionId: data.id,
          txRef: data.tx_ref,
          status: data.status,
          paymentType: data.payment_type,
          customer: {
            name: data.customer.name,
            email: data.customer.email,
            phoneNumber: data.customer.phone_number,
          },
        };
      }

      return {
        success: false,
        message: 'Payment verification failed',
      };
    } catch (error) {
      logger.error('Payment verification error:', error);
      throw new Error('Failed to verify payment');
    }
  }

  /**
   * Process refund
   * @param {string} transactionId - Flutterwave transaction ID
   * @param {number} amount - Amount to refund
   * @returns {Promise<Object>} - Refund result
   */
  async processRefund(transactionId, amount) {
    try {
      const response = await axios.post(
        `${this.baseUrl}/transactions/${transactionId}/refund`,
        { amount },
        {
          headers: {
            'Authorization': `Bearer ${this.secretKey}`,
            'Content-Type': 'application/json',
          },
        }
      );

      if (response.data.status === 'success') {
        return {
          success: true,
          refundId: response.data.data.id,
          status: response.data.data.status,
        };
      }

      return {
        success: false,
        message: 'Refund failed',
      };
    } catch (error) {
      logger.error('Refund error:', error);
      throw new Error('Failed to process refund');
    }
  }

  /**
   * Handle webhook from Flutterwave
   * @param {Object} payload - Webhook payload
   * @param {string} signature - Webhook signature
   * @returns {Object} - Processed webhook data
   */
  handleWebhook(payload, signature) {
    // Verify webhook signature
    const webhookSecret = process.env.FLUTTERWAVE_WEBHOOK_SECRET;
    
    // In production, verify signature matches
    // For now, just process the webhook
    
    if (payload.event === 'charge.completed' && payload.data.status === 'successful') {
      return {
        success: true,
        transactionId: payload.data.id,
        txRef: payload.data.tx_ref,
        amount: payload.data.amount,
        currency: payload.data.currency,
      };
    }

    return {
      success: false,
      event: payload.event,
    };
  }
}

module.exports = new PaymentService();











