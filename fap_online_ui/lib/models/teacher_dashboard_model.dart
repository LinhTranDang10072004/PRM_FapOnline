class TeacherDashboard {
  final int teacherId;

  final String teacherName;

  final int totalClasses;

  final int todaySchedules;

  final List<TodaySchedule> todaySchedule;

  final List<TeacherClass> classes;

  TeacherDashboard({
    required this.teacherId,

    required this.teacherName,

    required this.totalClasses,

    required this.todaySchedules,

    required this.todaySchedule,

    required this.classes,
  });

  factory TeacherDashboard.fromJson(Map<String, dynamic> json) {
    return TeacherDashboard(
      teacherId: json["teacherId"],

      teacherName: json["teacherName"],

      totalClasses: json["totalClasses"],

      todaySchedules: json["todaySchedules"],

      todaySchedule: (json["todaySchedule"] as List)
          .map((e) => TodaySchedule.fromJson(e))
          .toList(),

      classes: (json["classes"] as List)
          .map((e) => TeacherClass.fromJson(e))
          .toList(),
    );
  }
}

class TeacherClass {
  int? classId;

  String? classCode;

  String? className;

  String? subjectName;

  int? studentCount;

  String? status;

  TeacherClass({
    this.classId,

    this.classCode,

    this.className,

    this.subjectName,

    this.studentCount,

    this.status,
  });

  factory TeacherClass.fromJson(Map<String, dynamic> json) {
    return TeacherClass(
      classId: json['classId'],

      classCode: json['classCode'],

      className: json['className'],

      subjectName: json['subjectName'],

      studentCount: json['studentCount'],

      status: json['status'],
    );
  }
}

class TodaySchedule {
  int? scheduleId;

  int? classId;

  String? classCode;

  String? className;

  String? subjectName;

  String? roomName;

  String? startTime;

  String? endTime;

  String? scheduleDate;

  TodaySchedule({
    this.scheduleId,

    this.classId,

    this.classCode,

    this.className,

    this.subjectName,

    this.roomName,

    this.startTime,

    this.endTime,

    this.scheduleDate,
  });

  factory TodaySchedule.fromJson(Map<String, dynamic> json) {
    return TodaySchedule(
      scheduleId: json['scheduleId'],

      classId: json['classId'],

      classCode: json['classCode'],

      className: json['className'],

      subjectName: json['subjectName'],

      roomName: json['roomName'],

      startTime: json['startTime'],

      endTime: json['endTime'],

      scheduleDate: json['scheduleDate'],
    );
  }
}
