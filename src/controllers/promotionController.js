const Promotion = require('../models/Promotion');
const AuditLog = require('../models/AuditLog');
const { AppError } = require('../middleware/errorHandler');

// @desc    Get all promotions
// @route   GET /api/v1/admin/promotions
// @access  Private/Admin
exports.getPromotions = async (req, res, next) => {
  try {
    const { page = 1, limit = 20, status, type } = req.query;

    const query = {};
    if (status) query.status = status;
    if (type) query.type = type;

    const skip = (parseInt(page) - 1) * parseInt(limit);

    const promotions = await Promotion.find(query)
      .populate('createdBy', 'profile.firstName profile.lastName')
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(parseInt(limit));

    const total = await Promotion.countDocuments(query);

    res.status(200).json({
      success: true,
      data: {
        promotions,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total,
          pages: Math.ceil(total / parseInt(limit)),
        },
      },
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get single promotion
// @route   GET /api/v1/admin/promotions/:id
// @access  Private/Admin
exports.getPromotion = async (req, res, next) => {
  try {
    const promotion = await Promotion.findById(req.params.id)
      .populate('createdBy', 'profile')
      .populate('targetUsers', 'email profile')
      .populate('targetListings', 'title location')
      .populate('usedBy.user', 'email profile')
      .populate('usedBy.booking');

    if (!promotion) {
      return next(new AppError('Promotion not found', 404));
    }

    res.status(200).json({
      success: true,
      data: promotion,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Create promotion
// @route   POST /api/v1/admin/promotions
// @access  Private/Admin
exports.createPromotion = async (req, res, next) => {
  try {
    const promotionData = {
      ...req.body,
      createdBy: req.user.id,
    };

    const promotion = await Promotion.create(promotionData);

    await AuditLog.create({
      action: 'promotion_created',
      performedBy: req.user.id,
      targetModel: 'Promotion',
      targetId: promotion._id,
      description: `Created promotion code: ${promotion.code}`,
      category: 'content_management',
    });

    res.status(201).json({
      success: true,
      data: promotion,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Update promotion
// @route   PUT /api/v1/admin/promotions/:id
// @access  Private/Admin
exports.updatePromotion = async (req, res, next) => {
  try {
    const promotion = await Promotion.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true, runValidators: true }
    );

    if (!promotion) {
      return next(new AppError('Promotion not found', 404));
    }

    await AuditLog.create({
      action: 'promotion_updated',
      performedBy: req.user.id,
      targetModel: 'Promotion',
      targetId: promotion._id,
      description: `Updated promotion code: ${promotion.code}`,
      category: 'content_management',
      changes: { after: req.body },
    });

    res.status(200).json({
      success: true,
      data: promotion,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Delete promotion
// @route   DELETE /api/v1/admin/promotions/:id
// @access  Private/Admin
exports.deletePromotion = async (req, res, next) => {
  try {
    const promotion = await Promotion.findById(req.params.id);

    if (!promotion) {
      return next(new AppError('Promotion not found', 404));
    }

    await promotion.remove();

    await AuditLog.create({
      action: 'promotion_deleted',
      performedBy: req.user.id,
      targetModel: 'Promotion',
      targetId: promotion._id,
      description: `Deleted promotion code: ${promotion.code}`,
      category: 'content_management',
      severity: 'medium',
    });

    res.status(200).json({
      success: true,
      message: 'Promotion deleted successfully',
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get promotion statistics
// @route   GET /api/v1/admin/promotions/stats
// @access  Private/Admin
exports.getPromotionStats = async (req, res, next) => {
  try {
    const stats = await Promotion.aggregate([
      {
        $facet: {
          totalPromotions: [{ $count: 'count' }],
          activePromotions: [
            {
              $match: {
                status: 'active',
                validFrom: { $lte: new Date() },
                validUntil: { $gte: new Date() },
              },
            },
            { $count: 'count' },
          ],
          usageStats: [
            {
              $group: {
                _id: null,
                totalUsage: { $sum: '$usageCount' },
                totalSavings: {
                  $sum: {
                    $reduce: {
                      input: '$usedBy',
                      initialValue: 0,
                      in: { $add: ['$$value', '$$this.discountAmount'] },
                    },
                  },
                },
              },
            },
          ],
          topPromotions: [
            { $sort: { usageCount: -1 } },
            { $limit: 5 },
            {
              $project: {
                code: 1,
                name: 1,
                usageCount: 1,
                type: 1,
                value: 1,
              },
            },
          ],
        },
      },
    ]);

    res.status(200).json({
      success: true,
      data: stats[0],
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Toggle promotion status
// @route   PUT /api/v1/admin/promotions/:id/toggle-status
// @access  Private/Admin
exports.togglePromotionStatus = async (req, res, next) => {
  try {
    const promotion = await Promotion.findById(req.params.id);

    if (!promotion) {
      return next(new AppError('Promotion not found', 404));
    }

    promotion.status = promotion.status === 'active' ? 'inactive' : 'active';
    await promotion.save();

    await AuditLog.create({
      action: 'promotion_updated',
      performedBy: req.user.id,
      targetModel: 'Promotion',
      targetId: promotion._id,
      description: `Changed promotion ${promotion.code} status to ${promotion.status}`,
      category: 'content_management',
    });

    res.status(200).json({
      success: true,
      data: promotion,
    });
  } catch (error) {
    next(error);
  }
};






