import 'package:flutter/material.dart';

/// Bảng màu chính — tông vàng/cam FPT.
class AppColors {
  AppColors._();

  // ── Brand (vàng / cam FPT) ─────────────────────────────────────────────
  static const Color primary = Color(0xFFF58220);
  static const Color primaryLight = Color(0xFFFFB347);
  static const Color primaryDark = Color(0xFFE36A00);

  // ── Accent / CTA ──────────────────────────────────────────────────────
  static const Color accent = Color(0xFFF37021);
  static const Color accentLight = Color(0xFFFFF4E8);

  // ── Semantic ───────────────────────────────────────────────────────────
  static const Color success = Color(0xFF16A34A);
  static const Color successLight = Color(0xFFF0FDF4);

  static const Color warning = Color(0xFFFBBF24);
  static const Color warningLight = Color(0xFFFFFBEB);

  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFFEF2F2);

  // ── Surfaces ───────────────────────────────────────────────────────────
  static const Color background = Color(0xFFFFFBF5);
  static const Color surface = Colors.white;
  static const Color cardBg = Colors.white;

  // ── Text ────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textHint = Color(0xFF94A3B8);

  // ── Borders & Dividers ─────────────────────────────────────────────────
  static const Color divider = Color(0xFFE8E0D5);
  static const Color border = Color(0xFFDCCFC0);

  // ── Misc ────────────────────────────────────────────────────────────────
  static const Color unreadDot = Color(0xFFF58220);
  static const Color shimmerBase = Color(0xFFF3EDE4);
  static const Color shimmerHighlight = Color(0xFFFFF8F0);

  static const String logoAsset = 'image/logo.png';
}
