import 'package:flutter/material.dart';

import '../../models/dashboard_summary_model.dart';
import '../../services/auth_service.dart';
import '../../services/student_api_service.dart';
import 'timetable_screen.dart';
import 'attendance_screen.dart';
import 'mark_report_screen.dart';
import 'applications_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'transcript_screen.dart';
import 'my_classes_screen.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  final AuthService _authService = AuthService();
  final StudentApiService _studentApi = StudentApiService();

  DashboardSummaryModel? _summary;
  bool _loadingSummary = true;
  String? _summaryError;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    setState(() {
      _loadingSummary = true;
      _summaryError = null;
    });
    try {
      final token = await _authService.getToken();
      if (token == null || token.isEmpty) {
        setState(() {
          _summaryError = 'Chưa đăng nhập';
          _loadingSummary = false;
        });
        return;
      }
      final summary = await _studentApi.getDashboardSummary(token);
      if (!mounted) return;
      setState(() {
        _summary = summary;
        _loadingSummary = false;
        if (summary == null) {
          _summaryError = 'Không tải được tổng quan';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _summaryError = e.toString();
        _loadingSummary = false;
      });
    }
  }

  Widget _buildDashboardItem(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
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
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  Widget _buildSummaryCard() {
    if (_loadingSummary) {
      return const Card(
        margin: EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_summaryError != null) {
      return Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: ListTile(
          leading: const Icon(Icons.error_outline, color: Colors.red),
          title: Text(_summaryError!),
          trailing: IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSummary,
          ),
        ),
      );
    }

    final summary = _summary!;
    final hasNext = (summary.nextClassSubject ?? '').isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.dashboard_customize, color: Colors.indigo),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Tổng quan hôm nay',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
                IconButton(
                  tooltip: 'Làm mới',
                  onPressed: _loadSummary,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                child: Icon(Icons.notifications_active),
              ),
              title: Text('${summary.unreadNotifications} thông báo chưa đọc'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationsScreen(),
                  ),
                );
              },
            ),
            const Divider(),
            if (hasNext) ...[
              const Text(
                'Buổi học sắp tới',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                summary.nextClassSubject!,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text('Giờ: ${summary.nextClassTime ?? '-'}'),
              Text('Phòng: ${summary.nextClassRoom ?? '-'}'),
            ] else
              const Text('Không có buổi học sắp tới trong 14 ngày tới'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Đăng xuất',
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadSummary,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSummaryCard(),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildDashboardItem(
                  'Lớp của tôi',
                  Icons.class_,
                  Colors.deepPurple,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MyClassesScreen(),
                      ),
                    );
                  },
                ),
                _buildDashboardItem(
                  'Thời khóa biểu',
                  Icons.calendar_today,
                  Colors.blue,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TimetableScreen(),
                      ),
                    );
                  },
                ),
                _buildDashboardItem(
                  'Điểm danh',
                  Icons.check_circle_outline,
                  Colors.green,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AttendanceScreen(),
                      ),
                    );
                  },
                ),
                _buildDashboardItem(
                  'Mark Report',
                  Icons.grade,
                  Colors.orange,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MarkReportScreen(),
                      ),
                    );
                  },
                ),
                _buildDashboardItem(
                  'Transcript',
                  Icons.school,
                  Colors.teal,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TranscriptScreen(),
                      ),
                    );
                  },
                ),
                _buildDashboardItem(
                  'Đơn từ',
                  Icons.description,
                  Colors.purple,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ApplicationsScreen(),
                      ),
                    );
                  },
                ),
                _buildDashboardItem(
                  'Thông báo',
                  Icons.notifications,
                  Colors.amber,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotificationsScreen(),
                      ),
                    );
                  },
                ),
                _buildDashboardItem(
                  'Hồ sơ',
                  Icons.person,
                  Colors.indigo,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
