import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://192.168.114.184/api';
  static String? token;
  static String? activeProjectId;

  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
        if (activeProjectId != null) 'X-Project-ID': activeProjectId!,
      };

  // 1. Login (Contoh, sesuaikan dengan implementasi Anda)
  static Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: headers,
        body: jsonEncode({'email': email, 'password': password}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        token = data['token'];
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // 2. Register (Contoh, sesuaikan dengan implementasi Anda)
  static Future<bool> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: headers,
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 3. Logout
  static Future<void> logout() async {
    token = null;
    activeProjectId = null;
  }

  // 4. Dashboard Summary
  static Future<Map<String, dynamic>?> getDashboardSummary() async {
    final response = await http.get(Uri.parse('$baseUrl/dashboard/summary'), headers: headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception(jsonDecode(response.body)['message'] ?? 'Gagal mengambil data ringkasan');
  }

  // 5. Tasks
  static Future<List<dynamic>> getTasks() async {
    final response = await http.get(Uri.parse('$baseUrl/tasks'), headers: headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception(jsonDecode(response.body)['message'] ?? 'Gagal mengambil daftar tugas');
  }

  // 6. Assets
  static Future<List<dynamic>> getAssets() async {
    final response = await http.get(Uri.parse('$baseUrl/assets'), headers: headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception(jsonDecode(response.body)['message'] ?? 'Gagal mengambil daftar aset');
  }

  // 7. User Profile
  static Future<Map<String, dynamic>?> getUserProfile() async {
    final response = await http.get(Uri.parse('$baseUrl/user'), headers: headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception(jsonDecode(response.body)['message'] ?? 'Gagal mengambil profil');
  }

  // 8. Team Members
  static Future<List<dynamic>> getTeamMembers() async {
    final response = await http.get(Uri.parse('$baseUrl/team/members'), headers: headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception(jsonDecode(response.body)['message'] ?? 'Gagal mengambil daftar anggota tim');
  }

  // 9. Buat Project / Tim Baru
  static Future<Map<String, dynamic>> createTeam({
    required String name,
    required String teamCode,
    required String description,
    required List<String> roles,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/teams'),
        headers: headers,
        body: jsonEncode({
          'name': name,
          'team_code': teamCode,
          'description': description,
          'roles': roles,
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'data': data};
      }
      return {'success': false, 'message': data['message'] ?? 'Gagal membuat project'};
    } catch (e) {
      return {'success': false, 'message': 'Koneksi error: $e'};
    }
  }

  // 10. Gabung ke Project / Tim
  static Future<Map<String, dynamic>> joinTeam(String teamCode) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/teams/join'),
        headers: headers,
        body: jsonEncode({'team_code': teamCode}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message'] ?? 'Permintaan bergabung berhasil dikirim'};
      }
      return {'success': false, 'message': data['message'] ?? 'Gagal bergabung ke project'};
    } catch (e) {
      return {'success': false, 'message': 'Koneksi error: $e'};
    }
  }

  // 11. Ambil Semua Project Yang Diikuti User
  static Future<List<dynamic>> getUserTeams() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/user/teams'), headers: headers);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (_) {}
    return [];
  }
}