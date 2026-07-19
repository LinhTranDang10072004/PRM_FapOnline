import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../models/grade_item_model.dart';
import 'auth_service.dart';

class GradeService {
  final Dio dio = Dio();
  final AuthService _authService = AuthService();

  Future<Options> _authOptions() async {
    final token = await _authService.getToken();
    return Options(
      headers: {
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );
  }

  Future<List<GradeItemModel>> getGradesByClass(
    int classId,
    int teacherId,
  ) async {
    final response = await dio.get(
      '${ApiConfig.baseUrl}/api/student-grades/class/$classId/$teacherId',
      options: await _authOptions(),
    );

    final List data = response.data as List;
    return data
        .map((e) => GradeItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> updateGrade(int id, double score, String status) async {
    await dio.put(
      '${ApiConfig.baseUrl}/api/student-grades/$id',
      data: {
        'score': score,
        'status': status,
      },
      options: await _authOptions(),
    );
  }

  Future<GradeItemModel> createGrade(Map<String, dynamic> data) async {
    final response = await dio.post(
      '${ApiConfig.baseUrl}/api/student-grades',
      data: data,
      options: await _authOptions(),
    );

    return GradeItemModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteGrade(int id) async {
    await dio.delete(
      '${ApiConfig.baseUrl}/api/student-grades/$id',
      options: await _authOptions(),
    );
  }
}
