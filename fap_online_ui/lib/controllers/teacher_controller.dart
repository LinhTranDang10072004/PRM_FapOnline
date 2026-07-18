import 'package:flutter/material.dart';

import '../models/teacher_dashboard_model.dart';
import '../services/teacher_service.dart';


class TeacherController extends ChangeNotifier {


  final TeacherService teacherService = TeacherService();



  TeacherDashboard? dashboard;



  bool isLoading = false;



  String? errorMessage;




  // Load dashboard giáo viên

  Future<void> loadTeacherDashboard(int userId) async {

    try {

      isLoading = true;
      errorMessage = null;

      notifyListeners();



      dashboard =
          await teacherService.getTeacherDashboard(userId);



    } catch (e) {

      errorMessage = e.toString();

    }



    isLoading = false;

    notifyListeners();

  }



  // Reset data

  void clearData(){

    dashboard = null;

    errorMessage = null;

    notifyListeners();

  }


}