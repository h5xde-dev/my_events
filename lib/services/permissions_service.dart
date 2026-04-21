import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:location/location.dart';

class PermissionsService {
  PermissionsService._();

  static Future<void> requestRequiredOnLaunch() async {
    await _requestNotificationPermission();
    await _requestLocationPermission();
  }

  static Future<void> _requestNotificationPermission() async {
    try {
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (e) {
      debugPrint('Notification permission request failed: $e');
    }
  }

  static Future<void> _requestLocationPermission() async {
    final location = Location();
    try {
      var serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
      }
      if (!serviceEnabled) return;

      var permission = await location.hasPermission();
      if (permission == PermissionStatus.denied) {
        permission = await location.requestPermission();
      }
    } catch (e) {
      debugPrint('Location permission request failed: $e');
    }
  }
}
