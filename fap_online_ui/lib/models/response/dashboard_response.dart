class ChildSummaryDTO {
  final int studentId;
  final String studentCode;
  final String fullName;
  final String major;
  final String academicStatus;

  ChildSummaryDTO({
    required this.studentId,
    required this.studentCode,
    required this.fullName,
    required this.major,
    required this.academicStatus,
  });

  factory ChildSummaryDTO.fromJson(Map<String, dynamic> json) {
    return ChildSummaryDTO(
      studentId: json['studentId'] ?? 0,
      studentCode: json['studentCode'] ?? '',
      fullName: json['fullName'] ?? '',
      major: json['major'] ?? '',
      academicStatus: json['academicStatus'] ?? '',
    );
  }
}

class TodayScheduleDTO {
  final int? studentId;
  final String studentName;
  final String subjectCode;
  final String roomName;
  final String timeSlot;

  TodayScheduleDTO({
    this.studentId,
    required this.studentName,
    required this.subjectCode,
    required this.roomName,
    required this.timeSlot,
  });

  factory TodayScheduleDTO.fromJson(Map<String, dynamic> json) {
    return TodayScheduleDTO(
      studentId: json['studentId'],
      studentName: json['studentName'] ?? '',
      subjectCode: json['subjectCode'] ?? '',
      roomName: json['roomName'] ?? '',
      timeSlot: json['timeSlot'] ?? '',
    );
  }
}

class RecentGradeDTO {
  final int studentId;
  final String studentName;
  final String subjectCode;
  final String gradeComponent;
  final double score;
  final String enteredAt;

  RecentGradeDTO({
    required this.studentId,
    required this.studentName,
    required this.subjectCode,
    required this.gradeComponent,
    required this.score,
    required this.enteredAt,
  });

  factory RecentGradeDTO.fromJson(Map<String, dynamic> json) {
    return RecentGradeDTO(
      studentId: json['studentId'] ?? 0,
      studentName: json['studentName'] ?? '',
      subjectCode: json['subjectCode'] ?? '',
      gradeComponent: json['gradeComponent'] ?? '',
      score: (json['score'] ?? 0).toDouble(),
      enteredAt: json['enteredAt'] ?? '',
    );
  }
}

class UnpaidFeeDTO {
  final int studentId;
  final String studentName;
  final String feeType;
  final double amount;
  final double paidAmount;
  final String dueDate;

  UnpaidFeeDTO({
    required this.studentId,
    required this.studentName,
    required this.feeType,
    required this.amount,
    required this.paidAmount,
    required this.dueDate,
  });

  factory UnpaidFeeDTO.fromJson(Map<String, dynamic> json) {
    return UnpaidFeeDTO(
      studentId: json['studentId'] ?? 0,
      studentName: json['studentName'] ?? '',
      feeType: json['feeType'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      paidAmount: (json['paidAmount'] ?? 0).toDouble(),
      dueDate: json['dueDate'] ?? '',
    );
  }
}

class DashboardResponse {
  final List<ChildSummaryDTO> children;
  final int unreadNotificationCount;
  final List<TodayScheduleDTO> todaySchedules;
  final List<RecentGradeDTO> recentGrades;
  final List<UnpaidFeeDTO> unpaidFees;
  final int attendancePresentCount;
  final int attendanceTotalCount;

  DashboardResponse({
    required this.children,
    required this.unreadNotificationCount,
    required this.todaySchedules,
    required this.recentGrades,
    required this.unpaidFees,
    required this.attendancePresentCount,
    required this.attendanceTotalCount,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      children:
          (json['children'] as List?)
              ?.map((e) => ChildSummaryDTO.fromJson(e))
              .toList() ??
          [],
      unreadNotificationCount: json['unreadNotificationCount'] ?? 0,
      todaySchedules:
          (json['todaySchedules'] as List?)
              ?.map((e) => TodayScheduleDTO.fromJson(e))
              .toList() ??
          [],
      recentGrades:
          (json['recentGrades'] as List?)
              ?.map((e) => RecentGradeDTO.fromJson(e))
              .toList() ??
          [],
      unpaidFees:
          (json['unpaidFees'] as List?)
              ?.map((e) => UnpaidFeeDTO.fromJson(e))
              .toList() ??
          [],
      attendancePresentCount: json['attendancePresentCount'] ?? 0,
      attendanceTotalCount: json['attendanceTotalCount'] ?? 0,
    );
  }
}
