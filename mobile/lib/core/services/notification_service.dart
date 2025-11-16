import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  
  Future<void> initialize() async {
    // Request permission
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }

    // Get FCM token
    String? token = await _fcm.getToken();
    print('FCM Token: $token');
    // TODO: Send this token to your backend

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        // Show local notification
        _showNotification(message);
      }
    });

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle notification taps
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      _handleNotificationTap(message);
    });

    // Check if app was opened from a terminated state
    RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  void _showNotification(RemoteMessage message) {
    // Implement local notification display
    // You can use flutter_local_notifications package
  }

  void _handleNotificationTap(RemoteMessage message) {
    // Handle navigation based on notification data
    final data = message.data;
    
    if (data['type'] == 'booking_confirmed') {
      // Navigate to booking details
      // navigatorKey.currentState?.pushNamed('/booking-details', arguments: data['bookingId']);
    } else if (data['type'] == 'new_message') {
      // Navigate to messages
    }
  }

  Future<String?> getToken() async {
    return await _fcm.getToken();
  }

  Future<void> subscribeToTopic(String topic) async {
    await _fcm.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _fcm.unsubscribeFromTopic(topic);
  }
}

// Top-level function for background message handling
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
}

























