

import 'package:flutter/material.dart';
import 'zeno_pay_service.dart';

void main() async {
  final zenoPay = ZenoPayService(apiKey: 'YOUR_API_KEY');

  try {
    // Initiate Payment
    final paymentResponse = await zenoPay.initiatePayment(
      orderId: '3rer407fe-3ee8-4525-456f-ccb95de38250',
      buyerName: 'John Joh',
      buyerEmail: 'iam@gmail.com',
      buyerPhone: '0744963858',
      amount: 1000,
      webhookUrl: 'https://your-domain.com/payment-webhook',
    );

    print('Payment Response: $paymentResponse');

    // Check Order Status
    final statusResponse =
        await zenoPay.checkOrderStatus('3rer407fe-3ee8-4525-456f-ccb95de38250');

    print('Order Status: $statusResponse');
  } catch (e) {
    print('Error: $e');
  }
}
