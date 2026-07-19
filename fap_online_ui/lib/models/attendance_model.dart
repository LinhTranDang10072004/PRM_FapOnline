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
