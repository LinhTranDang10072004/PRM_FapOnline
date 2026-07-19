import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/attendance_model.dart';
import 'auth_service.dart';

class TeacherAttendanceService {
  final AuthService _authService = AuthService();

  Future<List<AttendanceStudent>> getAttendance(int scheduleId) async {
    final token = await _authService.getToken();
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/attendance/$scheduleId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body) as List;
      return data
          .map((e) => AttendanceStudent.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    throw Exception('Không lấy được danh sách điểm danh');
  }

  Future<void> saveAttendance({
    required int scheduleId,
    required int userId,
    required List<AttendanceStudent> students,
  }) async {
    final token = await _authService.getToken();
    final body = {
      'scheduleId': scheduleId,
      'userId': userId,
      'attendanceList': students.map((e) => e.toJson()).toList(),
    };

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/attendance/save'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Không lưu được điểm danh');
    }
  }
}
