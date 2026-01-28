import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:ui';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/services/itunes_service.dart';
import '../../providers/app_providers.dart';
import '../../data/lyrics_data.dart';
import '../widgets/glass_card.dart';
import 'lyrics_learning_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chartAsync = ref.watch(japanTopChartProvider);
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: chartAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accent500),
        ),
        error: (error, stack) => _buildErrorState(error.toString(), ref),
        data: (tracks) => _buildContent(context, tracks, screenHeight),
      ),
    );
  }

  Widget _buildErrorState(String error, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.wifiOff, size: 48, color: AppColors.textTertiary),
            const SizedBox(height: 16),
            Text(
              '데이터를 불러올 수 없습니다',
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(error, style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () => ref.invalidate(japanTopChartProvider),
              icon: const Icon(LucideIcons.refreshCw, size: 16),
              label: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<iTunesTrack> tracks, double screenHeight) {
    final featuredTrack = tracks.isNotEmpty ? tracks.first : null;
    final heroHeight = screenHeight * 0.38;
    // 10~12위 곡을 최근 학습으로 사용
    final recentTracks = tracks.length > 12 ? tracks.sublist(9, 12) : tracks.take(3).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 오늘의 추천곡 (히어로 섹션)
          _HeroSection(track: featuredTrack, height: heroHeight),

          const SizedBox(height: 28),

          // 🎵 인기 노래
          _SectionHeader(title: '🇯🇵 인기 노래', actionText: '더보기'),
          const SizedBox(height: 16),
          _PopularSongsCarousel(tracks: tracks.take(10).toList()),

          const SizedBox(height: 36),

          // 📚 최근 학습한 노래
          _SectionHeader(title: '최근 학습', actionText: '전체보기'),
          const SizedBox(height: 16),
          _RecentLearningList(tracks: recentTracks),

          const SizedBox(height: 120),
        ],
      ),
    );
  }
}

/// 오늘의 추천곡 히어로 섹션
class _HeroSection extends StatelessWidget {
  final iTunesTrack? track;
  final double height;

  const _HeroSection({
    required this.track,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    if (track == null) return SizedBox(height: height);

    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 배경 이미지
          CachedNetworkImage(
            imageUrl: track!.albumImageUrlLarge ?? track!.albumImageUrl ?? '',
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(color: AppColors.surfaceLight),
            errorWidget: (context, url, error) => Container(
              color: AppColors.surfaceLight,
              child: const Icon(LucideIcons.music2, size: 64, color: AppColors.textTertiary),
            ),
          ),

          // 그라데이션 오버레이
          Container(
            decoration: const BoxDecoration(gradient: AppColors.heroGradient),
          ),

          // 컨텐츠
          Positioned(
            left: 20,
            right: 20,
            bottom: 28,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 오늘의 추천곡 태그
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary500.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '오늘의 추천곡 🎵',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // 제목
                Text(
                  track!.name,
                  style: AppTextStyles.headlineLarge.copyWith(fontWeight: FontWeight.w800),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),

                // 아티스트
                Text(
                  track!.artistName,
                  style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 18),

                // 버튼들
                Row(
                  children: [
                    Expanded(
                      child: AnimatedPressable(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const LyricsLearningPage(
                                songData: tutorialSongData,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.accent500,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accent500.withOpacity(0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(LucideIcons.play, color: Colors.white, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                '학습 시작',
                                style: AppTextStyles.labelLarge.copyWith(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    AnimatedPressable(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: const Icon(LucideIcons.bookmark, color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 상단 검색 버튼
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 16,
            child: GlassCard(
              padding: const EdgeInsets.all(10),
              borderRadius: 12,
              blur: 15,
              onTap: () {},
              child: const Icon(LucideIcons.search, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

/// 섹션 헤더
class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionText;
  final VoidCallback? onAction;

  const _SectionHeader({
    required this.title,
    required this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.headlineSmall),
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionText,
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.textTertiary),
            ),
          ),
        ],
      ),
    );
  }
}

/// 인기 노래 가로 스크롤 - 트렌디 버전
class _PopularSongsCarousel extends StatelessWidget {
  final List<iTunesTrack> tracks;

  const _PopularSongsCarousel({required this.tracks});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: tracks.length,
        itemBuilder: (context, index) {
          final track = tracks[index];
          return _TrendySongCard(track: track, index: index);
        },
      ),
    );
  }
}

/// 트렌디한 노래 카드
class _TrendySongCard extends StatelessWidget {
  final iTunesTrack track;
  final int index;

  const _TrendySongCard({required this.track, required this.index});

  @override
  Widget build(BuildContext context) {
    final isTop3 = index < 3;

    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 14),
      child: AnimatedPressable(
        onTap: () {},
        child: Stack(
          children: [
            // 메인 카드
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // 앨범 아트 풀사이즈
                    CachedNetworkImage(
                      imageUrl: track.albumImageUrl ?? '',
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: AppColors.surfaceLight),
                      errorWidget: (_, __, ___) => Container(
                        color: AppColors.surfaceLight,
                        child: const Icon(LucideIcons.music2, color: AppColors.textTertiary),
                      ),
                    ),

                    // 하단 그라데이션
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 100,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.8),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // 하단 정보
                    Positioned(
                      bottom: 12,
                      left: 12,
                      right: 12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            track.name,
                            style: AppTextStyles.titleSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            track.artistName,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white.withOpacity(0.8),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // 재생 버튼 오버레이
                    Positioned(
                      top: 12,
                      right: 12,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              LucideIcons.play,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 순위 배지 (Top 3만)
            if (isTop3)
              Positioned(
                top: -4,
                left: -4,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: index == 0
                          ? [const Color(0xFFFFD700), const Color(0xFFFFA500)]
                          : index == 1
                          ? [const Color(0xFFC0C0C0), const Color(0xFF808080)]
                          : [const Color(0xFFCD7F32), const Color(0xFF8B4513)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
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
}

/// 최근 학습 리스트 - 트렌디 버전
class _RecentLearningList extends StatelessWidget {
  final List<iTunesTrack> tracks;

  const _RecentLearningList({required this.tracks});

  @override
  Widget build(BuildContext context) {
    if (tracks.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Icon(LucideIcons.music2, size: 40, color: AppColors.textTertiary),
              const SizedBox(height: 12),
              Text('아직 학습한 노래가 없어요', style: AppTextStyles.bodyMedium),
              const SizedBox(height: 4),
              Text('위에서 노래를 선택해 학습을 시작하세요!', style: AppTextStyles.bodySmall),
            ],
          ),
        ),
      );
    }

    // 목 진행률 데이터
    final progressList = [0.75, 0.45, 0.90];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: tracks.asMap().entries.map((entry) {
          final index = entry.key;
          final track = entry.value;
          final progress = progressList[index % progressList.length];
          return _TrendyLearningCard(track: track, progress: progress);
        }).toList(),
      ),
    );
  }
}

/// 트렌디한 학습 카드
class _TrendyLearningCard extends StatelessWidget {
  final iTunesTrack track;
  final double progress;

  const _TrendyLearningCard({required this.track, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: AnimatedPressable(
        onTap: () {},
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.surface,
                AppColors.surface.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border.withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              children: [
                // 진행률 배경
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9 * progress,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.accent500.withOpacity(0.15),
                          AppColors.accent500.withOpacity(0.05),
                        ],
                      ),
                    ),
                  ),
                ),

                // 컨텐츠
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      // 앨범 아트
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: track.albumImageUrl ?? '',
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              width: 56,
                              height: 56,
                              color: AppColors.surfaceLight,
                            ),
                            errorWidget: (_, __, ___) => Container(
                              width: 56,
                              height: 56,
                              color: AppColors.surfaceLight,
                              child: const Icon(
                                LucideIcons.music2,
                                size: 24,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // 노래 정보
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              track.name,
                              style: AppTextStyles.titleSmall.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              track.artistName,
                              style: AppTextStyles.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // 진행률 원형
                      Container(
                        width: 48,
                        height: 48,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 3,
                              backgroundColor: AppColors.border,
                              valueColor: const AlwaysStoppedAnimation(AppColors.accent500),
                            ),
                            Center(
                              child: Text(
                                '${(progress * 100).toInt()}%',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.accent500,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),

                      // 재생 버튼
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.accent500,
                              AppColors.accent600,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent500.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          LucideIcons.play,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}