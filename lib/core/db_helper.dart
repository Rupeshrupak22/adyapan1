import 'dart:convert';
import 'dart:math';
import 'package:mysql_client/mysql_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class DbHelper {
  static MySQLConnection? _conn;
  static final Random _random = Random.secure();

  static String _newId(String prefix) {
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final suffix = _random.nextInt(0x7fffffff).toRadixString(16);
    return '${prefix}_${timestamp}_$suffix';
  }

  // Establish a new connection or return the existing live connection
  static Future<MySQLConnection> getConnection() async {
    if (_conn != null && _conn!.connected) {
      try {
        // Test connection with a fast dummy query to check if it's still alive
        await _conn!.execute('SELECT 1;');
        return _conn!;
      } catch (_) {
        // Connection closed or timed out, recreate it
        _conn = null;
      }
    }

    final host = dotenv.env['MYSQL_HOST'] ?? '';
    final portStr = dotenv.env['MYSQL_PORT'] ?? '4000';
    final port = int.tryParse(portStr) ?? 4000;
    final user = dotenv.env['MYSQL_USER'] ?? '';
    final password = dotenv.env['MYSQL_PASSWORD'] ?? '';
    final db = dotenv.env['MYSQL_DATABASE'] ?? 'preschool';
    final sslEnabled = dotenv.env['MYSQL_SSL'] == 'true';

    final conn = await MySQLConnection.createConnection(
      host: host,
      port: port,
      userName: user,
      password: password,
      databaseName: db,
      secure: sslEnabled, // Enable SSL/TLS encryption for TiDB Serverless
    );

    await conn.connect();
    _conn = conn;
    
    // Ensure standard database tables are created automatically
    await _initDatabase();

    return _conn!;
  }

  // Create table if it does not exist
  static Future<void> _initDatabase() async {
    if (_conn == null) return;
    try {
      await _conn!.execute('''
        CREATE TABLE IF NOT EXISTS users (
          id VARCHAR(64) PRIMARY KEY,
          name VARCHAR(255) NOT NULL,
          email VARCHAR(255) NOT NULL UNIQUE,
          phone VARCHAR(50) NOT NULL,
          class_name VARCHAR(100) NOT NULL,
          school VARCHAR(255) NOT NULL,
          password VARCHAR(255) NOT NULL,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
      ''');
      await _conn!.execute('''
        CREATE TABLE IF NOT EXISTS login_events (
          id VARCHAR(64) PRIMARY KEY,
          user_id VARCHAR(64) NOT NULL,
          name VARCHAR(160),
          email VARCHAR(190) NOT NULL,
          role VARCHAR(30),
          source VARCHAR(40) NOT NULL DEFAULT 'unknown',
          status VARCHAR(40) NOT NULL DEFAULT 'success',
          ip_address VARCHAR(80),
          user_agent TEXT,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          INDEX idx_login_events_user_id (user_id),
          INDEX idx_login_events_email (email),
          INDEX idx_login_events_source (source),
          INDEX idx_login_events_created_at (created_at)
        );
      ''');
    } catch (e) {
      print('❌ Database table initialization failed: $e');
    }
  }

  // Call Next.js REST API for authentication (Tries both ngrok and local IP base URLs)
  static Future<Map<String, dynamic>?> callAuthApi({
    required String path, // '/api/auth/login' or '/api/auth/signup'
    required Map<String, dynamic> body,
  }) async {
    final baseUrl = dotenv.env['API_BASE_URL'] ?? 'https://abc123.ngrok-free.app';
    final localUrl = dotenv.env['LOCAL_API_BASE_URL'] ?? 'http://192.168.1.25:3000';
    
    for (final base in [baseUrl, localUrl]) {
      try {
        final url = Uri.parse('${base.replaceAll(RegExp(r'/+$'), '')}$path');
        print('📡 Hitting Auth API: $url');
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            ...body,
            'clientType': 'mobile',
          }),
        ).timeout(const Duration(seconds: 4));
        
        print('📡 Auth API response status: ${response.statusCode}');
        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = jsonDecode(response.body);
          print('📡 Auth API response data: $data');
          return data;
        }
      } catch (e) {
        print('⚠️ Failed to hit Auth API on $base: $e');
      }
    }
    return null;
  }

  // Register a new user in both remote TiDB and Next.js REST API
  static Future<bool> registerUser({
    required String name,
    required String email,
    required String phone,
    required String className,
    required String school,
    required String password,
    required String role,
    String? teacherId,
  }) async {
    final cleanEmail = email.toLowerCase().trim();

    // 1. Sync in Next.js backend API (Only student role for Next.js, or try for both)
    try {
      final body = {
        'name': name,
        'email': cleanEmail,
        'phone': phone,
        'className': className,
        'class_name': className,
        'school': school,
        'password': password,
        'role': role,
        'teacher_id': teacherId,
      };
      final apiResponse = await callAuthApi(path: '/api/auth/signup', body: body);
      if (apiResponse != null) {
        return true;
      }
    } catch (e) {
      print('⚠️ REST API signup sync failed, but proceeding with direct DB: $e');
    }

    // 2. Direct TiDB Database registration
    try {
      final conn = await getConnection();

      // Check if user already exists
      final checkRes = await conn.execute(
        'SELECT id FROM users WHERE LOWER(email) = :email;',
        {'email': cleanEmail},
      );

      if (checkRes.rows.isNotEmpty) {
        return false; // Email already in database!
      }

      final userId = role == 'teacher' 
          ? (teacherId ?? _newId('tch')) 
          : _newId('usr');

      // Insert new user using named parameters and schema compatibility
      await conn.execute('''
        INSERT INTO users (
          id, name, email, phone, 
          class_name, class_level, 
          school, school_name, 
          password, password_hash, 
          role, otp_verified, signup_source, teacher_id
        )
        VALUES (
          :id, :name, :email, :phone, 
          :className, :className, 
          :school, :school, 
          :password, :password, 
          :role, :otpVerified, :signupSource, :teacherId
        );
      ''', {
        'id': userId,
        'name': name,
        'email': cleanEmail,
        'phone': phone,
        'className': className,
        'school': school,
        'password': password,
        'role': role,
        'otpVerified': 1,
        'signupSource': 'flutter',
        'teacherId': role == 'teacher' ? userId : teacherId, // For teachers, teacherId is their own ID!
      });

      return true;
    } catch (e) {
      print('❌ Database registration error: $e');
      rethrow;
    }
  }

  // Validate credentials in Next.js API & TiDB Database with automatic profile synchronization
  static Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    final cleanEmail = email.toLowerCase().trim();

    // 1. Try Next.js REST API
    Map<String, dynamic>? apiUser;
    try {
      final apiResponse = await callAuthApi(
        path: '/api/auth/login',
        body: {'email': cleanEmail, 'password': password},
      );
      if (apiResponse != null) {
        final userObj = apiResponse['user'] ?? apiResponse;
        apiUser = {
          'name': userObj['name'] ?? '',
          'email': userObj['email'] ?? cleanEmail,
          'phone': userObj['phone'] ?? '',
          'className': userObj['className'] ?? userObj['class_name'] ?? '',
          'school': userObj['school'] ?? '',
          'role': userObj['role'] ?? 'student',
          'teacher_id': userObj['teacher_id'] ?? '',
        };
      }
    } catch (e) {
      print('⚠️ REST API login failed, checking direct DB: $e');
    }

    // 2. Check direct database
    try {
      final conn = await getConnection();
      final results = await conn.execute('''
        SELECT id, name, email, phone, class_name, school, role, teacher_id
        FROM users
        WHERE LOWER(email) = :email AND (password = :password OR password_hash = :password);
      ''', {
        'email': cleanEmail,
        'password': password,
      });

      if (results.rows.isEmpty) {
        // If direct DB has no user but API successfully logged them in, sync user details from API to DB!
        if (apiUser != null) {
          try {
            final userId = apiUser['role'] == 'teacher' 
                ? (apiUser['teacher_id'] != null && apiUser['teacher_id'].toString().isNotEmpty ? apiUser['teacher_id'].toString() : _newId('tch')) 
                : _newId('usr');
            await conn.execute('''
              INSERT INTO users (
                id, name, email, phone, 
                class_name, class_level, 
                school, school_name, 
                password, password_hash, 
                role, otp_verified, signup_source, teacher_id
              )
              VALUES (
                :id, :name, :email, :phone, 
                :className, :className, 
                :school, :school, 
                :password, :password, 
                :role, :otpVerified, :signupSource, :teacherId
              )
              ON DUPLICATE KEY UPDATE name = :name;
            ''', {
              'id': userId,
              'name': apiUser['name'],
              'email': cleanEmail,
              'phone': apiUser['phone'],
              'className': apiUser['className'],
              'school': apiUser['school'],
              'password': password,
              'role': apiUser['role'] ?? 'student',
              'otpVerified': 1,
              'signupSource': 'flutter',
              'teacherId': apiUser['role'] == 'teacher' ? userId : (apiUser['teacher_id'] ?? ''),
            });
          } catch (e) {
            print('⚠️ Auto-sync API user to local DB failed: $e');
          }
          return apiUser;
        }
        return null; // Username/Password mismatch
      }

      final row = results.rows.first.assoc();
      try {
        await conn.execute('''
          INSERT INTO login_events (id, user_id, name, email, role, source, status, user_agent)
          VALUES (:id, :userId, :name, :email, :role, :source, :status, :userAgent);
        ''', {
          'id': _newId('mobile_login'),
          'userId': row['id'] ?? '',
          'name': row['name'] ?? '',
          'email': row['email'] ?? cleanEmail,
          'role': 'student',
          'source': 'mobile',
          'status': 'success',
          'userAgent': 'flutter',
        });
      } catch (e) {
        print('⚠️ Mobile login event insert failed: $e');
      }

      return {
        'name': row['name'] ?? '',
        'email': row['email'] ?? '',
        'phone': row['phone'] ?? '',
        'className': row['class_name'] ?? '',
        'school': row['school'] ?? '',
        'role': row['role'] ?? 'student',
        'teacher_id': row['teacher_id'] ?? '',
      };
    } catch (e) {
      print('❌ Direct database login failed: $e');
      // If direct DB failed (e.g. Whitelist/connection issue) but API succeeded, use API user!
      if (apiUser != null) {
        return apiUser;
      }
      rethrow;
    }
  }

  // Fetch list of students linked to a specific teacher
  static Future<List<Map<String, dynamic>>> getLinkedStudents(String teacherId) async {
    try {
      final conn = await getConnection();
      final results = await conn.execute('''
        SELECT name, email, phone, class_name, school, created_at
        FROM users
        WHERE role = 'student' AND teacher_id = :teacherId
        ORDER BY name ASC;
      ''', {'teacherId': teacherId});

      final list = <Map<String, dynamic>>[];
      for (final row in results.rows) {
        final assoc = row.assoc();
        list.add({
          'name': assoc['name'] ?? '',
          'email': assoc['email'] ?? '',
          'phone': assoc['phone'] ?? '',
          'className': assoc['class_name'] ?? '',
          'school': assoc['school'] ?? '',
          'createdAt': assoc['created_at'] ?? '',
        });
      }
      return list;
    } catch (e) {
      print('❌ Failed to fetch linked students: $e');
      return [];
    }
  }
}
