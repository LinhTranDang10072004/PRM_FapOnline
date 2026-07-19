import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/app_routes.dart';
import 'config/constants.dart';
import 'provider/auth_provider.dart';
import 'provider/dashboard_provider.dart';
import 'provider/parent_child_provider.dart';
import 'provider/profile_provider.dart';
import 'provider/attendance_provider.dart';
import 'provider/transcript_provider.dart';
import 'provider/student_fee_provider.dart';
import 'theme/app_theme.dart';

import 'package:intl/date_symbol_data_local.dart';

import 'features/staff/presentation/providers/staff_dashboard_provider.dart';
import 'features/staff/presentation/providers/staff_class_provider.dart';
import 'features/staff/presentation/providers/staff_schedule_provider.dart';
import 'features/staff/presentation/providers/staff_application_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('vi', null);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => ParentChildProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => TranscriptProvider()),
        ChangeNotifierProvider(create: (_) => StudentFeeProvider()),
        // Staff Providers
        ChangeNotifierProvider(create: (_) => StaffDashboardProvider()),
        ChangeNotifierProvider(create: (_) => StaffClassProvider()),
        ChangeNotifierProvider(create: (_) => StaffScheduleProvider()),
        ChangeNotifierProvider(create: (_) => StaffApplicationProvider()),
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
      initialRoute: AppRoutes.start,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}
