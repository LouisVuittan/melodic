import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/theme.dart';

class StudyroomPage extends StatelessWidget {
  const StudyroomPage({super.key});

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '공부방',
                      style: AppTextStyles.headlineLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '나만의 단어장으로 복습해보세요',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.gray400,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 학습 통계 카드
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary500.withOpacity(0.15),
                        AppColors.accent500.withOpacity(0.15),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.gray700,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      _buildStatItem(
                        icon: LucideIcons.flame,
                        value: '7',
                        label: '연속 학습',
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 24),
                      _buildStatItem(
                        icon: LucideIcons.bookOpen,
                        value: '128',
                        label: '학습한 단어',
                        color: AppColors.accent500,
                      ),
                      const SizedBox(width: 24),
                      _buildStatItem(
                        icon: LucideIcons.checkCircle,
                        value: '85%',
                        label: '정답률',
                        color: AppColors.success,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 학습 메뉴 그리드
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                delegate: SliverChildListDelegate([
                  _buildMenuCard(
                    icon: LucideIcons.bookMarked,
                    title: '단어장',
                    subtitle: '저장한 단어 복습',
                    color: AppColors.primary500,
                    onTap: () {},
                  ),
                  _buildMenuCard(
                    icon: LucideIcons.brain,
                    title: '퀴즈',
                    subtitle: '단어 퀴즈 풀기',
                    color: AppColors.accent500,
                    onTap: () {},
                  ),
                  _buildMenuCard(
                    icon: LucideIcons.messageSquare,
                    title: '문장 연습',
                    subtitle: '문장 만들기 연습',
                    color: AppColors.success,
                    onTap: () {},
                  ),
                  _buildMenuCard(
                    icon: LucideIcons.barChart2,
                    title: '학습 분석',
                    subtitle: '내 학습 통계',
                    color: AppColors.warning,
                    onTap: () {},
                  ),
                ]),
              ),
            ),

            // 오늘의 복습 단어 섹션
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '오늘의 복습 단어',
                      style: AppTextStyles.titleLarge,
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        '전체보기',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.accent500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 단어 리스트
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final words = [
                      {'word': '夜', 'reading': 'よる', 'meaning': '밤'},
                      {'word': '走る', 'reading': 'はしる', 'meaning': '달리다'},
                      {'word': '空', 'reading': 'そら', 'meaning': '하늘'},
                      {'word': '光', 'reading': 'ひかり', 'meaning': '빛'},
                      {'word': '心', 'reading': 'こころ', 'meaning': '마음'},
                    ];
                    final word = words[index];
                    return _buildWordItem(word);
                  },
                  childCount: 5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.headlineMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.gray400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.gray900,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.gray800,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const Spacer(),
            Text(
              title,
              style: AppTextStyles.titleMedium,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWordItem(Map<String, String> word) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.gray900,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.gray800,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      word['word']!,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      word['reading']!,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.accent400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  word['meaning']!,
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          Icon(
            LucideIcons.volume2,
            color: AppColors.gray400,
            size: 20,
          ),
        ],
      ),
    );
  }
}
