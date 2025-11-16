import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class HostPayoutProvider with ChangeNotifier {
  final ApiService apiService;

  HostPayoutProvider({required this.apiService});

  PayoutSettings? _settings;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;

  PayoutSettings? get settings => _settings;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;

  Future<void> fetchSettings() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await apiService.get('/users/payout-settings');
      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>? ?? {};
        _settings = data.isEmpty ? null : PayoutSettings.fromJson(data);
      } else {
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

  Future<Map<String, dynamic>> saveSettings({
    required String method,
    Map<String, dynamic>? bankAccount,
    Map<String, dynamic>? mobileMoney,
    String preferredCurrency = 'TZS',
  }) async {
    try {
      _isSaving = true;
      _error = null;
      notifyListeners();

      final payload = {
        'method': method,
        'preferredCurrency': preferredCurrency,
        if (bankAccount != null) 'bankAccount': bankAccount,
        if (mobileMoney != null) 'mobileMoney': mobileMoney,
      };

      final response = await apiService.put('/users/payout-settings', data: payload);
      _isSaving = false;

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>? ?? {};
        _settings = PayoutSettings.fromJson(data);
        notifyListeners();
        return {
          'success': true,
          'message': response.data['message']?.toString() ?? 'Payout settings saved',
        };
      }

      final message = response.data['message']?.toString() ?? 'Failed to save payout settings';
      _error = message;
      notifyListeners();
      return {'success': false, 'message': message};
    } catch (e) {
      _error = e.toString();
      _isSaving = false;
      notifyListeners();
      return {'success': false, 'message': _error ?? 'Failed to save payout settings'};
    }
  }
}


