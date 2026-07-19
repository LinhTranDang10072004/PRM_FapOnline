import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../models/teacher_class_model.dart';
import 'auth_service.dart';

class TeacherClassService {
  final Dio dio = Dio();
  final AuthService _authService = AuthService();

  Future<List<TeacherClassModel>> getTeacherClasses(int userId) async {
    try {
      final token = await _authService.getToken();
      final response = await dio.get(
        '${ApiConfig.baseUrl}/api/teacher/classes/$userId',
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
        ),
      );

      final List data = response.data as List;
      return data
          .map((e) => TeacherClassModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to load teacher classes: $e');
    }
  }
}
