import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/review_provider.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/models/review.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';

class ReviewsListScreen extends StatefulWidget {
  final String listingId;
  final String listingTitle;

  const ReviewsListScreen({
    super.key,
    required this.listingId,
    required this.listingTitle,
  });

  @override
  State<ReviewsListScreen> createState() => _ReviewsListScreenState();
}

class _ReviewsListScreenState extends State<ReviewsListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReviewProvider>().fetchListingReviews(widget.listingId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reviews'),
      ),
      body: Consumer<ReviewProvider>(
        builder: (context, reviewProvider, child) {
          if (reviewProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (reviewProvider.listingReviews.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.rate_review_outlined,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No reviews yet',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Be the first to review this property',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => reviewProvider.fetchListingReviews(widget.listingId),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: reviewProvider.listingReviews.length,
              separatorBuilder: (context, index) => const Divider(height: 32),
              itemBuilder: (context, index) {
                final review = reviewProvider.listingReviews[index];
                return ReviewCard(review: review);
              },
            ),
          );
        },
      ),
    );
  }
}

class ReviewCard extends StatelessWidget {
  final Review review;

  const ReviewCard({
    super.key,
    required this.review,
  });

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final languageCode = localeProvider.locale.languageCode;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Reviewer info
        Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: review.author.profilePicture != null
                  ? NetworkImage(review.author.profilePicture!)
                  : null,
              child: review.author.profilePicture == null
                  ? Text(
                      review.author.firstName.isNotEmpty
                          ? review.author.firstName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    DateFormat('MMM d, yyyy').format(review.createdAt),
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Overall rating
        Row(
          children: [
            RatingBarIndicator(
              rating: review.ratings.overall,
              itemBuilder: (context, index) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              itemCount: 5,
              itemSize: 20.0,
              unratedColor: Colors.grey.shade300,
            ),
            const SizedBox(width: 8),
            Text(
              review.ratings.overall.toStringAsFixed(1),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        
        // Category ratings
        if (_hasDetailedRatings(review)) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (review.ratings.cleanliness != null)
                _buildCategoryChip('Cleanliness', review.ratings.cleanliness!),
              if (review.ratings.accuracy != null)
                _buildCategoryChip('Accuracy', review.ratings.accuracy!),
              if (review.ratings.communication != null)
                _buildCategoryChip('Communication', review.ratings.communication!),
              if (review.ratings.location != null)
                _buildCategoryChip('Location', review.ratings.location!),
              if (review.ratings.checkIn != null)
                _buildCategoryChip('Check-in', review.ratings.checkIn!),
              if (review.ratings.value != null)
                _buildCategoryChip('Value', review.ratings.value!),
            ],
          ),
        ],
        
        // Review comment
        if (review.comment != null) ...[
          const SizedBox(height: 12),
          Text(
            review.comment!.getLocalized(languageCode),
            style: const TextStyle(fontSize: 15, height: 1.5),
          ),
        ],
        
        // Review photos
        if (review.photos.isNotEmpty) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: review.photos.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    review.photos[index],
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),
        ],
        
        // Host response
        if (review.response != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Host Response',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('MMM d, yyyy').format(review.response!.respondedAt),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  review.response!.text,
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
              ],
            ),
          ),
        ],
        
        // Helpful button
        const SizedBox(height: 12),
        Consumer<ReviewProvider>(
          builder: (context, reviewProvider, child) {
            return TextButton.icon(
              onPressed: () {
                reviewProvider.markHelpful(review.id);
              },
              icon: Icon(
                review.helpful.count > 0 ? Icons.thumb_up : Icons.thumb_up_outlined,
                size: 18,
              ),
              label: Text(
                review.helpful.count > 0
                    ? 'Helpful (${review.helpful.count})'
                    : 'Helpful',
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 32),
              ),
            );
          },
        ),
      ],
    );
  }

  bool _hasDetailedRatings(Review review) {
    return review.ratings.cleanliness != null ||
        review.ratings.accuracy != null ||
        review.ratings.communication != null ||
        review.ratings.location != null ||
        review.ratings.checkIn != null ||
        review.ratings.value != null;
  }

  Widget _buildCategoryChip(String label, double rating) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.star, size: 12, color: Colors.amber),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}






