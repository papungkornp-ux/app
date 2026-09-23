import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  // Android Emulator ใช้ 10.0.2.2 แทน localhost ของคอมพิวเตอร์
  static const String baseUrl = 'http://10.0.2.2/merit_api';

  // เมธอดกลางสำหรับส่งข้อมูลแบบ POST ไปยัง PHP API
  // ทุกคำสั่ง เช่น login, register และบันทึกกิจกรรมจะใช้เมธอดนี้
  static Future<Map<String, dynamic>> _post(
    Map<String, dynamic> payload,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/index.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    // ตรวจสอบ HTTP status code ก่อนอ่านข้อมูล
    if (response.statusCode >= 400) {
      throw Exception('เชื่อมต่อเซิร์ฟเวอร์ไม่สำเร็จ');
    }

    // แปลง JSON ที่ PHP ส่งกลับมาเป็น Map
    final body = jsonDecode(response.body);

    // API ต้องส่ง success: true กลับมา
    // หากไม่สำเร็จ จะนำข้อความจากเซิร์ฟเวอร์มาแสดง
    if (body is! Map<String, dynamic> || body['success'] != true) {
      throw Exception(
        body is Map
            ? body['message'] ?? 'ดำเนินการไม่สำเร็จ'
            : 'ดำเนินการไม่สำเร็จ',
      );
    }

    return body;
  }

  // ส่งชื่อผู้ใช้และรหัสผ่านไปตรวจสอบกับเซิร์ฟเวอร์
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

  // สร้างบัญชีใหม่ โดยบันทึกชื่อผู้ใช้ รหัสผ่าน และศาสนา
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

  // บันทึกกิจกรรมประจำวันที่ผู้ใช้เลือก
  // activities จะเก็บรหัสกิจกรรมและค่าคะแนนของกิจกรรมนั้น
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

  // ขอข้อมูลแต้มรวมของผู้ใช้จากเซิร์ฟเวอร์
  static Future<Map<String, dynamic>> getSummary({
    required String username,
  }) {
    return _post({'action': 'summary', 'username': username});
  }

  // ขอประวัติการบันทึก แล้วคืนเฉพาะรายการ history
  static Future<List<dynamic>> getHistory({
    required String username,
  }) async {
    final result = await _post({'action': 'history', 'username': username});

    // หากไม่มี history ให้คืน List ว่างแทน null
    return result['history'] as List<dynamic>? ?? <dynamic>[];
  }
}
