import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Chip trạng thái nhỏ gọn với nền màu + chữ.
///
/// Sử dụng các factory constructor tiện lợi cho các trạng thái phổ biến:
/// ```dart
/// StatusBadge.active()
/// StatusBadge.absent()
/// StatusBadge.paid()
/// ```
class StatusBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const StatusBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  // ── Trạng thái chung ──────────────────────────────────────────────────

  /// Đang hoạt động
  factory StatusBadge.active() => StatusBadge(
        label: 'Đang học',
        backgroundColor: AppColors.successLight,
        textColor: AppColors.success,
      );

  /// Nghỉ phép
  factory StatusBadge.onLeave() => StatusBadge(
        label: 'Nghỉ phép',
        backgroundColor: AppColors.warningLight,
        textColor: const Color(0xFFB45309), // amber-700
      );

  // ── Thông báo ─────────────────────────────────────────────────────────

  /// Đã đăng
  factory StatusBadge.published() => StatusBadge(
        label: 'Đã đăng',
        backgroundColor: AppColors.primaryLight.withOpacity(0.12),
        textColor: AppColors.primaryLight,
      );

  // ── Học phí ───────────────────────────────────────────────────────────

  /// Đã thanh toán
  factory StatusBadge.paid() => StatusBadge(
        label: 'Đã thanh toán',
        backgroundColor: AppColors.successLight,
        textColor: AppColors.success,
      );

  /// Chưa thanh toán
  factory StatusBadge.unpaid() => StatusBadge(
        label: 'Chưa thanh toán',
        backgroundColor: AppColors.errorLight,
        textColor: AppColors.error,
      );

  /// Thanh toán một phần
  factory StatusBadge.partiallyPaid() => StatusBadge(
        label: 'Thanh toán một phần',
        backgroundColor: AppColors.warningLight,
        textColor: const Color(0xFFB45309),
      );

  /// Quá hạn
  factory StatusBadge.overdue() => StatusBadge(
        label: 'Quá hạn',
        backgroundColor: AppColors.errorLight,
        textColor: AppColors.error,
      );

  // ── Điểm danh ─────────────────────────────────────────────────────────

  /// Có mặt
  factory StatusBadge.present() => StatusBadge(
        label: 'Có mặt',
        backgroundColor: AppColors.successLight,
        textColor: AppColors.success,
      );

  /// Vắng mặt
  factory StatusBadge.absent() => StatusBadge(
        label: 'Vắng mặt',
        backgroundColor: AppColors.errorLight,
        textColor: AppColors.error,
      );

  /// Đi muộn
  factory StatusBadge.late() => StatusBadge(
        label: 'Đi muộn',
        backgroundColor: AppColors.warningLight,
        textColor: const Color(0xFFB45309),
      );

  /// Được phép vắng
  factory StatusBadge.excused() => StatusBadge(
        label: 'Được phép',
        backgroundColor: AppColors.primaryLight.withOpacity(0.12),
        textColor: AppColors.primaryLight,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
          height: 1.2,
        ),
      ),
    );
  }
}
