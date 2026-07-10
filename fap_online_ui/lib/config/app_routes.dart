import 'package:flutter/material.dart';

import '../screens/startup_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/home_screen.dart';
import '../screens/children/child_detail_hub_screen.dart';

class AppRoutes {
  static const String start = '/';
  static const String login = '/login';
  static const String parentShell = '/parent-shell';
  static const String dashboard = parentShell;
  static const String childDetail = '/child-detail';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case start:
        return MaterialPageRoute(builder: (_) => const StartupScreen(), settings: settings);
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen(), settings: settings);
      case parentShell:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );
      case childDetail:
        final studentId = settings.arguments is int ? settings.arguments as int : 1;
        return MaterialPageRoute(
          builder: (_) => ChildDetailHubScreen(studentId: studentId),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route not found')),
          ),
          settings: settings,
        );
    }
  }
}
