import 'package:flutter/material.dart';

import '../../../../core/utils/async_value.dart';
import '../../data/models/parent_models.dart';
import '../../domain/repositories/parent_repository.dart';
import '../../../../core/utils/preferences.dart';

class ParentDashboardProvider extends ChangeNotifier {
  final ParentRepository _repository;
  bool _disposed = false;

  ParentDashboardProvider(this._repository);

  AsyncValue<ParentDashboardData> _dashboardState = const AsyncValue.loading();
  AsyncValue<ParentDashboardData> get dashboardState => _dashboardState;

  String? _displayName;
  String? get displayName => _displayName;

  AttendanceSummary _attendanceSummary = const AttendanceSummary.empty();
  AttendanceSummary get attendanceSummary => _attendanceSummary;

  Map<int, AttendanceSummary> _attendanceByChild = <int, AttendanceSummary>{};
  Map<int, AttendanceSummary> get attendanceByChild => _attendanceByChild;
  bool _attendanceLoading = false;
  bool get attendanceLoading => _attendanceLoading;

  Future<void> load() async {
    _dashboardState = const AsyncValue.loading();
    _safeNotify();

    try {
      final dashboard = await _repository.fetchDashboard();
      if (_disposed) return;
      _displayName = await PreferencesHelper.getFullName();
      _dashboardState = AsyncValue.data(dashboard);
    } catch (e, st) {
      if (_disposed) return;
      _dashboardState = AsyncValue.error(e, st);
    }

    if (_disposed) return;
    _safeNotify();

    _loadAttendanceSummaries();
  }

  Future<void> refresh() => load();

  Future<void> _loadAttendanceSummaries() async {
    if (_disposed) return;
    if (_dashboardState is! AsyncData<ParentDashboardData>) return;
    final dashboard = (_dashboardState as AsyncData<ParentDashboardData>).value;
    if (_attendanceLoading) return;

    _attendanceLoading = true;
    _safeNotify();

    try {
      final childIds = dashboard.children
          .map((child) => child.studentId)
          .whereType<int>()
          .toList(growable: false);

      if (childIds.isEmpty) {
        _attendanceByChild = <int, AttendanceSummary>{};
        _attendanceSummary = const AttendanceSummary.empty();
        return;
      }

      final attendanceEntries = await Future.wait(
        childIds.map((childId) async {
          final summary = await _repository.fetchAttendanceSummaryForChild(childId);
          return MapEntry(childId, summary);
        }),
      );

      if (_disposed) return;
      _attendanceByChild = Map<int, AttendanceSummary>.fromEntries(attendanceEntries);
      _attendanceSummary = _attendanceByChild.values.fold(
        const AttendanceSummary.empty(),
        (previous, next) => previous.combine(next),
      );
    } catch (e, st) {
      if (_disposed) return;
      // We don't overwrite the main dashboard state here, just maybe set an attendance error state
    }

    if (_disposed) return;
    _attendanceLoading = false;
    _safeNotify();
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
