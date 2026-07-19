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

  // ── Admin ───────────────────────────────────────────────────────────────
  static const String adminDashboard = '/admin/dashboard';
  static const String adminUsers = '/admin/users';
  static String adminUserById(int userId) => '/admin/users/$userId';
  static String adminUserLock(int userId) => '/admin/users/$userId/lock';
  static String adminUserUnlock(int userId) => '/admin/users/$userId/unlock';
  static const String adminRoles = '/admin/roles';
  static String adminRoleById(int roleId) => '/admin/roles/$roleId';
  static const String adminRoleAssign = '/admin/roles/assign';
  static const String adminRoleUnassign = '/admin/roles/unassign';
  static const String adminProfile = '/admin/profile';
  static const String adminChangePassword = '/admin/profile/change-password';

  // ── Staff ───────────────────────────────────────────────────────────────
  // References
  static const String staffReferenceTeachers = '/staff/references/teachers';
  static const String staffReferenceStudents = '/staff/references/students';

  // UC-12: Staff Dashboard
  static const String staffDashboard = '/staff/dashboard';

  // UC-13/14/15: Class management
  static const String staffClasses = '/staff/classes';
  static String staffClassById(int classId) => '/staff/classes/$classId';
  static String staffClassTeacher(int classId) => '/staff/classes/$classId/teacher';
  static String staffClassStudents(int classId) => '/staff/classes/$classId/students';
  static String staffClassStudent(int classId, int studentId) =>
      '/staff/classes/$classId/students/$studentId';

  // UC-16/17: Schedule management
  static const String staffSchedules = '/staff/schedules';
  static String staffScheduleById(int scheduleId) => '/staff/schedules/$scheduleId';

  // Rooms & TimeSlots
  static const String staffRooms = '/staff/rooms';
  static String staffRoomById(int roomId) => '/staff/rooms/$roomId';
  static const String staffTimeSlots = '/staff/timeslots';
  static String staffTimeSlotById(int timeSlotId) => '/staff/timeslots/$timeSlotId';

  // UC-18: Application management
  static const String staffApplications = '/staff/applications';
  static String staffApplicationById(int id) => '/staff/applications/$id';
  static String staffApplicationApprove(int id) => '/staff/applications/$id/approve';
  static String staffApplicationReject(int id) => '/staff/applications/$id/reject';

  static String getImageUrl(String path) {
    if (path.startsWith('http')) return path;
    final baseDomain = baseUrl.replaceAll('/api', '');
    return '$baseDomain$path';
  }
}
