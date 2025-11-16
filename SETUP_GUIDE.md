# Pango - Complete Setup Guide

This guide will walk you through setting up the complete Pango application from scratch.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Backend Setup](#backend-setup)
3. [Database Setup](#database-setup)
4. [Mobile App Setup](#mobile-app-setup)
5. [External Services](#external-services)
6. [Testing](#testing)
7. [Deployment](#deployment)

---

## Prerequisites

### Required Software

1. **Node.js and npm**
   ```bash
   # Install Node.js 18.x or higher
   # Download from: https://nodejs.org/
   
   # Verify installation
   node --version
   npm --version
   ```

2. **MongoDB**
   ```bash
   # Option 1: Install MongoDB locally
   # Download from: https://www.mongodb.com/try/download/community
   
   # Option 2: Use Docker
   docker run -d -p 27017:27017 --name mongodb mongo:latest
   
   # Option 3: Use MongoDB Atlas (cloud)
   # Sign up at: https://www.mongodb.com/cloud/atlas
   ```

3. **Flutter SDK**
   ```bash
   # Download from: https://flutter.dev/docs/get-started/install
   
   # Verify installation
   flutter doctor
   ```

4. **Git**
   ```bash
   git --version
   ```

### Optional Software

- **Redis** (for caching)
- **Docker** (for containerization)
- **Postman** (for API testing)

---

## Backend Setup

### Step 1: Clone Repository

```bash
git clone https://github.com/yourusername/pango.git
cd pango/backend
```

### Step 2: Install Dependencies

```bash
npm install
```

### Step 3: Environment Configuration

```bash
# Copy example environment file
cp .env.example .env
```

Edit `.env` file with your configuration:

```env
# Server Configuration
NODE_ENV=development
PORT=3000
API_VERSION=v1

# Database
MONGODB_URI=mongodb://localhost:27017/pango

# JWT Configuration
JWT_SECRET=your_very_secure_secret_key_change_this
JWT_EXPIRE=7d
JWT_REFRESH_SECRET=your_refresh_token_secret
JWT_REFRESH_EXPIRE=30d

# Email Configuration (SendGrid)
SENDGRID_API_KEY=your_sendgrid_api_key
EMAIL_FROM=noreply@pango.co.tz
EMAIL_FROM_NAME=Pango

# Firebase (Push Notifications)
FIREBASE_PROJECT_ID=your_firebase_project_id
FIREBASE_PRIVATE_KEY=your_firebase_private_key
FIREBASE_CLIENT_EMAIL=your_firebase_client_email

# Google Maps
GOOGLE_MAPS_API_KEY=your_google_maps_api_key

# M-Pesa Configuration
MPESA_CONSUMER_KEY=your_mpesa_consumer_key
MPESA_CONSUMER_SECRET=your_mpesa_consumer_secret
MPESA_PASSKEY=your_mpesa_passkey
MPESA_SHORTCODE=your_shortcode
MPESA_CALLBACK_URL=https://api.pango.co.tz/v1/payments/mpesa/callback

# Stripe (Optional)
STRIPE_SECRET_KEY=your_stripe_secret_key
STRIPE_PUBLISHABLE_KEY=your_stripe_publishable_key

# Redis (Optional)
REDIS_HOST=localhost
REDIS_PORT=6379

# App URLs
FRONTEND_URL=http://localhost:3000
```

### Step 4: Start Backend Server

```bash
# Development mode (with auto-reload)
npm run dev

# Production mode
npm start
```

Server will be running at `http://localhost:3000`

### Step 5: Verify Backend

```bash
# Check health endpoint
curl http://localhost:3000/health

# Expected response:
# {"success":true,"message":"Server is healthy","timestamp":"..."}
```

---

## Database Setup

### Step 1: Start MongoDB

```bash
# If using Docker
docker start mongodb

# If using local installation
sudo systemctl start mongod  # Linux
brew services start mongodb-community  # macOS
```

### Step 2: Create Database

MongoDB will automatically create the database on first connection. The models will create collections automatically.

### Step 3: Seed Initial Data (Optional)

Create a seed script `backend/src/utils/seed.js`:

```javascript
const mongoose = require('mongoose');
const User = require('../models/User');
const Listing = require('../models/Listing');

async function seed() {
  await mongoose.connect(process.env.MONGODB_URI);
  
  // Create admin user
  await User.create({
    email: 'admin@pango.co.tz',
    phoneNumber: '+255712345678',
    password: 'Admin123!',
    role: 'admin',
    profile: {
      firstName: 'Admin',
      lastName: 'User',
    },
  });
  
  console.log('Database seeded successfully');
  process.exit(0);
}

seed();
```

Run: `node src/utils/seed.js`

---

## Mobile App Setup

### Step 1: Navigate to Mobile Directory

```bash
cd ../mobile
```

### Step 2: Install Flutter Dependencies

```bash
flutter pub get
```

### Step 3: Configure API Endpoint

Edit `lib/core/config/constants.dart`:

```dart
class AppConstants {
  // For local development
  static const String baseUrl = 'http://YOUR_IP_ADDRESS:3000/api/v1';
  
  // Android Emulator: use 10.0.2.2
  // iOS Simulator: use localhost
  // Physical Device: use your computer's local IP
}
```

**Find your local IP:**
```bash
# Windows
ipconfig

# macOS/Linux
ifconfig
# or
ip addr show
```

### Step 4: Configure Google Maps

#### Get API Key
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project
3. Enable Maps SDK for Android and iOS
4. Create API credentials
5. Add API key to your app

#### Android Configuration

Edit `android/app/src/main/AndroidManifest.xml`:
```xml
<manifest>
    <application>
        <meta-data
            android:name="com.google.android.geo.API_KEY"
            android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
    </application>
</manifest>
```

#### iOS Configuration

Edit `ios/Runner/AppDelegate.swift`:
```swift
import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

### Step 5: Run the App

```bash
# List available devices
flutter devices

# Run on connected device
flutter run

# Run with release mode
flutter run --release
```

---

## External Services

### 1. Firebase Setup (Push Notifications)

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project
3. Add Android and iOS apps
4. Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
5. Place files in respective directories:
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`
6. Get service account key for backend:
   - Project Settings > Service Accounts
   - Generate new private key
   - Add credentials to backend `.env`

### 2. M-Pesa Integration (Tanzania)

1. Register at [Vodacom M-Pesa Developer Portal](https://developer.mpesa.vm.co.tz/)
2. Create application
3. Get Consumer Key and Consumer Secret
4. Test in sandbox environment first
5. Apply for production access

### 3. SendGrid (Email)

1. Sign up at [SendGrid](https://sendgrid.com/)
2. Create API key
3. Verify sender email
4. Add API key to backend `.env`

### 4. Stripe (Card Payments)

1. Sign up at [Stripe](https://stripe.com/)
2. Get API keys (Test mode first)
3. Add keys to backend `.env`
4. Configure webhooks

---

## Testing

### Backend Testing

```bash
cd backend

# Run all tests
npm test

# Run with coverage
npm run test:coverage

# Test specific file
npm test -- path/to/test.js
```

### Mobile Testing

```bash
cd mobile

# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run integration tests
flutter test integration_test
```

### Manual API Testing

Use Postman or curl:

```bash
# Register user
curl -X POST http://localhost:3000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "phoneNumber": "+255712345678",
    "password": "Test123!",
    "firstName": "Test",
    "lastName": "User"
  }'

# Login
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "Test123!"
  }'

# Get listings
curl http://localhost:3000/api/v1/listings
```

---

## Deployment

### Backend Deployment

#### Using Docker

```dockerfile
# Create Dockerfile in backend/
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
```

```bash
# Build image
docker build -t pango-api .

# Run container
docker run -p 3000:3000 --env-file .env pango-api
```

#### Deploy to Cloud

**AWS EC2:**
1. Launch EC2 instance
2. Install Node.js and MongoDB
3. Clone repository
4. Configure environment
5. Use PM2 for process management
6. Set up reverse proxy (Nginx)

**Heroku:**
```bash
heroku create pango-api
heroku addons:create mongolab
git push heroku main
```

### Mobile Deployment

#### Android

```bash
# Build release APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release

# Upload to Google Play Console
# https://play.google.com/console
```

#### iOS

```bash
# Build release
flutter build ios --release

# Open in Xcode
open ios/Runner.xcworkspace

# Archive and upload to App Store Connect
```

---

## Troubleshooting

### Common Issues

**Issue: MongoDB connection error**
```
Solution:
- Check MongoDB is running: sudo systemctl status mongod
- Verify connection string in .env
- Check network connectivity
```

**Issue: Flutter can't connect to API**
```
Solution:
- Use correct IP address (not localhost on physical device)
- Check firewall settings
- Verify API is running
- Check baseUrl in constants.dart
```

**Issue: Google Maps not showing**
```
Solution:
- Verify API key is correct
- Enable Maps SDK in Google Cloud Console
- Check billing is enabled
- Verify API key restrictions
```

**Issue: Build errors in Flutter**
```bash
# Clean and rebuild
flutter clean
rm -rf pubspec.lock
flutter pub get
flutter run
```

---

## Next Steps

1. ✅ Complete setup
2. ✅ Test all features
3. 📱 Customize branding
4. 🎨 Adjust UI/UX
5. 🔒 Security audit
6. 🚀 Deploy to production
7. 📊 Set up monitoring
8. 📈 Plan marketing

---

## Support

For help:
- 📧 Email: support@pango.co.tz
- 💬 Telegram: @PangoSupport
- 📚 Documentation: See TECHNICAL_SPECIFICATION.md

---

Good luck with your Pango deployment! 🚀

























