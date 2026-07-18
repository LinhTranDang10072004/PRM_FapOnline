import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/attendance_controller.dart';

class AttendanceScreen extends StatefulWidget {
  final int scheduleId;
  final int userId;

  const AttendanceScreen({
    super.key,
    required this.scheduleId,
    required this.userId,
  });

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      Provider.of<AttendanceController>(
        context,
        listen: false,
      ).loadAttendance(widget.scheduleId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Attendance Management")),

      body: Consumer<AttendanceController>(
        builder: (context, controller, child) {
          if (controller.isLoading && controller.students.isEmpty) {
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

          if (controller.students.isEmpty) {
            return const Center(child: Text("Không có sinh viên"));
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: controller.students.length,

                  itemBuilder: (context, index) {
                    final student = controller.students[index];
                    
                    student.status =
                        (student.status == null || student.status!.isEmpty)
                        ? "AbsentWithoutPermission"
                        : student.status;

                    student.note ??= "";

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),

                      child: Padding(
                        padding: const EdgeInsets.all(12),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(
                              student.fullName ?? "",

                              style: const TextStyle(
                                fontSize: 16,

                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text("Student Code: ${student.studentCode}"),

                            const SizedBox(height: 12),

                            DropdownButtonFormField<String>(
                              value:
                                  (student.status == "Present" ||
                                      student.status == "Late" ||
                                      student.status ==
                                          "AbsentWithPermission" ||
                                      student.status ==
                                          "AbsentWithoutPermission")
                                  ? student.status
                                  : "AbsentWithoutPermission",

                              decoration: const InputDecoration(
                                labelText: "Status",
                                border: OutlineInputBorder(),
                              ),

                              items: const [
                                DropdownMenuItem(
                                  value: "Present",
                                  child: Text("Present"),
                                ),
                                DropdownMenuItem(
                                  value: "AbsentWithoutPermission",
                                  child: Text("Absent"),
                                ),
                                DropdownMenuItem(
                                  value: "Late",
                                  child: Text("Late"),
                                ),
                              ],

                              onChanged: (value) {
                                if (value != null) {
                                  controller.updateAttendanceStatus(
                                    index,
                                    value,
                                  );
                                }
                              },
                            ),

                            const SizedBox(height: 12),

                            TextFormField(
                              initialValue: student.note,

                              decoration: const InputDecoration(
                                labelText: "Note",

                                border: OutlineInputBorder(),
                              ),

                              onChanged: (value) {
                                controller.updateAttendanceNote(index, value);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),

                child: SizedBox(
                  width: double.infinity,

                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save),

                    label: const Text("Save Attendance"),

                    onPressed: () async {
                      bool success = await controller.saveAttendance(
                        scheduleId: widget.scheduleId,

                        userId: widget.userId,
                      );

                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? "Lưu điểm danh thành công"
                                : "Lưu điểm danh thất bại",
                          ),

                          backgroundColor: success ? Colors.green : Colors.red,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
