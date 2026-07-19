import 'package:flutter/material.dart';

import '../../data/models/admin_models.dart';
import '../../data/services/admin_user_service.dart';

class AdminUserProvider extends ChangeNotifier {
  final AdminUserService _service = AdminUserService();

  List<AdminUserModel> _users = [];
  bool _isLoading = false;
  String? _error;
  String _roleFilter = '';
  String _statusFilter = '';
  String _query = '';

  List<AdminUserModel> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get roleFilter => _roleFilter;
  String get statusFilter => _statusFilter;
  String get query => _query;

  Future<void> loadUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _users = await _service.getUsers(
        role: _roleFilter.isEmpty ? null : _roleFilter,
        status: _statusFilter.isEmpty ? null : _statusFilter,
        q: _query.isEmpty ? null : _query,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setRoleFilter(String role) {
    _roleFilter = role;
    loadUsers();
  }

  void setStatusFilter(String status) {
    _statusFilter = status;
    loadUsers();
  }

  void setQuery(String q) {
    _query = q;
  }

  Future<void> search() => loadUsers();

  Future<bool> createUser(AdminUserCreateRequest request) async {
    try {
      final created = await _service.createUser(request);
      _users = [created, ..._users];
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateUser(int userId, AdminUserUpdateRequest request) async {
    try {
      final updated = await _service.updateUser(userId, request);
      _users = _users.map((u) => u.userId == userId ? updated : u).toList();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteUser(int userId) async {
    try {
      await _service.deleteUser(userId);
      _users = _users.where((u) => u.userId != userId).toList();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleLock(AdminUserModel user) async {
    try {
      final updated = user.isLocked
          ? await _service.unlockUser(user.userId)
          : await _service.lockUser(user.userId);
      _users =
          _users.map((u) => u.userId == user.userId ? updated : u).toList();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
