# ZenoPay Mobile Money Tanzania - Flutter Integration

A clean Flutter implementation guide for integrating **ZenoPay Mobile Money Tanzania API** using the [`http`](https://pub.dev/packages/http) package and `dart:convert` for JSON handling.

---

## Features

* Initiate Mobile Money payments in Tanzania.
* Check order/payment status.
* Receive webhook notifications for completed payments.

---

## 1. Add Dependencies

In your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
```

Then run:

```bash
flutter pub get
```

---

## 2. Create a ZenoPay Service

Create a file `zenopay_service.dart`:

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ZenoPayService {
  final String apiKey;
  final String baseUrl = 'https://zenoapi.com/api/payments';

  ZenoPayService({required this.apiKey});

  /// Initiate Mobile Money Payment (Tanzania)
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
      "order_id": orderId,
      "buyer_name": buyerName,
      "buyer_email": buyerEmail,
      "buyer_phone": buyerPhone,
      "amount": amount,
      if (webhookUrl != null) "webhook_url": webhookUrl,
    };

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "x-api-key": apiKey,
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'Failed to initiate payment: ${response.statusCode} ${response.body}',
      );
    }
  }

  /// Check Order Status
  Future<Map<String, dynamic>> checkOrderStatus(String orderId) async {
    final url = Uri.parse('$baseUrl/order-status?order_id=$orderId');

    final response = await http.get(
      url,
      headers: {
        "x-api-key": apiKey,
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'Failed to fetch order status: ${response.statusCode} ${response.body}',
      );
    }
  }
}
```

---

## 3. Example Usage in Flutter

```dart
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
```

---

## 4. Handling Webhook Notifications

Set up a backend endpoint (Node.js, PHP, or any server) to receive POST requests when payment status is `COMPLETED`.

**Security:** Verify the `x-api-key` in the request headers.

**Example payload:**

```json
{
  "order_id": "677e43274d7cb",
  "payment_status": "COMPLETED",
  "reference": "1003020496",
  "metadata": {}
}
```

---

## 5. Next Steps

* Build a **Flutter widget** with a button to trigger payment.
* Show real-time order status updates.
* Integrate your backend to securely handle webhooks.

---

**ZenoPay Flutter Integration** makes it easy to receive payments across Tanzania quickly and securely.

---