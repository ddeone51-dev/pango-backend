const AuditLog = require('../models/AuditLog');
const { AppError } = require('../middleware/errorHandler');

// @desc    Get audit logs
// @route   GET /api/v1/admin/audit-logs
// @access  Private/Admin
exports.getAuditLogs = async (req, res, next) => {
  try {
    const {
      page = 1,
      limit = 50,
      action,
      category,
      severity,
      performedBy,
      targetModel,
      startDate,
      endDate,
    } = req.query;

    const query = {};
    if (action) query.action = action;
    if (category) query.category = category;
    if (severity) query.severity = severity;
    if (performedBy) query.performedBy = performedBy;
    if (targetModel) query.targetModel = targetModel;

    if (startDate || endDate) {
      query.createdAt = {};
      if (startDate) query.createdAt.$gte = new Date(startDate);
      if (endDate) query.createdAt.$lte = new Date(endDate);
    }

    const skip = (parseInt(page) - 1) * parseInt(limit);

    const logs = await AuditLog.find(query)
      .populate('performedBy', 'email profile.firstName profile.lastName')
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(parseInt(limit));

    const total = await AuditLog.countDocuments(query);

    res.status(200).json({
      success: true,
      data: {
        logs,
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

// @desc    Get single audit log
// @route   GET /api/v1/admin/audit-logs/:id
// @access  Private/Admin
exports.getAuditLog = async (req, res, next) => {
  try {
    const log = await AuditLog.findById(req.params.id)
      .populate('performedBy', 'email profile');

    if (!log) {
      return next(new AppError('Audit log not found', 404));
    }

    res.status(200).json({
      success: true,
      data: log,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get audit log statistics
// @route   GET /api/v1/admin/audit-logs/stats
// @access  Private/Admin
exports.getAuditLogStats = async (req, res, next) => {
  try {
    const { period = '30d' } = req.query;

    let startDate = new Date();
    if (period === '7d') startDate.setDate(startDate.getDate() - 7);
    else if (period === '30d') startDate.setDate(startDate.getDate() - 30);
    else if (period === '90d') startDate.setDate(startDate.getDate() - 90);

    const stats = await AuditLog.aggregate([
      {
        $match: { createdAt: { $gte: startDate } },
      },
      {
        $facet: {
          totalActions: [{ $count: 'count' }],
          byAction: [
            { $group: { _id: '$action', count: { $sum: 1 } } },
            { $sort: { count: -1 } },
            { $limit: 10 },
          ],
          byCategory: [
            { $group: { _id: '$category', count: { $sum: 1 } } },
          ],
          bySeverity: [
            { $group: { _id: '$severity', count: { $sum: 1 } } },
          ],
          topAdmins: [
            { $group: { _id: '$performedBy', actions: { $sum: 1 } } },
            { $sort: { actions: -1 } },
            { $limit: 10 },
            {
              $lookup: {
                from: 'users',
                localField: '_id',
                foreignField: '_id',
                as: 'adminInfo',
              },
            },
            { $unwind: '$adminInfo' },
          ],
          activityOverTime: [
            {
              $group: {
                _id: {
                  $dateToString: { format: '%Y-%m-%d', date: '$createdAt' },
                },
                count: { $sum: 1 },
              },
            },
            { $sort: { _id: 1 } },
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

// @desc    Export audit logs
// @route   GET /api/v1/admin/audit-logs/export
// @access  Private/Admin
exports.exportAuditLogs = async (req, res, next) => {
  try {
    const { startDate, endDate, format = 'json' } = req.query;

    const query = {};
    if (startDate || endDate) {
      query.createdAt = {};
      if (startDate) query.createdAt.$gte = new Date(startDate);
      if (endDate) query.createdAt.$lte = new Date(endDate);
    }

    const logs = await AuditLog.find(query)
      .populate('performedBy', 'email profile.firstName profile.lastName')
      .sort({ createdAt: -1 })
      .lean();

    if (format === 'csv') {
      // Convert to CSV format
      const csv = [
        'Date,Action,Performed By,Category,Severity,Description',
        ...logs.map((log) =>
          [
            log.createdAt,
            log.action,
            log.performedBy?.email || 'N/A',
            log.category,
            log.severity,
            `"${log.description}"`,
          ].join(',')
        ),
      ].join('\n');

      res.header('Content-Type', 'text/csv');
      res.header('Content-Disposition', 'attachment; filename=audit-logs.csv');
      return res.send(csv);
    }

    res.status(200).json({
      success: true,
      data: logs,
    });
  } catch (error) {
    next(error);
  }
};

