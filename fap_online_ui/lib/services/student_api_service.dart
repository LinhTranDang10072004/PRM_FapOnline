import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/timetable_model.dart';
import '../models/weekly_timetable_model.dart';
import '../models/mark_report_model.dart';
import '../models/grade_model.dart';
import '../models/attendance_model.dart';
import '../models/transcript_model.dart';
import '../models/dashboard_summary_model.dart';
import '../models/notification_model.dart';
import '../models/application_model.dart';

class StudentApiService {
  Future<WeeklyTimetableModel> getWeeklyTimetable(
    String token, {
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final query = <String, String>{};
    if (fromDate != null) {
      query['fromDate'] = _formatDate(fromDate);
    }
    if (toDate != null) {
      query['toDate'] = _formatDate(toDate);
    }

    final uri = Uri.parse('${ApiConfig.baseUrl}/api/student/timetable')
        .replace(queryParameters: query.isEmpty ? null : query);

    try {
      final response = await http
          .get(uri, headers: {'Authorization': 'Bearer $token'})
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return WeeklyTimetableModel.fromJson(json.decode(response.body));
      }

      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    } catch (e) {
      print('Error fetching weekly timetable: $e');
      rethrow;
    }
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  @Deprecated('Use getWeeklyTimetable instead')
  Future<List<TimetableModel>> getTimetable(String token) async {
    final weekly = await getWeeklyTimetable(token);
    return weekly.entries;
  }

  Future<List<GradeDetailModel>> getMarks(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/student/marks'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        return (json.decode(response.body) as List)
            .map((e) => GradeDetailModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    } catch (e) {
      print('Error fetching marks: $e');
      rethrow;
    }
  }

  Future<MarkReportModel> getMarkReport(String token) async {
    final marks = await getMarks(token);
    if (marks.isEmpty) {
      return MarkReportModel(semesters: []);
    }

    // Group theo kỳ: FA26 → 5 môn, SP26 → ...
    final Map<int, List<GradeDetailModel>> bySemester = {};
    final Map<int, SemesterMarkModel> meta = {};

    for (final m in marks) {
      final sid = m.semesterId ?? 0;
      bySemester.putIfAbsent(sid, () => []);
      bySemester[sid]!.add(m);
      meta.putIfAbsent(
        sid,
        () => SemesterMarkModel(
          semesterId: sid,
          semesterCode: (m.semesterCode != null && m.semesterCode!.isNotEmpty)
              ? m.semesterCode!
              : 'Kỳ $sid',
          semesterName: m.semesterName ?? '',
          courses: const [],
        ),
      );
    }

    final semesters = bySemester.entries.map((e) {
      final info = meta[e.key]!;
      return SemesterMarkModel(
        semesterId: info.semesterId,
        semesterCode: info.semesterCode,
        semesterName: info.semesterName,
        courses: e.value
            .map(
              (m) => CourseMarkSummaryModel(
                classId: m.classId ?? 0,
                classCode: m.classCode ?? '',
                subjectCode: m.subjectCode ?? '',
                subjectName: m.subjectName ?? '',
                average: m.finalScore,
                attendancePercent: m.attendancePercent,
                result: m.result,
              ),
            )
            .toList(),
      );
    }).toList();

    return MarkReportModel(semesters: semesters);
  }

  Future<GradeDetailModel> getMarkDetail(String token, int classId) async {
    if (classId <= 0) {
      throw Exception('Mã lớp không hợp lệ. Vui lòng mở lại Mark Report.');
    }
    final marks = await getMarks(token);
    return marks.firstWhere(
      (m) => m.classId == classId,
      orElse: () => throw Exception(
        'Không tìm thấy điểm cho lớp $classId. Có thể lớp chưa có điểm tổng kết.',
      ),
    );
  }

  Future<List<AttendanceModel>> getAttendance(String token) async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/api/student/attendance'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return (json.decode(response.body) as List)
            .map((e) => AttendanceModel.fromJson(e))
            .toList();
      }

      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    } catch (e) {
      print('Error fetching attendance: $e');
      rethrow;
    }
  }

  Future<TranscriptModel> getTranscript(String token) async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/api/student/transcript'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return TranscriptModel.fromJson(json.decode(response.body));
      }

      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    } catch (e) {
      print('Error fetching transcript: $e');
      rethrow;
    }
  }

  Future<DashboardSummaryModel?> getDashboardSummary(String token) async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/api/student/dashboard'), headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) return DashboardSummaryModel.fromJson(json.decode(response.body));
    } catch (e) {}
    return null;
  }

  Future<List<Map<String, dynamic>>> getMyClasses(String token) async {
    final response = await http
        .get(
          Uri.parse('${ApiConfig.baseUrl}/api/student/classes'),
          headers: {'Authorization': 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      return (json.decode(response.body) as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }

    throw Exception('HTTP ${response.statusCode}: ${response.body}');
  }

  Future<List<NotificationModel>> getNotifications(String token) async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/api/student/notifications'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return (json.decode(response.body) as List)
            .map((e) => NotificationModel.fromJson(e))
            .toList();
      }

      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    } catch (e) {
      print('Error fetching notifications: $e');
      rethrow;
    }
  }

  Future<List<ApplicationModel>> getMyApplications(String token) async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/api/applications/my'), headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) return (json.decode(response.body) as List).map((e) => ApplicationModel.fromJson(e)).toList();
    } catch (e) {}
    return [];
  }

  Future<Map<String, dynamic>> submitApplication(String token, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/applications'),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      if (response.statusCode == 200) return {'success': true};
      else return {'success': false, 'error': json.decode(response.body)['message'] ?? 'Failed to submit'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
