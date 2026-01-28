import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';

/// 최근 학습 노래 모델
class RecentSong {
  final String id;
  final String title;
  final String artist;
  final String? coverUrl;
  final bool isFavorite;
  final DateTime? learnedDate;
  final int progress; // 0-100

  RecentSong({
    required this.id,
    required this.title,
    required this.artist,
    this.coverUrl,
    this.isFavorite = false,
    this.learnedDate,
    this.progress = 0,
  });
}

/// 최근 학습 섹션
class RecentLearningSection extends StatelessWidget {
  final ValueChanged<RecentSong>? onSongTap;

  const RecentLearningSection({
    super.key,
    this.onSongTap,
  });

  // TODO: 실제 데이터 연동
  List<RecentSong> get _recentSongs => [
    RecentSong(
      id: '1',
      title: 'Perfect',
      artist: 'Ed Sheeran',
      progress: 75,
      isFavorite: true,
      learnedDate: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    RecentSong(
      id: '2',
      title: 'Lemon',
      artist: '米津玄師',
      progress: 30,
      learnedDate: DateTime.now().subtract(const Duration(days: 1)),
    ),
    RecentSong(
      id: '3',
      title: 'Stay With Me',
      artist: '真夜中のドア',
      progress: 100,
      isFavorite: true,
      learnedDate: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final songs = _recentSongs;

    if (songs.isEmpty) {
      return _EmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 섹션 헤더
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '최근 학습',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: 전체 보기
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    '전체보기',
                    style: TextStyle(
                      color: AppColors.accent400,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    LucideIcons.chevronRight,
                    size: 16,
                    color: AppColors.accent400,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 노래 리스트
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: songs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return _RecentSongCard(
              song: songs[index],
              onTap: () => onSongTap?.call(songs[index]),
            );
          },
        ),
      ],
    );
  }
}

class _RecentSongCard extends StatelessWidget {
  final RecentSong song;
  final VoidCallback? onTap;

  const _RecentSongCard({
    required this.song,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // 앨범 커버
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                gradient: song.coverUrl == null ? AppColors.accentGradient : null,
              ),
              child: song.coverUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        song.coverUrl!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Icon(
                      LucideIcons.music,
                      color: Colors.white,
                      size: 24,
                    ),
            ),
            const SizedBox(width: 14),

            // 노래 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          song.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (song.isFavorite)
                        const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Icon(
                            LucideIcons.heart,
                            size: 16,
                            color: AppColors.error,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    song.artist,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // 진행률 바
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: song.progress / 100,
                            backgroundColor: AppColors.surfaceVariant,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              song.progress == 100
                                  ? AppColors.success
                                  : AppColors.accent500,
                            ),
                            minHeight: 4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${song.progress}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: song.progress == 100
                              ? AppColors.success
                              : AppColors.accent400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),
            const Icon(
              LucideIcons.play,
              size: 24,
              color: AppColors.accent500,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              LucideIcons.music2,
              size: 32,
              color: AppColors.gray500,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '아직 학습한 노래가 없어요',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '좋아하는 노래를 검색해서\n가사로 언어를 배워보세요!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
