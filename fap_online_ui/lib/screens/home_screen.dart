import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'login_screen.dart';
import 'student/student_dashboard_screen.dart';
import 'student/timetable_screen.dart';
import 'student/attendance_screen.dart';
import 'student/mark_report_screen.dart';
import 'student/transcript_screen.dart';
import 'student/applications_screen.dart';
import 'student/profile_screen.dart';
import 'student/notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  String _fullName = '';
  String _username = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final fullName = await _authService.getFullName() ?? '';
    final username = await _authService.getUsername() ?? '';
    if (!mounted) return;
    setState(() {
      _fullName = fullName;
      _username = username;
      _loading = false;
    });
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, Widget screen) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context); // Close drawer
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FAP Online'),
        actions: [
          IconButton(
            tooltip: 'Đăng xuất',
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(_fullName.isNotEmpty ? _fullName : _username),
              accountEmail: Text('@$_username'),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40),
              ),
            ),
            _buildDrawerItem(Icons.dashboard, 'Dashboard', const StudentDashboardScreen()),
            _buildDrawerItem(Icons.calendar_today, 'Thời khóa biểu', const TimetableScreen()),
            _buildDrawerItem(Icons.check_circle_outline, 'Điểm danh', const AttendanceScreen()),
            _buildDrawerItem(Icons.grade, 'Báo cáo điểm', const MarkReportScreen()),
            _buildDrawerItem(Icons.article, 'Bảng điểm', const TranscriptScreen()),
            _buildDrawerItem(Icons.description, 'Đơn từ', const ApplicationsScreen()),
            _buildDrawerItem(Icons.notifications, 'Thông báo', const NotificationsScreen()),
            _buildDrawerItem(Icons.person, 'Trang cá nhân', const ProfileScreen()),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.school, size: 64, color: Colors.blue),
                    const SizedBox(height: 16),
                    Text(
                      'Xin chào, ${_fullName.isNotEmpty ? _fullName : _username}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Chào mừng bạn đến với FAP Online',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
