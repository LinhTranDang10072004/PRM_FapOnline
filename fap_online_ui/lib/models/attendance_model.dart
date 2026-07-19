class AttendanceModel {
  final String? subjectCode;
  final String? subjectName;
  final int totalSlots;
  final int absentSlots;
  final int presentSlots;
  final double absentPercent;
  final double presentPercent;
  final int? semesterId;
  final String? semesterCode;
  final String? semesterName;

  AttendanceModel({
    this.subjectCode,
    this.subjectName,
    required this.totalSlots,
    required this.absentSlots,
    required this.presentSlots,
    required this.absentPercent,
    required this.presentPercent,
    this.semesterId,
    this.semesterCode,
    this.semesterName,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    final total = json['totalSlots'] ?? 20;
    final absent = json['absentSlots'] ?? 0;
    final present = json['presentSlots'] ?? (total - absent);
    final presentPct = (json['presentPercent'] as num?)?.toDouble();
    final absentPct = (json['absentPercent'] as num?)?.toDouble();

    return AttendanceModel(
      subjectCode: json['subjectCode'],
      subjectName: json['subjectName'],
      totalSlots: total is int ? total : int.tryParse('$total') ?? 20,
      absentSlots: absent is int ? absent : int.tryParse('$absent') ?? 0,
      presentSlots: present is int ? present : int.tryParse('$present') ?? 0,
      absentPercent: absentPct ?? 0.0,
      presentPercent: presentPct ?? 0.0,
      semesterId: json['semesterId'],
      semesterCode: json['semesterCode']?.toString(),
      semesterName: json['semesterName']?.toString(),
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
