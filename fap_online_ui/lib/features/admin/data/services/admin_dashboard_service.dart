import '../../../../services/api_service.dart';
import '../../../../config/api_endpoints.dart';
import '../models/admin_models.dart';

class AdminDashboardService {
  final ApiService _api = ApiService();

  /// GET /api/admin/dashboard
  Future<AdminDashboardModel> getDashboard() async {
    final data = await _api.get(ApiEndpoints.adminDashboard);
    return AdminDashboardModel.fromJson(data as Map<String, dynamic>);
  }
}
