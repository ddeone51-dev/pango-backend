import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config/routes.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/storage_service.dart';
import '../../core/config/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    // Wait for authentication check to complete
    final authProvider = context.read<AuthProvider>();
    
    // Wait until authentication check is done
    while (authProvider.isCheckingAuth) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    // Add a minimum splash time for better UX
    await Future.delayed(const Duration(seconds: 1));
    
    if (!mounted) return;
    
    print('🚀 Splash screen navigation - isAuthenticated: ${authProvider.isAuthenticated}');
    print('🚀 AuthProvider user: ${authProvider.user?.fullName ?? "No user"}');
    
    if (authProvider.isAuthenticated) {
      print('🚀 Navigating to main screen');
      Navigator.of(context).pushReplacementNamed(Routes.main);
    } else {
      // Check if user has completed onboarding
      final hasCompletedOnboarding = StorageService.getBool(AppConstants.onboardingCompletedKey) ?? false;
      print('🚀 Has completed onboarding: $hasCompletedOnboarding');
      
      if (hasCompletedOnboarding) {
        print('🚀 User has completed onboarding, navigating to login');
        Navigator.of(context).pushReplacementNamed(Routes.login);
      } else {
        print('🚀 First time user, navigating to onboarding');
        Navigator.of(context).pushReplacementNamed(Routes.onboarding);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Homia text above the logo
            Text(
              'Homia',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 48,
              ),
            ),
            const SizedBox(height: 20),
            
            // Home image as splash
            Image.asset(
              'assets/images/home.jpeg',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            
            // Tagline below the logo
            Text(
              'Your Home Away From Home',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}







