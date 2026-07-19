import 'package:flutter/material.dart';
import '../models/response/student_fee_dto.dart';
import '../services/student_fee_service.dart';

class StudentFeeProvider extends ChangeNotifier {
  final StudentFeeService _service = StudentFeeService();

  List<StudentFeeDTO> _feesList = [];
  List<StudentFeeDTO> get feesList => _feesList;

  List<StudentFeeDTO> _unpaidFees = [];
  List<StudentFeeDTO> get unpaidFees => _unpaidFees;

  double? _totalUnpaidAmount;
  double? get totalUnpaidAmount => _totalUnpaidAmount;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // Semester filter
  int? _selectedSemesterId;
  int? get selectedSemesterId => _selectedSemesterId;

  Future<void> fetchStudentFees(int studentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _feesList = await _service.getStudentFees(studentId);
    } catch (e) {
      _error = 'Lỗi khi tải học phí: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUnpaidFees(int studentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _unpaidFees = await _service.getUnpaidFees(studentId);
    } catch (e) {
      _error = 'Lỗi khi tải học phí chưa thanh toán: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchOverdueFees(int studentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _unpaidFees = await _service.getOverdueFees(studentId);
    } catch (e) {
      _error = 'Lỗi khi tải học phí quá hạn: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchFeesBySemester(int studentId, int semesterId) async {
    _isLoading = true;
    _error = null;
    _selectedSemesterId = semesterId;
    notifyListeners();

    try {
      _feesList = await _service.getFeesBySemester(studentId, semesterId);
    } catch (e) {
      _error = 'Lỗi khi tải học phí học kỳ: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTotalUnpaidAmount(int studentId) async {
    try {
      _totalUnpaidAmount = await _service.getTotalUnpaidAmount(studentId);
      notifyListeners();
    } catch (e) {
      _error = 'Lỗi khi tính tổng học phí: $e';
      notifyListeners();
    }
  }

  void setSemesterFilter(int? semesterId) {
    _selectedSemesterId = semesterId;
    notifyListeners();
  }

  void clearFees() {
    _feesList = [];
    _unpaidFees = [];
    _totalUnpaidAmount = null;
    _selectedSemesterId = null;
    _error = null;
    notifyListeners();
  }
}
