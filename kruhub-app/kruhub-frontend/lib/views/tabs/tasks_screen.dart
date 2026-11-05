import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/notification_service.dart';
import '../../services/project_state.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  List<dynamic> _tasks = [];
  bool _isLoading = true;
  String? _selectedDivision;
  String? _selectedStatus;
  String? _selectedApprovalStatus;
  String _searchQuery = '';

  final List<String> _divisionOptions = const [
    'General',
    'Engineering',
    'Marketing',
    'Finance',
    'Operations',
    'Product',
  ];
  final List<String> _statusOptions = const ['In Progress', 'Review', 'Blocked', 'Completed'];
  final List<String> _approvalOptions = const ['Pending', 'Approved', 'Rejected'];

  @override
  void initState() {
    super.initState();
    ProjectState.activeProjectIdNotifier.addListener(_onProjectChanged);
    _fetchTasks();
  }

  @override
  void dispose() {
    ProjectState.activeProjectIdNotifier.removeListener(_onProjectChanged);
    super.dispose();
  }

  void _onProjectChanged() => _fetchTasks();

  Future<void> _fetchTasks() async {
    if (ApiService.activeProjectId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    if (mounted) setState(() => _isLoading = true);

    try {
      final tasks = await ApiService.getTasks(
        division: _selectedDivision,
        status: _selectedStatus,
        approvalStatus: _selectedApprovalStatus,
        search: _searchQuery,
      );
      if (mounted) {
        setState(() {
          _tasks = tasks;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat tugas: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  Future<void> _openFilterSheet() async {
    final result = await showModalBottomSheet<Map<String, String?>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1B1B1D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        String? tempDivision = _selectedDivision;
        String? tempStatus = _selectedStatus;
        String? tempApprovalStatus = _selectedApprovalStatus;
        String tempSearch = _searchQuery;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Filter Tugas', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: TextEditingController(text: tempSearch),
                    onChanged: (value) => tempSearch = value,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Cari tugas',
                      labelStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: tempDivision,
                    dropdownColor: const Color(0xFF1B1B1D),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Divisi', labelStyle: TextStyle(color: Colors.grey)),
                    items: ['Semua Divisi', ..._divisionOptions]
                        .map((value) => DropdownMenuItem<String>(
                              value: value == 'Semua Divisi' ? null : value,
                              child: Text(value == 'Semua Divisi' ? 'Semua Divisi' : value),
                            ))
                        .toList(),
                    onChanged: (value) => setSheetState(() => tempDivision = value),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: tempStatus,
                    dropdownColor: const Color(0xFF1B1B1D),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Status', labelStyle: TextStyle(color: Colors.grey)),
                    items: ['Semua Status', ..._statusOptions]
                        .map((value) => DropdownMenuItem<String>(
                              value: value == 'Semua Status' ? null : value,
                              child: Text(value == 'Semua Status' ? 'Semua Status' : value),
                            ))
                        .toList(),
                    onChanged: (value) => setSheetState(() => tempStatus = value),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: tempApprovalStatus,
                    dropdownColor: const Color(0xFF1B1B1D),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Status Approval',
                      labelStyle: TextStyle(color: Colors.grey),
                    ),
                    items: ['Semua Approval', ..._approvalOptions]
                        .map((value) => DropdownMenuItem<String>(
                              value: value == 'Semua Approval' ? null : value,
                              child: Text(value == 'Semua Approval' ? 'Semua Approval' : value),
                            ))
                        .toList(),
                    onChanged: (value) => setSheetState(() => tempApprovalStatus = value),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            tempDivision = null;
                            tempStatus = null;
                            tempApprovalStatus = null;
                            tempSearch = '';
                            Navigator.pop(context, {
                              'division': null,
                              'status': null,
                              'approval_status': null,
                              'search': '',
                            });
                          },
                          child: const Text('Reset'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, {
                            'division': tempDivision,
                            'status': tempStatus,
                            'approval_status': tempApprovalStatus,
                            'search': tempSearch,
                          }),
                          child: const Text('Terapkan'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedDivision = result['division'];
        _selectedStatus = result['status'];
        _selectedApprovalStatus = result['approval_status'];
        _searchQuery = result['search'] ?? '';
      });
      await _fetchTasks();
    }
  }

  Future<void> _approveTask(Map<String, dynamic> task, String approvalStatus) async {
    final taskId = task['id'];
    if (taskId == null) return;

    try {
      final result = await ApiService.approveTask(taskId, approvalStatus);
      if (!mounted) return;
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task ${approvalStatus == 'Approved' ? 'disetujui' : 'ditolak'}.'),
            backgroundColor: approvalStatus == 'Approved' ? Colors.green : Colors.orange,
          ),
        );
        await NotificationService.show(
          'Task ${approvalStatus == 'Approved' ? 'Disetujui' : 'Ditolak'}',
          '${task['title'] ?? 'Task'} telah ${approvalStatus == 'Approved' ? 'disetujui' : 'ditolak'}.',
        );
        await _fetchTasks();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Gagal mengubah approval task'), backgroundColor: Colors.redAccent),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghubungi server: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  void _showTaskDetail(Map<String, dynamic> task) {
    final title = task['title'] ?? 'Tanpa judul';
    final status = task['status'] ?? 'In Progress';
    final division = task['division'] ?? 'General';
    final approval = task['approval_status'] ?? 'Pending';
    final assignee = task['assignee'] is Map ? task['assignee']['name'] ?? 'Belum ditugaskan' : 'Belum ditugaskan';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1B1B1D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Detail Tugas', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _infoRow('Divisi', division),
            _infoRow('Status', status),
            _infoRow('Approval', approval),
            _infoRow('Penanggung Jawab', assignee),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _approveTask(task, 'Rejected');
                    },
                    icon: const Icon(Icons.close),
                    label: const Text('Tolak'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _approveTask(task, 'Approved');
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Approve'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
                        child: IconButton(icon: const Icon(Icons.notifications_outlined, color: Colors.white), onPressed: () {}),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildMiniStat('${_tasks.length}', 'Active Tasks', Icons.playlist_add_check, const Color(0xFF2C2C2E), Colors.white, Colors.white)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildMiniStat('${_tasks.where((t) => t['status'] == 'Review').length}', 'Awaiting Review', Icons.access_time_filled, const Color(0xFFFDE8D0), const Color(0xFFE67E22), const Color(0xFFE67E22))),
                      const SizedBox(width: 8),
                      Expanded(child: _buildMiniStat('${_tasks.where((t) => t['status'] == 'Completed').length}', 'Completed', Icons.check_circle, const Color(0xFFD4F4E2), const Color(0xFF2ECC71), const Color(0xFF2ECC71))),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('All Tasks', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      TextButton.icon(
                        onPressed: _openFilterSheet,
                        icon: const Icon(Icons.filter_list, color: Colors.grey),
                        label: const Text('Filter', style: TextStyle(color: Colors.grey)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_selectedDivision != null || _selectedStatus != null || _selectedApprovalStatus != null || _searchQuery.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (_selectedDivision != null) _buildFilterChip('Divisi: $_selectedDivision'),
                        if (_selectedStatus != null) _buildFilterChip('Status: $_selectedStatus'),
                        if (_selectedApprovalStatus != null) _buildFilterChip('Approval: $_selectedApprovalStatus'),
                        if (_searchQuery.isNotEmpty) _buildFilterChip('Cari: $_searchQuery'),
                      ],
                    ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator(color: Colors.white))
                        : RefreshIndicator(
                            onRefresh: _fetchTasks,
                            color: Colors.white,
                            child: _tasks.isEmpty
                                ? ListView(
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    children: const [
                                      SizedBox(height: 100),
                                      Center(child: Text('Tidak ada tugas ditemukan di project ini', style: TextStyle(color: Colors.grey))),
                                    ],
                                  )
                                : ListView.builder(
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    itemCount: _tasks.length,
                                    itemBuilder: (context, index) {
                                      final task = _tasks[index];
                                      final title = task['title'] ?? '';
                                      final division = task['division'] ?? 'General';
                                      final status = task['status'] ?? 'In Progress';
                                      final approval = task['approval_status'] ?? 'Pending';
                                      final date = task['deadline_date'] ?? '-';

                                      return GestureDetector(
                                        onTap: () => _showTaskDetail(task),
                                        child: Container(
                                          margin: const EdgeInsets.only(bottom: 12),
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(color: const Color(0xFF1C1C1E), borderRadius: BorderRadius.circular(20)),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                    decoration: BoxDecoration(color: const Color(0xFF2C2C2E), borderRadius: BorderRadius.circular(12)),
                                                    child: Text(division, style: const TextStyle(color: Colors.white, fontSize: 12)),
                                                  ),
                                                  _buildStatusBadge(status),
                                                ],
                                              ),
                                              const SizedBox(height: 12),
                                              Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                              const SizedBox(height: 12),
                                              Row(
                                                children: [
                                                  const Icon(Icons.calendar_today_outlined, color: Colors.grey, size: 14),
                                                  const SizedBox(width: 6),
                                                  Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                                ],
                                              ),
                                              const SizedBox(height: 12),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  _buildApprovalBadge(approval),
                                                  Row(
                                                    children: [
                                                      TextButton(
                                                        onPressed: () => _approveTask(task, 'Rejected'),
                                                        child: const Text('Tolak', style: TextStyle(color: Colors.orange)),
                                                      ),
                                                      TextButton(
                                                        onPressed: () => _approveTask(task, 'Approved'),
                                                        child: const Text('Approve', style: TextStyle(color: Colors.green)),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
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

  Widget _buildFilterChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
    );
  }

  Widget _buildMiniStat(String val, String label, IconData icon, Color iconBg, Color iconColor, Color valColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF1C1C1E), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(height: 8),
          Text(val, style: TextStyle(color: valColor, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg = const Color(0xFF2C2C2E);
    Color text = Colors.grey;

    if (status == 'Review') {
      bg = const Color(0xFFFDE8D0);
      text = const Color(0xFFE67E22);
    } else if (status == 'Blocked') {
      bg = const Color(0xFFFDE8E8);
      text = const Color(0xFFE74C3C);
    } else if (status == 'Completed') {
      bg = const Color(0xFFD4F4E2);
      text = const Color(0xFF2ECC71);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(status, style: TextStyle(color: text, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildApprovalBadge(String approval) {
    Color bg = const Color(0xFF2C2C2E);
    Color text = Colors.white;
    if (approval == 'Approved') {
      bg = const Color(0xFFD4F4E2);
      text = const Color(0xFF2ECC71);
    } else if (approval == 'Rejected') {
      bg = const Color(0xFFFDE8E8);
      text = const Color(0xFFE74C3C);
    } else {
      bg = const Color(0xFFFDE8D0);
      text = const Color(0xFFE67E22);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Text(approval, style: TextStyle(color: text, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
