const nodemailer = require('nodemailer');
const logger = require('../utils/logger');

class EmailService {
  constructor() {
    this.transporter = null;
    this.enabled = false;
    this.initializeTransporter();
  }

  initializeTransporter() {
    // Check if email credentials are configured
    if (process.env.EMAIL_HOST && process.env.EMAIL_USER && process.env.EMAIL_PASS) {
      this.transporter = nodemailer.createTransporter({
        host: process.env.EMAIL_HOST,
        port: parseInt(process.env.EMAIL_PORT) || 587,
        secure: process.env.EMAIL_SECURE === 'true', // true for 465, false for other ports
        auth: {
          user: process.env.EMAIL_USER,
          pass: process.env.EMAIL_PASS,
        },
      });
      this.enabled = true;
      logger.info('Email service initialized');
    } else {
      logger.warn('Email credentials not configured. Emails will be logged only.');
    }
  }

  async sendVerificationEmail(email, token, firstName) {
    try {
      if (!this.enabled) {
        // Development mode - just log the token
        logger.info(`📧 Email (Development): Send to ${email}`);
        logger.info(`📧 VERIFICATION TOKEN: ${token}`);
        return { success: true, mode: 'development' };
      }

      // Production mode - actually send email
      const mailOptions = {
        from: `"Pango - Property Rentals" <${process.env.EMAIL_FROM || process.env.EMAIL_USER}>`,
        to: email,
        subject: 'Verify Your Pango Account',
        html: `
          <!DOCTYPE html>
          <html>
          <head>
            <style>
              body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
              .container { max-width: 600px; margin: 0 auto; padding: 20px; }
              .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
              .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }
              .code { background: #fff; border: 2px dashed #667eea; padding: 20px; text-align: center; font-size: 32px; letter-spacing: 8px; font-weight: bold; margin: 20px 0; border-radius: 8px; }
              .button { display: inline-block; padding: 15px 30px; background: #667eea; color: white; text-decoration: none; border-radius: 5px; font-weight: bold; margin: 20px 0; }
              .footer { text-align: center; color: #999; font-size: 12px; margin-top: 20px; }
            </style>
          </head>
          <body>
            <div class="container">
              <div class="header">
                <h1>🏠 Pango</h1>
                <p>Verify Your Account</p>
              </div>
              <div class="content">
                <h2>Karibu ${firstName}!</h2>
                <p>Thank you for registering with Pango. To complete your registration, please verify your email address.</p>
                
                <p><strong>Your verification code is:</strong></p>
                <div class="code">${token}</div>
                
                <p>Enter this code in the Pango app to verify your account.</p>
                
                <p><small>This code will expire in 24 hours.</small></p>
                
                <p>If you didn't create a Pango account, please ignore this email.</p>
                
                <hr style="border: 1px solid #eee; margin: 30px 0;">
                
                <p><strong>Why verify?</strong></p>
                <ul>
                  <li>✅ Secure your account</li>
                  <li>✅ Book properties</li>
                  <li>✅ List your own properties</li>
                  <li>✅ Receive booking notifications</li>
                </ul>
              </div>
              <div class="footer">
                <p>Pango - Find Your Perfect Stay in Tanzania 🇹🇿</p>
                <p>This is an automated email. Please do not reply.</p>
              </div>
            </div>
          </body>
          </html>
        `,
        text: `
          Karibu ${firstName}!
          
          Your Pango verification code is: ${token}
          
          Enter this code in the app to verify your account.
          
          This code will expire in 24 hours.
          
          If you didn't create a Pango account, please ignore this email.
          
          - Pango Team
        `,
      };

      const result = await this.transporter.sendMail(mailOptions);
      logger.info(`Email sent to ${email}: ${result.messageId}`);
      return { success: true, mode: 'production', messageId: result.messageId };
    } catch (error) {
      logger.error(`Failed to send email to ${email}: ${error.message}`);
      // Fallback to logging
      logger.info(`📧 EMAIL FALLBACK - Token for ${email}: ${token}`);
      throw error;
    }
  }

  async sendWelcomeEmail(email, firstName) {
    try {
      if (!this.enabled) {
        logger.info(`📧 Welcome email (Dev): ${firstName} at ${email}`);
        return { success: true, mode: 'development' };
      }

      const mailOptions = {
        from: `"Pango - Property Rentals" <${process.env.EMAIL_FROM || process.env.EMAIL_USER}>`,
        to: email,
        subject: 'Welcome to Pango! 🏠',
        html: `
          <!DOCTYPE html>
          <html>
          <head>
            <style>
              body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
              .container { max-width: 600px; margin: 0 auto; padding: 20px; }
              .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
              .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }
              .button { display: inline-block; padding: 15px 30px; background: #667eea; color: white; text-decoration: none; border-radius: 5px; font-weight: bold; }
            </style>
          </head>
          <body>
            <div class="container">
              <div class="header">
                <h1>🏠 Pango</h1>
                <h2>Karibu ${firstName}!</h2>
              </div>
              <div class="content">
                <p>Welcome to Pango - Tanzania's premier property rental platform!</p>
                
                <p><strong>What you can do now:</strong></p>
                <ul>
                  <li>🔍 Browse thousands of properties across Tanzania</li>
                  <li>📍 Find places in Dar es Salaam, Zanzibar, Arusha & more</li>
                  <li>💰 Book instantly with secure payments</li>
                  <li>🏠 List your own property and earn</li>
                </ul>
                
                <p>Start your journey today!</p>
                
                <p>Asante sana,<br>The Pango Team 🇹🇿</p>
              </div>
            </div>
          </body>
          </html>
        `,
      };

      const result = await this.transporter.sendMail(mailOptions);
      logger.info(`Welcome email sent to ${email}`);
      return { success: true, messageId: result.messageId };
    } catch (error) {
      logger.error(`Failed to send welcome email: ${error.message}`);
      return { success: false, error: error.message };
    }
  }
}

module.exports = new EmailService();







