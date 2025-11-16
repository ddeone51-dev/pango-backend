import 'package:flutter/material.dart';
import '../models/host_calendar_models.dart';
import '../services/api_service.dart';

class HostCalendarProvider with ChangeNotifier {
  HostCalendarProvider({required this.apiService});

  final ApiService apiService;

  final List<HostCalendarListing> _listings = [];
  bool _isLoading = false;
  String? _error;

  List<HostCalendarListing> get listings => List.unmodifiable(_listings);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCalendar() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await apiService.get('/bookings/host/calendar');
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] as List<dynamic>;
        _listings
          ..clear()
          ..addAll(data.map((item) => _parseListing(item as Map<String, dynamic>)));
      } else {
        _error = response.data['message']?.toString() ?? 'Failed to load calendar';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> blockDateRange({
    required String listingId,
    required DateTime start,
    required DateTime end,
    String? reason,
  }) async {
    try {
      final response = await apiService.post(
        '/listings/$listingId/availability/block',
        data: {
          'startDate': start.toIso8601String(),
          'endDate': end.toIso8601String(),
          if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
        },
      );

      if (response.data['success'] == true) {
        await fetchCalendar();
        return true;
      }

      _error = response.data['message']?.toString() ?? 'Failed to block dates';
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> unblockDate({
    required String listingId,
    required String blockId,
  }) async {
    try {
      final response = await apiService.delete('/listings/$listingId/availability/block/$blockId');

      if (response.data['success'] == true) {
        await fetchCalendar();
        return true;
      }

      _error = response.data['message']?.toString() ?? 'Failed to remove blocked dates';
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  HostCalendarListing? getListingById(String id) {
    try {
      return _listings.firstWhere((listing) => listing.listingId == id);
    } catch (_) {
      return null;
    }
  }

  HostCalendarListing _parseListing(Map<String, dynamic> json) {
    return HostCalendarListing(
      listingId: json['listingId']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Listing',
      location: json['location']?.toString() ?? '',
      instantBooking: json['instantBooking'] == true,
      bookings: (json['bookings'] as List<dynamic>? ?? [])
          .map((item) => _parseBooking(item as Map<String, dynamic>))
          .toList(),
      blockedDates: (json['blockedDates'] as List<dynamic>? ?? [])
          .map((item) => _parseBlockedDate(item as Map<String, dynamic>))
          .toList(),
    );
  }

  HostBookingEvent _parseBooking(Map<String, dynamic> json) {
    return HostBookingEvent(
      id: json['id']?.toString() ?? '',
      start: DateTime.tryParse(json['start']?.toString() ?? '') ?? DateTime.now(),
      end: DateTime.tryParse(json['end']?.toString() ?? '') ?? DateTime.now(),
      status: json['status']?.toString() ?? 'UNKNOWN',
      guestName: json['guestName']?.toString() ?? 'Guest',
      guestEmail: json['guestEmail']?.toString(),
      guestPhone: json['guestPhone']?.toString(),
    );
  }

  HostBlockedDate _parseBlockedDate(Map<String, dynamic> json) {
    return HostBlockedDate(
      id: json['id']?.toString() ?? '',
      start: DateTime.tryParse(json['start']?.toString() ?? '') ?? DateTime.now(),
      end: DateTime.tryParse(json['end']?.toString() ?? '') ?? DateTime.now(),
      reason: json['reason']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }
}



