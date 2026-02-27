import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/services/itunes_service.dart';
import '../../providers/app_providers.dart';
import 'track_learning_page.dart';
import 'artist_page.dart';
import '../../providers/app_providers.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
final searchResultPageProvider = FutureProvider.family<SearchPageResult, String>((ref, query) async {
  if (query.isEmpty) {
    return SearchPageResult(tracks: [], artists: []);
  }

  final service = ref.read(iTunesServiceProvider);
  final rawResults = await service.searchJapaneseMusic(query: query, limit: 30);

  // 1차 필터링: 일본어가 포함된 곡만 추림 (이전 단계)
  final japaneseRegex = RegExp(r'[\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FAF]');
  final langFiltered = rawResults.where((track) {
    final text = '${track.name}${track.artistName}';
    return japaneseRegex.hasMatch(text);
  }).toList();

  // 🚨 2차 필터링: 우타넷(Uta-Net)에 가사가 있는 곡만 남기기
  final validTracks = <iTunesTrack>[];

  // 프록시 서버 주소 (실제 구동 중인 서버 IP/도메인으로 변경하세요)
  const proxyBaseUrl = 'https://e4e1-211-179-133-167.ngrok-free.app'; // 예: 10.0.2.2:4000 (에뮬레이터)

  // API 과부하 및 로딩 지연을 막기 위해 상위 15개만 검사합니다.
  final tracksToCheck = langFiltered.take(15).toList();

  // 비동기 병렬 처리로 여러 곡을 동시에 검사 (Future.wait)
  await Future.wait(tracksToCheck.map((track) async {
    try {
      final uri = Uri.parse('$proxyBaseUrl/api/lyrics?artist=${Uri.encodeComponent(track.artistName)}&title=${Uri.encodeComponent(track.name)}');

      // 스크래핑이 너무 오래 걸리면 포기하도록 타임아웃 3초 설정
      final response = await http.get(uri).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          validTracks.add(track); // 우타넷에 가사가 있는 곡만 리스트에 추가!
        }
      }
    } catch (e) {
      // 타임아웃이나 서버 에러 발생 시 해당 곡은 스킵
      print('Uta-Net 확인 실패 (${track.name}): $e');
    }
  }));

  // 비동기 처리 때문에 순서가 섞였을 수 있으므로, 원래 검색 결과 순서대로 재정렬
  validTracks.sort((a, b) => langFiltered.indexOf(a).compareTo(langFiltered.indexOf(b)));

  // 아티스트 중복 제거 로직
  final artistMap = <int, iTunesTrack>{};
  for (final track in validTracks) {
    if (!artistMap.containsKey(track.artistId)) {
      artistMap[track.artistId] = track;
    }
  }

  return SearchPageResult(
    tracks: validTracks,
    artists: artistMap.values.toList(),
  );
});

class SearchPageResult {
  final List<iTunesTrack> tracks;
  final List<iTunesTrack> artists; // 아티스트 정보용 (트랙에서 추출)

  SearchPageResult({required this.tracks, required this.artists});
}

enum SearchFilter { all, songs, artists }

class SearchResultPage extends ConsumerStatefulWidget {
  final String query;

  const SearchResultPage({super.key, required this.query});

  @override
  ConsumerState<SearchResultPage> createState() => _SearchResultPageState();
}

class _SearchResultPageState extends ConsumerState<SearchResultPage> {
  late TextEditingController _searchController;
  SearchFilter _currentFilter = SearchFilter.all;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.query);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    if (query.trim().isEmpty) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => SearchResultPage(query: query.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final resultAsync = ref.watch(searchResultPageProvider(widget.query));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 검색창
            _buildSearchBar(),

            // 필터 탭
            _buildFilterTabs(),

            // 결과
            Expanded(
              child: resultAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.accent500),
                ),
                error: (e, _) => _buildErrorState(e.toString()),
                data: (result) => _buildResults(result),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: [
          // 뒤로가기
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(LucideIcons.arrowLeft, size: 22),
            color: AppColors.textPrimary,
          ),

          // 검색 입력
          Expanded(
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onSubmitted: _onSearch,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: '검색...',
                        hintStyle: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textTertiary,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() {});
                      },
                      child: const Icon(
                        LucideIcons.x,
                        size: 18,
                        color: AppColors.textTertiary,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _FilterChip(
            label: '전체',
            isSelected: _currentFilter == SearchFilter.all,
            onTap: () => setState(() => _currentFilter = SearchFilter.all),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: '곡',
            isSelected: _currentFilter == SearchFilter.songs,
            onTap: () => setState(() => _currentFilter = SearchFilter.songs),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: '아티스트',
            isSelected: _currentFilter == SearchFilter.artists,
            onTap: () => setState(() => _currentFilter = SearchFilter.artists),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.alertCircle, size: 48, color: AppColors.textTertiary),
            const SizedBox(height: 16),
            Text(
              '검색 중 오류가 발생했습니다',
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(SearchPageResult result) {
    if (result.tracks.isEmpty) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 전체 or 곡 필터일 때
          if (_currentFilter == SearchFilter.all || _currentFilter == SearchFilter.songs) ...[
            // 인기 결과 (전체 필터일 때만)
            if (_currentFilter == SearchFilter.all && result.tracks.isNotEmpty)
              _buildTopResult(result.tracks.first),

            // 곡 섹션
            if (result.tracks.isNotEmpty)
              _buildSongsSection(result.tracks),
          ],

          // 전체 or 아티스트 필터일 때
          if (_currentFilter == SearchFilter.all || _currentFilter == SearchFilter.artists) ...[
            if (result.artists.isNotEmpty)
              _buildArtistsSection(result.artists),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.searchX, size: 56, color: AppColors.textTertiary),
            const SizedBox(height: 16),
            Text(
              '"${widget.query}"에 대한 결과가 없습니다',
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '다른 검색어로 시도해보세요',
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopResult(iTunesTrack track) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🎯 인기 결과',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),

          GestureDetector(
            onTap: () => _navigateToLearning(track),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // 큰 앨범아트
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: track.albumImageUrl ?? '',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        width: 100,
                        height: 100,
                        color: AppColors.surfaceLight,
                        child: const Icon(LucideIcons.music2, size: 32, color: AppColors.textTertiary),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        width: 100,
                        height: 100,
                        color: AppColors.surfaceLight,
                        child: const Icon(LucideIcons.music2, size: 32, color: AppColors.textTertiary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // 정보
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          track.name,
                          style: AppTextStyles.titleMedium.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${track.artistName} · 곡',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // 학습 시작 버튼
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.accent500,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(LucideIcons.play, size: 16, color: Colors.white),
                              const SizedBox(width: 6),
                              Text(
                                '학습 시작',
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
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSongsSection(List<iTunesTrack> tracks) {
    // 전체 필터면 첫번째는 인기결과에서 보여줬으니 제외
    final displayTracks = _currentFilter == SearchFilter.all
        ? tracks.skip(1).take(5).toList()
        : tracks.take(10).toList();

    if (displayTracks.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '🎵 곡',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (tracks.length > 5 && _currentFilter == SearchFilter.all)
                GestureDetector(
                  onTap: () => setState(() => _currentFilter = SearchFilter.songs),
                  child: Text(
                    '더보기',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.accent500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          ...displayTracks.map((track) => _SongListItem(
            track: track,
            onTap: () => _navigateToLearning(track),
          )),
        ],
      ),
    );
  }

  Widget _buildArtistsSection(List<iTunesTrack> artists) {
    final displayArtists = _currentFilter == SearchFilter.all
        ? artists.take(3).toList()
        : artists.take(10).toList();

    if (displayArtists.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '👤 아티스트',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (artists.length > 3 && _currentFilter == SearchFilter.all)
                GestureDetector(
                  onTap: () => setState(() => _currentFilter = SearchFilter.artists),
                  child: Text(
                    '더보기',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.accent500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          ...displayArtists.map((artist) => _ArtistListItem(
            track: artist,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ArtistPage(
                    artistId: artist.artistId,
                    artistName: artist.artistName,
                    artistImageUrl: artist.albumImageUrlLarge ?? artist.albumImageUrl,
                  ),
                ),
              );
            },
          )),
        ],
      ),
    );
  }

  void _navigateToLearning(iTunesTrack track) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TrackLearningPage(track: track),
      ),
    );
  }
}

/// 필터 칩
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent500 : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.accent500 : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

/// 곡 리스트 아이템
class _SongListItem extends StatelessWidget {
  final iTunesTrack track;
  final VoidCallback onTap;

  const _SongListItem({
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
            // 앨범아트
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: track.albumImageUrl ?? '',
                width: 52,
                height: 52,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  width: 52,
                  height: 52,
                  color: AppColors.surfaceLight,
                  child: const Icon(LucideIcons.music2, size: 20, color: AppColors.textTertiary),
                ),
                errorWidget: (_, __, ___) => Container(
                  width: 52,
                  height: 52,
                  color: AppColors.surfaceLight,
                  child: const Icon(LucideIcons.music2, size: 20, color: AppColors.textTertiary),
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
                    track.artistName,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // 더보기
            const Icon(
              LucideIcons.chevronRight,
              size: 20,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

/// 아티스트 리스트 아이템 (Deezer 이미지 사용)
class _ArtistListItem extends ConsumerWidget {
  final iTunesTrack track;
  final VoidCallback onTap;

  const _ArtistListItem({
    required this.track,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Deezer에서 아티스트 이미지 가져오기
    final artistImageAsync = ref.watch(artistImageProvider(track.artistName));

    final imageUrl = artistImageAsync.when(
      data: (url) => (url != null && url.isNotEmpty) ? url : track.albumImageUrl,
      loading: () => track.albumImageUrl, // 로딩 중엔 앨범 이미지
      error: (_, __) => track.albumImageUrl, // 에러 시 앨범 이미지
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            // 원형 이미지
            ClipOval(
              child: CachedNetworkImage(
                imageUrl: imageUrl ?? '',
                width: 52,
                height: 52,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  width: 52,
                  height: 52,
                  color: AppColors.surfaceLight,
                  child: const Icon(LucideIcons.user, size: 20, color: AppColors.textTertiary),
                ),
                errorWidget: (_, __, ___) => Container(
                  width: 52,
                  height: 52,
                  color: AppColors.surfaceLight,
                  child: const Icon(LucideIcons.user, size: 20, color: AppColors.textTertiary),
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
                    track.artistName,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '아티스트',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // 화살표
            const Icon(
              LucideIcons.chevronRight,
              size: 20,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}