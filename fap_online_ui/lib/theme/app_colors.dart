import 'package:flutter/material.dart';

/// Bảng màu chính của ứng dụng PRM Parent.
/// Tất cả các widget nên sử dụng các hằng số này thay vì hard-code giá trị màu.
class AppColors {
  AppColors._(); // Prevent instantiation

  // ── Brand ──────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF1E3A8A);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF1E2D5B);

  // ── Accent / CTA ──────────────────────────────────────────────────────
  static const Color accent = Color(0xFFF97316);
  static const Color accentLight = Color(0xFFFFF7ED);

  // ── Semantic ───────────────────────────────────────────────────────────
  static const Color success = Color(0xFF16A34A);
  static const Color successLight = Color(0xFFF0FDF4);

  static const Color warning = Color(0xFFFBBF24);
  static const Color warningLight = Color(0xFFFFFBEB);

  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFFEF2F2);

  // ── Surfaces ───────────────────────────────────────────────────────────
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  static const Color cardBg = Colors.white;

  // ── Text ────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textHint = Color(0xFF94A3B8);

  // ── Borders & Dividers ─────────────────────────────────────────────────
  static const Color divider = Color(0xFFE2E8F0);
  static const Color border = Color(0xFFCBD5E1);

  // ── Misc ────────────────────────────────────────────────────────────────
  static const Color unreadDot = Color(0xFF3B82F6);
  static const Color shimmerBase = Color(0xFFE2E8F0);
  static const Color shimmerHighlight = Color(0xFFF1F5F9);
}
