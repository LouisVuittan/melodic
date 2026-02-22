import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:ui';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/services/itunes_service.dart';
import '../../providers/app_providers.dart';
import 'track_learning_page.dart';
import '../../providers/app_providers.dart'; // artistImageProvider 사용
/// 아티스트 상세 정보 Provider
final artistDetailProvider = FutureProvider.family<_ArtistDetailData, int>((ref, artistId) async {
  final service = ref.read(iTunesServiceProvider);

  // 아티스트의 곡 검색 (lookup API 사용)
  final tracks = await service.getArtistTracks(artistId: artistId, limit: 30);

  // 앨범 추출 (중복 제거)
  final albumMap = <int, iTunesTrack>{};
  for (final track in tracks) {
    if (!albumMap.containsKey(track.albumId)) {
      albumMap[track.albumId] = track;
    }
  }

  return _ArtistDetailData(
    tracks: tracks,
    albums: albumMap.values.toList(),
    totalTracks: tracks.length,
  );
});

/// 즐겨찾기 아티스트 Provider
final favoriteArtistsProvider = StateProvider<Set<int>>((ref) => {});

class _ArtistDetailData {
  final List<iTunesTrack> tracks;
  final List<iTunesTrack> albums;
  final int totalTracks;

  _ArtistDetailData({
    required this.tracks,
    required this.albums,
    required this.totalTracks,
  });
}

class ArtistPage extends ConsumerWidget {
  final int artistId;
  final String artistName;
  final String? artistImageUrl;

  const ArtistPage({
    super.key,
    required this.artistId,
    required this.artistName,
    this.artistImageUrl,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(artistDetailProvider(artistId));
    final favorites = ref.watch(favoriteArtistsProvider);
    final isFavorite = favorites.contains(artistId);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: detailAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accent500),
        ),
        error: (e, _) => _buildErrorState(context, e.toString()),
        data: (data) => _buildContent(context, ref, data, isFavorite),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return SafeArea(
      child: Column(
        children: [
          _buildBackButton(context),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.alertCircle, size: 48, color: AppColors.textTertiary),
                  const SizedBox(height: 16),
                  Text(
                    '정보를 불러올 수 없습니다',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, _ArtistDetailData data, bool isFavorite) {
    final screenHeight = MediaQuery.of(context).size.height;
    final heroHeight = screenHeight * 0.4;

    // Last.fm에서 아티스트 이미지 가져오기
    final lastFmImageAsync = ref.watch(artistImageProvider(artistName));

    // 대표 이미지 우선순위: Last.fm > 전달받은 이미지 > 앨범 이미지
    final fallbackImageUrl = artistImageUrl ??
        (data.tracks.isNotEmpty ? data.tracks.first.albumImageUrlLarge ?? data.tracks.first.albumImageUrl : null);

    final heroImageUrl = lastFmImageAsync.when(
      data: (lastFmUrl) => (lastFmUrl != null && lastFmUrl.isNotEmpty) ? lastFmUrl : fallbackImageUrl,
      loading: () => fallbackImageUrl,
      error: (_, __) => fallbackImageUrl,
    );

    return CustomScrollView(
      slivers: [
        // 히어로 헤더
        SliverToBoxAdapter(
          child: _buildHeroHeader(context, ref, data, isFavorite, heroHeight, heroImageUrl),
        ),

        // 인기 곡
        if (data.tracks.isNotEmpty)
          SliverToBoxAdapter(
            child: _buildPopularSongs(context, data.tracks.take(5).toList(), data.tracks),
          ),

        // 앨범
        if (data.albums.isNotEmpty)
          SliverToBoxAdapter(
            child: _buildAlbums(context, data.albums),
          ),

        // 하단 여백
        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  Widget _buildHeroHeader(
      BuildContext context,
      WidgetRef ref,
      _ArtistDetailData data,
      bool isFavorite,
      double height,
      String? imageUrl,
      ) {
    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 배경 이미지
          if (imageUrl != null)
            CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: AppColors.surfaceLight),
              errorWidget: (_, __, ___) => Container(
                color: AppColors.surfaceLight,
                child: const Center(
                  child: Icon(LucideIcons.user, size: 64, color: AppColors.textTertiary),
                ),
              ),
            )
          else
            Container(
              color: AppColors.surfaceLight,
              child: const Center(
                child: Icon(LucideIcons.user, size: 64, color: AppColors.textTertiary),
              ),
            ),

          // 그라데이션 오버레이
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.3),
                  AppColors.background.withOpacity(0.9),
                  AppColors.background,
                ],
                stops: const [0.0, 0.5, 0.8, 1.0],
              ),
            ),
          ),

          // 뒤로가기 버튼 (상단)
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
              ),
            ),
          ),

          // 아티스트 정보 (하단)
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 아티스트 이름
                Text(
                  artistName,
                  style: AppTextStyles.headlineLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // 곡 수 + 즐겨찾기
                Row(
                  children: [
                    Text(
                      '곡 ${data.totalTracks}개',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // 즐겨찾기 버튼
                    GestureDetector(
                      onTap: () => _toggleFavorite(ref, isFavorite),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isFavorite
                              ? AppColors.accent500
                              : Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isFavorite
                                ? AppColors.accent500
                                : Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isFavorite ? LucideIcons.star : LucideIcons.star,
                              size: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isFavorite ? '즐겨찾기됨' : '즐겨찾기',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _toggleFavorite(WidgetRef ref, bool isFavorite) {
    final notifier = ref.read(favoriteArtistsProvider.notifier);
    if (isFavorite) {
      notifier.state = {...notifier.state}..remove(artistId);
    } else {
      notifier.state = {...notifier.state, artistId};
    }
  }

  Widget _buildPopularSongs(BuildContext context, List<iTunesTrack> displayTracks, List<iTunesTrack> allTracks) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(
                    '인기 곡',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              // 더보기 버튼 (곡이 5개 이상일 때만)
              if (allTracks.length > 5)
                GestureDetector(
                  onTap: () => _navigateToAllSongs(context, allTracks),
                  child: Row(
                    children: [
                      Text(
                        '더보기',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        LucideIcons.chevronRight,
                        size: 16,
                        color: AppColors.textTertiary,
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          ...displayTracks.asMap().entries.map((entry) {
            final index = entry.key;
            final track = entry.value;
            return _SongListItem(
              rank: index + 1,
              track: track,
              onTap: () => _navigateToLearning(context, track),
            );
          }),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _navigateToAllSongs(BuildContext context, List<iTunesTrack> tracks) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ArtistAllSongsPage(
          artistName: artistName,
          tracks: tracks,
        ),
      ),
    );
  }

  Widget _buildAlbums(BuildContext context, List<iTunesTrack> albums) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Text('💿', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                '앨범',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: albums.length,
            itemBuilder: (context, index) {
              final album = albums[index];
              return Padding(
                padding: EdgeInsets.only(right: index < albums.length - 1 ? 12 : 0),
                child: _AlbumCard(album: album),
              );
            },
          ),
        ),
      ],
    );
  }

  void _navigateToLearning(BuildContext context, iTunesTrack track) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TrackLearningPage(track: track),
      ),
    );
  }
}

/// 곡 리스트 아이템 (순위 포함)
class _SongListItem extends StatelessWidget {
  final int rank;
  final iTunesTrack track;
  final VoidCallback onTap;

  const _SongListItem({
    required this.rank,
    required this.track,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            // 순위
            SizedBox(
              width: 24,
              child: Text(
                '$rank',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // 앨범아트
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: track.albumImageUrl ?? '',
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  width: 48,
                  height: 48,
                  color: AppColors.surfaceLight,
                  child: const Icon(LucideIcons.music2, size: 18, color: AppColors.textTertiary),
                ),
                errorWidget: (_, __, ___) => Container(
                  width: 48,
                  height: 48,
                  color: AppColors.surfaceLight,
                  child: const Icon(LucideIcons.music2, size: 18, color: AppColors.textTertiary),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.name,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    track.albumName ?? '',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // 화살표
            const Icon(LucideIcons.chevronRight, size: 20, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

/// 앨범 카드
class _AlbumCard extends StatelessWidget {
  final iTunesTrack album;

  const _AlbumCard({required this.album});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 앨범 커버
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: album.albumImageUrl ?? '',
              width: 130,
              height: 130,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                width: 130,
                height: 130,
                color: AppColors.surfaceLight,
                child: const Icon(LucideIcons.disc, size: 32, color: AppColors.textTertiary),
              ),
              errorWidget: (_, __, ___) => Container(
                width: 130,
                height: 130,
                color: AppColors.surfaceLight,
                child: const Icon(LucideIcons.disc, size: 32, color: AppColors.textTertiary),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // 앨범명
          Text(
            album.albumName ?? '',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// 아티스트 전체 곡 목록 페이지
class ArtistAllSongsPage extends StatelessWidget {
  final String artistName;
  final List<iTunesTrack> tracks;

  const ArtistAllSongsPage({
    super.key,
    required this.artistName,
    required this.tracks,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textPrimary),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              artistName,
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '곡 ${tracks.length}개',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: tracks.length,
        itemBuilder: (context, index) {
          final track = tracks[index];
          return _AllSongsListItem(
            rank: index + 1,
            track: track,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TrackLearningPage(track: track),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// 전체 곡 목록 아이템
class _AllSongsListItem extends StatelessWidget {
  final int rank;
  final iTunesTrack track;
  final VoidCallback onTap;

  const _AllSongsListItem({
    required this.rank,
    required this.track,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            // 순위
            SizedBox(
              width: 28,
              child: Text(
                '$rank',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // 앨범아트
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: track.albumImageUrl ?? '',
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  width: 48,
                  height: 48,
                  color: AppColors.surfaceLight,
                  child: const Icon(LucideIcons.music2, size: 18, color: AppColors.textTertiary),
                ),
                errorWidget: (_, __, ___) => Container(
                  width: 48,
                  height: 48,
                  color: AppColors.surfaceLight,
                  child: const Icon(LucideIcons.music2, size: 18, color: AppColors.textTertiary),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.name,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    track.albumName ?? '',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // 화살표
            const Icon(LucideIcons.chevronRight, size: 20, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}