import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../bookings/bookings_list_screen.dart';
import '../favorites/favorites_screen.dart';
import '../profile/profile_screen.dart';
import '../../core/l10n/app_localizations.dart';

class MainScreen extends StatefulWidget {
  final int initialTabIndex;
  
  const MainScreen({super.key, this.initialTabIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  late final List<Widget> _screens;
  
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex;
    _screens = [
      const HomeScreen(),
      const BookingsListScreen(),
      const FavoritesScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home_rounded),
            label: l10n.translate('home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.book_outlined),
            activeIcon: const Icon(Icons.book_rounded),
            label: l10n.translate('bookings'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.favorite_outline),
            activeIcon: const Icon(Icons.favorite_rounded),
            label: l10n.translate('favorites'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person_rounded),
            label: l10n.translate('profile'),
          ),
        ],
      ),
    );
  }
}





















