import 'package:dio/dio.dart';

import '../models/grade_item_model.dart';


class GradeService {


  final Dio dio = Dio(
    BaseOptions(
      baseUrl: "http://10.0.2.2:8080",
    ),
  );



  // ==========================================
  // GET GRADES BY CLASS
  // ==========================================

  Future<List<GradeItemModel>> getGradesByClass(
      int classId,
      int teacherId,
      ) async {


    final response = await dio.get(
  "/api/student-grades/class/$classId/$teacherId",
);


    List data = response.data;


    return data
        .map(
          (e) => GradeItemModel.fromJson(e),
        )
        .toList();

  }




  // ==========================================
  // UPDATE GRADE
  // ==========================================

  Future<void> updateGrade(
      int id,
      double score,
      String status
      ) async {


    await dio.put(
      "/api/student-grades/$id",

      data: {

        "score": score,

        "status": status,

      },

    );

  }





  // ==========================================
  // CREATE GRADE
  // ==========================================

  Future<GradeItemModel> createGrade(
      Map<String, dynamic> data
      ) async {


    final response = await dio.post(
      "/api/student-grades",
      data: data,
    );


    return GradeItemModel.fromJson(
      response.data,
    );

  }





  // ==========================================
  // DELETE GRADE
  // ==========================================

  Future<void> deleteGrade(
      int id
      ) async {


    await dio.delete(
      "/api/student-grades/$id",
    );

  }


}