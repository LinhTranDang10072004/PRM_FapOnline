import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8082';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8082';
    }
    return 'http://localhost:8082';
  }

  static const String loginPath = '/api/auth/login';
  static const String mePath = '/api/auth/me';
  static const String logoutPath = '/api/auth/logout';
}
