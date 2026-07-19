import 'package:flutter/material.dart';
import '../../services/student_api_service.dart';
import '../../services/auth_service.dart';
import '../../models/grade_model.dart';

class MarkDetailScreen extends StatefulWidget {
  final int classId;
  final String subjectTitle;

  const MarkDetailScreen({
    super.key,
    required this.classId,
    required this.subjectTitle,
  });

  @override
  State<MarkDetailScreen> createState() => _MarkDetailScreenState();
}

class _MarkDetailScreenState extends State<MarkDetailScreen> {
  final StudentApiService _studentApiService = StudentApiService();
  final AuthService _authService = AuthService();
  late Future<GradeDetailModel> _detailFuture;

  static const _navy = Color(0xFF1B2A4A);

  @override
  void initState() {
    super.initState();
    _detailFuture = _fetchDetail();
  }

  Future<GradeDetailModel> _fetchDetail() async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Không tìm thấy token đăng nhập. Vui lòng đăng nhập lại.');
    }
    return _studentApiService.getMarkDetail(token, widget.classId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: _navy,
        foregroundColor: Colors.white,
        title: const Text('Mark Detail'),
      ),
      body: FutureBuilder<GradeDetailModel>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Không có dữ liệu điểm.'));
          }

          final detail = snapshot.data!;
          final isPassed = detail.isPassed;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                widget.subjectTitle,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text('Class name: ${detail.classCode ?? ''}'),
              const SizedBox(height: 12),
              _summaryCard(detail, isPassed),
              const SizedBox(height: 16),
              const Text(
                'Grade Components',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...detail.components.map(_componentTile),
            ],
          );
        },
      ),
    );
  }

  Widget _summaryCard(GradeDetailModel detail, bool isPassed) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Average', style: TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  (detail.finalScore ?? 0).toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isPassed ? Colors.green.shade700 : Colors.red.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Attendance'),
                Text('${detail.attendancePercent.toStringAsFixed(1)}%'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Result'),
                Text(
                  detail.result,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isPassed ? Colors.green.shade700 : Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _componentTile(ComponentGradeModel component) {
    final score = component.score;
    final hasZero = score == null || score == 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(component.componentName),
        subtitle: Text('Weight: ${component.weight.toStringAsFixed(0)}%'),
        trailing: Text(
          score?.toStringAsFixed(1) ?? '-',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: hasZero ? Colors.red.shade700 : Colors.black87,
          ),
        ),
      ),
    );
  }
}
