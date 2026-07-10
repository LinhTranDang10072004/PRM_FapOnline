import 'package:flutter/foundation.dart';

class ApiEndpoints {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8082/api';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8082/api';
    }
    return 'http://localhost:8082/api';
  }
  
  // Auth
  static const String login = '/auth/login';
  static const String me = '/auth/me';
  static const String logout = '/auth/logout';
  
  // Parent
  static const String dashboard = '/parent/dashboard';
  static const String children = '/parent/children';
  static const String notifications = '/parent/notifications';
  static const String profile = '/parent/profile';
  static const String changePassword = '/parent/profile/change-password';
}
