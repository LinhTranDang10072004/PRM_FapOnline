import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../../provider/dashboard_provider.dart';
import '../../provider/parent_child_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_card.dart';
import '../../widgets/child_selector.dart';
import '../../widgets/summary_card.dart';
import '../../widgets/loading_skeleton.dart';
import '../../widgets/empty_state.dart';
import '../notification/notification_detail_screen.dart';

/// Tab Bảng điều khiển chính — hiển thị tổng quan cho phụ huynh.
class DashboardTab extends StatefulWidget {
  final Function(int)? onTabChange;

  const DashboardTab({super.key, this.onTabChange});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  // ── Mock data ────────────────────────────────────────────────────────────
  final List<ChildData> _children = const [
    ChildData(studentId: 1, name: 'Nguyễn Văn B'),
    ChildData(studentId: 2, name: 'Nguyễn Thị C'),
  ];

  int _selectedChildId = 1;

  final List<_NotificationItem> _notifications = const [
    _NotificationItem(
      unread: true,
      title: 'Lịch thi cuối kỳ đã cập nhật',
      subtitle: 'Phòng đào tạo',
      time: '2 giờ trước',
    ),
    _NotificationItem(
      unread: true,
      title: 'Điểm môn PRM301 đã công bố',
      subtitle: 'Giảng viên Trần Văn D',
      time: '5 giờ trước',
    ),
    _NotificationItem(
      unread: false,
      title: 'Thông báo đóng học phí HK2/2026',
      subtitle: 'Phòng tài chính',
      time: 'Hôm qua',
    ),
  ];

  // ── Handlers ─────────────────────────────────────────────────────────────
  Future<void> _onRefresh() async {
    context.read<DashboardProvider>().fetchDashboard();
    context.read<ParentChildProvider>().fetchChildren();
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = context.watch<DashboardProvider>();
    final parentChildProvider = context.watch<ParentChildProvider>();

    if (dashboardProvider.isLoading || parentChildProvider.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final children = parentChildProvider.children.map((c) => ChildData(
      studentId: c.studentId,
      name: c.fullName,
    )).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Section 1: Greeting header ───────────────────────────
                _buildGreetingHeader(),

                // ── Section 2: Child selector ────────────────────────────
                if (children.length > 1) ...[
                  const SizedBox(height: 4),
                  ChildSelector(
                    children: children,
                    selectedId: parentChildProvider.selectedChildId ?? children.first.studentId,
                    onSelected: (id) {
                      parentChildProvider.selectChild(id);
                    },
                  ),
                ],

                // ── Section 3: Summary cards (2×2 grid) ─────────────────
                const SizedBox(height: 20),
                _buildSummaryGrid(),

                // ── Section 4: Recent notifications ─────────────────────
                const SizedBox(height: 24),
                _buildNotificationHeader(),
                const SizedBox(height: 12),
                _buildNotificationList(),

                // Bottom padding
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Section builders ───────────────────────────────────────────────────────

  Widget _buildGreetingHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          // Left: greeting text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Xin chào,',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                const Text('Nguyễn Văn A', style: AppTextStyles.h2),
              ],
            ),
          ),
          // Right: avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: const Icon(
              Icons.person_rounded,
              size: 28,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryGrid() {
    final childProvider = context.watch<ParentChildProvider>();
    final selectedChildId = childProvider.selectedChildId;
    final data = context.read<DashboardProvider>().dashboardData;
    
    // Filter data for selected child if available
    int todaySchedulesCount = 0;
    double totalUnpaid = 0;
    int recentGradesCount = 0;
    
    if (data != null) {
      if (selectedChildId != null) {
        // Filter for selected child
        todaySchedulesCount = data.todaySchedules.where((s) => s.studentId == null || s.studentId == selectedChildId).length;
        
        final childUnpaidFees = data.unpaidFees.where((f) => f.studentId == selectedChildId).toList();
        for (var f in childUnpaidFees) {
          totalUnpaid += (f.amount - f.paidAmount);
        }
        
        recentGradesCount = data.recentGrades.where((g) => g.studentId == selectedChildId).length;
      } else {
        // Show all
        todaySchedulesCount = data.todaySchedules.length;
        for (var f in data.unpaidFees) {
          totalUnpaid += (f.amount - f.paidAmount);
        }
        recentGradesCount = data.recentGrades.length;
      }
    }
    
    String unpaidDisplay = '0';
    if (totalUnpaid > 0) {
      unpaidDisplay = '${(totalUnpaid / 1000000).toStringAsFixed(1)}M';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.15,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          SummaryCard(
            icon: Icons.calendar_today_rounded,
            iconColor: AppColors.primary,
            iconBgColor: AppColors.primary.withOpacity(0.1),
            title: 'Lịch học sắp tới',
            value: todaySchedulesCount.toString(),
            subtitle: 'Buổi hôm nay',
            onTap: () => widget.onTabChange?.call(2),
          ),
          SummaryCard(
            icon: Icons.how_to_reg_rounded,
            iconColor: AppColors.success,
            iconBgColor: AppColors.success.withOpacity(0.1),
            title: 'Tỷ lệ điểm danh',
            value: '---', // Not in dashboard API yet
            subtitle: 'Học kỳ này',
          ),
          SummaryCard(
            icon: Icons.grade_rounded,
            iconColor: AppColors.accent,
            iconBgColor: AppColors.accent.withOpacity(0.1),
            title: 'Điểm mới công bố',
            value: recentGradesCount.toString(),
            subtitle: 'Gần đây',
          ),
          SummaryCard(
            icon: Icons.payment_rounded,
            iconColor: AppColors.error,
            iconBgColor: AppColors.error.withOpacity(0.1),
            title: 'Học phí chưa đóng',
            value: unpaidDisplay,
            subtitle: 'VNĐ',
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Thông báo mới nhất', style: AppTextStyles.subtitle),
          TextButton(
            onPressed: () {
              widget.onTabChange?.call(3);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryLight,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Xem tất cả',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: List.generate(_notifications.length, (index) {
          final item = _notifications[index];
          return Padding(
            padding: EdgeInsets.only(
              bottom: index < _notifications.length - 1 ? 8 : 0,
            ),
            child: AppCard(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotificationDetailScreen(
                      title: item.title,
                      sender: item.subtitle,
                      time: item.time,
                    ),
                  ),
                );
              },
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                children: [
                  // Unread dot
                  if (item.unread)
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: AppColors.unreadDot,
                        shape: BoxShape.circle,
                      ),
                    )
                  else
                    const SizedBox(width: 20),

                  // Title + subtitle + time
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight:
                                item.unread ? FontWeight.w600 : FontWeight.w400,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.subtitle,
                          style: AppTextStyles.caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.time,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textHint,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Arrow
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textHint,
                    size: 20,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Data model cho mock notification ─────────────────────────────────────────

class _NotificationItem {
  final bool unread;
  final String title;
  final String subtitle;
  final String time;

  const _NotificationItem({
    required this.unread,
    required this.title,
    required this.subtitle,
    required this.time,
  });
}
