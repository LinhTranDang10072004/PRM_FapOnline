

import 'package:dio/dio.dart';

import '../models/teacher_dashboard_model.dart';



class TeacherService {


  final Dio dio = Dio();



  // Lấy dashboard giáo viên

  Future<TeacherDashboard> getTeacherDashboard(
      int userId
  ) async {


    try {


      final response = await dio.get(
        "http://10.0.2.2:8080/api/teacher/dashboard/$userId",
      );



      if(response.statusCode == 200){


        return TeacherDashboard.fromJson(
          response.data
        );


      }else{


        throw Exception(
            "Không lấy được dữ liệu dashboard"
        );


      }



    } catch(e){


      throw Exception(
          "Lỗi gọi API Teacher Dashboard: $e"
      );


    }


  }


}