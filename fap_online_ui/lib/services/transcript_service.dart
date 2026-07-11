import '../config/api_endpoints.dart';
import '../models/response/transcript_dto.dart';
import 'api_service.dart';

class TranscriptService {
  final ApiService _apiService = ApiService();

  Future<List<TranscriptDTO>> getStudentTranscript(int studentId) async {
    try {
      final response = await _apiService.get(ApiEndpoints.transcriptStudent(studentId));
      
      if (response is List) {
        return response
            .map((item) => TranscriptDTO.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching transcript: $e');
      return [];
    }
  }

  Future<List<TranscriptDTO>> getRecentGrades(
    int studentId, {
    int limit = 5,
  }) async {
    try {
      final endpoint = '${ApiEndpoints.transcriptRecent(studentId)}?limit=$limit';
      final response = await _apiService.get(endpoint);
      
      if (response is List) {
        return response
            .map((item) => TranscriptDTO.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching recent grades: $e');
      return [];
    }
  }

  Future<List<TranscriptDTO>> getSemesterTranscript(
    int studentId,
    int semesterId,
  ) async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.transcriptSemester(studentId, semesterId),
      );
      
      if (response is List) {
        return response
            .map((item) => TranscriptDTO.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching semester transcript: $e');
      return [];
    }
  }

  Future<double?> getAverageScore(int studentId) async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.transcriptAverage(studentId),
      );
      
      if (response is num) {
        return response.toDouble();
      }
      return null;
    } catch (e) {
      print('Error fetching average score: $e');
      return null;
    }
  }
}
