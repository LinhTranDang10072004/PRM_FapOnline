import '../config/api_endpoints.dart';
import '../models/response/student_fee_dto.dart';
import 'api_service.dart';

class StudentFeeService {
  final ApiService _apiService = ApiService();

  Future<List<StudentFeeDTO>> getStudentFees(int studentId) async {
    try {
      final response = await _apiService.get(ApiEndpoints.feesStudent(studentId));
      
      if (response is List) {
        return response
            .map((item) => StudentFeeDTO.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching student fees: $e');
      return [];
    }
  }

  Future<List<StudentFeeDTO>> getUnpaidFees(int studentId) async {
    try {
      final response = await _apiService.get(ApiEndpoints.feesUnpaid(studentId));
      
      if (response is List) {
        return response
            .map((item) => StudentFeeDTO.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching unpaid fees: $e');
      return [];
    }
  }

  Future<List<StudentFeeDTO>> getOverdueFees(int studentId) async {
    try {
      final response = await _apiService.get(ApiEndpoints.feesOverdue(studentId));
      
      if (response is List) {
        return response
            .map((item) => StudentFeeDTO.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching overdue fees: $e');
      return [];
    }
  }

  Future<List<StudentFeeDTO>> getFeesBySemester(
    int studentId,
    int semesterId,
  ) async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.feesSemester(studentId, semesterId),
      );
      
      if (response is List) {
        return response
            .map((item) => StudentFeeDTO.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching fees by semester: $e');
      return [];
    }
  }

  Future<double?> getTotalUnpaidAmount(int studentId) async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.feesTotalUnpaid(studentId),
      );
      
      if (response is num) {
        return response.toDouble();
      }
      return null;
    } catch (e) {
      print('Error fetching total unpaid amount: $e');
      return null;
    }
  }
}
