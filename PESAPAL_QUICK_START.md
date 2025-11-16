# 🚀 Pesapal Quick Start Guide
## Get Your Pango App Accepting Payments in 30 Minutes!

---

## ✅ What's Already Done

### Backend ✅
- Payment model created
- Pesapal API integration complete
- Payment routes configured
- IPN notifications handling
- Payment status tracking

### Flutter App ✅
- Payment service created
- WebView payment screen ready
- Payment method selection UI
- Integration example provided
- Package dependencies installed

---

## 🎯 What You Need To Do

### Step 1: Get Pesapal Sandbox Credentials (5 minutes)

1. **Create Account**
   - Go to https://www.pesapal.com/
   - Click "Sign Up" → Business Account
   - Fill registration form
   - Verify email

2. **Get Sandbox Keys**
   - Log in to Pesapal dashboard
   - Go to **Settings** → **API Keys**
   - Find **Sandbox** section
   - Copy:
     - Consumer Key (starts with `qkio1...`)
     - Consumer Secret (long string)

---

### Step 2: Configure Render Backend (3 minutes)

1. **Go to Render Dashboard**
   - Visit https://dashboard.render.com/
   - Click on `pango-backend` service

2. **Add Environment Variables**
   - Click **Environment** tab
   - Click **Add Environment Variable**
   - Add these 4 variables:

   ```
   PESAPAL_CONSUMER_KEY=your_sandbox_consumer_key
   PESAPAL_CONSUMER_SECRET=your_sandbox_consumer_secret
   PESAPAL_IPN_URL=https://pango-backend.onrender.com/api/v1/payments/pesapal/ipn
   PESAPAL_CALLBACK_URL=https://pango-backend.onrender.com/api/v1/payments/pesapal/callback
   ```

3. **Save & Redeploy**
   - Click **Save Changes**
   - Render will automatically redeploy (wait 2-3 minutes)
   - Check logs to confirm successful deployment

---

### Step 3: Test Backend API (5 minutes)

1. **Wake Up Your Backend**
   - Visit: https://pango-backend.onrender.com/health
   - Should see: `{"status":"ok"}`

2. **Create a Test Booking**
   - Log in to your mobile app
   - Browse listings
   - Create a test booking

3. **Note Down IDs**
   You'll need:
   - `listingId` - ID of the property
   - `bookingId` - ID of your booking
   - `JWT token` - Your auth token (check app storage)

---

### Step 4: Test Payment Flow (10 minutes)

#### Option A: Test from Mobile App (Recommended)

1. **Update Your Booking Screen**
   - Open the file where you handle bookings
   - Add the payment button/flow
   - Use the example from `payment_integration_example.dart`

2. **Key Code Snippet**
   ```dart
   import 'package:your_app/features/payment/payment_method_screen.dart';
   import 'package:your_app/features/payment/payment_webview_screen.dart';
   
   // When user clicks "Pay Now"
   Future<void> _handlePayment() async {
     // Show payment method selector
     await showModalBottomSheet(
       context: context,
       builder: (context) => PaymentMethodScreen(
         amount: bookingAmount,
         currency: 'TZS',
         onMethodSelected: (method) async {
           // Initiate payment
           final paymentData = await paymentService.initiatePayment(
             listingId: listing.id,
             bookingId: booking.id,
             paymentMethod: method,
             customerPhone: userPhone,
             customerEmail: userEmail,
           );
           
           // Open payment page
           final result = await Navigator.push(
             context,
             MaterialPageRoute(
               builder: (context) => PaymentWebViewScreen(
                 redirectUrl: paymentData['redirectUrl'],
                 paymentId: paymentData['paymentId'],
                 merchantReference: paymentData['merchantReference'],
               ),
             ),
           );
           
           // Handle result
           if (result?['success'] == true) {
             showSuccessDialog();
           }
         },
       ),
     );
   }
   ```

3. **Run the App**
   ```bash
   cd mobile
   flutter run
   ```

4. **Test Payment**
   - Click "Pay Now" on a booking
   - Select M-Pesa (or any method)
   - You'll see Pesapal's payment page
   - Use Pesapal's test credentials to complete payment
   - Verify payment success!

#### Option B: Test with API Call (Quick Test)

```bash
# Replace YOUR_JWT_TOKEN, your_listing_id, your_booking_id
curl -X POST https://pango-backend.onrender.com/api/v1/payments/initiate \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "listingId": "your_listing_id",
    "bookingId": "your_booking_id",
    "paymentMethod": "M-PESA",
    "customerPhone": "+255123456789",
    "customerEmail": "test@example.com",
    "customerFirstName": "Test",
    "customerLastName": "User"
  }'
```

Expected response:
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

---

### Step 5: Check Payment Status (2 minutes)

1. **Monitor Render Logs**
   - Go to Render dashboard
   - Click on `pango-backend`
   - Go to **Logs** tab
   - You should see:
     ```
     ✅ Pesapal auth successful
     Registering IPN URL...
     ✅ IPN registered: abc123
     Submitting order to Pesapal: PANG1234567890
     ✅ Order submitted successfully
     ```

2. **Check Payment Status**
   ```bash
   curl -X GET https://pango-backend.onrender.com/api/v1/payments/PAYMENT_ID/status \
     -H "Authorization: Bearer YOUR_JWT_TOKEN"
   ```

---

## 🧪 Pesapal Test Credentials

### Sandbox Test Cards (Use these in Pesapal payment page)

**Test Credit Card:**
- Card Number: `5105105105105100`
- CVV: `123`
- Expiry: Any future date

**Test M-Pesa:**
- Use any phone number
- Use test PIN provided by Pesapal

### Expected Flow

1. User clicks "Pay Now"
2. Selects payment method (M-Pesa, Card, etc.)
3. Payment initiated → redirects to Pesapal
4. Completes payment on Pesapal page
5. Redirects back to your app
6. Payment status updates automatically
7. Booking confirmed!

---

## ✅ Verification Checklist

- [ ] Pesapal sandbox credentials obtained
- [ ] Environment variables added to Render
- [ ] Backend redeployed successfully
- [ ] Payment API tested (POST /payments/initiate)
- [ ] Payment WebView loads correctly
- [ ] Payment completes successfully
- [ ] IPN notifications received in logs
- [ ] Payment status updates to COMPLETED
- [ ] Booking status changes to CONFIRMED

---

## 🐛 Troubleshooting

### "Authentication failed"
- ✅ Check consumer key and secret are correct
- ✅ Verify no extra spaces in environment variables
- ✅ Make sure you're using sandbox credentials

### "No redirect URL received"
- ✅ Check Render logs for detailed error
- ✅ Verify IPN URL is correct
- ✅ Ensure base URL includes `/api` suffix

### "Payment status not updating"
- ✅ Check IPN endpoint logs in Render
- ✅ Verify IPN URL is publicly accessible (https)
- ✅ Check payment was actually completed in Pesapal

### "WebView won't load"
- ✅ Ensure internet permission in Android manifest
- ✅ Check redirect URL is valid HTTPS
- ✅ Try on real device instead of emulator

---

## 🎉 Next Steps

Once sandbox testing works:

1. **Apply for Production Credentials**
   - Complete KYC verification in Pesapal dashboard
   - Submit business documents
   - Wait for approval (usually 1-3 days)

2. **Switch to Production**
   - Update Render environment variables:
     ```
     PESAPAL_CONSUMER_KEY=production_key
     PESAPAL_CONSUMER_SECRET=production_secret
     ```
   - Test with small real transactions
   - Monitor carefully

3. **Launch! 🚀**
   - Announce payment feature
   - Monitor payment success rates
   - Celebrate your first real payment! 🎉

---

## 📚 Files Reference

### Backend
- Model: `backend/src/models/Payment.js`
- Service: `backend/src/services/pesapalService.js`
- Controller: `backend/src/controllers/paymentController.js`
- Routes: `backend/src/routes/paymentRoutes.js`

### Flutter
- Service: `mobile/lib/core/services/payment_service.dart`
- WebView: `mobile/lib/features/payment/payment_webview_screen.dart`
- Method Selection: `mobile/lib/features/payment/payment_method_screen.dart`
- Example: `mobile/lib/features/payment/payment_integration_example.dart`

### Documentation
- Complete Guide: `PESAPAL_PANGO_SETUP.md`
- Original Guide: `PESAPAL_INTEGRATION_GUIDE.md`
- This Quick Start: `PESAPAL_QUICK_START.md`

---

**🎯 You're ready to accept payments! Follow the steps above and you'll be processing transactions in less than 30 minutes.**

**Questions? Check the main setup guide: `PESAPAL_PANGO_SETUP.md`**

