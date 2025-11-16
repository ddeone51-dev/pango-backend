import 'package:flutter/material.dart';
import '../models/listing.dart';
import '../services/api_service.dart';

class ListingProvider with ChangeNotifier {
  final ApiService apiService;
  
  List<Listing> _listings = [];
  List<Listing> _featuredListings = [];
  List<Listing> _nearbyListings = [];
  List<Listing> _hostListings = [];
  Listing? _selectedListing;
  bool _isLoading = false;
  String? _error;
  
  ListingProvider({required this.apiService});
  
  List<Listing> get listings => _listings;
  List<Listing> get featuredListings => _featuredListings;
  List<Listing> get nearbyListings => _nearbyListings;
  List<Listing> get hostListings => _hostListings;
  Listing? get selectedListing => _selectedListing;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> fetchListings({
    String? location,
    double? lat,
    double? lng,
    int? guests,
    String? propertyType,
    double? minPrice,
    double? maxPrice,
    List<String>? amenities,
  }) async {
    print('🏠 FETCHING LISTINGS - Starting...');
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final queryParams = <String, dynamic>{};
      if (location != null) queryParams['location'] = location;
      if (lat != null) queryParams['lat'] = lat;
      if (lng != null) queryParams['lng'] = lng;
      if (guests != null) queryParams['guests'] = guests;
      if (propertyType != null) queryParams['propertyType'] = propertyType;
      if (minPrice != null) queryParams['minPrice'] = minPrice;
      if (maxPrice != null) queryParams['maxPrice'] = maxPrice;
      if (amenities != null && amenities.isNotEmpty) {
        queryParams['amenities'] = amenities.join(',');
      }
      
      print('🏠 FETCHING LISTINGS - Making API call...');
      final response = await apiService.get('/listings', queryParameters: queryParams);
      print('🏠 FETCHING LISTINGS - API response: ${response.data}');
      
      if (response.data['success']) {
        _listings = (response.data['data']['listings'] as List)
            .map((json) => Listing.fromJson(json))
            .toList();
        print('🏠 FETCHING LISTINGS - Found ${_listings.length} listings');
      } else {
        print('🏠 FETCHING LISTINGS - API returned success: false');
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('🏠 FETCHING LISTINGS - ERROR: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> fetchFeaturedListings() async {
    try {
      final response = await apiService.get('/listings/featured');
      
      if (response.data['success']) {
        _featuredListings = (response.data['data'] as List)
            .map((json) => Listing.fromJson(json))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching featured listings: $e');
    }
  }
  
  Future<void> fetchNearbyListings(double lat, double lng, {double radius = 50}) async {
    try {
      final response = await apiService.get(
        '/listings/nearby',
        queryParameters: {
          'lat': lat,
          'lng': lng,
          'radius': radius,
        },
      );
      
      if (response.data['success']) {
        _nearbyListings = (response.data['data'] as List)
            .map((json) => Listing.fromJson(json))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching nearby listings: $e');
    }
  }
  
  Future<void> fetchListingById(String id) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final response = await apiService.get('/listings/$id');
      
      if (response.data['success']) {
        _selectedListing = Listing.fromJson(response.data['data']);
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchHostListings(String hostId) async {
    print('🏠 FETCHING HOST LISTINGS - Starting for host: $hostId');
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      print('🏠 FETCHING HOST LISTINGS - Making API call...');
      final response = await apiService.get('/listings/host/$hostId');
      print('🏠 FETCHING HOST LISTINGS - API response: ${response.data}');
      
      if (response.data['success']) {
        _hostListings = (response.data['data'] as List)
            .map((json) => Listing.fromJson(json))
            .toList();
        print('🏠 FETCHING HOST LISTINGS - Found ${_hostListings.length} host listings');
      } else {
        print('🏠 FETCHING HOST LISTINGS - API returned success: false');
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('🏠 FETCHING HOST LISTINGS - ERROR: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void clearSelectedListing() {
    _selectedListing = null;
    notifyListeners();
  }
  
  Future<bool> createListing(Map<String, dynamic> listingData) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final response = await apiService.post('/listings', data: listingData);
      
      if (response.data['success']) {
        // Add the new listing to the list
        final newListing = Listing.fromJson(response.data['data']);
        _listings.insert(0, newListing);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      _error = 'Failed to create listing';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> updateListing(String id, Map<String, dynamic> listingData) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final response = await apiService.put('/listings/$id', data: listingData);
      
      if (response.data['success']) {
        // Update the listing in the list
        final updatedListing = Listing.fromJson(response.data['data']);
        final index = _listings.indexWhere((l) => l.id == id);
        if (index != -1) {
          _listings[index] = updatedListing;
        }
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      _error = 'Failed to update listing';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> deleteListing(String id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final response = await apiService.delete('/listings/$id');
      
      if (response.data['success']) {
        // Remove the listing from the list
        _listings.removeWhere((l) => l.id == id);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      _error = 'Failed to delete listing';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}


