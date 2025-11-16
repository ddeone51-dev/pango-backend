const PDFDocument = require('pdfkit');
const mongoose = require('mongoose');
const Booking = require('../models/Booking');
const Listing = require('../models/Listing');
const { AppError } = require('../middleware/errorHandler');
const logger = require('../utils/logger');
const pushNotificationService = require('../services/pushNotificationService');
const { calculateSplit, releaseHostPayout } = require('../services/payoutService');

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
      status: { $in: ['confirmed', 'pending', 'in_progress', 'awaiting_arrival_confirmation'] },
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
    const split = calculateSplit(total);
    const autoReleaseAt = new Date(checkIn);
    const autoReleaseHours = Number(process.env.PAYOUT_AUTO_RELEASE_HOURS || 24);
    autoReleaseAt.setHours(autoReleaseAt.getHours() + autoReleaseHours);

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
      arrival: {
        requiresConfirmation: true,
      },
      payout: {
        status: 'pending',
        platformFee: split.platformFee,
        hostAmount: split.hostAmount,
        currency: listing.pricing.currency,
        autoReleaseAt,
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

    if (!['pending', 'confirmed'].includes(booking.status)) {
      return next(new AppError('Booking cannot be confirmed', 400));
    }

    // Update booking status and payment info
    booking.status = 'awaiting_arrival_confirmation';
    booking.payment.status = 'completed';
    booking.payment.paidAt = new Date();
    booking.arrival = booking.arrival || { requiresConfirmation: true };
    booking.arrival.requiresConfirmation = true;
    booking.checkInConfirmed = false;

    booking.payout = booking.payout || {};
    const split = calculateSplit(booking.pricing?.total || 0);
    booking.payout.platformFee = split.platformFee;
    booking.payout.hostAmount = split.hostAmount;
    booking.payout.status = 'pending';
    booking.payout.currency = booking.pricing?.currency || 'TZS';
    const autoReleaseHours = Number(process.env.PAYOUT_AUTO_RELEASE_HOURS || 24);
    const autoReleaseAt = new Date(booking.checkInDate);
    autoReleaseAt.setHours(autoReleaseAt.getHours() + autoReleaseHours);
    booking.payout.autoReleaseAt = autoReleaseAt;

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

// @desc    Guest confirms arrival (releases host payout)
// @route   PUT /api/v1/bookings/:id/confirm-arrival
// @access  Private (Guest/Admin)
exports.confirmArrival = async (req, res, next) => {
  try {
    const booking = await Booking.findById(req.params.id);

    if (!booking) {
      return next(new AppError('Booking not found', 404));
    }

    const isGuest = booking.guestId.toString() === req.user.id;
    const isAdmin = req.user.role === 'admin';

    if (!isGuest && !isAdmin) {
      return next(new AppError('Only the guest can confirm arrival', 403));
    }

    if (booking.payment?.status !== 'completed') {
      return next(new AppError('Payment not completed yet', 400));
    }

    if (booking.checkInConfirmed) {
      return res.status(200).json({
        success: true,
        data: booking,
        message: 'Arrival already confirmed',
      });
    }

    booking.checkInConfirmed = true;
    booking.status = 'in_progress';
    booking.arrival = booking.arrival || {};
    booking.arrival.confirmedAt = new Date();
    booking.arrival.confirmedBy = req.user.id;
    booking.payout = booking.payout || {};
    booking.payout.status = 'ready_for_release';
    await booking.save();

    let payoutError;
    try {
      await releaseHostPayout(booking, { reason: 'guest_confirmed', initiatedBy: req.user.id });
    } catch (err) {
      payoutError = err.message;
    }

    res.status(payoutError ? 202 : 200).json({
      success: !payoutError,
      data: booking,
      message: payoutError
        ? `Arrival confirmed but payout pending: ${payoutError}`
        : 'Arrival confirmed and payout released',
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

exports.getHostCalendar = async (req, res, next) => {
  try {
    const hostId = req.user.id;
    if (!mongoose.Types.ObjectId.isValid(hostId)) {
      return next(new AppError('Invalid host id', 400));
    }
    const listings = await Listing.find({
      hostId,
      status: { $in: ['active', 'inactive'] },
    }).select('_id title location blockedDates availability');

    const blockingStatuses = ['pending', 'confirmed', 'in_progress', 'awaiting_arrival_confirmation'];
    const bookings = await Booking.find({
      hostId,
      status: { $in: blockingStatuses },
    })
      .select('listingId checkInDate checkOutDate status guestDetails')
      .populate('guestId', 'profile.firstName profile.lastName phoneNumber email');

    const bookingsByListing = bookings.reduce((acc, booking) => {
      const listingId = booking.listingId?._id?.toString() || booking.listingId?.toString();
      if (!listingId) return acc;
      if (!acc[listingId]) acc[listingId] = [];
      const guestName = booking.guestDetails?.fullName
        || `${booking.guestId?.profile?.firstName || ''} ${booking.guestId?.profile?.lastName || ''}`.trim();
      acc[listingId].push({
        id: booking._id,
        start: booking.checkInDate,
        end: booking.checkOutDate,
        status: booking.status,
        guestName: guestName || 'Guest',
        guestEmail: booking.guestDetails?.email || booking.guestId?.email || null,
        guestPhone: booking.guestDetails?.phoneNumber || booking.guestId?.phoneNumber || null,
      });
      return acc;
    }, {});

    const data = listings.map((listing) => {
      const listingId = listing._id.toString();
      const title = listing.title?.en || listing.title?.sw || listing.title || 'Listing';
      const blockedDates = (listing.blockedDates || []).map((block) => ({
        id: block._id,
        start: block.start,
        end: block.end,
        reason: block.reason,
        createdAt: block.createdAt,
      }));
      return {
        listingId,
        title,
        location: listing.location?.city || '',
        instantBooking: listing.availability?.instantBooking || false,
        blockedDates,
        bookings: bookingsByListing[listingId] || [],
      };
    });

    res.status(200).json({
      success: true,
      data,
    });
  } catch (error) {
    next(error);
  }
};

exports.getHostAnalytics = async (req, res, next) => {
  try {
    const hostId = req.user.id;
    if (!mongoose.Types.ObjectId.isValid(hostId)) {
      return next(new AppError('Invalid host id', 400));
    }
    const rangeDays = parseInt(req.query.range, 10) || 30;
    const now = new Date();
    const rangeStart = new Date(now);
    rangeStart.setDate(rangeStart.getDate() - Math.max(rangeDays - 1, 0));

    const listings = await Listing.find({ hostId }).select('_id title');
    const listingsCount = listings.length;

    const bookings = await Booking.find({ hostId })
      .populate('listingId', 'title')
      .select('checkInDate checkOutDate status pricing createdAt');

    const totalBookings = bookings.length;
    const upcomingBookings = bookings.filter((booking) => {
      const checkIn = new Date(booking.checkInDate);
      return checkIn >= now && ['pending', 'confirmed', 'in_progress', 'awaiting_arrival_confirmation'].includes(booking.status);
    }).length;
    const completedBookings = bookings.filter((booking) => booking.status === 'completed').length;
    const cancelledBookings = bookings.filter((booking) => String(booking.status).startsWith('cancelled')).length;

    const completedOrConfirmed = bookings.filter((booking) => ['completed', 'confirmed', 'awaiting_arrival_confirmation'].includes(booking.status));
    const totalRevenue = completedOrConfirmed.reduce((sum, booking) => (
      sum + (booking.pricing?.total || 0)
    ), 0);

    const rangeBookings = bookings.filter((booking) => (
      new Date(booking.checkInDate) >= rangeStart
    ));

    const revenueRange = rangeBookings
      .filter((booking) => ['completed', 'confirmed'].includes(booking.status))
      .reduce((sum, booking) => sum + (booking.pricing?.total || 0), 0);

    const calcNights = (start, end) => {
      const startDate = new Date(start);
      const endDate = new Date(end);
      const diff = Math.ceil((endDate - startDate) / (1000 * 60 * 60 * 24));
      return Number.isNaN(diff) || diff < 0 ? 0 : diff;
    };

    const totalNightsBooked = completedOrConfirmed.reduce((sum, booking) => (
      sum + calcNights(booking.checkInDate, booking.checkOutDate)
    ), 0);

    const rangeNightsBooked = rangeBookings
      .filter((booking) => ['completed', 'confirmed', 'in_progress', 'awaiting_arrival_confirmation'].includes(booking.status))
      .reduce((sum, booking) => sum + calcNights(booking.checkInDate, booking.checkOutDate), 0);

    const occupancyRate = listingsCount > 0 && rangeDays > 0
      ? Math.min(100, (rangeNightsBooked / (listingsCount * rangeDays)) * 100)
      : 0;

    const averageStay = completedBookings > 0
      ? totalNightsBooked / completedBookings
      : 0;

    const topListingsMap = {};
    bookings.forEach((booking) => {
      const listingId = booking.listingId?._id?.toString() || booking.listingId?.toString();
      if (!listingId) return;
      const title = booking.listingId?.title?.en
        || booking.listingId?.title?.sw
        || booking.listingId?.title
        || 'Listing';

      if (!topListingsMap[listingId]) {
        topListingsMap[listingId] = {
          listingId,
          title,
          bookings: 0,
          revenue: 0,
        };
      }

      topListingsMap[listingId].bookings += 1;
      if (['completed', 'confirmed', 'awaiting_arrival_confirmation'].includes(booking.status)) {
        topListingsMap[listingId].revenue += booking.pricing?.total || 0;
      }
    });

    const topListings = Object.values(topListingsMap)
      .sort((a, b) => b.bookings - a.bookings)
      .slice(0, 5);

    const sixMonthsAgo = new Date(now.getFullYear(), now.getMonth() - 5, 1);
    const trendAggregation = await Booking.aggregate([
      {
        $match: {
          hostId: new mongoose.Types.ObjectId(hostId),
          createdAt: { $gte: sixMonthsAgo },
        },
      },
      {
        $group: {
          _id: {
            year: { $year: '$createdAt' },
            month: { $month: '$createdAt' },
          },
          bookings: { $sum: 1 },
          revenue: { $sum: { $ifNull: ['$pricing.total', 0] } },
        },
      },
      { $sort: { '_id.year': 1, '_id.month': 1 } },
    ]);

    const monthlyTrend = trendAggregation.map((item) => ({
      label: `${item._id.year}-${String(item._id.month).padStart(2, '0')}`,
      bookings: item.bookings,
      revenue: item.revenue,
    }));

    res.status(200).json({
      success: true,
      data: {
        totals: {
          totalBookings,
          upcomingBookings,
          completedBookings,
          cancelledBookings,
        },
        revenue: {
          total: totalRevenue,
          range: revenueRange,
        },
        occupancyRate,
        averageStay,
        rangeDays,
        topListings,
        monthlyTrend,
      },
    });
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
      reason: req.body.reason || (isGuest ? 'Cancelled by guest' : 'Cancelled by host'),
    };

    if (booking.payout && booking.payout.status !== 'completed') {
      booking.payout.status = 'cancelled';
      booking.payout.failureReason = 'Booking cancelled before payout release';
    }

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
      status: { $in: ['confirmed', 'pending', 'awaiting_arrival_confirmation', 'in_progress'] },
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





















