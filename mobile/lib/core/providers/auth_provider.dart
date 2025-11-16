import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/push_notification_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService authService;
  
  User? _user;
  bool _isLoading = false;
  bool _isCheckingAuth = false;
  String? _error;
  
  AuthProvider({required this.authService}) {
    _checkAuth();
  }
  
  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isCheckingAuth => _isCheckingAuth;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  bool get isHostApproved => _user?.hostStatus == 'approved';
  bool get isHostPending => _user?.hostStatus == 'pending';
  bool get isHostRejected => _user?.hostStatus == 'rejected';
  bool get hasPayoutSettings => _user?.hasPayoutSettings ?? false;
  
  Future<void> _checkAuth() async {
    try {
      _isCheckingAuth = true;
      notifyListeners();
      
      print('🔐 Checking authentication...');
      _user = await authService.getCurrentUser();
      print('🔐 Auth check result: ${_user != null ? "User logged in" : "No user"}');
      
      _isCheckingAuth = false;
      notifyListeners();
    } catch (e) {
      print('🔐 Auth check error: $e');
      _isCheckingAuth = false;
      _error = e.toString();
      notifyListeners();
    }
  }
  
  Future<bool> register({
    required String email,
    required String phoneNumber,
    required String password,
    required String firstName,
    required String lastName,
    String role = 'guest',
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final result = await authService.register(
        email: email,
        phoneNumber: phoneNumber,
        password: password,
        firstName: firstName,
        lastName: lastName,
        role: role,
      );
      
      // Convert the user map to User object
      _user = User.fromJson(result['user']);
      _isLoading = false;
      notifyListeners();
      
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> login({
    String? email,
    String? phoneNumber,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final result = await authService.login(
        email: email,
        phoneNumber: phoneNumber,
        password: password,
      );
      
      // Convert the user map to User object
      _user = User.fromJson(result['user']);
      
      // Register FCM token for push notifications after login
      try {
        final pushService = PushNotificationService();
        final token = pushService.fcmToken;
        if (token != null) {
          print('🔔 FCM token available for registration after login');
        }
      } catch (e) {
        print('⚠️ Failed to access FCM token: $e');
      }
      
      _isLoading = false;
      notifyListeners();
      
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<void> logout() async {
    await authService.logout();
    _user = null;
    notifyListeners();
  }
  
  // Refresh authentication state (useful when app comes back to foreground)
  Future<void> refreshAuth() async {
    if (!_isCheckingAuth) {
      await _checkAuth();
    }
  }

  Future<bool> requestHostRole() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final success = await authService.requestHostRole();
      if (success) {
        await _checkAuth();
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Send phone verification code
  Future<bool> sendPhoneCode(String phoneNumber) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await authService.sendPhoneVerificationCode(phoneNumber);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Verify phone with code
  Future<bool> verifyPhone(String phoneNumber, String code) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await authService.verifyPhone(phoneNumber, code);
      
      // Refresh user data
      await _checkAuth();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Send email verification code
  Future<bool> sendEmailCode(String email) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await authService.sendEmailVerificationCode(email);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Verify email with token
  Future<bool> verifyEmail(String token) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await authService.verifyEmail(token);
      
      // Refresh user data
      await _checkAuth();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}


