import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  // Android Emulator maps 10.0.2.2 to the host computer's localhost.
  static const String baseUrl = 'http://10.0.2.2/merit_api';

  static Future<Map<String, dynamic>> _post(
    Map<String, dynamic> payload,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/index.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode >= 400) {
      throw Exception('เชื่อมต่อเซิร์ฟเวอร์ไม่สำเร็จ');
    }

    final body = jsonDecode(response.body);
    if (body is! Map<String, dynamic> || body['success'] != true) {
      throw Exception(
        body is Map
            ? body['message'] ?? 'ดำเนินการไม่สำเร็จ'
            : 'ดำเนินการไม่สำเร็จ',
      );
    }
    return body;
  }

  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) {
    return _post({
      'action': 'login',
      'username': username,
      'password': password,
    });
  }

  static Future<void> register({
    required String username,
    required String password,
    required String religion,
  }) async {
    await _post({
      'action': 'register',
      'username': username,
      'password': password,
      'religion': religion,
    });
  }

  static Future<void> saveDailyLog({
    required String username,
    required String religion,
    required String date,
    required Map<String, int> activities,
  }) async {
    await _post({
      'action': 'save_daily_log',
      'username': username,
      'religion': religion,
      'date': date,
      'activities': activities,
    });
  }

  static Future<Map<String, dynamic>> getSummary({required String username}) {
    return _post({'action': 'summary', 'username': username});
  }

  static Future<List<dynamic>> getHistory({required String username}) async {
    final result = await _post({'action': 'history', 'username': username});
    return result['history'] as List<dynamic>? ?? <dynamic>[];
  }
}
