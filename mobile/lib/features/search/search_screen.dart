import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config/routes.dart';
import '../../core/providers/listing_provider.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/config/constants.dart';
import '../widgets/listing_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  String? _selectedRegion;
  String? _selectedPropertyType;
  int? _guests;
  double? _minPrice;
  double? _maxPrice;
  List<String> _selectedAmenities = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Load initial listings
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ListingProvider>().fetchListings();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // Debounced search - waits 500ms after user stops typing
  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    _debounce = Timer(const Duration(milliseconds: 500), () {
      // Trigger search after user stops typing for 500ms
      final location = value.trim();
      context.read<ListingProvider>().fetchListings(
        location: location.isNotEmpty ? location : null,
        propertyType: _selectedPropertyType,
        guests: _guests,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        amenities: _selectedAmenities.isNotEmpty ? _selectedAmenities : null,
      );
    });
  }

  void _applyFilters() {
    // Close the filter bottom sheet first
    Navigator.of(context).pop();
    
    // Then apply filters and fetch listings
    context.read<ListingProvider>().fetchListings(
      location: _selectedRegion,
      guests: _guests,
      propertyType: _selectedPropertyType,
      minPrice: _minPrice,
      maxPrice: _maxPrice,
      amenities: _selectedAmenities.isNotEmpty ? _selectedAmenities : null,
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return DraggableScrollableSheet(
            initialChildSize: 0.9,
            maxChildSize: 0.9,
            minChildSize: 0.5,
            expand: false,
            builder: (context, scrollController) {
              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filters',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        TextButton(
                          onPressed: () {
                            setModalState(() {
                              _selectedRegion = null;
                              _selectedPropertyType = null;
                              _guests = null;
                              _minPrice = null;
                              _maxPrice = null;
                              _selectedAmenities = [];
                            });
                            setState(() {});
                          },
                          child: const Text('Clear All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        children: [
                          // Region
                          Text(
                            'Region',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: AppConstants.regions.map((region) {
                              return FilterChip(
                                label: Text(region),
                                selected: _selectedRegion == region,
                                onSelected: (selected) {
                                  setModalState(() {
                                    _selectedRegion = selected ? region : null;
                                  });
                                  setState(() {});
                                },
                              );
                            }).toList(),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Property Type
                          Text(
                            'Property Type',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: AppConstants.propertyTypes.map((type) {
                              return FilterChip(
                                label: Text(type.toUpperCase()),
                                selected: _selectedPropertyType == type,
                                onSelected: (selected) {
                                  setModalState(() {
                                    _selectedPropertyType = selected ? type : null;
                                  });
                                  setState(() {});
                                },
                              );
                            }).toList(),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Guests
                          Text(
                            'Number of Guests',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    hintText: 'Enter number',
                                  ),
                                  onChanged: (value) {
                                    setModalState(() {
                                      _guests = int.tryParse(value);
                                    });
                                    setState(() {});
                                  },
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Price Range
                          Text(
                            'Price Range (TZS per night)',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    hintText: 'Min',
                                  ),
                                  onChanged: (value) {
                                    setModalState(() {
                                      _minPrice = double.tryParse(value);
                                    });
                                    setState(() {});
                                  },
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text('-'),
                              ),
                              Expanded(
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    hintText: 'Max',
                                  ),
                                  onChanged: (value) {
                                    setModalState(() {
                                      _maxPrice = double.tryParse(value);
                                    });
                                    setState(() {});
                                  },
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Amenities
                          Text(
                            'Amenities',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: AppConstants.amenities.take(10).map((amenity) {
                              return FilterChip(
                                label: Text(amenity.replaceAll('_', ' ').toUpperCase()),
                                selected: _selectedAmenities.contains(amenity),
                                onSelected: (selected) {
                                  setModalState(() {
                                    if (selected) {
                                      _selectedAmenities.add(amenity);
                                    } else {
                                      _selectedAmenities.remove(amenity);
                                    }
                                  });
                                  setState(() {});
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _applyFilters,
                        child: const Text('Apply Filters'),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final listingProvider = context.watch<ListingProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
        ),
        title: Text(l10n.translate('search')),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: _showFilters,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar with Real-Time Results
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              autofocus: false,
              decoration: InputDecoration(
                hintText: 'Search by location... (e.g., Dar es Salaam)',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                filled: true,
                fillColor: Colors.grey[100],
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _debounce?.cancel();
                          setState(() {
                            _selectedRegion = null;
                          });
                          // Show all listings when cleared
                          context.read<ListingProvider>().fetchListings();
                        },
                      )
                    : null,
              ),
              // Real-time search with debouncing - searches 500ms after user stops typing
              onChanged: (value) {
                setState(() {}); // Update UI to show/hide clear button
                _onSearchChanged(value); // Debounced search
              },
              onSubmitted: (value) {
                // Immediate search on Enter key
                _debounce?.cancel();
                final location = value.trim();
                context.read<ListingProvider>().fetchListings(
                  location: location.isNotEmpty ? location : null,
                  propertyType: _selectedPropertyType,
                  guests: _guests,
                  minPrice: _minPrice,
                  maxPrice: _maxPrice,
                  amenities: _selectedAmenities.isNotEmpty ? _selectedAmenities : null,
                );
              },
            ),
          ),

          // Results Counter
          if (!listingProvider.isLoading && listingProvider.error == null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Text(
                    '${listingProvider.listings.length} ${listingProvider.listings.length == 1 ? 'property' : 'properties'} found',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  if (_searchController.text.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Chip(
                      label: Text(
                        'for "${_searchController.text}"',
                        style: const TextStyle(fontSize: 12),
                      ),
                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () {
                        _searchController.clear();
                        _debounce?.cancel();
                        context.read<ListingProvider>().fetchListings();
                      },
                    ),
                  ],
                ],
              ),
            ),

          // Results
          Expanded(
            child: listingProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : listingProvider.error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 64, color: Colors.red),
                            const SizedBox(height: 16),
                            Text('Error: ${listingProvider.error}'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                context.read<ListingProvider>().fetchListings();
                              },
                              child: const Text('Try Again'),
                            ),
                          ],
                        ),
                      )
                    : listingProvider.listings.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.search_off, size: 64, color: Colors.grey),
                                const SizedBox(height: 16),
                                const Text(
                                  'No listings found',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Try adjusting your search or filters',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _selectedRegion = null;
                                      _selectedPropertyType = null;
                                      _guests = null;
                                      _minPrice = null;
                                      _maxPrice = null;
                                      _selectedAmenities = [];
                                    });
                                    context.read<ListingProvider>().fetchListings();
                                  },
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Show All Listings'),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () async {
                              await context.read<ListingProvider>().fetchListings(
                                location: _searchController.text.isNotEmpty ? _searchController.text : null,
                                propertyType: _selectedPropertyType,
                                guests: _guests,
                                minPrice: _minPrice,
                                maxPrice: _maxPrice,
                                amenities: _selectedAmenities.isNotEmpty ? _selectedAmenities : null,
                              );
                            },
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              itemCount: listingProvider.listings.length,
                              itemBuilder: (context, index) {
                                final listing = listingProvider.listings[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: ListingCard(
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
          ),
        ],
      ),
    );
  }
}





