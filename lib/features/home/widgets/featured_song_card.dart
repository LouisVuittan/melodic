import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:melodic_app/core/theme/app_colors.dart';

class FeaturedSongCard extends StatelessWidget {
  const FeaturedSongCard({super.key});

  @override
  Widget build(BuildContext context) {
    // 임시 데이터 (나중에 Provider로 대체)
    const song = _MockSong(
      id: 'betelgeuse_yuuri',
      title: 'ベテルギウス',
      artist: '優里 (Yuuri)',
      albumCover: 'https://i.scdn.co/image/ab67616d0000b27347d84e78824f8c08344a7fb4',
      language: '일본어',
    );

    return GestureDetector(
      onTap: () {
        context.push(
          '/lyrics/${song.id}?title=${Uri.encodeComponent(song.title)}&artist=${Uri.encodeComponent(song.artist)}',
        );
      },
      child: Container(
        height: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary500.withOpacity(0.15),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 배경 이미지
            CachedNetworkImage(
              imageUrl: song.albumCover,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: AppColors.surfaceMedium,
              ),
              errorWidget: (context, url, error) => Container(
                color: AppColors.surfaceMedium,
                child: const Icon(
                  LucideIcons.music,
                  color: AppColors.textTertiary,
                  size: 48,
                ),
              ),
            ),

            // 어두운 그라데이션 오버레이
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Color(0x40000000),
                    Color(0xE0000000),
                  ],
                  stops: [0.0, 0.4, 1.0],
                ),
              ),
            ),

            // 블러 효과가 적용된 하단 영역
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ClipRRect(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // 텍스트 정보
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 언어 태그
                            _buildLanguageTag(song.language),
                            const SizedBox(height: 12),

                            // 곡 제목
                            Text(
                              song.title,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.2,
                                letterSpacing: -0.5,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),

                            // 아티스트
                            Text(
                              song.artist,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 플레이 버튼
                      _buildPlayButton(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageTag(String language) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary500,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '#$language',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            LucideIcons.chevronRight,
            size: 14,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildPlayButton() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary500.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(
        LucideIcons.play,
        color: Colors.white,
        size: 24,
      ),
    );
  }
}

/// 임시 목 데이터 클래스
class _MockSong {
  final String id;
  final String title;
  final String artist;
  final String albumCover;
  final String language;

  const _MockSong({
    required this.id,
    required this.title,
    required this.artist,
    required this.albumCover,
    required this.language,
  });
}
