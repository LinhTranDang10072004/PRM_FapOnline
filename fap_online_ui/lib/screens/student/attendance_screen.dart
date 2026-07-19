import 'package:flutter/material.dart';
import '../../services/student_api_service.dart';
import '../../services/auth_service.dart';
import '../../models/attendance_model.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final StudentApiService _studentApiService = StudentApiService();
  final AuthService _authService = AuthService();
  late Future<List<AttendanceModel>> _attendanceFuture;

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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Báo cáo điểm danh'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reload,
          ),
        ],
      ),
      body: FutureBuilder<List<AttendanceModel>>(
        future: _attendanceFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Không có dữ liệu điểm danh.'));
          }

          final attendanceList = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: attendanceList.length,
            itemBuilder: (context, index) {
              final item = attendanceList[index];
              final bool warning = item.absentPercent >= 20.0;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: warning ? Colors.red.shade100 : Colors.green.shade100,
                    child: Icon(
                      warning ? Icons.warning : Icons.check,
                      color: warning ? Colors.red : Colors.green,
                    ),
                  ),
                  title: Text(
                    item.subjectName ?? item.subjectCode ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Vắng: ${item.absentSlots}/${item.totalSlots} slot'),
                  trailing: Text(
                    '${item.absentPercent}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: warning ? Colors.red : Colors.black,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
