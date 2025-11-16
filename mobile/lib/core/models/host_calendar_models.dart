class HostCalendarEvent {
  HostCalendarEvent({
    required this.id,
    required this.start,
    required this.end,
    required this.type,
    this.status,
    this.guestName,
    this.guestEmail,
    this.guestPhone,
    this.reason,
  });

  final String id;
  final DateTime start;
  final DateTime end;
  final HostCalendarEventType type;
  final String? status;
  final String? guestName;
  final String? guestEmail;
  final String? guestPhone;
  final String? reason;
}

enum HostCalendarEventType {
  booking,
  blocked,
}

class HostCalendarListing {
  HostCalendarListing({
    required this.listingId,
    required this.title,
    required this.location,
    required this.instantBooking,
    required this.bookings,
    required this.blockedDates,
  });

  final String listingId;
  final String title;
  final String location;
  final bool instantBooking;
  final List<HostBookingEvent> bookings;
  final List<HostBlockedDate> blockedDates;
}

class HostBookingEvent {
  HostBookingEvent({
    required this.id,
    required this.start,
    required this.end,
    required this.status,
    required this.guestName,
    this.guestEmail,
    this.guestPhone,
  });

  final String id;
  final DateTime start;
  final DateTime end;
  final String status;
  final String guestName;
  final String? guestEmail;
  final String? guestPhone;
}

class HostBlockedDate {
  HostBlockedDate({
    required this.id,
    required this.start,
    required this.end,
    this.reason,
    this.createdAt,
  });

  final String id;
  final DateTime start;
  final DateTime end;
  final String? reason;
  final DateTime? createdAt;
}



