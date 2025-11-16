import 'package:flutter/material.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/auth/verification_screen.dart';
import '../../features/home/main_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/listing/listing_detail_screen.dart';
import '../../features/listing/map_view_screen.dart';
import '../../features/booking/booking_screen.dart';
import '../../features/booking/booking_confirmation_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/profile/edit_profile_screen.dart';
import '../../features/host/host_dashboard_screen.dart';
import '../../features/host/host_listings_screen.dart';
import '../../features/host/improved_add_listing_screen.dart';
import '../../features/host/host_calendar_screen.dart';
import '../../features/host/host_analytics_screen.dart';
import '../../features/host/host_payout_settings_screen.dart';
import '../../features/notifications/notification_settings_screen.dart';

class Routes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String verification = '/verification';
  static const String main = '/main';
  static const String home = '/home';
  static const String search = '/search';
  static const String mapView = '/map-view';
  static const String listingDetail = '/listing-detail';
  static const String booking = '/booking';
  static const String bookingConfirmation = '/booking-confirmation';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String hostDashboard = '/host-dashboard';
  static const String hostListings = '/host-listings';
  static const String addListing = '/add-listing';
  static const String hostCalendar = '/host-calendar';
  static const String hostAnalytics = '/host-analytics';
  static const String hostPayoutSettings = '/host-payout-settings';
  static const String notificationSettings = '/notification-settings';
  
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      
      case verification:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => VerificationScreen(
            verificationType: args['verificationType'],
            contact: args['contact'],
            email: args['email'],
            password: args['password'],
            firstName: args['firstName'],
            lastName: args['lastName'],
            role: args['role'],
          ),
        );
      
      case main:
        final initialTabIndex = settings.arguments as int? ?? 0;
        return MaterialPageRoute(builder: (_) => MainScreen(initialTabIndex: initialTabIndex));
      
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      
      case search:
        return MaterialPageRoute(builder: (_) => const SearchScreen());
      
      case mapView:
        return MaterialPageRoute(builder: (_) => const MapViewScreen());
      
      case listingDetail:
        final listingId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => ListingDetailScreen(listingId: listingId),
        );
      
      case booking:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => BookingScreen(
            listing: args['listing'],
            checkIn: args['checkIn'],
            checkOut: args['checkOut'],
            guests: args['guests'],
          ),
        );
      
      case bookingConfirmation:
        final bookingId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => BookingConfirmationScreen(bookingId: bookingId),
        );
      
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      
      case editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());
      
      case hostDashboard:
        return MaterialPageRoute(builder: (_) => const HostDashboardScreen());
      
      case hostListings:
        return MaterialPageRoute(builder: (_) => const HostListingsScreen());
      
      case addListing:
        return MaterialPageRoute(builder: (_) => const ImprovedAddListingScreen());
      
      case hostCalendar:
        return MaterialPageRoute(builder: (_) => const HostCalendarScreen());
      
      case hostAnalytics:
        return MaterialPageRoute(builder: (_) => const HostAnalyticsScreen());
      
      case hostPayoutSettings:
        return MaterialPageRoute(builder: (_) => const HostPayoutSettingsScreen());
      
      case notificationSettings:
        return MaterialPageRoute(builder: (_) => const NotificationSettingsScreen());
      
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}



