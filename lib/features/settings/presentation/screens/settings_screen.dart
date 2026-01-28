import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';

/// 설정 화면
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 헤더
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                '설정',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 프로필 섹션
            _ProfileSection(),
            const SizedBox(height: 24),

            // 학습 설정
            _SettingsSection(
              title: '학습 설정',
              items: [
                _SettingsItem(
                  icon: LucideIcons.globe,
                  title: '학습 언어',
                  subtitle: '영어, 일본어',
                  onTap: () {
                    // TODO: 언어 설정
                  },
                ),
                _SettingsItem(
                  icon: LucideIcons.graduationCap,
                  title: '난이도',
                  subtitle: '중급',
                  onTap: () {},
                ),
                _SettingsItem(
                  icon: LucideIcons.bell,
                  title: '학습 리마인더',
                  trailing: Switch(
                    value: true,
                    onChanged: (value) {},
                    activeColor: AppColors.accent500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 앱 설정
            _SettingsSection(
              title: '앱 설정',
              items: [
                _SettingsItem(
                  icon: LucideIcons.moon,
                  title: '다크 모드',
                  trailing: Switch(
                    value: true,
                    onChanged: (value) {},
                    activeColor: AppColors.accent500,
                  ),
                ),
                _SettingsItem(
                  icon: LucideIcons.volume2,
                  title: '자동 재생',
                  subtitle: '가사 페이지에서 자동 재생',
                  trailing: Switch(
                    value: false,
                    onChanged: (value) {},
                    activeColor: AppColors.accent500,
                  ),
                ),
                _SettingsItem(
                  icon: LucideIcons.text,
                  title: '자막 설정',
                  subtitle: '번역 자막 표시',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 계정
            _SettingsSection(
              title: '계정',
              items: [
                _SettingsItem(
                  icon: LucideIcons.crown,
                  title: '프리미엄 업그레이드',
                  subtitle: '광고 제거 및 무제한 학습',
                  onTap: () {},
                  showBadge: true,
                ),
                _SettingsItem(
                  icon: LucideIcons.download,
                  title: '데이터 백업',
                  subtitle: '학습 데이터 내보내기',
                  onTap: () {},
                ),
                _SettingsItem(
                  icon: LucideIcons.logOut,
                  title: '로그아웃',
                  onTap: () {},
                  isDestructive: true,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 정보
            _SettingsSection(
              title: '정보',
              items: [
                _SettingsItem(
                  icon: LucideIcons.helpCircle,
                  title: '튜토리얼',
                  onTap: () {
                    // TODO: 온보딩 페이지로 이동
                  },
                ),
                _SettingsItem(
                  icon: LucideIcons.messageSquare,
                  title: '피드백 보내기',
                  onTap: () {},
                ),
                _SettingsItem(
                  icon: LucideIcons.shield,
                  title: '개인정보 처리방침',
                  onTap: () {},
                ),
                _SettingsItem(
                  icon: LucideIcons.fileText,
                  title: '이용약관',
                  onTap: () {},
                ),
                _SettingsItem(
                  icon: LucideIcons.info,
                  title: '앱 버전',
                  subtitle: 'v1.0.0',
                ),
              ],
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // 프로필 이미지
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.surfaceVariant,
            child: const Icon(
              LucideIcons.user,
              size: 32,
              color: AppColors.gray400,
            ),
          ),
          const SizedBox(width: 16),

          // 사용자 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '밍밍이',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'user@example.com',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // 편집 버튼
          IconButton(
            onPressed: () {
              // TODO: 프로필 편집
            },
            icon: const Icon(
              LucideIcons.edit2,
              color: AppColors.gray400,
              size: 20,
            ),
          ),
        ],
      ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final isLast = entry.key == items.length - 1;
              return Column(
                children: [
                  entry.value,
                  if (!isLast)
                    const Divider(
                      height: 1,
                      indent: 56,
                      color: AppColors.border,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showBadge;
  final bool isDestructive;

  const _SettingsItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.showBadge = false,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // 아이콘
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDestructive
                    ? AppColors.error.withOpacity(0.1)
                    : showBadge
                        ? AppColors.warning.withOpacity(0.1)
                        : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 18,
                color: isDestructive
                    ? AppColors.error
                    : showBadge
                        ? AppColors.warning
                        : AppColors.gray400,
              ),
            ),
            const SizedBox(width: 14),

            // 타이틀
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: isDestructive
                              ? AppColors.error
                              : AppColors.textPrimary,
                        ),
                      ),
                      if (showBadge) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warning,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'PRO',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // 트레일링
            if (trailing != null)
              trailing!
            else if (onTap != null)
              const Icon(
                LucideIcons.chevronRight,
                size: 20,
                color: AppColors.gray500,
              ),
          ],
        ),
      ),
    );
  }
}
