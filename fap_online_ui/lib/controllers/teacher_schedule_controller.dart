import 'package:flutter/material.dart';

import '../models/teacher_schedule_model.dart';
import '../services/teacher_schedule_service.dart';

class TeacherScheduleController extends ChangeNotifier {
  final TeacherScheduleService teacherScheduleService =
      TeacherScheduleService();

  List<TeacherSchedule> schedules = [];

  bool isLoading = false;

  String? errorMessage;

  // Load thời khóa biểu giáo viên
  Future<void> loadTeacherSchedule(int userId) async {
    try {
      isLoading = true;
      errorMessage = null;

      notifyListeners();

      schedules = await teacherScheduleService.getTeacherSchedule(
        userId,
      );
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  // Refresh dữ liệu
  Future<void> refresh(int userId) async {
    await loadTeacherSchedule(userId);
  }

  // Xóa dữ liệu
  void clearData() {
    schedules = [];
    errorMessage = null;
    notifyListeners();
  }
}