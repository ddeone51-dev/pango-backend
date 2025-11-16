class AppConstants {
  // API Configuration
  // Live Render backend - accessible from anywhere!
  static const String baseUrl = 'https://pango-backend.onrender.com/api/v1';
  static const String baseUrlProduction = 'https://pango-backend.onrender.com/api/v1';
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String languageKey = 'language';
  static const String onboardingCompletedKey = 'onboarding_completed';
  
  // Pagination
  static const int defaultPageSize = 20;
  
  // Currency
  static const String currency = 'TZS';
  static const String currencySymbol = 'TSh';
  
  // Google Maps
  static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
  
  // Tanzania Regions
  static const List<String> regions = [
    'Dar es Salaam',
    'Arusha',
    'Dodoma',
    'Mwanza',
    'Mbeya',
    'Tanga',
    'Zanzibar',
    'Kilimanjaro',
    'Morogoro',
    'Pwani',
  ];
  
  // Property Types
  static const List<String> propertyTypes = [
    'apartment',
    'house',
    'villa',
    'guesthouse',
    'hotel',
    'resort',
    'cottage',
    'bungalow',
    'studio',
  ];
  
  // Amenities
  static const List<String> amenities = [
    'wifi',
    'parking',
    'kitchen',
    'air_conditioning',
    'heating',
    'tv',
    'pool',
    'gym',
    'security',
    'generator',
    'water_tank',
    'washer',
    'dryer',
    'workspace',
    'breakfast',
    'pet_friendly',
    'family_friendly',
    'accessible',
    'smoking_allowed',
    'mosquito_nets',
  ];
  
  // Date Formats
  static const String dateFormat = 'dd MMM yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd MMM yyyy HH:mm';
  
  // Image Limits
  static const int maxImagesPerListing = 10;
  static const int maxImageSizeMB = 5;
  
  // Booking Rules
  static const int minNights = 1;
  static const int maxNights = 365;
  static const double serviceFeePercentage = 10.0;
  static const double taxPercentage = 18.0; // VAT
}


