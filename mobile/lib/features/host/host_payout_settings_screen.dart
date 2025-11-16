import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/host_payout_provider.dart';
import '../../core/providers/auth_provider.dart';

class HostPayoutSettingsScreen extends StatefulWidget {
  const HostPayoutSettingsScreen({super.key});

  @override
  State<HostPayoutSettingsScreen> createState() => _HostPayoutSettingsScreenState();
}

class _HostPayoutSettingsScreenState extends State<HostPayoutSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bankAccountNameController = TextEditingController();
  final _bankAccountNumberController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _branchNameController = TextEditingController();
  final _swiftCodeController = TextEditingController();

  final _mobileAccountNameController = TextEditingController();
  final _mobilePhoneController = TextEditingController();
  String _mobileProvider = 'mpesa';

  String _method = 'bank_account';
  bool _initialised = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final payoutProvider = context.read<HostPayoutProvider>();
      await payoutProvider.fetchSettings();
      _prefill(payoutProvider.settings);
    });
  }

  void _prefill(payoutSettings) {
    if (payoutSettings == null || _initialised) return;
    setState(() {
      _method = payoutSettings.method ?? 'bank_account';
      if (payoutSettings.bankAccount != null) {
        _bankAccountNameController.text = payoutSettings.bankAccount?.accountName ?? '';
        _bankAccountNumberController.text = payoutSettings.bankAccount?.accountNumber ?? '';
        _bankNameController.text = payoutSettings.bankAccount?.bankName ?? '';
        _branchNameController.text = payoutSettings.bankAccount?.branchName ?? '';
        _swiftCodeController.text = payoutSettings.bankAccount?.swiftCode ?? '';
      }
      if (payoutSettings.mobileMoney != null) {
        final provider = payoutSettings.mobileMoney?.provider?.trim() ?? '';
        // Ensure the provider value is one of the valid dropdown values
        const validProviders = ['mpesa', 'tigopesa', 'airtel_money', 'halopesa', 't-pesa', 'other'];
        _mobileProvider = validProviders.contains(provider) ? provider : 'mpesa';
        _mobileAccountNameController.text = payoutSettings.mobileMoney?.accountName ?? '';
        _mobilePhoneController.text = payoutSettings.mobileMoney?.phoneNumber ?? '';
      }
      _initialised = true;
    });
  }

  @override
  void dispose() {
    _bankAccountNameController.dispose();
    _bankAccountNumberController.dispose();
    _bankNameController.dispose();
    _branchNameController.dispose();
    _swiftCodeController.dispose();
    _mobileAccountNameController.dispose();
    _mobilePhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payout Settings'),
      ),
      body: Consumer<HostPayoutProvider>(
        builder: (context, payoutProvider, child) {
          _prefill(payoutProvider.settings);
          if (payoutProvider.isLoading && !_initialised) {
            return const Center(child: CircularProgressIndicator());
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Card(
                  color: Colors.blueGrey.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'How payouts work',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '• Guests confirm their arrival and then we release 93% of the booking total to you.\n'
                          '• Homie keeps a 7% platform fee for marketing, support, and payment processing.\n'
                          '• If a guest forgets to confirm, we auto-release payouts 24h after check-in.',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Preferred payout method',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'bank_account',
                      label: Text('Bank Account'),
                      icon: Icon(Icons.account_balance),
                    ),
                    ButtonSegment(
                      value: 'mobile_money',
                      label: Text('Mobile Money'),
                      icon: Icon(Icons.phone_iphone),
                    ),
                  ],
                  selected: {_method},
                  onSelectionChanged: (value) {
                    setState(() {
                      _method = value.first;
                    });
                  },
                ),
                const SizedBox(height: 20),
                if (_method == 'bank_account') _buildBankForm() else _buildMobileForm(),
                const SizedBox(height: 24),
                // Show cooldown information if applicable
                if (payoutProvider.settings != null && !payoutProvider.settings!.canUpdate) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.schedule, color: Colors.orange.shade700, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Update Cooldown Period',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.orange.shade900,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'For security reasons, payout details can only be updated once every 2 days. You can update again in ${payoutProvider.settings!.daysUntilNextUpdate.toStringAsFixed(1)} day(s).',
                                style: TextStyle(
                                  color: Colors.orange.shade800,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: (payoutProvider.isSaving || (payoutProvider.settings != null && !payoutProvider.settings!.canUpdate))
                        ? null
                        : () => _handleSave(payoutProvider),
                    icon: payoutProvider.isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save),
                    label: Text(payoutProvider.isSaving ? 'Saving...' : 'Save payout details'),
                  ),
                ),
                if (payoutProvider.error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    payoutProvider.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBankForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bank account details',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _bankAccountNameController,
          decoration: const InputDecoration(
            labelText: 'Account name',
            hintText: 'e.g. John Doe',
          ),
          validator: (value) => value == null || value.isEmpty ? 'Account name is required' : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _bankAccountNumberController,
          decoration: const InputDecoration(
            labelText: 'Account number',
            hintText: 'e.g. 0123456789',
          ),
          validator: (value) => value == null || value.isEmpty ? 'Account number is required' : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _bankNameController,
          decoration: const InputDecoration(
            labelText: 'Bank name',
            hintText: 'e.g. CRDB Bank',
          ),
          validator: (value) => value == null || value.isEmpty ? 'Bank name is required' : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _branchNameController,
          decoration: const InputDecoration(
            labelText: 'Branch (optional)',
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _swiftCodeController,
          decoration: const InputDecoration(
            labelText: 'SWIFT / Routing code (optional)',
          ),
        ),
      ],
    );
  }

  Widget _buildMobileForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mobile money details',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _mobileProvider,
          items: const [
            DropdownMenuItem(value: 'mpesa', child: Text('M-Pesa')),
            DropdownMenuItem(value: 'tigopesa', child: Text('Tigo Pesa')),
            DropdownMenuItem(value: 'airtel_money', child: Text('Airtel Money')),
            DropdownMenuItem(value: 'halopesa', child: Text('HaloPesa')),
            DropdownMenuItem(value: 't-pesa', child: Text('T-Pesa')),
            DropdownMenuItem(value: 'other', child: Text('Other')),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _mobileProvider = value;
              });
            }
          },
          decoration: const InputDecoration(
            labelText: 'Provider',
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _mobilePhoneController,
          decoration: const InputDecoration(
            labelText: 'Wallet phone number',
            hintText: 'e.g. 07XXXXXXXX',
          ),
          keyboardType: TextInputType.phone,
          validator: (value) => value == null || value.length < 10
              ? 'Enter a valid mobile number'
              : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _mobileAccountNameController,
          decoration: const InputDecoration(
            labelText: 'Account name (optional)',
          ),
        ),
      ],
    );
  }

  Future<void> _handleSave(HostPayoutProvider provider) async {
    if (!_formKey.currentState!.validate()) return;

    Map<String, dynamic>? bankAccount;
    Map<String, dynamic>? mobileMoney;

    if (_method == 'bank_account') {
      bankAccount = {
        'accountName': _bankAccountNameController.text.trim(),
        'accountNumber': _bankAccountNumberController.text.trim(),
        'bankName': _bankNameController.text.trim(),
        'branchName': _branchNameController.text.trim(),
        'swiftCode': _swiftCodeController.text.trim(),
      };
    } else {
      mobileMoney = {
        'provider': _mobileProvider,
        'phoneNumber': _mobilePhoneController.text.trim(),
        'accountName': _mobileAccountNameController.text.trim(),
      };
    }

    final result = await provider.saveSettings(
      method: _method,
      bankAccount: bankAccount,
      mobileMoney: mobileMoney,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      await context.read<AuthProvider>().refreshAuth();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']?.toString() ?? 'Payout details saved'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']?.toString() ?? 'Could not save payout details'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}


