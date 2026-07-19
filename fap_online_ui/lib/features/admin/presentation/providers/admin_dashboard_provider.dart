import 'package:flutter/material.dart';

import '../../data/models/admin_models.dart';
import '../../data/services/admin_dashboard_service.dart';

class AdminDashboardProvider extends ChangeNotifier {
  final AdminDashboardService _service = AdminDashboardService();

  AdminDashboardModel? _dashboard;
  bool _isLoading = false;
  String? _error;

  AdminDashboardModel? get dashboard => _dashboard;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _dashboard = await _service.getDashboard();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async => load();
}
