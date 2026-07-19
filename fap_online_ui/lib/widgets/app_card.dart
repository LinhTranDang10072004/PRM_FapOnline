import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';

/// Card tái sử dụng với nền trắng, bo góc 16, bóng nhẹ.
///
/// Hỗ trợ [onTap], [border] tùy chọn (dùng để hiển thị trạng thái active),
/// và [padding] tuỳ chỉnh.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Border? border;
  final Color? backgroundColor;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.onTap,
    this.border,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: backgroundColor ?? AppColors.cardBg,
      borderRadius: BorderRadius.circular(16),
      border: border,
      boxShadow: AppShadows.card,
    );

    Widget cardWidget;
    if (onTap != null) {
      cardWidget = DecoratedBox(
        decoration: decoration,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: padding,
              child: child,
            ),
          ),
        ),
      );
    } else {
      cardWidget = Container(
        decoration: decoration,
        padding: padding,
        child: child,
      );
    }

    if (margin != null) {
      return Padding(
        padding: margin!,
        child: cardWidget,
      );
    }
    return cardWidget;
  }
}
