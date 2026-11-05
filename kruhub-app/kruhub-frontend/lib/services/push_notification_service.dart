import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'api_service.dart';
import 'notification_service.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('FCM background message: ${message.messageId}');
}

class PushNotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      FirebaseMessaging.onMessage.listen((message) {
        final notification = message.notification;
        if (notification != null) {
          NotificationService.show(
            notification.title ?? 'KruHub',
            notification.body ?? 'Ada pembaruan terbaru untuk Anda.',
          );
        }
      });

      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        await registerCurrentDevice();
      }

      _messaging.onTokenRefresh.listen((token) async {
        await ApiService.registerDeviceToken(token, platform: Platform.operatingSystem);
      });
    } catch (error) {
      print('FCM initialization failed: $error');
    }
  }

  static Future<void> registerCurrentDevice() async {
    if (ApiService.token == null || ApiService.token!.isEmpty) {
      return;
    }

    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await ApiService.registerDeviceToken(
          token,
          platform: Platform.operatingSystem,
        );
      }
    } catch (error) {
      print('Register device token failed: $error');
    }
  }
}
