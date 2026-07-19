class StudentGradeSummaryModel {

  int? attendanceId;

  int? assignmentId;

  int? midtermId;

  int? finalExamId;


  final int studentId;

  final String studentName;

  final String studentCode;


  double? attendance;

  double? assignment;

  double? midterm;

  double? finalExam;



  StudentGradeSummaryModel({

    required this.studentId,

    required this.studentName,

    required this.studentCode,


    this.attendanceId,

    this.assignmentId,

    this.midtermId,

    this.finalExamId,


    this.attendance,

    this.assignment,

    this.midterm,

    this.finalExam,

  });





  double get total {


    return

        ((attendance ?? 0) * 0.1) +

        ((assignment ?? 0) * 0.2) +

        ((midterm ?? 0) * 0.3) +

        ((finalExam ?? 0) * 0.4);


  }

}