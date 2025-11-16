class HostAnalyticsData {
  HostAnalyticsData({
    required this.totalBookings,
    required this.upcomingBookings,
    required this.completedBookings,
    required this.cancelledBookings,
    required this.totalRevenue,
    required this.rangeRevenue,
    required this.occupancyRate,
    required this.averageStay,
    required this.rangeDays,
    required this.topListings,
    required this.monthlyTrend,
  });

  final int totalBookings;
  final int upcomingBookings;
  final int completedBookings;
  final int cancelledBookings;
  final double totalRevenue;
  final double rangeRevenue;
  final double occupancyRate;
  final double averageStay;
  final int rangeDays;
  final List<HostTopListing> topListings;
  final List<HostMonthlyTrend> monthlyTrend;
}

class HostTopListing {
  HostTopListing({
    required this.listingId,
    required this.title,
    required this.bookings,
    required this.revenue,
  });

  final String listingId;
  final String title;
  final int bookings;
  final double revenue;
}

class HostMonthlyTrend {
  HostMonthlyTrend({
    required this.label,
    required this.bookings,
    required this.revenue,
  });

  final String label;
  final int bookings;
  final double revenue;
}



