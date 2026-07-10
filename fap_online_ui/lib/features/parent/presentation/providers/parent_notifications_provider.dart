import 'package:flutter/material.dart';

import '../models/parent_models.dart';
import '../services/parent_repository.dart';

class ParentNotificationsProvider extends ChangeNotifier {
  final ParentRepository _repository;
  bool _disposed = false;

  ParentNotificationsProvider(this._repository);

  bool _loading = true;
  bool get isLoading => _loading;

  String? _error;
  String? get error => _error;

  List<ParentNotificationItem> _notifications = <ParentNotificationItem>[];
  List<ParentNotificationItem> get notifications => _notifications;

  Future<void> load() async {
    _loading = true;
    _error = null;
    _safeNotify();

    try {
      _notifications = await _repository.fetchNotifications();
    } catch (e) {
      if (_disposed) return;
      _error = e.toString();
    }

    if (_disposed) return;
    _loading = false;
    _safeNotify();
  }

  int get unreadCount => _notifications.where((item) => !item.isRead).length;

  Future<void> markAsRead(ParentNotificationItem notification) async {
    final id = notification.notificationId;
    if (id == null || notification.isRead) return;

    await _repository.markNotificationAsRead(id);
    _notifications = _notifications.map((item) {
      if (item.notificationId == id) {
        return ParentNotificationItem(
          notificationId: item.notificationId,
          title: item.title,
          message: item.message,
          sentAt: item.sentAt,
          isRead: true,
        );
      }
      return item;
    }).toList();
    _safeNotify();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _safeNotify() {
    if (_disposed) return;
    notifyListeners();
  }
}
