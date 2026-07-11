class NotificationDTO {
  final int notificationId;
  final String title;
  final String message;
  final String sentAt;
  final bool isRead;

  NotificationDTO({
    required this.notificationId,
    required this.title,
    required this.message,
    required this.sentAt,
    required this.isRead,
  });

  factory NotificationDTO.fromJson(Map<String, dynamic> json) {
    return NotificationDTO(
      notificationId: json['notificationId'] ?? 0,
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      sentAt: json['sentAt'] ?? '',
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationId': notificationId,
      'title': title,
      'message': message,
      'sentAt': sentAt,
      'isRead': isRead,
    };
  }
}
