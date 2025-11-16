import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  
  AppLocalizations(this.locale);
  
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }
  
  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();
  
  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_name': 'Homia',
      'welcome': 'Welcome',
      'login': 'Login',
      'register': 'Register',
      'email': 'Email',
      'password': 'Password',
      'phone_number': 'Phone Number',
      'first_name': 'First Name',
      'last_name': 'Last Name',
      'continue': 'Continue',
      'search': 'Search',
      'filters': 'Filters',
      'home': 'Home',
      'bookings': 'Bookings',
      'favorites': 'Favorites',
      'profile': 'Profile',
      'where_stay': 'Where do you want to stay?',
      'popular_destinations': 'Popular Destinations',
      'featured_listings': 'Featured Listings',
      'property_type': 'Property Type',
      'price_range': 'Price Range',
      'amenities': 'Amenities',
      'guests': 'Guests',
      'check_in': 'Check In',
      'check_out': 'Check Out',
      'per_night': 'per night',
      'book_now': 'Book Now',
      'view_details': 'View Details',
      'description': 'Description',
      'location': 'Location',
      'reviews': 'Reviews',
      'host': 'Host',
      'house_rules': 'House Rules',
      'total': 'Total',
      'subtotal': 'Subtotal',
      'cleaning_fee': 'Cleaning Fee',
      'service_fee': 'Service Fee',
      'taxes': 'Taxes',
      'confirm_booking': 'Confirm Booking',
      'booking_confirmed': 'Booking Confirmed!',
      'payment_processing': 'Processing Payment',
      'payment_method': 'Payment Method',
      'mpesa': 'M-Pesa',
      'card': 'Card',
      'my_bookings': 'My Bookings',
      'upcoming': 'Upcoming',
      'past': 'Past',
      'cancel_booking': 'Cancel Booking',
      'host_dashboard': 'Host Dashboard',
      'my_listings': 'My Listings',
      'add_listing': 'Add Listing',
      'earnings': 'Earnings',
      'logout': 'Logout',
      'what_type_property': 'What type of property are you listing?',
      'where_property_located': 'Where is your property located?',
      'details': 'Details',
      'tell_about_property': 'Tell us about your property',
      'photos': 'Photos',
      'add_photos': 'Add photos of your property',
      'pricing': 'Pricing',
      'set_price': 'Set your price',
    },
    'sw': {
      'app_name': 'Homia',
      'welcome': 'Karibu',
      'login': 'Ingia',
      'register': 'Jisajili',
      'email': 'Barua Pepe',
      'password': 'Neno la Siri',
      'phone_number': 'Nambari ya Simu',
      'first_name': 'Jina la Kwanza',
      'last_name': 'Jina la Ukoo',
      'continue': 'Endelea',
      'search': 'Tafuta',
      'filters': 'Chuja',
      'home': 'Nyumbani',
      'bookings': 'Uhifadhi',
      'favorites': 'Pendezi',
      'profile': 'Wasifu',
      'where_stay': 'Unataka kukaa wapi?',
      'popular_destinations': 'Maeneo Maarufu',
      'featured_listings': 'Mihifadhi Maalum',
      'property_type': 'Aina ya Mali',
      'price_range': 'Bei',
      'amenities': 'Huduma',
      'guests': 'Wageni',
      'check_in': 'Kuingia',
      'check_out': 'Kutoka',
      'per_night': 'kwa usiku',
      'book_now': 'Hifadhi Sasa',
      'view_details': 'Tazama Maelezo',
      'description': 'Maelezo',
      'location': 'Mahali',
      'reviews': 'Maoni',
      'host': 'Mwenyeji',
      'house_rules': 'Sheria za Nyumba',
      'total': 'Jumla',
      'subtotal': 'Jumla Ndogo',
      'cleaning_fee': 'Ada ya Usafi',
      'service_fee': 'Ada ya Huduma',
      'taxes': 'Kodi',
      'confirm_booking': 'Thibitisha Uhifadhi',
      'booking_confirmed': 'Uhifadhi Umethibitishwa!',
      'payment_processing': 'Malipo yanaendelea',
      'payment_method': 'Njia ya Malipo',
      'mpesa': 'M-Pesa',
      'card': 'Kadi',
      'my_bookings': 'Uhifadhi Wangu',
      'upcoming': 'Zijazo',
      'past': 'Zilizopita',
      'cancel_booking': 'Futa Uhifadhi',
      'host_dashboard': 'Dashibodi ya Mwenyeji',
      'my_listings': 'Mihifadhi Yangu',
      'add_listing': 'Ongeza Mihifadhi',
      'earnings': 'Mapato',
      'logout': 'Toka',
      'what_type_property': 'Ni aina gani ya mali unayoweka?',
      'where_property_located': 'Mali yako iko wapi?',
      'details': 'Maelezo',
      'tell_about_property': 'Tuambie kuhusu mali yako',
      'photos': 'Picha',
      'add_photos': 'Ongeza picha za mali yako',
      'pricing': 'Bei',
      'set_price': 'Weka bei yako',
    },
  };
  
  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();
  
  @override
  bool isSupported(Locale locale) {
    return ['en', 'sw'].contains(locale.languageCode);
  }
  
  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }
  
  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}




















