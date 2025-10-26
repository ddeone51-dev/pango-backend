const express = require('express');
const authRoutes = require('./authRoutes');
const listingRoutes = require('./listingRoutes');
const bookingRoutes = require('./bookingRoutes');
const userRoutes = require('./userRoutes');
const uploadRoutes = require('./uploadRoutes');
const adminRoutes = require('./adminRoutes');
const paymentRoutes = require('./paymentRoutes');
const disputeRoutes = require('./disputeRoutes');
const supportTicketRoutes = require('./supportTicketRoutes');
const moderationRoutes = require('./moderationRoutes');
const promotionRoutes = require('./promotionRoutes');
const notificationRoutes = require('./notificationRoutes');
const analyticsRoutes = require('./analyticsRoutes');
const auditLogRoutes = require('./auditLogRoutes');
const reportRoutes = require('./reportRoutes');

const router = express.Router();

// Mount routes
router.use('/auth', authRoutes);
router.use('/listings', listingRoutes);
router.use('/bookings', bookingRoutes);
router.use('/users', userRoutes);
router.use('/upload', uploadRoutes);
router.use('/payments', paymentRoutes);
router.use('/admin', adminRoutes);
router.use('/payments', require('./paymentRoutes'));


// User report route (authenticated users can report content)
router.use('/moderation', reportRoutes);

// Admin-only routes
router.use('/admin/disputes', disputeRoutes);
router.use('/admin/support', supportTicketRoutes);
router.use('/admin/moderation', moderationRoutes);
router.use('/admin/promotions', promotionRoutes);
router.use('/admin/notifications', notificationRoutes);
router.use('/admin/analytics', analyticsRoutes);
router.use('/admin/audit-logs', auditLogRoutes);

// API info
router.get('/', (req, res) => {
  res.json({
    message: 'Pango API',
    version: '1.0.0',
    documentation: '/api-docs',
  });
});

module.exports = router;



