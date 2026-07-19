import '../config/api_endpoints.dart';
import 'dart:typed_data';
import '../models/response/profile_dto.dart';
import 'api_service.dart';

class ProfileService {
  final ApiService _apiService = ApiService();

  Future<ProfileDTO?> getProfile() async {
    try {
      final response = await _apiService.get(ApiEndpoints.profile);
      if (response != null) {
        return ProfileDTO.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Error fetching profile: $e');
      return null;
    }
  }

  Future<bool> updateProfile(ProfileDTO profile) async {
    try {
      await _apiService.put(ApiEndpoints.profile, body: profile.toJson());
      return true;
    } catch (e) {
      print('Error updating profile: $e');
      return false;
    }
  }

  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      await _apiService.put(
        ApiEndpoints.changePassword,
        body: {
          'oldPassword': oldPassword,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
      );
      return true;
    } catch (e) {
      print('Error changing password: $e');
      return false;
    }
  }

  Future<String> uploadAvatar(Uint8List bytes, String filename) async {
    final response = await _apiService.uploadBytes(
      '/files/upload',
      bytes,
      filename,
    );
    final url = response is Map ? response['url'] as String? : null;
    if (url == null || url.isEmpty) {
      throw ApiException('Máy chủ không trả về đường dẫn ảnh.', 0);
    }
    return url;
  }
}
