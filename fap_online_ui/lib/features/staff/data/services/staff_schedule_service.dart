import '../../../../services/api_service.dart';
import '../../../../config/api_endpoints.dart';
import '../models/staff_models.dart';

class StaffScheduleService {
  final ApiService _api = ApiService();

  /// UC-16: GET /api/staff/schedules  (optional filter: classId, date)
  Future<List<ScheduleModel>> getSchedules({int? classId, String? date}) async {
    final params = <String>[];
    if (classId != null) params.add('classId=$classId');
    if (date != null && date.isNotEmpty) params.add('date=$date');
    final query = params.isNotEmpty ? '?${params.join('&')}' : '';
    final data = await _api.get('${ApiEndpoints.staffSchedules}$query');
    return (data as List<dynamic>)
        .map((e) => ScheduleModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /api/staff/schedules/{scheduleId}
  Future<ScheduleModel> getScheduleById(int scheduleId) async {
    final data = await _api.get(ApiEndpoints.staffScheduleById(scheduleId));
    return ScheduleModel.fromJson(data as Map<String, dynamic>);
  }

  /// UC-16: POST /api/staff/schedules
  Future<ScheduleModel> createSchedule(StaffCreateScheduleRequest request) async {
    final data = await _api.post(ApiEndpoints.staffSchedules, request.toJson());
    return ScheduleModel.fromJson(data as Map<String, dynamic>);
  }

  /// UC-17: PUT /api/staff/schedules/{scheduleId}
  Future<ScheduleModel> updateSchedule(
      int scheduleId, StaffUpdateScheduleRequest request) async {
    final data = await _api.put(
      ApiEndpoints.staffScheduleById(scheduleId),
      body: request.toJson(),
    );
    return ScheduleModel.fromJson(data as Map<String, dynamic>);
  }

  /// DELETE /api/staff/schedules/{scheduleId}
  Future<void> deleteSchedule(int scheduleId) async {
    await _api.delete(ApiEndpoints.staffScheduleById(scheduleId));
  }
}
