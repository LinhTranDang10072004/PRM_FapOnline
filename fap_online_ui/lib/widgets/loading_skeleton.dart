import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';

/// Placeholder shimmer/pulse dùng khi đang tải dữ liệu.
///
/// Có thể dùng trực tiếp hoặc qua các widget dựng sẵn:
/// - [SkeletonCard] — skeleton hình card.
/// - [SkeletonListTile] — skeleton hình list tile (avatar + 2 dòng text).
class LoadingSkeleton extends StatefulWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const LoadingSkeleton({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = 8,
  });

  @override
  State<LoadingSkeleton> createState() => _LoadingSkeletonState();
}

class _LoadingSkeletonState extends State<LoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            color: Color.lerp(
              AppColors.shimmerBase,
              AppColors.shimmerHighlight,
              _animation.value,
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Skeleton Card
// ─────────────────────────────────────────────────────────────────────────────

/// Skeleton có hình dạng card (nền trắng, bo góc, bóng nhẹ) dùng làm
/// placeholder khi đang tải nội dung card.
class SkeletonCard extends StatelessWidget {
  final double height;

  const SkeletonCard({super.key, this.height = 120});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LoadingSkeleton(width: 140, height: 14),
          const SizedBox(height: 12),
          const LoadingSkeleton(height: 12),
          const SizedBox(height: 8),
          LoadingSkeleton(width: MediaQuery.of(context).size.width * 0.6, height: 12),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Skeleton List Tile
// ─────────────────────────────────────────────────────────────────────────────

/// Skeleton hình list tile: vòng tròn avatar bên trái + 2 dòng text.
class SkeletonListTile extends StatelessWidget {
  const SkeletonListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Avatar circle
          const LoadingSkeleton(width: 44, height: 44, borderRadius: 22),
          const SizedBox(width: 12),
          // Text lines
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                LoadingSkeleton(width: 160, height: 14),
                SizedBox(height: 8),
                LoadingSkeleton(width: 100, height: 11),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
