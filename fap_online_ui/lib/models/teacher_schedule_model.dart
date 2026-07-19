class TeacherSchedule {
  int? scheduleId;

  int? classId;

  String? classCode;

  String? className;

  String? subjectName;

  String? roomName;

  String? scheduleDate;

  String? startTime;

  String? endTime;

  String? status;

  TeacherSchedule({
    this.scheduleId,

    this.classId,

    this.classCode,

    this.className,

    this.subjectName,

    this.roomName,

    this.scheduleDate,

    this.startTime,

    this.endTime,

    this.status,
  });

  factory TeacherSchedule.fromJson(Map<String, dynamic> json) {
    return TeacherSchedule(
      scheduleId: json['scheduleId'],

      classId: json['classId'],

      classCode: json['classCode'],

      className: json['className'],

      subjectName: json['subjectName'],

      roomName: json['roomName'],

      scheduleDate: json['scheduleDate'],

      startTime: json['startTime'],

      endTime: json['endTime'],

      status: json['status'],
    );
  }
}
