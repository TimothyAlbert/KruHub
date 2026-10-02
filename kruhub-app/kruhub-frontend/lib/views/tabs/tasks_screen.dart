import 'package:flutter/material.dart';

class TasksScreen extends StatelessWidget {
  final String role;
  const TasksScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Mengikuti scaffold template
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('All Tasks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)), //[cite: 3]
              Text('Filter', style: TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 16),
          _buildTaskCard('Production', 'In Progress', 'Rig Lighting Setup', 'Sep 28', Colors.grey), //[cite: 3]
          _buildTaskCard('Sound', 'Review', 'Audio Mixdown', 'Sep 30', Colors.orange), //[cite: 3]
          _buildTaskCard('Logistics', 'Blocked', 'Set Teardown', '-', Colors.redAccent), //[cite: 3]
        ],
      ),
      // RBAC: Hanya Ketua & PIC yang bisa tambah tugas
      floatingActionButton: (role == 'ketua_pelaksana' || role == 'pic')
          ? FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: () {},
              child: const Icon(Icons.add, color: Colors.black),
            )
          : null,
    );
  }

  Widget _buildTaskCard(String division, String status, String title, String date, Color statusColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: Colors.grey.withOpacity(0.2), borderRadius: BorderRadius.circular(12)), child: Text(division, style: const TextStyle(fontSize: 12, color: Colors.white))),
              Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: statusColor.withOpacity(0.2), borderRadius: BorderRadius.circular(12)), child: Text(status, style: TextStyle(fontSize: 12, color: statusColor, fontWeight: FontWeight.bold))),
            ],
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          Row(children: [const Icon(Icons.calendar_today, size: 14, color: Colors.grey), const SizedBox(width: 6), Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12))]),
        ],
      ),
    );
  }
}