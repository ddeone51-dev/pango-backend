# 🔐 HOW TO ADD YOUR FLUTTERWAVE KEYS (SECURELY)

## ⚠️ IMPORTANT: Keep Your Keys Private!

**NEVER share your API keys with anyone!**

---

## 📝 STEP-BY-STEP GUIDE

### Step 1: Get Your Keys from Flutterwave

1. Login to: https://dashboard.flutterwave.com/
2. Go to: **Settings** → **API Keys**
3. You'll see:
   - ✅ **Public Key** (starts with FLWPUBK_TEST-)
   - ✅ **Secret Key** (starts with FLWSECK_TEST-)
   - ✅ **Encryption Key**

**Copy these - you'll need them!**

---

### Step 2: Add Keys to Backend .env

1. Open: `backend/.env` file (in your code editor)
2. Scroll to the bottom
3. You'll see these placeholders:

```env
FLUTTERWAVE_PUBLIC_KEY=FLWPUBK_TEST-your-public-key-here
FLUTTERWAVE_SECRET_KEY=FLWSECK_TEST-your-secret-key-here
FLUTTERWAVE_ENCRYPTION_KEY=your-encryption-key-here
FLUTTERWAVE_WEBHOOK_SECRET=your-webhook-secret-here
```

4. **Replace each placeholder** with your actual keys:

```env
# Example (use YOUR actual keys!)
FLUTTERWAVE_PUBLIC_KEY=FLWPUBK_TEST-abc123def456...
FLUTTERWAVE_SECRET_KEY=FLWSECK_TEST-xyz789uvw012...
FLUTTERWAVE_ENCRYPTION_KEY=FLWENC-abc123...
FLUTTERWAVE_WEBHOOK_SECRET=my-webhook-secret
```

5. **Save the file**

---

### Step 3: Add Public Key to Mobile App

1. Open: `mobile/lib/core/services/payment_service.dart`
2. Find this line:

```dart
static const String _publicKey = 'FLWPUBK_TEST-YOUR-PUBLIC-KEY-HERE';
```

3. **Replace** with your actual public key:

```dart
static const String _publicKey = 'FLWPUBK_TEST-abc123def456...';
```

4. **Save the file**

**Note:** Only the public key goes in the mobile app! Secret keys stay on backend only!

---

### Step 4: Install Flutterwave Package

1. Open terminal in `mobile` folder
2. Run:

```bash
flutter pub get
```

This installs the Flutterwave package.

---

### Step 5: Restart Backend

The backend needs to load the new environment variables:

```bash
# In backend folder
# Stop current server (Ctrl+C)
npm run dev
```

---

### Step 6: Hot Restart Mobile App

```bash
# In Flutter terminal
Press: R
```

---

## ✅ VERIFICATION

### Check Backend Keys Loaded:

1. Open terminal in `backend` folder
2. Run:

```bash
node -e "require('dotenv').config(); console.log('Public Key:', process.env.FLUTTERWAVE_PUBLIC_KEY ? '✅ Loaded' : '❌ Missing');"
```

You should see: `Public Key: ✅ Loaded`

---

## 🎯 WHAT EACH KEY DOES

### Public Key (FLWPUBK_TEST-...):
- **Used in**: Mobile app
- **Purpose**: Initialize payments
- **Security**: Safe to use client-side
- **Visibility**: Users can see it (okay!)

### Secret Key (FLWSECK_TEST-...):
- **Used in**: Backend only
- **Purpose**: Verify transactions, process refunds
- **Security**: MUST stay on server
- **Visibility**: NEVER expose to clients

### Encryption Key:
- **Used in**: Backend only
- **Purpose**: Encrypt sensitive payment data
- **Security**: Keep secret
- **Visibility**: Server-side only

### Webhook Secret:
- **Used in**: Backend webhook handler
- **Purpose**: Verify webhook authenticity
- **Security**: Keep secret
- **Visibility**: Server-side only

---

## 🔒 SECURITY CHECKLIST

Before you start:

- [ ] Keys are in .env file (not in code)
- [ ] .env is in .gitignore (not committed to git)
- [ ] Only public key is in mobile app
- [ ] Secret keys only in backend
- [ ] Keys not shared with anyone
- [ ] Using TEST keys for now (not LIVE)

---

## 🚀 TESTING PAYMENTS

### After Adding Your Keys:

1. **Backend**: Restart server
2. **Mobile**: Hot restart app (R)
3. **Navigate**: Home → Listing → Book
4. **Select**: Any payment method
5. **Enter**: Phone number (for mobile money)
6. **Confirm**: Booking
7. **Flutterwave**: Opens payment screen
8. **Test**: Use test credentials from Flutterwave docs
9. **Success**: Returns to app with confirmation!

---

## 🧪 TEST MODE

Your TEST keys will use **Sandbox/Test mode**:

### Test Cards (for testing):
```
Card Number: 5531886652142950
CVV: 564
Expiry: 09/32
OTP: 12345
```

### Test Mobile Money:
Follow Flutterwave test docs for test phone numbers

### Test Success:
- No real money charged
- Test all payment flows
- Debug any issues

---

## 🎯 WHEN TO SWITCH TO LIVE

### After Testing:

1. Test all payment methods work
2. Test success scenarios
3. Test failure scenarios
4. Verify bookings created correctly
5. Check payment confirmations

### Then:

1. Apply for live account with Flutterwave
2. Submit business documents
3. Get approved
4. Get LIVE keys (FLWPUBK-... without TEST)
5. Replace TEST keys with LIVE keys in .env
6. Set `isTestMode: false` in payment_service.dart
7. Go live! 🚀

---

## 📞 WHERE TO GET HELP

### Flutterwave Resources:
- **Dashboard**: https://dashboard.flutterwave.com/
- **Docs**: https://developer.flutterwave.com/docs
- **Flutter Guide**: https://developer.flutterwave.com/docs/flutter
- **Test Cards**: https://developer.flutterwave.com/docs/test-cards
- **Support**: support@flutterwave.com

---

## ✅ READY TO ADD YOUR KEYS?

### Here's What to Do:

1. ✅ Open `backend/.env`
2. ✅ Add your Flutterwave keys (replace placeholders)
3. ✅ Open `mobile/lib/core/services/payment_service.dart`
4. ✅ Add your public key (replace placeholder)
5. ✅ Run `flutter pub get` in mobile folder
6. ✅ Restart backend
7. ✅ Hot restart mobile app
8. ✅ Test a payment!

---

## 🎊 YOU'RE READY!

**The integration is complete!**

Just add your keys securely and you can start processing payments! 💳✨

**Remember: Keep your keys secret and safe!** 🔒











