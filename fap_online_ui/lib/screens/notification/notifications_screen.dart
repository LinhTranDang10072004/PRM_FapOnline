import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/dashboard_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../services/notification_service.dart';
import '../../models/response/notification_dto.dart';
import 'notification_detail_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  String _selectedFilter = 'all'; // 'all' or 'unread'
  List<NotificationDTO> _allNotifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    final notifications = await _notificationService.getNotifications();
    setState(() {
      _allNotifications = notifications;
      _isLoading = false;
    });
  }

  String _formatTime(String sentAt) {
    try {
      final dateTime = DateTime.parse(sentAt);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 60) {
        return '${difference.inMinutes} phút trước';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} giờ trước';
      } else if (difference.inDays == 1) {
        return 'Hôm qua';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} ngày trước';
      } else if (difference.inDays < 30) {
        return '${(difference.inDays / 7).floor()} tuần trước';
      } else {
        return '${(difference.inDays / 30).floor()} tháng trước';
      }
    } catch (e) {
      return sentAt;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final notifications = _allNotifications.where((n) {
      if (_selectedFilter == 'unread') return !n.isRead;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Thông báo', style: AppTextStyles.h2),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadNotifications,
        child: Column(
          children: [
            // Filter Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('Tất cả'),
                    selected: _selectedFilter == 'all',
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedFilter = 'all');
                    },
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: _selectedFilter == 'all'
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Chưa đọc'),
                    selected: _selectedFilter == 'unread',
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedFilter = 'unread');
                    },
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: _selectedFilter == 'unread'
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: notifications.isEmpty
                  ? const Center(child: Text('Không có thông báo nào'))
                  : ListView.separated(
                      itemCount: notifications.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1, color: AppColors.divider),
                      itemBuilder: (context, index) {
                        final item = notifications[index];
                        final bool unread = !item.isRead;

                        return InkWell(
                          onTap: () async {
                            final dashboardProvider = context
                                .read<DashboardProvider>();
                            final navigator = Navigator.of(context);
                            // Mark as read when opening
                            if (unread) {
                              final markedAsRead = await _notificationService
                                  .markAsRead(item.notificationId);
                              if (!mounted) return;
                              if (markedAsRead) {
                                // Update local state
                                setState(() {
                                  final idx = _allNotifications.indexWhere(
                                    (n) =>
                                        n.notificationId == item.notificationId,
                                  );
                                  if (idx != -1) {
                                    _allNotifications[idx] = NotificationDTO(
                                      notificationId: item.notificationId,
                                      title: item.title,
                                      message: item.message,
                                      sentAt: item.sentAt,
                                      isRead: true,
                                    );
                                  }
                                });
                                // Keep the navigation badge in sync with the
                                // server's unread count.
                                dashboardProvider.fetchDashboard();
                              }
                            }

                            navigator.push(
                              MaterialPageRoute(
                                builder: (_) => NotificationDetailScreen(
                                  title: item.title,
                                  sender: 'Hệ thống',
                                  time: _formatTime(item.sentAt),
                                  message: item.message,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            color: unread
                                ? AppColors.primaryLight.withOpacity(0.05)
                                : Colors.transparent,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (unread)
                                  Container(
                                    width: 8,
                                    height: 8,
                                    margin: const EdgeInsets.only(
                                      top: 6,
                                      right: 12,
                                    ),
                                    decoration: const BoxDecoration(
                                      color: AppColors.unreadDot,
                                      shape: BoxShape.circle,
                                    ),
                                  )
                                else
                                  const SizedBox(width: 20),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.title,
                                        style: AppTextStyles.bodyMedium
                                            .copyWith(
                                              fontWeight: unread
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Hệ thống • ${_formatTime(item.sentAt)}',
                                        style: AppTextStyles.caption,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
