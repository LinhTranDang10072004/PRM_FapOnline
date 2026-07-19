import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'teacher_schedule_screen.dart';
import 'attendance_screen.dart';
import 'grade_management_screen.dart';

import '../controllers/teacher_controller.dart';
import '../services/auth_service.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  final AuthService authService = AuthService();

  @override
  void initState() {
    super.initState();

    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    final userId = await authService.getUserId();

    if (userId == null) {
      return;
    }

    if (!mounted) {
      return;
    }

    Provider.of<TeacherController>(
      context,
      listen: false,
    ).loadTeacherDashboard(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Teacher Dashboard"),

        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),

            onPressed: _loadDashboard,
          ),
        ],
      ),

      body: Consumer<TeacherController>(
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

          final dashboard = controller.dashboard;

          if (dashboard == null) {
            return const Center(child: Text("Không có dữ liệu"));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  "Xin chào: ${dashboard.teacherName}",

                  style: Theme.of(context).textTheme.headlineSmall,
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    _buildCard(
                      "Lớp phụ trách",
                      dashboard.totalClasses.toString(),
                      Icons.class_,
                    ),

                    _buildCard(
                      "Lịch hôm nay",
                      dashboard.todaySchedules.toString(),
                      Icons.schedule,
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                const Text(
                  "Today's Classes",

                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                ListView.builder(
                  shrinkWrap: true,

                  physics: const NeverScrollableScrollPhysics(),

                  itemCount: dashboard.todaySchedule.length,

                  itemBuilder: (context, index) {
                    final item = dashboard.todaySchedule[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 15),

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

                            const SizedBox(height: 8),

                            Text("${item.classCode} - ${item.className}"),

                            Text("${item.startTime} - ${item.endTime}"),

                            Text(item.roomName ?? ""),

                            const SizedBox(height: 15),

                            ElevatedButton.icon(
                              icon: const Icon(Icons.fact_check),

                              label: const Text("Take Attendance"),

                              onPressed: () async {
                                final userId = await authService.getUserId();

                                if (!mounted ||
                                    userId == null ||
                                    item.scheduleId == null) {
                                  return;
                                }

                                Navigator.push(
                                  context,

                                  MaterialPageRoute(
                                    builder: (_) => AttendanceScreen(
                                      scheduleId: item.scheduleId!,

                                      userId: userId,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 30),

                const Text(
                  "Quick Actions",

                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 15),

                _buildMenuButton(
                  icon: Icons.calendar_month,

                  title: "Teaching Schedule",

                  onTap: () {
                    Navigator.push(
                      context,

                      MaterialPageRoute(
                        builder: (_) => const TeacherScheduleScreen(),
                      ),
                    );
                  },
                ),

                _buildMenuButton(
                  icon: Icons.grade,

                  title: "Grade Management",

                  onTap: () {
                    _showClassSelector(
                      context,
                      dashboard.classes,
                      dashboard.teacherId,
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showClassSelector(BuildContext context, List classes, int teacherId) {
    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text("Select Class"),

          content: SizedBox(
            width: double.maxFinite,

            child: ListView.builder(
              shrinkWrap: true,

              itemCount: classes.length,

              itemBuilder: (context, index) {
                final item = classes[index];

                return ListTile(
                  leading: const Icon(Icons.class_),

                  title: Text("${item.classCode} - ${item.className}"),

                  subtitle: Text(item.subjectName ?? ""),

                  onTap: () {
                    Navigator.pop(context);

                    Navigator.push(
                      context,

                      MaterialPageRoute(
                        builder: (_) => GradeManagementScreen(
                          classId: item.classId,
                          teacherId: teacherId,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildCard(String title, String value, IconData icon) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.42,

      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Column(
            children: [
              Icon(icon),

              const SizedBox(height: 8),

              Text(
                value,

                style: const TextStyle(
                  fontSize: 24,

                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(title),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton({
    required IconData icon,

    required String title,

    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),

      child: ListTile(
        leading: Icon(icon),

        title: Text(title),

        trailing: const Icon(Icons.arrow_forward_ios),

        onTap: onTap,
      ),
    );
  }
}
