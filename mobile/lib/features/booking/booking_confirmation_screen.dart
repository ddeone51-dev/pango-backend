import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/booking_provider.dart';
import '../../core/config/routes.dart';
import '../../core/l10n/app_localizations.dart';

class BookingConfirmationScreen extends StatefulWidget {
  final String bookingId;

  const BookingConfirmationScreen({super.key, required this.bookingId});

  @override
  State<BookingConfirmationScreen> createState() => _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  bool _refreshing = false;
  bool _downloadingReceipt = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.bookingId.isNotEmpty) {
        context.read<BookingProvider>().fetchBookingById(widget.bookingId);
      }
    });
  }

  Future<void> _handleDownloadReceipt(BookingProvider bookingProvider) async {
    final booking = bookingProvider.selectedBooking;
    if (booking == null) return;

    setState(() => _downloadingReceipt = true);
    final file = await bookingProvider.downloadReceipt(booking.id);
    if (!mounted) return;

    setState(() => _downloadingReceipt = false);

    final message = file != null
        ? 'Receipt downloaded. Check your documents folder.'
        : bookingProvider.error ?? 'Failed to download receipt.';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: file != null ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bookingProvider = context.watch<BookingProvider>();
    final booking = bookingProvider.selectedBooking;
    final paymentStatus =
        booking == null ? '' : (booking.payment.status).toLowerCase();
    final isPaymentCompleted =
        paymentStatus == 'completed' || booking?.status == 'completed';
    final isAwaitingArrival = booking?.status == 'awaiting_arrival_confirmation';
    final isBookingConfirmed = booking == null
        ? false
        : ['confirmed', 'completed', 'in_progress', 'awaiting_arrival_confirmation']
            .contains(booking.status);
    final isProcessingState = !(isPaymentCompleted && isBookingConfirmed);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isProcessingState
              ? l10n.translate('payment_processing')
              : l10n.translate('booking_confirmed'),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pushNamedAndRemoveUntil(
              Routes.main,
              (route) => false,
              arguments: 0, // Navigate to home tab (index 0)
            );
          },
        ),
      ),
      body: booking == null
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Status Icon
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: isProcessingState ? Colors.orange.shade50 : Colors.green.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isProcessingState ? Icons.hourglass_bottom_rounded : Icons.check_circle_rounded,
                        size: 80,
                        color: isProcessingState ? Colors.orange.shade600 : Colors.green.shade500,
                      ),
                    ),

                    const SizedBox(height: 32),

                    Text(
                      isProcessingState
                          ? l10n.translate('payment_processing')
                          : l10n.translate('booking_confirmed'),
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 16),

                    Text(
                      isProcessingState
                          ? 'We sent a payment request to your SIM. This can take up to 1–2 minutes. You can refresh below.'
                          : isAwaitingArrival
                              ? 'Payment confirmed! Please confirm your arrival from My Bookings once you reach the property so we can release payment to your host.'
                              : 'Your booking has been successfully confirmed. You will receive a confirmation email shortly.',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 32),

                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildInfoRow('Booking ID', '#${booking.id.substring(0, 8).toUpperCase()}'),
                            const Divider(height: 24),
                            _buildInfoRow('Status', booking.status.toUpperCase()),
                            const Divider(height: 24),
                            _buildInfoRow('Check-in', '${booking.checkInDate.day}/${booking.checkInDate.month}/${booking.checkInDate.year}'),
                            _buildInfoRow('Check-out', '${booking.checkOutDate.day}/${booking.checkOutDate.month}/${booking.checkOutDate.year}'),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      child: isProcessingState
                          ? ElevatedButton.icon(
                              onPressed: _refreshing
                                  ? null
                                  : () async {
                                      setState(() => _refreshing = true);
                                      await context.read<BookingProvider>().fetchBookingById(widget.bookingId);
                                      if (!mounted) return;
                                      final updated = context.read<BookingProvider>().selectedBooking;
                                      final status = updated?.status ?? 'pending';
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Status: ${status.toUpperCase()}')),
                                      );
                                      setState(() => _refreshing = false);
                                    },
                              icon: _refreshing
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Icon(Icons.refresh),
                              label: Text(_refreshing ? 'Refreshing...' : 'Refresh Status'),
                            )
                          : ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                  Routes.main,
                                  (route) => false,
                                  arguments: 0, // Navigate to home tab (index 0)
                                );
                              },
                              child: const Text('Back to Home'),
                            ),
                    ),

                    if (isAwaitingArrival) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              Routes.main,
                              (route) => false,
                              arguments: 1,
                            );
                          },
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text('Confirm Arrival from My Bookings'),
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),

                    if (!isProcessingState)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _downloadingReceipt
                              ? null
                              : () => _handleDownloadReceipt(bookingProvider),
                          icon: _downloadingReceipt
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.download),
                          label: Text(
                            _downloadingReceipt ? 'Preparing receipt...' : 'Download Receipt',
                          ),
                        ),
                      ),

                    if (!isProcessingState) const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            Routes.main,
                            (route) => false,
                            arguments: 1, // Navigate to bookings tab (index 1)
                          );
                        },
                        child: Text(l10n.translate('my_bookings')),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}





















