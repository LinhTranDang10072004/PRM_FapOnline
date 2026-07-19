import 'package:flutter/material.dart';

/// Bộ đổ bóng (BoxShadow) chuẩn dùng cho card, bottom nav, v.v.
class AppShadows {
  AppShadows._(); // Prevent instantiation

  /// Đổ bóng mặc định cho card.
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  /// Đổ bóng khi card được hover / pressed.
  static const List<BoxShadow> cardHover = [
    BoxShadow(
      color: Color(0x1F000000),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  /// Đổ bóng nhẹ cho các thành phần nhỏ.
  static const List<BoxShadow> subtle = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  /// Đổ bóng cho thanh điều hướng dưới cùng.
  static const List<BoxShadow> bottomNav = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 20,
      offset: Offset(0, -4),
    ),
  ];
}
