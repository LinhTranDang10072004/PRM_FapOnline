class DashboardSummaryModel {
  final int unreadNotifications;
  final String? nextClassSubject;
  final String? nextClassTime;
  final String? nextClassRoom;

  DashboardSummaryModel({
    required this.unreadNotifications,
    this.nextClassSubject,
    this.nextClassTime,
    this.nextClassRoom,
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    return DashboardSummaryModel(
      unreadNotifications: json['unreadNotifications'] ?? 0,
      nextClassSubject: json['nextClassSubject'],
      nextClassTime: json['nextClassTime'],
      nextClassRoom: json['nextClassRoom'],
    );
  }
}
