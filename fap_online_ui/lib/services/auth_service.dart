import '../config/api_endpoints.dart';
import '../models/auth_response.dart';
import '../models/request/login_request.dart';
import '../utils/preferences.dart';
import 'api_service.dart';

class AuthService {

  final ApiService _apiService = ApiService();

  Future<AuthResponse> login(LoginRequest request) async {
    final response = await _apiService.post(ApiEndpoints.login, request.toJson());
    final authResponse = AuthResponse.fromJson(response as Map<String, dynamic>);
    await _persistSession(authResponse);

    return authResponse;
  }

  Future<AuthResponse?> me() async {
    try {
      final response = await _apiService.get(ApiEndpoints.me);
      return AuthResponse.fromJson(response as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<AuthResponse?> restoreSession() async {
    final current = await me();
    if (current != null) {
      await _persistSession(current);
    }
    return current;
  }

  Future<String?> getUsername() {
    return PreferencesHelper.getUsername();
  }

  Future<String?> getFullName() {
    return PreferencesHelper.getFullName();
  }

  Future<void> logout() async {
    try {
      await _apiService.post(ApiEndpoints.logout, <String, dynamic>{});
    } catch (_) {}
    await PreferencesHelper.clearUserData();
  }


  Future<void> _persistSession(AuthResponse authResponse) async {
    final token = authResponse.token;
    final username = authResponse.username;
    final fullName = authResponse.fullName;

    if (token != null && token.isNotEmpty) {
      await PreferencesHelper.saveToken(token);
    }
    if (auth.userId != null) {
      await prefs.setInt(_userIdKey, auth.userId!);
    }
    if (auth.fullName != null) {
      await prefs.setString(_fullNameKey, auth.fullName!);

    if (username != null && username.isNotEmpty) {
      await PreferencesHelper.saveUsername(username);
    }
    if (fullName != null && fullName.isNotEmpty) {
      await PreferencesHelper.saveFullName(fullName);

    }

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getInt(_userIdKey);
  }

  Map<String, dynamic> _decodeBody(String raw) {
    if (raw.isEmpty) return {};

    try {
      final meData = await _apiService.get(ApiEndpoints.me);
      if (meData is Map<String, dynamic>) {
        final roles = meData['roles'] as List<dynamic>?;
        final role = meData['role'] as String? ??
            (roles?.isNotEmpty == true ? roles!.first as String? : null);
        if (role != null && role.isNotEmpty) {
          await PreferencesHelper.saveRole(role);
        }
      }
    } catch (_) {

    }
  }
}
