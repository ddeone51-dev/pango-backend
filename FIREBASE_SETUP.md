# Firebase Push Notifications Setup Guide

This guide will help you set up Firebase Cloud Messaging (FCM) for push notifications in the Pango app.

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name: "Pango"
4. Enable Google Analytics (optional)
5. Create project

## Step 2: Add Android App

1. In Firebase Console, click "Add app" → Android
2. Register app:
   - **Android package name**: `com.pango.mobile` (or your package name)
   - **App nickname**: Pango Android
   - **Debug signing certificate**: (optional for development)
3. Download `google-services.json`
4. Place file in `mobile/android/app/`

### Android Configuration

Edit `mobile/android/build.gradle`:
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.3.15'
    }
}
```

Edit `mobile/android/app/build.gradle`:
```gradle
plugins {
    id "com.android.application"
    id "com.google.gms.google-services"  // Add this line
}

dependencies {
    implementation platform('com.google.firebase:firebase-bom:32.3.1')
    implementation 'com.google.firebase:firebase-messaging'
}
```

Edit `mobile/android/app/src/main/AndroidManifest.xml`:
```xml
<manifest>
    <application>
        <!-- Add this service -->
        <service
            android:name=".MyFirebaseMessagingService"
            android:exported="false">
            <intent-filter>
                <action android:name="com.google.firebase.MESSAGING_EVENT" />
            </intent-filter>
        </service>
    </application>
</manifest>
```

## Step 3: Add iOS App

1. In Firebase Console, click "Add app" → iOS
2. Register app:
   - **iOS bundle ID**: `com.pango.mobile` (match Xcode bundle ID)
   - **App nickname**: Pango iOS
3. Download `GoogleService-Info.plist`
4. Open `mobile/ios/Runner.xcworkspace` in Xcode
5. Drag `GoogleService-Info.plist` into Runner folder in Xcode

### iOS Configuration

Edit `mobile/ios/Podfile`:
```ruby
platform :ios, '11.0'

target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
  
  # Add Firebase pods
  pod 'Firebase/Messaging'
end
```

Run:
```bash
cd ios
pod install
```

Edit `mobile/ios/Runner/AppDelegate.swift`:
```swift
import UIKit
import Flutter
import Firebase

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

## Step 4: Get Server Key for Backend

1. In Firebase Console, go to Project Settings
2. Go to "Cloud Messaging" tab
3. Find "Server key" or "Cloud Messaging API (Legacy)"
4. If not enabled:
   - Click "Manage API in Google Cloud Console"
   - Enable "Firebase Cloud Messaging API"
5. Copy server key

## Step 5: Backend Configuration

Edit `backend/.env`:
```env
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_PRIVATE_KEY=your_private_key
FIREBASE_CLIENT_EMAIL=your_client_email
```

To get service account:
1. Firebase Console → Project Settings → Service Accounts
2. Click "Generate new private key"
3. Download JSON file
4. Extract values for .env

## Step 6: Initialize in Flutter App

Edit `mobile/lib/main.dart`:
```dart
import 'package:firebase_core/firebase_core.dart';
import 'core/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize Notifications
  final notificationService = NotificationService();
  await notificationService.initialize();
  
  // Initialize Hive and other services
  await Hive.initFlutter();
  await StorageService.init();
  
  runApp(const PangoApp());
}
```

## Step 7: Update pubspec.yaml

Already included in pubspec.yaml:
```yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_messaging: ^14.7.10
  firebase_analytics: ^10.8.0
```

## Step 8: Backend Implementation

Create `backend/src/utils/notifications.js`:
```javascript
const admin = require('firebase-admin');

// Initialize Firebase Admin
const serviceAccount = {
  projectId: process.env.FIREBASE_PROJECT_ID,
  privateKey: process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n'),
  clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
};

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

// Send notification to single device
async function sendNotification(token, notification, data = {}) {
  try {
    const message = {
      notification: {
        title: notification.title,
        body: notification.body,
      },
      data: data,
      token: token,
    };
    
    const response = await admin.messaging().send(message);
    console.log('Successfully sent message:', response);
    return response;
  } catch (error) {
    console.error('Error sending message:', error);
    throw error;
  }
}

// Send to multiple devices
async function sendToMultipleDevices(tokens, notification, data = {}) {
  try {
    const message = {
      notification: {
        title: notification.title,
        body: notification.body,
      },
      data: data,
      tokens: tokens,
    };
    
    const response = await admin.messaging().sendMulticast(message);
    console.log(`Successfully sent ${response.successCount} messages`);
    return response;
  } catch (error) {
    console.error('Error sending messages:', error);
    throw error;
  }
}

// Send to topic
async function sendToTopic(topic, notification, data = {}) {
  try {
    const message = {
      notification: {
        title: notification.title,
        body: notification.body,
      },
      data: data,
      topic: topic,
    };
    
    const response = await admin.messaging().send(message);
    console.log('Successfully sent message to topic:', response);
    return response;
  } catch (error) {
    console.error('Error sending message to topic:', error);
    throw error;
  }
}

module.exports = {
  sendNotification,
  sendToMultipleDevices,
  sendToTopic,
};
```

## Step 9: Notification Usage Examples

### Send booking confirmation:
```javascript
const { sendNotification } = require('../utils/notifications');

// In booking controller
const userToken = booking.guestId.deviceTokens[0];
await sendNotification(
  userToken,
  {
    title: 'Booking Confirmed',
    body: 'Your booking has been confirmed!',
  },
  {
    type: 'booking_confirmed',
    bookingId: booking._id.toString(),
  }
);
```

### Send to all hosts:
```javascript
await sendToTopic(
  'hosts',
  {
    title: 'New Feature Available',
    body: 'Check out our new analytics dashboard!',
  }
);
```

## Step 10: Testing

### Test from Firebase Console:
1. Go to Firebase Console → Cloud Messaging
2. Click "Send your first message"
3. Enter notification title and text
4. Select target (app, topic, or token)
5. Send test message

### Test Programmatically:
```bash
# Register a test user and get FCM token
# Then send notification via backend
curl -X POST http://localhost:3000/api/v1/test-notification \
  -H "Content-Type: application/json" \
  -d '{
    "token": "device_fcm_token_here",
    "title": "Test Notification",
    "body": "This is a test message"
  }'
```

## Troubleshooting

**iOS Notifications not working:**
- Enable push notifications capability in Xcode
- Upload APNs certificate to Firebase
- Test on physical device (not simulator)

**Android Notifications not showing:**
- Check google-services.json is in correct location
- Verify Firebase dependencies are added
- Check notification channel settings

**Token not received:**
- Check internet connection
- Verify Firebase is initialized
- Check console for errors

## Production Checklist

- [ ] Upload production APNs certificate (iOS)
- [ ] Enable FCM API in Google Cloud Console
- [ ] Set up notification channels (Android)
- [ ] Implement notification handling in app
- [ ] Test on real devices
- [ ] Set up notification analytics
- [ ] Implement retry logic for failed sends
- [ ] Add notification preferences in user settings

## Best Practices

1. **Always request permission** before sending notifications
2. **Store FCM tokens** in user document
3. **Update tokens** when they change
4. **Remove invalid tokens** after failed sends
5. **Use topics** for broadcasting to groups
6. **Add deep linking** for notification taps
7. **Test thoroughly** on both iOS and Android
8. **Monitor delivery rates** in Firebase Console

---

For more information, visit [Firebase Documentation](https://firebase.google.com/docs/cloud-messaging)

























