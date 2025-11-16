import 'package:flutter/material.dart';
import '../models/review.dart';
import '../models/booking.dart';
import '../services/api_service.dart';

class ReviewProvider with ChangeNotifier {
  final ApiService apiService;
  
  List<Review> _listingReviews = [];
  List<Review> _myReviews = [];
  List<Review> _reviewsAboutMe = [];
  List<Booking> _eligibleBookings = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;
  
  ReviewProvider({required this.apiService});
  
  List<Review> get listingReviews => _listingReviews;
  List<Review> get myReviews => _myReviews;
  List<Review> get reviewsAboutMe => _reviewsAboutMe;
  List<Booking> get eligibleBookings => _eligibleBookings;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;
  
  // Fetch reviews for a specific listing
  Future<void> fetchListingReviews(String listingId, {int page = 1, int limit = 10}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final response = await apiService.get(
        '/reviews/listing/$listingId',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );
      
      if (response.data['success']) {
        _listingReviews = (response.data['data'] as List)
            .map((json) => Review.fromJson(json))
            .toList();
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Fetch user's own reviews
  Future<void> fetchMyReviews() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final response = await apiService.get('/reviews/my-reviews');
      
      if (response.data['success']) {
        _myReviews = (response.data['data'] as List)
            .map((json) => Review.fromJson(json))
            .toList();
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Fetch reviews about the user
  Future<void> fetchReviewsAboutMe() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final response = await apiService.get('/reviews/about-me');
      
      if (response.data['success']) {
        _reviewsAboutMe = (response.data['data'] as List)
            .map((json) => Review.fromJson(json))
            .toList();
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Fetch bookings eligible for review
  Future<void> fetchEligibleBookings() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final response = await apiService.get('/reviews/eligible-bookings');
      
      if (response.data['success']) {
        _eligibleBookings = (response.data['data'] as List)
            .map((json) => Booking.fromJson(json))
            .toList();
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Create a new review
  Future<bool> createReview(CreateReviewData reviewData) async {
    try {
      _isSubmitting = true;
      _error = null;
      notifyListeners();
      
      final response = await apiService.post(
        '/reviews',
        data: reviewData.toJson(),
      );
      
      _isSubmitting = false;
      
      if (response.data['success']) {
        // Refresh eligible bookings to remove the reviewed one
        await fetchEligibleBookings();
        notifyListeners();
        return true;
      } else {
        _error = response.data['message'] ?? 'Failed to submit review';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }
  
  // Mark review as helpful
  Future<bool> markHelpful(String reviewId) async {
    try {
      final response = await apiService.put('/reviews/$reviewId/helpful');
      
      if (response.data['success']) {
        // Update the review in the list
        final reviewIndex = _listingReviews.indexWhere((r) => r.id == reviewId);
        if (reviewIndex != -1) {
          _listingReviews[reviewIndex] = Review.fromJson(response.data['data']);
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  // Add a response to a review (hosts only)
  Future<bool> respondToReview(String reviewId, String responseText) async {
    try {
      _isSubmitting = true;
      notifyListeners();
      
      final response = await apiService.put(
        '/reviews/$reviewId/respond',
        data: {'text': responseText},
      );
      
      _isSubmitting = false;
      
      if (response.data['success']) {
        // Update the review in reviewsAboutMe
        final reviewIndex = _reviewsAboutMe.indexWhere((r) => r.id == reviewId);
        if (reviewIndex != -1) {
          _reviewsAboutMe[reviewIndex] = Review.fromJson(response.data['data']);
        }
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }
  
  // Delete a review
  Future<bool> deleteReview(String reviewId) async {
    try {
      final response = await apiService.delete('/reviews/$reviewId');
      
      if (response.data['success']) {
        // Remove from lists
        _myReviews.removeWhere((r) => r.id == reviewId);
        _listingReviews.removeWhere((r) => r.id == reviewId);
        _reviewsAboutMe.removeWhere((r) => r.id == reviewId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  // Clear reviews when logging out
  void clear() {
    _listingReviews = [];
    _myReviews = [];
    _reviewsAboutMe = [];
    _eligibleBookings = [];
    _isLoading = false;
    _isSubmitting = false;
    _error = null;
    notifyListeners();
  }
}






