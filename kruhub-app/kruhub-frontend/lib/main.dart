import 'package:flutter/material.dart';
import 'services/notification_service.dart';
import 'services/push_notification_service.dart';
import 'views/auth/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();
  await PushNotificationService.initialize();
  runApp(const KruHubApp());
}

class KruHubApp extends StatelessWidget {
  const KruHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KruHub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}