import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Unified API Service — connects mobile app to Render backend
/// All data flows through this service → same data on website & app
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'https://preschool-wzj1.onrender.com';

  String? _token;
  String? _refreshToken;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  /// Initialize — load saved token from SharedPreferences
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    _refreshToken = prefs.getString('refresh_token');
  }

  /// Save tokens after login
  Future<void> _saveTokens(String token, String refreshToken) async {
    _token = token;
    _refreshToken = refreshToken;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('refresh_token', refreshToken);
  }

  /// Clear tokens on logout
  Future<void> clearTokens() async {
    _token = null;
    _refreshToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('refresh_token');
  }

  bool get isLoggedIn => _token != null;

  // ─── AUTH ─────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/v1/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password, 'platform': 'mobile'}),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data['success'] == true) {
        await _saveTokens(data['data']['token'], data['data']['refreshToken']);
        return data['data']['user'];
      }
      return null;
    } catch (e) {
      print('❌ Login error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    String? className,
    String? school,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/v1/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
          'class_name': className,
          'school_name': school,
          'platform': 'mobile',
        }),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(res.body);
      if (res.statusCode == 201 && data['success'] == true) {
        await _saveTokens(data['data']['token'], data['data']['refreshToken']);
        return data['data']['user'];
      }
      return null;
    } catch (e) {
      print('❌ Register error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getMe() async {
    return await _get('/api/v1/auth/me');
  }

  Future<void> logout() async {
    await _post('/api/v1/auth/logout', {});
    await clearTokens();
  }

  // ─── PROFILE ──────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> getProfile() async {
    return await _get('/api/v1/profile');
  }

  Future<Map<String, dynamic>?> updateProfile(Map<String, dynamic> data) async {
    return await _put('/api/v1/profile', data);
  }

  // ─── DASHBOARD ────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> getDashboard() async {
    return await _get('/api/v1/dashboard');
  }

  // ─── ATTENDANCE ───────────────────────────────────────────────────

  Future<List<dynamic>> getAttendance({int page = 1, int limit = 50}) async {
    final data = await _get('/api/v1/attendance?page=$page&limit=$limit');
    return data?['data'] ?? [];
  }

  Future<Map<String, dynamic>?> getAttendanceSummary(String userId) async {
    return await _get('/api/v1/attendance/summary/$userId');
  }

  // ─── CLASSES (Live + Scheduled) ───────────────────────────────────

  Future<List<dynamic>> getClasses({int page = 1, int limit = 20}) async {
    final data = await _get('/api/v1/classes?page=$page&limit=$limit');
    return data?['data'] ?? [];
  }

  // ─── NOTICES / NOTIFICATIONS ──────────────────────────────────────

  Future<List<dynamic>> getNotices({int page = 1, int limit = 20}) async {
    final data = await _get('/api/v1/notices?page=$page&limit=$limit');
    return data?['data'] ?? [];
  }

  Future<void> markNoticeRead(String id) async {
    await _put('/api/v1/notices/$id/read', {});
  }

  // ─── PAYMENTS ─────────────────────────────────────────────────────

  Future<List<dynamic>> getPayments({int page = 1, int limit = 20}) async {
    final data = await _get('/api/v1/payments?page=$page&limit=$limit');
    return data?['data'] ?? [];
  }

  // ─── STUDENTS ─────────────────────────────────────────────────────

  Future<List<dynamic>> getStudents({String? schoolId}) async {
    final query = schoolId != null ? '?schoolId=$schoolId' : '';
    final res = await _getRaw('/api/v1/students$query');
    if (res != null) return res is List ? res : [];
    return [];
  }

  // ─── TEACHERS ─────────────────────────────────────────────────────

  Future<List<dynamic>> getTeachers({String? schoolId}) async {
    final query = schoolId != null ? '?schoolId=$schoolId' : '';
    final res = await _getRaw('/api/v1/teachers$query');
    if (res != null) return res is List ? res : [];
    return [];
  }

  // ─── SCHOOLS ──────────────────────────────────────────────────────

  Future<List<dynamic>> getSchools() async {
    final res = await _getRaw('/api/v1/schools');
    if (res != null) return res is List ? res : [];
    return [];
  }

  // ─── LEADS ────────────────────────────────────────────────────────

  Future<bool> submitLead(Map<String, dynamic> data) async {
    final res = await _post('/api/v1/leads', data);
    return res != null;
  }

  // ─── PRIVATE HELPERS ──────────────────────────────────────────────

  Future<Map<String, dynamic>?> _get(String path) async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl$path'),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode == 401) {
        final refreshed = await _refreshAccessToken();
        if (refreshed) return _get(path);
        return null;
      }

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
      return null;
    } catch (e) {
      print('❌ GET $path error: $e');
      return null;
    }
  }

  Future<dynamic> _getRaw(String path) async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl$path'),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode == 401) {
        final refreshed = await _refreshAccessToken();
        if (refreshed) return _getRaw(path);
        return null;
      }

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
      return null;
    } catch (e) {
      print('❌ GET $path error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> _post(String path, Map<String, dynamic> body) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl$path'),
        headers: _headers,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode == 401) {
        final refreshed = await _refreshAccessToken();
        if (refreshed) return _post(path, body);
        return null;
      }

      if (res.statusCode == 200 || res.statusCode == 201) {
        return jsonDecode(res.body);
      }
      return null;
    } catch (e) {
      print('❌ POST $path error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> _put(String path, Map<String, dynamic> body) async {
    try {
      final res = await http.put(
        Uri.parse('$baseUrl$path'),
        headers: _headers,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode == 401) {
        final refreshed = await _refreshAccessToken();
        if (refreshed) return _put(path, body);
        return null;
      }

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
      return null;
    } catch (e) {
      print('❌ PUT $path error: $e');
      return null;
    }
  }

  /// Auto-refresh expired access token
  Future<bool> _refreshAccessToken() async {
    if (_refreshToken == null) return false;

    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/v1/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': _refreshToken}),
      ).timeout(const Duration(seconds: 5));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _token = data['data']['token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);
        return true;
      }
    } catch (e) {
      print('❌ Token refresh failed: $e');
    }

    // Refresh failed — force logout
    await clearTokens();
    return false;
  }
}
