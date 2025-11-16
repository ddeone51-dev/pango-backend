import 'package:flutter/material.dart';

class PaymentMethodScreen extends StatefulWidget {
  final double amount;
  final String currency;
  final Function(String paymentMethod) onMethodSelected;

  const PaymentMethodScreen({
    Key? key,
    required this.amount,
    this.currency = 'TZS',
    required this.onMethodSelected,
  }) : super(key: key);

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  String? _selectedMethod;

  final List<PaymentMethodOption> _paymentMethods = [
    PaymentMethodOption(
      id: 'M-PESA',
      name: 'M-Pesa',
      description: 'Pay with M-Pesa mobile money',
      icon: Icons.phone_android,
      color: Colors.green,
    ),
    PaymentMethodOption(
      id: 'TIGO_PESA',
      name: 'Tigo Pesa',
      description: 'Pay with Tigo Pesa mobile money',
      icon: Icons.phone_android,
      color: Colors.blue,
    ),
    PaymentMethodOption(
      id: 'AIRTEL_MONEY',
      name: 'Airtel Money',
      description: 'Pay with Airtel Money',
      icon: Icons.phone_android,
      color: Colors.red,
    ),
    PaymentMethodOption(
      id: 'VISA',
      name: 'Visa Card',
      description: 'Pay with Visa credit/debit card',
      icon: Icons.credit_card,
      color: Colors.indigo,
    ),
    PaymentMethodOption(
      id: 'MASTERCARD',
      name: 'Mastercard',
      description: 'Pay with Mastercard credit/debit card',
      icon: Icons.credit_card,
      color: Colors.orange,
    ),
  ];

  String get _formattedAmount {
    return '${widget.currency} ${widget.amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Payment Method'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Amount Display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                const Text(
                  'Amount to Pay',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formattedAmount,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Payment Methods List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _paymentMethods.length,
              itemBuilder: (context, index) {
                final method = _paymentMethods[index];
                final isSelected = _selectedMethod == method.id;

                return Card(
                  elevation: isSelected ? 4 : 1,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedMethod = method.id;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Icon
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: method.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              method.icon,
                              color: method.color,
                              size: 28,
                            ),
                          ),

                          const SizedBox(width: 16),

                          // Name and Description
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  method.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  method.description,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Radio Button
                          Radio<String>(
                            value: method.id,
                            groupValue: _selectedMethod,
                            onChanged: (value) {
                              setState(() {
                                _selectedMethod = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Continue Button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _selectedMethod != null
                      ? () {
                          widget.onMethodSelected(_selectedMethod!);
                          Navigator.of(context).pop();
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Continue to Payment',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentMethodOption {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;

  PaymentMethodOption({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
  });
}


