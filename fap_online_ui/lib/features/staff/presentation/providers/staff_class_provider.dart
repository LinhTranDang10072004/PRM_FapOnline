import 'package:flutter/material.dart';
import '../../data/models/staff_models.dart';
import '../../data/services/staff_class_service.dart';

class StaffClassProvider extends ChangeNotifier {
  final StaffClassService _service = StaffClassService();

  List<ClassModel> _classes = [];
  ClassModel? _selectedClass;
  List<ClassStudentModel> _students = [];

  // References
  List<TeacherModel> _allTeachers = [];
  List<StudentModel> _allStudents = [];

  bool _isLoading = false;
  bool _isStudentsLoading = false;
  String? _error;

  List<ClassModel> get classes => _classes;
  ClassModel? get selectedClass => _selectedClass;
  List<ClassStudentModel> get students => _students;
  bool get isLoading => _isLoading;
  bool get isStudentsLoading => _isStudentsLoading;
  String? get error => _error;

  List<TeacherModel> get allTeachers => _allTeachers;
  List<StudentModel> get allStudents => _allStudents;

  Future<void> loadReferences() async {
    try {
      _allTeachers = await _service.getTeachers();
      _allStudents = await _service.getStudents();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load references: $e');
    }
  }

  Future<void> loadClasses({int? semesterId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _classes = await _service.getAllClasses(semesterId: semesterId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadClassDetail(int classId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _selectedClass = await _service.getClassById(classId);
      _students = await _service.getClassStudents(classId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createClass(CreateClassRequest request) async {
    try {
      final created = await _service.createClass(request);
      _classes = [created, ..._classes];
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateClass(int classId, UpdateClassRequest request) async {
    try {
      final updated = await _service.updateClass(classId, request);
      _classes = _classes.map((c) => c.classId == classId ? updated : c).toList();
      if (_selectedClass?.classId == classId) _selectedClass = updated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelClass(int classId) async {
    try {
      final updated = await _service.cancelClass(classId);
      _classes = _classes.map((c) => c.classId == classId ? updated : c).toList();
      if (_selectedClass?.classId == classId) _selectedClass = updated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> assignTeacher(int classId, int teacherId) async {
    try {
      final updated = await _service.assignTeacher(classId, teacherId);
      _classes = _classes.map((c) => c.classId == classId ? updated : c).toList();
      if (_selectedClass?.classId == classId) _selectedClass = updated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> addStudentToClass(int classId, int studentId) async {
    try {
      final student = await _service.addStudentToClass(classId, studentId);
      _students = [student, ..._students];
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeStudentFromClass(int classId, int studentId) async {
    try {
      await _service.removeStudentFromClass(classId, studentId);
      _students = _students.where((s) => s.studentId != studentId).toList();
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
