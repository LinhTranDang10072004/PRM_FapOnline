import 'package:flutter/foundation.dart';

class ApiEndpoints {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080/api';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080/api';
    }
    return 'http://localhost:8080/api';
  }
  
  // Auth
  static const String login = '/auth/login';
  static const String me = '/auth/me';
  static const String logout = '/auth/logout';
  
  // Parent
  static const String dashboard = '/parent/dashboard';
  static const String children = '/parent/children';
  static const String notifications = '/parent/notifications';
  static const String profile = '/parent/profile';
  static const String changePassword = '/parent/profile/change-password';
  
  // Attendance
  static String attendanceStudent(int studentId) => '/attendance/student/$studentId';
  static String attendanceMonthly(int studentId) => '/attendance/monthly/$studentId';
  static String attendanceStats(int studentId) => '/attendance/stats/$studentId';
  
  // Transcript
  static String transcriptStudent(int studentId) => '/transcript/student/$studentId';
  static String transcriptRecent(int studentId) => '/transcript/recent/$studentId';
  static String transcriptSemester(int studentId, int semesterId) => '/transcript/semester/$studentId/$semesterId';
  static String transcriptAverage(int studentId) => '/transcript/average/$studentId';
  
  // Fees
  static String feesStudent(int studentId) => '/fees/student/$studentId';
  static String feesUnpaid(int studentId) => '/fees/unpaid/$studentId';
  static String feesOverdue(int studentId) => '/fees/overdue/$studentId';
  static String feesSemester(int studentId, int semesterId) => '/fees/semester/$studentId/$semesterId';
  static String feesTotalUnpaid(int studentId) => '/fees/total-unpaid/$studentId';

  static String getImageUrl(String path) {
    if (path.startsWith('http')) return path;
    final baseDomain = baseUrl.replaceAll('/api', '');
    return '$baseDomain$path';
  }
}
