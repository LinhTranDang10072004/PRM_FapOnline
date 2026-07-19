import 'package:flutter/material.dart';

import '../models/teacher_class_model.dart';
import '../services/teacher_class_service.dart';

class TeacherClassController extends ChangeNotifier {
  final TeacherClassService service = TeacherClassService();

  List<TeacherClassModel> _classes = [];

  List<TeacherClassModel> get classes => _classes;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  Future<void> loadTeacherClasses(int userId) async {
    try {
      _isLoading = true;

      _errorMessage = null;

      notifyListeners();

      _classes = await service.getTeacherClasses(userId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }
}
