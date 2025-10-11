const SupportTicket = require('../models/SupportTicket');
const AuditLog = require('../models/AuditLog');
const AppNotification = require('../models/AppNotification');
const { AppError } = require('../middleware/errorHandler');

// @desc    Get all support tickets
// @route   GET /api/v1/admin/support/tickets
// @access  Private/Admin
exports.getTickets = async (req, res, next) => {
  try {
    const {
      page = 1,
      limit = 20,
      status,
      priority,
      category,
      assignedTo,
      search,
    } = req.query;

    const query = {};
    if (status) query.status = status;
    if (priority) query.priority = priority;
    if (category) query.category = category;
    if (assignedTo) query.assignedTo = assignedTo;
    
    if (search) {
      query.$or = [
        { ticketNumber: { $regex: search, $options: 'i' } },
        { subject: { $regex: search, $options: 'i' } },
      ];
    }

    const skip = (parseInt(page) - 1) * parseInt(limit);

    const tickets = await SupportTicket.find(query)
      .populate('user', 'email profile.firstName profile.lastName')
      .populate('assignedTo', 'profile.firstName profile.lastName')
      .sort({ priority: -1, createdAt: -1 })
      .skip(skip)
      .limit(parseInt(limit));

    const total = await SupportTicket.countDocuments(query);

    // Get statistics
    const stats = await SupportTicket.aggregate([
      {
        $facet: {
          byStatus: [
            { $group: { _id: '$status', count: { $sum: 1 } } },
          ],
          byCategory: [
            { $group: { _id: '$category', count: { $sum: 1 } } },
          ],
          byPriority: [
            { $group: { _id: '$priority', count: { $sum: 1 } } },
          ],
        },
      },
    ]);

    res.status(200).json({
      success: true,
      data: {
        tickets,
        stats: stats[0],
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

// @desc    Get single ticket
// @route   GET /api/v1/admin/support/tickets/:id
// @access  Private/Admin
exports.getTicket = async (req, res, next) => {
  try {
    const ticket = await SupportTicket.findById(req.params.id)
      .populate('user', 'email profile phoneNumber')
      .populate('assignedTo', 'profile')
      .populate('relatedBooking')
      .populate('relatedListing', 'title location')
      .populate('messages.sender', 'profile.firstName profile.lastName')
      .populate('internalNotes.addedBy', 'profile.firstName profile.lastName');

    if (!ticket) {
      return next(new AppError('Ticket not found', 404));
    }

    res.status(200).json({
      success: true,
      data: ticket,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Assign ticket to admin
// @route   PUT /api/v1/admin/support/tickets/:id/assign
// @access  Private/Admin
exports.assignTicket = async (req, res, next) => {
  try {
    const { adminId } = req.body;

    const ticket = await SupportTicket.findByIdAndUpdate(
      req.params.id,
      {
        assignedTo: adminId || req.user.id,
        status: 'in_progress',
      },
      { new: true }
    );

    if (!ticket) {
      return next(new AppError('Ticket not found', 404));
    }

    await AuditLog.create({
      action: 'ticket_assigned',
      performedBy: req.user.id,
      targetModel: 'SupportTicket',
      targetId: ticket._id,
      description: `Assigned ticket ${ticket.ticketNumber}`,
      category: 'support',
    });

    res.status(200).json({
      success: true,
      data: ticket,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Reply to ticket
// @route   POST /api/v1/admin/support/tickets/:id/reply
// @access  Private/Admin
exports.replyToTicket = async (req, res, next) => {
  try {
    const { message } = req.body;

    const ticket = await SupportTicket.findById(req.params.id);

    if (!ticket) {
      return next(new AppError('Ticket not found', 404));
    }

    ticket.messages.push({
      sender: req.user.id,
      message,
      isStaffReply: true,
    });

    ticket.status = 'waiting_for_customer';
    await ticket.save();

    // Send notification to user
    await AppNotification.create({
      recipient: ticket.user,
      type: 'ticket_response',
      title: `Response to Ticket ${ticket.ticketNumber}`,
      message: 'Support has responded to your ticket',
      data: { ticketId: ticket._id },
      channel: 'email',
    });

    res.status(200).json({
      success: true,
      data: ticket,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Add internal note
// @route   POST /api/v1/admin/support/tickets/:id/notes
// @access  Private/Admin
exports.addInternalNote = async (req, res, next) => {
  try {
    const { note } = req.body;

    const ticket = await SupportTicket.findById(req.params.id);

    if (!ticket) {
      return next(new AppError('Ticket not found', 404));
    }

    ticket.internalNotes.push({
      note,
      addedBy: req.user.id,
    });

    await ticket.save();

    res.status(200).json({
      success: true,
      data: ticket,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Update ticket status/priority
// @route   PUT /api/v1/admin/support/tickets/:id
// @access  Private/Admin
exports.updateTicket = async (req, res, next) => {
  try {
    const { status, priority, category } = req.body;

    const updateData = {};
    if (status) updateData.status = status;
    if (priority) updateData.priority = priority;
    if (category) updateData.category = category;

    if (status === 'resolved') {
      updateData.resolvedAt = new Date();
    }
    if (status === 'closed') {
      updateData.closedAt = new Date();
    }

    const ticket = await SupportTicket.findByIdAndUpdate(
      req.params.id,
      updateData,
      { new: true, runValidators: true }
    );

    if (!ticket) {
      return next(new AppError('Ticket not found', 404));
    }

    await AuditLog.create({
      action: 'ticket_updated',
      performedBy: req.user.id,
      targetModel: 'SupportTicket',
      targetId: ticket._id,
      description: `Updated ticket ${ticket.ticketNumber}`,
      category: 'support',
      changes: { after: updateData },
    });

    res.status(200).json({
      success: true,
      data: ticket,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Resolve ticket
// @route   PUT /api/v1/admin/support/tickets/:id/resolve
// @access  Private/Admin
exports.resolveTicket = async (req, res, next) => {
  try {
    const ticket = await SupportTicket.findByIdAndUpdate(
      req.params.id,
      {
        status: 'resolved',
        resolvedAt: new Date(),
      },
      { new: true }
    );

    if (!ticket) {
      return next(new AppError('Ticket not found', 404));
    }

    // Notify user
    await AppNotification.create({
      recipient: ticket.user,
      type: 'ticket_resolved',
      title: `Ticket ${ticket.ticketNumber} Resolved`,
      message: 'Your support ticket has been resolved',
      data: { ticketId: ticket._id },
    });

    await AuditLog.create({
      action: 'ticket_resolved',
      performedBy: req.user.id,
      targetModel: 'SupportTicket',
      targetId: ticket._id,
      description: `Resolved ticket ${ticket.ticketNumber}`,
      category: 'support',
    });

    res.status(200).json({
      success: true,
      data: ticket,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get ticket statistics
// @route   GET /api/v1/admin/support/stats
// @access  Private/Admin
exports.getTicketStats = async (req, res, next) => {
  try {
    const { period = '30d' } = req.query;

    let startDate = new Date();
    if (period === '7d') startDate.setDate(startDate.getDate() - 7);
    else if (period === '30d') startDate.setDate(startDate.getDate() - 30);
    else if (period === '90d') startDate.setDate(startDate.getDate() - 90);

    const stats = await SupportTicket.aggregate([
      {
        $match: { createdAt: { $gte: startDate } },
      },
      {
        $facet: {
          totalTickets: [{ $count: 'count' }],
          byStatus: [
            { $group: { _id: '$status', count: { $sum: 1 } } },
          ],
          byCategory: [
            { $group: { _id: '$category', count: { $sum: 1 } } },
          ],
          byPriority: [
            { $group: { _id: '$priority', count: { $sum: 1 } } },
          ],
          avgResolutionTime: [
            {
              $match: { resolvedAt: { $exists: true } },
            },
            {
              $project: {
                resolutionTime: {
                  $subtract: ['$resolvedAt', '$createdAt'],
                },
              },
            },
            {
              $group: {
                _id: null,
                avgTime: { $avg: '$resolutionTime' },
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

