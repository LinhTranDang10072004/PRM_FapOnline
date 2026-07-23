import 'package:flutter/material.dart';

import '../../data/models/admin_models.dart';
import '../../data/services/admin_dashboard_service.dart';

class AdminDashboardProvider extends ChangeNotifier {
  final AdminDashboardService _service = AdminDashboardService();

  static const List<String> terms = ['Fall', 'Spring', 'Summer'];

  AdminDashboardModel? _dashboard;
  List<String> _academicYears = [];
  bool _isLoading = false;
  bool _isFiltersLoading = false;
  String? _error;

  String? _selectedAcademicYear; // null = Tất cả
  String? _selectedTerm; // null = Tất cả

  AdminDashboardModel? get dashboard => _dashboard;
  List<String> get academicYears => _academicYears;
  bool get isLoading => _isLoading;
  bool get isFiltersLoading => _isFiltersLoading;
  String? get error => _error;
  String? get selectedAcademicYear => _selectedAcademicYear;
  String? get selectedTerm => _selectedTerm;

  Future<void> load() async {
    await Future.wait([_loadFilters(), _loadDashboard()]);
  }

  Future<void> refresh() async => _loadDashboard();

  Future<void> setAcademicYear(String? year) async {
    _selectedAcademicYear = year;
    notifyListeners();
    await _loadDashboard();
  }

  Future<void> setTerm(String? term) async {
    _selectedTerm = term;
    notifyListeners();
    await _loadDashboard();
  }

  Future<void> _loadFilters() async {
    _isFiltersLoading = true;
    notifyListeners();
    try {
      _academicYears = await _service.getAcademicYears();
    } catch (_) {
      // Giữ danh sách cũ nếu lỗi; dashboard vẫn load được.
    } finally {
      _isFiltersLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadDashboard() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _dashboard = await _service.getDashboard(
        academicYear: _selectedAcademicYear,
        term: _selectedTerm,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
