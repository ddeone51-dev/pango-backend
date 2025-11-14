const axios = require('axios');
const Booking = require('../models/Booking');
const User = require('../models/User');
const Transaction = require('../models/Transaction');
const logger = require('../utils/logger');

const PLATFORM_FEE_PERCENT = Number(process.env.PLATFORM_FEE_PERCENT || 7);
const AUTO_RELEASE_HOURS = Number(process.env.PAYOUT_AUTO_RELEASE_HOURS || 24);
const ZENOPAY_PAYOUT_API = process.env.ZENOPAY_PAYOUT_API;
const ZENOPAY_PAYOUT_KEY = process.env.ZENOPAY_PAYOUT_KEY;

const calculateSplit = (total = 0) => {
  const platformFee = Number(((total * PLATFORM_FEE_PERCENT) / 100).toFixed(2));
  const hostAmount = Math.max(Number((total - platformFee).toFixed(2)), 0);
  return {
    platformFee,
    hostAmount,
  };
};

const ensureHostPayoutReady = (host) => {
  const settings = host?.payoutSettings;
  if (!settings || !settings.method || !settings.isSetupComplete) {
    throw new Error('Host payout settings are incomplete');
  }

  if (settings.method === 'bank_account') {
    const { bankAccount = {} } = settings;
    if (!bankAccount.accountName || !bankAccount.accountNumber || !bankAccount.bankName) {
      throw new Error('Bank details are incomplete');
    }
  } else if (settings.method === 'mobile_money') {
    const { mobileMoney = {} } = settings;
    if (!mobileMoney.phoneNumber || !mobileMoney.provider) {
      throw new Error('Mobile money details are incomplete');
    }
  }

  return settings;
};

const buildDestination = (settings) => {
  if (settings.method === 'bank_account') {
    return {
      type: 'bank_account',
      accountName: settings.bankAccount.accountName,
      accountNumber: settings.bankAccount.accountNumber,
      bankName: settings.bankAccount.bankName,
      branchName: settings.bankAccount.branchName,
      swiftCode: settings.bankAccount.swiftCode,
    };
  }

  return {
    type: 'mobile_money',
    accountName: settings.mobileMoney.accountName || settings.mobileMoney.phoneNumber,
    phoneNumber: settings.mobileMoney.phoneNumber,
    provider: settings.mobileMoney.provider,
  };
};

const mockPayout = async (payload) => {
  logger.warn('ZenoPay payout credentials missing, mocking payout success');
  logger.info(`Mock payout payload: ${JSON.stringify(payload)}`);
  return {
    status: 'SUCCESS',
    reference: `MOCK-${Date.now()}`,
    providerResponse: payload,
  };
};

const sendPayoutToZenoPay = async (payload) => {
  if (!ZENOPAY_PAYOUT_API || !ZENOPAY_PAYOUT_KEY) {
    return mockPayout(payload);
  }

  const response = await axios.post(ZENOPAY_PAYOUT_API, payload, {
    headers: {
      Authorization: `Bearer ${ZENOPAY_PAYOUT_KEY}`,
      'Content-Type': 'application/json',
    },
    timeout: 20000,
  });

  return response.data;
};

const releaseHostPayout = async (bookingOrId, options = {}) => {
  const reason = options.reason || 'guest_confirmed';
  const initiatedBy = options.initiatedBy || 'system';

  const booking = typeof bookingOrId === 'string'
    ? await Booking.findById(bookingOrId)
    : bookingOrId;

  if (!booking) {
    throw new Error('Booking not found');
  }

  if (!booking.payment || booking.payment.status !== 'completed') {
    throw new Error('Payment not completed yet');
  }

  if (booking.payout?.status === 'completed') {
    logger.info(`Payout already completed for booking ${booking._id}`);
    return booking;
  }

  const host = await User.findById(booking.hostId).select('payoutSettings email phoneNumber profile');
  const payoutSettings = ensureHostPayoutReady(host);
  const destination = buildDestination(payoutSettings);

  const split = calculateSplit(booking.pricing?.total || 0);
  booking.payout = booking.payout || {};
  booking.payout.status = 'processing';
  booking.payout.platformFee = split.platformFee;
  booking.payout.hostAmount = split.hostAmount;
  booking.payout.currency = booking.pricing?.currency || 'TZS';
  booking.payout.method = payoutSettings.method;
  booking.payout.destination = destination;
  booking.payout.releaseReason = reason;
  await booking.save();

  const payoutPayload = {
    amount: split.hostAmount,
    currency: booking.payout.currency,
    reference: `HOMIA_PAYOUT_${booking._id}`,
    destination,
    metadata: {
      bookingId: booking._id.toString(),
      hostId: booking.hostId.toString(),
      reason,
    },
  };

  try {
    const payoutResponse = await sendPayoutToZenoPay(payoutPayload);
    booking.payout.status = 'completed';
    booking.payout.releasedAt = new Date();
    booking.payout.transactionReference = payoutResponse.reference || payoutResponse.id || payoutResponse.transactionId || `HP-${Date.now()}`;
    booking.payout.failureReason = undefined;
    await booking.save();

    await Transaction.create({
      booking: booking._id,
      user: booking.guestId,
      host: booking.hostId,
      listing: booking.listingId,
      amount: booking.pricing?.total || 0,
      platformFee: split.platformFee,
      hostPayout: split.hostAmount,
      currency: booking.payout.currency,
      type: 'payout',
      status: 'completed',
      paymentMethod: payoutSettings.method === 'bank_account' ? 'bank_transfer' : 'mobile_money',
      paymentProvider: destination.provider || destination.bankName || 'zenopay',
      transactionId: booking.payout.transactionReference,
      description: `Host payout for booking ${booking._id}`,
      processedAt: new Date(),
      metadata: {
        releaseReason: reason,
        initiatedBy,
      },
    });

    return booking;
  } catch (error) {
    logger.error(`Host payout failed for booking ${booking._id}: ${error.message}`);
    booking.payout.status = 'failed';
    booking.payout.failureReason = error.message;
    await booking.save();
    throw error;
  }
};

const processAutoRelease = async () => {
  const now = new Date();
  const candidates = await Booking.find({
    'payout.status': { $in: ['pending', 'ready_for_release', 'failed'] },
    'payout.autoReleaseAt': { $lte: now },
    status: { $in: ['confirmed', 'awaiting_arrival_confirmation', 'in_progress'] },
    checkInConfirmed: false,
  }).limit(10);

  for (const booking of candidates) {
    try {
      booking.arrival = booking.arrival || {};
      booking.arrival.autoConfirmedAt = new Date();
      booking.checkInConfirmed = true;
      booking.status = 'in_progress';
      await booking.save();
      await releaseHostPayout(booking, { reason: 'auto_release', initiatedBy: 'scheduler' });
    } catch (error) {
      logger.error(`Auto payout failed for booking ${booking._id}: ${error.message}`);
    }
  }
};

let payoutWatcherStarted = false;
const startPayoutWatcher = () => {
  if (payoutWatcherStarted) return;
  payoutWatcherStarted = true;
  const intervalMinutes = Number(process.env.PAYOUT_WATCH_INTERVAL_MINUTES || 15);
  setInterval(() => {
    processAutoRelease().catch((err) => logger.error(`Payout watcher error: ${err.message}`));
  }, intervalMinutes * 60 * 1000);
};

module.exports = {
  calculateSplit,
  releaseHostPayout,
  processAutoRelease,
  startPayoutWatcher,
};

