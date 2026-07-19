class AttendanceModel {
  final String? subjectCode;
  final String? subjectName;
  final int totalSlots;
  final int absentSlots;
  final double absentPercent;

  AttendanceModel({
    this.subjectCode,
    this.subjectName,
    required this.totalSlots,
    required this.absentSlots,
    required this.absentPercent,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      subjectCode: json['subjectCode'],
      subjectName: json['subjectName'],
      totalSlots: json['totalSlots'] ?? 0,
      absentSlots: json['absentSlots'] ?? 0,
      absentPercent: (json['absentPercent'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Teacher take-attendance row for one student in a schedule.
class AttendanceStudent {
  int? studentId;
  String? studentCode;
  String? fullName;
  String? status;
  String? note;

  AttendanceStudent({
    this.studentId,
    this.studentCode,
    this.fullName,
    this.status,
    this.note,
  });

  factory AttendanceStudent.fromJson(Map<String, dynamic> json) {
    return AttendanceStudent(
      studentId: json['studentId'],
      studentCode: json['studentCode'],
      fullName: json['fullName'],
      status: json['status'],
      note: json['note'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'status': status,
      'note': note,
    };
  }
}
