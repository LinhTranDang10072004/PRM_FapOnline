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
import 'features/staff/presentation/providers/staff_room_provider.dart';
import 'features/staff/presentation/providers/staff_timeslot_provider.dart';
import 'features/admin/presentation/providers/admin_dashboard_provider.dart';
import 'features/admin/presentation/providers/admin_user_provider.dart';
import 'features/admin/presentation/providers/admin_role_provider.dart';
import 'features/admin/presentation/providers/admin_profile_provider.dart';
import 'controllers/teacher_controller.dart';
import 'controllers/teacher_schedule_controller.dart';
import 'controllers/teacher_class_controller.dart';
import 'controllers/attendance_controller.dart';
import 'controllers/grade_controller.dart';

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
        ChangeNotifierProvider(create: (_) => StaffRoomProvider()),
        ChangeNotifierProvider(create: (_) => StaffTimeSlotProvider()),
        // Admin Providers
        ChangeNotifierProvider(create: (_) => AdminDashboardProvider()),
        ChangeNotifierProvider(create: (_) => AdminUserProvider()),
        ChangeNotifierProvider(create: (_) => AdminRoleProvider()),
        ChangeNotifierProvider(create: (_) => AdminProfileProvider()),
        // Teacher Controllers
        ChangeNotifierProvider(create: (_) => TeacherController()),
        ChangeNotifierProvider(create: (_) => TeacherScheduleController()),
        ChangeNotifierProvider(create: (_) => TeacherClassController()),
        ChangeNotifierProvider(create: (_) => AttendanceController()),
        ChangeNotifierProvider(create: (_) => GradeController()),
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
