import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(settings: settings);

    const channel = AndroidNotificationChannel(
      'kruhub_alerts',
      'KruHub Alerts',
      description: 'Notifikasi penting untuk task, asset, dan status proyek.',
      importance: Importance.max,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static Future<void> show(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'kruhub_alerts',
      'KruHub Alerts',
      channelDescription: 'Notifikasi penting untuk task, asset, dan status proyek.',
      importance: Importance.max,
      priority: Priority.high,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);

    await _plugin.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
    );
  }
}
