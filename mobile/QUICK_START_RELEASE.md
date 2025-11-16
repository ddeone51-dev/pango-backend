# Quick Start: Building for Play Store

## 🚀 Quick Steps

### 1. Generate Signing Key (First Time Only)

```bash
cd android
keytool -genkey -v -keystore homia-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias homia
```

**Save these details securely:**
- Keystore password
- Key password  
- Alias: `homia`

### 2. Create key.properties

Create `android/key.properties`:
```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=homia
storeFile=homia-release-key.jks
```

### 3. Update Version (For Each Release)

Edit `pubspec.yaml`:
```yaml
version: 1.0.0+1  # Increment build number (+1) for each release
```

### 4. Build Release Bundle

**Windows:**
```bash
BUILD_RELEASE.bat
```

**Mac/Linux:**
```bash
chmod +x BUILD_RELEASE.sh
./BUILD_RELEASE.sh
```

**Or manually:**
```bash
flutter clean
flutter pub get
flutter build appbundle --release
```

### 5. Find Your AAB File

Location: `build/app/outputs/bundle/release/app-release.aab`

### 6. Upload to Play Store

1. Go to https://play.google.com/console
2. Select your app
3. Go to Production → Create new release
4. Upload `app-release.aab`
5. Add release notes
6. Review and publish

## 📝 Version Update Examples

**Bug fix:**
```yaml
version: 1.0.0+1  →  version: 1.0.1+2
```

**New feature:**
```yaml
version: 1.0.1+2  →  version: 1.1.0+3
```

**Major update:**
```yaml
version: 1.1.0+3  →  version: 2.0.0+4
```

## ⚠️ Important

- **Always increment build number** (+1, +2, +3...) for each upload
- **Never lose your keystore** - backup it securely
- **Test release builds** before uploading
- **Version code must always increase** - Play Store won't accept lower numbers

## 📚 Full Documentation

See `PLAY_STORE_RELEASE.md` for complete guide.

