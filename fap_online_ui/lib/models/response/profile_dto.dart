class ProfileDTO {
  final String? fullName;
  final String? email;
  final String? phone;
  final String? dateOfBirth;
  final String? gender;
  final String? address;
  final String? avatarUrl;
  final String? role;
  final String? username;

  ProfileDTO({
    this.fullName,
    this.email,
    this.phone,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.avatarUrl,
    this.role,
    this.username,
  });

  factory ProfileDTO.fromJson(Map<String, dynamic> json) {
    return ProfileDTO(
      fullName: json['fullName'],
      email: json['email'],
      phone: json['phone'],
      dateOfBirth: json['dateOfBirth'],
      gender: json['gender'],
      address: json['address'],
      avatarUrl: json['avatarUrl'],
      role: json['role'],
      username: json['username'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (fullName != null) 'fullName': fullName,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
      if (gender != null) 'gender': gender,
      if (address != null) 'address': address,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      // role and username are read-only
    };
  }
}
