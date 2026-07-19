import 'package:flutter/material.dart';

import '../../data/models/admin_models.dart';
import '../../data/services/admin_profile_service.dart';

class AdminProfileProvider extends ChangeNotifier {
  final AdminProfileService _service = AdminProfileService();

  AdminProfileModel? _profile;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;

  AdminProfileModel? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _profile = await _service.getProfile();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile(AdminProfileUpdateRequest request) async {
    _isSaving = true;
    _error = null;
    notifyListeners();
    try {
      _profile = await _service.updateProfile(request);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> changePassword(AdminChangePasswordRequest request) async {
    _isSaving = true;
    _error = null;
    notifyListeners();
    try {
      await _service.changePassword(request);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
