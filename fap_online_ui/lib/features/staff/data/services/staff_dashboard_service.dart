import '../../../../services/api_service.dart';
import '../../../../config/api_endpoints.dart';
import '../models/staff_models.dart';

class StaffDashboardService {
  final ApiService _api = ApiService();

  /// UC-12: GET /api/staff/dashboard
  Future<StaffDashboardModel> getDashboard() async {
    final data = await _api.get(ApiEndpoints.staffDashboard);
    return StaffDashboardModel.fromJson(data as Map<String, dynamic>);
  }
}
