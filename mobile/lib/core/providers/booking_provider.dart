import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/booking.dart';
import '../services/api_service.dart';
import '../services/zenopay_service.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

class BookingProvider with ChangeNotifier {
  final ApiService apiService;
  final ZenoPayService zenopayService;

  BookingProvider({required this.apiService, required this.zenopayService});

  final List<Booking> _bookings = [];
  Booking? _selectedBooking;
  bool _isLoading = false;
  String? _error;

  List<Booking> get bookings => _bookings;
  Booking? get selectedBooking => _selectedBooking;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> createBooking({
    required String listingId,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required int numberOfGuests,
    required Map<String, dynamic> guestDetails,
    required double totalAmount,
    required String phoneNumber,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      return await _processPaymentAndCreateBooking(
        listingId: listingId,
        checkInDate: checkInDate,
        checkOutDate: checkOutDate,
        numberOfGuests: numberOfGuests,
        guestDetails: guestDetails,
        totalAmount: totalAmount,
        phoneNumber: phoneNumber,
      );
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> _processPaymentAndCreateBooking({
    required String listingId,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required int numberOfGuests,
    required Map<String, dynamic> guestDetails,
    required double totalAmount,
    required String phoneNumber,
  }) async {
    try {
      final orderId = 'HOMIA_${DateTime.now().millisecondsSinceEpoch}';

      // Resolve hostId from listing (fallback to a known host)
      String resolvedHostId = '68e98ebf924dda17abf985c9';
      bool hostFound = false;
      try {
        final listingRes = await apiService.get('/listings/$listingId');
        final data = listingRes.data['data'] ?? listingRes.data;
        final dynamic host = data['hostId'];
        if (host is String && host.isNotEmpty) {
          resolvedHostId = host;
          hostFound = true;
        } else if (host is Map && host['_id'] is String && (host['_id'] as String).isNotEmpty) {
          resolvedHostId = host['_id'];
          hostFound = true;
        }
      } catch (_) {}

      // Backend sets hostId from listing.hostId and ignores body hostId.
      // If the listing has no hostId, abort early to avoid 400.
      if (!hostFound) {
        _error = 'This demo listing cannot be booked. Please choose another property.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Prepare buyer phone (local format)
      String providedPhone = (guestDetails['phoneNumber']?.toString() ?? phoneNumber).trim();
      final buyerPhoneLocal = providedPhone.startsWith('+255')
          ? providedPhone.replaceFirst('+255', '0')
          : providedPhone;
      if (buyerPhoneLocal.isEmpty || !buyerPhoneLocal.startsWith('0') || buyerPhoneLocal.length != 10) {
        _error = 'Enter a valid Tanzanian phone (07XXXXXXXX) in guest details.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // 1) Create booking immediately (pending) so we can show awaiting screen
      final bookingData = {
        'listingId': listingId,
        'checkInDate': checkInDate.toIso8601String(),
        'checkOutDate': checkOutDate.toIso8601String(),
        'numberOfGuests': numberOfGuests,
        'guestDetails': guestDetails,
        'paymentMethod': 'zenopay',
        'transactionId': orderId,
        'orderId': orderId,
        'hostId': resolvedHostId,
      };

      final response = await apiService.post(
        '/bookings',
        data: bookingData,
        options: Options(
          contentType: Headers.jsonContentType,
          responseType: ResponseType.json,
        ),
      );

      if (response.data['success']) {
        _selectedBooking = Booking.fromJson(response.data['data']);
        _isLoading = false;
        notifyListeners();

        // 2) Fire-and-forget: initiate ZenoPay now; SIM prompt will arrive while user is on Awaiting screen
        final createdId = _selectedBooking!.id;
        // ignore: unawaited_futures
        () async {
          try {
            final paymentResult = await zenopayService.initiatePayment(
              orderId: orderId,
              buyerName: (guestDetails['fullName'] ?? 'Guest').toString(),
              buyerEmail: (guestDetails['email'] ?? '').toString(),
              buyerPhone: buyerPhoneLocal,
              amount: totalAmount.toInt().toDouble(),
              webhookUrl: 'https://pango-backend.onrender.com/api/v1/payments/zenopay-webhook',
            );
            // ignore: avoid_print
            print('ZENOPAY INIT RESULT: $paymentResult | phone: $buyerPhoneLocal');
            // Start background status watcher
            await _awaitPaymentAndConfirm(createdId, orderId);
            
            // Manual fallback: If webhook doesn't work, check status after 30 seconds
            Future.delayed(const Duration(seconds: 30), () async {
              try {
                final statusResult = await zenopayService.checkOrderStatus(orderId);
                print('MANUAL STATUS CHECK: $statusResult');
                
                // Extract payment status from the data array
                String paymentStatus = '';
                if (statusResult['data'] is List && (statusResult['data'] as List).isNotEmpty) {
                  final data = (statusResult['data'] as List)[0];
                  paymentStatus = (data['payment_status'] ?? '').toString().toUpperCase();
                } else {
                  paymentStatus = (statusResult['payment_status'] ?? statusResult['status'] ?? '').toString().toUpperCase();
                }
                print('MANUAL PAYMENT STATUS: $paymentStatus');
                
                if (paymentStatus == 'COMPLETED') {
                  // Manually confirm booking payment
                  try {
                    await apiService.put('/bookings/$createdId/payment-confirm');
                    print('✅ Manual payment confirmation successful');
                  } catch (e) {
                    print('❌ Manual payment confirmation failed: $e');
                  }
                }
              } catch (e) {
                print('MANUAL STATUS CHECK ERROR: $e');
              }
            });
          } catch (e) {
            // ignore: avoid_print
            print('ZENOPAY INIT ERROR: $e');
          }
        }();
        return true;
      } else {
        _error = response.data['message'] ?? 'Booking creation failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Payment processing failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // List and manage bookings used by UI screens
  Future<void> fetchBookings({String? role}) async {
    try {
      _isLoading = true;
      notifyListeners();

      final queryParams = role != null ? {'role': role} : null;
      final response = await apiService.get('/bookings', queryParameters: queryParams);

      if (response.data['success'] == true) {
        final data = response.data['data'] as List;
        print('📋 FETCH BOOKINGS - Received ${data.length} bookings from API');
        print('📋 FETCH BOOKINGS - Data: $data');
        _bookings.clear();
        _bookings.addAll(data.map((json) => Booking.fromJson(json)));
        print('📋 FETCH BOOKINGS - Local bookings list now has ${_bookings.length} items');
      } else {
        print('📋 FETCH BOOKINGS - API returned success: false');
        _error = response.data['message']?.toString();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchBookingById(String id) async {
    try {
      final response = await apiService.get('/bookings/$id');
      if (response.data['success'] == true) {
        _selectedBooking = Booking.fromJson(response.data['data']);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> cancelBooking(String bookingId, String reason) async {
    try {
      final response = await apiService.put('/bookings/$bookingId/cancel', data: {
        'reason': reason,
      });
      if (response.data['success'] == true) {
        await fetchBookings();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<Map<String, dynamic>> confirmArrival(String bookingId) async {
    try {
      final response = await apiService.put('/bookings/$bookingId/confirm-arrival');
      final success = response.data['success'] != false;
      final message = response.data['message']?.toString() ??
          (success ? 'Arrival confirmed' : 'Arrival confirmed but payout pending');
      await fetchBookings();
      return {'success': success, 'message': message};
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return {
        'success': false,
        'message': _error ?? 'Failed to confirm arrival',
      };
    }
  }

  // Poll ZenoPay and confirm booking upon completion
  Future<void> _awaitPaymentAndConfirm(String bookingId, String orderId) async {
    try {
      for (int i = 0; i < 24; i++) { // up to ~2 minutes
        await Future.delayed(const Duration(seconds: 5));
        try {
          final status = await zenopayService.checkOrderStatus(orderId);
          print('ZENOPAY STATUS CHECK #$i: $status');
          
          // Extract payment status from the data array
          String paymentStatus = '';
          if (status['data'] is List && (status['data'] as List).isNotEmpty) {
            final data = (status['data'] as List)[0];
            paymentStatus = (data['payment_status'] ?? '').toString().toUpperCase();
          } else {
            paymentStatus = (status['payment_status'] ?? status['status'] ?? '').toString().toUpperCase();
          }
          print('PAYMENT STATUS: $paymentStatus');
          if (paymentStatus == 'COMPLETED') {
            // Attempt to confirm booking on backend (if endpoint exists)
            try {
              await apiService.put('/bookings/$bookingId/payment-confirm');
            } catch (_) {
              // If endpoint not available, just refresh bookings
            }
            // Refresh selected booking
            await fetchBookingById(bookingId);
            break;
          }
        } catch (e) {
          print('ZENOPAY STATUS CHECK ERROR #$i: $e');
          // ignore transient errors and continue polling
        }
      }
    } catch (_) {}
  }

  Future<File?> downloadReceipt(String bookingId) async {
    try {
      _error = null;
      final response = await apiService.get(
        '/bookings/$bookingId/receipt',
        options: Options(responseType: ResponseType.bytes),
      );

      final data = response.data;
      late final List<int> bytes;
      if (data is List<int>) {
        bytes = data;
      } else if (data is Uint8List) {
        bytes = data.toList();
      } else {
        throw Exception('Invalid receipt data');
      }
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/homia-receipt-$bookingId.pdf');

      await file.writeAsBytes(bytes, flush: true);
      await OpenFilex.open(file.path);

      return file;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }
}
