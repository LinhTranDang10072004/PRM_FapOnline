import '../config/api_endpoints.dart';
import '../models/response/notification_dto.dart';
import 'api_service.dart';

class NotificationService {
  final ApiService _apiService = ApiService();

  Future<List<NotificationDTO>> getNotifications({int page = 0, int size = 20}) async {
    try {
      final response = await _apiService.get('${ApiEndpoints.notifications}?page=$page&size=$size');
      if (response is List) {
        return response.map((e) => NotificationDTO.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }

  Future<bool> markAsRead(int notificationId) async {
    try {
      await _apiService.put('${ApiEndpoints.notifications}/$notificationId/read');
      return true;
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }
}
