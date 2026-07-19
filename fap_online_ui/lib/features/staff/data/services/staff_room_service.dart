import '../../../../services/api_service.dart';
import '../../../../config/api_endpoints.dart';
import '../models/staff_models.dart';

class StaffRoomService {
  final ApiService _api = ApiService();

  Future<List<RoomModel>> getRooms() async {
    final data = await _api.get(ApiEndpoints.staffRooms);
    return (data as List<dynamic>)
        .map((e) => RoomModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<RoomModel> createRoom(RoomRequest request) async {
    final data = await _api.post(ApiEndpoints.staffRooms, request.toJson());
    return RoomModel.fromJson(data as Map<String, dynamic>);
  }

  Future<RoomModel> updateRoom(int roomId, RoomRequest request) async {
    final data = await _api.put(
      ApiEndpoints.staffRoomById(roomId),
      body: request.toJson(),
    );
    return RoomModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deleteRoom(int roomId) async {
    await _api.delete(ApiEndpoints.staffRoomById(roomId));
  }
}
