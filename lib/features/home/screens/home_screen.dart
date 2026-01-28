import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:melodic_app/core/theme/app_colors.dart';
import 'package:melodic_app/core/constants/app_constants.dart';
import 'package:melodic_app/features/home/widgets/featured_song_card.dart';
import 'package:melodic_app/features/home/widgets/popular_songs_section.dart';
import 'package:melodic_app/features/home/widgets/recent_learning_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            // 커스텀 앱바
            SliverToBoxAdapter(
              child: _buildHeader(context),
            ),

            // 오늘의 추천곡 (풀 카드)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: _buildSectionTitle(context, '오늘의 추천곡', emoji: '🎶'),
              ),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: FeaturedSongCard(),
              ),
            ),

            // 인기 노래
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
                child: _buildSectionHeader(
                  context,
                  '인기 노래',
                  onMoreTap: () {
                    // TODO: 더보기 페이지로 이동
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: PopularSongsSection(),
            ),

            // 최근 학습
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
                child: _buildSectionHeader(
                  context,
                  '최근 학습',
                  onMoreTap: () {
                    context.go('/studyroom');
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: RecentLearningSection(),
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 로고 & 타이틀
          Row(
            children: [
              // 로고 이미지 (또는 아이콘)
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  LucideIcons.music2,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              ShaderMask(
                shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
                child: const Text(
                  'Melodic',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          // 검색 버튼
          GestureDetector(
            onTap: () {
              // TODO: 검색 화면으로 이동
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceMedium,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                LucideIcons.search,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, {String? emoji}) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
        ),
        if (emoji != null) ...[
          const SizedBox(width: 8),
          Text(
            emoji,
            style: const TextStyle(fontSize: 20),
          ),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title, {
    VoidCallback? onMoreTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
        ),
        if (onMoreTap != null)
          GestureDetector(
            onTap: onMoreTap,
            child: Text(
              '더보기',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textTertiary,
                  ),
            ),
          ),
      ],
    );
  }
}
