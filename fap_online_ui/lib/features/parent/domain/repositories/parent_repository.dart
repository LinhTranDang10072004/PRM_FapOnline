import '../config/api_endpoints.dart';
import '../models/parent_models.dart';
import 'api_service.dart';

class ParentRepository {
  final ApiService _apiService;

  ParentRepository({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  Future<ParentDashboardData> fetchDashboard() async {
    final response = await _apiService.get(ApiEndpoints.dashboard);
    return ParentDashboardData.fromJson(response as Map<String, dynamic>);
  }

  Future<List<ParentNotificationItem>> fetchNotifications() async {
    final response = await _apiService.get(ApiEndpoints.notifications);
    return _readList(response).map((item) {
      return ParentNotificationItem.fromJson(item as Map<String, dynamic>);
    }).toList();
  }

  Future<void> markNotificationAsRead(int notificationId) async {
    await _apiService.put('${ApiEndpoints.notifications}/$notificationId/read');
  }

  Future<ParentProfileData> fetchProfile() async {
    final response = await _apiService.get(ApiEndpoints.profile);
    return ParentProfileData.fromJson(response as Map<String, dynamic>);
  }

  Future<void> updateProfile(ParentProfileData profile) async {
    await _apiService.put(ApiEndpoints.profile, body: profile.toJson());
  }

  Future<ParentChildDetailData> fetchChildDetail(int studentId) async {
    final response = await _apiService.get('${ApiEndpoints.children}/$studentId');
    return ParentChildDetailData.fromJson(response as Map<String, dynamic>);
  }

  Future<List<ParentWeeklyTimetableItem>> fetchChildTimetable(int studentId) async {
    final response = await _apiService.get('${ApiEndpoints.children}/$studentId/schedule');
    return _readList(response).map((item) {
      return ParentWeeklyTimetableItem.fromJson(item as Map<String, dynamic>);
    }).toList();
  }

  Future<List<ParentAttendanceRecord>> fetchChildAttendance(int studentId) async {
    final response = await _apiService.get('${ApiEndpoints.children}/$studentId/attendance');
    return _readList(response).map((item) {
      return ParentAttendanceRecord.fromJson(item as Map<String, dynamic>);
    }).toList();
  }

  Future<List<ParentGradeRecord>> fetchChildGrades(int studentId) async {
    final response = await _apiService.get('${ApiEndpoints.children}/$studentId/grades');
    return _readList(response).map((item) {
      return ParentGradeRecord.fromJson(item as Map<String, dynamic>);
    }).toList();
  }

  Future<List<ParentTranscriptRecord>> fetchChildTranscript(int studentId) async {
    final response = await _apiService.get('${ApiEndpoints.children}/$studentId/transcript');
    return _readList(response).map((item) {
      return ParentTranscriptRecord.fromJson(item as Map<String, dynamic>);
    }).toList();
  }

  Future<List<ParentFeeRecord>> fetchChildFees(int studentId) async {
    final response = await _apiService.get('${ApiEndpoints.children}/$studentId/fees');
    return _readList(response).map((item) {
      return ParentFeeRecord.fromJson(item as Map<String, dynamic>);
    }).toList();
  }

  Future<AttendanceSummary> fetchAttendanceSummaryForChild(int studentId) async {
    final records = await fetchChildAttendance(studentId);
    return AttendanceSummary.fromRecords(records);
  }

  Future<void> logout() async {
    try {
      await _apiService.post(ApiEndpoints.logout, <String, dynamic>{});
    } catch (_) {
      // Backend logout is advisory only, local session will be cleared by caller.
    }
  }

  List<dynamic> _readList(dynamic response) {
    if (response is List) return response;
    return const [];
  }
}
