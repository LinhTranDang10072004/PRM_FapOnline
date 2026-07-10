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
    if (username != null && username.isNotEmpty) {
      await PreferencesHelper.saveUsername(username);
    }
    if (fullName != null && fullName.isNotEmpty) {
      await PreferencesHelper.saveFullName(fullName);
    }
  }
}
