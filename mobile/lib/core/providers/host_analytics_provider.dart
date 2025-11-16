import 'package:flutter/material.dart';
import '../models/host_analytics_models.dart';
import '../services/api_service.dart';

class HostAnalyticsProvider with ChangeNotifier {
  HostAnalyticsProvider({required this.apiService});

  final ApiService apiService;

  HostAnalyticsData? _analytics;
  bool _isLoading = false;
  String? _error;
  int _rangeDays = 30;

  HostAnalyticsData? get analytics => _analytics;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get rangeDays => _rangeDays;

  Future<void> fetchAnalytics({int? range}) async {
    try {
      _isLoading = true;
      _error = null;
      if (range != null) {
        _rangeDays = range;
      }
      notifyListeners();

      final response = await apiService.get(
        '/bookings/host/analytics',
        queryParameters: {
          'range': _rangeDays,
        },
      );

      if (response.data['success'] == true) {
        _analytics = _parseAnalytics(response.data['data'] as Map<String, dynamic>);
      } else {
        _error = response.data['message']?.toString() ?? 'Failed to load analytics';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  HostAnalyticsData _parseAnalytics(Map<String, dynamic> json) {
    final totals = json['totals'] as Map<String, dynamic>? ?? {};
    final revenue = json['revenue'] as Map<String, dynamic>? ?? {};
    final topListings = (json['topListings'] as List<dynamic>? ?? [])
        .map((item) {
          final data = item as Map<String, dynamic>;
          return HostTopListing(
            listingId: data['listingId']?.toString() ?? '',
            title: data['title']?.toString() ?? 'Listing',
            bookings: data['bookings'] is num ? (data['bookings'] as num).toInt() : 0,
            revenue: data['revenue'] is num ? (data['revenue'] as num).toDouble() : 0,
          );
        })
        .toList();

    final monthlyTrend = (json['monthlyTrend'] as List<dynamic>? ?? [])
        .map((item) {
          final data = item as Map<String, dynamic>;
          return HostMonthlyTrend(
            label: data['label']?.toString() ?? '',
            bookings: data['bookings'] is num ? (data['bookings'] as num).toInt() : 0,
            revenue: data['revenue'] is num ? (data['revenue'] as num).toDouble() : 0,
          );
        })
        .toList();

    return HostAnalyticsData(
      totalBookings: totals['totalBookings'] is num ? (totals['totalBookings'] as num).toInt() : 0,
      upcomingBookings: totals['upcomingBookings'] is num ? (totals['upcomingBookings'] as num).toInt() : 0,
      completedBookings: totals['completedBookings'] is num ? (totals['completedBookings'] as num).toInt() : 0,
      cancelledBookings: totals['cancelledBookings'] is num ? (totals['cancelledBookings'] as num).toInt() : 0,
      totalRevenue: revenue['total'] is num ? (revenue['total'] as num).toDouble() : 0,
      rangeRevenue: revenue['range'] is num ? (revenue['range'] as num).toDouble() : 0,
      occupancyRate: json['occupancyRate'] is num ? (json['occupancyRate'] as num).toDouble() : 0,
      averageStay: json['averageStay'] is num ? (json['averageStay'] as num).toDouble() : 0,
      rangeDays: json['rangeDays'] is num ? (json['rangeDays'] as num).toInt() : _rangeDays,
      topListings: topListings,
      monthlyTrend: monthlyTrend,
    );
  }
}



