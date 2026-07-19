import '../../../../services/api_service.dart';
import '../../../../config/api_endpoints.dart';
import '../models/admin_models.dart';

class AdminRoleService {
  final ApiService _api = ApiService();

  Future<List<AdminRoleModel>> getRoles() async {
    final data = await _api.get(ApiEndpoints.adminRoles);
    return (data as List<dynamic>)
        .map((e) => AdminRoleModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AdminRoleModel> createRole(AdminRoleRequest request) async {
    final data = await _api.post(ApiEndpoints.adminRoles, request.toJson());
    return AdminRoleModel.fromJson(data as Map<String, dynamic>);
  }

  Future<AdminRoleModel> updateRole(int roleId, AdminRoleRequest request) async {
    final data = await _api.put(
      ApiEndpoints.adminRoleById(roleId),
      body: request.toJson(),
    );
    return AdminRoleModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deleteRole(int roleId) async {
    await _api.delete(ApiEndpoints.adminRoleById(roleId));
  }

  Future<AdminUserModel> assignRole(AssignRoleRequest request) async {
    final data =
        await _api.post(ApiEndpoints.adminRoleAssign, request.toJson());
    return AdminUserModel.fromJson(data as Map<String, dynamic>);
  }

  Future<AdminUserModel> unassignRole(AssignRoleRequest request) async {
    final data =
        await _api.post(ApiEndpoints.adminRoleUnassign, request.toJson());
    return AdminUserModel.fromJson(data as Map<String, dynamic>);
  }
}
