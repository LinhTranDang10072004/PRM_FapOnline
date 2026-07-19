import 'package:flutter/material.dart';
import '../../data/models/staff_models.dart';
import '../../data/services/staff_room_service.dart';

class StaffRoomProvider extends ChangeNotifier {
  final StaffRoomService _service = StaffRoomService();

  List<RoomModel> _rooms = [];
  bool _isLoading = false;
  String? _error;

  List<RoomModel> get rooms => _rooms;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadRooms() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _rooms = await _service.getRooms();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createRoom(RoomRequest request) async {
    try {
      final created = await _service.createRoom(request);
      _rooms = [created, ..._rooms];
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateRoom(int roomId, RoomRequest request) async {
    try {
      final updated = await _service.updateRoom(roomId, request);
      _rooms = _rooms.map((r) => r.roomId == roomId ? updated : r).toList();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteRoom(int roomId) async {
    try {
      await _service.deleteRoom(roomId);
      _rooms = _rooms.where((r) => r.roomId != roomId).toList();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
