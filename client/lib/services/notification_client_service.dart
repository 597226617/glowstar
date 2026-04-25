import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Notification Client Service for GlowStar
/// 
/// Handles push notifications and local notifications
class NotificationClientService {
  static final NotificationClientService _instance = NotificationClientService._internal();
  factory NotificationClientService() => _instance;
  NotificationClientService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  /// Initialize notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
  }

  /// Show local notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isInitialized) await initialize();

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'glowstar_channel',
      'GlowStar',
      channelDescription: 'GlowStar notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(id, title, body, details, payload: payload);
  }

  /// Show match notification
  Future<void> showMatchNotification(String matchName) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: '新匹配！',
      body: '你和 $matchName 有共同兴趣！',
      payload: 'match',
    );
  }

  /// Show message notification
  Future<void> showMessageNotification(String senderName, String message) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: '新消息',
      body: '$senderName: $message',
      payload: 'message',
    );
  }

  /// Show system notification
  Future<void> showSystemNotification(String title, String body) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: title,
      body: body,
      payload: 'system',
    );
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // Navigate based on payload
    debugPrint('Notification tapped: ${response.payload}');
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    return await _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.areNotificationsEnabled() ?? true;
  }

  /// Request notification permissions
  Future<void> requestPermissions() async {
    await _localNotifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
}
