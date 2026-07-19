class WeeklyTimetableDTO {
  final String scheduleDate;
  final String subjectCode;
  final String roomName;
  final String timeSlot;
  final String startTime;
  final String endTime;
  final String status;

  WeeklyTimetableDTO({
    required this.scheduleDate,
    required this.subjectCode,
    required this.roomName,
    required this.timeSlot,
    required this.startTime,
    required this.endTime,
    required this.status,
  });

  factory WeeklyTimetableDTO.fromJson(Map<String, dynamic> json) {
    return WeeklyTimetableDTO(
      scheduleDate: json['scheduleDate'] ?? '',
      subjectCode: json['subjectCode'] ?? '',
      roomName: json['roomName'] ?? '',
      timeSlot: json['timeSlot'] ?? '',
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      status: json['status'] ?? '',
    );
  }
}
