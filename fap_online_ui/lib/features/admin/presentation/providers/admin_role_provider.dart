import 'package:flutter/material.dart';

import '../../data/models/admin_models.dart';
import '../../data/services/admin_role_service.dart';
import '../../data/services/admin_user_service.dart';

class AdminRoleProvider extends ChangeNotifier {
  final AdminRoleService _roleService = AdminRoleService();
  final AdminUserService _userService = AdminUserService();

  List<AdminRoleModel> _roles = [];
  List<AdminUserModel> _users = [];
  bool _isLoading = false;
  String? _error;

  List<AdminRoleModel> get roles => _roles;
  List<AdminUserModel> get users => _users;
  List<AdminRoleModel> get activeRoles =>
      _roles.where((r) => r.isActive).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _roleService.getRoles(),
        _userService.getUsers(),
      ]);
      _roles = results[0] as List<AdminRoleModel>;
      _users = results[1] as List<AdminUserModel>;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createRole(AdminRoleRequest request) async {
    try {
      final created = await _roleService.createRole(request);
      _roles = [created, ..._roles];
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateRole(int roleId, AdminRoleRequest request) async {
    try {
      final updated = await _roleService.updateRole(roleId, request);
      _roles = _roles.map((r) => r.roleId == roleId ? updated : r).toList();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteRole(int roleId) async {
    try {
      await _roleService.deleteRole(roleId);
      _roles = _roles.where((r) => r.roleId != roleId).toList();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> assignRole(int userId, int roleId) async {
    try {
      final updated = await _roleService.assignRole(
        AssignRoleRequest(userId: userId, roleId: roleId),
      );
      _users = _users.map((u) => u.userId == userId ? updated : u).toList();
      await _refreshRoleCounts();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> unassignRole(int userId, int roleId) async {
    try {
      final updated = await _roleService.unassignRole(
        AssignRoleRequest(userId: userId, roleId: roleId),
      );
      _users = _users.map((u) => u.userId == userId ? updated : u).toList();
      await _refreshRoleCounts();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> _refreshRoleCounts() async {
    try {
      _roles = await _roleService.getRoles();
    } catch (_) {}
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
