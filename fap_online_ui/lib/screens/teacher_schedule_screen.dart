import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/teacher_schedule_controller.dart';
import '../services/auth_service.dart';

class TeacherScheduleScreen extends StatefulWidget {
  const TeacherScheduleScreen({super.key});

  @override
  State<TeacherScheduleScreen> createState() => _TeacherScheduleScreenState();
}

class _TeacherScheduleScreenState extends State<TeacherScheduleScreen> {
  final AuthService authService = AuthService();

  int? userId;

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    userId = await authService.getUserId();

    if (userId == null) return;

    if (!mounted) return;

    Provider.of<TeacherScheduleController>(
      context,
      listen: false,
    ).loadTeacherSchedule(userId!);
  }

  Future<void> _refresh() async {
    if (userId == null) return;

    await Provider.of<TeacherScheduleController>(
      context,
      listen: false,
    ).refresh(userId!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Teaching Schedule")),
      body: Consumer<TeacherScheduleController>(
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

          if (controller.schedules.isEmpty) {
            return const Center(child: Text("No teaching schedule"));
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.schedules.length,
              itemBuilder: (context, index) {
                final item = controller.schedules[index];

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.subjectName ?? "",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Row(
                          children: [
                            const Icon(Icons.class_),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "${item.classCode} - ${item.className}",
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        Row(
                          children: [
                            const Icon(Icons.calendar_today),
                            const SizedBox(width: 8),
                            Text(item.scheduleDate ?? ""),
                          ],
                        ),

                        const SizedBox(height: 8),

                        Row(
                          children: [
                            const Icon(Icons.access_time),
                            const SizedBox(width: 8),
                            Text("${item.startTime} - ${item.endTime}"),
                          ],
                        ),

                        const SizedBox(height: 8),

                        Row(
                          children: [
                            const Icon(Icons.meeting_room),
                            const SizedBox(width: 8),
                            Text(item.roomName ?? ""),
                          ],
                        ),

                     
                        
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
