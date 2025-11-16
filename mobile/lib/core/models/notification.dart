class AppNotification {
  final String id;
  final String title;
  final String body;
  final String type;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.data,
    required this.createdAt,
    this.isRead = false,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: json['type'] ?? 'general',
      data: json['data'] ?? {},
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
    };
  }

  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    String? type,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  String get icon {
    switch (type) {
      case 'booking_confirmed':
        return '🎉';
      case 'new_booking':
        return '📬';
      case 'booking_cancelled':
        return '❌';
      case 'checkin_reminder':
        return '🏠';
      case 'review_request':
        return '⭐';
      case 'new_review':
        return '⭐';
      case 'review_response':
        return '💬';
      case 'payment_confirmed':
        return '✅';
      case 'price_drop':
        return '💰';
      case 'special_offer':
        return '🎁';
      default:
        return '🔔';
    }
  }

  String get routeName {
    final screen = data['screen'];
    if (screen != null) {
      switch (screen.toString()) {
        case 'BookingDetail':
          return '/booking-detail';
        case 'ListingDetail':
          return '/listing-detail';
        case 'WriteReview':
          return '/write-review';
        case 'ListingReviews':
          return '/listing-reviews';
        case 'HostBookings':
          return '/host-bookings';
        case 'Offers':
          return '/offers';
        default:
          return '/home';
      }
    }
    return '/home';
  }
}

class NotificationPreferences {
  final bool push;
  final bool email;
  final bool sms;

  NotificationPreferences({
    required this.push,
    required this.email,
    required this.sms,
  });

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      push: json['push'] ?? true,
      email: json['email'] ?? true,
      sms: json['sms'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'push': push,
      'email': email,
      'sms': sms,
    };
  }

  NotificationPreferences copyWith({
    bool? push,
    bool? email,
    bool? sms,
  }) {
    return NotificationPreferences(
      push: push ?? this.push,
      email: email ?? this.email,
      sms: sms ?? this.sms,
    );
  }
}






