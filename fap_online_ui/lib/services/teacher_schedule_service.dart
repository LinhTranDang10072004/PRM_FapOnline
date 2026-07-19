import 'package:dio/dio.dart';

import '../models/teacher_schedule_model.dart';

class TeacherScheduleService {
  final Dio dio = Dio();

  Future<List<TeacherSchedule>> getTeacherSchedule(
      int userId,
      ) async {
    try {
      final response = await dio.get(
        "http://10.0.2.2:8080/api/teacher/schedule/$userId",
      );

      if (response.statusCode == 200) {
        return List<TeacherSchedule>.from(
          response.data.map(
                (item) => TeacherSchedule.fromJson(item),
          ),
        );
      } else {
        throw Exception("Không lấy được thời khóa biểu");
      }
    } catch (e) {
      throw Exception(
        "Lỗi gọi API Teacher Schedule: $e",
      );
    }
  }
}