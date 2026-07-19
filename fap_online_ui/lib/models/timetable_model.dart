class TimetableModel {
  final int? scheduleId;
  final String? scheduleDate;
  final String? roomCode;
  final String? slotCode;
  final String? slotTime;
  final String? classCode;
  final String? subjectCode;
  final String? subjectName;
  final String? teacherCode;
  final String? scheduleStatus;
  final String? attendanceStatus;
  final String? attendanceLabel;
  final String? statusType;
  final String? statusLabel;

  TimetableModel({
    this.scheduleId,
    this.scheduleDate,
    this.roomCode,
    this.slotCode,
    this.slotTime,
    this.classCode,
    this.subjectCode,
    this.subjectName,
    this.teacherCode,
    this.scheduleStatus,
    this.attendanceStatus,
    this.attendanceLabel,
    this.statusType,
    this.statusLabel,
  });

  factory TimetableModel.fromJson(Map<String, dynamic> json) {
    return TimetableModel(
      scheduleId: json['scheduleId'],
      scheduleDate: json['scheduleDate']?.toString(),
      roomCode: json['roomCode'],
      slotCode: json['slotCode'],
      slotTime: json['slotTime'],
      classCode: json['classCode'],
      subjectCode: json['subjectCode'],
      subjectName: json['subjectName'],
      teacherCode: json['teacherCode'],
      scheduleStatus: json['scheduleStatus'],
      attendanceStatus: json['attendanceStatus'],
      attendanceLabel: json['attendanceLabel'],
      statusType: json['statusType'],
      statusLabel: json['statusLabel'],
    );
  }
}
