import 'package:flutter/material.dart';

import 'admin_dashboard_screen.dart';

class AdminShellScreen extends StatefulWidget {
  const AdminShellScreen({super.key});

  @override
  State<AdminShellScreen> createState() => _AdminShellScreenState();
}

class _AdminShellScreenState extends State<AdminShellScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    AdminDashboardScreen(),
    _AdminPlaceholderScreen(
      title: 'Project CMS',
      subtitle: 'Kelola proyek, status, dan timeline',
      icon: Icons.folder_copy_rounded,
    ),
    _AdminPlaceholderScreen(
      title: 'Reports',
      subtitle: 'Analitik, review, dan ringkasan operasional',
      icon: Icons.analytics_rounded,
    ),
    _AdminPlaceholderScreen(
      title: 'Settings',
      subtitle: 'Konfigurasi platform dan akses admin',
      icon: Icons.settings_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F10),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F10),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Admin CMS'),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(canvasColor: const Color(0xFF0F0F10)),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: const Color(0xFF0F0F10),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.manage_accounts_rounded),
              label: 'Users',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.folder_copy_rounded),
              label: 'Projects',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics_rounded),
              label: 'Reports',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_rounded),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminPlaceholderScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _AdminPlaceholderScreen({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, color: Colors.white, size: 34),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
