import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/parent_child_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_card.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/empty_state.dart';
import '../../config/api_endpoints.dart';

class MyChildrenScreen extends StatelessWidget {
  const MyChildrenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ParentChildProvider>();

    if (provider.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final children = provider.children;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Con em của tôi', style: AppTextStyles.h2),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: children.isEmpty
          ? EmptyState(
              icon: Icons.people_outline,
              title: 'Chưa có sinh viên nào',
              subtitle: 'Chưa có sinh viên nào được liên kết.\nVui lòng liên hệ Admin/Staff.',
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: children.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final child = children[index];
                final isActive = child.academicStatus?.toLowerCase() == 'active';
                
                return AppCard(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/child-detail',
                      arguments: child.studentId,
                    );
                  },
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.primary,
                        backgroundImage: child.avatarUrl != null && child.avatarUrl!.isNotEmpty
                            ? NetworkImage(ApiEndpoints.getImageUrl(child.avatarUrl!))
                            : null,
                        child: child.avatarUrl == null || child.avatarUrl!.isEmpty
                            ? const Icon(Icons.person, color: Colors.white, size: 28)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              child.fullName,
                              style: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'MSSV: ${child.studentCode}',
                              style: AppTextStyles.caption,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Ngành: ${child.major}',
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                      ),
                      if (isActive)
                        StatusBadge.active()
                      else
                        StatusBadge.onLeave(),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
