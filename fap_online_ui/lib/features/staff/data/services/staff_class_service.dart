import '../../../../services/api_service.dart';
import '../../../../config/api_endpoints.dart';
import '../models/staff_models.dart';

class StaffClassService {
  final ApiService _api = ApiService();

  /// UC-13: GET /api/staff/classes  (optionally filter by semesterId)
  Future<List<ClassModel>> getAllClasses({int? semesterId}) async {
    final endpoint = semesterId != null
        ? '${ApiEndpoints.staffClasses}?semesterId=$semesterId'
        : ApiEndpoints.staffClasses;
    final data = await _api.get(endpoint);
    return (data as List<dynamic>)
        .map((e) => ClassModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /api/staff/classes/{classId}
  Future<ClassModel> getClassById(int classId) async {
    final data = await _api.get(ApiEndpoints.staffClassById(classId));
    return ClassModel.fromJson(data as Map<String, dynamic>);
  }

  /// UC-13: POST /api/staff/classes
  Future<ClassModel> createClass(CreateClassRequest request) async {
    final data = await _api.post(ApiEndpoints.staffClasses, request.toJson());
    return ClassModel.fromJson(data as Map<String, dynamic>);
  }

  /// UC-14: PUT /api/staff/classes/{classId}
  Future<ClassModel> updateClass(int classId, UpdateClassRequest request) async {
    final data = await _api.put(
      ApiEndpoints.staffClassById(classId),
      body: request.toJson(),
    );
    return ClassModel.fromJson(data as Map<String, dynamic>);
  }

  /// DELETE /api/staff/classes/{classId}  (soft-cancel)
  Future<ClassModel> cancelClass(int classId) async {
    final data = await _api.delete(ApiEndpoints.staffClassById(classId));
    return ClassModel.fromJson(data as Map<String, dynamic>);
  }

  /// UC-15: PUT /api/staff/classes/{classId}/teacher
  Future<ClassModel> assignTeacher(int classId, int teacherId) async {
    final data = await _api.put(
      ApiEndpoints.staffClassTeacher(classId),
      body: AssignTeacherRequest(teacherId: teacherId).toJson(),
    );
    return ClassModel.fromJson(data as Map<String, dynamic>);
  }

  /// UC-14: GET /api/staff/classes/{classId}/students
  Future<List<ClassStudentModel>> getClassStudents(int classId) async {
    final data = await _api.get(ApiEndpoints.staffClassStudents(classId));
    return (data as List<dynamic>)
        .map((e) => ClassStudentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// UC-14: POST /api/staff/classes/{classId}/students
  Future<ClassStudentModel> addStudentToClass(int classId, int studentId) async {
    final data = await _api.post(
      ApiEndpoints.staffClassStudents(classId),
      AddStudentToClassRequest(studentId: studentId).toJson(),
    );
    return ClassStudentModel.fromJson(data as Map<String, dynamic>);
  }

  /// UC-14: DELETE /api/staff/classes/{classId}/students/{studentId}
  Future<void> removeStudentFromClass(int classId, int studentId) async {
    await _api.delete(ApiEndpoints.staffClassStudent(classId, studentId));
  }
}
