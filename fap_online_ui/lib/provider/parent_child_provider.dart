import 'package:flutter/material.dart';
import '../models/response/child_detail_dto.dart';
import '../models/response/weekly_timetable_dto.dart';
import '../models/response/transcript_dto.dart';
import '../services/parent_child_service.dart';

class ParentChildProvider extends ChangeNotifier {
  final ParentChildService _service = ParentChildService();

  List<ChildDetailDTO> _children = [];
  List<ChildDetailDTO> get children => _children;

  int? _selectedChildId;
  int? get selectedChildId => _selectedChildId;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  List<WeeklyTimetableDTO> _currentTimetable = [];
  List<WeeklyTimetableDTO> get currentTimetable => _currentTimetable;
  
  bool _isLoadingTimetable = false;
  bool get isLoadingTimetable => _isLoadingTimetable;

  String? _currentStartDate;
  String? _currentEndDate;

  List<TranscriptDTO> _currentTranscript = [];
  List<TranscriptDTO> get currentTranscript => _currentTranscript;

  bool _isLoadingTranscript = false;
  bool get isLoadingTranscript => _isLoadingTranscript;

  Future<void> fetchChildren() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _children = await _service.getMyChildren();
      if (_children.isNotEmpty && _selectedChildId == null) {
        _selectedChildId = _children.first.studentId;
      }
    } catch (e) {
      _error = 'Không thể tải danh sách con em';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectChild(int childId) {
    if (_selectedChildId != childId) {
      _selectedChildId = childId;
      notifyListeners();
      
      // If we are showing timetable for a child, we need to refresh it when child changes.
      // Callers should explicitly call fetchTimetable if needed, or we can auto fetch here
      // depending on architecture. For now we will just reset the local state or trigger a reload.
      if (_currentStartDate != null && _currentEndDate != null) {
        fetchTimetable(startDate: _currentStartDate!, endDate: _currentEndDate!);
      }
      if (_currentTranscript.isNotEmpty) {
        fetchTranscript();
      }
    }
  }

  Future<void> fetchTimetable({required String startDate, required String endDate}) async {
    if (_selectedChildId == null) return;
    
    _isLoadingTimetable = true;
    _currentStartDate = startDate;
    _currentEndDate = endDate;
    notifyListeners();

    try {
      _currentTimetable = await _service.getChildTimetable(_selectedChildId!, startDate: startDate, endDate: endDate);
    } catch (e) {
      print(e);
      _currentTimetable = [];
    } finally {
      _isLoadingTimetable = false;
      notifyListeners();
    }
  }

  Future<void> fetchTranscript() async {
    if (_selectedChildId == null) return;

    _isLoadingTranscript = true;
    notifyListeners();

    try {
      _currentTranscript = await _service.getChildTranscript(_selectedChildId!);
    } catch (e) {
      print(e);
      _currentTranscript = [];
    } finally {
      _isLoadingTranscript = false;
      notifyListeners();
    }
  }
}
