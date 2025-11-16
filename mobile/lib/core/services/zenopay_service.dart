import 'dart:convert';
import 'package:http/http.dart' as http;

class ZenoPayService {
  final String apiKey;
  final String baseUrl = 'https://zenoapi.com/api/payments';

  ZenoPayService({required this.apiKey});

  Future<Map<String, dynamic>> initiatePayment({
    required String orderId,
    required String buyerName,
    required String buyerEmail,
    required String buyerPhone,
    required double amount,
    String? webhookUrl,
  }) async {
    final url = Uri.parse('$baseUrl/mobile_money_tanzania');

    final body = {
      'order_id': orderId,
      'buyer_name': buyerName,
      'buyer_email': buyerEmail,
      'buyer_phone': buyerPhone,
      'amount': amount.round(),
      if (webhookUrl != null) 'webhook_url': webhookUrl,
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to initiate payment: ${response.statusCode} ${response.body}');
  }

  Future<Map<String, dynamic>> checkOrderStatus(String orderId) async {
    final url = Uri.parse('$baseUrl/order-status?order_id=$orderId');

    final response = await http.get(
      url,
      headers: {
        'x-api-key': apiKey,
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to fetch order status: ${response.statusCode} ${response.body}');
  }
}

