import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/services/payment_service.dart';
import '../../core/services/api_service.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final String redirectUrl;
  final String paymentId;
  final String merchantReference;

  const PaymentWebViewScreen({
    Key? key,
    required this.redirectUrl,
    required this.paymentId,
    required this.merchantReference,
  }) : super(key: key);

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  late final PaymentService _paymentService;
  bool _isLoading = true;
  bool _isCheckingStatus = false;

  @override
  void initState() {
    super.initState();
    _paymentService = PaymentService(ApiService().dio);
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() => _isLoading = true);
            
            debugPrint('Page started loading: $url');
            
            // Check if redirected to callback URL
            if (url.contains('/payments/pesapal/callback') || 
                url.contains('payment/result') ||
                url.contains('payment/success')) {
              _handlePaymentCallback();
            }
          },
          onPageFinished: (url) {
            setState(() => _isLoading = false);
            debugPrint('Page finished loading: $url');
          },
          onWebResourceError: (error) {
            debugPrint('Web resource error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.redirectUrl));
  }

  Future<void> _handlePaymentCallback() async {
    if (_isCheckingStatus) return;
    
    setState(() => _isCheckingStatus = true);

    try {
      // Wait a moment for backend to process IPN
      await Future.delayed(const Duration(seconds: 2));

      // Check payment status
      final paymentStatus = await _paymentService.getPaymentStatus(widget.paymentId);
      
      if (!mounted) return;

      if (paymentStatus['status'] == 'COMPLETED') {
        // Payment successful
        Navigator.of(context).pop({
          'success': true,
          'paymentId': widget.paymentId,
          'status': 'COMPLETED',
        });
      } else if (paymentStatus['status'] == 'FAILED') {
        // Payment failed
        Navigator.of(context).pop({
          'success': false,
          'paymentId': widget.paymentId,
          'status': 'FAILED',
        });
      } else {
        // Still pending, wait a bit more
        await Future.delayed(const Duration(seconds: 3));
        
        if (!mounted) return;
        
        // Check one more time
        final finalStatus = await _paymentService.getPaymentStatus(widget.paymentId);
        
        if (!mounted) return;
        
        Navigator.of(context).pop({
          'success': finalStatus['status'] == 'COMPLETED',
          'paymentId': widget.paymentId,
          'status': finalStatus['status'],
        });
      }
    } catch (e) {
      debugPrint('Error checking payment status: $e');
      
      if (!mounted) return;
      
      // If error, assume pending and let user check later
      Navigator.of(context).pop({
        'success': false,
        'paymentId': widget.paymentId,
        'status': 'PENDING',
        'error': e.toString(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Payment'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            _showCancelDialog();
          },
        ),
        actions: [
          if (_isCheckingStatus)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: Colors.white,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Loading payment page...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_isCheckingStatus)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Card(
                  margin: EdgeInsets.all(24),
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Verifying payment...',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Please wait',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Payment?'),
        content: const Text(
          'Are you sure you want to cancel this payment? '
          'You can complete it later from your bookings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Continue Payment'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop({
                'success': false,
                'paymentId': widget.paymentId,
                'status': 'CANCELLED',
              });
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}


