import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'dart:ui';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/lyrics_data.dart';

class LyricsLearningPage extends StatefulWidget {
  final SongLyrics songData;

  const LyricsLearningPage({
    super.key,
    required this.songData,
  });

  @override
  State<LyricsLearningPage> createState() => _LyricsLearningPageState();
}

class _LyricsLearningPageState extends State<LyricsLearningPage> with SingleTickerProviderStateMixin {
  late YoutubePlayerController _youtubeController;
  late TabController _tabController;

  int _currentLyricIndex = 0;
  bool _isRepeatOn = false;
  bool _isPlaying = false;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();

    _youtubeController = YoutubePlayerController(
      initialVideoId: widget.songData.youtubeId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: false,
        hideControls: true,
      ),
    )..addListener(_onPlayerStateChange);

    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() => _selectedTab = _tabController.index);
    });

    // 상태바 스타일 설정
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  void _onPlayerStateChange() {
    if (!mounted) return;

    final currentTime = _youtubeController.value.position.inMilliseconds / 1000;
    final lyrics = widget.songData.lyricsAnalysis;

    // 현재 시간에 해당하는 가사 찾기
    for (int i = 0; i < lyrics.length; i++) {
      if (currentTime >= lyrics[i].startTime && currentTime < lyrics[i].endTime) {
        if (_currentLyricIndex != i) {
          setState(() => _currentLyricIndex = i);
        }
        break;
      }
    }

    // 반복 모드일 때 구간 반복
    if (_isRepeatOn && currentTime >= lyrics[_currentLyricIndex].endTime - 0.2) {
      _youtubeController.seekTo(Duration(
        milliseconds: (lyrics[_currentLyricIndex].startTime * 1000).toInt(),
      ));
    }

    // 재생 상태 업데이트
    final isPlaying = _youtubeController.value.isPlaying;
    if (_isPlaying != isPlaying) {
      setState(() => _isPlaying = isPlaying);
    }
  }

  void _goToPreviousLyric() {
    if (_currentLyricIndex > 0) {
      setState(() => _currentLyricIndex--);
      _seekToCurrentLyric();
    }
  }

  void _goToNextLyric() {
    if (_currentLyricIndex < widget.songData.lyricsAnalysis.length - 1) {
      setState(() => _currentLyricIndex++);
      _seekToCurrentLyric();
    }
  }

  void _seekToCurrentLyric() {
    final lyric = widget.songData.lyricsAnalysis[_currentLyricIndex];
    _youtubeController.seekTo(Duration(
      milliseconds: (lyric.startTime * 1000).toInt(),
    ));
  }

  void _togglePlay() {
    if (_isPlaying) {
      _youtubeController.pause();
    } else {
      _youtubeController.play();
    }
  }

  void _restartSection() {
    _seekToCurrentLyric();
    if (!_isPlaying) {
      _youtubeController.play();
    }
  }

  void _toggleRepeat() {
    setState(() => _isRepeatOn = !_isRepeatOn);
  }

  @override
  void dispose() {
    _youtubeController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentLyric = widget.songData.lyricsAnalysis[_currentLyricIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: YoutubePlayerBuilder(
        player: YoutubePlayer(
          controller: _youtubeController,
          showVideoProgressIndicator: false,
        ),
        builder: (context, player) {
          return Column(
            children: [
              // 헤더
              _buildHeader(),

              // YouTube 플레이어
              AspectRatio(
                aspectRatio: 16 / 9,
                child: ClipRRect(
                  child: player,
                ),
              ),

              // 컨트롤 바
              _buildControlBar(),

              // 가사 카드
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildLyricsCard(currentLyric),
                      const SizedBox(height: 16),
                      _buildStudyTabs(currentLyric),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 8,
        right: 16,
        bottom: 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.border.withOpacity(0.5))),
      ),
      child: Row(
        children: [
          // 뒤로가기
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(LucideIcons.chevronLeft, color: AppColors.textPrimary),
          ),

          // 앨범 아트
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              widget.songData.albumImageUrl,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 40,
                height: 40,
                color: AppColors.surfaceLight,
                child: const Icon(LucideIcons.music2, size: 20, color: AppColors.textTertiary),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // 제목/아티스트
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.songData.title,
                  style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  widget.songData.artist,
                  style: AppTextStyles.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // 북마크 버튼
          IconButton(
            onPressed: () {},
            icon: const Icon(LucideIcons.bookmark, color: AppColors.textSecondary, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildControlBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.8),
            AppColors.background,
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 되감기
          _ControlButton(
            icon: LucideIcons.skipBack,
            onTap: _restartSection,
            tooltip: '구간 처음으로',
          ),
          const SizedBox(width: 16),

          // 재생/일시정지
          _PlayButton(
            isPlaying: _isPlaying,
            onTap: _togglePlay,
          ),
          const SizedBox(width: 16),

          // 반복
          _ControlButton(
            icon: LucideIcons.repeat,
            onTap: _toggleRepeat,
            isActive: _isRepeatOn,
            tooltip: '구간 반복',
          ),
        ],
      ),
    );
  }

  Widget _buildLyricsCard(LyricLine lyric) {
    final totalLyrics = widget.songData.lyricsAnalysis.length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // 가사 + 네비게이션
          Row(
            children: [
              // 이전 버튼
              _NavButton(
                icon: LucideIcons.chevronLeft,
                onTap: _currentLyricIndex > 0 ? _goToPreviousLyric : null,
              ),

              // 가사
              Expanded(
                child: Column(
                  children: [
                    // 원문
                    Text(
                      lyric.original,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),

                    // 번역
                    Text(
                      lyric.translated,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // 다음 버튼
              _NavButton(
                icon: LucideIcons.chevronRight,
                onTap: _currentLyricIndex < totalLyrics - 1 ? _goToNextLyric : null,
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 진행률 표시
          Text(
            '${_currentLyricIndex + 1} / $totalLyrics',
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _buildStudyTabs(LyricLine lyric) {
    final tabs = [
      {'icon': '📚', 'label': '단어', 'count': lyric.words.length},
      {'icon': '📖', 'label': '문법', 'count': lyric.grammar.length},
      {'icon': '🗣️', 'label': '표현', 'count': lyric.expressions.length},
    ];

    return Column(
      children: [
        // 탭 바 (웹버전 스타일)
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: tabs.asMap().entries.map((entry) {
              final index = entry.key;
              final tab = entry.value;
              final isSelected = _selectedTab == index;

              return Expanded(
                child: GestureDetector(
                  onTap: () => _tabController.animateTo(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isSelected ? AppColors.accent500 : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          tab['icon'] as String,
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tab['label'] as String,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: isSelected ? AppColors.accent500 : AppColors.textTertiary,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),

        // 탭 컨텐츠 (스와이프 형식)
        SizedBox(
          height: 180,
          child: TabBarView(
            controller: _tabController,
            children: [
              _SwipeableStudyCards(
                items: lyric.words.map((w) => _StudyItem(
                  title: w.word,
                  subtitle: w.meaning,
                  example: w.example,
                )).toList(),
                icon: LucideIcons.bookOpen,
                color: AppColors.accent500,
                emptyMessage: '이 구간에 학습할 단어가 없어요',
              ),
              _SwipeableStudyCards(
                items: lyric.grammar.map((g) => _StudyItem(
                  title: g.pattern,
                  subtitle: g.explanation,
                  example: g.example,
                )).toList(),
                icon: LucideIcons.fileText,
                color: AppColors.primary500,
                emptyMessage: '이 구간에 학습할 문법이 없어요',
              ),
              _SwipeableStudyCards(
                items: lyric.expressions.map((e) => _StudyItem(
                  title: e.expression,
                  subtitle: e.meaning,
                  example: e.example,
                )).toList(),
                icon: LucideIcons.messageCircle,
                color: AppColors.secondary500,
                emptyMessage: '이 구간에 학습할 표현이 없어요',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 학습 아이템 데이터
class _StudyItem {
  final String title;
  final String subtitle;
  final String example;

  const _StudyItem({
    required this.title,
    required this.subtitle,
    required this.example,
  });
}

/// 스와이프 가능한 학습 카드들 (글래스모피즘 + 스택 효과)
class _SwipeableStudyCards extends StatefulWidget {
  final List<_StudyItem> items;
  final IconData icon;
  final Color color;
  final String emptyMessage;

  const _SwipeableStudyCards({
    required this.items,
    required this.icon,
    required this.color,
    required this.emptyMessage,
  });

  @override
  State<_SwipeableStudyCards> createState() => _SwipeableStudyCardsState();
}

class _SwipeableStudyCardsState extends State<_SwipeableStudyCards> {
  late PageController _pageController;
  int _currentPage = 0;
  final Set<String> _savedItems = {};
  final Set<String> _hiddenItems = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
  }

  @override
  void didUpdateWidget(covariant _SwipeableStudyCards oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _currentPage = 0;
      _pageController.jumpToPage(0);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleSave(String item) {
    setState(() {
      if (_savedItems.contains(item)) {
        _savedItems.remove(item);
      } else {
        _savedItems.add(item);
      }
    });
  }

  void _toggleHide(String item) {
    setState(() {
      if (_hiddenItems.contains(item)) {
        _hiddenItems.remove(item);
      } else {
        _hiddenItems.add(item);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.inbox, size: 32, color: AppColors.textTertiary),
            const SizedBox(height: 8),
            Text(widget.emptyMessage, style: AppTextStyles.bodySmall),
          ],
        ),
      );
    }

    return Column(
      children: [
        // 카드 스와이프 영역 + 좌우 네비게이션
        Expanded(
          child: Row(
            children: [
              // 왼쪽 화살표
              GestureDetector(
                onTap: _currentPage > 0
                    ? () => _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                )
                    : null,
                child: Container(
                  width: 36,
                  alignment: Alignment.center,
                  child: Icon(
                    LucideIcons.chevronLeft,
                    size: 20,
                    color: _currentPage > 0
                        ? AppColors.textSecondary
                        : AppColors.textTertiary.withOpacity(0.3),
                  ),
                ),
              ),

              // 카드 영역
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  itemCount: widget.items.length,
                  itemBuilder: (context, index) {
                    final item = widget.items[index];
                    final isSaved = _savedItems.contains(item.title);
                    final isHidden = _hiddenItems.contains(item.title);

                    return AnimatedBuilder(
                      animation: _pageController,
                      builder: (context, child) {
                        double value = 1.0;
                        if (_pageController.position.haveDimensions) {
                          value = (_pageController.page! - index).abs();
                          value = (1 - (value * 0.15)).clamp(0.85, 1.0);
                        }

                        return Transform.scale(
                          scale: value,
                          child: Opacity(
                            opacity: value,
                            child: _GlassStudyCard(
                              item: item,
                              icon: widget.icon,
                              color: widget.color,
                              isSaved: isSaved,
                              isHidden: isHidden,
                              onToggleSave: () => _toggleSave(item.title),
                              onToggleHide: () => _toggleHide(item.title),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              // 오른쪽 화살표
              GestureDetector(
                onTap: _currentPage < widget.items.length - 1
                    ? () => _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                )
                    : null,
                child: Container(
                  width: 36,
                  alignment: Alignment.center,
                  child: Icon(
                    LucideIcons.chevronRight,
                    size: 20,
                    color: _currentPage < widget.items.length - 1
                        ? AppColors.textSecondary
                        : AppColors.textTertiary.withOpacity(0.3),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Dot indicator (웹버전 스타일 - 원형)
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.items.length,
                (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? widget.color
                    : widget.color.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}

/// 글래스모피즘 학습 카드
class _GlassStudyCard extends StatelessWidget {
  final _StudyItem item;
  final IconData icon;
  final Color color;
  final bool isSaved;
  final bool isHidden;
  final VoidCallback onToggleSave;
  final VoidCallback onToggleHide;

  const _GlassStudyCard({
    required this.item,
    required this.icon,
    required this.color,
    required this.isSaved,
    required this.isHidden,
    required this.onToggleSave,
    required this.onToggleHide,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 헤더: 단어 + 버튼들
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: AppTextStyles.titleSmall.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.subtitle,
                        style: AppTextStyles.bodySmall.copyWith(color: color),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // 즐겨찾기
                GestureDetector(
                  onTap: onToggleSave,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isSaved ? color : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isSaved ? LucideIcons.check : LucideIcons.bookmark,
                      size: 14,
                      color: isSaved ? Colors.white : AppColors.textTertiary,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                // 숨기기
                GestureDetector(
                  onTap: onToggleHide,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isHidden ? AppColors.error.withOpacity(0.2) : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      LucideIcons.eyeOff,
                      size: 14,
                      color: isHidden ? AppColors.error : AppColors.textTertiary,
                    ),
                  ),
                ),
              ],
            ),

            // 예문
            if (item.example.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '예문',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textTertiary,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.example,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;
  final String tooltip;

  const _ControlButton({
    required this.icon,
    required this.onTap,
    this.isActive = false,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.accent500.withOpacity(0.2) : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? AppColors.accent500 : AppColors.border,
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isActive ? AppColors.accent500 : AppColors.textSecondary,
        ),
      ),
    );
  }
}

/// 재생 버튼 (큰 버전)
class _PlayButton extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onTap;

  const _PlayButton({
    required this.isPlaying,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.accent500, AppColors.accent600],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent500.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          isPlaying ? LucideIcons.pause : LucideIcons.play,
          size: 24,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// 네비게이션 버튼
class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _NavButton({
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isEnabled ? AppColors.surfaceLight : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 24,
          color: isEnabled ? AppColors.textPrimary : AppColors.textTertiary.withOpacity(0.3),
        ),
      ),
    );
  }
}

/// 학습 아이템 카드
class _StudyItemCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String example;
  final IconData icon;
  final Color color;
  final bool isSaved;
  final bool isHidden;
  final VoidCallback onToggleSave;
  final VoidCallback onToggleHide;

  const _StudyItemCard({
    required this.title,
    required this.subtitle,
    required this.example,
    required this.icon,
    required this.color,
    required this.isSaved,
    required this.isHidden,
    required this.onToggleSave,
    required this.onToggleHide,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(color: color),
                    ),
                  ],
                ),
              ),
              // 즐겨찾기 버튼
              GestureDetector(
                onTap: onToggleSave,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSaved ? color : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isSaved ? LucideIcons.check : LucideIcons.bookmarkPlus,
                    size: 16,
                    color: isSaved ? Colors.white : AppColors.textTertiary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // 숨기기 버튼
              GestureDetector(
                onTap: onToggleHide,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isHidden ? AppColors.error.withOpacity(0.2) : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    LucideIcons.eyeOff,
                    size: 16,
                    color: isHidden ? AppColors.error : AppColors.textTertiary,
                  ),
                ),
              ),
            ],
          ),

          // 예문
          if (example.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('💡 ', style: AppTextStyles.bodySmall),
                  Expanded(
                    child: Text(
                      example,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}