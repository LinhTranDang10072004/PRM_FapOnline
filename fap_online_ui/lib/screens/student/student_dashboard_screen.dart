import 'package:flutter/material.dart';
import 'timetable_screen.dart';
import 'attendance_screen.dart';
import 'mark_report_screen.dart';
import 'applications_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({Key? key}) : super(key: key);

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  Widget _buildDashboardItem(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildDashboardItem('Thời khóa biểu', Icons.calendar_today, Colors.blue, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const TimetableScreen()));
            }),
            _buildDashboardItem('Điểm danh', Icons.check_circle_outline, Colors.green, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceScreen()));
            }),
            _buildDashboardItem('Mark Report', Icons.grade, Colors.orange, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const MarkReportScreen()));
            }),
            _buildDashboardItem('Đơn từ', Icons.description, Colors.purple, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ApplicationsScreen()));
            }),
            _buildDashboardItem('Thông báo', Icons.notifications, Colors.amber, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
            }),
          ],
        ),
      ),
    );
  }
}
