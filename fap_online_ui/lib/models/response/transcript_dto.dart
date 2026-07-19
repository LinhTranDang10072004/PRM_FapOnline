class TranscriptDTO {
  final String subjectCode;
  final String subjectName;
  final double? finalScore;
  final String status;

  TranscriptDTO({
    required this.subjectCode,
    required this.subjectName,
    this.finalScore,
    required this.status,
  });

  factory TranscriptDTO.fromJson(Map<String, dynamic> json) {
    return TranscriptDTO(
      subjectCode: json['subjectCode'] ?? '',
      subjectName: json['subjectName'] ?? '',
      finalScore: json['finalScore'] != null ? (json['finalScore'] as num).toDouble() : null,
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subjectCode': subjectCode,
      'subjectName': subjectName,
      'finalScore': finalScore,
      'status': status,
    };
  }
}
