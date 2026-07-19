class ParentDashboardData {
  final List<ParentChildSummary> children;
  final int unreadNotificationCount;
  final List<ParentTodaySchedule> todaySchedules;
  final List<ParentRecentGrade> recentGrades;
  final List<ParentUnpaidFee> unpaidFees;

  const ParentDashboardData({
    required this.children,
    required this.unreadNotificationCount,
    required this.todaySchedules,
    required this.recentGrades,
    required this.unpaidFees,
  });

  factory ParentDashboardData.fromJson(Map<String, dynamic> json) {
    return ParentDashboardData(
      children: _listOf(json['children'])
          .map((item) => ParentChildSummary.fromJson(item as Map<String, dynamic>))
          .toList(),
      unreadNotificationCount: (json['unreadNotificationCount'] as num?)?.toInt() ?? 0,
      todaySchedules: _listOf(json['todaySchedules'])
          .map((item) => ParentTodaySchedule.fromJson(item as Map<String, dynamic>))
          .toList(),
      recentGrades: _listOf(json['recentGrades'])
          .map((item) => ParentRecentGrade.fromJson(item as Map<String, dynamic>))
          .toList(),
      unpaidFees: _listOf(json['unpaidFees'])
          .map((item) => ParentUnpaidFee.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ParentChildSummary {
  final int? studentId;
  final String? studentCode;
  final String? fullName;
  final String? major;
  final String? academicStatus;

  const ParentChildSummary({
    required this.studentId,
    required this.studentCode,
    required this.fullName,
    required this.major,
    required this.academicStatus,
  });

  factory ParentChildSummary.fromJson(Map<String, dynamic> json) {
    return ParentChildSummary(
      studentId: _toInt(json['studentId']),
      studentCode: _toString(json['studentCode']),
      fullName: _toString(json['fullName']),
      major: _toString(json['major']),
      academicStatus: _toString(json['academicStatus']),
    );
  }
}

class ParentTodaySchedule {
  final int? studentId;
  final String? studentName;
  final String? subjectCode;
  final String? roomName;
  final String? timeSlot;

  const ParentTodaySchedule({
    required this.studentId,
    required this.studentName,
    required this.subjectCode,
    required this.roomName,
    required this.timeSlot,
  });

  factory ParentTodaySchedule.fromJson(Map<String, dynamic> json) {
    return ParentTodaySchedule(
      studentId: _toInt(json['studentId']),
      studentName: _toString(json['studentName']),
      subjectCode: _toString(json['subjectCode']),
      roomName: _toString(json['roomName']),
      timeSlot: _toString(json['timeSlot']),
    );
  }
}

class ParentRecentGrade {
  final int? studentId;
  final String? studentName;
  final String? subjectCode;
  final String? gradeComponent;
  final num? score;
  final String? enteredAt;

  const ParentRecentGrade({
    required this.studentId,
    required this.studentName,
    required this.subjectCode,
    required this.gradeComponent,
    required this.score,
    required this.enteredAt,
  });

  factory ParentRecentGrade.fromJson(Map<String, dynamic> json) {
    return ParentRecentGrade(
      studentId: _toInt(json['studentId']),
      studentName: _toString(json['studentName']),
      subjectCode: _toString(json['subjectCode']),
      gradeComponent: _toString(json['gradeComponent']),
      score: _toNum(json['score']),
      enteredAt: _toString(json['enteredAt']),
    );
  }
}

class ParentUnpaidFee {
  final int? studentId;
  final String? studentName;
  final String? feeType;
  final num? amount;
  final num? paidAmount;
  final String? dueDate;

  const ParentUnpaidFee({
    required this.studentId,
    required this.studentName,
    required this.feeType,
    required this.amount,
    required this.paidAmount,
    required this.dueDate,
  });

  factory ParentUnpaidFee.fromJson(Map<String, dynamic> json) {
    return ParentUnpaidFee(
      studentId: _toInt(json['studentId']),
      studentName: _toString(json['studentName']),
      feeType: _toString(json['feeType']),
      amount: _toNum(json['amount']),
      paidAmount: _toNum(json['paidAmount']),
      dueDate: _toString(json['dueDate']),
    );
  }
}

class ParentNotificationItem {
  final int? notificationId;
  final String? title;
  final String? message;
  final String? sentAt;
  final bool isRead;

  const ParentNotificationItem({
    required this.notificationId,
    required this.title,
    required this.message,
    required this.sentAt,
    required this.isRead,
  });

  factory ParentNotificationItem.fromJson(Map<String, dynamic> json) {
    return ParentNotificationItem(
      notificationId: _toInt(json['notificationId']),
      title: _toString(json['title']),
      message: _toString(json['message']),
      sentAt: _toString(json['sentAt']),
      isRead: json['isRead'] == true || json['read'] == true,
    );
  }
}

class ParentProfileData {
  final String? fullName;
  final String? email;
  final String? phone;
  final String? dateOfBirth;
  final String? gender;
  final String? address;
  final String? avatarUrl;

  const ParentProfileData({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.dateOfBirth,
    required this.gender,
    required this.address,
    required this.avatarUrl,
  });

  factory ParentProfileData.fromJson(Map<String, dynamic> json) {
    return ParentProfileData(
      fullName: _toString(json['fullName']),
      email: _toString(json['email']),
      phone: _toString(json['phone']),
      dateOfBirth: _toString(json['dateOfBirth']),
      gender: _toString(json['gender']),
      address: _toString(json['address']),
      avatarUrl: _toString(json['avatarUrl']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'phone': phone?.trim().isEmpty == true ? null : phone,
      'dateOfBirth': dateOfBirth?.trim().isEmpty == true ? null : dateOfBirth,
      'gender': gender,
      'address': address?.trim().isEmpty == true ? null : address,
      'avatarUrl': avatarUrl?.trim().isEmpty == true ? null : avatarUrl,
    };
  }
}

class ParentChildDetailData {
  final int? studentId;
  final String? studentCode;
  final String? fullName;
  final String? email;
  final String? phone;
  final String? dateOfBirth;
  final String? gender;
  final String? avatarUrl;
  final String? major;
  final int? enrollmentYear;
  final String? academicStatus;

  const ParentChildDetailData({
    required this.studentId,
    required this.studentCode,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.dateOfBirth,
    required this.gender,
    required this.avatarUrl,
    required this.major,
    required this.enrollmentYear,
    required this.academicStatus,
  });

  factory ParentChildDetailData.fromJson(Map<String, dynamic> json) {
    return ParentChildDetailData(
      studentId: _toInt(json['studentId']),
      studentCode: _toString(json['studentCode']),
      fullName: _toString(json['fullName']),
      email: _toString(json['email']),
      phone: _toString(json['phone']),
      dateOfBirth: _toString(json['dateOfBirth']),
      gender: _toString(json['gender']),
      avatarUrl: _toString(json['avatarUrl']),
      major: _toString(json['major']),
      enrollmentYear: _toInt(json['enrollmentYear']),
      academicStatus: _toString(json['academicStatus']),
    );
  }
}

class ParentWeeklyTimetableItem {
  final String? scheduleDate;
  final String? subjectCode;
  final String? roomName;
  final String? timeSlot;
  final String? startTime;
  final String? endTime;
  final String? status;

  const ParentWeeklyTimetableItem({
    required this.scheduleDate,
    required this.subjectCode,
    required this.roomName,
    required this.timeSlot,
    required this.startTime,
    required this.endTime,
    required this.status,
  });

  factory ParentWeeklyTimetableItem.fromJson(Map<String, dynamic> json) {
    return ParentWeeklyTimetableItem(
      scheduleDate: _toString(json['scheduleDate']),
      subjectCode: _toString(json['subjectCode']),
      roomName: _toString(json['roomName']),
      timeSlot: _toString(json['timeSlot']),
      startTime: _toString(json['startTime']),
      endTime: _toString(json['endTime']),
      status: _toString(json['status']),
    );
  }
}

class ParentAttendanceRecord {
  final String? subjectCode;
  final String? date;
  final String? timeSlot;
  final String? status;

  const ParentAttendanceRecord({
    required this.subjectCode,
    required this.date,
    required this.timeSlot,
    required this.status,
  });

  factory ParentAttendanceRecord.fromJson(Map<String, dynamic> json) {
    return ParentAttendanceRecord(
      subjectCode: _toString(json['subjectCode']),
      date: _toString(json['date']),
      timeSlot: _toString(json['timeSlot']),
      status: _toString(json['status']),
    );
  }
}

class ParentGradeRecord {
  final String? subjectCode;
  final String? gradeComponent;
  final num? score;
  final num? weight;

  const ParentGradeRecord({
    required this.subjectCode,
    required this.gradeComponent,
    required this.score,
    required this.weight,
  });

  factory ParentGradeRecord.fromJson(Map<String, dynamic> json) {
    return ParentGradeRecord(
      subjectCode: _toString(json['subjectCode']),
      gradeComponent: _toString(json['gradeComponent']),
      score: _toNum(json['score']),
      weight: _toNum(json['weight']),
    );
  }
}

class ParentTranscriptRecord {
  final String? subjectCode;
  final String? subjectName;
  final num? finalScore;
  final String? status;

  const ParentTranscriptRecord({
    required this.subjectCode,
    required this.subjectName,
    required this.finalScore,
    required this.status,
  });

  factory ParentTranscriptRecord.fromJson(Map<String, dynamic> json) {
    return ParentTranscriptRecord(
      subjectCode: _toString(json['subjectCode']),
      subjectName: _toString(json['subjectName']),
      finalScore: _toNum(json['finalScore']),
      status: _toString(json['status']),
    );
  }
}

class ParentFeeRecord {
  final int? feeId;
  final String? feeType;
  final num? amount;
  final num? paidAmount;
  final String? dueDate;
  final String? status;

  const ParentFeeRecord({
    required this.feeId,
    required this.feeType,
    required this.amount,
    required this.paidAmount,
    required this.dueDate,
    required this.status,
  });

  factory ParentFeeRecord.fromJson(Map<String, dynamic> json) {
    return ParentFeeRecord(
      feeId: _toInt(json['feeId']),
      feeType: _toString(json['feeType']),
      amount: _toNum(json['amount']),
      paidAmount: _toNum(json['paidAmount']),
      dueDate: _toString(json['dueDate']),
      status: _toString(json['status']),
    );
  }
}

class AttendanceSummary {
  final int total;
  final int present;
  final int late;
  final int absent;
  final int other;

  const AttendanceSummary({
    required this.total,
    required this.present,
    required this.late,
    required this.absent,
    required this.other,
  });

  const AttendanceSummary.empty()
      : total = 0,
        present = 0,
        late = 0,
        absent = 0,
        other = 0;

  factory AttendanceSummary.fromRecords(List<ParentAttendanceRecord> records) {
    var present = 0;
    var late = 0;
    var absent = 0;
    var other = 0;

    for (final record in records) {
      final status = (record.status ?? '').trim().toLowerCase();
      if (status.contains('present')) {
        present++;
      } else if (status.contains('late')) {
        late++;
      } else if (status.contains('absent')) {
        absent++;
      } else if (status.isNotEmpty) {
        other++;
      }
    }

    return AttendanceSummary(
      total: records.length,
      present: present,
      late: late,
      absent: absent,
      other: other,
    );
  }

  AttendanceSummary combine(AttendanceSummary otherSummary) {
    return AttendanceSummary(
      total: total + otherSummary.total,
      present: present + otherSummary.present,
      late: late + otherSummary.late,
      absent: absent + otherSummary.absent,
      other: other + otherSummary.other,
    );
  }
}

List<dynamic> _listOf(dynamic value) {
  if (value is List) return value;
  return const [];
}

String? _toString(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

num? _toNum(dynamic value) {
  if (value == null) return null;
  if (value is num) return value;
  return num.tryParse(value.toString());
}
