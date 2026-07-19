import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/parent_child_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_shadows.dart';
import '../../widgets/app_card.dart';
import '../../config/api_endpoints.dart';
import '../grades/transcript_screen.dart';
import '../attendance/attendance_screen.dart';
import '../fee/fee_screen.dart';
import '../timetable/timetable_screen.dart';

class ChildDetailHubScreen extends StatefulWidget {
  final int studentId;

  const ChildDetailHubScreen({super.key, required this.studentId});

  @override
  State<ChildDetailHubScreen> createState() => _ChildDetailHubScreenState();
}

class _ChildDetailHubScreenState extends State<ChildDetailHubScreen> {
  @override
  void initState() {
    super.initState();
    // Select this child when opening the detail screen
    context.read<ParentChildProvider>().selectChild(widget.studentId);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ParentChildProvider>();
    
    // Find the student or return first if not found
    final student = provider.children.isNotEmpty
        ? provider.children.firstWhere(
            (c) => c.studentId == widget.studentId,
            orElse: () => provider.children.first,
          )
        : null;

    if (student == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Chi tiết sinh viên'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Center(child: Text('Không tìm thấy thông tin')),
      );
    }
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(student.fullName),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCard(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.primary,
                    backgroundImage: student.avatarUrl != null && student.avatarUrl!.isNotEmpty
                        ? NetworkImage(ApiEndpoints.getImageUrl(student.avatarUrl!))
                        : null,
                    child: student.avatarUrl == null || student.avatarUrl!.isEmpty
                        ? const Icon(Icons.person, color: Colors.white, size: 40)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(student.fullName, style: AppTextStyles.h2),
                        const SizedBox(height: 4),
                        Text(
                          'MSSV: ${student.studentCode}',
                          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Ngành: ${student.major}',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Thông tin học vụ', style: AppTextStyles.subtitle),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildActionTile(
                  context,
                  icon: Icons.calendar_month_rounded,
                  color: AppColors.primary,
                  label: 'Thời khóa biểu',
                  onTap: () {
                    // Navigate to timetable screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TimetableScreen(),
                      ),
                    );
                  },
                ),
                _buildActionTile(
                  context,
                  icon: Icons.how_to_reg_rounded,
                  color: AppColors.success,
                  label: 'Điểm danh',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AttendanceScreen(),
                      ),
                    );
                  },
                ),
                _buildActionTile(
                  context,
                  icon: Icons.grade_rounded,
                  color: AppColors.accent,
                  label: 'Bảng điểm',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TranscriptScreen(),
                      ),
                    );
                  },
                ),
                _buildActionTile(
                  context,
                  icon: Icons.payment_rounded,
                  color: AppColors.error,
                  label: 'Học phí',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FeeScreen(),
                      ),
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

  Widget _buildActionTile(BuildContext context, {required IconData icon, required Color color, required String label, required VoidCallback onTap}) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
