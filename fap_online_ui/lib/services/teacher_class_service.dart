import 'package:dio/dio.dart';

import '../models/teacher_class_model.dart';

class TeacherClassService {
  final Dio dio = Dio(BaseOptions(baseUrl: "http://10.0.2.2:8080"));

  Future<List<TeacherClassModel>> getTeacherClasses(int userId) async {
    try {
      final response = await dio.get("/api/teacher/classes/$userId");

      List data = response.data;

      return data.map((e) => TeacherClassModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception("Failed to load teacher classes: $e");
    }
  }
}
