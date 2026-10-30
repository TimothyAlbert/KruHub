import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class CreateProjectScreen extends StatefulWidget {
  const CreateProjectScreen({super.key});

  @override
  State<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _clientController = TextEditingController();
  final _budgetController = TextEditingController();
  final _locationController = TextEditingController();
  final _projectTypeController = TextEditingController();
  final _statusController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _objectiveController = TextEditingController();
  final _scopeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _roleController = TextEditingController();

  final List<String> _roles = ['Owner', 'Project Lead', 'Division Lead', 'Member'];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _statusController.text = 'Planning';
    _projectTypeController.text = 'Product';
  }

  void _addRole() {
    final roleText = _roleController.text.trim();
    if (roleText.isNotEmpty && !_roles.contains(roleText)) {
      setState(() {
        _roles.add(roleText);
        _roleController.clear();
      });
    }
  }

  void _removeRole(String role) {
    if (_roles.length > 1) {
      setState(() {
        _roles.remove(role);
      });
    }
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      controller.text = picked.toIso8601String().split('T').first;
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final res = await ApiService.createTeam(
      name: _nameController.text.trim(),
      teamCode: '',
      description: _descriptionController.text.trim(),
      projectType: _projectTypeController.text.trim(),
      projectStatus: _statusController.text.trim(),
      clientName: _clientController.text.trim(),
      budget: _budgetController.text.trim(),
      startDate: _startDateController.text.trim(),
      endDate: _endDateController.text.trim(),
      location: _locationController.text.trim(),
      objective: _objectiveController.text.trim(),
      scope: _scopeController.text.trim(),
      roles: _roles,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (res['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Project berhasil dibuat!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'Gagal membuat project'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F10),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F10),
        elevation: 0,
        title: const Text('Create a Project', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel('Nama Project'),
                _buildTextField(_nameController, 'Contoh: Skyline Feature Film', validator: (v) => v!.isEmpty ? 'Nama project wajib diisi' : null),
                const SizedBox(height: 16),

                _buildLabel('Tipe Project'),
                _buildTextField(_projectTypeController, 'Contoh: Product / Campaign / Internal'),
                const SizedBox(height: 16),

                _buildLabel('Client / Brand'),
                _buildTextField(_clientController, 'Contoh: PT Maju Bersama'),
                const SizedBox(height: 16),

                _buildLabel('Status Project'),
                _buildTextField(_statusController, 'Contoh: Planning / Active / On Hold'),
                const SizedBox(height: 16),

                _buildLabel('Budget / Anggaran'),
                _buildTextField(_budgetController, 'Contoh: Rp 250.000.000'),
                const SizedBox(height: 16),

                _buildLabel('Lokasi Project'),
                _buildTextField(_locationController, 'Contoh: Jakarta / Remote / Hybrid'),
                const SizedBox(height: 16),

                _buildLabel('Tanggal Mulai'),
                GestureDetector(
                  onTap: () => _pickDate(_startDateController),
                  child: AbsorbPointer(
                    child: _buildTextField(_startDateController, 'YYYY-MM-DD'),
                  ),
                ),
                const SizedBox(height: 16),

                _buildLabel('Tanggal Selesai'),
                GestureDetector(
                  onTap: () => _pickDate(_endDateController),
                  child: AbsorbPointer(
                    child: _buildTextField(_endDateController, 'YYYY-MM-DD'),
                  ),
                ),
                const SizedBox(height: 16),

                _buildLabel('Tujuan Project'),
                _buildTextField(_objectiveController, 'Jelaskan tujuan utama project...', maxLines: 3),
                const SizedBox(height: 16),

                _buildLabel('Scope / Cakupan Project'),
                _buildTextField(_scopeController, 'Jelaskan cakupan kerja, deliverable, dan target...', maxLines: 3),
                const SizedBox(height: 16),

                _buildLabel('Deskripsi Project'),
                _buildTextField(_descriptionController, 'Jelaskan detail, timing, dan kebutuhan tim...', maxLines: 4),
                const SizedBox(height: 20),

                _buildLabel('Role & Divisi Dalam Project'),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(_roleController, 'Tambah role atau divisi...'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _addRole,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C2C2E),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _roles.map((role) {
                    return Chip(
                      backgroundColor: const Color(0xFF1C1C1E),
                      label: Text(role, style: const TextStyle(color: Colors.white)),
                      deleteIcon: const Icon(Icons.close, size: 16, color: Colors.grey),
                      onDeleted: () => _removeRole(role),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 36),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text('Buat Project Sekarang', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFF1C1C1E),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}