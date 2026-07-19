class ApplicationModel {
  final int? applicationId;
  final String? title;
  final String? content;
  final String? status;
  final String? createdAt;
  final String? startDate;
  final String? endDate;

  ApplicationModel({
    this.applicationId,
    this.title,
    this.content,
    this.status,
    this.createdAt,
    this.startDate,
    this.endDate,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      applicationId: json['applicationId'],
      title: json['title'],
      content: json['content'],
      status: json['status'],
      createdAt: json['createdAt'],
      startDate: json['startDate'],
      endDate: json['endDate'],
    );
  }
}
