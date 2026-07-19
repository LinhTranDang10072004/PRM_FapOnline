class ChildDetailDTO {
  final int studentId;
  final String studentCode;
  final String fullName;
  final String major;
  final String academicStatus;
  final String? email;
  final String? phone;
  final String? dateOfBirth;
  final String? gender;
  final String? address;
  final String? avatarUrl;
  final int? enrollmentYear;

  ChildDetailDTO({
    required this.studentId,
    required this.studentCode,
    required this.fullName,
    required this.major,
    required this.academicStatus,
    this.email,
    this.phone,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.avatarUrl,
    this.enrollmentYear,
  });

  factory ChildDetailDTO.fromJson(Map<String, dynamic> json) {
    return ChildDetailDTO(
      studentId: json['studentId'] ?? 0,
      studentCode: json['studentCode'] ?? '',
      fullName: json['fullName'] ?? '',
      major: json['major'] ?? '',
      academicStatus: json['academicStatus'] ?? '',
      email: json['email'],
      phone: json['phone'],
      dateOfBirth: json['dateOfBirth'],
      gender: json['gender'],
      address: json['address'],
      avatarUrl: json['avatarUrl'],
      enrollmentYear: json['enrollmentYear'],
    );
  }
}
