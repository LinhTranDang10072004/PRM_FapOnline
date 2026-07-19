class ApiConfig {
  /// Android emulator: 10.0.2.2 maps to host machine localhost.
  /// Physical device: replace with your PC LAN IP, e.g. http://192.168.1.10:8080
  /// iOS simulator / desktop: http://localhost:8080
  static const String baseUrl = 'http://localhost:8080';
  // hoặc 'http://127.0.0.1:8080'
  static const String loginPath = '/api/auth/login';
  static const String mePath = '/api/auth/me';
  static const String logoutPath = '/api/auth/logout';
}
