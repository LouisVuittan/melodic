import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/theme.dart';
import '../widgets/featured_song_card.dart';
import '../widgets/song_grid.dart';
import '../widgets/category_chips.dart';
import '../widgets/section_header.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selectedCategory = '전체';

  final List<String> _categories = [
    '전체',
    'J-Pop',
    'Pop',
    'R&B',
    '발라드',
    '인디',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 상단 앱바
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 로고
                    ShaderMask(
                      shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
                      child: Text(
                        'Melodic',
                        style: AppTextStyles.headlineLarge.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // 검색 아이콘
                    GestureDetector(
                      onTap: () {
                        // TODO: 검색 페이지로 이동
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.gray800,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          LucideIcons.search,
                          color: AppColors.textPrimary,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 오늘의 추천곡 섹션
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: AppColors.accentGradient,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                LucideIcons.sparkles,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '오늘의 추천',
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const FeaturedSongCard(
                      title: 'ベテルギウス',
                      artist: '優里 (Yuuri)',
                      albumArt: 'https://i.scdn.co/image/ab67616d0000b273c5716278abba6a103ad13aa7',
                      language: '일본어',
                    ),
                  ],
                ),
              ),
            ),

            // 카테고리 칩
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: CategoryChips(
                  categories: _categories,
                  selectedCategory: _selectedCategory,
                  onCategorySelected: (category) {
                    setState(() => _selectedCategory = category);
                  },
                ),
              ),
            ),

            // 인기 노래 섹션 헤더
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: SectionHeader(
                  title: '인기 노래',
                  onMoreTap: () {
                    // TODO: 더보기 페이지
                  },
                ),
              ),
            ),

            // 인기 노래 그리드
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: const SongGrid(),
            ),

            // 최근 학습 섹션 헤더
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 12),
                child: SectionHeader(
                  title: '최근 학습',
                  onMoreTap: () {
                    // TODO: 전체보기 페이지
                  },
                ),
              ),
            ),

            // 최근 학습 리스트
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return _buildRecentLearningItem(index);
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

  Widget _buildRecentLearningItem(int index) {
    final songs = [
      {'title': 'Lemon', 'artist': '米津玄師', 'progress': 0.75},
      {'title': 'Shape of You', 'artist': 'Ed Sheeran', 'progress': 0.45},
      {'title': '夜に駆ける', 'artist': 'YOASOBI', 'progress': 0.90},
      {'title': 'Blinding Lights', 'artist': 'The Weeknd', 'progress': 0.30},
      {'title': 'ドライフラワー', 'artist': '優里', 'progress': 0.60},
    ];

    final song = songs[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
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
          // 앨범 아트 플레이스홀더
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.gray800,
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  AppColors.primary500.withOpacity(0.3),
                  AppColors.accent500.withOpacity(0.3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(
              LucideIcons.music2,
              color: AppColors.gray400,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          // 노래 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song['title'] as String,
                  style: AppTextStyles.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  song['artist'] as String,
                  style: AppTextStyles.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // 진행률 바
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: song['progress'] as double,
                    backgroundColor: AppColors.gray700,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.accent500,
                    ),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // 재생 버튼
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.accent500,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              LucideIcons.play,
              color: Colors.white,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}
