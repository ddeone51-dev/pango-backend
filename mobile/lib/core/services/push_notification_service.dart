import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'api_service.dart';
import 'storage_service.dart';

// Top-level function for background message handling
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Background message received: ${message.messageId}');
  // Handle background message
}

class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  String? _fcmToken;
  ApiService? _apiService;
  
  // Notification handlers
  Function(RemoteMessage)? onMessageReceived;
  Function(String)? onNotificationTapped;

  String? get fcmToken => _fcmToken;

  /// Initialize push notifications
  Future<void> initialize({ApiService? apiService}) async {
    _apiService = apiService;

    // Request permission (iOS & Android 13+)
    final settings = await _requestPermission();
    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      print('Push notification permission not granted');
      return;
    }

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Get FCM token
    _fcmToken = await _firebaseMessaging.getToken();
    print('FCM Token: $_fcmToken');

    // Register token with backend
    if (_fcmToken != null && _apiService != null) {
      await _registerToken(_fcmToken!);
    }

    // Listen to token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      _fcmToken = newToken;
      print('FCM Token refreshed: $newToken');
      if (_apiService != null) {
        _registerToken(newToken);
      }
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification opened from terminated state
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        _handleNotificationTap(message);
      }
    });

    // Handle notification opened from background state
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Set background message handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  /// Request notification permissions
  Future<NotificationSettings> _requestPermission() async {
    return await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );
  }

  /// Initialize local notifications (for showing in foreground)
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        if (details.payload != null) {
          onNotificationTapped?.call(details.payload!);
        }
      },
    );

    // Create Android notification channel
    if (Platform.isAndroid) {
      const channel = AndroidNotificationChannel(
        'homia_notifications',
        'Homia Notifications',
        description: 'General notifications from Homia',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  /// Register FCM token with backend
  Future<void> _registerToken(String token) async {
    try {
      await _apiService?.post('/notifications/register-token', data: {'token': token});
      print('Token registered with backend');
    } catch (e) {
      print('Failed to register token: $e');
    }
  }

  /// Handle foreground messages
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Foreground message received: ${message.notification?.title}');
    
    // Notify listeners
    onMessageReceived?.call(message);

    // Show local notification
    await _showLocalNotification(message);
  }

  /// Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails(
      'homia_notifications',
      'Homia Notifications',
      channelDescription: 'General notifications from Homia',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      notification.title,
      notification.body,
      notificationDetails,
      payload: jsonEncode(message.data),
    );
  }

  /// Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    print('Notification tapped: ${message.data}');
    
    final data = message.data;
    final screen = data['screen'];
    
    if (screen != null) {
      onNotificationTapped?.call(jsonEncode(data));
    }
  }

  /// Remove device token (on logout)
  Future<void> removeToken() async {
    try {
      if (_fcmToken != null && _apiService != null) {
        await _apiService?.delete('/notifications/remove-token', data: {'token': _fcmToken});
      }
      _fcmToken = null;
    } catch (e) {
      print('Failed to remove token: $e');
    }
  }

  /// Send test notification
  Future<bool> sendTestNotification() async {
    try {
      final response = await _apiService?.post('/notifications/test');
      return response?.data['success'] == true;
    } catch (e) {
      print('Failed to send test notification: $e');
      return false;
    }
  }

  /// Update notification preferences
  Future<bool> updatePreferences({
    bool? push,
    bool? email,
    bool? sms,
  }) async {
    try {
      final data = <String, bool>{};
      if (push != null) data['push'] = push;
      if (email != null) data['email'] = email;
      if (sms != null) data['sms'] = sms;

      final response = await _apiService?.put('/notifications/preferences', data: data);
      return response?.data['success'] == true;
    } catch (e) {
      print('Failed to update preferences: $e');
      return false;
    }
  }

  /// Get notification preferences
  Future<Map<String, dynamic>?> getPreferences() async {
    try {
      final response = await _apiService?.get('/notifications/preferences');
      if (response?.data['success'] == true) {
        return response?.data['data'];
      }
      return null;
    } catch (e) {
      print('Failed to get preferences: $e');
      return null;
    }
  }

  /// Get notification badge count
  Future<int> getBadgeCount() async {
    if (Platform.isIOS) {
      // iOS badge management
      return 0; // Implement based on your needs
    }
    return 0;
  }

  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }
}

