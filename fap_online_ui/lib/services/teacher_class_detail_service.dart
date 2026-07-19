import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'auth_service.dart';

class TeacherClassDetailService {
  final AuthService _authService = AuthService();

  Future<List<Map<String, dynamic>>> getClassStudents(
    int userId,
    int classId,
  ) async {
    final token = await _authService.getToken();
    final response = await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/teacher/classes/$userId/$classId/students',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List<dynamic>;
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }

    throw Exception('Không lấy được danh sách sinh viên (${response.statusCode})');
  }
}
