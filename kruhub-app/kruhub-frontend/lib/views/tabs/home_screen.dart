import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/project_state.dart';
import '../../widgets/project_selector_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _summary;
  List<dynamic> _tasks = [];
  List<dynamic> _userProjects = [];
  Map<String, dynamic>? _activeProject;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      // 1. Ambil daftar project milik user
      final projects = await ApiService.getUserTeams();

      if (mounted) {
        setState(() {
          _userProjects = projects;

          if (_userProjects.isNotEmpty) {
            // Pilih project pertama jika belum ada yang dipilih atau project lama sudah tidak ada
            if (_activeProject == null ||
                !_userProjects.any((p) => p['id'].toString() == _activeProject!['id'].toString())) {
              _activeProject = _userProjects.first;
            }
            // Publikasikan ID project aktif ke seluruh aplikasi via ProjectState
            ProjectState.setActiveProject(_activeProject!['id'].toString());
          } else {
            _activeProject = null;
            ProjectState.setActiveProject(null);
          }
        });
      }

      // 2. Ambil summary & tasks jika ada project yang aktif
      if (ApiService.activeProjectId != null) {
        final summary = await ApiService.getDashboardSummary();
        final tasks = await ApiService.getTasks();

        if (mounted) {
          setState(() {
            _summary = summary;
            _tasks = tasks;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _summary = null;
            _tasks = [];
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data beranda: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
                onRefresh: _loadData,
                color: Colors.white,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // HEADER USER PROFILE
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                radius: 24,
                                backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12'),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text('Welcome back', style: TextStyle(color: Colors.grey, fontSize: 13)),
                                  SizedBox(height: 2),
                                  Text('Hello, Timothy 👋', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            decoration: const BoxDecoration(color: Color(0xFF1C1C1E), shape: BoxShape.circle),
                            child: IconButton(
                              icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                              onPressed: () {},
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 20),

                      // SELECTOR PROJECT (DRAFT / ACTIVE PROJECT)
                      ProjectSelectorHeader(
                        userProjects: _userProjects,
                        activeProject: _activeProject,
                        onProjectSelected: (project) {
                          setState(() {
                            _activeProject = project;
                          });
                          // Update state global agar tab lain ikut merefresh data
                          ProjectState.setActiveProject(project['id'].toString());
                          _loadData();
                        },
                        onRefresh: _loadData,
                      ),
                      const SizedBox(height: 16),

                      // RINGKASAN DASHBOARD & UPCOMING DEADLINES
                      if (_userProjects.isNotEmpty && ApiService.activeProjectId != null) ...[
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.25,
                          children: [
                            _buildStatCard(
                              icon: Icons.playlist_add_check,
                              iconBg: const Color(0xFF2C2C2E),
                              iconColor: Colors.white,
                              value: '${_summary?['total_tasks'] ?? 0}',
                              valueColor: Colors.white,
                              label: 'Active Tasks',
                            ),
                            _buildStatCard(
                              icon: Icons.access_time_filled,
                              iconBg: const Color(0xFFFDE8D0),
                              iconColor: const Color(0xFFE67E22),
                              value: '${_summary?['pending_tasks'] ?? 0}',
                              valueColor: const Color(0xFFE67E22),
                              label: 'Awaiting Review',
                            ),
                            _buildStatCard(
                              icon: Icons.people_alt,
                              iconBg: const Color(0xFF2C2C2E),
                              iconColor: Colors.white,
                              value: '${_summary?['total_team_members'] ?? 0}',
                              valueColor: Colors.white,
                              label: 'Crew Members',
                            ),
                            _buildStatCard(
                              icon: Icons.check_circle,
                              iconBg: const Color(0xFFD4F4E2),
                              iconColor: const Color(0xFF2ECC71),
                              value: '${_summary?['completed_tasks'] ?? 0}',
                              valueColor: const Color(0xFF2ECC71),
                              label: 'Completed',
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text('Upcoming Deadlines', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            Text('See all', style: TextStyle(color: Colors.grey, fontSize: 14)),
                          ],
                        ),
                        const SizedBox(height: 12),

                        SizedBox(
                          height: 130,
                          child: _tasks.isEmpty
                              ? const Center(child: Text('Tidak ada tenggat waktu', style: TextStyle(color: Colors.grey)))
                              : ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _tasks.length > 3 ? 3 : _tasks.length,
                                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                                  itemBuilder: (context, index) {
                                    final task = _tasks[index];
                                    return Container(
                                      width: 220,
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(color: const Color(0xFF1C1C1E), borderRadius: BorderRadius.circular(20)),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                decoration: BoxDecoration(color: const Color(0xFF2C2C2E), borderRadius: BorderRadius.circular(12)),
                                                child: Text(task['division'] ?? 'General', style: const TextStyle(color: Colors.white, fontSize: 11)),
                                              ),
                                              const Spacer(),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                decoration: BoxDecoration(color: const Color(0xFF2C2C2E), borderRadius: BorderRadius.circular(12)),
                                                child: Text(task['status'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                                              ),
                                            ],
                                          ),
                                          const Spacer(),
                                          Text(task['title'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              const Icon(Icons.calendar_today_outlined, color: Colors.grey, size: 13),
                                              const SizedBox(width: 6),
                                              Text(task['deadline_date'] ?? '-', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                            ],
                                          )
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String value,
    required Color valueColor,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1C1C1E), borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const Spacer(),
          Text(value, style: TextStyle(color: valueColor, fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}