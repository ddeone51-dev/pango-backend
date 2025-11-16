import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config/routes.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/services/storage_service.dart';
import '../../core/config/constants.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Welcome to Homia',
      titleSw: 'Karibu Homia',
      description: 'Find and book amazing accommodations across Tanzania',
      descriptionSw: 'Pata na hifadhi makazi mazuri Tanzania nzima',
      icon: Icons.home_work_rounded,
    ),
    OnboardingPage(
      title: 'Explore Destinations',
      titleSw: 'Gundua Maeneo',
      description: 'From Dar es Salaam to Zanzibar, discover unique stays',
      descriptionSw: 'Kutoka Dar es Salaam hadi Zanzibar, gundua makazi ya kipekee',
      icon: Icons.explore_rounded,
    ),
    OnboardingPage(
      title: 'Easy Booking',
      titleSw: 'Uhifadhi Rahisi',
      description: 'Book your perfect stay with just a few taps',
      descriptionSw: 'Hifadhi mahali pazuri kwa mibofyo michache tu',
      icon: Icons.touch_app_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final isSwahili = localeProvider.locale.languageCode == 'sw';

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Language toggle
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => localeProvider.toggleLanguage(),
                    icon: const Icon(Icons.language),
                    label: Text(isSwahili ? 'English' : 'Kiswahili'),
                  ),
                ],
              ),
            ),
            
            // Pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          page.icon,
                          size: 150,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(height: 40),
                        Text(
                          isSwahili ? page.titleSw : page.title,
                          style: Theme.of(context).textTheme.displaySmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          isSwahili ? page.descriptionSw : page.description,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // Page indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Theme.of(context).primaryColor
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Buttons
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        // Mark onboarding as completed
                        await StorageService.setBool(AppConstants.onboardingCompletedKey, true);
                        Navigator.of(context).pushReplacementNamed(Routes.register);
                      },
                      child: Text(isSwahili ? 'Jisajili' : 'Get Started'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () async {
                      // Mark onboarding as completed
                      await StorageService.setBool(AppConstants.onboardingCompletedKey, true);
                      Navigator.of(context).pushReplacementNamed(Routes.login);
                    },
                    child: Text(isSwahili ? 'Tayari una akaunti? Ingia' : 'Already have an account? Login'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String titleSw;
  final String description;
  final String descriptionSw;
  final IconData icon;

  OnboardingPage({
    required this.title,
    required this.titleSw,
    required this.description,
    required this.descriptionSw,
    required this.icon,
  });
}




















