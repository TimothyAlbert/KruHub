import 'package:flutter/material.dart';

class AssetsScreen extends StatelessWidget {
  final String role;
  const AssetsScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Row Statistik Aset 1 Baris[cite: 4]
          Row(
            children: [
              Expanded(child: _buildAssetStat('48', 'Total Assets', Icons.inventory_2, Colors.grey)),
              const SizedBox(width: 8),
              Expanded(child: _buildAssetStat('5', 'In Maintenance', Icons.build, Colors.orange)), //[cite: 4]
              const SizedBox(width: 8),
              Expanded(child: _buildAssetStat('31', 'Available', Icons.check_circle, Colors.green)), //[cite: 4]
            ],
          ),
          const SizedBox(height: 24),
          const Text('All Assets', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)), //[cite: 4]
          const SizedBox(height: 16),
          _buildAssetCard('Camera', 'In Use', 'ARRI Alexa Mini', 'Studio A', Colors.grey), //[cite: 4]
          _buildAssetCard('Production', 'Available', 'Lighting Truss Kit', 'Warehouse', Colors.green), //[cite: 4]
        ],
      ),
      // RBAC: Hanya Ketua Pelaksana yang bisa tambah aset
      floatingActionButton: role == 'ketua_pelaksana'
          ? FloatingActionButton(
              backgroundColor: Colors.blueAccent,
              onPressed: () {},
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildAssetStat(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color == Colors.grey ? Colors.white : color)),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildAssetCard(String category, String status, String name, String location, Color statusColor) {
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
              Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: Colors.grey.withOpacity(0.2), borderRadius: BorderRadius.circular(12)), child: Text(category, style: const TextStyle(fontSize: 12, color: Colors.white))),
              Row(
                children: [
                  Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: statusColor.withOpacity(0.2), borderRadius: BorderRadius.circular(12)), child: Text(status, style: TextStyle(fontSize: 12, color: statusColor, fontWeight: FontWeight.bold))),
                  // RBAC Edit Icon
                  if (role == 'ketua_pelaksana') ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.edit, color: Colors.grey, size: 16),
                  ]
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          Row(children: [const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey), const SizedBox(width: 6), Text(location, style: const TextStyle(color: Colors.grey, fontSize: 12))]),
        ],
      ),
    );
  }
}