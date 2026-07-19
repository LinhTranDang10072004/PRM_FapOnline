import 'package:flutter/material.dart';
import '../../data/models/staff_models.dart';
import '../../data/services/staff_timeslot_service.dart';

class StaffTimeSlotProvider extends ChangeNotifier {
  final StaffTimeSlotService _service = StaffTimeSlotService();

  List<TimeSlotModel> _timeSlots = [];
  bool _isLoading = false;
  String? _error;

  List<TimeSlotModel> get timeSlots => _timeSlots;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadTimeSlots() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _timeSlots = await _service.getTimeSlots();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createTimeSlot(TimeSlotRequest request) async {
    try {
      final created = await _service.createTimeSlot(request);
      _timeSlots = [created, ..._timeSlots];
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTimeSlot(int timeSlotId, TimeSlotRequest request) async {
    try {
      final updated = await _service.updateTimeSlot(timeSlotId, request);
      _timeSlots = _timeSlots
          .map((s) => s.timeSlotId == timeSlotId ? updated : s)
          .toList();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTimeSlot(int timeSlotId) async {
    try {
      await _service.deleteTimeSlot(timeSlotId);
      _timeSlots =
          _timeSlots.where((s) => s.timeSlotId != timeSlotId).toList();
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
