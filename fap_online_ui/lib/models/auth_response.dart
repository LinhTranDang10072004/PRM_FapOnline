class AuthResponse {
  final String? token;
  final String? username;
  final String? fullName;
  final String? message;

  AuthResponse({
    this.token,
    this.username,
    this.fullName,
    this.message,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String?,
      username: json['username'] as String?,
      fullName: json['fullName'] as String?,
      message: json['message'] as String?,
    );
  }
}
