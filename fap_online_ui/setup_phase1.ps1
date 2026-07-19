$baseDir = "D:\VU-MOBILE-PROJECT\PRM_FapOnline\fap_online_ui\lib"

# Create folders
$folders = @("config", "controller", "models\request", "models\response", "provider", "screens\auth", "screens\dashboard", "screens\children", "screens\timetable", "screens\attendance", "screens\grades", "screens\fee", "screens\notification", "screens\profile", "services", "theme", "widgets", "utils")

foreach ($folder in $folders) {
    $path = Join-Path $baseDir $folder
    if (!(Test-Path $path)) {
        New-Item -ItemType Directory -Force -Path $path
    }
}

$files = @{
    "config\constants.dart" = @"
class Constants {
  static const String appName = 'FAP Online Parent';
  static const String tokenKey = 'jwt_token';
}
"@;

    "config\api_endpoints.dart" = @"
class ApiEndpoints {
  static const String baseUrl = 'http://10.0.2.2:8080/api';
  
  // Auth
  static const String login = '/auth/login';
  
  // Parent
  static const String dashboard = '/parent/dashboard';
  static const String children = '/parent/children';
  static const String notifications = '/parent/notifications';
  static const String profile = '/parent/profile';
  static const String changePassword = '/parent/profile/change-password';
}
"@;

    "config\app_routes.dart" = @"
import 'package:flutter/material.dart';

class AppRoutes {
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  
  static Map<String, WidgetBuilder> get routes => {
    // We will populate these as we build the screens
  };
}
"@;

    "theme\app_theme.dart" = @"
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: Colors.blue,
      brightness: Brightness.light,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
"@;

    "utils\preferences.dart" = @"
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';

class PreferencesHelper {
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(Constants.tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(Constants.tokenKey);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(Constants.tokenKey);
  }
}
"@;

    "services\api_service.dart" = @"
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
      if (token != null) 'Authorization': 'Bearer `$token',
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
"@;

    "widgets\app_button.dart" = @"
import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;

  const AppButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 24, height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Text(text, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
"@;

    "widgets\app_textfield.dart" = @"
import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final String? Function(String?)? validator;

  const AppTextField({
    Key? key,
    required this.label,
    required this.controller,
    this.obscureText = false,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
      ),
    );
  }
}
"@;

    "widgets\loading_widget.dart" = @"
import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
"@;

    "widgets\empty_widget.dart" = @"
import 'package:flutter/material.dart';

class EmptyWidget extends StatelessWidget {
  final String message;
  const EmptyWidget({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inbox, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }
}
"@;

    "main.dart" = @"
import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'config/constants.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Constants.appName,
      theme: AppTheme.lightTheme,
      home: const Scaffold(
        body: Center(child: Text('Setup Complete')),
      ),
    );
  }
}
"@;
}

foreach ($key in $files.Keys) {
    $filePath = Join-Path $baseDir $key
    Set-Content -Path $filePath -Value $files[$key] -Encoding UTF8
}
