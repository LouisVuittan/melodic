import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/theme.dart';

class SongGrid extends StatelessWidget {
  const SongGrid({super.key});

  @override
  Widget build(BuildContext context) {
    // 샘플 데이터 - 나중에 실제 데이터로 교체
    final songs = [
      {
        'title': '夜に駆ける',
        'artist': 'YOASOBI',
        'language': 'JP',
      },
      {
        'title': 'Blinding Lights',
        'artist': 'The Weeknd',
        'language': 'EN',
      },
      {
        'title': 'Lemon',
        'artist': '米津玄師',
        'language': 'JP',
      },
      {
        'title': 'Shape of You',
        'artist': 'Ed Sheeran',
        'language': 'EN',
      },
      {
        'title': 'ドライフラワー',
        'artist': '優里',
        'language': 'JP',
      },
      {
        'title': 'Bad Guy',
        'artist': 'Billie Eilish',
        'language': 'EN',
      },
    ];

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final song = songs[index];
          return _SongGridItem(
            title: song['title']!,
            artist: song['artist']!,
            language: song['language']!,
            onTap: () {
              // TODO: 가사 학습 페이지로 이동
            },
          );
        },
        childCount: songs.length,
      ),
    );
  }
}

class _SongGridItem extends StatelessWidget {
  final String title;
  final String artist;
  final String language;
  final VoidCallback? onTap;

  const _SongGridItem({
    required this.title,
    required this.artist,
    required this.language,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.gray900,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.gray800,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 앨범 아트 영역
            Expanded(
              child: Stack(
                children: [
                  // 앨범 아트 플레이스홀더
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.gray800,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary500.withOpacity(0.2),
                          AppColors.accent500.withOpacity(0.2),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        LucideIcons.music2,
                        color: AppColors.gray500,
                        size: 36,
                      ),
                    ),
                  ),
                  // 언어 태그
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: language == 'JP'
                            ? AppColors.error.withOpacity(0.9)
                            : AppColors.info.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        language,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  // 호버 시 재생 버튼 오버레이
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.3),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 노래 정보
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    artist,
                    style: AppTextStyles.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
