import 'package:flutter/material.dart';
import '../views/screens/create_project_screen.dart';
import '../views/screens/join_project_screen.dart';

class ProjectSelectorHeader extends StatelessWidget {
  final List<dynamic> userProjects;
  final Map<String, dynamic>? activeProject;
  final Function(Map<String, dynamic>) onProjectSelected;
  final VoidCallback onRefresh;

  const ProjectSelectorHeader({
    super.key,
    required this.userProjects,
    required this.activeProject,
    required this.onProjectSelected,
    required this.onRefresh,
  });

  void _openCreateProject(BuildContext context) async {
    final res = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateProjectScreen()),
    );
    if (res == true) onRefresh();
  }

  void _openJoinProject(BuildContext context) async {
    final res = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => JoinProjectScreen()),
    );
    if (res == true) onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    if (userProjects.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: const Color(0xFF1C1C1E), borderRadius: BorderRadius.circular(20)),
        child: Column(
          children: [
            const Icon(Icons.movie_filter_outlined, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            const Text(
              'Kamu belum memiliki/tergabung dalam sebuah project',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => _openCreateProject(context),
                icon: const Icon(Icons.add, color: Colors.black),
                label: const Text('Create a project', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () => _openJoinProject(context),
                icon: const Icon(Icons.group_add_outlined, color: Colors.white),
                label: const Text('Join a project', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.grey),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFF1C1C1E), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFF2C2C2E), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.movie_creation_outlined, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Current Project', style: TextStyle(color: Colors.grey, fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(
                    activeProject?['name'] ?? 'Pilih Project',
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
            color: const Color(0xFF1C1C1E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onSelected: (value) {
              if (value == 'CREATE') {
                _openCreateProject(context);
              } else if (value == 'JOIN') {
                _openJoinProject(context);
              } else {
                final selected = userProjects.firstWhere((p) => p['id'].toString() == value, orElse: () => null);
                if (selected != null) onProjectSelected(selected);
              }
            },
            itemBuilder: (context) {
              final List<PopupMenuEntry<String>> items = [];

              for (var project in userProjects) {
                items.add(
                  PopupMenuItem<String>(
                    value: project['id'].toString(),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check,
                          size: 18,
                          color: activeProject?['id'] == project['id'] ? Colors.white : Colors.transparent,
                        ),
                        const SizedBox(width: 8),
                        Text(project['name'] ?? '', style: const TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                );
              }

              items.add(const PopupMenuDivider(height: 1));
              items.add(
                const PopupMenuItem<String>(
                  value: 'CREATE',
                  child: Row(
                    children: [
                      Icon(Icons.add, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text('Create new project', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              );
              items.add(
                const PopupMenuItem<String>(
                  value: 'JOIN',
                  child: Row(
                    children: [
                      Icon(Icons.group_add_outlined, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text('Join new project', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              );

              return items;
            },
          )
        ],
      ),
    );
  }
}