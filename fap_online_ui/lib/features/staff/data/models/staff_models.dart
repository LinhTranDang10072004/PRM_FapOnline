/// Staff feature data models — mirrors the Spring Boot DTOs exactly.
library staff_models;

import 'package:intl/intl.dart';

// ─────────────────────────────────────────────────────────────────────────────
// UC-12: Staff Dashboard
// ─────────────────────────────────────────────────────────────────────────────

class StaffDashboardModel {
  final int totalActiveClasses;
  final int totalPendingApplications;
  final int totalAssignedTeachers;
  final int totalEnrolledStudents;
  final List<ScheduleModel> todaySchedules;

  const StaffDashboardModel({
    required this.totalActiveClasses,
    required this.totalPendingApplications,
    required this.totalAssignedTeachers,
    required this.totalEnrolledStudents,
    required this.todaySchedules,
  });

  factory StaffDashboardModel.fromJson(Map<String, dynamic> json) {
    return StaffDashboardModel(
      totalActiveClasses: (json['totalActiveClasses'] as num?)?.toInt() ?? 0,
      totalPendingApplications:
          (json['totalPendingApplications'] as num?)?.toInt() ?? 0,
      totalAssignedTeachers:
          (json['totalAssignedTeachers'] as num?)?.toInt() ?? 0,
      totalEnrolledStudents:
          (json['totalEnrolledStudents'] as num?)?.toInt() ?? 0,
      todaySchedules: (json['todaySchedules'] as List<dynamic>?)
              ?.map((e) => ScheduleModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// UC-13/14/15: Class Management
// ─────────────────────────────────────────────────────────────────────────────

class ClassModel {
  final int? classId;
  final String? classCode;
  final String? className;
  final int? subjectId;
  final String? subjectCode;
  final String? subjectName;
  final int? semesterId;
  final String? semesterName;
  final int? teacherId;
  final String? teacherName;
  final int? maxStudents;
  final int? currentStudents;
  final String? status;

  const ClassModel({
    this.classId,
    this.classCode,
    this.className,
    this.subjectId,
    this.subjectCode,
    this.subjectName,
    this.semesterId,
    this.semesterName,
    this.teacherId,
    this.teacherName,
    this.maxStudents,
    this.currentStudents,
    this.status,
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      classId: json['classId'] as int?,
      classCode: json['classCode'] as String?,
      className: json['className'] as String?,
      subjectId: json['subjectId'] as int?,
      subjectCode: json['subjectCode'] as String?,
      subjectName: json['subjectName'] as String?,
      semesterId: json['semesterId'] as int?,
      semesterName: json['semesterName'] as String?,
      teacherId: json['teacherId'] as int?,
      teacherName: json['teacherName'] as String?,
      maxStudents: json['maxStudents'] as int?,
      currentStudents: json['currentStudents'] as int?,
      status: json['status'] as String?,
    );
  }
}

class ClassStudentModel {
  final int? studentId;
  final String? studentCode;
  final String? fullName;
  final String? enrolledAt;
  final String? status;

  const ClassStudentModel({
    this.studentId,
    this.studentCode,
    this.fullName,
    this.enrolledAt,
    this.status,
  });

  factory ClassStudentModel.fromJson(Map<String, dynamic> json) {
    return ClassStudentModel(
      studentId: json['studentId'] as int?,
      studentCode: json['studentCode'] as String?,
      fullName: json['fullName'] as String?,
      enrolledAt: json['enrolledAt'] as String?,
      status: json['status'] as String?,
    );
  }
}

class CreateClassRequest {
  final String classCode;
  final String className;
  final int subjectId;
  final int semesterId;
  final int maxStudents;
  final String? status;

  const CreateClassRequest({
    required this.classCode,
    required this.className,
    required this.subjectId,
    required this.semesterId,
    required this.maxStudents,
    this.status,
  });

  Map<String, dynamic> toJson() => {
        'classCode': classCode,
        'className': className,
        'subjectId': subjectId,
        'semesterId': semesterId,
        'maxStudents': maxStudents,
        if (status != null) 'status': status,
      };
}

class UpdateClassRequest {
  final String? classCode;
  final String? className;
  final int? subjectId;
  final int? semesterId;
  final int? maxStudents;
  final String? status;

  const UpdateClassRequest({
    this.classCode,
    this.className,
    this.subjectId,
    this.semesterId,
    this.maxStudents,
    this.status,
  });

  Map<String, dynamic> toJson() => {
        if (classCode != null) 'classCode': classCode,
        if (className != null) 'className': className,
        if (subjectId != null) 'subjectId': subjectId,
        if (semesterId != null) 'semesterId': semesterId,
        if (maxStudents != null) 'maxStudents': maxStudents,
        if (status != null) 'status': status,
      };
}

class AssignTeacherRequest {
  final int teacherId;

  const AssignTeacherRequest({required this.teacherId});

  Map<String, dynamic> toJson() => {'teacherId': teacherId};
}

class AddStudentToClassRequest {
  final int studentId;

  const AddStudentToClassRequest({required this.studentId});

  Map<String, dynamic> toJson() => {'studentId': studentId};
}

// ─────────────────────────────────────────────────────────────────────────────
// UC-16/17: Schedule Management
// ─────────────────────────────────────────────────────────────────────────────

class ScheduleModel {
  final int? scheduleId;
  final int? classId;
  final String? classCode;
  final String? className;
  final int? roomId;
  final String? roomName;
  final int? timeSlotId;
  final String? slotName;
  final String? startTime;
  final String? endTime;
  final String? scheduleDate;
  final String? note;
  final String? status;

  const ScheduleModel({
    this.scheduleId,
    this.classId,
    this.classCode,
    this.className,
    this.roomId,
    this.roomName,
    this.timeSlotId,
    this.slotName,
    this.startTime,
    this.endTime,
    this.scheduleDate,
    this.note,
    this.status,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      scheduleId: json['scheduleId'] as int?,
      classId: json['classId'] as int?,
      classCode: json['classCode'] as String?,
      className: json['className'] as String?,
      roomId: json['roomId'] as int?,
      roomName: json['roomName'] as String?,
      timeSlotId: json['timeSlotId'] as int?,
      slotName: json['slotName'] as String?,
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
      scheduleDate: json['scheduleDate'] as String?,
      note: json['note'] as String?,
      status: json['status'] as String?,
    );
  }

  String get displayDate {
    if (scheduleDate == null) return '—';
    try {
      final d = DateTime.parse(scheduleDate!);
      return DateFormat('dd/MM/yyyy').format(d);
    } catch (_) {
      return scheduleDate!;
    }
  }

  String get displayTime {
    final s = startTime ?? '';
    final e = endTime ?? '';
    if (s.isEmpty && e.isEmpty) return slotName ?? '—';
    final sStr = s.length >= 5 ? s.substring(0, 5) : s;
    final eStr = e.length >= 5 ? e.substring(0, 5) : e;
    return '$sStr – $eStr';
  }
}

class StaffCreateScheduleRequest {
  final int classId;
  final int roomId;
  final int timeSlotId;
  final String scheduleDate; // yyyy-MM-dd
  final String? note;

  const StaffCreateScheduleRequest({
    required this.classId,
    required this.roomId,
    required this.timeSlotId,
    required this.scheduleDate,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'classId': classId,
        'roomId': roomId,
        'timeSlotId': timeSlotId,
        'scheduleDate': scheduleDate,
        if (note != null && note!.isNotEmpty) 'note': note,
      };
}

class StaffUpdateScheduleRequest {
  final int? roomId;
  final int? timeSlotId;
  final String? scheduleDate;
  final String? note;

  const StaffUpdateScheduleRequest({
    this.roomId,
    this.timeSlotId,
    this.scheduleDate,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        if (roomId != null) 'roomId': roomId,
        if (timeSlotId != null) 'timeSlotId': timeSlotId,
        if (scheduleDate != null) 'scheduleDate': scheduleDate,
        if (note != null) 'note': note,
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// UC-18: Application Management
// ─────────────────────────────────────────────────────────────────────────────

class ApplicationModel {
  final int? applicationId;
  final int? studentId;
  final String? studentCode;
  final String? studentName;
  final int? applicationTypeId;
  final String? applicationTypeName;
  final String? title;
  final String? content;
  final int? relatedScheduleId;
  final String? startDate;
  final String? endDate;
  final String? attachmentUrl;
  final String? status;
  final int? processedBy;
  final String? processedByName;
  final String? processedAt;
  final String? processNote;
  final String? createdAt;
  final String? updatedAt;

  const ApplicationModel({
    this.applicationId,
    this.studentId,
    this.studentCode,
    this.studentName,
    this.applicationTypeId,
    this.applicationTypeName,
    this.title,
    this.content,
    this.relatedScheduleId,
    this.startDate,
    this.endDate,
    this.attachmentUrl,
    this.status,
    this.processedBy,
    this.processedByName,
    this.processedAt,
    this.processNote,
    this.createdAt,
    this.updatedAt,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      applicationId: json['applicationId'] as int?,
      studentId: json['studentId'] as int?,
      studentCode: json['studentCode'] as String?,
      studentName: json['studentName'] as String?,
      applicationTypeId: json['applicationTypeId'] as int?,
      applicationTypeName: json['applicationTypeName'] as String?,
      title: json['title'] as String?,
      content: json['content'] as String?,
      relatedScheduleId: json['relatedScheduleId'] as int?,
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
      attachmentUrl: json['attachmentUrl'] as String?,
      status: json['status'] as String?,
      processedBy: json['processedBy'] as int?,
      processedByName: json['processedByName'] as String?,
      processedAt: json['processedAt'] as String?,
      processNote: json['processNote'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  String get displayCreatedAt {
    if (createdAt == null) return '—';
    try {
      final d = DateTime.parse(createdAt!);
      return DateFormat('dd/MM/yyyy HH:mm').format(d);
    } catch (_) {
      return createdAt!;
    }
  }
}

class ProcessApplicationRequest {
  final String? processNote;

  const ProcessApplicationRequest({this.processNote});

  Map<String, dynamic> toJson() => {
        if (processNote != null && processNote!.isNotEmpty)
          'processNote': processNote,
      };
}
