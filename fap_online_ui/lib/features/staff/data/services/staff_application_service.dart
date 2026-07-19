import '../../../../services/api_service.dart';
import '../../../../config/api_endpoints.dart';
import '../models/staff_models.dart';

class StaffApplicationService {
  final ApiService _api = ApiService();

  /// UC-18: GET /api/staff/applications  (optional filter by status)
  Future<List<ApplicationModel>> getApplications({String? status}) async {
    final query = status != null ? '?status=$status' : '';
    final data = await _api.get('${ApiEndpoints.staffApplications}$query');
    return (data as List<dynamic>)
        .map((e) => ApplicationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /api/staff/applications/{id}
  Future<ApplicationModel> getApplicationById(int id) async {
    final data = await _api.get(ApiEndpoints.staffApplicationById(id));
    return ApplicationModel.fromJson(data as Map<String, dynamic>);
  }

  /// UC-18: PUT /api/staff/applications/{id}/approve
  Future<ApplicationModel> approveApplication(int id, {String? note}) async {
    final data = await _api.put(
      ApiEndpoints.staffApplicationApprove(id),
      body: ProcessApplicationRequest(processNote: note).toJson(),
    );
    return ApplicationModel.fromJson(data as Map<String, dynamic>);
  }

  /// UC-18: PUT /api/staff/applications/{id}/reject  (processNote is required)
  Future<ApplicationModel> rejectApplication(int id,
      {required String note}) async {
    final data = await _api.put(
      ApiEndpoints.staffApplicationReject(id),
      body: ProcessApplicationRequest(processNote: note).toJson(),
    );
    return ApplicationModel.fromJson(data as Map<String, dynamic>);
  }
}
