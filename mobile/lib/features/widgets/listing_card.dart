import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../core/models/listing.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/providers/favorites_provider.dart';
import '../../core/utils/currency_formatter.dart';

class ListingCard extends StatelessWidget {
  final Listing listing;
  final VoidCallback onTap;
  final bool showFavoriteButton;

  const ListingCard({
    super.key,
    required this.listing,
    required this.onTap,
    this.showFavoriteButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>().locale.languageCode;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image
            SizedBox(
              height: 150,
              width: double.infinity,
              child: Stack(
                children: [
                  _buildImage(listing.mainImage),
                // Favorite button (top right)
                if (showFavoriteButton)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _FavoriteButton(listingId: listing.id),
                  ),
                // Featured badge (top left)
                if (listing.featured)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Featured',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                // Rating
                if (listing.rating.count > 0)
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            listing.rating.average.toStringAsFixed(1),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Details - Simplified (Location, Rating, Price only)
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                    // Title
                    Text(
                      listing.title.get(locale),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    
                    // Location
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 13,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${listing.location.city}, ${listing.location.region}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    
                    // Rating (if exists)
                    if (listing.rating.count > 0) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 13),
                          const SizedBox(width: 2),
                          Text(
                            listing.rating.average.toStringAsFixed(1),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              '(${listing.rating.count})',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 10,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    
                    const SizedBox(height: 4),
                    
                    // Price
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Expanded(
                          child: Text(
                            CurrencyFormatter.format(listing.pricing.basePrice),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '/ usiku',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String imageUrl) {
    // Check if it's a base64 data URL
    if (imageUrl.startsWith('data:image')) {
      try {
        final base64String = imageUrl.split(',')[1];
        final bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          height: 150,
          width: double.infinity,
          fit: BoxFit.cover,
          gaplessPlayback: true, // Smooth display
          filterQuality: FilterQuality.medium, // Optimized quality
          cacheHeight: 300, // Cache at 2x for crisp display
          cacheWidth: 480,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 150,
              color: Colors.grey.shade200,
              child: const Icon(Icons.image_not_supported, size: 40),
            );
          },
        );
      } catch (e) {
        return Container(
          height: 150,
          color: Colors.grey.shade200,
          child: const Icon(Icons.image_not_supported, size: 40),
        );
      }
    } else {
      // Regular URL - use cached network image
    return CachedNetworkImage(
      imageUrl: imageUrl,
      height: 150,
      width: double.infinity,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.low,
      memCacheWidth: 340,
      memCacheHeight: 240,
      maxWidthDiskCache: 480,
      maxHeightDiskCache: 340,
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
          child: const Icon(Icons.image_not_supported, size: 40),
        ),
      );
    }
  }
  
}


// Favorite Button Widget
class _FavoriteButton extends StatelessWidget {
  final String listingId;
  
  const _FavoriteButton({required this.listingId});
  
  @override
  Widget build(BuildContext context) {
    final favoritesProvider = context.watch<FavoritesProvider>();
    final isFavorite = favoritesProvider.isFavorite(listingId);
    
    return GestureDetector(
      onTap: () async {
        final success = await favoritesProvider.toggleFavorite(listingId);
        if (context.mounted && !success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Hitilafu! Jaribu tena.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: isFavorite ? Colors.red : Colors.grey.shade700,
          size: 20,
        ),
      ),
    );
  }
}


