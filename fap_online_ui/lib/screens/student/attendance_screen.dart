import 'package:flutter/material.dart';

import '../../models/attendance_model.dart';
import '../../services/auth_service.dart';
import '../../services/student_api_service.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final StudentApiService _studentApiService = StudentApiService();
  final AuthService _authService = AuthService();
  late Future<List<AttendanceModel>> _attendanceFuture;
  int _selectedSemesterIndex = 0;

  static const _navy = Color(0xFF1B2A4A);
  static const _orange = Color(0xFFF57C00);

  @override
  void initState() {
    super.initState();
    _attendanceFuture = _fetchAttendance();
  }

  Future<List<AttendanceModel>> _fetchAttendance() async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Không tìm thấy token đăng nhập. Vui lòng đăng nhập lại.');
    }
    return _studentApiService.getAttendance(token);
  }

  void _reload() {
    setState(() {
      _attendanceFuture = _fetchAttendance();
      _selectedSemesterIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: _navy,
        foregroundColor: Colors.white,
        title: const Text('Báo cáo điểm danh'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _reload),
        ],
      ),
      body: FutureBuilder<List<AttendanceModel>>(
        future: _attendanceFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Không có dữ liệu điểm danh.'));
          }

          final all = snapshot.data!;
          final semesters = _groupBySemester(all);
          if (_selectedSemesterIndex >= semesters.length) {
            _selectedSemesterIndex = 0;
          }
          final selected = semesters[_selectedSemesterIndex];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSemesterTabs(semesters),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Text(
                  'Mỗi kỳ: ${selected.items.isNotEmpty ? selected.items.first.totalSlots : 20} buổi · % tham gia = (20 − vắng) / 20',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: selected.items.length,
                  itemBuilder: (context, index) {
                    return _buildCard(selected.items[index]);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<_SemesterGroup> _groupBySemester(List<AttendanceModel> all) {
    final map = <int, _SemesterGroup>{};
    for (final item in all) {
      final sid = item.semesterId ?? 0;
      map.putIfAbsent(
        sid,
        () => _SemesterGroup(
          semesterId: sid,
          code: (item.semesterCode != null && item.semesterCode!.isNotEmpty)
              ? item.semesterCode!
              : 'Kỳ $sid',
          name: item.semesterName ?? '',
          items: [],
        ),
      );
      map[sid]!.items.add(item);
    }
    return map.values.toList();
  }

  Widget _buildSemesterTabs(List<_SemesterGroup> semesters) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(semesters.length, (index) {
            final sem = semesters[index];
            final selected = index == _selectedSemesterIndex;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(sem.code),
                selected: selected,
                onSelected: (_) =>
                    setState(() => _selectedSemesterIndex = index),
                selectedColor: _orange,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
                backgroundColor: Colors.white,
                side: BorderSide(
                  color: selected ? _orange : Colors.grey.shade300,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildCard(AttendanceModel item) {
    final warning = item.absentPercent >= 20.0;
    final presentColor =
        warning ? Colors.red.shade700 : Colors.green.shade700;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor:
                  warning ? Colors.red.shade100 : Colors.green.shade100,
              child: Icon(
                warning ? Icons.warning_amber_rounded : Icons.check_rounded,
                color: warning ? Colors.red : Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.subjectName ?? item.subjectCode ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.subjectCode ?? ''} · Tham gia ${item.presentSlots}/${item.totalSlots} buổi',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                  ),
                  Text(
                    'Vắng: ${item.absentSlots}/${item.totalSlots} buổi',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${item.presentPercent.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: presentColor,
                  ),
                ),
                Text(
                  'tham gia',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SemesterGroup {
  final int semesterId;
  final String code;
  final String name;
  final List<AttendanceModel> items;

  _SemesterGroup({
    required this.semesterId,
    required this.code,
    required this.name,
    required this.items,
  });
}
