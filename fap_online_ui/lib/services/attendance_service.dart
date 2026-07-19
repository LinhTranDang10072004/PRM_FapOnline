import '../config/api_endpoints.dart';
import '../models/response/attendance_dto.dart';
import 'api_service.dart';

class AttendanceService {
  final ApiService _apiService = ApiService();

  Future<List<AttendanceDTO>> getStudentAttendance(
    int studentId,
    String startDate,
    String endDate,
  ) async {
    try {
      final endpoint = '${ApiEndpoints.attendanceStudent(studentId)}?startDate=$startDate&endDate=$endDate';
      final response = await _apiService.get(endpoint);
      
      if (response is List) {
        return response
            .map((item) => AttendanceDTO.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching attendance: $e');
      return [];
    }
  }

  Future<List<AttendanceDTO>> getMonthlyAttendance(
    int studentId,
    int month,
    int year,
  ) async {
    try {
      final endpoint = '${ApiEndpoints.attendanceMonthly(studentId)}?month=$month&year=$year';
      final response = await _apiService.get(endpoint);
      
      if (response is List) {
        return response
            .map((item) => AttendanceDTO.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching monthly attendance: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getAttendanceStats(int studentId) async {
    try {
      final response = await _apiService.get(ApiEndpoints.attendanceStats(studentId));
      return response is Map ? response as Map<String, dynamic> : {};
    } catch (e) {
      print('Error fetching attendance stats: $e');
      return {};
    }
  }
}
