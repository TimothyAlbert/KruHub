import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FeatureCenterScreen extends StatefulWidget {
  const FeatureCenterScreen({super.key});

  @override
  State<FeatureCenterScreen> createState() => _FeatureCenterScreenState();
}

class _FeatureCenterScreenState extends State<FeatureCenterScreen> {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  bool _isLoading = false;
  bool _locationReady = false;
  bool _notificationReady = false;
  bool _sensorReady = false;
  String _statusMessage = 'Siap digunakan';
  String? _errorMessage;
  Position? _currentPosition;
  double _motionLevel = 0;

  @override
  void initState() {
    super.initState();
    _initializeFeatures();
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeFeatures() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _initNotifications();
      await _requestLocationPermission();
      _startSensorTracking();
      setState(() {
        _statusMessage = 'Semua fitur pendukung siap dipakai';
      });
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
        _statusMessage = 'Beberapa fitur belum aktif';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _initNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _notificationsPlugin.initialize(settings: initSettings);

    const channel = AndroidNotificationChannel(
      'kruhub_alerts',
      'KruHub Alerts',
      description: 'Notifikasi penting untuk task, asset, dan status proyek.',
      importance: Importance.max,
    );
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    final status = await Permission.notification.status;
    if (status.isDenied) {
      final granted = await Permission.notification.request();
      if (granted.isGranted) {
        setState(() => _notificationReady = true);
      }
    } else if (status.isGranted) {
      setState(() => _notificationReady = true);
    }
  }

  Future<void> _requestLocationPermission() async {
    final permission = await Permission.locationWhenInUse.status;
    if (permission.isPermanentlyDenied) {
      throw Exception('Izin lokasi ditolak permanen. Aktifkan dari pengaturan ponsel.');
    }
    if (permission.isDenied) {
      final result = await Permission.locationWhenInUse.request();
      if (result.isDenied) {
        throw Exception('Izin lokasi dibatalkan oleh pengguna.');
      }
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Layanan lokasi belum aktif.');
    }

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = position;
      _locationReady = true;
    });
  }

  void _startSensorTracking() {
    _accelerometerSubscription = accelerometerEventStream().listen((event) {
      final magnitude = math.sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      if (mounted) {
        setState(() {
          _motionLevel = magnitude;
          _sensorReady = magnitude > 20;
        });
      }
    });
  }

  Future<void> _sendNotification() async {
    if (!_notificationReady) {
      setState(() => _errorMessage = 'Izin notifikasi belum diberikan.');
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      'kruhub_alerts',
      'KruHub Alerts',
      channelDescription: 'Notifikasi penting untuk task, asset, dan status proyek.',
      importance: Importance.max,
      priority: Priority.high,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      id: 1,
      title: 'Notifikasi KruHub',
      body: 'Task atau asset Anda sudah siap ditinjau.',
      notificationDetails: notificationDetails,
    );

    setState(() => _statusMessage = 'Notifikasi berhasil dikirim');
  }

  Future<void> _refreshLocation() async {
    setState(() => _isLoading = true);
    try {
      final permission = await Permission.locationWhenInUse.request();
      if (!permission.isGranted) {
        throw Exception('Pembaharuan lokasi dibatalkan.');
      }
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
        _locationReady = true;
        _errorMessage = null;
        _statusMessage = 'Lokasi berhasil diperbarui';
      });
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
      });
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
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F10),
        title: const Text('Smart Tools', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_errorMessage != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.redAccent),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.white),
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1C1C1E),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _statusMessage,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ),
                    const SizedBox(height: 20),
                    _featureCard(
                      title: 'Lokasi',
                      subtitle: _currentPosition == null
                          ? 'Belum ada data lokasi'
                          : 'Lat: ${_currentPosition!.latitude.toStringAsFixed(4)}, Long: ${_currentPosition!.longitude.toStringAsFixed(4)}',
                      icon: Icons.location_on_outlined,
                      enabled: _locationReady,
                      onPressed: _refreshLocation,
                    ),
                    const SizedBox(height: 12),
                    _featureCard(
                      title: 'Notifikasi',
                      subtitle: 'Kirim reminder untuk task atau approval asset.',
                      icon: Icons.notifications_active_outlined,
                      enabled: _notificationReady,
                      onPressed: _sendNotification,
                    ),
                    const SizedBox(height: 12),
                    _featureCard(
                      title: 'Sensor Gerak',
                      subtitle: _sensorReady ? 'Gerakan terdeteksi: ${_motionLevel.toStringAsFixed(1)}' : 'Menunggu data sensor...',
                      icon: Icons.sensors_outlined,
                      enabled: _sensorReady,
                      onPressed: () => setState(() => _statusMessage = 'Sensor aktif dan memantau gerakan.'),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Manfaat fitur ini',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• Lokasi membantu tim mengetahui checkpoint proyek dan lokasi kerja.\n'
                      '• Notifikasi menjaga task dan approval tidak terlewat.\n'
                      '• Sensor gerak membantu mendeteksi aktivitas dan validasi kondisi kerja real-time.',
                      style: TextStyle(color: Colors.grey, height: 1.6),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _featureCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool enabled,
    required VoidCallback onPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: enabled ? Colors.white.withValues(alpha: 0.12) : const Color(0xFF2C2C2E),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: enabled ? Colors.white : const Color(0xFF2C2C2E),
              foregroundColor: enabled ? Colors.black : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(enabled ? 'Aktif' : 'Coba'),
          )
        ],
      ),
    );
  }
}
