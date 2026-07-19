import 'package:flutter/material.dart';
import '../../services/student_api_service.dart';
import '../../services/auth_service.dart';
import '../../models/mark_report_model.dart';
import 'mark_detail_screen.dart';

class MarkReportScreen extends StatefulWidget {
  const MarkReportScreen({super.key});

  @override
  State<MarkReportScreen> createState() => _MarkReportScreenState();
}

class _MarkReportScreenState extends State<MarkReportScreen> {
  final StudentApiService _studentApiService = StudentApiService();
  final AuthService _authService = AuthService();

  late Future<MarkReportModel> _markReportFuture;
  int _selectedSemesterIndex = 0;

  static const _navy = Color(0xFF1B2A4A);
  static const _orange = Color(0xFFF57C00);

  @override
  void initState() {
    super.initState();
    _markReportFuture = _fetchMarkReport();
  }

  Future<MarkReportModel> _fetchMarkReport() async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Không tìm thấy token đăng nhập. Vui lòng đăng nhập lại.');
    }
    return _studentApiService.getMarkReport(token);
  }

  void _reload() {
    setState(() {
      _markReportFuture = _fetchMarkReport();
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
        title: const Text('Mark Report'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _reload),
        ],
      ),
      body: FutureBuilder<MarkReportModel>(
        future: _markReportFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.semesters.isEmpty) {
            return const Center(child: Text('Chưa có dữ liệu điểm.'));
          }

          final semesters = snapshot.data!.semesters;
          if (_selectedSemesterIndex >= semesters.length) {
            _selectedSemesterIndex = 0;
          }
          final selectedSemester = semesters[_selectedSemesterIndex];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSemesterTabs(semesters),
              Expanded(
                child: selectedSemester.courses.isEmpty
                    ? const Center(child: Text('Không có môn học trong kỳ này.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: selectedSemester.courses.length,
                        itemBuilder: (context, index) {
                          return _buildCourseCard(selectedSemester.courses[index]);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSemesterTabs(List<SemesterMarkModel> semesters) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(semesters.length, (index) {
            final semester = semesters[index];
            final isSelected = index == _selectedSemesterIndex;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(semester.semesterCode),
                selected: isSelected,
                onSelected: (_) => setState(() => _selectedSemesterIndex = index),
                selectedColor: _orange,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
                backgroundColor: Colors.white,
                side: BorderSide(color: isSelected ? _orange : Colors.grey.shade300),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildCourseCard(CourseMarkSummaryModel course) {
    final isPassed = course.isPassed;
    final borderColor = isPassed ? Colors.green : Colors.red;
    final badgeColor = isPassed ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);
    final badgeTextColor = isPassed ? Colors.green.shade800 : Colors.red.shade700;
    final averageColor = isPassed ? Colors.green.shade700 : Colors.red.shade700;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MarkDetailScreen(
                classId: course.classId,
                subjectTitle: '${course.subjectCode} - ${course.subjectName}',
              ),
            ),
          );
        },
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 5, color: borderColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              '${course.subjectCode} - ${course.subjectName}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: badgeColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              course.result,
                              style: TextStyle(
                                color: badgeTextColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Class name: ${course.classCode}',
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      Text.rich(
                        TextSpan(
                          text: 'Average: ',
                          style: TextStyle(color: Colors.grey.shade800, fontSize: 14),
                          children: [
                            TextSpan(
                              text: (course.average ?? 0).toStringAsFixed(1),
                              style: TextStyle(
                                color: averageColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Attendance: ${course.attendancePercent.toStringAsFixed(1)}%',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
