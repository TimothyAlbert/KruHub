import 'package:flutter/material.dart';
import 'tabs/home_screen.dart';     // <-- Mengarah ke folder tabs/
import 'tabs/tasks_screen.dart';
import 'tabs/assets_screen.dart';
import 'tabs/team_screen.dart';
import 'tabs/profile_screen.dart';

class MainLayout extends StatefulWidget {
  final String userRole; // 'ketua_pelaksana', 'pic', 'staf'
  const MainLayout({super.key, required this.userRole});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // Inisialisasi 5 halaman utama
    _pages = [
      const HomeScreen(),
      TasksScreen(role: widget.userRole),
      AssetsScreen(role: widget.userRole),
      TeamScreen(role: widget.userRole), // Hanya bisa diakses fungsional oleh Ketua/PIC
      ProfileScreen(role: widget.userRole),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // TEMPLATE HEADER (Statis, tidak ikut reload saat ganti tab)[cite: 2, 3, 4]
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        toolbarHeight: 70,
        leadingWidth: 70,
        leading: const Padding(
          padding: EdgeInsets.only(left: 16.0, top: 8, bottom: 8),
          child: CircleAvatar(
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'), // Avatar dummy
          ),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome back', style: TextStyle(fontSize: 12, color: Colors.grey)),
            Text('Hello, Timothy 👋', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      
      // INDEXED STACK: Kunci performa agar tab tidak membebani app
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),

      // TEMPLATE BOTTOM NAVIGATION[cite: 2]
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.checklist), label: 'Tasks'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), activeIcon: Icon(Icons.inventory_2), label: 'Assets'),
          BottomNavigationBarItem(icon: Icon(Icons.groups_outlined), activeIcon: Icon(Icons.groups), label: 'Team'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}