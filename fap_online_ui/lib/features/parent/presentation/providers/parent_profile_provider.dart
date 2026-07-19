import 'package:flutter/material.dart';

import '../../data/models/parent_models.dart';
import '../../domain/repositories/parent_repository.dart';

class ParentProfileProvider extends ChangeNotifier {
  final ParentRepository _repository;
  bool _disposed = false;

  ParentProfileProvider(this._repository);

  bool _loading = true;
  bool get isLoading => _loading;

  bool _saving = false;
  bool get isSaving => _saving;

  String? _error;
  String? get error => _error;

  ParentProfileData? _profile;
  ParentProfileData? get profile => _profile;

  Future<void> load() async {
    _loading = true;
    _error = null;
    _safeNotify();

    try {
      _profile = await _repository.fetchProfile();
    } catch (e) {
      if (_disposed) return;
      _error = e.toString();
    }

    if (_disposed) return;
    _loading = false;
    _safeNotify();
  }

  Future<bool> saveProfile(ParentProfileData profile) async {
    _saving = true;
    _error = null;
    _safeNotify();

    var success = false;
    try {
      await _repository.updateProfile(profile);
      if (_disposed) return false;
      _profile = profile;
      success = true;
    } catch (e) {
      if (_disposed) return false;
      _error = e.toString();
    }

    if (_disposed) return false;
    _saving = false;
    _safeNotify();
    return success;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _safeNotify() {
    if (_disposed) return;
    notifyListeners();
  }
}
