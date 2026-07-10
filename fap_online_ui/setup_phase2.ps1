$baseDir = "D:\VU-MOBILE-PROJECT\PRM_FapOnline\fap_online_ui\lib"

$files = @{
    "models\request\login_request.dart" = @"
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}
"@;

    "models\response\login_response.dart" = @"
class LoginResponse {
  final String token;

  LoginResponse({required this.token});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] ?? '',
    );
  }
}
"@;

    "services\auth_service.dart" = @"
import '../config/api_endpoints.dart';
import '../models/request/login_request.dart';
import '../models/response/login_response.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<LoginResponse> login(LoginRequest request) async {
    final response = await _apiService.post(ApiEndpoints.login, request.toJson());
    return LoginResponse.fromJson(response);
  }
}
"@;

    "provider\auth_provider.dart" = @"
import 'package:flutter/material.dart';
import '../models/request/login_request.dart';
import '../services/auth_service.dart';
import '../utils/preferences.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final request = LoginRequest(email: email, password: password);
      final response = await _authService.login(request);
      
      // Save token locally
      await PreferencesHelper.saveToken(response.token);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await PreferencesHelper.clearToken();
    notifyListeners();
  }
}
"@;

    "screens\auth\login_screen.dart" = @"
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/auth_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_textfield.dart';
import '../../config/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final success = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (success) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Login failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.school, size: 80, color: Colors.blue),
                  const SizedBox(height: 24),
                  const Text(
                    'Parent Portal',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Login to manage your children',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 48),
                  AppTextField(
                    label: 'Email',
                    controller: _emailController,
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Email is required';
                      if (!val.contains('@')) return 'Invalid email format';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Password',
                    controller: _passwordController,
                    obscureText: true,
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Password is required';
                      if (val.length < 6) return 'Password too short';
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      return AppButton(
                        text: 'Login',
                        isLoading: auth.isLoading,
                        onPressed: _handleLogin,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
"@;

    "config\app_routes.dart" = @"
import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
// import '../screens/dashboard/dashboard_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  
  static Map<String, WidgetBuilder> get routes => {
    login: (context) => const LoginScreen(),
    // dashboard: (context) => const DashboardScreen(),
  };
}
"@;

    "main.dart" = @"
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'config/constants.dart';
import 'config/app_routes.dart';
import 'provider/auth_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Constants.appName,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.login,
      routes: AppRoutes.routes,
    );
  }
}
"@;
}

foreach ($key in $files.Keys) {
    $filePath = Join-Path $baseDir $key
    Set-Content -Path $filePath -Value $files[$key] -Encoding UTF8
}
