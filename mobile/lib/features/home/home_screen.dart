import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/config/routes.dart';
import '../../core/providers/listing_provider.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/config/constants.dart';
import '../../core/utils/currency_formatter.dart';
import '../widgets/listing_card.dart';
import '../widgets/horizontal_listing_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSearching = false;
  String? _activeFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ListingProvider>().fetchFeaturedListings();
      context.read<ListingProvider>().fetchListings();
      _fetchNearbyListings();
    });
  }

  void _clearSearch() {
    setState(() {
      _isSearching = false;
      _activeFilter = null;
    });
    context.read<ListingProvider>().fetchListings();
  }

  Future<void> _fetchNearbyListings() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Default to Dar es Salaam if location is disabled
        if (mounted) {
          context.read<ListingProvider>().fetchNearbyListings(-6.7924, 39.2083);
        }
        return;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Default to Dar es Salaam if permission denied
          if (mounted) {
            context.read<ListingProvider>().fetchNearbyListings(-6.7924, 39.2083);
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Default to Dar es Salaam
        if (mounted) {
          context.read<ListingProvider>().fetchNearbyListings(-6.7924, 39.2083);
        }
        return;
      }

      // Get current location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );

      if (mounted) {
        context.read<ListingProvider>().fetchNearbyListings(
          position.latitude,
          position.longitude,
        );
      }
    } catch (e) {
      // Fallback to Dar es Salaam on error
      if (mounted) {
        context.read<ListingProvider>().fetchNearbyListings(-6.7924, 39.2083);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeProvider = context.watch<LocaleProvider>();
    final listingProvider = context.watch<ListingProvider>();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/images/logo3.png',
            height: 80,
            width: 80,
            fit: BoxFit.contain,
          ),
        ),
        leadingWidth: 100,
        title: const Text(
          'Homia',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.map_outlined),
            tooltip: 'Map View',
            onPressed: () {
              Navigator.of(context).pushNamed(Routes.mapView);
            },
          ),
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () => localeProvider.toggleLanguage(),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _isSearching = false;
            _activeFilter = null;
          });
          await Future.wait([
            context.read<ListingProvider>().fetchFeaturedListings(),
            context.read<ListingProvider>().fetchListings(),
          ]);
          await _fetchNearbyListings();
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed(Routes.search);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: Colors.grey.shade600),
                        const SizedBox(width: 12),
                        Text(
                          l10n.translate('where_stay'),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Search Results Header (when searching)
              if (_isSearching) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          _activeFilter != null 
                              ? 'Properties in $_activeFilter'
                              : 'Search Results',
                          style: Theme.of(context).textTheme.headlineSmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _clearSearch,
                        icon: const Icon(Icons.close, size: 18),
                        label: const Text('Clear'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Popular Destinations
              if (!_isSearching) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    l10n.translate('popular_destinations'),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: AppConstants.regions.length,
                    itemBuilder: (context, index) {
                      final region = AppConstants.regions[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: Text(region),
                          selected: _activeFilter == region,
                          onSelected: (selected) {
                            setState(() {
                              _isSearching = true;
                              _activeFilter = selected ? region : null;
                            });
                            context.read<ListingProvider>().fetchListings(
                              location: selected ? region : null,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Featured Listings (hide when searching)
              if (!_isSearching) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          l10n.translate('featured_listings'),
                          style: Theme.of(context).textTheme.headlineSmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed(Routes.search);
                        },
                        child: Text(l10n.translate('view_details')),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                
                if (listingProvider.featuredListings.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else
                  SizedBox(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: listingProvider.featuredListings.length,
                      itemBuilder: (context, index) {
                        final listing = listingProvider.featuredListings[index];
                        return Container(
                          width: 340,
                          margin: const EdgeInsets.only(right: 12),
                          child: HorizontalListingCard(
                            listing: listing,
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                Routes.listingDetail,
                                arguments: listing.id,
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 24),
              ],

              // Nearby Listings (hide when searching)
              if (!_isSearching) ...[
                Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_on, 
                            color: Theme.of(context).primaryColor,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Nearby You',
                              style: Theme.of(context).textTheme.headlineSmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(Routes.search);
                      },
                      child: Text(l10n.translate('view_details')),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              
              if (listingProvider.nearbyListings.isEmpty)
                const SizedBox.shrink()
              else
                SizedBox(
                  height: 150,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: listingProvider.nearbyListings.length,
                    itemBuilder: (context, index) {
                      final listing = listingProvider.nearbyListings[index];
                      return Container(
                        width: 340,
                        margin: const EdgeInsets.only(right: 12),
                        child: HorizontalListingCard(
                          listing: listing,
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              Routes.listingDetail,
                              arguments: listing.id,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),
              ],

              // All Listings / Search Results
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  _isSearching 
                      ? (_activeFilter != null ? 'Results' : 'Search Results')
                      : 'Recommended for you',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              const SizedBox(height: 12),

              if (listingProvider.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (listingProvider.listings.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text('No listings found'),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.68,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    // Limit to 20 listings to prevent image buffer overload
                    itemCount: listingProvider.listings.length > 20 
                        ? 20 
                        : listingProvider.listings.length,
                    itemBuilder: (context, index) {
                      final listing = listingProvider.listings[index];
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

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}


