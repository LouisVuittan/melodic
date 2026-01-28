import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:melodic_app/core/theme/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            // 헤더
            SliverToBoxAdapter(
              child: _buildHeader(context),
            ),

            // 프로필 섹션
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: _buildProfileSection(context),
              ),
            ),

            // 구독 섹션
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildSubscriptionCard(context),
              ),
            ),

            // 설정 그룹들
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: _buildSettingsGroups(context),
              ),
            ),

            // 하단 여백
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Text(
        '설정',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.borderMedium.withOpacity(0.5),
        ),
      ),
      child: Row(
        children: [
          // 프로필 이미지
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                '밍',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // 사용자 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '밍밍이',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'mingming@example.com',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // 편집 버튼
          GestureDetector(
            onTap: () {
              // TODO: 프로필 편집
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceMedium,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                LucideIcons.pencil,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accent500.withOpacity(0.2),
            AppColors.primary500.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.accent500.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          // 아이콘
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.accent500.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              LucideIcons.crown,
              color: AppColors.accent400,
              size: 24,
            ),
          ),

          const SizedBox(width: 16),

          // 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '무료 플랜',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '프리미엄으로 모든 기능을 사용해보세요',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // 업그레이드 버튼
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              gradient: AppColors.accentGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '업그레이드',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsGroups(BuildContext context) {
    return Column(
      children: [
        // 학습 설정
        _buildSettingsGroup(
          title: '학습 설정',
          items: [
            _SettingsItem(
              icon: LucideIcons.languages,
              title: '학습 언어',
              subtitle: '일본어, 영어',
              onTap: () {},
            ),
            _SettingsItem(
              icon: LucideIcons.target,
              title: '일일 학습 목표',
              subtitle: '20 단어',
              onTap: () {},
            ),
            _SettingsItem(
              icon: LucideIcons.bellRing,
              title: '학습 알림',
              subtitle: '매일 오후 8시',
              onTap: () {},
            ),
          ],
        ),

        const SizedBox(height: 24),

        // 앱 설정
        _buildSettingsGroup(
          title: '앱 설정',
          items: [
            _SettingsItem(
              icon: LucideIcons.palette,
              title: '테마',
              subtitle: '다크 모드',
              onTap: () {},
            ),
            _SettingsItem(
              icon: LucideIcons.globe,
              title: '앱 언어',
              subtitle: '한국어',
              onTap: () {},
            ),
            _SettingsItem(
              icon: LucideIcons.download,
              title: '오프라인 데이터',
              subtitle: '관리',
              onTap: () {},
            ),
          ],
        ),

        const SizedBox(height: 24),

        // 기타
        _buildSettingsGroup(
          title: '기타',
          items: [
            _SettingsItem(
              icon: LucideIcons.helpCircle,
              title: '도움말',
              onTap: () {},
            ),
            _SettingsItem(
              icon: LucideIcons.messageCircle,
              title: '피드백 보내기',
              onTap: () {},
            ),
            _SettingsItem(
              icon: LucideIcons.fileText,
              title: '이용약관',
              onTap: () {},
            ),
            _SettingsItem(
              icon: LucideIcons.shield,
              title: '개인정보처리방침',
              onTap: () {},
            ),
          ],
        ),

        const SizedBox(height: 24),

        // 로그아웃
        GestureDetector(
          onTap: () {
            // TODO: 로그아웃
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.error.withOpacity(0.2),
              ),
            ),
            child: const Center(
              child: Text(
                '로그아웃',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // 버전 정보
        Text(
          'Melodic v1.0.0',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsGroup({
    required String title,
    required List<_SettingsItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textTertiary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.borderMedium.withOpacity(0.5),
            ),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  _buildSettingsItemWidget(item),
                  if (index < items.length - 1)
                    Divider(
                      height: 1,
                      indent: 56,
                      color: AppColors.borderMedium.withOpacity(0.5),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsItemWidget(_SettingsItem item) {
    return GestureDetector(
      onTap: item.onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.surfaceMedium,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                item.icon,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                item.title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (item.subtitle != null) ...[
              Text(
                item.subtitle!,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(width: 8),
            ],
            const Icon(
              LucideIcons.chevronRight,
              size: 18,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  _SettingsItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });
}
