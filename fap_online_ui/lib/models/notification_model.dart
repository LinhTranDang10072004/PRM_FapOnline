class NotificationModel {
  final int notificationId;
  final String title;
  final String content;
  final String type;
  final String createdAt;
  final bool isRead;

  NotificationModel({
    required this.notificationId,
    required this.title,
    required this.content,
    required this.type,
    required this.createdAt,
    required this.isRead,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      notificationId: json['notificationId'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      type: json['type'] ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
      isRead: json['isRead'] ?? false,
    );
  }
}
