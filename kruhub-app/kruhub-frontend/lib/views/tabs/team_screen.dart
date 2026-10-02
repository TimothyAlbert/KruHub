import 'package:flutter/material.dart';

class TeamScreen extends StatelessWidget {
  final String role;
  const TeamScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    if (role == 'staf') {
      return const Center(child: Text('Akses Ditolak. Anda bukan PIC.', style: TextStyle(color: Colors.grey)));
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Text('Manage Team', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        // Tambahkan list anggota tim di sini untuk di manage PIC/Ketua
      ],
    );
  }
}