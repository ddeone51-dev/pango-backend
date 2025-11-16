import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../config/constants.dart';
import '../config/environment.dart';
import 'storage_service.dart';

class ApiService {
  late Dio _dio;
  
  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: Environment.baseUrl, // Use environment-aware URL
        connectTimeout: Environment.connectionTimeout,
        receiveTimeout: Environment.apiTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    
    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: false, // reduce noise
        responseHeader: false, // reduce noise
        responseBody: false, // disable large dumps
        compact: true,
        maxWidth: 90,
      ),
    );
    
    // Add auth interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await StorageService.getString(AppConstants.tokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            // Handle token expiration
            await StorageService.remove(AppConstants.tokenKey);
            await StorageService.remove(AppConstants.userKey);
          }
          // Print concise backend error
          final data = error.response?.data;
          if (data != null) {
            try {
              // Attempt common shapes: { message }, { error }, { errors: [] }
              final message = data['message'] ?? data['error'] ?? data.toString();
              // ignore: avoid_print
              print('API Error ${error.response?.statusCode}: $message');
            } catch (_) {
              // ignore: avoid_print
              print('API Error ${error.response?.statusCode}: ${error.response?.data}');
            }
          }
          return handler.next(error);
        },
      ),
    );
  }
  
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }
  
  Future<Response> post(String path, {dynamic data, Options? options}) async {
    try {
      return await _dio.post(path, data: data, options: options);
    } catch (e) {
      rethrow;
    }
  }
  
  Future<Response> put(String path, {dynamic data}) async {
    try {
      return await _dio.put(path, data: data);
    } catch (e) {
      rethrow;
    }
  }
  
  Future<Response> delete(String path, {dynamic data}) async {
    try {
      return await _dio.delete(path, data: data);
    } catch (e) {
      rethrow;
    }
  }
}








