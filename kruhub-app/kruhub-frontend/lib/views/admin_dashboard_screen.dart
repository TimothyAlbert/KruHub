import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _isLoadingUsers = true;
  List<dynamic> _allUsers = [];

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    setState(() => _isLoadingUsers = true);
    final users = await ApiService.getAllUsers();
    if (mounted) {
      setState(() {
        _allUsers = users;
        _isLoadingUsers = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final stats = [
      _StatCard(label: 'Total Project', value: '12', color: const Color(0xFF4FC3F7)),
      _StatCard(label: 'Project Aktif', value: '8', color: const Color(0xFF66BB6A)),
      _StatCard(label: 'Member', value: '${_allUsers.length}', color: const Color(0xFFFFC107)),
      _StatCard(label: 'Task Pending', value: '14', color: const Color(0xFFEF5350)),
    ];

    final projects = [
      {'name': 'Skyline Feature Film', 'status': 'Active', 'members': 12},
      {'name': 'Nusantara Documentary', 'status': 'Review', 'members': 8},
      {'name': 'Urban Pulse Campaign', 'status': 'Active', 'members': 9},
      {'name': 'KRU Internal Ops', 'status': 'Maintenance', 'members': 5},
    ];

    final tasks = [
      {'title': 'Finalisasi storyboarding scene 5-9', 'status': 'In Progress'},
      {'title': 'Approve asset design terbaru', 'status': 'Review'},
      {'title': 'Persetujuan vendor lighting', 'status': 'Blocked'},
      {'title': 'Update schedule produksi', 'status': 'Completed'},
    ];

    final assets = [
      {'name': 'ARRI Alexa Mini LF', 'category': 'Kamera', 'status': 'In Use'},
      {'name': 'Sony A7S III', 'category': 'Kamera', 'status': 'Available'},
      {'name': 'Softbox 3x4', 'category': 'Lighting', 'status': 'Maintenance'},
      {'name': 'Boom Mic Wireless', 'category': 'Audio', 'status': 'Available'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F10),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F10),
        foregroundColor: Colors.white,
        title: const Text('Admin Dashboard'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadAdminData,
          color: Colors.white,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1E),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: const [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: Color(0xFF4FC3F7),
                        child: Icon(Icons.admin_panel_settings_rounded, color: Colors.black),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('KruHub Backup Admin', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            SizedBox(height: 4),
                            Text('Monitoring & recovery center', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  childAspectRatio: 1.35,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  physics: const NeverScrollableScrollPhysics(),
                  children: stats.map((item) => _StatCardView(item: item)).toList(),
                ),
                const SizedBox(height: 24),
                const Text('Semua User Terdaftar', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1E),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: _isLoadingUsers
                      ? const Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(child: CircularProgressIndicator(color: Colors.white)),
                        )
                      : ListView.separated(
                          itemCount: _allUsers.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          separatorBuilder: (_, __) => const Divider(color: Color(0xFF2C2C2E), height: 1),
                          itemBuilder: (context, index) {
                            final user = _allUsers[index];
                            final role = (user['role'] ?? 'member').toString();
                            final division = (user['division'] ?? 'General').toString();
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFF4FC3F7),
                                child: Text((user['name'] ?? 'U').toString().substring(0, 1).toUpperCase(), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                              ),
                              title: Text((user['name'] ?? '-').toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                              subtitle: Text('${user['email'] ?? '-'} • $division', style: const TextStyle(color: Colors.grey)),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _roleColor(role),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(role, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 24),
                const Text('Project Terbaru', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1E),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: ListView.separated(
                    itemCount: projects.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    separatorBuilder: (_, __) => const Divider(color: Color(0xFF2C2C2E), height: 1),
                    itemBuilder: (context, index) {
                      final project = projects[index];
                      return ListTile(
                        title: Text(project['name'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        subtitle: Text('${project['members']} member', style: const TextStyle(color: Colors.grey)),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _statusColor(project['status'] as String),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(project['status'] as String, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Task Terbaru', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1E),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: ListView.separated(
                    itemCount: tasks.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    separatorBuilder: (_, __) => const Divider(color: Color(0xFF2C2C2E), height: 1),
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return ListTile(
                        title: Text(task['title'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _statusColor(task['status'] as String),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(task['status'] as String, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Asset Terbaru', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1E),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: ListView.separated(
                    itemCount: assets.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    separatorBuilder: (_, __) => const Divider(color: Color(0xFF2C2C2E), height: 1),
                    itemBuilder: (context, index) {
                      final asset = assets[index];
                      return ListTile(
                        title: Text(asset['name'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        subtitle: Text(asset['category'] as String, style: const TextStyle(color: Colors.grey)),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _statusColor(asset['status'] as String),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(asset['status'] as String, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _roleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return const Color(0xFF4FC3F7);
      case 'project_lead':
      case 'owner':
        return const Color(0xFF66BB6A);
      case 'division_lead':
        return const Color(0xFFFFC107);
      default:
        return const Color(0xFF455A64);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Active':
      case 'Completed':
      case 'Available':
        return const Color(0xFF2E7D32);
      case 'Review':
      case 'In Progress':
        return const Color(0xFFFFA000);
      case 'Blocked':
      case 'Maintenance':
        return const Color(0xFFD32F2F);
      default:
        return const Color(0xFF455A64);
    }
  }
}

class _StatCard {
  final String label;
  final String value;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.color});
}

class _StatCardView extends StatelessWidget {
  final _StatCard item;

  const _StatCardView({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(Icons.trending_up_rounded, color: item.color),
            ),
          ),
          const SizedBox(height: 14),
          Text(item.label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 8),
          Text(item.value, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
