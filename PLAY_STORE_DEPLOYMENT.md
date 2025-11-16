# 🚀 Google Play Store Deployment Guide for Pango
## Complete Step-by-Step Instructions

---

## 📋 Table of Contents
1. [Prerequisites](#prerequisites)
2. [Step 1: App Signing Setup](#step-1-app-signing-setup)
3. [Step 2: Update App Information](#step-2-update-app-information)
4. [Step 3: Create App Icons](#step-3-create-app-icons)
5. [Step 4: Build Release Version](#step-4-build-release-version)
6. [Step 5: Create Play Store Listing](#step-5-create-play-store-listing)
7. [Step 6: Upload to Play Console](#step-6-upload-to-play-console)
8. [Step 7: Testing & Review](#step-7-testing--review)
9. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### What You Need
- [ ] Google Play Console account ($25 one-time fee)
- [ ] Android Studio or Flutter SDK installed
- [ ] Java JDK installed (for keytool)
- [ ] Your app ready to test
- [ ] Privacy policy URL
- [ ] App screenshots (at least 2)
- [ ] Feature graphic (1024 x 500px)
- [ ] App icon (512 x 512px)

### Current App Info
- **Package Name**: `com.techlandtz.pango`
- **Current Version**: `1.0.0+1`
- **Min SDK**: 21 (Android 5.0)
- **Target SDK**: Latest Flutter default

---

## Step 1: App Signing Setup

### 1.1 Create Upload Keystore

Open terminal in your project root and run:

```bash
keytool -genkey -v -keystore C:\pango\upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

**You'll be asked for:**
- Keystore password (choose a strong password, **save it!**)
- Key password (can be same as keystore password)
- Your name
- Organization
- City
- State
- Country code (TZ for Tanzania)

**IMPORTANT**: Save this information securely! You'll need it forever.

### 1.2 Create key.properties File

Create `mobile/android/key.properties`:

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=C:/pango/upload-keystore.jks
```

**⚠️ IMPORTANT**: Add this file to `.gitignore`! Never commit passwords.

### 1.3 Update build.gradle.kts

The signing configuration will be updated in the next step.

---

## Step 2: Update App Information

### 2.1 Update Version (pubspec.yaml)

Current: `version: 1.0.0+1`

For first release, this is perfect!
- `1.0.0` = Version name (users see this)
- `+1` = Version code (internal, must increment each release)

### 2.2 Update App Name

#### For Android (AndroidManifest.xml)
Change from `pango` to `Pango` (with capital P):

```xml
<application
    android:label="Pango"
    ...>
```

### 2.3 Review Permissions

Current permissions are good:
- ✅ INTERNET - For API calls
- ✅ ACCESS_FINE_LOCATION - For maps
- ✅ ACCESS_COARSE_LOCATION - For maps

---

## Step 3: Create App Icons

### 3.1 What You Need

**App Icon**:
- Size: 512 x 512px
- Format: PNG
- No transparency
- Follows Material Design guidelines

**Feature Graphic** (for Play Store):
- Size: 1024 x 500px
- Format: PNG or JPG
- Showcases your app

### 3.2 Generate Icons

Use one of these tools:
1. **Android Studio**: Right-click `android/app/src/main/res` → New → Image Asset
2. **Online Tool**: https://www.appicon.co/
3. **Flutter Launcher Icons Package**

#### Using Flutter Launcher Icons (Recommended)

1. Add to `pubspec.yaml`:
```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_launcher_icons:
  android: true
  ios: false
  image_path: "assets/icons/app_icon.png"
  adaptive_icon_background: "#FFFFFF"
  adaptive_icon_foreground: "assets/icons/app_icon.png"
```

2. Place your 512x512 icon at `assets/icons/app_icon.png`

3. Run:
```bash
flutter pub get
flutter pub run flutter_launcher_icons
```

---

## Step 4: Build Release Version

### 4.1 Update build.gradle.kts for Signing

File: `mobile/android/app/build.gradle.kts`

Add before `android {` block:

```kotlin
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}
```

Update `buildTypes` section:

```kotlin
signingConfigs {
    create("release") {
        keyAlias = keystoreProperties['keyAlias']
        keyPassword = keystoreProperties['keyPassword']
        storeFile = keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
        storePassword = keystoreProperties['storePassword']
    }
}

buildTypes {
    release {
        signingConfig = signingConfigs.getByName("release")
        // Enable code shrinking, obfuscation, and optimization
        minifyEnabled = true
        shrinkResources = true
        proguardFiles(
            getDefaultProguardFile("proguard-android-optimize.txt"),
            "proguard-rules.pro"
        )
    }
}
```

### 4.2 Create ProGuard Rules

Create `mobile/android/app/proguard-rules.pro`:

```proguard
# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Google Maps
-keep class com.google.android.gms.maps.** { *; }
-keep interface com.google.android.gms.maps.** { *; }

# Dio (HTTP client)
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
```

### 4.3 Build App Bundle (AAB) - Recommended

```bash
cd mobile
flutter clean
flutter pub get
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### 4.4 Build APK (Alternative)

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

**Note**: Play Store prefers AAB format!

---

## Step 5: Create Play Store Listing

### 5.1 Create Google Play Console Account

1. Go to https://play.google.com/console
2. Sign in with Google account
3. Pay $25 one-time registration fee
4. Complete account setup

### 5.2 Create New App

1. Click "Create app"
2. Fill in details:
   - **App name**: Pango
   - **Default language**: English (United States)
   - **App or game**: App
   - **Free or paid**: Free

### 5.3 Prepare Store Listing Content

#### Short Description (80 characters max)
```
Find and book amazing accommodations across Tanzania. Easy, fast, secure.
```

#### Full Description (4000 characters max)
```
🏠 Pango - Your Gateway to Tanzanian Accommodations

Find your perfect home away from home in Tanzania! Whether you're planning a business trip to Dar es Salaam, a safari adventure in Arusha, or a beach getaway in Zanzibar, Pango connects you with verified hosts offering quality accommodations.

✨ KEY FEATURES

🔍 Easy Search & Discovery
• Browse thousands of listings across Tanzania
• Interactive map view with location search
• Filter by price, amenities, and location
• Save your favorite properties

💳 Secure Booking & Payment
• Multiple payment options (M-Pesa, Tigo Pesa, Airtel Money, Cards)
• Secure payment processing via Pesapal
• Instant booking confirmation
• Transparent pricing with no hidden fees

🏡 Quality Accommodations
• Verified hosts and listings
• Real photos and detailed descriptions
• Guest reviews and ratings
• Direct communication with hosts

🗺️ Smart Features
• Google Maps integration
• Nearby listings discovery
• Real-time availability
• Booking history and management

👤 User-Friendly Experience
• Modern, intuitive interface
• Available in English and Swahili
• Fast and responsive
• Offline favorites

🏆 Why Choose Pango?

• 🇹🇿 Made for Tanzania - We understand local needs
• 🔒 Safe & Secure - Your data and payments are protected
• 💬 Great Support - We're here to help 24/7
• 🌟 Quality Guaranteed - All listings are verified

Whether you're a traveler looking for accommodation or a host wanting to earn income, Pango makes it simple, safe, and rewarding.

Download Pango today and discover your next stay in Tanzania! 🚀
```

#### App Category
```
Travel & Local
```

#### Tags
```
accommodation, booking, hotels, apartments, tanzania, travel, vacation rentals, airbnb alternative, dar es salaam, zanzibar
```

### 5.4 Graphics Requirements

#### Screenshots (Required: minimum 2, maximum 8)
- **Size**: 16:9 or 9:16 aspect ratio
- **Min**: 320px
- **Max**: 3840px
- **Format**: PNG or JPEG

**What to Screenshot**:
1. Home screen with listings
2. Listing detail page
3. Map view
4. Search results
5. User profile/bookings
6. Payment screen (optional)

#### Feature Graphic (Required)
- **Size**: 1024 x 500px
- **Format**: PNG or JPEG
- **Content**: App logo + tagline + attractive background

#### App Icon (Required)
- **Size**: 512 x 512px
- **Format**: PNG (32-bit)
- **No transparency**

---

## Step 6: Upload to Play Console

### 6.1 Create Release

1. Go to **Production** → **Create new release**
2. Choose **Google Play App Signing** (Recommended)
3. Upload your AAB file (`app-release.aab`)

### 6.2 Complete Release Details

**Release name**: `1.0.0 - Initial Release`

**Release notes**:
```
🎉 Welcome to Pango!

First release with:
• Browse and search accommodations across Tanzania
• Interactive map view with location-based search
• Secure booking and payment system
• Multiple payment methods (M-Pesa, Tigo Pesa, Airtel Money, Cards)
• User profiles and booking management
• Available in English and Swahili

Thank you for using Pango! We're excited to help you find your perfect stay.
```

### 6.3 Content Rating

1. Go to **Content rating**
2. Fill out questionnaire honestly
3. Answer questions about:
   - Violence
   - Sexual content
   - Profanity
   - User-generated content
   - Location sharing
4. Get rating (likely: Everyone or Teen)

### 6.4 Target Audience

- **Target age**: All ages or 13+
- **Contains ads**: No (unless you have ads)
- **App access**: Free for all users

### 6.5 Privacy Policy

You **MUST** provide a privacy policy URL.

Create a simple privacy policy covering:
- What data you collect (email, phone, location)
- How you use it (bookings, maps, communication)
- Third-party services (Google Maps, Pesapal, Firebase)
- User rights (access, deletion)
- Contact information

Host it on:
- Your website
- GitHub Pages
- Privacy policy generators (app-privacy-policy-generator.com)

### 6.6 App Content

- **Data safety**: Declare what data you collect
  - Location (for maps)
  - Personal info (name, email, phone)
  - Financial info (payment data - not stored by you)
  - Photos (profile, listings)

---

## Step 7: Testing & Review

### 7.1 Internal Testing (Recommended First)

1. Create **Internal testing** track
2. Add testers (up to 100 email addresses)
3. Upload AAB
4. Testers get instant access
5. Test for 1-2 weeks

### 7.2 Closed Testing (Beta)

1. Create **Closed testing** track
2. Invite beta testers
3. Gather feedback
4. Fix issues
5. Upload new version if needed

### 7.3 Production Release

1. Go to **Production** track
2. Upload final AAB
3. Complete all required sections:
   - Store listing ✅
   - Content rating ✅
   - Target audience ✅
   - Privacy policy ✅
   - App access ✅
   - Ads ✅
   - Data safety ✅
   - Release notes ✅
4. Click **Submit for review**

### 7.4 Review Process

- **Time**: 1-7 days (usually 2-3 days)
- **What they check**:
  - App functionality
  - Content policy compliance
  - User data handling
  - Payment processing
  - Permissions usage

---

## Troubleshooting

### Build Errors

#### "Keystore not found"
```bash
# Check if keystore exists
ls C:\pango\upload-keystore.jks

# Recreate if missing
keytool -genkey -v -keystore C:\pango\upload-keystore.jks ...
```

#### "Flutter SDK not found"
```bash
# Check Flutter
flutter doctor

# Fix issues
flutter doctor --android-licenses
```

#### "Gradle sync failed"
```bash
cd mobile/android
./gradlew clean
cd ../..
flutter clean
flutter pub get
```

### Upload Errors

#### "Version code already exists"
Update version in `pubspec.yaml`:
```yaml
version: 1.0.1+2  # Increment version code (+2)
```

#### "APK not signed"
Verify `key.properties` exists and is correct.

### Review Rejection

#### "Privacy policy missing"
Add privacy policy URL in App content section.

#### "Permissions not justified"
Add clear explanation for location permission in description.

#### "Crashes on startup"
Test on multiple devices/emulators before submission.

---

## Checklist Before Submission

- [ ] App builds successfully in release mode
- [ ] Tested on real Android device
- [ ] All features work properly
- [ ] No crashes or critical bugs
- [ ] App icon looks good
- [ ] Screenshots are clear and attractive
- [ ] Privacy policy is published
- [ ] Store listing is complete
- [ ] Payment functionality works (if enabled)
- [ ] Maps and location features work
- [ ] App size is reasonable (<50MB)
- [ ] Version number is correct
- [ ] Release notes are written
- [ ] Content rating is accurate

---

## Post-Launch

### Monitor Your App

1. **Google Play Console Dashboard**
   - Installs and uninstalls
   - Ratings and reviews
   - Crashes and ANRs
   - User acquisition

2. **Respond to Reviews**
   - Reply to user feedback
   - Fix reported issues
   - Thank positive reviewers

3. **Regular Updates**
   - Fix bugs quickly
   - Add new features
   - Improve based on feedback
   - Increment version for each update

### Update Process

1. Make changes to code
2. Update version: `1.0.1+2` → `1.0.2+3`
3. Build new AAB: `flutter build appbundle --release`
4. Upload to Play Console
5. Write release notes
6. Submit for review

---

## 🎉 Congratulations!

Your Pango app is ready for the Play Store! Follow this guide step by step, and you'll have your app published in no time.

**Good luck with your launch! 🚀**

---

## Resources

- **Play Console**: https://play.google.com/console
- **Flutter Docs**: https://docs.flutter.dev/deployment/android
- **App Signing**: https://developer.android.com/studio/publish/app-signing
- **Store Listing**: https://support.google.com/googleplay/android-developer/

---

**Questions?** Check the [Flutter deployment documentation](https://docs.flutter.dev/deployment/android) or reach out to Google Play support.

