const logger = require('../utils/logger');

/**
 * SMS Service
 * 
 * Note: The mobile app uses Firebase Phone Authentication for SMS verification.
 * This service is kept for backend-initiated SMS (future use cases like
 * notifications, reminders, etc.). Currently operates in logging mode only.
 * 
 * To enable actual SMS sending in the future, integrate a service like:
 * - Twilio
 * - Africa's Talking
 * - AWS SNS
 */

class SMSService {
  constructor() {
    this.enabled = false;
    logger.info('SMS Service: Logging mode (Firebase handles phone auth)');
  }

  async sendVerificationCode(phoneNumber, code) {
    try {
      // Development/Logging mode - Firebase handles actual SMS sending
      logger.info(`📱 SMS Verification Code (Logged only): ${phoneNumber} -> ${code}`);
      logger.info(`📱 Note: Mobile app uses Firebase Phone Auth for actual SMS`);
      return { success: true, mode: 'logging' };
    } catch (error) {
      logger.error(`Failed to log SMS for ${phoneNumber}: ${error.message}`);
      throw error;
    }
  }

  async sendWelcomeSMS(phoneNumber, firstName) {
    try {
      logger.info(`📱 Welcome SMS (Logged only): ${firstName} at ${phoneNumber}`);
      return { success: true, mode: 'logging' };
    } catch (error) {
      logger.error(`Failed to log welcome SMS: ${error.message}`);
      return { success: false, error: error.message };
    }
  }

  async sendNotificationSMS(phoneNumber, message) {
    try {
      logger.info(`📱 Notification SMS (Logged only): ${phoneNumber}`);
      logger.info(`📱 Message: ${message}`);
      return { success: true, mode: 'logging' };
    } catch (error) {
      logger.error(`Failed to log notification SMS: ${error.message}`);
      return { success: false, error: error.message };
    }
  }
}

module.exports = new SMSService();
