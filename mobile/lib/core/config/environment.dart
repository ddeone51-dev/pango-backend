/// Environment configuration for different build environments
class Environment {
  // Build mode
  static const bool isProduction = bool.fromEnvironment(
    'dart.vm.product',
    defaultValue: false,
  );

  // API Configuration
  static String get baseUrl {
    if (isProduction) {
      // Production API - Your live Render backend
      return const String.fromEnvironment(
        'API_URL',
        defaultValue: 'https://pango-backend.onrender.com/api/v1',
      );
    } else {
      // Development API - Use Render backend for testing
      return 'https://pango-backend.onrender.com/api/v1';
    }
  }

  // Environment name
  static String get name => isProduction ? 'Production' : 'Development';

  // Debug mode
  static bool get isDebug => !isProduction;

  // Feature flags
  static bool get enableAnalytics => isProduction;
  static bool get enableCrashReporting => isProduction;
  static bool get showDebugBanner => !isProduction;

  // API Configuration
  static Duration get apiTimeout => isProduction 
    ? const Duration(seconds: 60)  // Longer timeout for cloud API
    : const Duration(seconds: 30); // Shorter timeout for local API
  
  static Duration get connectionTimeout => isProduction 
    ? const Duration(seconds: 60)  // Longer timeout for cloud API
    : const Duration(seconds: 30); // Shorter timeout for local API

  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String languageKey = 'language';

  // Print environment info
  static void printInfo() {
    print('');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('🌍 Environment: $name');
    print('🔗 API URL: $baseUrl');
    print('🐛 Debug Mode: $isDebug');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('');
  }
}

