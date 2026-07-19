import '../../../../services/api_service.dart';
import '../../../../config/api_endpoints.dart';
import '../models/admin_models.dart';

class AdminUserService {
  final ApiService _api = ApiService();

  Future<List<AdminUserModel>> getUsers({
    String? role,
    String? status,
    String? q,
  }) async {
    final params = <String, String>{};
    if (role != null && role.isNotEmpty) params['role'] = role;
    if (status != null && status.isNotEmpty) params['status'] = status;
    if (q != null && q.isNotEmpty) params['q'] = q;

    final query = params.isEmpty
        ? ''
        : '?${params.entries.map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}').join('&')}';

    final data = await _api.get('${ApiEndpoints.adminUsers}$query');
    return (data as List<dynamic>)
        .map((e) => AdminUserModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AdminUserModel> createUser(AdminUserCreateRequest request) async {
    final data = await _api.post(ApiEndpoints.adminUsers, request.toJson());
    return AdminUserModel.fromJson(data as Map<String, dynamic>);
  }

  Future<AdminUserModel> updateUser(
    int userId,
    AdminUserUpdateRequest request,
  ) async {
    final data = await _api.put(
      ApiEndpoints.adminUserById(userId),
      body: request.toJson(),
    );
    return AdminUserModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deleteUser(int userId) async {
    await _api.delete(ApiEndpoints.adminUserById(userId));
  }

  Future<AdminUserModel> lockUser(int userId) async {
    final data = await _api.put(ApiEndpoints.adminUserLock(userId));
    return AdminUserModel.fromJson(data as Map<String, dynamic>);
  }

  Future<AdminUserModel> unlockUser(int userId) async {
    final data = await _api.put(ApiEndpoints.adminUserUnlock(userId));
    return AdminUserModel.fromJson(data as Map<String, dynamic>);
  }
}
