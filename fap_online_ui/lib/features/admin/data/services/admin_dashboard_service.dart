import '../../../../services/api_service.dart';
import '../../../../config/api_endpoints.dart';
import '../models/admin_models.dart';

class AdminDashboardService {
  final ApiService _api = ApiService();

  /// GET /api/admin/dashboard?academicYear=&term=
  Future<AdminDashboardModel> getDashboard({
    String? academicYear,
    String? term,
  }) async {
    final data = await _api.get(
      ApiEndpoints.adminDashboardFiltered(
        academicYear: academicYear,
        term: term,
      ),
    );
    return AdminDashboardModel.fromJson(data as Map<String, dynamic>);
  }

  /// GET /api/admin/dashboard/academic-years
  Future<List<String>> getAcademicYears() async {
    final data = await _api.get(ApiEndpoints.adminDashboardAcademicYears);
    if (data is! List) return [];
    return data.map((e) => e.toString()).toList();
  }

  /// GET /api/admin/dashboard/semesters
  Future<List<AdminSemesterModel>> getSemesters() async {
    final data = await _api.get(ApiEndpoints.adminDashboardSemesters);
    if (data is! List) return [];
    return data
        .map((e) => AdminSemesterModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
