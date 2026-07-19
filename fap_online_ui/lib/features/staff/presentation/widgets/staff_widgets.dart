import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';

/// Reusable stat card for Staff Dashboard
class StaffStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? iconBg;
  final Color? iconColor;

  const StaffStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.iconBg,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final bg = iconBg ?? AppColors.primaryLight.withOpacity(0.1);
    final ic = iconColor ?? AppColors.primaryLight;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: ic, size: 22),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Reusable status badge chip
class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = _resolve(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  (Color bg, Color fg, String label) _resolve(String s) {
    switch (s.toLowerCase()) {
      case 'active':
      case 'approved':
      case 'in progress':
        return (AppColors.successLight, AppColors.success, s);
      case 'pending':
      case 'open':
      case 'draft':
        return (AppColors.warningLight, const Color(0xFFB45309), s);
      case 'cancelled':
      case 'rejected':
        return (AppColors.errorLight, AppColors.error, s);
      case 'completed':
        return (const Color(0xFFEDE9FE), const Color(0xFF7C3AED), s);
      default:
        return (AppColors.background, AppColors.textSecondary, s);
    }
  }
}
