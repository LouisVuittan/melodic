import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:melodic_app/core/theme/app_colors.dart';

class RecentLearningSection extends StatelessWidget {
  const RecentLearningSection({super.key});

  @override
  Widget build(BuildContext context) {
    // 임시 데이터
    final recentItems = [
      _RecentItem(
        id: 'betelgeuse_yuuri',
        title: 'ベテルギウス',
        artist: '優里',
        albumCover: 'https://i.scdn.co/image/ab67616d0000b27347d84e78824f8c08344a7fb4',
        progress: 0.75,
        lastStudied: '2시간 전',
        wordsLearned: 24,
      ),
      _RecentItem(
        id: 'pretender',
        title: 'Pretender',
        artist: 'Official髭男dism',
        albumCover: 'https://i.scdn.co/image/ab67616d0000b273c0e7bf5cdd630f314f20586a',
        progress: 0.45,
        lastStudied: '어제',
        wordsLearned: 18,
      ),
      _RecentItem(
        id: 'shape_of_you',
        title: 'Shape of You',
        artist: 'Ed Sheeran',
        albumCover: 'https://i.scdn.co/image/ab67616d0000b273ba5db46f4b838ef6027e6f96',
        progress: 0.30,
        lastStudied: '3일 전',
        wordsLearned: 12,
      ),
    ];

    if (recentItems.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      children: recentItems
          .map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _RecentLearningCard(item: item),
              ))
          .toList(),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.surfaceMedium,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              LucideIcons.bookOpen,
              color: AppColors.textTertiary,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '아직 학습 기록이 없어요',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '좋아하는 노래로 학습을 시작해보세요!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textTertiary,
                ),
          ),
        ],
      ),
    );
  }
}

class _RecentLearningCard extends StatelessWidget {
  final _RecentItem item;

  const _RecentLearningCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push(
          '/lyrics/${item.id}?title=${Uri.encodeComponent(item.title)}&artist=${Uri.encodeComponent(item.artist)}',
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.borderMedium.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // 앨범 커버
            Container(
              width: 64,
              height: 64,
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
              clipBehavior: Clip.antiAlias,
              child: CachedNetworkImage(
                imageUrl: item.albumCover,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppColors.surfaceMedium,
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.surfaceMedium,
                  child: const Icon(
                    LucideIcons.music,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 14),

            // 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목 & 아티스트
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.artist,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 10),

                  // 진행률 바
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: item.progress,
                            minHeight: 5,
                            backgroundColor: AppColors.surfaceLight,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getProgressColor(item.progress),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${(item.progress * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getProgressColor(item.progress),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // 우측 정보
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.lastStudied,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary500.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        LucideIcons.bookOpen,
                        size: 12,
                        color: AppColors.primary400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${item.wordsLearned}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 0.8) return AppColors.success;
    if (progress >= 0.5) return AppColors.primary500;
    if (progress >= 0.3) return AppColors.warning;
    return AppColors.textTertiary;
  }
}

class _RecentItem {
  final String id;
  final String title;
  final String artist;
  final String albumCover;
  final double progress;
  final String lastStudied;
  final int wordsLearned;

  _RecentItem({
    required this.id,
    required this.title,
    required this.artist,
    required this.albumCover,
    required this.progress,
    required this.lastStudied,
    required this.wordsLearned,
  });
}
