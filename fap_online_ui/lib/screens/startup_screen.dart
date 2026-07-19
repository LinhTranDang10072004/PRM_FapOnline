import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../utils/preferences.dart';
import '../utils/role_router.dart';
import '../services/auth_service.dart';

class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _scaleAnimation = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutBack),
    );
    _fadeController.forward();

    _checkAuthAndNavigate();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final token = await PreferencesHelper.getToken();
    if (!mounted) return;

    // Đã login rồi → vào app theo role
    if (token != null && token.isNotEmpty) {
      var role = await PreferencesHelper.getRole();
      if (role == null || role.isEmpty) {
        await AuthService().restoreSession();
        role = await PreferencesHelper.getRole();
      }
      if (!mounted) return;

      final route = RoleRouter.shellRouteFor(role);
      Navigator.pushReplacementNamed(
        context,
        route == '/login' ? '/login' : route,
      );
      return;
    }

    // Chưa login:
    // - chưa chọn campus → /campus
    // - đã chọn campus   → /login
    final campusCode = await PreferencesHelper.getCampusCode();
    if (!mounted) return;

    if (campusCode == null || campusCode.isEmpty) {
      Navigator.pushReplacementNamed(context, '/campus');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: Colors.white),
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 220,
            child: CustomPaint(painter: _WavePainter(top: true)),
          ),
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 220,
            child: CustomPaint(painter: _WavePainter(top: false)),
          ),
          FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 148,
                      height: 148,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.22),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        AppColors.logoAsset,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'FPT UNIVERSITY',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        fontFamily: 'serif',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hệ thống quản lý học vụ',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 36,
            child: Text(
              'Version: 1.0.0',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.95),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final bool top;

  const _WavePainter({required this.top});

  @override
  void paint(Canvas canvas, Size size) {
    final layers = <({Color color, double heightFactor, double amp})>[
      (color: const Color(0xFFFFC107), heightFactor: 1.0, amp: 18),
      (color: const Color(0xFFFF9800), heightFactor: 0.78, amp: 22),
      (color: const Color(0xFFF58220), heightFactor: 0.55, amp: 16),
      (color: const Color(0xFFE65100), heightFactor: 0.32, amp: 12),
    ];

    for (final layer in layers) {
      final paint = Paint()..color = layer.color;
      final path = Path();
      final waveHeight = size.height * layer.heightFactor;

      if (top) {
        path.moveTo(0, 0);
        path.lineTo(size.width, 0);
        path.lineTo(size.width, waveHeight * 0.55);
        path.quadraticBezierTo(
          size.width * 0.75,
          waveHeight * 0.55 + layer.amp,
          size.width * 0.5,
          waveHeight * 0.7,
        );
        path.quadraticBezierTo(
          size.width * 0.25,
          waveHeight * 0.85 + layer.amp,
          0,
          waveHeight * 0.65,
        );
        path.close();
      } else {
        path.moveTo(0, size.height);
        path.lineTo(size.width, size.height);
        path.lineTo(size.width, size.height - waveHeight * 0.55);
        path.quadraticBezierTo(
          size.width * 0.7,
          size.height - waveHeight * 0.7 - layer.amp,
          size.width * 0.45,
          size.height - waveHeight * 0.62,
        );
        path.quadraticBezierTo(
          size.width * 0.2,
          size.height - waveHeight * 0.5 + layer.amp,
          0,
          size.height - waveHeight * 0.72,
        );
        path.close();
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
