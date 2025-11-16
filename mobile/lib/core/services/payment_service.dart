import 'package:dio/dio.dart';
import '../config/environment.dart';

class PaymentService {
  final Dio _dio;

  PaymentService(this._dio);

  /// Initiate Pesapal payment
  Future<Map<String, dynamic>> initiatePayment({
    required String listingId,
    required String bookingId,
    required String paymentMethod,
    required String customerPhone,
    required String customerEmail,
    String? customerFirstName,
    String? customerLastName,
    String? customerAddress,
    String? customerCity,
    String? customerRegion,
  }) async {
    try {
      final response = await _dio.post(
        '/payments/initiate',
        data: {
          'listingId': listingId,
          'bookingId': bookingId,
          'paymentMethod': paymentMethod,
          'customerPhone': customerPhone,
          'customerEmail': customerEmail,
          if (customerFirstName != null) 'customerFirstName': customerFirstName,
          if (customerLastName != null) 'customerLastName': customerLastName,
          if (customerAddress != null) 'customerAddress': customerAddress,
          if (customerCity != null) 'customerCity': customerCity,
          if (customerRegion != null) 'customerRegion': customerRegion,
        },
      );

      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Failed to initiate payment');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final message = e.response?.data['message'] ?? 'Failed to initiate payment';
        throw Exception(message);
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to initiate payment: $e');
    }
  }

  /// Get payment status
  Future<Map<String, dynamic>> getPaymentStatus(String paymentId) async {
    try {
      final response = await _dio.get('/payments/$paymentId/status');

      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Failed to get payment status');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final message = e.response?.data['message'] ?? 'Failed to get payment status';
        throw Exception(message);
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get payment status: $e');
    }
  }

  /// Get payment history
  Future<Map<String, dynamic>> getPaymentHistory({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _dio.get(
        '/payments/history',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Failed to get payment history');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final message = e.response?.data['message'] ?? 'Failed to get payment history';
        throw Exception(message);
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get payment history: $e');
    }
  }

  /// Check if payment is completed
  Future<bool> isPaymentCompleted(String paymentId) async {
    try {
      final paymentStatus = await getPaymentStatus(paymentId);
      return paymentStatus['status'] == 'COMPLETED';
    } catch (e) {
      return false;
    }
  }
}


