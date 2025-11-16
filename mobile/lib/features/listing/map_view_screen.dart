import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import '../../core/providers/listing_provider.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/models/listing.dart';
import '../../core/config/routes.dart';
import '../../core/utils/currency_formatter.dart';

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Listing? _selectedListing;
  bool _isDisposed = false;
  BitmapDescriptor? _customMarkerIcon;
  final TextEditingController _searchController = TextEditingController();
  List<Listing> _allListings = [];
  List<Listing> _filteredListings = [];
  
  // Default location (Center of Tanzania - to show all properties)
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(-6.3690, 34.8888), // Center of Tanzania
    zoom: 6, // Zoomed out to show entire country
  );

  @override
  void initState() {
    super.initState();
    _isDisposed = false;
    _loadCustomMarker();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadListings();
    });
  }
  
  // Load custom marker icon from logo
  Future<void> _loadCustomMarker() async {
    try {
      final ByteData data = await rootBundle.load('assets/images/logo.png');
      final ui.Codec codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(),
        targetWidth: 60, // 2x bigger marker size
        targetHeight: 60,
      );
      final ui.FrameInfo fi = await codec.getNextFrame();
      final ByteData? markerData = await fi.image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      
      if (markerData != null && mounted && !_isDisposed) {
        setState(() {
          _customMarkerIcon = BitmapDescriptor.bytes(markerData.buffer.asUint8List());
        });
      }
    } catch (e) {
      print('Error loading custom marker: $e');
      // Fallback to default marker will be used
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _searchController.dispose();
    _mapController?.dispose();
    _mapController = null;
    super.dispose();
  }

  Future<void> _loadListings() async {
    if (_isDisposed) return;
    final listingProvider = context.read<ListingProvider>();
    await listingProvider.fetchListings();
    if (!_isDisposed && mounted) {
      setState(() {
        _allListings = listingProvider.listings;
        _filteredListings = _allListings;
      });
      _updateMarkers(_filteredListings);
    }
  }
  
  // Search and filter listings
  void _searchListings(String query) {
    if (_isDisposed || !mounted) return;
    
    final locale = context.read<LocaleProvider>().locale.languageCode;
    final searchLower = query.toLowerCase();
    
    setState(() {
      if (query.isEmpty) {
        _filteredListings = _allListings;
      } else {
        _filteredListings = _allListings.where((listing) {
          final title = listing.title.get(locale).toLowerCase();
          final city = listing.location.city.toLowerCase();
          final region = listing.location.region.toLowerCase();
          final address = listing.location.address.toLowerCase();
          
          return title.contains(searchLower) ||
                 city.contains(searchLower) ||
                 region.contains(searchLower) ||
                 address.contains(searchLower);
        }).toList();
      }
    });
    
    _updateMarkers(_filteredListings);
    
    // If we have filtered results, fit them on screen
    if (_filteredListings.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!_isDisposed && mounted) {
          _fitAllMarkers();
        }
      });
    }
  }

  void _updateMarkers(List<Listing> listings) {
    if (_isDisposed || !mounted) return;
    
    // Limit markers to reduce rendering load (max 50 markers)
    final limitedListings = listings.take(50).toList();
    
    // Debug: Print how many listings we have
    print('🗺️ Creating markers for ${limitedListings.length} listings');
    
    setState(() {
      _markers = limitedListings.map((listing) {
        // Debug: Print each marker location
        print('📍 Marker: ${listing.location.city} at (${listing.location.latitude}, ${listing.location.longitude})');
        
        return Marker(
          markerId: MarkerId(listing.id),
          position: LatLng(
            listing.location.latitude,
            listing.location.longitude,
          ),
          // Use custom logo icon if loaded, otherwise use default green marker
          icon: _customMarkerIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          onTap: () {
            if (!_isDisposed && mounted) {
              setState(() {
                _selectedListing = listing;
              });
              // Animate camera to selected marker (only if controller exists)
              _mapController?.animateCamera(
                CameraUpdate.newLatLng(
                  LatLng(listing.location.latitude, listing.location.longitude),
                ),
              );
            }
          },
        );
      }).toSet();
      
      print('✅ Total markers created: ${_markers.length}');
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    if (!_isDisposed) {
      _mapController = controller;
      // Fit all markers on screen after map is created
      _fitAllMarkers();
    }
  }
  
  // Fit map to show all markers
  void _fitAllMarkers() async {
    if (_markers.isEmpty || _mapController == null || _isDisposed) return;
    
    // Calculate bounds to fit all markers
    double minLat = double.infinity;
    double maxLat = -double.infinity;
    double minLng = double.infinity;
    double maxLng = -double.infinity;
    
    for (var marker in _markers) {
      minLat = minLat < marker.position.latitude ? minLat : marker.position.latitude;
      maxLat = maxLat > marker.position.latitude ? maxLat : marker.position.latitude;
      minLng = minLng < marker.position.longitude ? minLng : marker.position.longitude;
      maxLng = maxLng > marker.position.longitude ? maxLng : marker.position.longitude;
    }
    
    // Add padding
    final bounds = LatLngBounds(
      southwest: LatLng(minLat - 0.5, minLng - 0.5),
      northeast: LatLng(maxLat + 0.5, maxLng + 0.5),
    );
    
    // Animate to bounds
    await Future.delayed(const Duration(milliseconds: 100));
    if (!_isDisposed && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 50),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final listingProvider = context.watch<ListingProvider>();
    final locale = context.watch<LocaleProvider>().locale.languageCode;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
        ),
        title: const Text('Map View'),
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_out_map),
            tooltip: 'Show All Properties',
            onPressed: () {
              _fitAllMarkers();
            },
          ),
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Google Map (Optimized for performance)
          RepaintBoundary(
            child: GoogleMap(
              key: const Key('main_map_view'),
              onMapCreated: _onMapCreated,
              initialCameraPosition: _initialPosition,
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              liteModeEnabled: false,  // Full features but optimized
              buildingsEnabled: false,  // Reduce rendering load
              trafficEnabled: false,
              indoorViewEnabled: false,
              compassEnabled: false,
              rotateGesturesEnabled: false,  // Reduce gesture complexity
              tiltGesturesEnabled: false,
              minMaxZoomPreference: const MinMaxZoomPreference(5, 18),  // Allow zooming out to see all Tanzania
              onTap: (_) {
                // Close property card when map is tapped
                if (!_isDisposed && mounted) {
                  setState(() {
                    _selectedListing = null;
                  });
                }
              },
            ),
          ),
          
          // Search Bar
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(30),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _searchListings,
                  decoration: InputDecoration(
                    hintText: 'Search by city, region, or property name...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              _searchListings('');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Results Counter
          if (_searchController.text.isNotEmpty)
            Positioned(
              top: 75,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_filteredListings.length} properties found',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          
          // Loading Indicator
          if (listingProvider.isLoading)
            Positioned(
              top: 110,
              left: 0,
              right: 0,
              child: Center(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Loading properties...',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          
          // Property Card (shown when marker is tapped)
          if (_selectedListing != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed(
                    Routes.listingDetail,
                    arguments: _selectedListing!.id,
                  );
                },
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Property Image
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: _selectedListing!.mainImage,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 150,
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 150,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.image_not_supported, size: 50),
                          ),
                        ),
                      ),
                      
                      // Property Details
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title and Rating
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    _selectedListing!.title.get(locale),
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (_selectedListing!.rating.count > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _selectedListing!.rating.average.toStringAsFixed(1),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            
                            const SizedBox(height: 8),
                            
                            // Location
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 16,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    '${_selectedListing!.location.city}, ${_selectedListing!.location.region}',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 8),
                            
                            // Property Type and Capacity
                            Row(
                              children: [
                                _buildInfoChip(
                                  Icons.home_outlined,
                                  _selectedListing!.propertyType.toUpperCase(),
                                ),
                                const SizedBox(width: 8),
                                _buildInfoChip(
                                  Icons.people_outline,
                                  '${_selectedListing!.capacity.guests} guests',
                                ),
                                const SizedBox(width: 8),
                                _buildInfoChip(
                                  Icons.bed_outlined,
                                  '${_selectedListing!.capacity.beds} beds',
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 12),
                            
                            // Price and View Button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      CurrencyFormatter.format(_selectedListing!.pricing.basePrice),
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'per night',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pushNamed(
                                      Routes.listingDetail,
                                      arguments: _selectedListing!.id,
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                  ),
                                  child: const Text('View Details'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          
          // Listings Count Badge
          Positioned(
            top: 20,
            right: 20,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.home,
                      size: 16,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${listingProvider.listings.length} properties',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'zoom_in',
            mini: true,
            backgroundColor: Colors.white,
            onPressed: () {
              _mapController?.animateCamera(CameraUpdate.zoomIn());
            },
            child: Icon(Icons.add, color: Theme.of(context).primaryColor),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'zoom_out',
            mini: true,
            backgroundColor: Colors.white,
            onPressed: () {
              _mapController?.animateCamera(CameraUpdate.zoomOut());
            },
            child: Icon(Icons.remove, color: Theme.of(context).primaryColor),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'my_location',
            backgroundColor: Theme.of(context).primaryColor,
            onPressed: () {
              _mapController?.animateCamera(
                CameraUpdate.newCameraPosition(_initialPosition),
              );
            },
            child: const Icon(Icons.my_location, color: Colors.white),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade700),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}



