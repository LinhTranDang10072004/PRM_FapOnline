import '../config/api_endpoints.dart';
import '../models/auth_response.dart';
import '../models/request/login_request.dart';
import '../utils/preferences.dart';
import 'api_service.dart';

/// Gọi API đăng nhập / đăng xuất.
class AuthService {
  final ApiService _apiService = ApiService();

  Future<AuthResponse> login(LoginRequest request) async {
    // tra ve sau khi dang nhap
    final response = await _apiService.post(
      ApiEndpoints.login,
      request.toJson(),
    ); // lay enpoint login
    final authResponse = AuthResponse.fromJson(
      response as Map<String, dynamic>,
    );
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
    // khôi phục phiên đăng nhập
    final current = await me();
    if (current != null) {
      await _persistSession(current);
    }
    return current;
  }

  Future<String?> getUsername() => PreferencesHelper.getUsername();

  Future<String?> getFullName() => PreferencesHelper.getFullName();

  Future<int?> getUserId() => PreferencesHelper.getUserId();

  Future<String?> getRole() => PreferencesHelper.getRole();

  Future<String?> getToken() => PreferencesHelper.getToken();

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
    final userId = authResponse.userId;
    final role = authResponse.role;

    if (token != null && token.isNotEmpty) {
      await PreferencesHelper.saveToken(token);
    }
    if (userId != null) {
      await PreferencesHelper.saveUserId(userId);
    }
    if (username != null && username.isNotEmpty) {
      await PreferencesHelper.saveUsername(username);
    }
    if (fullName != null && fullName.isNotEmpty) {
      await PreferencesHelper.saveFullName(fullName);
    }
    if (role != null && role.isNotEmpty) {
      await PreferencesHelper.saveRole(role);
    } else {
      await _tryFetchAndSaveRole();
    }
  }

  Future<void> _tryFetchAndSaveRole() async {
    try {
      final meData = await _apiService.get(ApiEndpoints.me);
      if (meData is Map<String, dynamic>) {
        final roles = meData['roles'] as List<dynamic>?;
        final role =
            meData['role'] as String? ??
            (roles?.isNotEmpty == true ? roles!.first as String? : null);
        if (role != null && role.isNotEmpty) {
          await PreferencesHelper.saveRole(role);
        }
      }
    } catch (_) {}
  }
}
