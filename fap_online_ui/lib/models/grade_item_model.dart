class GradeItemModel {

  final int studentGradeId;

  final int studentId;

  final String studentName;

  final String studentCode;

  final int classGradeComponentId;

  final String componentName;

  final double weight;

  final double? score;

  final String status;


  GradeItemModel({
    required this.studentGradeId,
    required this.studentId,
    required this.studentName,
    required this.studentCode,
    required this.classGradeComponentId,
    required this.componentName,
    required this.weight,
    this.score,
    required this.status,
  });



  factory GradeItemModel.fromJson(Map<String, dynamic> json) {

    return GradeItemModel(

      studentGradeId: json['studentGradeId'],

      studentId: json['studentId'],

      studentName: json['studentName'] ?? '',

      studentCode: json['studentCode'] ?? '',

      classGradeComponentId:
          json['classGradeComponentId'],

      componentName:
          json['componentName'] ?? '',

      weight:
          (json['weight'] ?? 0).toDouble(),

      score:
          json['score'] == null
              ? null
              : (json['score']).toDouble(),

      status:
          json['status'] ?? '',

    );

  }



  Map<String, dynamic> toJson() {

    return {

      "studentGradeId": studentGradeId,

      "studentId": studentId,

      "studentName": studentName,

      "studentCode": studentCode,

      "classGradeComponentId":
          classGradeComponentId,

      "componentName":
          componentName,

      "weight":
          weight,

      "score":
          score,

      "status":
          status,

    };

  }

}