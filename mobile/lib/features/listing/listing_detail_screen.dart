import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import '../../core/config/routes.dart';
import '../../core/models/listing.dart';
import '../../core/providers/listing_provider.dart';
import '../../core/providers/review_provider.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/widgets/report_bottom_sheet.dart';
import '../../core/models/review.dart';
import '../reviews/reviews_list_screen.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ListingDetailScreen extends StatefulWidget {
  final String listingId;

  const ListingDetailScreen({super.key, required this.listingId});

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  int _currentImageIndex = 0;
  DateTime? _checkIn;
  DateTime? _checkOut;
  BitmapDescriptor? _customMarkerIcon;
  int _guests = 1;

  @override
  void initState() {
    super.initState();
    _loadCustomMarker();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ListingProvider>().fetchListingById(widget.listingId);
      context.read<ReviewProvider>().fetchListingReviews(widget.listingId, limit: 3);
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
      
      if (markerData != null && mounted) {
        setState(() {
          _customMarkerIcon = BitmapDescriptor.bytes(markerData.buffer.asUint8List());
        });
      }
    } catch (e) {
      // Fallback to default marker
    }
  }

  // Show fullscreen map
  void _showFullScreenMap(Listing listing, String locale) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _FullScreenMapView(
          listing: listing,
          locale: locale,
          customMarkerIcon: _customMarkerIcon,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = context.watch<LocaleProvider>().locale.languageCode;
    final listingProvider = context.watch<ListingProvider>();
    final listing = listingProvider.selectedListing;

    if (listingProvider.isLoading || listing == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Images
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            actions: [
              // Report button
              IconButton(
                icon: const Icon(Icons.flag_outlined),
                onPressed: () {
                  showReportBottomSheet(
                    context: context,
                    contentType: 'listing',
                    contentId: listing.id,
                    contentOwnerId: listing.hostId,
                    contentTitle: listing.title.get(locale),
                  );
                },
                tooltip: 'Report this listing',
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  CarouselSlider(
                    options: CarouselOptions(
                      height: 300,
                      viewportFraction: 1.0,
                      enableInfiniteScroll: false,
                      enlargeCenterPage: false,
                      scrollPhysics: const BouncingScrollPhysics(),
                      pageSnapping: true,
                      pauseAutoPlayOnTouch: true,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _currentImageIndex = index;
                        });
                      },
                    ),
                    items: listing.images.map((image) {
                      return _buildCarouselImage(image.url);
                    }).toList(),
                  ),
                  // Image indicators
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        listing.images.length,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentImageIndex == index
                                ? Colors.white
                                : Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Rating
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          listing.title.get(locale),
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                      ),
                      if (listing.rating.count > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
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
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                listing.rating.average.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
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
                      const Icon(Icons.location_on, size: 20),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          '${listing.location.city}, ${listing.location.region}',
                          style: Theme.of(context).textTheme.bodyLarge,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Price (Moved here - right after title and location)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              CurrencyFormatter.format(listing.pricing.basePrice),
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'per night',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        if (listing.pricing.cleaningFee > 0)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Cleaning Fee',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                CurrencyFormatter.format(listing.pricing.cleaningFee),
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Capacity
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoChip(
                          Icons.people_outline,
                          '${listing.capacity.guests} guests',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildInfoChip(
                          Icons.bed_outlined,
                          '${listing.capacity.beds} beds',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildInfoChip(
                          Icons.bathroom_outlined,
                          '${listing.capacity.bathrooms} baths',
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 32),

                  // Description
                  Text(
                    l10n.translate('description'),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    listing.description.get(locale),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),

                  const Divider(height: 32),

                  // Amenities
                  Text(
                    l10n.translate('amenities'),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: listing.amenities.map((amenity) {
                      return Chip(
                        label: Text(
                          amenity.replaceAll('_', ' ').toUpperCase(),
                        ),
                      );
                    }).toList(),
                  ),

                  const Divider(height: 32),

                  // Location Map
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Location',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      TextButton.icon(
                        onPressed: () => _showFullScreenMap(listing, locale),
                        icon: const Icon(Icons.fullscreen, size: 20),
                        label: const Text('Full Screen'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      height: 250,
                      child: Stack(
                        children: [
                          RepaintBoundary(
                            child: GoogleMap(
                              key: Key('detail_map_${listing.id}'),
                              initialCameraPosition: CameraPosition(
                                target: LatLng(
                                  listing.location.latitude,
                                  listing.location.longitude,
                                ),
                                zoom: 15,
                              ),
                              markers: {
                                Marker(
                                  markerId: MarkerId(listing.id),
                                  position: LatLng(
                                    listing.location.latitude,
                                    listing.location.longitude,
                                  ),
                                  icon: _customMarkerIcon ?? BitmapDescriptor.defaultMarkerWithHue(
                                    BitmapDescriptor.hueGreen,
                                  ),
                                  infoWindow: InfoWindow(
                                    title: listing.title.get(locale),
                                    snippet: listing.location.address,
                                  ),
                                ),
                              },
                              zoomControlsEnabled: true,  // ENABLED - Show zoom buttons
                              myLocationButtonEnabled: false,
                              mapToolbarEnabled: false,
                              buildingsEnabled: true,
                              trafficEnabled: false,
                              indoorViewEnabled: false,
                              compassEnabled: true,  // ENABLED - Show compass
                              rotateGesturesEnabled: true,  // ENABLED - Allow rotation
                              tiltGesturesEnabled: false,
                              scrollGesturesEnabled: true,  // ENABLED - Allow panning
                              zoomGesturesEnabled: true,    // ENABLED - Allow pinch zoom
                              minMaxZoomPreference: const MinMaxZoomPreference(10, 20),  // Allow zoom range
                              liteModeEnabled: false,  // DISABLED for full interactivity
                            ),
                          ),
                          // Fullscreen button overlay
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Material(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              elevation: 4,
                              child: InkWell(
                                onTap: () => _showFullScreenMap(listing, locale),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: const Icon(
                                    Icons.fullscreen,
                                    size: 24,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          listing.location.address,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 32),

                  // Host Information
                  Text(
                    'Your Host',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  _buildHostInfo(listing),

                  const Divider(height: 32),

                  // Reviews Section
                  _buildReviewsSection(context, listing, locale),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushNamed(
                Routes.booking,
                arguments: {
                  'listing': listing,
                  'checkIn': _checkIn,
                  'checkOut': _checkOut,
                  'guests': _guests,
                },
              );
            },
            child: Text(l10n.translate('book_now')),
          ),
        ),
      ),
    );
  }

  String _getHostInitial(listing) {
    try {
      if (listing.host != null && listing.host!['profile'] != null) {
        final firstName = listing.host!['profile']['firstName'];
        if (firstName != null && firstName.toString().isNotEmpty) {
          return firstName.toString().substring(0, 1).toUpperCase();
        }
      }
      return 'H';
    } catch (e) {
      return 'H';
    }
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildHostInfo(listing) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Host Avatar
              CircleAvatar(
                radius: 35,
                backgroundColor: Theme.of(context).primaryColor,
                child: Text(
                  _getHostInitial(listing),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Host Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.host != null && listing.host!['profile'] != null
                          ? '${listing.host!['profile']['firstName'] ?? 'Host'} ${listing.host!['profile']['lastName'] ?? ''}'
                          : 'Host',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.verified_user,
                          size: 16,
                          color: (listing.host != null && listing.host!['isEmailVerified'] == true)
                              ? Colors.green
                              : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          (listing.host != null && listing.host!['isEmailVerified'] == true)
                              ? 'Verified Host'
                              : 'Host',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Host & Property Rating Info
          const Divider(),
          const SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Host Rating (if available)
              if (listing.host != null && listing.host!['rating'] != null)
                _buildRatingItem(
                  context,
                  Icons.person_rounded,
                  listing.host!['rating']['average']?.toStringAsFixed(1) ?? '0.0',
                  'Host Rating',
                )
              else
                _buildRatingItem(
                  context,
                  Icons.person_rounded,
                  'New',
                  'Host',
                ),
              
              Container(
                width: 1,
                height: 40,
                color: Colors.grey.shade300,
              ),
              
              // Property Rating
              if (listing.rating.count > 0)
                _buildRatingItem(
                  context,
                  Icons.star_rounded,
                  listing.rating.average.toStringAsFixed(1),
                  '${listing.rating.count} reviews',
                )
              else
                _buildRatingItem(
                  context,
                  Icons.star_rounded,
                  'New',
                  'Property',
                ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Contact Host Button
          OutlinedButton.icon(
            onPressed: () {
              // TODO: Implement contact host functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Contact host feature coming soon!')),
              );
            },
            icon: const Icon(Icons.message_outlined),
            label: const Text('Contact Host'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              side: BorderSide(color: Theme.of(context).primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingItem(BuildContext context, IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(
          icon,
          color: Theme.of(context).primaryColor,
          size: 28,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
  
  Widget _buildReviewsSection(BuildContext context, Listing listing, String locale) {
    return Consumer<ReviewProvider>(
      builder: (context, reviewProvider, child) {
        final reviews = reviewProvider.listingReviews;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      listing.rating.count > 0
                          ? '${listing.rating.average.toStringAsFixed(1)} · ${listing.rating.count} ${listing.rating.count == 1 ? 'review' : 'reviews'}'
                          : 'No reviews yet',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
                if (listing.rating.count > 0)
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ReviewsListScreen(
                            listingId: listing.id,
                            listingTitle: listing.title.get(locale),
                          ),
                        ),
                      );
                    },
                    child: const Text('See all'),
                  ),
              ],
            ),
            
            if (listing.rating.count > 0) ...[
              const SizedBox(height: 16),
              
              // Rating breakdown
              _buildRatingBreakdown(context, listing),
              
              const SizedBox(height: 20),
              
              // Recent reviews
              if (reviewProvider.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (reviews.isNotEmpty)
                ...reviews.take(3).map((review) => Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: _buildReviewPreview(review, locale),
                    ))
              else
                const Text('No reviews available'),
            ] else
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Be the first to review this property after your stay!',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildRatingBreakdown(BuildContext context, Listing listing) {
    return Column(
      children: [
        if (listing.rating.breakdown.cleanliness > 0)
          _buildRatingBar('Cleanliness', listing.rating.breakdown.cleanliness),
        if (listing.rating.breakdown.accuracy > 0)
          _buildRatingBar('Accuracy', listing.rating.breakdown.accuracy),
        if (listing.rating.breakdown.communication > 0)
          _buildRatingBar('Communication', listing.rating.breakdown.communication),
        if (listing.rating.breakdown.location > 0)
          _buildRatingBar('Location', listing.rating.breakdown.location),
        if (listing.rating.breakdown.checkIn > 0)
          _buildRatingBar('Check-in', listing.rating.breakdown.checkIn),
        if (listing.rating.breakdown.value > 0)
          _buildRatingBar('Value', listing.rating.breakdown.value),
      ],
    );
  }

  Widget _buildRatingBar(String label, double rating) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: rating / 5.0,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
              minHeight: 6,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 30,
            child: Text(
              rating.toStringAsFixed(1),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewPreview(Review review, String locale) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: review.author.profilePicture != null
                    ? NetworkImage(review.author.profilePicture!)
                    : null,
                child: review.author.profilePicture == null
                    ? Text(
                        review.author.firstName.isNotEmpty
                            ? review.author.firstName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.author.fullName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Row(
                      children: [
                        RatingBarIndicator(
                          rating: review.ratings.overall,
                          itemBuilder: (context, index) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          itemCount: 5,
                          itemSize: 14.0,
                          unratedColor: Colors.grey.shade300,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          review.ratings.overall.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (review.comment != null) ...[
            const SizedBox(height: 12),
            Text(
              review.comment!.getLocalized(locale),
              style: const TextStyle(fontSize: 14, height: 1.4),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildCarouselImage(String imageUrl) {
    // Check if it's a base64 data URL
    if (imageUrl.startsWith('data:image')) {
      try {
        final base64String = imageUrl.split(',')[1];
        final bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 300,
          gaplessPlayback: true, // Smooth transitions
          filterQuality: FilterQuality.medium, // Balance quality/performance
          cacheHeight: 600, // Cache at 2x resolution
          cacheWidth: 1200,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey.shade200,
              child: const Center(
                child: Icon(Icons.image_not_supported, size: 50),
              ),
            );
          },
        );
      } catch (e) {
        return Container(
          color: Colors.grey.shade200,
          child: const Center(
            child: Icon(Icons.image_not_supported, size: 50),
          ),
        );
      }
    } else {
      // Regular URL - use cached network image
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 300,
        filterQuality: FilterQuality.low,
        memCacheWidth: 800,
        memCacheHeight: 600,
        maxWidthDiskCache: 1200,
        maxHeightDiskCache: 900,
        placeholder: (context, url) => Container(
          color: Colors.grey.shade200,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey.shade200,
          child: const Center(
            child: Icon(Icons.image_not_supported, size: 50),
          ),
        ),
      );
    }
  }
}

// Fullscreen Map View Widget
class _FullScreenMapView extends StatefulWidget {
  final Listing listing;
  final String locale;
  final BitmapDescriptor? customMarkerIcon;

  const _FullScreenMapView({
    required this.listing,
    required this.locale,
    this.customMarkerIcon,
  });

  @override
  State<_FullScreenMapView> createState() => _FullScreenMapViewState();
}

class _FullScreenMapViewState extends State<_FullScreenMapView> {
  GoogleMapController? _mapController;
  MapType _currentMapType = MapType.normal;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _toggleMapType() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal 
          ? MapType.satellite 
          : MapType.normal;
    });
  }

  void _zoomIn() {
    _mapController?.animateCamera(CameraUpdate.zoomIn());
  }

  void _zoomOut() {
    _mapController?.animateCamera(CameraUpdate.zoomOut());
  }

  void _resetCamera() {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            widget.listing.location.latitude,
            widget.listing.location.longitude,
          ),
          zoom: 15,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Fullscreen Google Map
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: LatLng(
                widget.listing.location.latitude,
                widget.listing.location.longitude,
              ),
              zoom: 15,
            ),
            markers: {
              Marker(
                markerId: MarkerId(widget.listing.id),
                position: LatLng(
                  widget.listing.location.latitude,
                  widget.listing.location.longitude,
                ),
                icon: widget.customMarkerIcon ?? BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueGreen,
                ),
                infoWindow: InfoWindow(
                  title: widget.listing.title.get(widget.locale),
                  snippet: widget.listing.location.address,
                ),
              ),
            },
            mapType: _currentMapType,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,  // We'll use custom controls
            compassEnabled: true,
            rotateGesturesEnabled: true,
            scrollGesturesEnabled: true,
            zoomGesturesEnabled: true,
            tiltGesturesEnabled: true,
            buildingsEnabled: true,
            trafficEnabled: false,
          ),

          // Top Bar with Back Button and Title
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      elevation: 4,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black87),
                        onPressed: () => Navigator.pop(context),
                        tooltip: 'Back',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.listing.title.get(widget.locale),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      widget.listing.location.address,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Right Side Control Panel
          Positioned(
            right: 16,
            top: MediaQuery.of(context).padding.top + 80,
            child: Column(
              children: [
                // Map Type Toggle
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  elevation: 4,
                  child: InkWell(
                    onTap: _toggleMapType,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _currentMapType == MapType.normal 
                                ? Icons.satellite_alt 
                                : Icons.map,
                            size: 24,
                            color: Colors.black87,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _currentMapType == MapType.normal 
                                ? 'Satellite' 
                                : 'Map',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Zoom In
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  elevation: 4,
                  child: IconButton(
                    icon: const Icon(Icons.add, color: Colors.black87),
                    onPressed: _zoomIn,
                    tooltip: 'Zoom In',
                  ),
                ),
                const SizedBox(height: 8),
                
                // Zoom Out
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  elevation: 4,
                  child: IconButton(
                    icon: const Icon(Icons.remove, color: Colors.black87),
                    onPressed: _zoomOut,
                    tooltip: 'Zoom Out',
                  ),
                ),
                const SizedBox(height: 12),
                
                // Reset Camera
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  elevation: 4,
                  child: IconButton(
                    icon: const Icon(Icons.my_location, color: Colors.black87),
                    onPressed: _resetCamera,
                    tooltip: 'Reset View',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


