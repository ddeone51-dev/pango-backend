# 🎯 Pesapal Payment Integration for Pango
## Complete Setup Guide

> **Status**: Backend implementation complete ✅  
> **Next Steps**: Get credentials → Configure environment → Test → Flutter integration

---

## 📋 Table of Contents
1. [What's Done](#whats-done)
2. [Get Pesapal Credentials](#get-pesapal-credentials)
3. [Configure Backend](#configure-backend)
4. [Deploy to Render](#deploy-to-render)
5. [Test the Integration](#test-the-integration)
6. [Flutter Integration](#flutter-integration)
7. [Go Live](#go-live)

---

## ✅ What's Done

### Backend Implementation Complete
- ✅ **Payment Model** (`backend/src/models/Payment.js`)
  - Tracks all payment transactions
  - Stores Pesapal order tracking IDs
  - Handles multiple payment methods (M-Pesa, Tigo Pesa, Airtel Money, Cards)
  
- ✅ **Pesapal Service** (`backend/src/services/pesapalService.js`)
  - Authentication with Pesapal API
  - IPN (Instant Payment Notification) registration
  - Order submission with best practices
  - Payment status checking
  - Following proven patterns from your guide
  
- ✅ **Payment Controller** (`backend/src/controllers/paymentController.js`)
  - `/api/v1/payments/initiate` - Start payment
  - `/api/v1/payments/pesapal/callback` - Handle payment redirect
  - `/api/v1/payments/pesapal/ipn` - Receive payment notifications
  - `/api/v1/payments/:paymentId/status` - Check payment status
  - `/api/v1/payments/history` - View payment history
  
- ✅ **API Routes** (`backend/src/routes/paymentRoutes.js`)
  - All routes configured and protected where needed

---

## 🔑 Get Pesapal Credentials

### Step 1: Create Pesapal Account
1. Go to [Pesapal Website](https://www.pesapal.com/)
2. Click "Sign Up" for a business account
3. Complete the registration form
4. Verify your email

### Step 2: Get Sandbox Credentials (For Testing)
1. Log in to your Pesapal dashboard
2. Navigate to **Settings** → **API Keys**
3. Find your **Sandbox** credentials:
   - Consumer Key
   - Consumer Secret
4. Copy these for testing

### Step 3: Get Production Credentials (For Live)
1. Complete KYC (Know Your Customer) verification
2. Submit required business documents
3. Wait for approval
4. Get your **Production** credentials from the dashboard

---

## ⚙️ Configure Backend

### Step 1: Add Environment Variables

You need to add these to your Render dashboard:

```bash
# Pesapal Configuration
PESAPAL_CONSUMER_KEY=your_sandbox_consumer_key_here
PESAPAL_CONSUMER_SECRET=your_sandbox_consumer_secret_here

# URLs for callbacks
PESAPAL_IPN_URL=https://pango-backend.onrender.com/api/v1/payments/pesapal/ipn
PESAPAL_CALLBACK_URL=https://pango-backend.onrender.com/api/v1/payments/pesapal/callback

# Frontend URL (for redirecting users after payment)
FRONTEND_URL=https://your-app-url.com
```

### Step 2: Add to Render

1. Go to [Render Dashboard](https://dashboard.render.com/)
2. Select your `pango-backend` service
3. Go to **Environment** tab
4. Click **Add Environment Variable**
5. Add each variable above
6. Click **Save Changes**

The service will automatically redeploy with new environment variables.

---

## 🚀 Deploy to Render

### Your backend is already deployed! Just update environment variables:

1. **Current URL**: `https://pango-backend.onrender.com`
2. **Add Pesapal variables** (see above)
3. **Redeploy** (happens automatically)

### Verify Deployment

Visit these URLs to check:
- Health: https://pango-backend.onrender.com/health
- API: https://pango-backend.onrender.com/api/v1

---

## 🧪 Test the Integration

### Step 1: Test Payment Initiation

Use this curl command to test (replace with your JWT token):

```bash
curl -X POST https://pango-backend.onrender.com/api/v1/payments/initiate \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "listingId": "your_listing_id",
    "bookingId": "your_booking_id",
    "paymentMethod": "M-PESA",
    "customerPhone": "+255123456789",
    "customerEmail": "customer@example.com",
    "customerFirstName": "Test",
    "customerLastName": "User"
  }'
```

### Step 2: Expected Response

```json
{
  "success": true,
  "message": "Payment initiated successfully",
  "data": {
    "paymentId": "...",
    "orderTrackingId": "...",
    "merchantReference": "PANG1234567890",
    "redirectUrl": "https://cybqa.pesapal.com/pesapalv3/...",
    "amount": "TZS 100,000.00"
  }
}
```

### Step 3: Test Payment Flow

1. Open the `redirectUrl` in a browser
2. Complete payment with Pesapal test credentials
3. You'll be redirected back to your callback URL
4. Check payment status

### Step 4: Check IPN Endpoint

Monitor your Render logs to see IPN notifications:
```bash
# In Render dashboard, go to Logs tab
# You should see:
=== PESAPAL IPN RECEIVED ===
Timestamp: ...
Body: { OrderTrackingId: ..., OrderMerchantReference: ... }
✅ Payment completed: PANG1234567890
```

---

## 📱 Flutter Integration

Now let's add Pesapal to your Flutter app!

### Step 1: Add Required Packages

```yaml
# mobile/pubspec.yaml
dependencies:
  webview_flutter: ^4.4.2
  url_launcher: ^6.2.1
```

### Step 2: Create Payment Service

Create `mobile/lib/core/services/payment_service.dart`:

```dart
import 'package:dio/dio.dart';
import '../config/environment.dart';

class PaymentService {
  final Dio _dio;

  PaymentService(this._dio);

  /// Initiate Pesapal payment
  Future<Map<String, dynamic>> initiatePayment({
    required String listingId,
    required String bookingId,
    required String paymentMethod,
    required String customerPhone,
    required String customerEmail,
    required String customerFirstName,
    required String customerLastName,
  }) async {
    try {
      final response = await _dio.post(
        '${Environment.baseUrl}/payments/initiate',
        data: {
          'listingId': listingId,
          'bookingId': bookingId,
          'paymentMethod': paymentMethod,
          'customerPhone': customerPhone,
          'customerEmail': customerEmail,
          'customerFirstName': customerFirstName,
          'customerLastName': customerLastName,
        },
      );

      return response.data['data'];
    } catch (e) {
      throw Exception('Failed to initiate payment: $e');
    }
  }

  /// Get payment status
  Future<Map<String, dynamic>> getPaymentStatus(String paymentId) async {
    try {
      final response = await _dio.get(
        '${Environment.baseUrl}/payments/$paymentId/status',
      );

      return response.data['data'];
    } catch (e) {
      throw Exception('Failed to get payment status: $e');
    }
  }

  /// Get payment history
  Future<List<dynamic>> getPaymentHistory({int page = 1, int limit = 10}) async {
    try {
      final response = await _dio.get(
        '${Environment.baseUrl}/payments/history',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      return response.data['data']['payments'];
    } catch (e) {
      throw Exception('Failed to get payment history: $e');
    }
  }
}
```

### Step 3: Create Payment Screen

Create `mobile/lib/features/payment/payment_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentScreen extends StatefulWidget {
  final String redirectUrl;
  final String paymentId;

  const PaymentScreen({
    Key? key,
    required this.redirectUrl,
    required this.paymentId,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() => _isLoading = true);
            
            // Check if payment completed
            if (url.contains('/payment/result')) {
              // Payment completed, go back
              Navigator.of(context).pop(true);
            }
          },
          onPageFinished: (url) {
            setState(() => _isLoading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.redirectUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Payment'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
```

### Step 4: Integrate in Booking Flow

Update your booking confirmation screen:

```dart
// When user clicks "Pay Now" button
Future<void> _handlePayment() async {
  setState(() => _isLoading = true);

  try {
    // Initiate payment
    final paymentData = await paymentService.initiatePayment(
      listingId: widget.listing.id,
      bookingId: _bookingId,
      paymentMethod: _selectedPaymentMethod, // 'M-PESA', 'TIGO_PESA', etc.
      customerPhone: _phoneController.text,
      customerEmail: _emailController.text,
      customerFirstName: _firstNameController.text,
      customerLastName: _lastNameController.text,
    );

    // Open payment webview
    final paymentCompleted = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          redirectUrl: paymentData['redirectUrl'],
          paymentId: paymentData['paymentId'],
        ),
      ),
    );

    if (paymentCompleted == true) {
      // Payment successful
      _showSuccessDialog();
    }
  } catch (e) {
    _showErrorDialog(e.toString());
  } finally {
    setState(() => _isLoading = false);
  }
}
```

---

## 🎉 Go Live

### When You're Ready for Production:

1. **Get Production Credentials**
   - Complete KYC verification
   - Get approved by Pesapal
   - Get production consumer key & secret

2. **Update Render Environment**
   ```bash
   PESAPAL_CONSUMER_KEY=production_key_here
   PESAPAL_CONSUMER_SECRET=production_secret_here
   ```

3. **Test Thoroughly**
   - Test all payment methods
   - Test with real small amounts
   - Verify IPN notifications
   - Check booking confirmations

4. **Monitor**
   - Check Render logs regularly
   - Monitor payment success rates
   - Track failed payments

---

## 🔧 Troubleshooting

### Payment Initiation Fails
- ✅ Check Pesapal credentials are correct
- ✅ Verify BASE_URL includes `/api` suffix
- ✅ Check Render logs for error details

### IPN Not Received
- ✅ Verify IPN URL is publicly accessible
- ✅ Check Render logs for incoming requests
- ✅ Ensure URL starts with `https://`

### Payment Status Not Updating
- ✅ Check IPN endpoint logs
- ✅ Verify database connection
- ✅ Test manually with getPaymentStatus

---

## 📞 Support

- **Pesapal Docs**: https://developer.pesapal.com/
- **Pesapal Support**: support@pesapal.com
- **Your Guide**: PESAPAL_INTEGRATION_GUIDE.md (in root folder)

---

## ✨ Next Steps

1. ✅ **Get your Pesapal sandbox credentials**
2. ✅ **Add environment variables to Render**
3. ✅ **Test payment flow**
4. ✅ **Implement Flutter UI**
5. ✅ **Test end-to-end**
6. ✅ **Apply for production credentials**
7. ✅ **Go live!**

---

**🚀 Your Pango app is almost ready to accept real payments!**

