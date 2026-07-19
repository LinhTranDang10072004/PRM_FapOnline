import 'package:flutter/material.dart';
import '../../data/models/staff_models.dart';
import '../../data/services/staff_schedule_service.dart';

class StaffScheduleProvider extends ChangeNotifier {
  final StaffScheduleService _service = StaffScheduleService();

  List<ScheduleModel> _schedules = [];
  bool _isLoading = false;
  String? _error;

  // Filters
  int? _filterClassId;
  String? _filterDate; // yyyy-MM-dd

  List<ScheduleModel> get schedules => _schedules;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int? get filterClassId => _filterClassId;
  String? get filterDate => _filterDate;

  Future<void> loadSchedules({int? classId, String? date}) async {
    _filterClassId = classId;
    _filterDate = date;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _schedules = await _service.getSchedules(classId: classId, date: date);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async =>
      loadSchedules(classId: _filterClassId, date: _filterDate);

  Future<bool> createSchedule(StaffCreateScheduleRequest request) async {
    try {
      final created = await _service.createSchedule(request);
      _schedules = [created, ..._schedules];
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateSchedule(
      int scheduleId, StaffUpdateScheduleRequest request) async {
    try {
      final updated = await _service.updateSchedule(scheduleId, request);
      _schedules = _schedules
          .map((s) => s.scheduleId == scheduleId ? updated : s)
          .toList();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteSchedule(int scheduleId) async {
    try {
      await _service.deleteSchedule(scheduleId);
      _schedules = _schedules.where((s) => s.scheduleId != scheduleId).toList();
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
