# 🚀 Push Notifications - Quick Setup Guide

## ⚡ Quick Start (5 Minutes)

Follow these simple steps to enable push notifications in your Pango app.

---

## 📋 Prerequisites

- Firebase project already created ✅ (You have Firebase configured)
- Firebase Cloud Messaging (FCM) enabled in Firebase Console

---

## 🔧 Setup Steps

### Step 1: Backend Setup (2 minutes)

1. **Download Firebase Admin SDK Key**
   ```
   1. Go to Firebase Console: https://console.firebase.google.com
   2. Select your Pango project
   3. Click ⚙️ Settings → Project Settings
   4. Go to "Service accounts" tab
   5. Click "Generate new private key"
   6. Save file as: backend/firebase-service-account.json
   ```

2. **Initialize Firebase Admin in server.js**
   
   Add this to `backend/src/server.js` (after the imports):
   
   ```javascript
   const admin = require('firebase-admin');
   
   // Initialize Firebase Admin
   try {
     const serviceAccount = require('./firebase-service-account.json');
     admin.initializeApp({
       credential: admin.credential.cert(serviceAccount),
     });
     console.log('✅ Firebase Admin initialized');
   } catch (e) {
     console.warn('⚠️ Firebase Admin not initialized:', e.message);
   }
   ```

3. **Add to .gitignore**
   ```bash
   echo "firebase-service-account.json" >> backend/.gitignore
   ```

That's it for backend! ✅

---

### Step 2: Flutter/Android Setup (3 minutes)

1. **Download google-services.json**
   ```
   1. Go to Firebase Console
   2. Click ⚙️ Settings → Project Settings
   3. Under "Your apps" section
   4. Click Android icon or your Android app
   5. Download "google-services.json"
   6. Move to: mobile/android/app/google-services.json
   ```

2. **Update Android build.gradle** (if not already done)
   
   In `mobile/android/build.gradle`:
   ```gradle
   dependencies {
       classpath 'com.google.gms:google-services:4.3.15'
   }
   ```
   
   In `mobile/android/app/build.gradle` (at the bottom):
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   ```

3. **Run Flutter commands**
   ```bash
   cd mobile
   flutter pub get
   flutter clean
   flutter run
   ```

Done! ✅

---

## 🧪 Testing

### Test 1: Check Token Registration

1. Run the app
2. Check logs for:
   ```
   ✅ Push Notification Service ready
   FCM Token: [your-token-here]
   ```

### Test 2: Send Test Notification

1. Open app
2. Go to: **Profile → Settings → Notifications**
3. Click **"Send Test Notification"**
4. You should receive: "Test Notification from Pango" 🎉

### Test 3: Create a Booking

1. Create a test booking
2. Host should receive: "New Booking Request 📬"
3. Check notification inbox in app

---

## 📱 Where to Access Notifications

### Notification Inbox:
- Navigate to: `NotificationsScreen()`
- Or add button in AppBar:
  ```dart
  IconButton(
    icon: Badge(
      label: Text('${notificationProvider.unreadCount}'),
      child: Icon(Icons.notifications),
    ),
    onPressed: () {
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => NotificationsScreen(),
      ));
    },
  )
  ```

### Settings:
- Navigate to: `NotificationSettingsScreen()`
- Usually in Profile → Settings

---

## ⚙️ Environment Variables

Add to `backend/.env`:

```env
# Firebase (optional, using service account file instead)
FIREBASE_PROJECT_ID=your-project-id
```

---

## 🐛 Common Issues & Fixes

### "Firebase not initialized"
**Solution:** Ensure `firebase-service-account.json` is in `backend/` folder

### "Token not registered"
**Solution:** Check user is logged in before initializing push service

### "Notifications not showing"
**Solution:**
1. Check device notification permissions
2. Ensure FCM token is generated (check logs)
3. Verify google-services.json is in correct location

### "Build failed" (Android)
**Solution:**
1. Run `flutter clean`
2. Delete `build` folder
3. Run `flutter pub get`
4. Run `flutter run`

---

## 📊 Monitoring

### Check Token Registration:
```javascript
// In your database, check User model:
db.users.findOne({ _id: userId }, { deviceTokens: 1 })
```

### Test API Endpoints:
```bash
# Register token
curl -X POST http://localhost:5000/api/notifications/register-token \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"token":"FCM_TOKEN_HERE"}'

# Send test notification
curl -X POST http://localhost:5000/api/notifications/test \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

## 🎯 Integration Checklist

- [ ] Firebase Admin SDK key downloaded
- [ ] Backend server.js updated
- [ ] google-services.json added to Android
- [ ] Flutter dependencies installed (`flutter pub get`)
- [ ] App runs without errors
- [ ] FCM token appears in logs
- [ ] Test notification received
- [ ] Notification inbox accessible
- [ ] Settings screen accessible
- [ ] Booking notifications work

---

## 📚 Additional Resources

- **Firebase Console:** https://console.firebase.google.com
- **FCM Documentation:** https://firebase.google.com/docs/cloud-messaging
- **FlutterFire:** https://firebase.flutter.dev/

---

## 🎉 You're Done!

Once all checkboxes are ticked ✅, your push notification system is fully operational!

Users will now receive:
- 📬 Booking updates
- ⭐ Review notifications
- 💰 Payment confirmations
- 🎁 Special offers
- And more!

**Need help?** Check `PUSH_NOTIFICATIONS_READY.md` for detailed documentation.

---

**Setup Time:** ~5 minutes
**Status:** Production Ready
**Support:** Fully implemented with error handling






