class CourseMarkSummaryModel {
  final int classId;
  final String classCode;
  final String subjectCode;
  final String subjectName;
  final double? average;
  final double attendancePercent;
  final String result;

  CourseMarkSummaryModel({
    required this.classId,
    required this.classCode,
    required this.subjectCode,
    required this.subjectName,
    this.average,
    required this.attendancePercent,
    required this.result,
  });

  factory CourseMarkSummaryModel.fromJson(Map<String, dynamic> json) {
    return CourseMarkSummaryModel(
      classId: json['classId'] ?? 0,
      classCode: json['classCode'] ?? '',
      subjectCode: json['subjectCode'] ?? '',
      subjectName: json['subjectName'] ?? '',
      average: (json['average'] as num?)?.toDouble(),
      attendancePercent: (json['attendancePercent'] as num?)?.toDouble() ?? 0,
      result: json['result'] ?? 'Not Passed',
    );
  }

  bool get isPassed {
    final value = result.toLowerCase();
    return value == 'passed' || value == 'pass';
  }
}

class SemesterMarkModel {
  final int semesterId;
  final String semesterCode;
  final String semesterName;
  final List<CourseMarkSummaryModel> courses;

  SemesterMarkModel({
    required this.semesterId,
    required this.semesterCode,
    required this.semesterName,
    required this.courses,
  });

  factory SemesterMarkModel.fromJson(Map<String, dynamic> json) {
    return SemesterMarkModel(
      semesterId: json['semesterId'] ?? 0,
      semesterCode: json['semesterCode'] ?? '',
      semesterName: json['semesterName'] ?? '',
      courses: (json['courses'] as List<dynamic>?)
              ?.map((e) => CourseMarkSummaryModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class MarkReportModel {
  final List<SemesterMarkModel> semesters;

  MarkReportModel({required this.semesters});

  factory MarkReportModel.fromJson(Map<String, dynamic> json) {
    return MarkReportModel(
      semesters: (json['semesters'] as List<dynamic>?)
              ?.map((e) => SemesterMarkModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}
