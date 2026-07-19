import 'package:flutter/material.dart';
import '../../services/student_api_service.dart';
import '../../services/auth_service.dart';
import '../../models/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final StudentApiService _studentApiService = StudentApiService();
  final AuthService _authService = AuthService();
  late Future<List<NotificationModel>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _notificationsFuture = _fetchNotifications();
  }

  Future<List<NotificationModel>> _fetchNotifications() async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Không tìm thấy token đăng nhập. Vui lòng đăng nhập lại.');
    }
    return _studentApiService.getNotifications(token);
  }

  void _reload() {
    setState(() {
      _notificationsFuture = _fetchNotifications();
    });
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'academic':
        return Icons.menu_book;
      case 'grade':
        return Icons.grade;
      case 'finance':
        return Icons.attach_money;
      default:
        return Icons.notifications;
    }
  }

  Color _getColorForType(String type) {
    switch (type.toLowerCase()) {
      case 'academic':
        return Colors.blue;
      case 'grade':
        return Colors.orange;
      case 'finance':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reload,
          ),
        ],
      ),
      body: FutureBuilder<List<NotificationModel>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Không có thông báo.'));
          }

          final notifications = snapshot.data!;
          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notif = notifications[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getColorForType(notif.type).withOpacity(0.2),
                    child: Icon(
                      _getIconForType(notif.type),
                      color: _getColorForType(notif.type),
                    ),
                  ),
                  title: Text(
                    notif.title,
                    style: TextStyle(
                      fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(notif.content),
                      const SizedBox(height: 8),
                      Text(
                        notif.createdAt,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
