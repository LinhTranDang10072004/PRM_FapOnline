import '../../../../services/api_service.dart';
import '../../../../config/api_endpoints.dart';
import '../models/admin_models.dart';

class AdminProfileService {
  final ApiService _api = ApiService();

  Future<AdminProfileModel> getProfile() async {
    final data = await _api.get(ApiEndpoints.adminProfile);
    return AdminProfileModel.fromJson(data as Map<String, dynamic>);
  }

  Future<AdminProfileModel> updateProfile(
    AdminProfileUpdateRequest request,
  ) async {
    final data = await _api.put(
      ApiEndpoints.adminProfile,
      body: request.toJson(),
    );
    return AdminProfileModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> changePassword(AdminChangePasswordRequest request) async {
    await _api.put(
      ApiEndpoints.adminChangePassword,
      body: request.toJson(),
    );
  }
}
