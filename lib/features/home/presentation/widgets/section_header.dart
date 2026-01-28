import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/theme.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onMoreTap;
  final String moreText;

  const SectionHeader({
    super.key,
    required this.title,
    this.onMoreTap,
    this.moreText = '더보기',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTextStyles.titleLarge,
        ),
        if (onMoreTap != null)
          GestureDetector(
            onTap: onMoreTap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  moreText,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.gray400,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  LucideIcons.chevronRight,
                  size: 16,
                  color: AppColors.gray400,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
