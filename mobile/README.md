# Pango Mobile App

Flutter mobile application for the Pango accommodation booking platform.

## Quick Start

```bash
# Install dependencies
flutter pub get

# Run on Android
flutter run

# Run on iOS
flutter run

# Build APK
flutter build apk --release
```

## Features

- ✅ User authentication (login/register)
- ✅ Browse and search listings
- ✅ Advanced filters
- ✅ Listing details with photo gallery
- ✅ Booking flow with payment
- ✅ User profile management
- ✅ Host dashboard
- ✅ Bilingual support (Swahili/English)
- ✅ Beautiful Material Design 3 UI

## Configuration

### API Endpoint

Edit `lib/core/config/constants.dart`:
```dart
static const String baseUrl = 'http://YOUR_IP:3000/api/v1';
```

**Important:** 
- Android emulator: use `http://10.0.2.2:3000/api/v1`
- iOS simulator: use `http://localhost:3000/api/v1`
- Physical device: use `http://YOUR_LOCAL_IP:3000/api/v1`

### Google Maps Setup

1. Get API key from [Google Cloud Console](https://console.cloud.google.com/)
2. Enable Maps SDK for Android and iOS
3. Configure in platform-specific files

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY_HERE"/>
```

**iOS** (`ios/Runner/AppDelegate.swift`):
```swift
import GoogleMaps
GMSServices.provideAPIKey("YOUR_API_KEY_HERE")
```

## Project Structure

```
mobile/
├── lib/
│   ├── core/
│   │   ├── config/      # App configuration
│   │   ├── models/      # Data models
│   │   ├── providers/   # State management
│   │   ├── services/    # API services
│   │   ├── l10n/        # Localization
│   │   └── utils/       # Utilities
│   ├── features/        # App features
│   │   ├── auth/        # Authentication
│   │   ├── home/        # Home screen
│   │   ├── listing/     # Listing details
│   │   ├── booking/     # Booking flow
│   │   ├── profile/     # User profile
│   │   └── host/        # Host dashboard
│   └── main.dart        # App entry point
├── assets/
│   ├── images/
│   ├── icons/
│   └── fonts/
├── android/
├── ios/
└── pubspec.yaml
```

## State Management

The app uses **Provider** for state management with the following providers:

- `AuthProvider` - Authentication state
- `ListingProvider` - Listings data
- `BookingProvider` - Booking operations
- `LocaleProvider` - Language switching

## Localization

Supported languages:
- **Swahili (sw)** - Primary
- **English (en)** - Secondary

Translation files are in `lib/core/l10n/app_localizations.dart`

Usage:
```dart
final l10n = AppLocalizations.of(context);
Text(l10n.translate('key'))
```

## Building for Production

### Android

```bash
# Build APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release
```

### iOS

```bash
# Build IPA
flutter build ios --release

# Then archive in Xcode
```

## Testing

```bash
# Run tests
flutter test

# Run with coverage
flutter test --coverage
```

## Troubleshooting

**Can't connect to API:**
- Check API is running
- Verify correct IP address in constants
- Check firewall settings

**Google Maps not showing:**
- Verify API key is correct
- Enable required APIs in Google Cloud
- Check billing is enabled

**Build errors:**
- Run `flutter clean`
- Delete `pubspec.lock`
- Run `flutter pub get`
- Rebuild

## Dependencies

Main dependencies:
- `provider` - State management
- `dio` - HTTP client
- `google_maps_flutter` - Maps integration
- `firebase_messaging` - Push notifications
- `cached_network_image` - Image caching
- `shared_preferences` - Local storage

See `pubspec.yaml` for complete list.

























