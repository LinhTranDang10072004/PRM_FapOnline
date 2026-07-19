import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/application_model.dart';

class ApplicationTypeModel {
  final int applicationTypeId;
  final String typeName;
  final String? description;

  ApplicationTypeModel({
    required this.applicationTypeId,
    required this.typeName,
    this.description,
  });

  factory ApplicationTypeModel.fromJson(Map<String, dynamic> json) {
    return ApplicationTypeModel(
      applicationTypeId: json['applicationTypeId'] as int,
      typeName: json['typeName']?.toString() ?? '',
      description: json['description']?.toString(),
    );
  }
}

class ApplicationApiService {
  Future<List<ApplicationTypeModel>> getTypes(String token) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/applications/types'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return (json.decode(response.body) as List)
          .map((e) => ApplicationTypeModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Không tải được loại đơn (${response.statusCode})');
  }

  Future<List<ApplicationModel>> getMyApplications(String token) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/applications/my'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((e) => ApplicationModel.fromJson(e)).toList();
    }
    throw Exception('Không tải được danh sách đơn (${response.statusCode})');
  }

  /// Returns null on success, error message on failure.
  Future<String?> submitApplication(
    String token, {
    required int applicationTypeId,
    required String title,
    required String content,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/applications'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'applicationTypeId': applicationTypeId,
          'title': title,
          'content': content,
          if (startDate != null) 'startDate': startDate,
          if (endDate != null) 'endDate': endDate,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return null;
      }
      try {
        final body = json.decode(response.body);
        if (body is Map && body['message'] != null) {
          return body['message'].toString();
        }
      } catch (_) {}
      return 'Nộp đơn thất bại (${response.statusCode})';
    } catch (e) {
      return e.toString();
    }
  }
}
