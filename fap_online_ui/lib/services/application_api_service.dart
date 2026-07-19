import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/application_model.dart';

class ApplicationApiService {
  Future<List<ApplicationModel>> getMyApplications(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/applications/my'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        return data.map((e) => ApplicationModel.fromJson(e)).toList();
      }
    } catch (e) {
      print('Error fetching applications: $e');
    }
    return [];
  }

  Future<bool> submitApplication(String token, ApplicationModel app) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/applications'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'title': app.title,
          'content': app.content,
          'status': app.status ?? 'Pending',
          'startDate': app.startDate,
          'endDate': app.endDate,
        }),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error submitting application: $e');
      return false;
    }
  }
}
