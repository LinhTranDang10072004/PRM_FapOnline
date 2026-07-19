import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/dashboard_provider.dart';
import '../provider/parent_child_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';

import 'dashboard/dashboard_tab.dart';
import 'children/my_children_screen.dart';
import 'timetable/timetable_screen.dart';
import 'notification/notifications_screen.dart';
import 'profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _initialized = false;

  late final List<Widget> _tabs = [
    DashboardTab(
      onTabChange: (index) {
        setState(() => _currentIndex = index);
      },
    ),
    const MyChildrenScreen(),
    const TimetableScreen(),
    const NotificationsScreen(),
    const ProfileScreen(),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      context.read<DashboardProvider>().fetchDashboard();
      context.read<ParentChildProvider>().fetchChildren();
    }
  }

  Widget _buildDrawerItem(IconData icon, String title, Widget screen) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context); // Close drawer
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get unread count from provider
    final dashboardProvider = context.watch<DashboardProvider>();
    final int unreadCount = dashboardProvider.dashboardData?.unreadNotificationCount ?? 0;

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
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Trang chủ',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.people_rounded),
              label: 'Con em',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_rounded),
              label: 'Lịch học',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.notifications_rounded),
                  if (unreadCount > 0)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              label: 'Thông báo',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Cá nhân',
            ),
          ],
        ),
      ),
    );
  }
}
