import '../config/api_endpoints.dart';
import '../models/response/child_detail_dto.dart';
import '../models/response/weekly_timetable_dto.dart';
import '../models/response/transcript_dto.dart';
import 'api_service.dart';

class ParentChildService {
  final ApiService _apiService = ApiService();

  Future<List<ChildDetailDTO>> getMyChildren() async {
    try {
      final response = await _apiService.get(ApiEndpoints.children);
      if (response is List) {
        return response.map((e) => ChildDetailDTO.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching children: $e');
      return [];
    }
  }

  Future<ChildDetailDTO?> getChildDetail(int studentId) async {
    try {
      final response = await _apiService.get('${ApiEndpoints.children}/$studentId');
      return ChildDetailDTO.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      print('Error fetching child detail: $e');
      return null;
    }
  }

  Future<List<WeeklyTimetableDTO>> getChildTimetable(int studentId, {required String startDate, required String endDate}) async {
    try {
      String url = '${ApiEndpoints.children}/$studentId/schedule?startDate=$startDate&endDate=$endDate';
      final response = await _apiService.get(url);
      if (response is List) {
        return response.map((e) => WeeklyTimetableDTO.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching child timetable: $e');
      return [];
    }
  }

  Future<List<TranscriptDTO>> getChildTranscript(int studentId) async {
    try {
      final response = await _apiService.get('${ApiEndpoints.children}/$studentId/transcript');
      if (response is List) {
        return response.map((e) => TranscriptDTO.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching child transcript: $e');
      return [];
    }
  }
}
