import 'package:flutter/material.dart';
import '../../data/models/staff_models.dart';
import '../../data/services/staff_application_service.dart';

enum AppFilter { all, pending, approved, rejected }

class StaffApplicationProvider extends ChangeNotifier {
  final StaffApplicationService _service = StaffApplicationService();

  List<ApplicationModel> _applications = [];
  AppFilter _filter = AppFilter.pending;
  bool _isLoading = false;
  String? _error;

  List<ApplicationModel> get applications => _applications;
  AppFilter get filter => _filter;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get pendingCount =>
      _applications.where((a) => a.status == 'Pending').length;

  Future<void> loadApplications({AppFilter? filter}) async {
    if (filter != null) _filter = filter;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final statusParam = _filterToParam(_filter);
      _applications = await _service.getApplications(status: statusParam);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async => loadApplications();

  Future<String?> approveApplication(int id, {String? note}) async {
    try {
      final updated = await _service.approveApplication(id, note: note);
      _replaceApplication(updated);
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> rejectApplication(int id, {required String note}) async {
    try {
      final updated = await _service.rejectApplication(id, note: note);
      _replaceApplication(updated);
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  void _replaceApplication(ApplicationModel updated) {
    _applications = _applications
        .map((a) => a.applicationId == updated.applicationId ? updated : a)
        .toList();
  }

  void setFilter(AppFilter filter) {
    if (_filter == filter) return;
    loadApplications(filter: filter);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String? _filterToParam(AppFilter f) {
    switch (f) {
      case AppFilter.pending:
        return 'Pending';
      case AppFilter.approved:
        return 'Approved';
      case AppFilter.rejected:
        return 'Rejected';
      case AppFilter.all:
        return null;
    }
  }
}
