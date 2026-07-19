class TranscriptSubjectModel {
  final String? classCode;
  final String? subjectCode;
  final String? subjectName;
  final double? finalScore;
  final String? result;

  TranscriptSubjectModel({
    this.classCode,
    this.subjectCode,
    this.subjectName,
    this.finalScore,
    this.result,
  });

  factory TranscriptSubjectModel.fromJson(Map<String, dynamic> json) {
    return TranscriptSubjectModel(
      classCode: json['classCode'],
      subjectCode: json['subjectCode'],
      subjectName: json['subjectName'],
      finalScore: (json['finalScore'] as num?)?.toDouble(),
      result: json['result'],
    );
  }
}

class TranscriptModel {
  final String? semesterName;
  final List<TranscriptSubjectModel> subjects;

  TranscriptModel({
    this.semesterName,
    required this.subjects,
  });

  factory TranscriptModel.fromJson(Map<String, dynamic> json) {
    return TranscriptModel(
      semesterName: json['semesterName'],
      subjects: (json['subjects'] as List<dynamic>?)
              ?.map((e) => TranscriptSubjectModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}
