class TeacherClassModel {

  final int classId;

  final String classCode;

  final String className;

  final String subjectName;


  TeacherClassModel({

    required this.classId,

    required this.classCode,

    required this.className,

    required this.subjectName,

  });



  factory TeacherClassModel.fromJson(
      Map<String, dynamic> json
      ){

    return TeacherClassModel(

      classId: json['classId'],

      classCode: json['classCode'] ?? "",

      className: json['className'] ?? "",

      subjectName: json['subjectName'] ?? "",

    );

  }

}