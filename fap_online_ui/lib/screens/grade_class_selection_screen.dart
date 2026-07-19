import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../controllers/teacher_class_controller.dart';
import '../models/teacher_class_model.dart';
import 'grade_management_screen.dart';

class GradeClassSelectionScreen extends StatefulWidget {
  const GradeClassSelectionScreen({super.key});

  @override
  State<GradeClassSelectionScreen> createState() =>
      _GradeClassSelectionScreenState();
}

class _GradeClassSelectionScreenState extends State<GradeClassSelectionScreen> {
  int? teacherId;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final authService = AuthService();

      final userId = await authService.getUserId();

      if (userId != null && mounted) {
        setState(() {
          teacherId = userId;
        });

        context.read<TeacherClassController>().loadTeacherClasses(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Class")),

      body: Consumer<TeacherClassController>(
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

          if (controller.classes.isEmpty) {
            return const Center(child: Text("No classes found"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),

            itemCount: controller.classes.length,

            itemBuilder: (context, index) {
              TeacherClassModel item = controller.classes[index];

              return Card(
                elevation: 3,

                margin: const EdgeInsets.only(bottom: 15),

                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.class_)),

                  title: Text(
                    item.classCode,

                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [Text(item.className), Text(item.subjectName)],
                  ),

                  trailing: const Icon(Icons.arrow_forward_ios),

                  onTap: () {
                    if (teacherId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Teacher information not found"),
                        ),
                      );

                      return;
                    }

                    Navigator.push(
                      context,

                      MaterialPageRoute(
                        builder: (_) => GradeManagementScreen(
                          classId: item.classId,

                          teacherId: teacherId!,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
