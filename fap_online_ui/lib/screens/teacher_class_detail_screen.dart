import 'package:flutter/material.dart';

import '../models/attendance_model.dart';
import '../models/teacher_dashboard_model.dart';
import '../models/teacher_schedule_model.dart';
import '../services/teacher_attendance_service.dart';
import '../services/teacher_class_detail_service.dart';
import '../services/teacher_schedule_service.dart';
import 'attendance_screen.dart';

class TeacherClassDetailScreen extends StatefulWidget {
  final TeacherClass teacherClass;
  final int userId;

  const TeacherClassDetailScreen({
    super.key,
    required this.teacherClass,
    required this.userId,
  });

  @override
  State<TeacherClassDetailScreen> createState() =>
      _TeacherClassDetailScreenState();
}

class _TeacherClassDetailScreenState extends State<TeacherClassDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _classService = TeacherClassDetailService();
  final _scheduleService = TeacherScheduleService();
  final _attendanceService = TeacherAttendanceService();

  bool _loadingStudents = true;
  bool _loadingHistory = true;
  String? _error;
  List<Map<String, dynamic>> _students = [];
  List<_SessionHistoryItem> _history = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    await Future.wait([_loadStudents(), _loadHistory()]);
  }

  Future<void> _loadStudents() async {
    setState(() {
      _loadingStudents = true;
      _error = null;
    });
    try {
      final students = await _classService.getClassStudents(
        widget.userId,
        widget.teacherClass.classId!,
      );
      if (!mounted) return;
      setState(() {
        _students = students;
        _loadingStudents = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loadingStudents = false;
      });
    }
  }

  Future<void> _loadHistory() async {
    setState(() => _loadingHistory = true);
    try {
      final schedules =
          await _scheduleService.getTeacherSchedule(widget.userId);
      final classSchedules = schedules
          .where((s) => s.classId == widget.teacherClass.classId)
          .toList()
        ..sort((a, b) => (b.scheduleDate ?? '').compareTo(a.scheduleDate ?? ''));

      final items = <_SessionHistoryItem>[];
      for (final schedule in classSchedules) {
        if (schedule.scheduleId == null) continue;
        List<AttendanceStudent> roster = [];
        var taken = false;
        try {
          roster = await _attendanceService.getAttendance(schedule.scheduleId!);
          taken = roster.any((s) =>
              (s.status ?? '').isNotEmpty &&
              s.status!.toLowerCase() != 'notyet' &&
              s.status!.toLowerCase() != 'none');
        } catch (_) {
          taken = false;
        }
        items.add(_SessionHistoryItem(schedule: schedule, taken: taken, roster: roster));
      }

      if (!mounted) return;
      setState(() {
        _history = items;
        _loadingHistory = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loadingHistory = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cls = widget.teacherClass;
    return Scaffold(
      appBar: AppBar(
        title: Text(cls.classCode ?? 'Chi tiết lớp'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Sinh viên'),
            Tab(text: 'Lịch sử điểm danh'),
          ],
        ),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(12),
            child: ListTile(
              leading: const Icon(Icons.class_),
              title: Text(cls.className ?? ''),
              subtitle: Text(
                '${cls.subjectName ?? ''}\n'
                'SV: ${cls.studentCount ?? _students.length} · ${cls.status ?? ''}',
              ),
              isThreeLine: true,
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildStudentsTab(),
                _buildHistoryTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsTab() {
    if (_loadingStudents) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_students.isEmpty) {
      return const Center(child: Text('Chưa có sinh viên trong lớp'));
    }
    return RefreshIndicator(
      onRefresh: _loadStudents,
      child: ListView.builder(
        itemCount: _students.length,
        itemBuilder: (_, i) {
          final s = _students[i];
          return ListTile(
            leading: CircleAvatar(
              child: Text('${i + 1}'),
            ),
            title: Text(s['fullName']?.toString() ?? ''),
            subtitle: Text(
              '${s['studentCode'] ?? ''} · ${s['status'] ?? ''}',
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistoryTab() {
    if (_loadingHistory) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_history.isEmpty) {
      return const Center(child: Text('Chưa có buổi học nào'));
    }
    return RefreshIndicator(
      onRefresh: _loadHistory,
      child: ListView.builder(
        itemCount: _history.length,
        itemBuilder: (_, i) {
          final item = _history[i];
          final s = item.schedule;
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text('${s.scheduleDate ?? ''} · ${s.startTime ?? ''}-${s.endTime ?? ''}'),
              subtitle: Text(
                '${s.roomName ?? ''}\n'
                '${item.taken ? 'Đã điểm danh (${item.roster.length} SV)' : 'Chưa điểm danh'}',
              ),
              isThreeLine: true,
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AttendanceScreen(
                      scheduleId: s.scheduleId!,
                      userId: widget.userId,
                    ),
                  ),
                );
                _loadHistory();
              },
            ),
          );
        },
      ),
    );
  }
}

class _SessionHistoryItem {
  final TeacherSchedule schedule;
  final bool taken;
  final List<AttendanceStudent> roster;

  _SessionHistoryItem({
    required this.schedule,
    required this.taken,
    required this.roster,
  });
}
