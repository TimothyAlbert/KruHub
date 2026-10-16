import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/api_service.dart';
import '../../services/project_state.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final user = await ApiService.getUserProfile();
      if (mounted) {
        setState(() {
          _user = user;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat profil: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  void _handleLogout() async {
    await ApiService.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F10),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : RefreshIndicator(
                onRefresh: _fetchProfile,
                color: Colors.white,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(radius: 24, backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12')),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Welcome back', style: TextStyle(color: Colors.grey, fontSize: 13)),
                                  const SizedBox(height: 2),
                                  Text('Hello, ${_user?['name'] ?? 'User'} 👋', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            decoration: const BoxDecoration(color: Color(0xFF1C1C1E), shape: BoxShape.circle),
                            child: IconButton(icon: const Icon(Icons.notifications_outlined, color: Colors.white), onPressed: () {}),
                          )
                        ],
                      ),
                      const SizedBox(height: 20),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: const Color(0xFF1C1C1E), borderRadius: BorderRadius.circular(20)),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const CircleAvatar(radius: 32, backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12')),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(_user?['name'] ?? '-', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 2),
                                      Text(_user?['role'] ?? 'Member', style: const TextStyle(color: Colors.grey, fontSize: 14)),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(color: Color(0xFF2C2C2E), shape: BoxShape.circle),
                                  child: const Icon(Icons.edit_outlined, color: Colors.white, size: 18),
                                )
                              ],
                            ),
                            const SizedBox(height: 16),

                            // KARTU ACTIVE PROJECT ID (OTOMATIS MENDENGARKAN DROPDOWN HOME)
                            ValueListenableBuilder<String?>(
                              valueListenable: ProjectState.activeProjectIdNotifier,
                              builder: (context, activeId, child) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(color: const Color(0xFF2C2C2E), borderRadius: BorderRadius.circular(12)),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('Active Project ID', style: TextStyle(color: Colors.grey, fontSize: 11)),
                                          const SizedBox(height: 2),
                                          Text(activeId ?? 'No Project Selected', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                      if (activeId != null)
                                        InkWell(
                                          onTap: () {
                                            Clipboard.setData(ClipboardData(text: activeId));
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Project ID berhasil disalin!'), duration: Duration(seconds: 2)),
                                            );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(color: const Color(0xFF1C1C1E), borderRadius: BorderRadius.circular(8)),
                                            child: Row(
                                              children: const [
                                                Icon(Icons.copy, color: Colors.white, size: 14),
                                                SizedBox(width: 6),
                                                Text('Copy', style: TextStyle(color: Colors.white, fontSize: 12)),
                                              ],
                                            ),
                                          ),
                                        )
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      const Text('Account Details', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: const Color(0xFF1C1C1E), borderRadius: BorderRadius.circular(20)),
                        child: Column(
                          children: [
                            _buildAccountRow(Icons.person_outline, 'Full Name', _user?['name'] ?? '-'),
                            const SizedBox(height: 16),
                            _buildAccountRow(Icons.verified_user_outlined, 'Role', _user?['role'] ?? 'Member'),
                            const SizedBox(height: 16),
                            _buildAccountRow(Icons.movie_creation_outlined, 'Division', _user?['division'] ?? 'General'),
                            const SizedBox(height: 16),
                            _buildAccountRow(Icons.email_outlined, 'Email', _user?['email'] ?? '-'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _handleLogout,
                          icon: const Icon(Icons.logout, color: Colors.white),
                          label: const Text('Keluar / Logout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent.withOpacity(0.8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildAccountRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: const Color(0xFF2C2C2E), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: Colors.grey, size: 20),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        )
      ],
    );
  }
}