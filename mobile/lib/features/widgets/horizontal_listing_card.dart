import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../core/models/listing.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/providers/favorites_provider.dart';
import '../../core/utils/currency_formatter.dart';

class HorizontalListingCard extends StatelessWidget {
  final Listing listing;
  final VoidCallback onTap;

  const HorizontalListingCard({
    super.key,
    required this.listing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>().locale.languageCode;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 140,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image (Left Side)
              Stack(
                children: [
                  _buildImage(listing.mainImage),
                  // Favorite button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _FavoriteButton(listingId: listing.id),
                  ),
                  // Featured badge
                  if (listing.featured)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
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
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 14),
                            const SizedBox(width: 2),
                            Text(
                              listing.rating.average.toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),

              // Details (Right Side)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      Text(
                        listing.title.get(locale),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      
                      // Location
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14,
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
                      const SizedBox(height: 6),
                      
                      // Capacity
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          _buildCapacityIcon(Icons.people_outline, '${listing.capacity.guests}'),
                          _buildCapacityIcon(Icons.bed_outlined, '${listing.capacity.beds}'),
                          _buildCapacityIcon(Icons.bathroom_outlined, '${listing.capacity.bathrooms}'),
                        ],
                      ),
                      
                      const Spacer(),
                      
                      // Price
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            CurrencyFormatter.format(listing.pricing.basePrice),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Text(
                              '/ usiku',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
          height: 140,
          width: 140,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          filterQuality: FilterQuality.medium,
          cacheHeight: 280,
          cacheWidth: 280,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 140,
              width: 140,
              color: Colors.grey.shade200,
              child: const Icon(Icons.image_not_supported, size: 40),
            );
          },
        );
      } catch (e) {
        return Container(
          height: 140,
          width: 140,
          color: Colors.grey.shade200,
          child: const Icon(Icons.image_not_supported, size: 40),
        );
      }
    } else {
      // Regular URL - use cached network image
      return CachedNetworkImage(
        imageUrl: imageUrl,
        height: 140,
        width: 140,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.low,
        memCacheWidth: 180,  // More aggressive to prevent buffer overload
        memCacheHeight: 180,
        maxWidthDiskCache: 250,
        maxHeightDiskCache: 250,
        placeholder: (context, url) => Container(
          height: 140,
          width: 140,
          color: Colors.grey.shade200,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          height: 140,
          width: 140,
          color: Colors.grey.shade200,
          child: const Icon(Icons.image_not_supported, size: 40),
        ),
      );
    }
  }

  Widget _buildCapacityIcon(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 3),
        Text(
          value,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
    );
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
        padding: const EdgeInsets.all(5),
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
          size: 18,
        ),
      ),
    );
  }
}




