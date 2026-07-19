import '../config/api_endpoints.dart';
import '../models/response/dashboard_response.dart';
import 'api_service.dart';

class DashboardService {
  final ApiService _apiService = ApiService();

  Future<DashboardResponse?> getDashboardData() async {
    try {
      final response = await _apiService.get(ApiEndpoints.dashboard);
      return DashboardResponse.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      print('Error fetching dashboard data: $e');
      return null;
    }
  }
}
