import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/providers/favorites_provider.dart';
import '../../core/config/routes.dart';
import '../widgets/listing_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoritesProvider>().fetchFavorites();
      _showWelcomeDialog();
    });
  }

  Future<void> _showWelcomeDialog() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenWelcome = prefs.getBool('favorites_welcome_shown') ?? false;
    
    if (!hasSeenWelcome && mounted) {
      await prefs.setBool('favorites_welcome_shown', true);
      
      if (!mounted) return;
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.favorite, color: Theme.of(context).primaryColor, size: 28),
              const SizedBox(width: 12),
              const Text('Your Favorites'),
            ],
          ),
          content: const Text(
            'Save your favorite listings here for quick access anytime! '
            'This makes it easy to compare properties and book the perfect stay.',
            style: TextStyle(fontSize: 16, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Got it!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final favoritesProvider = context.watch<FavoritesProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('favorites')),
        actions: [
          if (favoritesProvider.favorites.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: Text(
                  '${favoritesProvider.favorites.length}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => favoritesProvider.fetchFavorites(),
        child: favoritesProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : favoritesProvider.favorites.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite_border,
                          size: 100,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Hakuna vipendwa bado',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Anza kutafuta na uhifadhi maeneo unayopenda',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey.shade500,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            // Switch to home tab (index 0)
                            DefaultTabController.of(context).animateTo(0);
                          },
                          icon: const Icon(Icons.explore),
                          label: const Text('Gundua Mali'),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16),
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.68,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: favoritesProvider.favorites.length,
                      itemBuilder: (context, index) {
                        final listing = favoritesProvider.favorites[index];
                        return ListingCard(
                          listing: listing,
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              Routes.listingDetail,
                              arguments: listing.id,
                            );
                          },
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}


