# Play Store Release Guide for Homia

This guide will help you prepare and upload Homia to the Google Play Store, and manage future updates.

## 📋 Prerequisites

1. **Google Play Console Account**
   - Create an account at https://play.google.com/console
   - Pay the one-time $25 registration fee
   - Complete developer profile

2. **App Signing Key**
   - Generate a keystore for signing your app
   - Keep it secure - you'll need it for all future updates

3. **App Assets**
   - App icon (512x512 PNG)
   - Feature graphic (1024x500 PNG)
   - Screenshots (at least 2, up to 8)
   - Short description (80 characters max)
   - Full description (4000 characters max)

## 🔐 Step 1: Generate Signing Key

### Generate Keystore

```bash
cd android
keytool -genkey -v -keystore homia-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias homia
```

**Important:** 
- Store the keystore file securely (e.g., in a password manager or secure cloud storage)
- Remember the password and alias - you'll need them for every release
- **DO NOT** commit the keystore file to Git

### Create key.properties file

Create `android/key.properties` (this file should NOT be committed to Git):

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=homia
storeFile=homia-release-key.jks
```

Add to `.gitignore`:
```
android/key.properties
android/homia-release-key.jks
```

## 🔧 Step 2: Configure Release Signing

Update `android/app/build.gradle.kts` to use the keystore for release builds.

## 📱 Step 3: Update App Version

### Current Version: 1.0.0+1

**Version Format:** `version: X.Y.Z+BUILD_NUMBER`
- `X.Y.Z` = Version name (shown to users)
- `BUILD_NUMBER` = Version code (must increment for each Play Store upload)

### For Future Updates:

**Minor Update (bug fixes):**
```yaml
version: 1.0.1+2  # Increment patch version and build number
```

**Feature Update:**
```yaml
version: 1.1.0+3  # Increment minor version and build number
```

**Major Update:**
```yaml
version: 2.0.0+4  # Increment major version and build number
```

**Important:** The build number (version code) must ALWAYS increase for each Play Store upload, even if the version name stays the same.

## 🏗️ Step 4: Build Release Bundle (AAB)

Google Play requires Android App Bundle (AAB) format:

```bash
cd mobile
flutter build appbundle --release
```

The AAB file will be at: `build/app/outputs/bundle/release/app-release.aab`

## 📦 Step 5: Build Release APK (Alternative)

If you need an APK instead:

```bash
flutter build apk --release
```

The APK will be at: `build/app/outputs/flutter-apk/app-release.apk`

## 🚀 Step 6: Upload to Play Store

1. **Go to Google Play Console**
   - https://play.google.com/console

2. **Create New App**
   - Click "Create app"
   - Fill in app details:
     - App name: Homia
     - Default language: English
     - App or game: App
     - Free or paid: Free
     - Declarations: Complete all required

3. **Set Up Store Listing**
   - App icon: 512x512 PNG
   - Feature graphic: 1024x500 PNG
   - Screenshots: At least 2 (phone, tablet if applicable)
   - Short description: "Your Home Away From Home - Book accommodations across Tanzania"
   - Full description: (See APP_DESCRIPTION.md)
   - Category: Travel & Local
   - Contact details

4. **Content Rating**
   - Complete the questionnaire
   - Get rating certificate

5. **Privacy Policy**
   - Required for apps that collect user data
   - Host on your website or use a service like GitHub Pages

6. **Upload Release**
   - Go to "Production" → "Create new release"
   - Upload the AAB file
   - Add release notes
   - Review and roll out

## 🔄 Step 7: Future Updates

### Process for Each Update:

1. **Update Version in pubspec.yaml**
   ```yaml
   version: 1.0.1+2  # Increment appropriately
   ```

2. **Test Thoroughly**
   ```bash
   flutter test
   flutter run --release
   ```

3. **Build New Release**
   ```bash
   flutter build appbundle --release
   ```

4. **Upload to Play Store**
   - Go to Play Console
   - Create new release
   - Upload new AAB
   - Add release notes
   - Roll out (staged or full)

### Version Numbering Best Practices:

- **Patch (1.0.1)**: Bug fixes, small improvements
- **Minor (1.1.0)**: New features, enhancements
- **Major (2.0.0)**: Breaking changes, major redesigns

**Always increment build number (+1, +2, +3...) for every upload!**

## 📝 Release Notes Template

```
What's New in Version X.Y.Z:

✨ New Features:
- Feature 1
- Feature 2

🐛 Bug Fixes:
- Fixed issue 1
- Fixed issue 2

🔧 Improvements:
- Improvement 1
- Improvement 2
```

## ⚠️ Important Notes

1. **Never lose your keystore** - You cannot update the app without it
2. **Always test release builds** before uploading
3. **Version code must always increase** - Play Store won't accept lower numbers
4. **Review process** - First release takes 1-7 days, updates usually faster
5. **Staged rollouts** - Consider using staged rollouts (5% → 20% → 100%)

## 🔍 Testing Checklist

Before uploading to Play Store:

- [ ] App builds successfully in release mode
- [ ] All features work correctly
- [ ] No debug logs or test data
- [ ] App icon and splash screen look good
- [ ] Permissions are properly declared
- [ ] Privacy policy is accessible
- [ ] App works on different screen sizes
- [ ] Performance is acceptable
- [ ] No crashes in testing

## 📞 Support

For issues or questions:
- Check Flutter documentation: https://flutter.dev/docs
- Google Play Console Help: https://support.google.com/googleplay/android-developer

---

**Last Updated:** 2024
**Current Version:** 1.0.0+1

