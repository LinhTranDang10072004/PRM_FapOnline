import '../config/api_endpoints.dart';
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

  Future<String?> uploadAvatar(String filePath) async {
    try {
      final response = await _apiService.uploadFile('/files/upload', filePath);
      if (response != null && response['url'] != null) {
        return response['url'];
      }
      return null;
    } catch (e) {
      print('Error uploading avatar: $e');
      return null;
    }
  }
}
