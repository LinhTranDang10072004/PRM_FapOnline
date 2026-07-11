import 'package:flutter/material.dart';
import '../models/response/transcript_dto.dart';
import '../services/transcript_service.dart';

class TranscriptProvider extends ChangeNotifier {
  final TranscriptService _service = TranscriptService();

  List<TranscriptDTO> _transcriptList = [];
  List<TranscriptDTO> get transcriptList => _transcriptList;

  double? _averageScore;
  double? get averageScore => _averageScore;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // Semester filter
  int? _selectedSemesterId;
  int? get selectedSemesterId => _selectedSemesterId;

  Future<void> fetchStudentTranscript(int studentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _transcriptList = await _service.getStudentTranscript(studentId);
    } catch (e) {
      _error = 'Lỗi khi tải bảng điểm: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRecentGrades(int studentId, {int limit = 5}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _transcriptList = await _service.getRecentGrades(studentId, limit: limit);
    } catch (e) {
      _error = 'Lỗi khi tải điểm gần đây: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchSemesterTranscript(int studentId, int semesterId) async {
    _isLoading = true;
    _error = null;
    _selectedSemesterId = semesterId;
    notifyListeners();

    try {
      _transcriptList = await _service.getSemesterTranscript(
        studentId,
        semesterId,
      );
    } catch (e) {
      _error = 'Lỗi khi tải bảng điểm học kỳ: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAverageScore(int studentId) async {
    try {
      _averageScore = await _service.getAverageScore(studentId);
      notifyListeners();
    } catch (e) {
      _error = 'Lỗi khi tải điểm trung bình: $e';
      notifyListeners();
    }
  }

  void setSemesterFilter(int? semesterId) {
    _selectedSemesterId = semesterId;
    notifyListeners();
  }

  void clearTranscript() {
    _transcriptList = [];
    _averageScore = null;
    _selectedSemesterId = null;
    _error = null;
    notifyListeners();
  }
}
