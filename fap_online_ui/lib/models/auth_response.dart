class AuthResponse {
  final int? userId;
  final String? token;
  final String? username;
  final String? fullName;
  final String? message;
  final String? role;

  AuthResponse({
    this.userId,
    this.token,
    this.username,
    this.fullName,
    this.message,
    this.role,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      userId: json['userId'],
      token: json['token'] as String?,
      username: json['username'] as String?,
      fullName: json['fullName'] as String?,
      message: json['message'] as String?,
      role: json['role'] as String?,
    );
  }
}
