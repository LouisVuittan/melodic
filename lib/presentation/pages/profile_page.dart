import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../widgets/glass_card.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 120),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // 프로필 카드
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GradientBorderCard(
                  padding: const EdgeInsets.all(24),
                  gradient: AppColors.primaryGradient,
                  child: Column(
                    children: [
                      // 프로필 이미지
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Center(
                          child: Text(
                            '밍',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 이름
                      Text(
                        '밍밍이',
                        style: AppTextStyles.headlineMedium,
                      ),
                      const SizedBox(height: 8),

                      // 레벨 배지
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent500.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.accent500.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              LucideIcons.crown,
                              size: 14,
                              color: AppColors.accent400,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Level 12 · 중급',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.accent400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 통계
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _ProfileStat(value: '23', label: '완료 곡'),
                          Container(
                            height: 30,
                            width: 1,
                            color: AppColors.border,
                          ),
                          _ProfileStat(value: '512', label: '학습 단어'),
                          Container(
                            height: 30,
                            width: 1,
                            color: AppColors.border,
                          ),
                          _ProfileStat(value: '14시간', label: '학습 시간'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // 설정 섹션
              _SettingsSection(
                title: '학습 설정',
                items: [
                  _SettingsItem(
                    icon: LucideIcons.target,
                    title: '일일 목표',
                    trailing: Text(
                      '10분',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.accent500,
                      ),
                    ),
                  ),
                  _SettingsItem(
                    icon: LucideIcons.bell,
                    title: '학습 알림',
                    trailing: Switch(
                      value: true,
                      onChanged: (_) {},
                      activeColor: AppColors.accent500,
                    ),
                  ),
                  _SettingsItem(
                    icon: LucideIcons.volume2,
                    title: '발음 설정',
                    trailing: const Icon(
                      LucideIcons.chevronRight,
                      size: 18,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              _SettingsSection(
                title: '앱 설정',
                items: [
                  _SettingsItem(
                    icon: LucideIcons.globe,
                    title: '언어',
                    trailing: Text(
                      '한국어',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  _SettingsItem(
                    icon: LucideIcons.moon,
                    title: '다크 모드',
                    trailing: Switch(
                      value: true,
                      onChanged: (_) {},
                      activeColor: AppColors.accent500,
                    ),
                  ),
                  _SettingsItem(
                    icon: LucideIcons.download,
                    title: '오프라인 데이터',
                    trailing: const Icon(
                      LucideIcons.chevronRight,
                      size: 18,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              _SettingsSection(
                title: '지원',
                items: [
                  _SettingsItem(
                    icon: LucideIcons.helpCircle,
                    title: '도움말',
                    trailing: const Icon(
                      LucideIcons.chevronRight,
                      size: 18,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  _SettingsItem(
                    icon: LucideIcons.messageCircle,
                    title: '피드백 보내기',
                    trailing: const Icon(
                      LucideIcons.chevronRight,
                      size: 18,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  _SettingsItem(
                    icon: LucideIcons.fileText,
                    title: '이용약관',
                    trailing: const Icon(
                      LucideIcons.chevronRight,
                      size: 18,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // 버전 정보
              Text(
                'Melodic v1.0.0',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String value;
  final String label;

  const _ProfileStat({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.labelSmall,
        ),
      ],
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<_SettingsItem> items;

  const _SettingsSection({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              title,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.border,
                width: 1,
              ),
            ),
            child: Column(
              children: items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return Column(
                  children: [
                    item,
                    if (index < items.length - 1)
                      Divider(
                        height: 1,
                        color: AppColors.border,
                        indent: 56,
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyLarge,
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
