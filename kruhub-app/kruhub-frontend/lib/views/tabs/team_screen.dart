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
  Map<String, dynamic> _project = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    ProjectState.activeProjectIdNotifier.addListener(_onProjectChanged);
    _fetchProjectData();
  }

  @override
  void dispose() {
    ProjectState.activeProjectIdNotifier.removeListener(_onProjectChanged);
    super.dispose();
  }

  void _onProjectChanged() {
    _fetchProjectData();
  }

  Future<void> _fetchProjectData() async {
    if (ApiService.activeProjectId == null) {
      if (mounted) {
        setState(() {
          _members = [];
          _project = {};
          _isLoading = false;
        });
      }
      return;
    }

    if (mounted) setState(() => _isLoading = true);

    try {
      final project = await ApiService.getTeamDetails();
      final members = await ApiService.getTeamMembers();

      if (mounted) {
        setState(() {
          _project = project is Map ? Map<String, dynamic>.from(project) : {};
          _members = members;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat detail project: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _openProjectSettings() async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: _project['name'] ?? '');
    final descriptionController =
        TextEditingController(text: _project['description'] ?? '');
    final typeController = TextEditingController(text: _project['project_type'] ?? '');
    final statusController =
        TextEditingController(text: _project['project_status'] ?? 'Planning');
    final clientController =
        TextEditingController(text: _project['client_name'] ?? '');
    final budgetController = TextEditingController(text: _project['budget'] ?? '');
    final locationController =
        TextEditingController(text: _project['location'] ?? '');
    final objectiveController =
        TextEditingController(text: _project['objective'] ?? '');
    final scopeController = TextEditingController(text: _project['scope'] ?? '');

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1B1B1D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        bool isSaving = false;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            Future<void> submit() async {
              if (!formKey.currentState!.validate()) return;

              setSheetState(() => isSaving = true);

              final result = await ApiService.updateTeam(
                name: nameController.text,
                description: descriptionController.text,
                projectType: typeController.text,
                projectStatus: statusController.text,
                clientName: clientController.text,
                budget: budgetController.text,
                location: locationController.text,
                objective: objectiveController.text,
                scope: scopeController.text,
              );

              if (!mounted) return;

              setSheetState(() => isSaving = false);

              if (result['success'] == true) {
                if (context.mounted) {
                  Navigator.pop(context, true);
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Project berhasil diperbarui'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result['message'] ?? 'Gagal update project'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            }

            return Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                20,
                16,
                MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Edit Project',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close, color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildField('Nama Project', nameController, required: true),
                      _buildField('Tipe Project', typeController),
                      _buildField('Status Project', statusController),
                      _buildField('Client / Brand', clientController),
                      _buildField('Budget', budgetController),
                      _buildField('Lokasi', locationController),
                      _buildField('Deskripsi', descriptionController, maxLines: 3),
                      _buildField('Tujuan', objectiveController, maxLines: 3),
                      _buildField('Scope', scopeController, maxLines: 4),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: isSaving ? null : submit,
                          icon: isSaving
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.save),
                          label: Text(isSaving ? 'Menyimpan...' : 'Simpan Perubahan'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2C2C2E),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
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
      },
    );

    if (saved == true) {
      await _fetchProjectData();
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
                'Silakan pilih atau buat project terlebih dahulu di menu Home.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFF0F0F10),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Project',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              color: Color(0xFF1C1C1E),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              onPressed: _openProjectSettings,
                              icon: const Icon(
                                Icons.edit_outlined,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: const BoxDecoration(
                              color: Color(0xFF1C1C1E),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.person_add_alt_1_outlined,
                                color: Colors.white,
                              ),
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_isLoading)
                    const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  else
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _fetchProjectData,
                        color: Colors.white,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            _buildProjectSummaryCard(),
                            const SizedBox(height: 20),
                            const Text(
                              'Anggota Tim',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (_members.isEmpty)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 32),
                                  child: Text(
                                    'Tidak ada anggota tim',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              )
                            else
                              ..._members.map((member) {
                                final name = member['name'] ?? 'Unknown';
                                final role =
                                    member['pivot']?['role'] ?? member['role'] ?? 'member';
                                final division = member['division'] ?? 'General';
                                final initial =
                                    name.toString().isNotEmpty ? name[0].toUpperCase() : 'U';

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1C1C1E),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 22,
                                        backgroundColor: const Color(0xFF2C2C2E),
                                        child: Text(
                                          initial,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              name,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Divisi: $division',
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      _buildRoleBadge(role.toString()),
                                    ],
                                  ),
                                );
                              }),
                          ],
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

  Widget _buildProjectSummaryCard() {
    final name = _project['name'] ?? 'Project';
    final type = _project['project_type'] ?? 'Belum diisi';
    final status = _project['project_status'] ?? 'Planning';
    final client = _project['client_name'] ?? 'Belum diisi';
    final location = _project['location'] ?? 'Belum diisi';
    final budget = _project['budget'] ?? 'Belum diisi';
    final objective = _project['objective'] ?? 'Belum ada objective';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDE8D0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    color: Color(0xFFE67E22),
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _infoChip('Jenis', type),
              _infoChip('Client', client),
              _infoChip('Lokasi', location),
              _infoChip('Budget', budget),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Objective',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(
            objective,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(color: Colors.white, fontSize: 11),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    bool required = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        minLines: maxLines,
        maxLines: maxLines > 1 ? maxLines : 1,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          filled: true,
          fillColor: const Color(0xFF18181A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        validator: required
            ? (value) => (value == null || value.trim().isEmpty)
                ? '$label wajib diisi'
                : null
            : null,
      ),
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
    } else if (role.toLowerCase().contains('ketua') ||
        role.toLowerCase().contains('pic')) {
      bg = const Color(0xFFFDE8D0);
      text = const Color(0xFFE67E22);
    } else {
      bg = const Color(0xFF2C2C2E);
      text = Colors.white;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Text(
        displayRole,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}