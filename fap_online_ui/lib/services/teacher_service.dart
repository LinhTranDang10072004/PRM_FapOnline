import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../models/teacher_dashboard_model.dart';
import 'auth_service.dart';

class TeacherService {
  final Dio dio = Dio();
  final AuthService _authService = AuthService();

  Future<TeacherDashboard> getTeacherDashboard(int userId) async {
    try {
      final token = await _authService.getToken();
      final response = await dio.get(
        '${ApiConfig.baseUrl}/api/teacher/dashboard/$userId',
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return TeacherDashboard.fromJson(response.data);
      }

      throw Exception('Không lấy được dữ liệu dashboard');
    } catch (e) {
      throw Exception('Lỗi gọi API Teacher Dashboard: $e');
    }
  }
}
