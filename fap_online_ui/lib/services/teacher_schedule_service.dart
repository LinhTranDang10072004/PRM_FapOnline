import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../models/teacher_schedule_model.dart';
import 'auth_service.dart';

class TeacherScheduleService {
  final Dio dio = Dio();
  final AuthService _authService = AuthService();

  Future<List<TeacherSchedule>> getTeacherSchedule(int userId) async {
    try {
      final token = await _authService.getToken();
      final response = await dio.get(
        '${ApiConfig.baseUrl}/api/teacher/schedule/$userId',
        options: Options(headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        }),
      );

      if (response.statusCode == 200) {
        return List<TeacherSchedule>.from(
          (response.data as List).map(
            (item) => TeacherSchedule.fromJson(item as Map<String, dynamic>),
          ),
        );
      }
      throw Exception('Không lấy được thời khóa biểu');
    } catch (e) {
      throw Exception('Lỗi gọi API Teacher Schedule: $e');
    }
  }
}
