import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification.dart';
import '../services/push_notification_service.dart';

class NotificationProvider with ChangeNotifier {
  final PushNotificationService _pushService = PushNotificationService();
  
  List<AppNotification> _notifications = [];
  NotificationPreferences _preferences = NotificationPreferences(
    push: true,
    email: true,
    sms: false,
  );
  
  bool _isLoading = false;
  String? _error;

  List<AppNotification> get notifications => _notifications;
  List<AppNotification> get unreadNotifications => 
      _notifications.where((n) => !n.isRead).toList();
  int get unreadCount => unreadNotifications.length;
  NotificationPreferences get preferences => _preferences;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load notifications from local storage
  Future<void> loadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString('notifications');
      
      if (notificationsJson != null) {
        final List<dynamic> decoded = jsonDecode(notificationsJson);
        _notifications = decoded
            .map((json) => AppNotification.fromJson(json))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      print('Error loading notifications: $e');
    }
  }

  /// Save notifications to local storage
  Future<void> _saveNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = jsonEncode(
        _notifications.map((n) => n.toJson()).toList(),
      );
      await prefs.setString('notifications', notificationsJson);
    } catch (e) {
      print('Error saving notifications: $e');
    }
  }

  /// Add a new notification
  Future<void> addNotification(AppNotification notification) async {
    _notifications.insert(0, notification);
    await _saveNotifications();
    notifyListeners();
  }

  /// Mark notification as read
  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      await _saveNotifications();
      notifyListeners();
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    _notifications = _notifications
        .map((n) => n.copyWith(isRead: true))
        .toList();
    await _saveNotifications();
    notifyListeners();
  }

  /// Delete notification
  Future<void> deleteNotification(String id) async {
    _notifications.removeWhere((n) => n.id == id);
    await _saveNotifications();
    notifyListeners();
  }

  /// Clear all notifications
  Future<void> clearAll() async {
    _notifications.clear();
    await _saveNotifications();
    await _pushService.clearAllNotifications();
    notifyListeners();
  }

  /// Load preferences from backend
  Future<void> loadPreferences() async {
    try {
      _isLoading = true;
      notifyListeners();

      final prefsData = await _pushService.getPreferences();
      if (prefsData != null) {
        _preferences = NotificationPreferences.fromJson(prefsData);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update notification preferences
  Future<bool> updatePreferences({
    bool? push,
    bool? email,
    bool? sms,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final success = await _pushService.updatePreferences(
        push: push,
        email: email,
        sms: sms,
      );

      if (success) {
        _preferences = _preferences.copyWith(
          push: push ?? _preferences.push,
          email: email ?? _preferences.email,
          sms: sms ?? _preferences.sms,
        );
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

  /// Send test notification
  Future<bool> sendTestNotification() async {
    try {
      return await _pushService.sendTestNotification();
    } catch (e) {
      return false;
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}






