import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:melodic_app/core/theme/app_colors.dart';

class PopularSongsSection extends StatelessWidget {
  const PopularSongsSection({super.key});

  @override
  Widget build(BuildContext context) {
    // 임시 데이터
    final songs = [
      _SongData(
        id: 'pretender',
        title: 'Pretender',
        artist: 'Official髭男dism',
        albumCover: 'https://i.scdn.co/image/ab67616d0000b273c0e7bf5cdd630f314f20586a',
        language: '일본어',
      ),
      _SongData(
        id: 'shape_of_you',
        title: 'Shape of You',
        artist: 'Ed Sheeran',
        albumCover: 'https://i.scdn.co/image/ab67616d0000b273ba5db46f4b838ef6027e6f96',
        language: '영어',
      ),
      _SongData(
        id: 'lemon',
        title: 'Lemon',
        artist: '米津玄師',
        albumCover: 'https://i.scdn.co/image/ab67616d0000b2734e3be2fb8e0a4b7cc4e83c35',
        language: '일본어',
      ),
      _SongData(
        id: 'blinding_lights',
        title: 'Blinding Lights',
        artist: 'The Weeknd',
        albumCover: 'https://i.scdn.co/image/ab67616d0000b2738863bc11d2aa12b54f5aeb36',
        language: '영어',
      ),
      _SongData(
        id: 'dry_flower',
        title: 'ドライフラワー',
        artist: '優里',
        albumCover: 'https://i.scdn.co/image/ab67616d0000b273c5ad390e5e92f0c0c88bacd4',
        language: '일본어',
      ),
    ];

    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: songs.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final song = songs[index];
          return _SongCard(song: song);
        },
      ),
    );
  }
}

class _SongCard extends StatelessWidget {
  final _SongData song;

  const _SongCard({required this.song});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push(
          '/lyrics/${song.id}?title=${Uri.encodeComponent(song.title)}&artist=${Uri.encodeComponent(song.artist)}',
        );
      },
      child: SizedBox(
        width: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 앨범 커버
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  // 앨범 이미지
                  CachedNetworkImage(
                    imageUrl: song.albumCover,
                    fit: BoxFit.cover,
                    width: 140,
                    height: 140,
                    placeholder: (context, url) => Container(
                      color: AppColors.surfaceMedium,
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary500,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.surfaceMedium,
                      child: const Icon(
                        LucideIcons.music,
                        color: AppColors.textTertiary,
                        size: 32,
                      ),
                    ),
                  ),

                  // 언어 뱃지
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        song.language,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  // 호버/탭 오버레이
                  Positioned.fill(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          context.push(
                            '/lyrics/${song.id}?title=${Uri.encodeComponent(song.title)}&artist=${Uri.encodeComponent(song.artist)}',
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 곡 제목
            Text(
              song.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 2),

            // 아티스트
            Text(
              song.artist,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _SongData {
  final String id;
  final String title;
  final String artist;
  final String albumCover;
  final String language;

  _SongData({
    required this.id,
    required this.title,
    required this.artist,
    required this.albumCover,
    required this.language,
  });
}
