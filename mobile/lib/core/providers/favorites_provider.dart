import 'package:flutter/material.dart';
import '../models/listing.dart';
import '../services/api_service.dart';

class FavoritesProvider with ChangeNotifier {
  final ApiService apiService;
  
  List<Listing> _favorites = [];
  Set<String> _favoriteIds = {};
  bool _isLoading = false;
  String? _error;
  
  FavoritesProvider({required this.apiService});
  
  List<Listing> get favorites => _favorites;
  Set<String> get favoriteIds => _favoriteIds;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  bool isFavorite(String listingId) {
    return _favoriteIds.contains(listingId);
  }
  
  Future<void> fetchFavorites() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final response = await apiService.get('/users/saved-listings');
      
      if (response.data['success']) {
        _favorites = (response.data['data'] as List)
            .map((json) => Listing.fromJson(json))
            .toList();
        _favoriteIds = _favorites.map((l) => l.id).toSet();
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> toggleFavorite(String listingId) async {
    try {
      final wasFavorite = _favoriteIds.contains(listingId);
      
      // Optimistically update UI
      if (wasFavorite) {
        _favoriteIds.remove(listingId);
        _favorites.removeWhere((l) => l.id == listingId);
      } else {
        _favoriteIds.add(listingId);
      }
      notifyListeners();
      
      // Make API call
      final response = wasFavorite
          ? await apiService.delete('/users/saved-listings/$listingId')
          : await apiService.post('/users/saved-listings/$listingId');
      
      if (response.data['success']) {
        // If adding to favorites, fetch the full list to get listing details
        if (!wasFavorite) {
          await fetchFavorites();
        }
        return true;
      } else {
        // Revert on failure
        if (wasFavorite) {
          _favoriteIds.add(listingId);
        } else {
          _favoriteIds.remove(listingId);
        }
        notifyListeners();
        return false;
      }
    } catch (e) {
      // Revert on error
      final wasFavorite = !_favoriteIds.contains(listingId);
      if (wasFavorite) {
        _favoriteIds.add(listingId);
      } else {
        _favoriteIds.remove(listingId);
      }
      notifyListeners();
      _error = e.toString();
      return false;
    }
  }
}











