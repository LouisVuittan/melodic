import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:melodic_app/core/theme/app_colors.dart';

class StudyroomScreen extends StatefulWidget {
  const StudyroomScreen({super.key});

  @override
  State<StudyroomScreen> createState() => _StudyroomScreenState();
}

class _StudyroomScreenState extends State<StudyroomScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 헤더
            _buildHeader(context),

            // 학습 통계 카드
            Padding(
              padding: const EdgeInsets.all(20),
              child: _buildStatsCard(context),
            ),

            // 탭 바
            _buildTabBar(),

            // 탭 컨텐츠
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildVocabularyTab(),
                  _buildHistoryTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '공부방',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
          ),
          Row(
            children: [
              _buildHeaderButton(
                icon: LucideIcons.search,
                onTap: () {
                  // TODO: 검색
                },
              ),
              const SizedBox(width: 8),
              _buildHeaderButton(
                icon: LucideIcons.filter,
                onTap: () {
                  // TODO: 필터
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surfaceMedium,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: AppColors.textSecondary,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary500.withOpacity(0.15),
            AppColors.accent500.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary500.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // 상단 행
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '오늘의 학습',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        '12',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          '/ 20 단어',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // 연속 학습 뱃지
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.flame,
                      size: 18,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '5일 연속',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 진행률 바
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: 0.6,
              minHeight: 8,
              backgroundColor: AppColors.surfaceLight,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary500,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 하단 통계
          Row(
            children: [
              _buildStatItem(
                icon: LucideIcons.bookOpen,
                label: '전체 단어',
                value: '156',
              ),
              const SizedBox(width: 24),
              _buildStatItem(
                icon: LucideIcons.checkCircle,
                label: '완료',
                value: '89',
              ),
              const SizedBox(width: 24),
              _buildStatItem(
                icon: LucideIcons.refreshCw,
                label: '복습 필요',
                value: '23',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: AppColors.textTertiary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceMedium,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primary500,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textTertiary,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.all(4),
        tabs: const [
          Tab(text: '단어장'),
          Tab(text: '학습 기록'),
        ],
      ),
    );
  }

  Widget _buildVocabularyTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 10,
      itemBuilder: (context, index) {
        return _buildVocabularyCard(index);
      },
    );
  }

  Widget _buildVocabularyCard(int index) {
    final words = [
      {'word': '夢', 'reading': 'ゆめ', 'meaning': '꿈'},
      {'word': '星', 'reading': 'ほし', 'meaning': '별'},
      {'word': '空', 'reading': 'そら', 'meaning': '하늘'},
      {'word': '花', 'reading': 'はな', 'meaning': '꽃'},
      {'word': '月', 'reading': 'つき', 'meaning': '달'},
    ];

    final word = words[index % words.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderMedium.withOpacity(0.5),
        ),
      ),
      child: Row(
        children: [
          // 단어 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      word['word']!,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      word['reading']!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  word['meaning']!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),

          // 학습 상태
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: index % 3 == 0
                  ? AppColors.success.withOpacity(0.15)
                  : AppColors.surfaceMedium,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              index % 3 == 0 ? '완료' : '학습중',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: index % 3 == 0
                    ? AppColors.success
                    : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.history,
            size: 48,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            '학습 기록이 여기에 표시됩니다',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
