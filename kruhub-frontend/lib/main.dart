import 'package:flutter/material.dart';
import 'views/auth/login_screen.dart';

void main() {
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
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212), // Background gelap
        primaryColor: Colors.blue,
        cardColor: const Color(0xFF1E1E1E), // Warna kartu UI
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF121212),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
        ),
        fontFamily: 'Inter', // Sesuaikan jika ada font khusus
      ),
      home: const LoginScreen(),
    );
  }
}