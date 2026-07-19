import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/grade_controller.dart';
import '../../models/student_grade_summary_model.dart';

class GradeManagementScreen extends StatefulWidget {
  final int classId;
  final int teacherId;

  const GradeManagementScreen({
    super.key,
    required this.classId,
    required this.teacherId,
  });

  @override
  State<GradeManagementScreen> createState() => _GradeManagementScreenState();
}

class _GradeManagementScreenState extends State<GradeManagementScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<GradeController>().loadGradesByClass(
        widget.classId,
        widget.teacherId,
      );
    });
  }

  double? _parseScore(TextEditingController controller) {
    if (controller.text.trim().isEmpty) {
      return null;
    }

    return double.tryParse(controller.text.replaceAll(",", ".").trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Grade Management")),

      body: Consumer<GradeController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage != null) {
            return Center(
              child: Text(
                controller.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final students = controller.summaryGrades;

          if (students.isEmpty) {
            return const Center(child: Text("No grades found"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),

            itemCount: students.length,

            itemBuilder: (context, index) {
              final student = students[index];

              return Card(
                elevation: 3,

                margin: const EdgeInsets.only(bottom: 15),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),

                child: Padding(
                  padding: const EdgeInsets.all(16),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                Text(
                                  student.studentName,

                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                Text(student.studentCode),
                              ],
                            ),
                          ),

                          IconButton(
                            icon: const Icon(Icons.edit),

                            onPressed: () {
                              _showEditGradeDialog(context, student);
                            },
                          ),
                        ],
                      ),

                      const Divider(),

                      _buildGradeRow("Attendance", student.attendance),

                      _buildGradeRow("Assignment", student.assignment),

                      _buildGradeRow("Midterm", student.midterm),

                      _buildGradeRow("Final Exam", student.finalExam),

                      const Divider(),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                        children: [
                          const Text(
                            "Total",

                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Text(
                            student.total.toStringAsFixed(2),

                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showEditGradeDialog(
    BuildContext context,
    StudentGradeSummaryModel student,
  ) {
    final attendanceController = TextEditingController(
      text: student.attendance?.toString() ?? "",
    );

    final assignmentController = TextEditingController(
      text: student.assignment?.toString() ?? "",
    );

    final midtermController = TextEditingController(
      text: student.midterm?.toString() ?? "",
    );

    final finalController = TextEditingController(
      text: student.finalExam?.toString() ?? "",
    );

    showDialog(
      context: context,

      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Update Grade"),

          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildScoreField("Attendance", attendanceController),

                _buildScoreField("Assignment", assignmentController),

                _buildScoreField("Midterm", midtermController),

                _buildScoreField("Final Exam", finalController),
              ],
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },

              child: const Text("Cancel"),
            ),

            ElevatedButton(
              child: const Text("Save"),

              onPressed: () async {
                final controller = context.read<GradeController>();

                try {
                  final attendance = _parseScore(attendanceController);

                  final assignment = _parseScore(assignmentController);

                  final midterm = _parseScore(midtermController);

                  final finalExam = _parseScore(finalController);

                  if (student.attendanceId != null && attendance != null) {
                    await controller.updateGrade(
                      student.attendanceId!,
                      attendance,
                      "Draft",
                      widget.classId,
                      widget.teacherId,
                    );
                  }

                  if (student.assignmentId != null && assignment != null) {
                    await controller.updateGrade(
                      student.assignmentId!,
                      assignment,
                      "Draft",
                      widget.classId,
                      widget.teacherId,
                    );
                  }

                  if (student.midtermId != null && midterm != null) {
                    await controller.updateGrade(
                      student.midtermId!,
                      midterm,
                      "Draft",
                      widget.classId,
                      widget.teacherId,
                    );
                  }

                  if (student.finalExamId != null && finalExam != null) {
                    await controller.updateGrade(
                      student.finalExamId!,
                      finalExam,
                      "Draft",
                      widget.classId,
                      widget.teacherId,
                    );
                  }

                  await controller.loadGradesByClass(
                    widget.classId,
                    widget.teacherId,
                  );

                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Update grade successfully")),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildGradeRow(String title, double? score) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [
          Text(title),

          Text(
            _score(score),

            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,

      keyboardType: const TextInputType.numberWithOptions(decimal: true),

      decoration: InputDecoration(labelText: label),
    );
  }

  String _score(double? score) {
    if (score == null) {
      return "-";
    }

    return score.toString();
  }
}
