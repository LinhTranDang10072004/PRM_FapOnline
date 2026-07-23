import 'package:flutter/material.dart';

import '../../../../config/app_routes.dart';
import '../../../../services/auth_service.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_shadows.dart';
import '../../../../utils/preferences.dart';
import 'admin_dashboard_screen.dart';
import 'admin_users_screen.dart';
import 'admin_roles_screen.dart';
import 'admin_profile_screen.dart';

class AdminShellScreen extends StatefulWidget {
  const AdminShellScreen({super.key});

  @override
  State<AdminShellScreen> createState() => _AdminShellScreenState();
}

class _AdminShellScreenState extends State<AdminShellScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    AdminDashboardScreen(),
    AdminUsersScreen(),
    AdminRolesScreen(),
    AdminProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: AppShadows.bottomNav,
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textHint,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'Tổng quan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.manage_accounts_rounded),
              label: 'Tài khoản',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.badge_rounded),
              label: 'Roles',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Hồ sơ',
            ),
          ],
        ),
      ),
      drawer: const _AdminDrawer(),
    );
  }
}

class _AdminDrawer extends StatefulWidget {
  const _AdminDrawer();

  @override
  State<_AdminDrawer> createState() => _AdminDrawerState();
}

class _AdminDrawerState extends State<_AdminDrawer> {
  String? _displayName;

  @override
  void initState() {
    super.initState();
    _loadName();
  }

  Future<void> _loadName() async {
    final name = await PreferencesHelper.getFullName();
    if (mounted) setState(() => _displayName = name);
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white24,
                  child: const Icon(
                    Icons.admin_panel_settings_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Xin chào, ${_displayName ?? 'Admin'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Tổng quan hệ thống',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: AppColors.error),
            title: const Text(
              'Đăng xuất',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () async {
              await authService.logout();
              if (!context.mounted) return;
              Navigator.of(context).pushReplacementNamed(AppRoutes.login);
            },
          ),
        ],
      ),
    );
  }
}
