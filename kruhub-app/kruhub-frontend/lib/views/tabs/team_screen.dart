import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/project_state.dart';

class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key});

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  List<dynamic> _members = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    ProjectState.activeProjectIdNotifier.addListener(_onProjectChanged);
    _fetchMembers();
  }

  @override
  void dispose() {
    ProjectState.activeProjectIdNotifier.removeListener(_onProjectChanged);
    super.dispose();
  }

  void _onProjectChanged() {
    _fetchMembers();
  }

  Future<void> _fetchMembers() async {
    if (ApiService.activeProjectId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    if (mounted) setState(() => _isLoading = true);

    try {
      final members = await ApiService.getTeamMembers();
      if (mounted) {
        setState(() {
          _members = members;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat anggota tim: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: ProjectState.activeProjectIdNotifier,
      builder: (context, activeId, child) {
        if (activeId == null) {
          return const Scaffold(
            backgroundColor: Color(0xFF0F0F10),
            body: Center(
              child: Text(
                "Silakan pilih atau buat project terlebih dahulu di menu Home.",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFF0F0F10),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Anggota Tim', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      Container(
                        decoration: const BoxDecoration(color: Color(0xFF1C1C1E), shape: BoxShape.circle),
                        child: IconButton(icon: const Icon(Icons.person_add_alt_1_outlined, color: Colors.white), onPressed: () {}),
                      )
                    ],
                  ),
                  const SizedBox(height: 20),

                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator(color: Colors.white))
                        : RefreshIndicator(
                            onRefresh: _fetchMembers,
                            color: Colors.white,
                            child: _members.isEmpty
                                ? ListView(
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    children: const [
                                      SizedBox(height: 100),
                                      Center(child: Text('Tidak ada anggota tim', style: TextStyle(color: Colors.grey))),
                                    ],
                                  )
                                : ListView.builder(
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    itemCount: _members.length,
                                    itemBuilder: (context, index) {
                                      final member = _members[index];
                                      final name = member['name'] ?? 'Unknown';
                                      
                                      // Prioritaskan membaca role dari pivot table
                                      final role = member['pivot']?['role'] ?? member['role'] ?? 'member';
                                      final division = member['division'] ?? 'General';
                                      final initial = name.toString().isNotEmpty ? name[0].toUpperCase() : 'U';

                                      return Container(
                                        margin: const EdgeInsets.only(bottom: 12),
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(color: const Color(0xFF1C1C1E), borderRadius: BorderRadius.circular(20)),
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 22,
                                              backgroundColor: const Color(0xFF2C2C2E),
                                              child: Text(initial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(name, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                                  const SizedBox(height: 4),
                                                  Text('Divisi: $division', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                                ],
                                              ),
                                            ),
                                            _buildRoleBadge(role.toString()),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoleBadge(String role) {
    Color bg = const Color(0xFF2C2C2E);
    Color text = Colors.grey;
    String displayRole = role.toUpperCase();

    if (role.toLowerCase() == 'owner') {
      bg = const Color(0xFFFDE8D0);
      text = const Color(0xFFE67E22);
      displayRole = 'OWNER';
    } else if (role.toLowerCase().contains('ketua') || role.toLowerCase().contains('pic')) {
      bg = const Color(0xFFFDE8D0);
      text = const Color(0xFFE67E22);
    } else {
      bg = const Color(0xFF2C2C2E);
      text = Colors.white;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Text(displayRole, style: TextStyle(color: text, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}