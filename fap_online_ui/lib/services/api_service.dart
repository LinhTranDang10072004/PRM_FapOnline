import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_endpoints.dart';
import '../utils/preferences.dart';

class ApiException implements Exception {
  final String message;
  final int statusCode;
  ApiException(this.message, this.statusCode);
  @override
  String toString() => message;
}

class ApiService {
  Future<Map<String, String>> _getHeaders() async {
    final token = await PreferencesHelper.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse(ApiEndpoints.baseUrl + endpoint),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 15));
      return _processResponse(response);
    } catch (e) {
      throw ApiException(e.toString(), 0);
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.baseUrl + endpoint),
        headers: await _getHeaders(),
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));
      return _processResponse(response);
    } catch (e) {
      throw ApiException(e.toString(), 0);
    }
  }

  Future<dynamic> put(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final response = await http.put(
        Uri.parse(ApiEndpoints.baseUrl + endpoint),
        headers: await _getHeaders(),
        body: body != null ? jsonEncode(body) : null,
      ).timeout(const Duration(seconds: 15));
      return _processResponse(response);
    } catch (e) {
      throw ApiException(e.toString(), 0);
    }
  }

  Future<dynamic> uploadFile(String endpoint, String filePath) async {
    try {
      final token = await PreferencesHelper.getToken();
      var request = http.MultipartRequest('POST', Uri.parse(ApiEndpoints.baseUrl + endpoint));
      
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      
      request.files.add(await http.MultipartFile.fromPath('file', filePath));
      
      var streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      var response = await http.Response.fromStream(streamedResponse);
      
      return _processResponse(response);
    } catch (e) {
      throw ApiException(e.toString(), 0);
    }
  }

  dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else {
      String msg = 'Unknown Error';
      try {
        final body = jsonDecode(response.body);
        msg = body['message'] ?? body['error'] ?? msg;
      } catch (_) {}
      throw ApiException(msg, response.statusCode);
    }
  }
}
