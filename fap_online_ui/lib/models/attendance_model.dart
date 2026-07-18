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

  factory AttendanceStudent.fromJson(
      Map<String, dynamic> json) {

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
      "studentId": studentId,
      "status": status,
      "note": note,
    };

  }

}