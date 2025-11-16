# Homia - Tanzanian Accommodation Booking Platform

![Homia Logo](https://via.placeholder.com/800x200/00A86B/FFFFFF?text=Homia+-+Your+Home+Away+From+Home)

## Overview

Homia is a mobile accommodation booking platform specifically designed for the Tanzanian market. It connects travelers with hosts offering accommodations across Tanzania, from urban apartments in Dar es Salaam to serene beach houses in Zanzibar.

### Key Features

✅ **User Authentication** - Secure login and registration with JWT  
✅ **Search & Filters** - Advanced search with multiple filters (location, price, amenities)  
✅ **Interactive Listings** - High-quality photos, detailed descriptions, host profiles  
✅ **Booking System** - Complete booking flow with date selection  
✅ **Payment Integration** - M-Pesa and card payment support  
✅ **Reviews & Ratings** - User reviews and 5-star rating system  
✅ **Host Dashboard** - Manage listings, bookings, and earnings  
✅ **Bilingual Support** - Swahili and English localization  
✅ **Currency Support** - Tanzanian Shillings (TZS)  
✅ **Push Notifications** - Booking confirmations and updates  

---

## Technology Stack

### Backend
- **Node.js** 18.x
- **Express.js** - Web framework
- **MongoDB** - Database
- **Mongoose** - ODM
- **JWT** - Authentication
- **Redis** - Caching
- **Firebase Admin** - Push notifications

### Frontend (Mobile)
- **Flutter** 3.x
- **Dart** - Programming language
- **Provider** - State management
- **Dio** - HTTP client
- **Google Maps Flutter** - Maps integration
- **Firebase Messaging** - Push notifications
- **Shared Preferences** - Local storage

---

## Project Structure

```
pango/
├── backend/                 # Node.js backend
│   ├── src/
│   │   ├── config/         # Database & configuration
│   │   ├── controllers/    # Request handlers
│   │   ├── middleware/     # Auth & error handling
│   │   ├── models/         # Mongoose models
│   │   ├── routes/         # API routes
│   │   ├── utils/          # Helper functions
│   │   ├── app.js          # Express app setup
│   │   └── server.js       # Server entry point
│   ├── package.json
│   └── .env.example
│
├── mobile/                  # Flutter mobile app
│   ├── lib/
│   │   ├── core/
│   │   │   ├── config/     # App configuration
│   │   │   ├── models/     # Data models
│   │   │   ├── providers/  # State management
│   │   │   ├── services/   # API & auth services
│   │   │   ├── l10n/       # Localization
│   │   │   └── utils/      # Utilities
│   │   ├── features/       # App features/screens
│   │   │   ├── auth/
│   │   │   ├── home/
│   │   │   ├── listing/
│   │   │   ├── booking/
│   │   │   ├── profile/
│   │   │   └── host/
│   │   └── main.dart
│   ├── pubspec.yaml
│   └── android/ & ios/
│
├── TECHNICAL_SPECIFICATION.md
└── README.md
```

---

## Getting Started

### Prerequisites

- Node.js >= 18.0.0
- npm >= 9.0.0
- MongoDB >= 6.0
- Redis (optional, for caching)
- Flutter SDK >= 3.0.0
- Dart >= 3.0.0
- Android Studio / Xcode (for mobile development)

### Backend Setup

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/pango.git
cd pango/backend
```

2. **Install dependencies**
```bash
npm install
```

3. **Configure environment variables**
```bash
cp .env.example .env
```

Edit `.env` file with your configuration:
```env
# Server
NODE_ENV=development
PORT=3000

# Database
MONGODB_URI=mongodb://localhost:27017/pango

# JWT
JWT_SECRET=your_super_secret_jwt_key
JWT_EXPIRE=7d

# Firebase (for push notifications)
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_PRIVATE_KEY=your_private_key
FIREBASE_CLIENT_EMAIL=your_client_email

# M-Pesa
MPESA_CONSUMER_KEY=your_mpesa_key
MPESA_CONSUMER_SECRET=your_mpesa_secret
MPESA_PASSKEY=your_passkey
MPESA_SHORTCODE=your_shortcode

# Google Maps
GOOGLE_MAPS_API_KEY=your_google_maps_api_key
```

4. **Start MongoDB**
```bash
# If using Docker
docker run -d -p 27017:27017 --name mongodb mongo:latest

# Or start local MongoDB service
sudo systemctl start mongod
```

5. **Run the server**
```bash
# Development mode with auto-reload
npm run dev

# Production mode
npm start
```

The API will be available at `http://localhost:3000/api/v1`

### Mobile App Setup

1. **Navigate to mobile directory**
```bash
cd ../mobile
```

2. **Install Flutter dependencies**
```bash
flutter pub get
```

3. **Configure API endpoint**

Edit `mobile/lib/core/config/constants.dart`:
```dart
static const String baseUrl = 'http://YOUR_IP:3000/api/v1';
// For Android emulator use: http://10.0.2.2:3000/api/v1
// For iOS simulator use: http://localhost:3000/api/v1
// For physical device use: http://YOUR_LOCAL_IP:3000/api/v1
```

4. **Configure Google Maps**

**Android**: Edit `android/app/src/main/AndroidManifest.xml`
```xml
<manifest>
    <application>
        <meta-data
            android:name="com.google.android.geo.API_KEY"
            android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
    </application>
</manifest>
```

**iOS**: Edit `ios/Runner/AppDelegate.swift`
```swift
GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
```

5. **Run the app**
```bash
# Check connected devices
flutter devices

# Run on Android
flutter run

# Run on iOS
flutter run

# Build APK
flutter build apk

# Build iOS app
flutter build ios
```

---

## API Documentation

### Base URL
```
Production: https://api.pango.co.tz/v1
Development: http://localhost:3000/api/v1
```

### Authentication

All authenticated endpoints require a Bearer token in the Authorization header:
```
Authorization: Bearer <your_jwt_token>
```

### Key Endpoints

#### Authentication
- `POST /auth/register` - Register new user
- `POST /auth/login` - Login user
- `POST /auth/logout` - Logout user
- `GET /auth/me` - Get current user

#### Listings
- `GET /listings` - Get all listings (with filters)
- `GET /listings/:id` - Get single listing
- `POST /listings` - Create listing (Host only)
- `PUT /listings/:id` - Update listing (Host only)
- `DELETE /listings/:id` - Delete listing (Host only)
- `GET /listings/featured` - Get featured listings

#### Bookings
- `GET /bookings` - Get user bookings
- `POST /bookings` - Create booking
- `GET /bookings/:id` - Get booking details
- `PUT /bookings/:id/confirm` - Confirm booking (Host)
- `PUT /bookings/:id/cancel` - Cancel booking

#### Users
- `GET /users/profile` - Get user profile
- `PUT /users/profile` - Update profile
- `POST /users/saved-listings/:id` - Save listing
- `DELETE /users/saved-listings/:id` - Remove saved listing

For complete API documentation, see [TECHNICAL_SPECIFICATION.md](TECHNICAL_SPECIFICATION.md)

---

## Features Implementation

### 1. User Authentication
- JWT-based authentication
- Secure password hashing with bcrypt
- Email and phone verification
- Password reset functionality

### 2. Search & Filtering
- Location-based search (region, city)
- Geospatial search (nearby listings)
- Price range filter
- Property type filter
- Amenities filter
- Guest capacity filter
- Date availability check

### 3. Listing Management
- Create, update, delete listings
- Multiple image upload
- Bilingual content (English & Swahili)
- Amenities selection
- Pricing configuration
- Availability calendar

### 4. Booking System
- Date range selection
- Guest count selection
- Price calculation (base + fees + taxes)
- Payment processing
- Booking confirmation
- Cancellation handling

### 5. Host Dashboard
- Earnings overview
- Booking management
- Listing management
- Analytics and insights
- Calendar management

### 6. Payment Integration
- M-Pesa mobile money (Primary for Tanzania)
- Credit/Debit card (Stripe)
- Secure payment processing
- Automatic payout to hosts
- Transaction history

### 7. Reviews & Ratings
- 5-star rating system
- Multiple rating categories (cleanliness, accuracy, location, etc.)
- Written reviews
- Host response to reviews
- Review moderation

### 8. Push Notifications
- Booking confirmations
- Payment confirmations
- Check-in reminders
- Review requests
- Host notifications

---

## Database Schema

### Collections

1. **users** - User accounts (guests, hosts, admins)
2. **listings** - Property listings
3. **bookings** - Booking records
4. **reviews** - User reviews
5. **notifications** - Push notifications
6. **messages** - In-app messaging
7. **payouts** - Host payouts

For detailed schema, see [TECHNICAL_SPECIFICATION.md](TECHNICAL_SPECIFICATION.md)

---

## Localization

The app supports two languages:
- **Swahili (sw)** - Primary language
- **English (en)** - Secondary language

Localization files are in `mobile/lib/core/l10n/app_localizations.dart`

### Adding New Translations

1. Add translations to the `_localizedValues` map
2. Use in code:
```dart
final l10n = AppLocalizations.of(context);
Text(l10n.translate('key'))
```

---

## Testing

### Backend Tests
```bash
cd backend
npm test
```

### Mobile Tests
```bash
cd mobile
flutter test
```

---

## Deployment

### Backend Deployment

**Using Docker:**
```bash
cd backend
docker build -t pango-api .
docker run -p 3000:3000 pango-api
```

**Recommended Platforms:**
- AWS EC2
- Google Cloud Run
- Heroku
- DigitalOcean

### Mobile Deployment

**Android:**
1. Build release APK:
```bash
flutter build apk --release
```
2. Upload to Google Play Console

**iOS:**
1. Build release IPA:
```bash
flutter build ios --release
```
2. Upload to App Store Connect using Xcode

---

## Environment Variables

### Backend Required Variables
- `NODE_ENV` - Environment (development/production)
- `PORT` - Server port
- `MONGODB_URI` - MongoDB connection string
- `JWT_SECRET` - JWT signing secret
- `GOOGLE_MAPS_API_KEY` - Google Maps API key
- `MPESA_CONSUMER_KEY` - M-Pesa API key
- `FIREBASE_PROJECT_ID` - Firebase project ID

### Optional Variables
- `REDIS_HOST` - Redis host for caching
- `SENDGRID_API_KEY` - Email service
- `SENTRY_DSN` - Error tracking

---

## Security Considerations

✅ JWT authentication with secure tokens  
✅ Password hashing (bcrypt with salt rounds)  
✅ Input validation and sanitization  
✅ SQL/NoSQL injection prevention  
✅ XSS protection  
✅ CORS configuration  
✅ Rate limiting  
✅ HTTPS only in production  
✅ Secure payment processing (PCI DSS compliant)  

---

## Performance Optimization

- Database indexing for fast queries
- Redis caching for frequently accessed data
- CDN for image delivery
- Pagination for large datasets
- Lazy loading images
- Connection pooling
- Query optimization

---

## Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## Troubleshooting

### Common Issues

**Backend won't start:**
- Check MongoDB is running
- Verify environment variables are set
- Check port 3000 is not in use

**Mobile app can't connect to API:**
- Use correct IP address (not localhost on physical device)
- Check firewall settings
- Verify API is running

**Google Maps not showing:**
- Verify API key is configured
- Enable Maps SDK for Android/iOS in Google Cloud Console
- Check billing is enabled

---

## Roadmap

### Phase 1 (MVP) ✅
- [x] User authentication
- [x] Listing browse and search
- [x] Booking system
- [x] Basic payment integration
- [x] Host dashboard

### Phase 2 (Enhancements)
- [ ] Advanced Google Maps integration
- [ ] In-app messaging
- [ ] Review system with moderation
- [ ] Multiple payment methods
- [ ] Push notifications

### Phase 3 (Growth Features)
- [ ] AI-powered recommendations
- [ ] Dynamic pricing
- [ ] Instant booking
- [ ] Host insurance
- [ ] Loyalty program
- [ ] Experiences and tours
- [ ] Business travel features

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## Support

For support, email support@pango.co.tz or join our Telegram community.

---

## Acknowledgments

- Inspired by Airbnb's user experience
- Built for the Tanzanian market with local needs in mind
- Special thanks to all contributors

---

## Contact

**Pango Team**  
Email: info@pango.co.tz  
Website: https://pango.co.tz  
Twitter: @PangoTZ  

---

Made with ❤️ for Tanzania 🇹🇿




















