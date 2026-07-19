import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late final Dio dio;

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal() {
    dio = Dio(BaseOptions(
      baseUrl: 'http://10.0.2.2:8080/api', // Use localhost equivalent for emulator
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));

    dio.interceptors.addAll([
      AuthInterceptor(),
      ErrorInterceptor(),
      UnauthorizedInterceptor(),
    ]);
  }
}

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    handler.next(options);
  }
}

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response != null && err.response?.data != null) {
      try {
        final data = err.response!.data;
        if (data is Map<String, dynamic> && data.containsKey('message')) {
          final message = data['message'];
          final customError = DioException(
            requestOptions: err.requestOptions,
            response: err.response,
            type: err.type,
            error: message,
            message: message,
          );
          return handler.next(customError);
        }
      } catch (_) {
        // Fallback to default
      }
    }
    handler.next(err);
  }
}

class UnauthorizedInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Trigger logout logic
      // e.g. clear SharedPreferences and redirect to login
      SharedPreferences.getInstance().then((prefs) {
        prefs.remove('auth_token');
      });
      // A mechanism like an EventBus or callback should be used to navigate.
      // Assuming a simple global navigator key or similar exists, but left generic for now.
    }
    handler.next(err);
  }
}
