import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class NotificationDetailScreen extends StatelessWidget {
  final String title;
  final String sender;
  final String time;
  final String? message;

  const NotificationDetailScreen({
    super.key,
    required this.title,
    required this.sender,
    required this.time,
    this.message,
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
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Divider(color: AppColors.divider),
            ),
            Text(
              message ?? 'Không có nội dung thông báo.',
              style: AppTextStyles.body.copyWith(height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}
