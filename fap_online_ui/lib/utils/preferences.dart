import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';

class PreferencesHelper {
  static const String _usernameKey = 'username';
  static const String _fullNameKey = 'full_name';
  static const String _roleKey = 'user_role';
  static const String _userIdKey = 'user_id';
  static const String _campusCodeKey = 'campus_code';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(Constants.tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(Constants.tokenKey);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(Constants.tokenKey);
  }

  static Future<void> saveUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usernameKey, username);
  }

  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey);
  }

  static Future<void> saveFullName(String fullName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fullNameKey, fullName);
  }

  static Future<String?> getFullName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_fullNameKey);
  }

  /// Xóa session login. Campus vẫn giữ để lần sau khỏi chọn lại.
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(Constants.tokenKey);
    await prefs.remove(_usernameKey);
    await prefs.remove(_fullNameKey);
    await prefs.remove(_roleKey);
    await prefs.remove(_userIdKey);
  }

  static Future<void> saveRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_roleKey, role);
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }

  static Future<void> saveUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, userId);
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  static Future<void> saveCampusCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_campusCodeKey, code);
  }

  static Future<String?> getCampusCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_campusCodeKey);
  }

  static Future<void> clearCampus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_campusCodeKey);
  }
}
