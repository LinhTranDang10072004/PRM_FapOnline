import 'package:flutter/material.dart';

import '../../data/models/parent_models.dart';
import '../../domain/repositories/parent_repository.dart';

class ChildDetailProvider extends ChangeNotifier {
  final ParentRepository _repository;
  bool _disposed = false;

  ChildDetailProvider(this._repository);

  bool _loading = true;
  bool get isLoading => _loading;

  String? _error;
  String? get error => _error;

  ParentChildDetailData? _detail;
  ParentChildDetailData? get detail => _detail;

  List<ParentWeeklyTimetableItem> _timetable = <ParentWeeklyTimetableItem>[];
  List<ParentWeeklyTimetableItem> get timetable => _timetable;

  List<ParentAttendanceRecord> _attendance = <ParentAttendanceRecord>[];
  List<ParentAttendanceRecord> get attendance => _attendance;

  List<ParentGradeRecord> _grades = <ParentGradeRecord>[];
  List<ParentGradeRecord> get grades => _grades;

  List<ParentTranscriptRecord> _transcript = <ParentTranscriptRecord>[];
  List<ParentTranscriptRecord> get transcript => _transcript;

  List<ParentFeeRecord> _fees = <ParentFeeRecord>[];
  List<ParentFeeRecord> get fees => _fees;

  Future<void> load(int studentId) async {
    _loading = true;
    _error = null;
    _safeNotify();

    try {
      final results = await Future.wait<dynamic>([
        _repository.fetchChildDetail(studentId),
        _repository.fetchChildTimetable(studentId),
        _repository.fetchChildAttendance(studentId),
        _repository.fetchChildGrades(studentId),
        _repository.fetchChildTranscript(studentId),
        _repository.fetchChildFees(studentId),
      ]);

      if (_disposed) return;
      _detail = results[0] as ParentChildDetailData;
      _timetable = results[1] as List<ParentWeeklyTimetableItem>;
      _attendance = results[2] as List<ParentAttendanceRecord>;
      _grades = results[3] as List<ParentGradeRecord>;
      _transcript = results[4] as List<ParentTranscriptRecord>;
      _fees = results[5] as List<ParentFeeRecord>;
    } catch (e) {
      if (_disposed) return;
      _error = e.toString();
    }

    if (_disposed) return;
    _loading = false;
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
