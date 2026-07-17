import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../models/response/profile_dto.dart';
import '../services/profile_service.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileService _service = ProfileService();

  // Expose service for direct access if needed
  ProfileService get profileService => _service;

  ProfileDTO? _profile;
  ProfileDTO? get profile => _profile;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> fetchProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _profile = await _service.getProfile();
      if (_profile == null) {
        _error = 'Không thể tải thông tin cá nhân';
      }
    } catch (e) {
      _error = 'Đã xảy ra lỗi';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile(ProfileDTO profile) async {
    try {
      final success = await _service.updateProfile(profile);
      if (success) {
        _profile = profile;
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<String?> uploadAvatar(Uint8List bytes, String filename) async {
    try {
      final avatarUrl = await _service.uploadAvatar(bytes, filename);
      return avatarUrl;
    } catch (e) {
      _error = 'Lỗi tải ảnh: $e';
      notifyListeners();
      return null;
    }
  }

  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    _error = null;
    notifyListeners();

    final success = await _service.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
    if (!success) {
      _error =
          'Không thể đổi mật khẩu. Vui lòng kiểm tra lại mật khẩu hiện tại.';
      notifyListeners();
    }
    return success;
  }
}
