import '../../../../services/api_service.dart';
import '../../../../config/api_endpoints.dart';
import '../models/staff_models.dart';

class StaffTimeSlotService {
  final ApiService _api = ApiService();

  Future<List<TimeSlotModel>> getTimeSlots() async {
    final data = await _api.get(ApiEndpoints.staffTimeSlots);
    return (data as List<dynamic>)
        .map((e) => TimeSlotModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<TimeSlotModel> createTimeSlot(TimeSlotRequest request) async {
    final data = await _api.post(ApiEndpoints.staffTimeSlots, request.toJson());
    return TimeSlotModel.fromJson(data as Map<String, dynamic>);
  }

  Future<TimeSlotModel> updateTimeSlot(
      int timeSlotId, TimeSlotRequest request) async {
    final data = await _api.put(
      ApiEndpoints.staffTimeSlotById(timeSlotId),
      body: request.toJson(),
    );
    return TimeSlotModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deleteTimeSlot(int timeSlotId) async {
    await _api.delete(ApiEndpoints.staffTimeSlotById(timeSlotId));
  }
}
