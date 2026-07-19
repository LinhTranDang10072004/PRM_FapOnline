import 'package:flutter/material.dart';
import '../models/student_grade_summary_model.dart';
import '../models/grade_item_model.dart';
import '../services/grade_service.dart';

class GradeController extends ChangeNotifier {
  final GradeService gradeService = GradeService();

  // Danh sách điểm
  List<GradeItemModel> _grades = [];

  List<GradeItemModel> get grades => _grades;

  // Loading
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  // Error
  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  // ==========================================
  // GET GRADE BY CLASS
  // Teacher xem điểm của lớp
  // ==========================================

  Future<void> loadGradesByClass(int classId,int teacherId,) async {
    try {
      _isLoading = true;

      _errorMessage = null;

      notifyListeners();

      _grades = await gradeService.getGradesByClass(
    classId,
    teacherId,
);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  // ==========================================
  // UPDATE GRADE
  // Sửa điểm
  // ==========================================

  Future<bool> updateGrade(
    int id,
    double score,
    String status,
    int classId,
    int teacherId,
  ) async {
    try {
      await gradeService.updateGrade(id, score, status);

      await loadGradesByClass(classId,teacherId,);

      return true;
    } catch (e) {
      _errorMessage = e.toString();

      notifyListeners();

      return false;
    }
  }

  // ==========================================
  // CREATE GRADE
  // Nhập điểm mới
  // ==========================================

  Future<bool> createGrade(Map<String, dynamic> data) async {
    try {
      await gradeService.createGrade(data);

      return true;
    } catch (e) {
      _errorMessage = e.toString();

      notifyListeners();

      return false;
    }
  }

  // ==========================================
  // DELETE GRADE
  // ==========================================

  Future<bool> deleteGrade(int id) async {
    try {
      await gradeService.deleteGrade(id);

      _grades.removeWhere((grade) => grade.studentGradeId == id);

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();

      notifyListeners();

      return false;
    }
  }

  // ==========================================
  // CLEAR DATA
  // ==========================================

  void clearGrades() {
    _grades = [];

    notifyListeners();
  }
  // ==========================================
  // SUMMARY GRADE
  // Gom điểm theo từng sinh viên
  // ==========================================

  List<StudentGradeSummaryModel> get summaryGrades {
    Map<int, StudentGradeSummaryModel> map = {};

    for (var grade in _grades) {
      if (!map.containsKey(grade.studentId)) {
        map[grade.studentId] = StudentGradeSummaryModel(
          studentId: grade.studentId,

          studentName: grade.studentName,

          studentCode: grade.studentCode,
        );
      }

      final student = map[grade.studentId]!;

      switch (grade.componentName) {
        case "Attendance":
          student.attendance = grade.score;

          student.attendanceId = grade.studentGradeId;

          break;

        case "Assignment":
          student.assignment = grade.score;

          student.assignmentId = grade.studentGradeId;

          break;

        case "Midterm":
          student.midterm = grade.score;

          student.midtermId = grade.studentGradeId;

          break;

        case "Final Exam":
          student.finalExam = grade.score;

          student.finalExamId = grade.studentGradeId;

          break;
      }
    }

    return map.values.toList();
  }
}
