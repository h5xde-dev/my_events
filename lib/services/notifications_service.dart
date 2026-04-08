import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationsService {
  NotificationsService._();

  static final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();
  static bool _isInitialized = false;

  static Future<void> init() async {
    if (_isInitialized) return;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInit = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidInit,
      iOS: darwinInit,
    );
    await _local.initialize(settings);

    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    _isInitialized = true;
  }

  static Future<String?> registerPushToken() async {
    try {
      return await FirebaseMessaging.instance.getToken();
    } on FirebaseException catch (e) {
      // Some Android emulators/devices without Google Play Services
      // cannot provide an FCM token.
      debugPrint('FCM token unavailable: ${e.code} ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Unexpected FCM token error: $e');
      return null;
    }
  }

  static Future<void> scheduleLocalReminder({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'event_reminders',
      'Event Reminders',
      channelDescription: 'Reminders about favorite events',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);
    await _local.show(id, title, body, details);
  }
}
