class AttendanceDTO {
  final String subjectCode;
  final String date;
  final String timeSlot;
  final String status;

  AttendanceDTO({
    required this.subjectCode,
    required this.date,
    required this.timeSlot,
    required this.status,
  });

  factory AttendanceDTO.fromJson(Map<String, dynamic> json) {
    return AttendanceDTO(
      subjectCode: json['subjectCode'] ?? '',
      date: json['date'] ?? '',
      timeSlot: json['timeSlot'] ?? '',
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subjectCode': subjectCode,
      'date': date,
      'timeSlot': timeSlot,
      'status': status,
    };
  }
}
