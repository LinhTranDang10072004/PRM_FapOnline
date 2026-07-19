import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Dữ liệu cho mỗi con em.
class ChildData {
  final int studentId;
  final String name;
  final String? avatarUrl;

  const ChildData({
    required this.studentId,
    required this.name,
    this.avatarUrl,
  });
}

/// Thanh chọn con em (horizontal chips) – dùng trong Dashboard.
class ChildSelector extends StatelessWidget {
  final List<ChildData> children;
  final int selectedId;
  final ValueChanged<int> onSelected;

  const ChildSelector({
    super.key,
    required this.children,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: children.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final child = children[index];
          final isSelected = child.studentId == selectedId;
          return _ChildChip(
            data: child,
            isSelected: isSelected,
            onTap: () => onSelected(child.studentId),
          );
        },
      ),
    );
  }
}

class _ChildChip extends StatelessWidget {
  final ChildData data;
  final bool isSelected;
  final VoidCallback onTap;

  const _ChildChip({
    required this.data,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.primary : AppColors.cardBg,
      borderRadius: BorderRadius.circular(22),
      elevation: isSelected ? 0 : 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.divider,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: isSelected
                    ? Colors.white.withOpacity(0.25)
                    : AppColors.primary.withOpacity(0.1),
                child: Text(
                  data.name.isNotEmpty ? data.name[0] : '?',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                data.name,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
