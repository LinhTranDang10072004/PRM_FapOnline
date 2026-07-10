import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_shadows.dart';
import '../../widgets/app_card.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/empty_state.dart';

class MyChildrenScreen extends StatelessWidget {
  const MyChildrenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data
    final List<Map<String, dynamic>> children = [
      {
        'id': 1,
        'name': 'Nguyễn Văn B',
        'code': 'SE171234',
        'major': 'Kỹ thuật phần mềm',
        'status': 'active'
      },
      {
        'id': 2,
        'name': 'Nguyễn Thị C',
        'code': 'SE171567',
        'major': 'Thiết kế đồ họa',
        'status': 'active'
      },
    ];

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
                return AppCard(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/child-detail',
                      arguments: child['id'],
                    );
                  },
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.primary,
                        child: const Icon(Icons.person, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              child['name'],
                              style: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'MSSV: ${child['code']}',
                              style: AppTextStyles.caption,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Ngành: ${child['major']}',
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                      ),
                      if (child['status'] == 'active')
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
