import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/theme.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = true;
  String _selectedLanguage = '일본어';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 상단 헤더
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Text(
                  '설정',
                  style: AppTextStyles.headlineLarge,
                ),
              ),
            ),

            // 프로필 카드
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.gray900,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.gray800,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // 프로필 이미지
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Center(
                          child: Text(
                            '밍',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
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
                            Text(
                              '밍밍이',
                              style: AppTextStyles.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.accent500.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Premium',
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: AppColors.accent500,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // 편집 버튼
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          LucideIcons.pencil,
                          color: AppColors.gray400,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 설정 섹션들
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 12),
                child: Text(
                  '학습 설정',
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.gray400,
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildSettingsGroup([
                  _SettingsTile(
                    icon: LucideIcons.globe,
                    title: '학습 언어',
                    trailing: Text(
                      _selectedLanguage,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.accent500,
                      ),
                    ),
                    onTap: () => _showLanguageSelector(),
                  ),
                  _SettingsTile(
                    icon: LucideIcons.target,
                    title: '일일 목표',
                    trailing: Text(
                      '10분',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.gray400,
                      ),
                    ),
                    onTap: () {},
                  ),
                  _SettingsTile(
                    icon: LucideIcons.bell,
                    title: '학습 알림',
                    trailing: Switch(
                      value: _notificationsEnabled,
                      onChanged: (value) {
                        setState(() => _notificationsEnabled = value);
                      },
                    ),
                  ),
                ]),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Text(
                  '앱 설정',
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.gray400,
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildSettingsGroup([
                  _SettingsTile(
                    icon: LucideIcons.moon,
                    title: '다크 모드',
                    trailing: Switch(
                      value: _darkModeEnabled,
                      onChanged: (value) {
                        setState(() => _darkModeEnabled = value);
                      },
                    ),
                  ),
                  _SettingsTile(
                    icon: LucideIcons.download,
                    title: '오프라인 데이터',
                    onTap: () {},
                  ),
                  _SettingsTile(
                    icon: LucideIcons.trash2,
                    title: '캐시 삭제',
                    onTap: () {},
                  ),
                ]),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Text(
                  '지원',
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.gray400,
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildSettingsGroup([
                  _SettingsTile(
                    icon: LucideIcons.helpCircle,
                    title: '도움말',
                    onTap: () {},
                  ),
                  _SettingsTile(
                    icon: LucideIcons.messageCircle,
                    title: '문의하기',
                    onTap: () {},
                  ),
                  _SettingsTile(
                    icon: LucideIcons.fileText,
                    title: '이용약관',
                    onTap: () {},
                  ),
                  _SettingsTile(
                    icon: LucideIcons.shield,
                    title: '개인정보 처리방침',
                    onTap: () {},
                  ),
                ]),
              ),
            ),

            // 버전 정보
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 100),
                child: Center(
                  child: Text(
                    'Melodic v1.0.0',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.gray500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<_SettingsTile> tiles) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.gray900,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.gray800,
          width: 1,
        ),
      ),
      child: Column(
        children: tiles.asMap().entries.map((entry) {
          final index = entry.key;
          final tile = entry.value;
          return Column(
            children: [
              tile,
              if (index < tiles.length - 1)
                Divider(
                  height: 1,
                  color: AppColors.gray800,
                  indent: 56,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '학습 언어 선택',
                  style: AppTextStyles.titleLarge,
                ),
                const SizedBox(height: 20),
                _buildLanguageOption('일본어', '🇯🇵'),
                _buildLanguageOption('영어', '🇺🇸'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(String language, String flag) {
    final isSelected = _selectedLanguage == language;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedLanguage = language);
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent500.withOpacity(0.1)
              : AppColors.gray800,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.accent500 : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Text(
              language,
              style: AppTextStyles.bodyLarge.copyWith(
                color: isSelected ? AppColors.accent500 : AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(
                LucideIcons.check,
                color: AppColors.accent500,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
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
            Icon(
              icon,
              color: AppColors.gray400,
              size: 20,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyLarge,
              ),
            ),
            if (trailing != null) trailing!,
            if (trailing == null)
              const Icon(
                LucideIcons.chevronRight,
                color: AppColors.gray500,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }
}
