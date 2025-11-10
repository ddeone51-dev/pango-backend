const PDFDocument = require('pdfkit');
const Booking = require('../models/Booking');
const Listing = require('../models/Listing');
const { AppError } = require('../middleware/errorHandler');
const logger = require('../utils/logger');
const pushNotificationService = require('../services/pushNotificationService');

const formatCurrency = (amount, currency = 'TZS') => new Intl.NumberFormat('en-TZ', {
  style: 'currency',
  currency,
  minimumFractionDigits: 0,
}).format(amount || 0);

// @desc    Create a booking
// @route   POST /api/v1/bookings
// @access  Private
exports.createBooking = async (req, res, next) => {
  try {
    const {
      listingId,
      checkInDate,
      checkOutDate,
      numberOfGuests,
      guestDetails,
      paymentMethod,
    } = req.body;

    // Get listing
    const listing = await Listing.findById(listingId);

    if (!listing) {
      return next(new AppError('Listing not found', 404));
    }

    if (listing.status !== 'active') {
      return next(new AppError('This listing is not available', 400));
    }

    // Check if guest capacity is sufficient
    if (numberOfGuests > listing.capacity.guests) {
      return next(new AppError('Number of guests exceeds listing capacity', 400));
    }

    // Calculate number of nights
    const checkIn = new Date(checkInDate);
    const checkOut = new Date(checkOutDate);
    const nights = Math.ceil((checkOut - checkIn) / (1000 * 60 * 60 * 24));

    if (nights < listing.availability.minNights) {
      return next(
        new AppError(
          `Minimum stay is ${listing.availability.minNights} nights`,
          400
        )
      );
    }

    if (nights > listing.availability.maxNights) {
      return next(
        new AppError(
          `Maximum stay is ${listing.availability.maxNights} nights`,
          400
        )
      );
    }

    // Check for overlapping bookings
    const overlappingBooking = await Booking.findOne({
      listingId,
      status: { $in: ['confirmed', 'pending', 'in_progress'] },
      $or: [
        {
          checkInDate: { $lt: checkOut },
          checkOutDate: { $gt: checkIn },
        },
      ],
    });

    if (overlappingBooking) {
      return next(new AppError('Listing is not available for these dates', 400));
    }

    // Calculate pricing
    const subtotal = listing.pricing.basePrice * nights;
    const cleaningFee = listing.pricing.cleaningFee;
    const serviceFee = subtotal * 0.1; // 10% service fee
    const taxes = subtotal * 0.18; // 18% VAT
    const total = subtotal + cleaningFee + serviceFee + taxes;

    // Create booking
    const booking = await Booking.create({
      listingId,
      guestId: req.user.id,
      hostId: listing.hostId || req.user.id, // Use current user as hostId if listing.hostId is null
      checkInDate: checkIn,
      checkOutDate: checkOut,
      numberOfGuests,
      pricing: {
        nightlyRate: listing.pricing.basePrice,
        numberOfNights: nights,
        subtotal,
        cleaningFee,
        serviceFee,
        taxes,
        total,
        currency: listing.pricing.currency,
      },
      payment: {
        method: paymentMethod,
        orderId: req.body.orderId,
        transactionId: req.body.transactionId,
      },
      guestDetails,
    });

    logger.info(`New booking created: ${booking._id}`);

    // Populate listing for notifications
    await booking.populate('listingId');

    // Send push notification to host about new booking
    pushNotificationService.sendNewBookingToHost(booking).catch(err => {
      console.error('Failed to send booking notification to host:', err);
    });

    res.status(201).json({
      success: true,
      data: booking,
      message: 'Booking created successfully',
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get all bookings for user
// @route   GET /api/v1/bookings
// @access  Private
exports.getBookings = async (req, res, next) => {
  try {
    const { role, status } = req.query;
    
    let query;
    if (role === 'host') {
      query = { hostId: req.user.id };
    } else {
      query = { guestId: req.user.id };
    }

    if (status) {
      query.status = status;
    }

    const bookings = await Booking.find(query)
      .populate('listingId')
      .populate('guestId', 'profile.firstName profile.lastName profile.profilePicture')
      .populate('hostId', 'profile.firstName profile.lastName profile.profilePicture')
      .sort({ createdAt: -1 });

    res.status(200).json({
      success: true,
      data: bookings,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get single booking
// @route   GET /api/v1/bookings/:id
// @access  Private
exports.getBooking = async (req, res, next) => {
  try {
    const booking = await Booking.findById(req.params.id)
      .populate('listingId')
      .populate('guestId')
      .populate('hostId');

    if (!booking) {
      return next(new AppError('Booking not found', 404));
    }

    // Check if user is guest or host of this booking
    if (
      booking.guestId._id.toString() !== req.user.id &&
      booking.hostId._id.toString() !== req.user.id &&
      req.user.role !== 'admin'
    ) {
      return next(new AppError('Not authorized to view this booking', 401));
    }

    res.status(200).json({
      success: true,
      data: booking,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Confirm booking
// @route   PUT /api/v1/bookings/:id/confirm
// @access  Private (Host)
exports.confirmBooking = async (req, res, next) => {
  try {
    const booking = await Booking.findById(req.params.id);

    if (!booking) {
      return next(new AppError('Booking not found', 404));
    }

    // Only host can confirm
    if (booking.hostId.toString() !== req.user.id) {
      return next(new AppError('Not authorized to confirm this booking', 401));
    }

    if (booking.status !== 'pending') {
      return next(new AppError('Booking cannot be confirmed', 400));
    }

    booking.status = 'confirmed';
    await booking.save();

    // Populate for notifications
    await booking.populate('listingId');

    // Send confirmation notification to guest
    pushNotificationService.sendBookingConfirmation(booking).catch(err => {
      console.error('Failed to send booking confirmation:', err);
    });

    res.status(200).json({
      success: true,
      data: booking,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Confirm booking payment (for payment systems)
// @route   PUT /api/v1/bookings/:id/payment-confirm
// @access  Public (called by payment webhooks)
exports.paymentConfirmBooking = async (req, res, next) => {
  try {
    const booking = await Booking.findById(req.params.id);

    if (!booking) {
      return next(new AppError('Booking not found', 404));
    }

    if (booking.status !== 'pending') {
      return next(new AppError('Booking cannot be confirmed', 400));
    }

    // Update booking status and payment info
    booking.status = 'confirmed';
    booking.payment.status = 'completed';
    booking.payment.paidAt = new Date();
    await booking.save();

    res.status(200).json({
      success: true,
      data: booking,
      message: 'Booking payment confirmed successfully'
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Download booking receipt as PDF
// @route   GET /api/v1/bookings/:id/receipt
// @access  Private
exports.downloadReceipt = async (req, res, next) => {
  try {
    const booking = await Booking.findById(req.params.id)
      .populate('listingId', 'title location.address location.city')
      .populate('guestId', 'email phoneNumber profile.firstName profile.lastName')
      .populate('hostId', 'email phoneNumber profile.firstName profile.lastName');

    if (!booking) {
      return next(new AppError('Booking not found', 404));
    }

    const userId = req.user.id;
    const isGuest = booking.guestId?._id?.toString() === userId;
    const isHost = booking.hostId?._id?.toString() === userId;
    const isAdmin = req.user.role === 'admin';

    if (!isGuest && !isHost && !isAdmin) {
      return next(new AppError('Not authorized to download this receipt', 403));
    }

    if ((booking.payment?.status || 'pending') !== 'completed') {
      return next(new AppError('Receipt is available after payment is completed', 400));
    }

    const doc = new PDFDocument({ margin: 50 });
    const fileName = `booking-${booking._id}-receipt.pdf`;

    res.setHeader('Content-Type', 'application/pdf');
    res.setHeader('Content-Disposition', `attachment; filename="${fileName}"`);

    doc.pipe(res);

    doc
      .fontSize(20)
      .text('Homia Booking Receipt', { align: 'center' })
      .moveDown(1.5);

    doc
      .fontSize(12)
      .text(`Receipt #: ${booking._id}`)
      .text(`Issued: ${new Date().toLocaleDateString('en-GB')}`)
      .text(`Booking Reference: ${booking.payment?.orderId || booking._id}`)
      .moveDown();

    doc.fontSize(14).text('Guest Details', { underline: true });
    doc
      .fontSize(12)
      .text(`${booking.guestId?.profile?.firstName || ''} ${booking.guestId?.profile?.lastName || ''}`.trim())
      .text(booking.guestId?.email || 'N/A')
      .text(booking.guestId?.phoneNumber || 'N/A')
      .moveDown();

    doc.fontSize(14).text('Listing Details', { underline: true });
    doc
      .fontSize(12)
      .text(booking.listingId?.title || 'Listing')
      .text(booking.listingId?.location?.address || booking.listingId?.location?.city || 'Location not available')
      .moveDown();

    doc.fontSize(14).text('Booking Summary', { underline: true });
    doc
      .fontSize(12)
      .text(`Check-in: ${new Date(booking.checkInDate).toLocaleDateString('en-GB')}`)
      .text(`Check-out: ${new Date(booking.checkOutDate).toLocaleDateString('en-GB')}`)
      .text(`Nights: ${booking.pricing?.numberOfNights || 0}`)
      .text(`Guests: ${booking.numberOfGuests || 0}`)
      .moveDown();

    doc.fontSize(14).text('Payment Details', { underline: true });
    doc
      .fontSize(12)
      .text(`Status: ${(booking.payment?.status || 'completed').toUpperCase()}`)
      .text(`Method: ${(booking.payment?.method || 'N/A').toString().toUpperCase()}`)
      .text(`Transaction ID: ${booking.payment?.transactionId || 'N/A'}`)
      .text(`Amount Paid: ${formatCurrency(booking.pricing?.total, booking.pricing?.currency)}`)
      .moveDown(2);

    doc
      .fontSize(12)
      .text('Thank you for choosing Homia!', { align: 'center' })
      .moveDown()
      .fontSize(10)
      .text('For support, contact support@homia.com', { align: 'center' });

    doc.end();
  } catch (error) {
    next(error);
  }
};

// @desc    Cancel booking
// @route   PUT /api/v1/bookings/:id/cancel
// @access  Private
exports.cancelBooking = async (req, res, next) => {
  try {
    const booking = await Booking.findById(req.params.id);

    if (!booking) {
      return next(new AppError('Booking not found', 404));
    }

    // Check authorization
    const isGuest = booking.guestId.toString() === req.user.id;
    const isHost = booking.hostId.toString() === req.user.id;

    if (!isGuest && !isHost) {
      return next(new AppError('Not authorized to cancel this booking', 401));
    }

    if (['completed', 'cancelled_by_guest', 'cancelled_by_host'].includes(booking.status)) {
      return next(new AppError('Booking cannot be cancelled', 400));
    }

    booking.status = isGuest ? 'cancelled_by_guest' : 'cancelled_by_host';
    booking.cancellation = {
      cancelledBy: req.user.id,
      cancelledAt: Date.now(),
      reason: req.body.reason,
    };

    await booking.save();

    // Populate for notifications
    await booking.populate('listingId');

    // Send cancellation notification to guest if cancelled by host
    if (isHost) {
      pushNotificationService.sendBookingCancellation(booking, 'host').catch(err => {
        console.error('Failed to send cancellation notification:', err);
      });
    }

    res.status(200).json({
      success: true,
      data: booking,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get upcoming bookings
// @route   GET /api/v1/bookings/upcoming
// @access  Private
exports.getUpcomingBookings = async (req, res, next) => {
  try {
    const now = new Date();
    
    const bookings = await Booking.find({
      $or: [{ guestId: req.user.id }, { hostId: req.user.id }],
      checkInDate: { $gte: now },
      status: { $in: ['confirmed', 'pending'] },
    })
      .populate('listingId')
      .sort({ checkInDate: 1 });

    res.status(200).json({
      success: true,
      data: bookings,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get past bookings
// @route   GET /api/v1/bookings/past
// @access  Private
exports.getPastBookings = async (req, res, next) => {
  try {
    const now = new Date();
    
    const bookings = await Booking.find({
      $or: [{ guestId: req.user.id }, { hostId: req.user.id }],
      checkOutDate: { $lt: now },
      status: 'completed',
    })
      .populate('listingId')
      .sort({ checkOutDate: -1 });

    res.status(200).json({
      success: true,
      data: bookings,
    });
  } catch (error) {
    next(error);
  }
};





















