class Booking {
  final String id;
  final String listingId;
  final String guestId;
  final String hostId;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int numberOfGuests;
  final BookingPricing pricing;
  final String status;
  final PaymentInfo payment;
  final DateTime createdAt;
  final bool checkInConfirmed;
  final BookingPayout? payout;
  final BookingArrival? arrival;
  
  Booking({
    required this.id,
    required this.listingId,
    required this.guestId,
    required this.hostId,
    required this.checkInDate,
    required this.checkOutDate,
    required this.numberOfGuests,
    required this.pricing,
    required this.status,
    required this.payment,
    required this.createdAt,
    required this.checkInConfirmed,
    this.payout,
    this.arrival,
  });
  
  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['_id'] ?? json['id'],
      listingId: json['listingId'] is String ? json['listingId'] : json['listingId']['_id'],
      guestId: json['guestId'] is String ? json['guestId'] : json['guestId']['_id'],
      hostId: json['hostId'] is String ? json['hostId'] : json['hostId']['_id'],
      checkInDate: DateTime.parse(json['checkInDate']),
      checkOutDate: DateTime.parse(json['checkOutDate']),
      numberOfGuests: json['numberOfGuests'],
      pricing: BookingPricing.fromJson(json['pricing']),
      status: json['status'],
      payment: PaymentInfo.fromJson(json['payment']),
      createdAt: DateTime.parse(json['createdAt']),
      checkInConfirmed: json['checkInConfirmed'] ?? false,
      payout: json['payout'] != null ? BookingPayout.fromJson(json['payout']) : null,
      arrival: json['arrival'] != null ? BookingArrival.fromJson(json['arrival']) : null,
    );
  }
  
  int get numberOfNights => checkOutDate.difference(checkInDate).inDays;

  bool get requiresArrivalConfirmation {
    if (checkInConfirmed) return false;
    if (arrival == null) return false;
    return arrival!.requiresConfirmation ?? false;
  }
}

class BookingPricing {
  final double nightlyRate;
  final int numberOfNights;
  final double subtotal;
  final double cleaningFee;
  final double serviceFee;
  final double taxes;
  final double total;
  final String currency;
  
  BookingPricing({
    required this.nightlyRate,
    required this.numberOfNights,
    required this.subtotal,
    required this.cleaningFee,
    required this.serviceFee,
    required this.taxes,
    required this.total,
    required this.currency,
  });
  
  factory BookingPricing.fromJson(Map<String, dynamic> json) {
    return BookingPricing(
      nightlyRate: (json['nightlyRate'] ?? 0).toDouble(),
      numberOfNights: json['numberOfNights'] ?? 0,
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      cleaningFee: (json['cleaningFee'] ?? 0).toDouble(),
      serviceFee: (json['serviceFee'] ?? 0).toDouble(),
      taxes: (json['taxes'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'TZS',
    );
  }
}

class PaymentInfo {
  final String method;
  final String status;
  final String? transactionId;
  final DateTime? paidAt;
  
  PaymentInfo({
    required this.method,
    required this.status,
    this.transactionId,
    this.paidAt,
  });
  
  factory PaymentInfo.fromJson(Map<String, dynamic> json) {
    return PaymentInfo(
      method: json['method'],
      status: json['status'],
      transactionId: json['transactionId'],
      paidAt: json['paidAt'] != null ? DateTime.parse(json['paidAt']) : null,
    );
  }
}

class BookingPayout {
  final String status;
  final double hostAmount;
  final double platformFee;
  final String currency;
  final DateTime? autoReleaseAt;

  BookingPayout({
    required this.status,
    required this.hostAmount,
    required this.platformFee,
    required this.currency,
    this.autoReleaseAt,
  });

  factory BookingPayout.fromJson(Map<String, dynamic> json) {
    return BookingPayout(
      status: json['status'] ?? 'pending',
      hostAmount: (json['hostAmount'] ?? 0).toDouble(),
      platformFee: (json['platformFee'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'TZS',
      autoReleaseAt: json['autoReleaseAt'] != null ? DateTime.parse(json['autoReleaseAt']) : null,
    );
  }
}

class BookingArrival {
  final bool? requiresConfirmation;
  final DateTime? confirmedAt;
  final DateTime? autoConfirmedAt;

  BookingArrival({
    this.requiresConfirmation,
    this.confirmedAt,
    this.autoConfirmedAt,
  });

  factory BookingArrival.fromJson(Map<String, dynamic> json) {
    return BookingArrival(
      requiresConfirmation: json['requiresConfirmation'],
      confirmedAt: json['confirmedAt'] != null ? DateTime.parse(json['confirmedAt']) : null,
      autoConfirmedAt: json['autoConfirmedAt'] != null ? DateTime.parse(json['autoConfirmedAt']) : null,
    );
  }
}
























