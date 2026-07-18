import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import '../models/auth_response.dart';

class AuthException implements Exception {
  final String message;
  final int? statusCode;

  AuthException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class AuthService {
  static const _tokenKey = 'auth_token';
  static const _usernameKey = 'auth_username';
  static const _fullNameKey = 'auth_full_name';
  static const _userIdKey = 'auth_user_id';
  Future<AuthResponse> login(String username, String password) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.loginPath}');

    late final http.Response response;
    try {
      response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'username': username.trim(),
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 15));
    } catch (_) {
      throw AuthException(
        'Không kết nối được server. Kiểm tra backend đã chạy và baseUrl đúng chưa.',
      );
    }

    final body = _decodeBody(response.body);

    if (response.statusCode == 200) {
      final auth = AuthResponse.fromJson(body);
      if (auth.token == null || auth.token!.isEmpty) {
        throw AuthException('Server không trả về token.');
      }
      await _saveSession(auth);
      return auth;
    }

    throw AuthException(
      _extractErrorMessage(body, response.statusCode),
      statusCode: response.statusCode,
    );
  }

  Future<void> logout() async {
    final token = await getToken();
    if (token != null) {
      try {
        await http
            .post(
              Uri.parse('${ApiConfig.baseUrl}${ApiConfig.logoutPath}'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              },
            )
            .timeout(const Duration(seconds: 10));
      } catch (_) {
        // Ignore network errors on logout; still clear local session.
      }
    }
    await clearSession();
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey);
  }

  Future<String?> getFullName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_fullNameKey);
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_usernameKey);
    await prefs.remove(_fullNameKey);
    await prefs.remove(_userIdKey);
  }

  Future<void> _saveSession(AuthResponse auth) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, auth.token!);
    if (auth.username != null) {
      await prefs.setString(_usernameKey, auth.username!);
    }
    if (auth.userId != null) {
      await prefs.setInt(_userIdKey, auth.userId!);
    }
    if (auth.fullName != null) {
      await prefs.setString(_fullNameKey, auth.fullName!);
    }
  }

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getInt(_userIdKey);
  }

  Map<String, dynamic> _decodeBody(String raw) {
    if (raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      return {};
    } catch (_) {
      return {};
    }
  }

  String _extractErrorMessage(Map<String, dynamic> body, int statusCode) {
    final message = body['message']?.toString();
    if (message != null && message.isNotEmpty) return message;

    final error = body['error']?.toString();
    if (error != null && error.isNotEmpty) return error;

    switch (statusCode) {
      case 401:
        return 'Sai username hoặc password';
      case 403:
        return 'Tài khoản không hoạt động';
      case 400:
        return 'Dữ liệu đăng nhập không hợp lệ';
      default:
        return 'Đăng nhập thất bại (HTTP $statusCode)';
    }
  }
}
