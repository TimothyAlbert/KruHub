import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://kruhub-production.up.railway.app/api';

  // Storage Global State
  static String? token;
  static String? currentUserRole;
  static String? activeProjectId;

  static bool get isCurrentUserAdmin =>
      (currentUserRole ?? '').toLowerCase() == 'admin';

  // Header Dinamik: Otomatis menyuntikkan Token & X-Project-ID
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
    if (activeProjectId != null) 'X-Project-ID': activeProjectId!,
  };

  // Helper untuk menetapkan Project Aktif
  static void setActiveProject(String? projectId) {
    activeProjectId = projectId;
    print('📌 Active Project ID diset ke: $activeProjectId');
  }

  // 1. Login
  static Future<bool> login(String email, String password) async {
    try {
      print('=== MENCOBA LOGIN ===');
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: headers,
        body: jsonEncode({'email': email, 'password': password}),
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        token = data['token'] ?? data['access_token'];
        return true;
      }
      return false;
    } catch (e) {
      print('🚨 ERROR KONEKSI LOGIN: $e');
      return false;
    }
  }

  // 2. Register
  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      print('=== MENCOBA REGISTER ===');
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: headers,
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'message': 'Registrasi berhasil'};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Registrasi gagal',
        };
      }
    } catch (e) {
      print('🚨 ERROR KONEKSI REGISTER: $e');
      return {'success': false, 'message': 'Koneksi error: $e'};
    }
  }

  // 3. Logout
  static Future<void> logout() async {
    try {
      if (token != null) {
        await http.post(Uri.parse('$baseUrl/logout'), headers: headers);
      }
    } catch (e) {
      print('🚨 ERROR KONEKSI LOGOUT: $e');
    } finally {
      token = null;
      currentUserRole = null;
      activeProjectId = null;
    }
  }

  // 4. User Profile
  static Future<Map<String, dynamic>?> getUserProfile() async {
    currentUserRole = null;
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final profile = jsonDecode(response.body);
        currentUserRole = (profile['role'] ?? '').toString();
        if (isCurrentUserAdmin) {
          activeProjectId = null;
        }
        return profile;
      }
      throw Exception(
        jsonDecode(response.body)['message'] ?? 'Gagal mengambil profil',
      );
    } catch (e) {
      print('🚨 ERROR KONEKSI USER PROFILE: $e');
      rethrow;
    }
  }

  // 4b. Semua User (Admin only)
  static Future<List<dynamic>> getAllUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/users'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data is List ? data : [];
      }
      return [];
    } catch (e) {
      print('🚨 ERROR KONEKSI GET ALL USERS: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> createUser({
    required String name,
    required String email,
    required String password,
    required String role,
    String? division,
    String? position,
    String? phone,
    String? bio,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/users'),
        headers: headers,
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'role': role,
          if (division != null && division.trim().isNotEmpty)
            'division': division,
          if (position != null && position.trim().isNotEmpty)
            'position': position,
          if (phone != null && phone.trim().isNotEmpty) 'phone': phone,
          if (bio != null && bio.trim().isNotEmpty) 'bio': bio,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'data': data};
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Gagal membuat user',
      };
    } catch (e) {
      print('🚨 ERROR KONEKSI CREATE USER: $e');
      return {'success': false, 'message': 'Koneksi error: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateUser({
    required int userId,
    String? name,
    String? email,
    String? password,
    String? role,
    String? division,
    String? position,
    String? phone,
    String? bio,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null && name.trim().isNotEmpty) body['name'] = name;
      if (email != null && email.trim().isNotEmpty) body['email'] = email;
      if (password != null && password.trim().isNotEmpty)
        body['password'] = password;
      if (role != null && role.trim().isNotEmpty) body['role'] = role;
      if (division != null) body['division'] = division;
      if (position != null) body['position'] = position;
      if (phone != null) body['phone'] = phone;
      if (bio != null) body['bio'] = bio;

      final response = await http.put(
        Uri.parse('$baseUrl/admin/users/$userId'),
        headers: headers,
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Gagal memperbarui user',
      };
    } catch (e) {
      print('🚨 ERROR KONEKSI UPDATE USER: $e');
      return {'success': false, 'message': 'Koneksi error: $e'};
    }
  }

  static Future<Map<String, dynamic>> deleteUser(int userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/users/$userId'),
        headers: headers,
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'User berhasil dihapus',
        };
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Gagal menghapus user',
      };
    } catch (e) {
      print('🚨 ERROR KONEKSI DELETE USER: $e');
      return {'success': false, 'message': 'Koneksi error: $e'};
    }
  }

  // 5. Dashboard Summary (Mengirim Header X-Project-ID)
  static Future<Map<String, dynamic>?> getDashboardSummary() async {
    try {
      print('=== FETCH DASHBOARD SUMMARY (Project: $activeProjectId) ===');
      final response = await http.get(
        Uri.parse('$baseUrl/dashboard/summary'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('🚨 ERROR KONEKSI DASHBOARD: $e');
      return null;
    }
  }

  // 6. Tasks (Filter berdasarkan X-Project-ID)
  static Future<List<dynamic>> getTasks() async {
    try {
      print('=== FETCH TASKS (Project: $activeProjectId) ===');
      final response = await http.get(
        Uri.parse('$baseUrl/tasks'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data is List ? data : [];
      }
      return [];
    } catch (e) {
      print('🚨 ERROR KONEKSI TASKS: $e');
      return [];
    }
  }

  // 7. Assets (Filter berdasarkan X-Project-ID)
  static Future<List<dynamic>> getAssets() async {
    try {
      print('=== FETCH ASSETS (Project: $activeProjectId) ===');
      final response = await http.get(
        Uri.parse('$baseUrl/assets'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data is List ? data : [];
      }
      return [];
    } catch (e) {
      print('🚨 ERROR KONEKSI ASSETS: $e');
      return [];
    }
  }

  // 8. Team Members (Filter berdasarkan X-Project-ID)
  static Future<List<dynamic>> getTeamMembers() async {
    try {
      print('=== FETCH TEAM MEMBERS (Project: $activeProjectId) ===');
      final response = await http.get(
        Uri.parse('$baseUrl/team/members'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data is List ? data : [];
      }
      return [];
    } catch (e) {
      print('🚨 ERROR KONEKSI TEAM MEMBERS: $e');
      return [];
    }
  }

  // 9. Ambil Semua Project Yang Diikuti User
  static Future<List<dynamic>> getUserTeams() async {
    try {
      print('=== FETCH USER TEAMS ===');
      final response = await http.get(
        Uri.parse('$baseUrl/user/teams'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data is List ? data : [];
      }
    } catch (e) {
      print('🚨 ERROR KONEKSI GET USER TEAMS: $e');
    }
    return [];
  }

  // 10. Buat Project / Tim Baru
  static Future<Map<String, dynamic>> createTeam({
    required String name,
    required String teamCode,
    required String description,
    String? projectType,
    String? projectStatus,
    String? clientName,
    String? budget,
    String? startDate,
    String? endDate,
    String? location,
    String? objective,
    String? scope,
    List<String>? roles,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/teams'),
        headers: headers,
        body: jsonEncode({
          'name': name,
          'team_code': teamCode,
          'description': description,
          if (projectType != null && projectType.trim().isNotEmpty)
            'project_type': projectType,
          if (projectStatus != null && projectStatus.trim().isNotEmpty)
            'project_status': projectStatus,
          if (clientName != null && clientName.trim().isNotEmpty)
            'client_name': clientName,
          if (budget != null && budget.trim().isNotEmpty) 'budget': budget,
          if (startDate != null && startDate.trim().isNotEmpty)
            'start_date': startDate,
          if (endDate != null && endDate.trim().isNotEmpty) 'end_date': endDate,
          if (location != null && location.trim().isNotEmpty)
            'location': location,
          if (objective != null && objective.trim().isNotEmpty)
            'objective': objective,
          if (scope != null && scope.trim().isNotEmpty) 'scope': scope,
          if (roles != null) 'roles': roles,
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'data': data};
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Gagal membuat project',
      };
    } catch (e) {
      print('🚨 ERROR KONEKSI CREATE TEAM: $e');
      return {'success': false, 'message': 'Koneksi error: $e'};
    }
  }

  // 11. Gabung ke Project / Tim
  static Future<Map<String, dynamic>> joinTeam(String teamCode) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/teams/join'),
        headers: headers,
        body: jsonEncode({'team_code': teamCode}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Berhasil bergabung ke project!',
        };
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Gagal bergabung ke project',
      };
    } catch (e) {
      print('🚨 ERROR KONEKSI JOIN TEAM: $e');
      return {'success': false, 'message': 'Koneksi error: $e'};
    }
  }
}
