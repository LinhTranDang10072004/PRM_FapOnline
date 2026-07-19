import 'package:flutter/material.dart';
import '../../data/models/staff_models.dart';
import '../../data/services/staff_dashboard_service.dart';

class StaffDashboardProvider extends ChangeNotifier {
  final StaffDashboardService _service = StaffDashboardService();

  StaffDashboardModel? _dashboard;
  bool _isLoading = false;
  String? _error;

  StaffDashboardModel? get dashboard => _dashboard;
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
