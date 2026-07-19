import 'package:flutter/material.dart';
import '../models/response/attendance_dto.dart';
import '../services/attendance_service.dart';

class AttendanceProvider extends ChangeNotifier {
  final AttendanceService _service = AttendanceService();

  List<AttendanceDTO> _attendanceList = [];
  List<AttendanceDTO> get attendanceList => _attendanceList;

  Map<String, dynamic> _attendanceStats = {};
  Map<String, dynamic> get attendanceStats => _attendanceStats;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> fetchStudentAttendance(
    int studentId,
    String startDate,
    String endDate,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _attendanceList = await _service.getStudentAttendance(
        studentId,
        startDate,
        endDate,
      );
    } catch (e) {
      _error = 'Lỗi khi tải điểm danh: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMonthlyAttendance(
    int studentId,
    int month,
    int year,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _attendanceList = await _service.getMonthlyAttendance(
        studentId,
        month,
        year,
      );
    } catch (e) {
      _error = 'Lỗi khi tải điểm danh tháng: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAttendanceStats(int studentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _attendanceStats = await _service.getAttendanceStats(studentId);
    } catch (e) {
      _error = 'Lỗi khi tải thống kê điểm danh: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearAttendance() {
    _attendanceList = [];
    _error = null;
    notifyListeners();
  }
}
