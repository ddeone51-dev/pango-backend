import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/booking_provider.dart';
import '../../core/providers/review_provider.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/config/routes.dart';
import '../reviews/review_screen.dart';

class BookingsListScreen extends StatefulWidget {
  const BookingsListScreen({super.key});

  @override
  State<BookingsListScreen> createState() => _BookingsListScreenState();
}

class _BookingsListScreenState extends State<BookingsListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Set<String> _confirmingArrivals = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().fetchBookings();
      context.read<ReviewProvider>().fetchEligibleBookings();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bookingProvider = context.watch<BookingProvider>();

    final upcomingBookings = bookingProvider.bookings
        .where((b) => ['pending', 'confirmed', 'in_progress', 'awaiting_arrival_confirmation'].contains(b.status))
        .toList();

    final pastBookings = bookingProvider.bookings
        .where((b) => ['completed', 'cancelled_by_guest', 'cancelled_by_host'].contains(b.status))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('my_bookings')),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.translate('upcoming')),
            Tab(text: l10n.translate('past')),
          ],
        ),
      ),
      body: bookingProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildBookingsList(upcomingBookings, true),
                _buildBookingsList(pastBookings, false),
              ],
            ),
    );
  }

  Widget _buildBookingsList(List bookings, bool isUpcoming) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              isUpcoming ? 'No upcoming bookings' : 'No past bookings',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<BookingProvider>().fetchBookings();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Booking #${booking.id.substring(0, 8).toUpperCase()}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      _buildStatusChip(booking.status),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        '${booking.checkInDate.day}/${booking.checkInDate.month}/${booking.checkInDate.year}',
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Icon(Icons.arrow_forward, size: 16),
                      ),
                      Text(
                        '${booking.checkOutDate.day}/${booking.checkOutDate.month}/${booking.checkOutDate.year}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.nights_stay, size: 16),
                      const SizedBox(width: 8),
                      Text('${booking.numberOfNights} nights'),
                      const SizedBox(width: 16),
                      const Icon(Icons.people, size: 16),
                      const SizedBox(width: 8),
                      Text('${booking.numberOfGuests} guests'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        CurrencyFormatter.format(booking.pricing.total),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  if (isUpcoming && booking.status != 'cancelled_by_guest') ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => _showCancelDialog(booking.id),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Cancel Booking'),
                      ),
                    ),
                  ],
                  if (isUpcoming && _shouldShowConfirmArrival(booking)) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _confirmingArrivals.contains(booking.id)
                            ? null
                            : () => _handleConfirmArrival(booking.id),
                        icon: _confirmingArrivals.contains(booking.id)
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.check_circle_outline),
                        label: Text(
                          _confirmingArrivals.contains(booking.id)
                              ? 'Confirming...'
                              : 'Confirm Arrival & Release Payment',
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tap after you reach the property so the host receives their payout.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                    ),
                  ],
                  // Add review button for completed bookings
                  if (!isUpcoming && booking.status == 'completed')
                    Consumer<ReviewProvider>(
                      builder: (context, reviewProvider, child) {
                        final eligibleBookingIds = reviewProvider.eligibleBookings
                            .map((b) => b.id)
                            .toSet();
                        final canReview = eligibleBookingIds.contains(booking.id);
                        
                        if (canReview) {
                          return Column(
                            children: [
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => ReviewScreen(
                                          bookingId: booking.id,
                                          listingId: booking.listingId,
                                        ),
                                      ),
                                    ).then((_) {
                                      // Refresh eligible bookings after review
                                      reviewProvider.fetchEligibleBookings();
                                    });
                                  },
                                  icon: const Icon(Icons.rate_review),
                                  label: const Text('Write a Review'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          );
                        } else {
                          return const Padding(
                            padding: EdgeInsets.only(top: 12),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.green, size: 16),
                                SizedBox(width: 8),
                                Text(
                                  'Review submitted',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;

    switch (status) {
      case 'confirmed':
        color = Colors.green;
        label = 'Confirmed';
        break;
      case 'awaiting_arrival_confirmation':
        color = Colors.orange;
        label = 'Awaiting arrival';
        break;
      case 'in_progress':
        color = Colors.blueGrey;
        label = 'In progress';
        break;
      case 'pending':
        color = Colors.orange;
        label = 'Pending';
        break;
      case 'completed':
        color = Colors.blue;
        label = 'Completed';
        break;
      case 'cancelled_by_guest':
      case 'cancelled_by_host':
        color = Colors.red;
        label = 'Cancelled';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  bool _shouldShowConfirmArrival(dynamic booking) {
    final statusAllows = ['awaiting_arrival_confirmation', 'confirmed'].contains(booking.status);
    final paymentCompleted = booking.payment.status == 'completed';
    final notConfirmed = booking.checkInConfirmed == false;
    final today = DateTime.now();
    final checkInReached = booking.checkInDate.isBefore(today.add(const Duration(days: 1)));
    return statusAllows && paymentCompleted && notConfirmed && checkInReached;
  }

  Future<void> _handleConfirmArrival(String bookingId) async {
    setState(() {
      _confirmingArrivals.add(bookingId);
    });
    final result = await context.read<BookingProvider>().confirmArrival(bookingId);
    if (!mounted) return;
    setState(() {
      _confirmingArrivals.remove(bookingId);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message']?.toString() ?? 'Arrival status updated'),
        backgroundColor: (result['success'] == true) ? Colors.green : Colors.orange,
      ),
    );
  }

  void _showCancelDialog(String bookingId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await context.read<BookingProvider>().cancelBooking(
                    bookingId,
                    'Cancelled by user',
                  );
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(success ? 'Booking cancelled' : 'Failed to cancel booking'),
                  backgroundColor: success ? Colors.green : Colors.red,
                ),
              );
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}




















