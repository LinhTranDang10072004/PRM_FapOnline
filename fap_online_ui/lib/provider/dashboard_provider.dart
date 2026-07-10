import 'package:flutter/material.dart';
import '../models/response/dashboard_response.dart';
import '../services/dashboard_service.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardService _service = DashboardService();

  DashboardResponse? _dashboardData;
  DashboardResponse? get dashboardData => _dashboardData;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> fetchDashboard() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _dashboardData = await _service.getDashboardData();
      if (_dashboardData == null) {
        _error = 'Không thể tải dữ liệu dashboard';
      }
    } catch (e) {
      _error = 'Đã xảy ra lỗi';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
