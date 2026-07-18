import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/attendance_model.dart';
import 'auth_service.dart';

class AttendanceService {

  // Đổi thành IP backend của bạn nếu chạy trên điện thoại
  static const String baseUrl = "http://10.0.2.2:8080";

  final AuthService authService = AuthService();

  // ==========================================
  // Lấy danh sách sinh viên của một buổi học
  // ==========================================
  Future<List<AttendanceStudent>> getAttendance(
      int scheduleId) async {

    final token = await authService.getToken();

    final response = await http.get(
      Uri.parse(
          "$baseUrl/attendance/$scheduleId"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {

      final List data =
          jsonDecode(response.body);

      return data
          .map(
            (e) => AttendanceStudent.fromJson(e),
          )
          .toList();

    }

    throw Exception(
        "Không lấy được danh sách điểm danh");
  }

  // ==========================================
  // Lưu điểm danh
  // ==========================================
  Future<void> saveAttendance({
  required int scheduleId,
  required int userId,
  required List<AttendanceStudent> students,
})async {

    final token = await authService.getToken();

    final body = {
      "scheduleId": scheduleId,
      "userId": userId,
      
      "attendanceList":
          students.map((e) => e.toJson()).toList(),
    };

    final response = await http.post(
      Uri.parse(
          "$baseUrl/attendance/save"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {

      throw Exception(
          "Lưu điểm danh thất bại");

    }
  }
}