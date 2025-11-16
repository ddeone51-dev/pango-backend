/// THIS FILE SHOWS HOW TO INTEGRATE PESAPAL PAYMENT INTO YOUR BOOKING FLOW
/// 
/// Copy the relevant functions into your booking confirmation screen or
/// wherever you want to handle payments.

import 'package:flutter/material.dart';
import '../../core/services/payment_service.dart';
import '../../core/services/api_service.dart';
import 'payment_method_screen.dart';
import 'payment_webview_screen.dart';

class PaymentIntegrationExample extends StatefulWidget {
  final String listingId;
  final String bookingId;
  final double amount;
  final String customerEmail;
  final String customerPhone;

  const PaymentIntegrationExample({
    Key? key,
    required this.listingId,
    required this.bookingId,
    required this.amount,
    required this.customerEmail,
    required this.customerPhone,
  }) : super(key: key);

  @override
  State<PaymentIntegrationExample> createState() => _PaymentIntegrationExampleState();
}

class _PaymentIntegrationExampleState extends State<PaymentIntegrationExample> {
  late final PaymentService _paymentService;
  bool _isProcessing = false;
  String? _selectedPaymentMethod;

  @override
  void initState() {
    super.initState();
    _paymentService = PaymentService(ApiService().dio);
  }

  /// Step 1: Show payment method selection
  Future<void> _selectPaymentMethod() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: PaymentMethodScreen(
          amount: widget.amount,
          currency: 'TZS',
          onMethodSelected: (method) {
            setState(() {
              _selectedPaymentMethod = method;
            });
            // Automatically proceed to payment after selection
            _processPayment();
          },
        ),
      ),
    );
  }

  /// Step 2: Initiate payment with Pesapal
  Future<void> _processPayment() async {
    if (_selectedPaymentMethod == null) {
      _showErrorDialog('Please select a payment method');
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // Initiate payment with backend
      final paymentData = await _paymentService.initiatePayment(
        listingId: widget.listingId,
        bookingId: widget.bookingId,
        paymentMethod: _selectedPaymentMethod!,
        customerPhone: widget.customerPhone,
        customerEmail: widget.customerEmail,
        customerFirstName: 'Customer', // Get from user profile or form
        customerLastName: 'User', // Get from user profile or form
      );

      setState(() => _isProcessing = false);

      // Open Pesapal payment page in WebView
      final result = await Navigator.of(context).push<Map<String, dynamic>>(
        MaterialPageRoute(
          builder: (context) => PaymentWebViewScreen(
            redirectUrl: paymentData['redirectUrl'],
            paymentId: paymentData['paymentId'],
            merchantReference: paymentData['merchantReference'],
          ),
        ),
      );

      // Handle payment result
      _handlePaymentResult(result);

    } catch (e) {
      setState(() => _isProcessing = false);
      _showErrorDialog(e.toString());
    }
  }

  /// Step 3: Handle payment result
  void _handlePaymentResult(Map<String, dynamic>? result) {
    if (result == null) {
      // User closed the payment page
      _showInfoDialog(
        'Payment Pending',
        'You can complete the payment later from your bookings.',
      );
      return;
    }

    final status = result['status'] as String?;
    final success = result['success'] as bool? ?? false;

    if (success && status == 'COMPLETED') {
      // Payment successful!
      _showSuccessDialog();
    } else if (status == 'FAILED') {
      // Payment failed
      _showErrorDialog('Payment failed. Please try again.');
    } else if (status == 'CANCELLED') {
      // Payment cancelled by user
      _showInfoDialog(
        'Payment Cancelled',
        'You can complete the payment later from your bookings.',
      );
    } else {
      // Payment still pending
      _showInfoDialog(
        'Payment Processing',
        'Your payment is being processed. You will receive a confirmation shortly.',
      );
    }
  }

  /// Show success dialog
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green[600], size: 32),
            const SizedBox(width: 12),
            const Text('Payment Successful!'),
          ],
        ),
        content: const Text(
          'Your booking has been confirmed. '
          'You will receive a confirmation email shortly.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              // Navigate to booking details or home
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('View Booking'),
          ),
        ],
      ),
    );
  }

  /// Show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 32),
            SizedBox(width: 12),
            Text('Payment Error'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  /// Show info dialog
  void _showInfoDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Total Amount',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'TZS ${widget.amount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 48),
            
            if (_isProcessing)
              const Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Processing payment...'),
                ],
              )
            else
              ElevatedButton.icon(
                onPressed: _selectPaymentMethod,
                icon: const Icon(Icons.payment),
                label: const Text('Pay Now'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// QUICK INTEGRATION GUIDE:
/// 
/// 1. Add this to your booking confirmation screen:
/// 
/// ```dart
/// final _paymentService = PaymentService(ApiService().dio);
/// 
/// Future<void> _handlePayment() async {
///   // Show payment method selection
///   final method = await showPaymentMethodSelector();
///   
///   // Initiate payment
///   final paymentData = await _paymentService.initiatePayment(...);
///   
///   // Open payment page
///   final result = await Navigator.push(
///     context,
///     MaterialPageRoute(
///       builder: (context) => PaymentWebViewScreen(
///         redirectUrl: paymentData['redirectUrl'],
///         paymentId: paymentData['paymentId'],
///         merchantReference: paymentData['merchantReference'],
///       ),
///     ),
///   );
///   
///   // Handle result
///   if (result['success']) {
///     // Payment successful!
///   }
/// }
/// ```
/// 
/// 2. That's it! The payment flow is handled automatically.


