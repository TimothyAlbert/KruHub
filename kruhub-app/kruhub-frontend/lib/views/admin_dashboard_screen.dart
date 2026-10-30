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

  Future<void> _openUserDialog({Map<String, dynamic>? user}) async {
    final isEdit = user != null;
    final nameCtrl = TextEditingController(text: user?['name'] ?? '');
    final emailCtrl = TextEditingController(text: user?['email'] ?? '');
    final passwordCtrl = TextEditingController();
    final divisionCtrl = TextEditingController(text: user?['division'] ?? '');
    final positionCtrl = TextEditingController(text: user?['position'] ?? '');
    final phoneCtrl = TextEditingController(text: user?['phone'] ?? '');
    final bioCtrl = TextEditingController(text: user?['bio'] ?? '');
    String role = (user?['role'] ?? 'user').toString();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1C1C1E),
              title: Text(isEdit ? 'Edit User' : 'Tambah User Baru', style: const TextStyle(color: Colors.white)),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 420,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameCtrl,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(labelText: 'Nama', labelStyle: TextStyle(color: Colors.grey)),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: emailCtrl,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(labelText: 'Email', labelStyle: TextStyle(color: Colors.grey)),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: passwordCtrl,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: isEdit ? 'Password Baru (opsional)' : 'Password',
                          labelStyle: const TextStyle(color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        initialValue: ['admin', 'user'].contains(role) ? role : 'user',
                        dropdownColor: const Color(0xFF1C1C1E),
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(labelText: 'Role', labelStyle: TextStyle(color: Colors.grey)),
                        items: const [
                          DropdownMenuItem(value: 'user', child: Text('User')),
                          DropdownMenuItem(value: 'admin', child: Text('Admin')),
                        ],
                        onChanged: (value) => setDialogState(() => role = value ?? 'user'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: divisionCtrl,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(labelText: 'Division', labelStyle: TextStyle(color: Colors.grey)),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: positionCtrl,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(labelText: 'Position', labelStyle: TextStyle(color: Colors.grey)),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: phoneCtrl,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(labelText: 'Phone', labelStyle: TextStyle(color: Colors.grey)),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: bioCtrl,
                        maxLines: 3,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(labelText: 'Bio', labelStyle: TextStyle(color: Colors.grey)),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Batal', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E88E5)),
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(isEdit ? 'Simpan' : 'Buat Akun', style: const TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != true) return;

    final payload = {
      'name': nameCtrl.text.trim(),
      'email': emailCtrl.text.trim(),
      'password': passwordCtrl.text.trim(),
      'role': role,
      'division': divisionCtrl.text.trim(),
      'position': positionCtrl.text.trim(),
      'phone': phoneCtrl.text.trim(),
      'bio': bioCtrl.text.trim(),
    };

    final name = (payload['name'] ?? '').toString();
    final email = (payload['email'] ?? '').toString();
    final password = (payload['password'] ?? '').toString();

    if (name.isEmpty || email.isEmpty || (!isEdit && password.isEmpty)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nama, email, dan password wajib diisi.'), backgroundColor: Colors.red),
        );
      }
      return;
    }

    if (isEdit) {
      final selectedUser = user;
      if (selectedUser == null) return;

      final response = await ApiService.updateUser(
        userId: (selectedUser['id'] as num).toInt(),
        name: name,
        email: email,
        password: password.isEmpty ? null : password,
        role: payload['role']?.toString(),
        division: payload['division']?.toString(),
        position: payload['position']?.toString(),
        phone: payload['phone']?.toString(),
        bio: payload['bio']?.toString(),
      );
      if (mounted) {
        if (response['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User berhasil diperbarui.'), backgroundColor: Colors.green),
          );
          _loadAdminData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? 'Gagal memperbarui user'), backgroundColor: Colors.red),
          );
        }
      }
      return;
    }

    final response = await ApiService.createUser(
      name: name,
      email: email,
      password: password,
      role: payload['role']?.toString() ?? 'user',
      division: payload['division']?.toString(),
      position: payload['position']?.toString(),
      phone: payload['phone']?.toString(),
      bio: payload['bio']?.toString(),
    );

    if (mounted) {
      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Akun user/admin baru berhasil dibuat.'), backgroundColor: Colors.green),
        );
        _loadAdminData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Gagal membuat user'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteUser(Map<String, dynamic> user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        title: const Text('Hapus User', style: TextStyle(color: Colors.white)),
        content: Text('Yakin ingin menghapus ${user['name']} dari sistem?', style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal', style: TextStyle(color: Colors.grey))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true) return;

    final response = await ApiService.deleteUser((user['id'] as num).toInt());
    if (mounted) {
      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'User berhasil dihapus'), backgroundColor: Colors.green),
        );
        _loadAdminData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Gagal menghapus user'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final stats = [
      StatCard(label: 'Total Project', value: '12', color: const Color(0xFF4FC3F7)),
      StatCard(label: 'Project Aktif', value: '8', color: const Color(0xFF66BB6A)),
      StatCard(label: 'Member', value: '${_allUsers.length}', color: const Color(0xFFFFC107)),
      StatCard(label: 'Task Pending', value: '14', color: const Color(0xFFEF5350)),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openUserDialog(),
        backgroundColor: const Color(0xFF1E88E5),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Tambah User'),
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
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E88E5), Color(0xFF0F172A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFF64B5F6), width: 1),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.admin_panel_settings_rounded, color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Admin Control Center', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                            SizedBox(height: 6),
                            Text('Global access • system monitoring • recovery mode', style: TextStyle(color: Color(0xFFE3F2FD), fontSize: 12)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.greenAccent, width: 1),
                        ),
                        child: const Text('SUPER ADMIN', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
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
                  children: stats.map((item) => StatCardView(item: item)).toList(),
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
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _roleColor(role),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(role, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                  ),
                                  const SizedBox(width: 8),
                                  PopupMenuButton<String>(
                                    color: const Color(0xFF1C1C1E),
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        _openUserDialog(user: user);
                                      } else if (value == 'delete') {
                                        _deleteUser(user);
                                      }
                                    },
                                    itemBuilder: (context) => const [
                                      PopupMenuItem(value: 'edit', child: Text('Edit User', style: TextStyle(color: Colors.white))),
                                      PopupMenuItem(value: 'delete', child: Text('Delete User', style: TextStyle(color: Colors.redAccent))),
                                    ],
                                    icon: const Icon(Icons.more_vert, color: Colors.white),
                                  ),
                                ],
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

class StatCard {
  final String label;
  final String value;
  final Color color;

  const StatCard({required this.label, required this.value, required this.color});
}

class StatCardView extends StatelessWidget {
  final StatCard item;

  const StatCardView({required this.item});

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
