import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/api_service.dart';
import '../../services/project_state.dart';

class AssetsScreen extends StatefulWidget {
  const AssetsScreen({super.key});

  @override
  State<AssetsScreen> createState() => _AssetsScreenState();
}

class _AssetsScreenState extends State<AssetsScreen> {
  List<dynamic> _assets = [];
  bool _isLoading = true;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    ProjectState.activeProjectIdNotifier.addListener(_onProjectChanged);
    _fetchAssets();
  }

  @override
  void dispose() {
    ProjectState.activeProjectIdNotifier.removeListener(_onProjectChanged);
    super.dispose();
  }

  void _onProjectChanged() {
    _fetchAssets();
  }

  Future<void> _fetchAssets() async {
    if (ApiService.activeProjectId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    if (mounted) setState(() => _isLoading = true);

    try {
      final assets = await ApiService.getAssets();
      if (mounted) {
        setState(() {
          _assets = assets;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat aset: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  Future<void> _pickAssetImage({
    required ImageSource source,
    required void Function(String dataUrl) onSelected,
  }) async {
    final image = await _picker.pickImage(
      source: source,
      preferredCameraDevice: CameraDevice.rear,
    );
    if (image == null) return;

    final bytes = await File(image.path).readAsBytes();
    final dataUrl = 'data:image/jpeg;base64,${base64Encode(bytes)}';

    onSelected(dataUrl);
  }

  Future<void> _showAddAssetDialog({String? initialPhotoDataUrl}) async {
    final nameController = TextEditingController();
    final categoryController = TextEditingController();
    final locationController = TextEditingController();
    final divisionController = TextEditingController();
    final descriptionController = TextEditingController();
    String status = 'Available';
    String? photoDataUrl = initialPhotoDataUrl;

    final shouldSubmit = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1C1C1E),
              title: const Text('Tambah Asset Baru', style: TextStyle(color: Colors.white)),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 420,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (photoDataUrl != null && photoDataUrl!.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.memory(
                            base64Decode(photoDataUrl!.split(',').last),
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2C2C2E),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.camera_alt_outlined, color: Colors.white70, size: 42),
                        ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _pickAssetImage(
                                source: ImageSource.camera,
                                onSelected: (dataUrl) {
                                  setDialogState(() => photoDataUrl = dataUrl);
                                },
                              ),
                              icon: const Icon(Icons.camera_alt_outlined),
                              label: const Text('Kamera'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _pickAssetImage(
                                source: ImageSource.gallery,
                                onSelected: (dataUrl) {
                                  setDialogState(() => photoDataUrl = dataUrl);
                                },
                              ),
                              icon: const Icon(Icons.photo_library_outlined),
                              label: const Text('Galeri'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: nameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(labelText: 'Nama Asset', labelStyle: TextStyle(color: Colors.grey)),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: categoryController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(labelText: 'Kategori', labelStyle: TextStyle(color: Colors.grey)),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: locationController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(labelText: 'Lokasi', labelStyle: TextStyle(color: Colors.grey)),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: divisionController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(labelText: 'Divisi', labelStyle: TextStyle(color: Colors.grey)),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: status,
                        dropdownColor: const Color(0xFF1C1C1E),
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(labelText: 'Status', labelStyle: TextStyle(color: Colors.grey)),
                        items: const [
                          DropdownMenuItem(value: 'Available', child: Text('Available')),
                          DropdownMenuItem(value: 'In Use', child: Text('In Use')),
                          DropdownMenuItem(value: 'Maintenance', child: Text('Maintenance')),
                        ],
                        onChanged: (value) => setDialogState(() => status = value ?? 'Available'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: descriptionController,
                        maxLines: 3,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(labelText: 'Deskripsi', labelStyle: TextStyle(color: Colors.grey)),
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
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Simpan Asset'),
                ),
              ],
            );
          },
        );
      },
    );

    if (shouldSubmit != true) return;

    final name = nameController.text.trim();
    final category = categoryController.text.trim();
    final location = locationController.text.trim();
    final division = divisionController.text.trim();
    final description = descriptionController.text.trim();

    if (name.isEmpty || category.isEmpty || location.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nama, kategori, dan lokasi wajib diisi.'), backgroundColor: Colors.redAccent),
        );
      }
      return;
    }

    final result = await ApiService.createAsset(
      name: name,
      category: category,
      location: location,
      division: division.isEmpty ? 'General' : division,
      status: status,
      description: description,
      photoDataUrl: photoDataUrl,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Asset berhasil dibuat.'), backgroundColor: Colors.green),
      );
      await _fetchAssets();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Gagal membuat asset'), backgroundColor: Colors.redAccent),
      );
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
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddAssetDialog(),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            icon: const Icon(Icons.add_a_photo_outlined),
            label: const Text('Tambah Asset'),
          ),
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
                        child: IconButton(icon: const Icon(Icons.notifications_outlined, color: Colors.white), onPressed: () {}),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(child: _buildMiniStat('${_assets.length}', 'Total Assets', Icons.view_in_ar, const Color(0xFF2C2C2E), Colors.white, Colors.white)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildMiniStat('${_assets.where((a) => a['status'] == 'Maintenance').length}', 'In Maintenance', Icons.build_rounded, const Color(0xFFFDE8D0), const Color(0xFFE67E22), const Color(0xFFE67E22))),
                      const SizedBox(width: 8),
                      Expanded(child: _buildMiniStat('${_assets.where((a) => a['status'] == 'Available').length}', 'Available', Icons.check_circle, const Color(0xFFD4F4E2), const Color(0xFF2ECC71), const Color(0xFF2ECC71))),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('All Assets', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('Filter', style: TextStyle(color: Colors.grey, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator(color: Colors.white))
                        : RefreshIndicator(
                            onRefresh: _fetchAssets,
                            color: Colors.white,
                            child: _assets.isEmpty
                                ? ListView(
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    children: const [
                                      SizedBox(height: 100),
                                      Center(child: Text('Belum ada aset terdaftar di project ini', style: TextStyle(color: Colors.grey))),
                                    ],
                                  )
                                : ListView.builder(
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    itemCount: _assets.length,
                                    itemBuilder: (context, index) {
                                      final asset = _assets[index];
                                      final name = asset['name'] ?? '';
                                      final category = asset['category'] ?? 'General';
                                      final status = asset['status'] ?? 'Available';
                                      final location = asset['location'] ?? 'Studio';

                                      return Container(
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
                                                  child: Text(category, style: const TextStyle(color: Colors.white, fontSize: 12)),
                                                ),
                                                _buildStatusBadge(status),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            Text(name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                            const SizedBox(height: 12),
                                            Row(
                                              children: [
                                                const Icon(Icons.location_on_outlined, color: Colors.grey, size: 14),
                                                const SizedBox(width: 6),
                                                Text(location, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                              ],
                                            ),
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

    if (status == 'Available') {
      bg = const Color(0xFFD4F4E2);
      text = const Color(0xFF2ECC71);
    } else if (status == 'Maintenance') {
      bg = const Color(0xFFFDE8D0);
      text = const Color(0xFFE67E22);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(status, style: TextStyle(color: text, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}