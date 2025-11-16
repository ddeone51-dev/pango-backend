import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import '../../core/providers/review_provider.dart';
import '../../core/models/review.dart';

class ReviewScreen extends StatefulWidget {
  final String bookingId;
  final String listingId;

  const ReviewScreen({
    super.key,
    required this.bookingId,
    required this.listingId,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  
  double _overallRating = 0;
  double _cleanlinessRating = 0;
  double _accuracyRating = 0;
  double _communicationRating = 0;
  double _locationRating = 0;
  double _checkInRating = 0;
  double _valueRating = 0;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_formKey.currentState!.validate() && _overallRating > 0) {
      final reviewProvider = context.read<ReviewProvider>();
      
      // Create review data
      final reviewData = CreateReviewData(
        bookingId: widget.bookingId,
        ratings: ReviewRatings(
          overall: _overallRating,
          cleanliness: _cleanlinessRating > 0 ? _cleanlinessRating : null,
          accuracy: _accuracyRating > 0 ? _accuracyRating : null,
          communication: _communicationRating > 0 ? _communicationRating : null,
          location: _locationRating > 0 ? _locationRating : null,
          checkIn: _checkInRating > 0 ? _checkInRating : null,
          value: _valueRating > 0 ? _valueRating : null,
        ),
        comment: ReviewComment(
          en: _commentController.text,
          sw: _commentController.text,
        ),
      );

      // Submit review
      final success = await reviewProvider.createReview(reviewData);
      
      if (!mounted) return;
      
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(reviewProvider.error ?? 'Failed to submit review'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide an overall rating'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Write a Review'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Overall Rating
              Text(
                'Overall Rating',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Center(
                child: RatingBar.builder(
                  initialRating: 0,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: false,
                  itemCount: 5,
                  itemSize: 50,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    setState(() {
                      _overallRating = rating;
                    });
                  },
                ),
              ),

              const Divider(height: 40),

              // Category Ratings
              Text(
                'Rate Your Experience',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),

              _buildRatingCategory('Cleanliness', _cleanlinessRating, (rating) {
                setState(() => _cleanlinessRating = rating);
              }),

              _buildRatingCategory('Accuracy', _accuracyRating, (rating) {
                setState(() => _accuracyRating = rating);
              }),

              _buildRatingCategory('Communication', _communicationRating, (rating) {
                setState(() => _communicationRating = rating);
              }),

              _buildRatingCategory('Location', _locationRating, (rating) {
                setState(() => _locationRating = rating);
              }),

              _buildRatingCategory('Check-in', _checkInRating, (rating) {
                setState(() => _checkInRating = rating);
              }),

              _buildRatingCategory('Value', _valueRating, (rating) {
                setState(() => _valueRating = rating);
              }),

              const Divider(height: 40),

              // Written Review
              Text(
                'Write Your Review',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _commentController,
                maxLines: 6,
                decoration: const InputDecoration(
                  hintText: 'Tell us about your experience...',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please write a review';
                  }
                  if (value.length < 20) {
                    return 'Review must be at least 20 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // Submit Button
              Consumer<ReviewProvider>(
                builder: (context, reviewProvider, child) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: reviewProvider.isSubmitting ? null : _submitReview,
                      child: reviewProvider.isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Submit Review'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingCategory(
    String label,
    double rating,
    Function(double) onRatingUpdate,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
          RatingBar.builder(
            initialRating: rating,
            minRating: 0,
            direction: Axis.horizontal,
            allowHalfRating: false,
            itemCount: 5,
            itemSize: 30,
            unratedColor: Colors.grey.shade300,
            itemBuilder: (context, _) => const Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: onRatingUpdate,
          ),
        ],
      ),
    );
  }
}




















