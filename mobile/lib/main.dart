import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/config/theme.dart';
import 'core/config/routes.dart';
import 'core/config/environment.dart';
import 'core/services/api_service.dart';
import 'core/services/auth_service.dart';
import 'core/services/storage_service.dart';
import 'core/services/push_notification_service.dart';
import 'core/services/zenopay_service.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/listing_provider.dart';
import 'core/providers/booking_provider.dart';
import 'core/providers/favorites_provider.dart';
import 'core/providers/review_provider.dart';
import 'core/providers/notification_provider.dart';
import 'core/providers/locale_provider.dart';
import 'core/providers/host_calendar_provider.dart';
import 'core/providers/host_analytics_provider.dart';
import 'core/providers/host_payout_provider.dart';
import 'core/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Print environment configuration
  Environment.printInfo();
  
  // Initialize Firebase (Google's SMS service)
  try {
    await Firebase.initializeApp();
    print('🔥 Firebase initialized successfully - Google SMS ready!');
  } catch (e) {
    print('⚠️ Firebase not configured yet - using fallback auth');
    print('📋 Follow FIREBASE_SETUP_GUIDE.md to enable Google SMS');
  }
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Initialize services
  await StorageService.init();
  
  // Push notifications will be initialized after app starts with API service
  print('✅ Push Notification Service will be initialized after app start');
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>(
          create: (_) => ApiService(),
        ),
        Provider<AuthService>(
          create: (context) => AuthService(
            apiService: context.read<ApiService>(),
          ),
        ),
        ChangeNotifierProvider<LocaleProvider>(
          create: (_) => LocaleProvider(),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(
            authService: context.read<AuthService>(),
          ),
        ),
        ChangeNotifierProvider<ListingProvider>(
          create: (context) => ListingProvider(
            apiService: context.read<ApiService>(),
          ),
        ),
        Provider<ZenoPayService>(
          create: (_) => ZenoPayService(apiKey: 'ULN3aqdUBl8-iRH1jyxf3f2bLY2WL6f7stFfLiBdnrlkBtX843Zi7aRZdQbfKyU1NGUsakCj1gElJee6Zq9HRQ'),
        ),
        ChangeNotifierProvider<BookingProvider>(
          create: (context) => BookingProvider(
            apiService: context.read<ApiService>(),
            zenopayService: context.read<ZenoPayService>(),
          ),
        ),
        ChangeNotifierProvider<FavoritesProvider>(
          create: (context) => FavoritesProvider(
            apiService: context.read<ApiService>(),
          ),
        ),
        ChangeNotifierProvider<ReviewProvider>(
          create: (context) => ReviewProvider(
            apiService: context.read<ApiService>(),
          ),
        ),
        ChangeNotifierProvider<NotificationProvider>(
          create: (context) {
            final provider = NotificationProvider();
            provider.loadNotifications();
            provider.loadPreferences();
            final pushService = PushNotificationService();
            pushService.initialize(apiService: context.read<ApiService>());
            return provider;
          },
        ),
        ChangeNotifierProvider<HostCalendarProvider>(
          create: (context) => HostCalendarProvider(
            apiService: context.read<ApiService>(),
          ),
        ),
        ChangeNotifierProvider<HostAnalyticsProvider>(
          create: (context) => HostAnalyticsProvider(
            apiService: context.read<ApiService>(),
          ),
        ),
        ChangeNotifierProvider<HostPayoutProvider>(
          create: (context) => HostPayoutProvider(
            apiService: context.read<ApiService>(),
          ),
        ),
      ],
      child: const HomiaApp(),
    ),
  );
}

class HomiaApp extends StatefulWidget {
  const HomiaApp({super.key});

  @override
  State<HomiaApp> createState() => _HomiaAppState();
}

class _HomiaAppState extends State<HomiaApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // App came back to foreground, only refresh if user is already authenticated
      final authProvider = context.read<AuthProvider>();
      if (authProvider.isAuthenticated) {
        authProvider.refreshAuth();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return MaterialApp(
          title: 'Homia',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
          locale: localeProvider.locale,
          supportedLocales: const [
            Locale('sw', 'TZ'), // Swahili
            Locale('en', 'US'), // English
          ],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          initialRoute: Routes.splash,
          onGenerateRoute: Routes.generateRoute,
        );
      },
    );
  }
}



