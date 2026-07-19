import 'package:flutter/material.dart';

import '../models/attendance_model.dart';
import '../services/teacher_attendance_service.dart';

class AttendanceController extends ChangeNotifier {
  final TeacherAttendanceService attendanceService = TeacherAttendanceService();

  List<AttendanceStudent> students = [];

  bool isLoading = false;

  String? errorMessage;

  // ============================
  // Lấy danh sách điểm danh
  // ============================

  Future<void> loadAttendance(int scheduleId) async {
    try {
      isLoading = true;
      errorMessage = null;

      notifyListeners();

      students = await attendanceService.getAttendance(scheduleId);
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;

    notifyListeners();
  }

  // ============================
  // Cập nhật trạng thái
  // ============================

  void updateAttendanceStatus(int index, String status) {
    students[index].status = status;

    notifyListeners();
  }

  // ============================
  // Cập nhật ghi chú
  // ============================

  void updateAttendanceNote(int index, String note) {
    students[index].note = note;

    notifyListeners();
  }

  // ============================
  // Lưu điểm danh
  // ============================

  Future<bool> saveAttendance({
    required int scheduleId,
    required int userId,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;

      notifyListeners();

      await attendanceService.saveAttendance(
        scheduleId: scheduleId,
        userId: userId,
        students: students,
      );

      isLoading = false;

      notifyListeners();

      return true;
    } catch (e) {
      errorMessage = e.toString();

      isLoading = false;

      notifyListeners();

      return false;
    }
  }

  // ============================
  // Xóa dữ liệu
  // ============================

  void clearData() {
    students.clear();

    errorMessage = null;

    notifyListeners();
  }
  
}
