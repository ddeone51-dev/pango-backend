const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/auth');
const FlaggedContent = require('../models/FlaggedContent');
const { AppError } = require('../middleware/errorHandler');

// @desc    Report content
// @route   POST /api/v1/moderation/report
// @access  Private
router.post('/report', protect, async (req, res, next) => {
  try {
    const {
      contentType,
      contentId,
      contentOwner,
      reason,
      description,
      evidence,
    } = req.body;

    // Validate required fields
    if (!contentType || !contentId || !contentOwner || !reason || !description) {
      return next(new AppError('Please provide all required fields', 400));
    }

    // Check if user has already reported this content
    const existingReport = await FlaggedContent.findOne({
      contentType,
      contentId,
      reportedBy: req.user.id,
    });

    if (existingReport) {
      return next(new AppError('You have already reported this content', 400));
    }

    // Create flagged content report
    const report = await FlaggedContent.create({
      contentType,
      contentId,
      contentOwner,
      reportedBy: req.user.id,
      reason,
      description,
      evidence: evidence || [],
      status: 'pending',
      priority: reason === 'fraud' || reason === 'violence' ? 'high' : 'medium',
    });

    res.status(201).json({
      success: true,
      message: 'Thank you for your report. We will review it shortly.',
      data: report,
    });
  } catch (error) {
    next(error);
  }
});

module.exports = router;






