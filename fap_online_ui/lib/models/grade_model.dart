import 'component_grade_model.dart';

export 'component_grade_model.dart';

class GradeDetailModel {
  final int? classId;
  final String? classCode;
  final String? subjectCode;
  final String? subjectName;
  final double? finalScore;
  final double attendancePercent;
  final String result;
  final List<ComponentGradeModel> components;

  GradeDetailModel({
    this.classId,
    this.classCode,
    this.subjectCode,
    this.subjectName,
    this.finalScore,
    required this.attendancePercent,
    required this.result,
    required this.components,
  });

  factory GradeDetailModel.fromJson(Map<String, dynamic> json) {
    return GradeDetailModel(
      classId: json['classId'],
      classCode: json['classCode'],
      subjectCode: json['subjectCode'],
      subjectName: json['subjectName'],
      finalScore: (json['finalScore'] as num?)?.toDouble(),
      attendancePercent: (json['attendancePercent'] as num?)?.toDouble() ?? 0,
      result: json['result'] ?? 'Not Passed',
      components: (json['components'] as List<dynamic>?)
              ?.map((e) => ComponentGradeModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  bool get isPassed {
    final value = result.toLowerCase();
    return value == 'passed' || value == 'pass';
  }
}
