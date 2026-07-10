import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_card.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primaryLight.withOpacity(0.1),
                    AppColors.background,
                  ],
                ),
              ),
              padding: const EdgeInsets.only(top: 60, bottom: 20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.person, size: 40, color: AppColors.primary),
                  ),
                  const SizedBox(height: 12),
                  const Text('Nguyễn Văn A', style: AppTextStyles.h2),
                  const SizedBox(height: 4),
                  Text('nguyenvana@gmail.com', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text('0912345678', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Phụ huynh', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AppCard(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.edit_outlined, color: AppColors.textPrimary),
                    title: const Text('Chỉnh sửa thông tin', style: AppTextStyles.bodyMedium),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                      );
                    },
                  ),
                  const Divider(indent: 56, height: 1, color: AppColors.divider),
                  ListTile(
                    leading: const Icon(Icons.lock_outline, color: AppColors.textPrimary),
                    title: const Text('Đổi mật khẩu', style: AppTextStyles.bodyMedium),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
                      );
                    },
                  ),
                  const Divider(indent: 56, height: 1, color: AppColors.divider),
                  ListTile(
                    leading: const Icon(Icons.logout, color: AppColors.error),
                    title: Text('Đăng xuất', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error)),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Đăng xuất'),
                          content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Hủy', style: TextStyle(color: AppColors.textSecondary)),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                Navigator.pushReplacementNamed(context, '/login');
                              },
                              child: const Text('Đăng xuất', style: TextStyle(color: AppColors.error)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text('Phiên bản 1.0.0', style: AppTextStyles.caption),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
