const express = require('express');
const helmet = require('helmet');
const cors = require('cors');
const mongoSanitize = require('express-mongo-sanitize');
const hpp = require('hpp');
const compression = require('compression');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');

const logger = require('./utils/logger');
const errorHandler = require('./middleware/errorHandler');
const routes = require('./routes');
const paymentRoutes = require('./routes/paymentRoutes');

const app = express();

// Trust proxy (needed for Render.com and other cloud platforms)
app.set('trust proxy', 1);

// Security middleware
app.use(helmet());

// CORS configuration
const corsOptions = {
  origin: process.env.FRONTEND_URL || '*',
  credentials: true,
  optionsSuccessStatus: 200,
};
app.use(cors(corsOptions));


// Body parser
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Serve static files (uploaded images)
app.use('/uploads', express.static('uploads'));

// Serve admin panel
app.use('/admin', express.static('public/admin'));

// Data sanitization against NoSQL injection
app.use(mongoSanitize());

// Prevent parameter pollution
app.use(hpp());

// Compression
app.use(compression());

// Logging
if (process.env.NODE_ENV === 'development') {
  app.use(morgan('dev'));
}

// Rate limiting
const limiter = rateLimit({
  windowMs: (process.env.RATE_LIMIT_WINDOW || 15) * 60 * 1000,
  max: process.env.RATE_LIMIT_MAX_REQUESTS || 100,
  message: 'Too many requests from this IP, please try again later.',
  standardHeaders: true,
  legacyHeaders: false,
});
app.use('/api', limiter);

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'Server is healthy',
    timestamp: new Date().toISOString(),
  });
});

// API routes
const apiBase = `/api/${process.env.API_VERSION || 'v1'}`;
app.use(apiBase, routes);

// Explicitly mount payments to ensure webhook path is available in all deploys
app.use(`${apiBase}/payments`, paymentRoutes);

// Failsafe: inline payments endpoints in case router mounting is bypassed in prod
// Health
app.get(`${apiBase}/payments/health`, (req, res) => {
  res.status(200).json({ success: true, message: 'payments router (inline) up' });
});

// ZenoPay webhook (inline)
app.post(`${apiBase}/payments/zenopay-webhook`, async (req, res) => {
  try {
    const { order_id, payment_status, reference } = req.body || {};
    if (!order_id) {
      return res.status(400).json({ success: false, message: 'order_id is required' });
    }
    if (payment_status === 'COMPLETED') {
      const Booking = require('./models/Booking');
      const booking = await Booking.findOne({ orderId: order_id });
      if (booking) {
        booking.payment = booking.payment || {};
        booking.payment.status = 'completed';
        if (reference) booking.payment.transactionId = reference;
        booking.payment.paidAt = new Date();
        await booking.save();
      }
    }
    res.status(200).json({ success: true, message: 'Webhook processed successfully' });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Webhook processing failed' });
  }
});

// 404 handler
app.all('*', (req, res) => {
  res.status(404).json({
    success: false,
    message: `Cannot find ${req.originalUrl} on this server!`,
  });
});

// Create admin user endpoint - Force deployment
app.post('/create-admin', async (req, res) => {
  try {
    const User = require('./models/User');
    const bcrypt = require('bcryptjs');
    
    const adminEmail = 'admin@pango.com';
    const adminPassword = 'admin123';
    
    // Check if admin already exists
    let admin = await User.findOne({ email: adminEmail });
    
    if (admin) {
      // Update existing admin
      const hashedPassword = await bcrypt.hash(adminPassword, 10);
      admin.password = hashedPassword;
      admin.role = 'admin';
      admin.accountStatus = 'active';
      await admin.save();
      
      res.json({
        success: true,
        message: 'Admin user updated successfully',
        email: adminEmail,
        password: adminPassword
      });
    } else {
      // Create new admin
      const hashedPassword = await bcrypt.hash(adminPassword, 10);
      admin = new User({
        email: adminEmail,
        phoneNumber: '+255000000000',
        password: hashedPassword,
        role: 'admin',
        accountStatus: 'active',
        profile: {
          firstName: 'Admin',
          lastName: 'User'
        }
      });
      
      await admin.save();
      
      res.json({
        success: true,
        message: 'Admin user created successfully',
        email: adminEmail,
        password: adminPassword
      });
    }
    
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Global error handler
app.use(errorHandler);

module.exports = app;



