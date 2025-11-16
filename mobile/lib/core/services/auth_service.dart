import 'dart:convert';
import 'package:dio/dio.dart';
import '../config/constants.dart';
import 'api_service.dart';
import 'storage_service.dart';
import '../models/user.dart';

class AuthService {
  final ApiService apiService;
  
  AuthService({required this.apiService});
  
  Future<Map<String, dynamic>> register({
    required String email,
    required String phoneNumber,
    required String password,
    required String firstName,
    required String lastName,
    String role = 'guest',
  }) async {
    try {
      final response = await apiService.post('/auth/register', data: {
        'email': email,
        'phoneNumber': phoneNumber,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'role': role,
      });
      
      if (response.data['success']) {
        final token = response.data['data']['token'];
        final user = User.fromJson(response.data['data']['user']);
        
        await StorageService.setString(AppConstants.tokenKey, token);
        await StorageService.setString(AppConstants.userKey, jsonEncode(user.toJson()));
        
        return response.data['data'];
      }
      
      throw Exception(response.data['message'] ?? 'Registration failed');
    } catch (e) {
      if (e.toString().contains('DioException') || e.toString().contains('DioError')) {
        // Network or server error
        final dioError = e as dynamic;
        if (dioError.response != null && dioError.response.data != null) {
          final data = dioError.response.data;
          String errorMessage = 'Registration failed';
          
          // Try to extract error message from different possible fields
          if (data is Map) {
            errorMessage = data['message']?.toString() ?? 
                          data['error']?.toString() ?? 
                          'Registration failed';
          } else if (data is String) {
            errorMessage = data;
          }
          
          throw Exception(errorMessage);
        } else if (dioError.type.toString().contains('connectionTimeout') || 
                   dioError.type.toString().contains('receiveTimeout')) {
          throw Exception('Connection timeout. Please check your network.');
        } else if (dioError.type.toString().contains('connectionError')) {
          throw Exception('Cannot connect to server. Please check if backend is running.');
        } else {
          throw Exception('Network error: ${dioError.message ?? "Unknown error"}');
        }
      }
      rethrow;
    }
  }
  
  Future<Map<String, dynamic>> login({
    String? email,
    String? phoneNumber,
    required String password,
  }) async {
    try {
      final Map<String, dynamic> loginData = {
        'password': password,
      };
      
      if (email != null) {
        loginData['email'] = email;
      } else if (phoneNumber != null) {
        loginData['phoneNumber'] = phoneNumber;
      }
      
      final response = await apiService.post('/auth/login', data: loginData);
      
      if (response.data['success']) {
        final token = response.data['data']['token'];
        final user = User.fromJson(response.data['data']['user']);
        
        await StorageService.setString(AppConstants.tokenKey, token);
        await StorageService.setString(AppConstants.userKey, jsonEncode(user.toJson()));
        
        return response.data['data'];
      }
      
      throw Exception(response.data['message'] ?? 'Login failed');
    } catch (e) {
      if (e.toString().contains('DioException') || e.toString().contains('DioError')) {
        final dioError = e as dynamic;
        if (dioError.response != null && dioError.response.data != null) {
          final data = dioError.response.data;
          String errorMessage = 'Login failed';
          
          // Try to extract error message from different possible fields
          if (data is Map) {
            errorMessage = data['message']?.toString() ?? 
                          data['error']?.toString() ?? 
                          'Login failed';
          } else if (data is String) {
            errorMessage = data;
          }
          
          throw Exception(errorMessage);
        } else if (dioError.type.toString().contains('connectionTimeout') || 
                   dioError.type.toString().contains('receiveTimeout')) {
          throw Exception('Connection timeout. Please check your network.');
        } else if (dioError.type.toString().contains('connectionError')) {
          throw Exception('Cannot connect to server. Please check if backend is running.');
        } else {
          throw Exception('Network error: ${dioError.message ?? "Unknown error"}');
        }
      }
      rethrow;
    }
  }
  
  Future<void> logout() async {
    try {
      await apiService.post('/auth/logout');
    } catch (e) {
      print('🔐 Logout API call failed: $e');
    }
    await StorageService.remove(AppConstants.tokenKey);
    await StorageService.remove(AppConstants.userKey);
    print('🔐 User logged out, storage cleared');
  }
  
  Future<User?> getCurrentUser() async {
    try {
      print('🔐 Starting authentication check...');
      
      // First check if we have a token
      final token = StorageService.getString(AppConstants.tokenKey);
      print('🔐 Token found: ${token != null ? "Yes" : "No"}');
      
      if (token == null) {
        print('🔐 No token found');
        return null;
      }
      
      // Try to get user info from stored data first
      final userJson = StorageService.getString(AppConstants.userKey);
      print('🔐 User data found: ${userJson != null ? "Yes" : "No"}');
      
      if (userJson != null) {
        final user = User.fromJson(jsonDecode(userJson));
        print('🔐 Found stored user: ${user.fullName}');
        
        // Try to validate token with server, but don't fail if network is down
        try {
          print('🔐 Attempting to validate token with server...');
          final response = await apiService.get('/auth/me');
          if (response.data['success']) {
            // Update stored user data with fresh data from server
            final freshUser = User.fromJson(response.data['data']);
            await StorageService.setString(AppConstants.userKey, jsonEncode(freshUser.toJson()));
            print('🔐 Token validated with server, user data updated');
            return freshUser;
          }
        } catch (e) {
          // If network error or server error, but we have stored user data, use it
          print('🔐 Network error during auth validation, using stored user data: $e');
          return user;
        }
        
        return user;
      }
      
      print('🔐 No stored user data found');
      return null;
    } catch (e) {
      // If any critical error occurs, clear stored data
      print('🔐 Critical error in getCurrentUser: $e');
      await logout();
      return null;
    }
  }
  
  Future<bool> isLoggedIn() async {
    final token = StorageService.getString(AppConstants.tokenKey);
    final userJson = StorageService.getString(AppConstants.userKey);
    return token != null && userJson != null;
  }

  Future<bool> requestHostRole() async {
    try {
      final response = await apiService.post('/auth/request-host');
      if (response.data['success'] == true) {
        final user = User.fromJson(response.data['data']);
        await StorageService.setString(AppConstants.userKey, jsonEncode(user.toJson()));
        return true;
      }
      throw Exception(response.data['message'] ?? 'Failed to request host role');
    } catch (e) {
      if (e is DioException && e.response != null) {
        final data = e.response?.data;
        if (data is Map && data['message'] != null) {
          throw Exception(data['message']);
        }
      }
      rethrow;
    }
  }
  
  // Send phone verification code
  Future<void> sendPhoneVerificationCode(String phoneNumber) async {
    final response = await apiService.post('/auth/send-phone-code', data: {
      'phoneNumber': phoneNumber,
    });
    
    if (!response.data['success']) {
      throw Exception(response.data['message'] ?? 'Failed to send verification code');
    }
  }
  
  // Verify phone with code
  Future<void> verifyPhone(String phoneNumber, String code) async {
    final response = await apiService.post('/auth/verify-phone', data: {
      'phoneNumber': phoneNumber,
      'code': code,
    });
    
    if (!response.data['success']) {
      throw Exception(response.data['message'] ?? 'Verification failed');
    }
  }
  
  // Send email verification code
  Future<void> sendEmailVerificationCode(String email) async {
    final response = await apiService.post('/auth/send-email-code', data: {
      'email': email,
    });
    
    if (!response.data['success']) {
      throw Exception(response.data['message'] ?? 'Failed to send verification code');
    }
  }
  
  // Verify email with token
  Future<void> verifyEmail(String token) async {
    final response = await apiService.post('/auth/verify-email', data: {
      'token': token,
    });
    
    if (!response.data['success']) {
      throw Exception(response.data['message'] ?? 'Verification failed');
    }
  }
}


