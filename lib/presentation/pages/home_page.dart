import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:ui';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/services/itunes_service.dart';
import '../../providers/app_providers.dart';
import '../../providers/search_provider.dart';
import '../../data/lyrics_data.dart';
import '../widgets/glass_card.dart';
import 'lyrics_learning_page.dart';
import 'search_result_page.dart';
import 'track_learning_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _isSearchActive = false;  // 검색창 활성화 (배경 어두움 + 입력 가능)
  bool _isPastHero = false;
  double _heroHeight = 0;

  late AnimationController _searchAnimController;
  late Animation<double> _searchWidthAnimation;
  late Animation<double> _fadeAnimation;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // 검색창이 펼쳐져야 하는지 (스크롤 후 OR 활성화 시)
  bool get _shouldExpand => _isPastHero || _isSearchActive;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    _searchAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _searchWidthAnimation = CurvedAnimation(
      parent: _searchAnimController,
      curve: Curves.easeOutExpo,
      reverseCurve: Curves.easeInExpo,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _searchAnimController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _heroHeight = MediaQuery.of(context).size.height * 0.38;
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchAnimController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_heroHeight == 0) return;
    final isPast = _scrollController.offset > _heroHeight - 100;

    if (isPast != _isPastHero) {
      setState(() => _isPastHero = isPast);
      // 스크롤 시 자동 펼쳐짐 (비활성화 상태)
      if (isPast && !_isSearchActive) {
        _searchAnimController.forward();
      } else if (!isPast && !_isSearchActive) {
        _searchAnimController.reverse();
      }
    }
  }

  void _activateSearch() {
    setState(() => _isSearchActive = true);
    _searchAnimController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _searchFocusNode.requestFocus();
    });
  }

  void _deactivateSearch() {
    _searchFocusNode.unfocus();
    setState(() => _isSearchActive = false);
    _searchController.clear();
    ref.read(searchQueryProvider.notifier).state = '';

    // 스크롤 위치에 따라 펼쳐진 상태 유지 or 접기
    if (!_isPastHero) {
      _searchAnimController.reverse();
    }
  }

  void _onSearchChanged(String value) {
    ref.read(searchQueryProvider.notifier).state = value;
    setState(() {}); // X 버튼 표시용
  }

  void _onSearchSubmit(String value) {
    if (value.trim().isEmpty) return;

    _deactivateSearch();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchResultPage(query: value.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chartAsync = ref.watch(japanTopChartProvider);
    final screenHeight = MediaQuery.of(context).size.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 메인 컨텐츠
          chartAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.accent500),
            ),
            error: (error, stack) => _buildErrorState(error.toString()),
            data: (tracks) => _buildContent(context, tracks, screenHeight),
          ),

          // 검색 배경 (활성화 시에만 어둡게)
          if (_isSearchActive)
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return GestureDetector(
                  onTap: _deactivateSearch,
                  child: Container(
                    color: Colors.black.withOpacity(0.5 * _fadeAnimation.value),
                  ),
                );
              },
            ),

          // 검색 버튼 / 검색창 (가운데 정렬)
          Positioned(
            top: statusBarHeight + 8,
            left: 16,
            right: 16,
            child: _buildSearchBar(screenWidth),
          ),

          // 검색 결과 드롭다운
          if (_isSearchActive)
            Positioned(
              top: statusBarHeight + 60,
              left: 16,
              right: 16,
              child: _buildSearchResults(),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(double screenWidth) {
    final query = ref.watch(searchQueryProvider);

    return AnimatedBuilder(
      animation: _searchAnimController,
      builder: (context, child) {
        // 애니메이션 진행에 따른 너비 계산 (44px -> full width)
        final collapsedWidth = 44.0;
        final expandedWidth = screenWidth - 32;
        final currentWidth = collapsedWidth + (_searchWidthAnimation.value * (expandedWidth - collapsedWidth));

        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: _shouldExpand ? 20 : 15,
                  sigmaY: _shouldExpand ? 20 : 15,
                ),
                child: GestureDetector(
                  onTap: _isSearchActive ? null : _activateSearch,
                  child: Container(
                    width: currentWidth,
                    height: 44,
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      color: _isSearchActive
                          ? AppColors.surface.withOpacity(0.95)
                          : _isPastHero
                          ? AppColors.surface.withOpacity(0.9)
                          : Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: _isSearchActive || _isPastHero
                            ? AppColors.border
                            : Colors.white.withOpacity(0.25),
                        width: 1,
                      ),
                      boxShadow: _shouldExpand
                          ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                          : null,
                    ),
                    child: Row(
                      children: [
                        // 검색 아이콘 / 뒤로가기
                        GestureDetector(
                          onTap: _isSearchActive ? _deactivateSearch : _activateSearch,
                          child: SizedBox(
                            width: 42,
                            height: 42,
                            child: Center(
                              child: Icon(
                                _isSearchActive ? LucideIcons.arrowLeft : LucideIcons.search,
                                size: 18,
                                color: _isSearchActive || _isPastHero
                                    ? AppColors.textSecondary
                                    : Colors.white,
                              ),
                            ),
                          ),
                        ),

                        // 텍스트 필드 (펼쳐졌을 때만)
                        if (_searchWidthAnimation.value > 0.3)
                          Expanded(
                            child: Opacity(
                              opacity: ((_searchWidthAnimation.value - 0.3) / 0.7).clamp(0.0, 1.0),
                              child: AbsorbPointer(
                                absorbing: !_isSearchActive,
                                child: TextField(
                                  controller: _searchController,
                                  focusNode: _searchFocusNode,
                                  onChanged: _onSearchChanged,
                                  onSubmitted: _onSearchSubmit,
                                  textInputAction: TextInputAction.search,
                                  cursorColor: AppColors.accent500,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: _isSearchActive
                                        ? AppColors.textPrimary
                                        : _isPastHero
                                        ? AppColors.textSecondary
                                        : Colors.white,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: '노래 또는 아티스트 검색...',
                                    hintStyle: AppTextStyles.bodySmall.copyWith(
                                      color: _isSearchActive
                                          ? AppColors.textTertiary
                                          : _isPastHero
                                          ? AppColors.textTertiary
                                          : Colors.white.withOpacity(0.6),
                                    ),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                            ),
                          ),

                        // X 버튼 (활성화 + 검색어 있을 때만)
                        if (_isSearchActive && query.isNotEmpty && _searchWidthAnimation.value > 0.5)
                          Opacity(
                            opacity: ((_searchWidthAnimation.value - 0.5) / 0.5).clamp(0.0, 1.0),
                            child: GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                _onSearchChanged('');
                              },
                              child: const SizedBox(
                                width: 42,
                                height: 42,
                                child: Center(
                                  child: Icon(
                                    LucideIcons.x,
                                    size: 16,
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchResults() {
    final query = ref.watch(searchQueryProvider);
    final searchResults = ref.watch(searchResultsProvider);

    if (query.length < 2) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        if (_fadeAnimation.value < 0.5) return const SizedBox.shrink();

        return Opacity(
          opacity: _fadeAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: searchResults.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.accent500,
                      ),
                    ),
                  ),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    '검색 중 오류 발생',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
                data: (tracks) {
                  if (tracks.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.searchX,
                            size: 28,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '일본 노래를 찾을 수 없습니다',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: tracks.asMap().entries.map((entry) {
                      final index = entry.key;
                      final track = entry.value;
                      final isLast = index == tracks.length - 1;

                      return _SearchResultItem(
                        track: track,
                        onTap: () {
                          _deactivateSearch();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TrackLearningPage(track: track),
                            ),
                          );
                        },
                        showDivider: !isLast,
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(String error) {
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
    final recentTracks = tracks.length > 12 ? tracks.sublist(9, 12) : tracks.take(3).toList();

    return SingleChildScrollView(
      controller: _scrollController,
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

/// 검색 결과 아이템
class _SearchResultItem extends StatelessWidget {
  final iTunesTrack track;
  final VoidCallback onTap;
  final bool showDivider;

  const _SearchResultItem({
    required this.track,
    required this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  // 앨범 아트
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: track.albumImageUrl ?? '',
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        width: 44,
                        height: 44,
                        color: AppColors.surfaceLight,
                        child: const Icon(
                          LucideIcons.music2,
                          size: 18,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        width: 44,
                        height: 44,
                        color: AppColors.surfaceLight,
                        child: const Icon(
                          LucideIcons.music2,
                          size: 18,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // 노래 정보
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
                        Text(
                          track.artistName,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textTertiary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            if (showDivider)
              Divider(
                height: 1,
                thickness: 1,
                indent: 68,
                color: AppColors.border.withOpacity(0.5),
              ),
          ],
        ),
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
                              builder: (_) => TrackLearningPage(
                                track: track!,
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
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TrackLearningPage(track: track),
            ),
          );
        },
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
                      left: 0,
                      right: 0,
                      bottom: 0,
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

                    // 노래 정보
                    Positioned(
                      left: 12,
                      right: 12,
                      bottom: 12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            track.name,
                            style: AppTextStyles.labelMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            track.artistName,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: Colors.white70,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 순위 뱃지 (Top 3)
            if (isTop3)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: index == 0
                          ? [const Color(0xFFFFD700), const Color(0xFFFFA500)]
                          : index == 1
                          ? [const Color(0xFFC0C0C0), const Color(0xFF909090)]
                          : [const Color(0xFFCD7F32), const Color(0xFFA0522D)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '#${index + 1}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
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

/// 최근 학습 리스트
class _RecentLearningList extends StatelessWidget {
  final List<iTunesTrack> tracks;

  const _RecentLearningList({required this.tracks});

  @override
  Widget build(BuildContext context) {
    if (tracks.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(32),
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
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TrackLearningPage(track: track),
            ),
          );
        },
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
                      SizedBox(
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

/// 터치 피드백 위젯
class AnimatedPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleFactor;

  const AnimatedPressable({
    super.key,
    required this.child,
    this.onTap,
    this.scaleFactor = 0.97,
  });

  @override
  State<AnimatedPressable> createState() => _AnimatedPressableState();
}

class _AnimatedPressableState extends State<AnimatedPressable>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.scaleFactor).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}