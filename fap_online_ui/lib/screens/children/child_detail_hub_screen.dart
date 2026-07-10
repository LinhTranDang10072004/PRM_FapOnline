import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_shadows.dart';
import '../../widgets/app_card.dart';

class ChildDetailHubScreen extends StatelessWidget {
  final int studentId;

  const ChildDetailHubScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    // Mock data for student info
    final String fullName = studentId == 1 ? 'Nguyễn Văn B' : 'Nguyễn Thị C';
    final String studentCode = studentId == 1 ? 'SE171234' : 'SE171567';
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(fullName),
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
                    child: const Icon(Icons.person, color: Colors.white, size: 40),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(fullName, style: AppTextStyles.h2),
                        const SizedBox(height: 4),
                        Text(
                          'MSSV: $studentCode',
                          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Học kỳ: Fall 2026 | Lớp: SE1712',
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
                    // Temporarily show a snackbar, but later link to timetable screen or just select tab
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chức năng có ở tab Lịch học')));
                  },
                ),
                _buildActionTile(
                  context,
                  icon: Icons.how_to_reg_rounded,
                  color: AppColors.success,
                  label: 'Điểm danh',
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coming soon'))),
                ),
                _buildActionTile(
                  context,
                  icon: Icons.grade_rounded,
                  color: AppColors.accent,
                  label: 'Bảng điểm',
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coming soon'))),
                ),
                _buildActionTile(
                  context,
                  icon: Icons.payment_rounded,
                  color: AppColors.error,
                  label: 'Học phí',
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coming soon'))),
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
