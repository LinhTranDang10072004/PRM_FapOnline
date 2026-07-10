import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'notification_detail_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedFilter = 'all'; // 'all' or 'unread'

  late List<Map<String, dynamic>> _allNotifications;

  @override
  void initState() {
    super.initState();
    _allNotifications = [
      {'id': 1, 'unread': true, 'title': 'Lịch thi cuối kỳ đã cập nhật', 'sender': 'Phòng đào tạo', 'time': '2 giờ trước'},
      {'id': 2, 'unread': true, 'title': 'Điểm môn PRM301 đã công bố', 'sender': 'GV. Trần Văn D', 'time': '5 giờ trước'},
      {'id': 3, 'unread': true, 'title': 'Thông báo đóng học phí HK2/2026', 'sender': 'Phòng tài chính', 'time': 'Hôm qua'},
      {'id': 4, 'unread': false, 'title': 'Lịch nghỉ lễ Quốc khánh 2/9', 'sender': 'Ban giám hiệu', 'time': '3 ngày trước'},
      {'id': 5, 'unread': false, 'title': 'Kết quả rèn luyện HK1/2026', 'sender': 'Phòng công tác sinh viên', 'time': '1 tuần trước'},
      {'id': 6, 'unread': false, 'title': 'Thông báo bảo trì hệ thống', 'sender': 'Phòng CNTT', 'time': '2 tuần trước'},
      {'id': 7, 'unread': false, 'title': 'Hướng dẫn đăng ký môn học', 'sender': 'Phòng đào tạo', 'time': '3 tuần trước'},
      {'id': 8, 'unread': false, 'title': 'Kết quả học tập HK1/2026', 'sender': 'Phòng đào tạo', 'time': '1 tháng trước'},
    ];
  }

  @override
  Widget build(BuildContext context) {
    final notifications = _allNotifications.where((n) {
      if (_selectedFilter == 'unread') return n['unread'] == true;
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
      body: Column(
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
                    color: _selectedFilter == 'all' ? Colors.white : AppColors.textSecondary,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                    color: _selectedFilter == 'unread' ? Colors.white : AppColors.textSecondary,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ],
            ),
          ),
          Expanded(
            child: notifications.isEmpty 
              ? const Center(child: Text('Không có thông báo nào'))
              : ListView.separated(
                  itemCount: notifications.length,
                  separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.divider),
                  itemBuilder: (context, index) {
                    final item = notifications[index];
                    final bool unread = item['unread'];
                    
                    return InkWell(
                      onTap: () {
                        setState(() {
                          item['unread'] = false;
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => NotificationDetailScreen(
                              title: item['title'],
                              sender: item['sender'],
                              time: item['time'],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        color: unread ? AppColors.primaryLight.withOpacity(0.05) : Colors.transparent,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (unread)
                              Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.only(top: 6, right: 12),
                                decoration: const BoxDecoration(
                                  color: AppColors.unreadDot,
                                  shape: BoxShape.circle,
                                ),
                              )
                            else
                              const SizedBox(width: 20),
                              
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['title'],
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      fontWeight: unread ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(item['sender'], style: AppTextStyles.caption),
                                      const Spacer(),
                                      Text(item['time'], style: AppTextStyles.caption.copyWith(color: AppColors.textHint)),
                                    ],
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
    );
  }
}
