import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/listing_provider.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/models/listing.dart';
import '../widgets/listing_card.dart';

class HostListingsScreen extends StatefulWidget {
  const HostListingsScreen({super.key});

  @override
  State<HostListingsScreen> createState() => _HostListingsScreenState();
}

class _HostListingsScreenState extends State<HostListingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchHostListings();
    });
  }

  Future<void> _fetchHostListings() async {
    try {
      // Get current user ID from auth provider
      // For now, we'll use a hardcoded user ID
      final userId = '68e678ea9851a06c9994a1cf'; // Your user ID
      
      await context.read<ListingProvider>().fetchHostListings(userId);
    } catch (e) {
      print('Error fetching host listings: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final listingProvider = context.watch<ListingProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('my_listings')),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigate to add listing screen
              Navigator.of(context).pushNamed('/add-listing');
            },
          ),
        ],
      ),
      body: listingProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : listingProvider.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading listings',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        listingProvider.error!,
                        style: TextStyle(color: Colors.grey.shade600),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchHostListings,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : listingProvider.hostListings.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.home_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No listings yet',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start by adding your first property',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pushNamed('/add-listing');
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Add Listing'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchHostListings,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: listingProvider.hostListings.length,
                        itemBuilder: (context, index) {
                          final listing = listingProvider.hostListings[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: ListingCard(
                              listing: listing,
                              onTap: () {
                                // Navigate to listing detail screen
                                Navigator.of(context).pushNamed(
                                  '/listing-detail',
                                  arguments: listing.id,
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}

