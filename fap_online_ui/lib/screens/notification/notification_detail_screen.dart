import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class NotificationDetailScreen extends StatelessWidget {
  final String title;
  final String sender;
  final String time;

  const NotificationDetailScreen({
    super.key,
    required this.title,
    required this.sender,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Chi tiết thông báo', style: AppTextStyles.subtitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.h2),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primaryLight.withOpacity(0.2),
                  child: const Icon(Icons.apartment_rounded, size: 16, color: AppColors.primary),
                ),
                const SizedBox(width: 8),
                Text(sender, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                const Spacer(),
                Text(time, style: AppTextStyles.caption),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                Chip(
                  label: const Text('Nguyễn Văn B'),
                  backgroundColor: AppColors.shimmerHighlight,
                  side: BorderSide.none,
                  labelStyle: AppTextStyles.captionBold,
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Divider(color: AppColors.divider),
            ),
            Text(
              'Kính gửi Quý Phụ huynh,\n\nNhà trường xin thông báo lịch thi cuối kỳ học kỳ Fall 2026 đã được cập nhật trên hệ thống. Quý phụ huynh vui lòng kiểm tra mục "Thời khóa biểu" hoặc "Bảng điểm" để theo dõi chi tiết lịch thi của con em mình.\n\nNếu có bất kỳ thắc mắc nào, xin vui lòng liên hệ phòng đào tạo qua email hoặc số điện thoại hỗ trợ.\n\nTrân trọng,\n$sender',
              style: AppTextStyles.body.copyWith(height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}
