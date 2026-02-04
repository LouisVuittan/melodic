import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
  late PageController _cardPageController;

  int _currentLyricIndex = 0;
  bool _isRepeatOn = false;
  bool _isPlaying = false;
  int _selectedTab = 0;
  int _currentCardIndex = 0;

  final Set<String> _savedItems = {};
  final Set<String> _hiddenItems = {};

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
      setState(() {
        _selectedTab = _tabController.index;
        _currentCardIndex = 0;
        _cardPageController.jumpToPage(0);
      });
    });

    _cardPageController = PageController(viewportFraction: 0.88);

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

    for (int i = 0; i < lyrics.length; i++) {
      if (currentTime >= lyrics[i].startTime && currentTime < lyrics[i].endTime) {
        if (_currentLyricIndex != i) {
          setState(() => _currentLyricIndex = i);
        }
        break;
      }
    }

    if (_isRepeatOn && currentTime >= lyrics[_currentLyricIndex].endTime - 0.2) {
      _youtubeController.seekTo(Duration(
        milliseconds: (lyrics[_currentLyricIndex].startTime * 1000).toInt(),
      ));
    }

    final isPlaying = _youtubeController.value.isPlaying;
    if (_isPlaying != isPlaying) {
      setState(() => _isPlaying = isPlaying);
    }
  }

  void _goToPreviousLyric() {
    if (_currentLyricIndex > 0) {
      setState(() {
        _currentLyricIndex--;
        _currentCardIndex = 0;
      });
      _cardPageController.jumpToPage(0);
      _seekToCurrentLyric();
    }
  }

  void _goToNextLyric() {
    if (_currentLyricIndex < widget.songData.lyricsAnalysis.length - 1) {
      setState(() {
        _currentLyricIndex++;
        _currentCardIndex = 0;
      });
      _cardPageController.jumpToPage(0);
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

  List<_StudyItem> get _currentItems {
    final lyric = widget.songData.lyricsAnalysis[_currentLyricIndex];
    switch (_selectedTab) {
      case 0:
        return lyric.words.map((w) => _StudyItem(w.word, w.meaning, w.example)).toList();
      case 1:
        return lyric.grammar.map((g) => _StudyItem(g.pattern, g.explanation, g.example)).toList();
      case 2:
        return lyric.expressions.map((e) => _StudyItem(e.expression, e.meaning, e.example)).toList();
      default:
        return [];
    }
  }

  @override
  void dispose() {
    _youtubeController.dispose();
    _tabController.dispose();
    _cardPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentLyric = widget.songData.lyricsAnalysis[_currentLyricIndex];
    final totalLyrics = widget.songData.lyricsAnalysis.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: YoutubePlayerBuilder(
        player: YoutubePlayer(
          controller: _youtubeController,
          showVideoProgressIndicator: false,
        ),
        builder: (context, player) {
          return Stack(
            children: [
              // 배경 블러 이미지
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: widget.songData.albumImageUrl,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(color: AppColors.background),
                ),
              ),
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          AppColors.background.withOpacity(0.95),
                          AppColors.background,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 메인 컨텐츠
              SafeArea(
                child: Column(
                  children: [
                    // 헤더
                    _buildHeader(),

                    // YouTube 플레이어
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: player,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 컨트롤 + 가사 영역
                    _buildLyricsSection(currentLyric, totalLyrics),

                    const SizedBox(height: 16),

                    // 학습 탭 + 카드
                    Expanded(
                      child: _buildStudySection(currentLyric),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(LucideIcons.chevronLeft, color: Colors.white),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  widget.songData.title,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  widget.songData.artist,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(LucideIcons.bookmark, color: Colors.white.withOpacity(0.7), size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildLyricsSection(LyricLine lyric, int totalLyrics) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // 가사 원문 + 번역
          Text(
            lyric.original,
            style: AppTextStyles.titleMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            lyric.translated,
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // 컨트롤 바
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 이전
              _buildControlBtn(
                icon: LucideIcons.chevronLeft,
                onTap: _currentLyricIndex > 0 ? _goToPreviousLyric : null,
                size: 18,
              ),
              const SizedBox(width: 8),

              // 되감기
              _buildControlBtn(
                icon: LucideIcons.skipBack,
                onTap: _restartSection,
              ),
              const SizedBox(width: 8),

              // 재생/일시정지
              GestureDetector(
                onTap: _togglePlay,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.accent500, AppColors.accent600],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent500.withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isPlaying ? LucideIcons.pause : LucideIcons.play,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // 반복
              _buildControlBtn(
                icon: LucideIcons.repeat,
                onTap: _toggleRepeat,
                isActive: _isRepeatOn,
              ),
              const SizedBox(width: 8),

              // 다음
              _buildControlBtn(
                icon: LucideIcons.chevronRight,
                onTap: _currentLyricIndex < totalLyrics - 1 ? _goToNextLyric : null,
                size: 18,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 진행률
          Text(
            '${_currentLyricIndex + 1} / $totalLyrics',
            style: AppTextStyles.labelSmall.copyWith(
              color: Colors.white.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlBtn({
    required IconData icon,
    VoidCallback? onTap,
    bool isActive = false,
    double size = 16,
  }) {
    final isEnabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.accent500.withOpacity(0.3)
              : Colors.white.withOpacity(isEnabled ? 0.1 : 0.05),
          shape: BoxShape.circle,
          border: isActive ? Border.all(color: AppColors.accent500, width: 1.5) : null,
        ),
        child: Icon(
          icon,
          color: isActive
              ? AppColors.accent500
              : Colors.white.withOpacity(isEnabled ? 0.8 : 0.3),
          size: size,
        ),
      ),
    );
  }

  Widget _buildStudySection(LyricLine lyric) {
    final items = _currentItems;

    return Column(
      children: [
        // 탭 바
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    _buildTab(0, '📚', '단어', lyric.words.length),
                    _buildTab(1, '📖', '문법', lyric.grammar.length),
                    _buildTab(2, '🗣️', '표현', lyric.expressions.length),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 카드 영역
        Expanded(
          child: items.isEmpty
              ? _buildEmptyState()
              : Column(
            children: [
              // 스와이프 카드
              Expanded(
                child: PageView.builder(
                  controller: _cardPageController,
                  onPageChanged: (i) => setState(() => _currentCardIndex = i),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return AnimatedBuilder(
                      animation: _cardPageController,
                      builder: (context, child) {
                        double scale = 1.0;
                        double opacity = 1.0;
                        if (_cardPageController.position.haveDimensions) {
                          final diff = (_cardPageController.page! - index).abs();
                          scale = (1 - (diff * 0.08)).clamp(0.92, 1.0);
                          opacity = (1 - (diff * 0.3)).clamp(0.6, 1.0);
                        }
                        return Transform.scale(
                          scale: scale,
                          child: Opacity(
                            opacity: opacity,
                            child: _buildGlassCard(items[index]),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              // 도트 인디케이터 + 네비게이션
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 이전
                    GestureDetector(
                      onTap: _currentCardIndex > 0
                          ? () => _cardPageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                      )
                          : null,
                      child: Icon(
                        LucideIcons.chevronLeft,
                        size: 20,
                        color: _currentCardIndex > 0
                            ? Colors.white.withOpacity(0.6)
                            : Colors.white.withOpacity(0.2),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // 도트
                    Row(
                      children: List.generate(
                        items.length,
                            (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: _currentCardIndex == i ? 20 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentCardIndex == i
                                ? AppColors.accent500
                                : Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // 다음
                    GestureDetector(
                      onTap: _currentCardIndex < items.length - 1
                          ? () => _cardPageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                      )
                          : null,
                      child: Icon(
                        LucideIcons.chevronRight,
                        size: 20,
                        color: _currentCardIndex < items.length - 1
                            ? Colors.white.withOpacity(0.6)
                            : Colors.white.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTab(int index, String emoji, String label, int count) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _tabController.animateTo(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 2),
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.inbox, size: 40, color: Colors.white.withOpacity(0.3)),
          const SizedBox(height: 12),
          Text(
            '이 구간에 학습할 항목이 없어요',
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard(_StudyItem item) {
    final isSaved = _savedItems.contains(item.title);
    final isHidden = _hiddenItems.contains(item.title);
    final color = _selectedTab == 0
        ? AppColors.accent500
        : _selectedTab == 1
        ? AppColors.primary500
        : AppColors.secondary500;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.15),
                  Colors.white.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 헤더
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: AppTextStyles.titleMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.subtitle,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: color,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // 버튼들
                      Row(
                        children: [
                          _buildCardBtn(
                            icon: isSaved ? LucideIcons.check : LucideIcons.bookmark,
                            isActive: isSaved,
                            activeColor: color,
                            onTap: () => _toggleSave(item.title),
                          ),
                          const SizedBox(width: 8),
                          _buildCardBtn(
                            icon: LucideIcons.eyeOff,
                            isActive: isHidden,
                            activeColor: AppColors.error,
                            onTap: () => _toggleHide(item.title),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const Spacer(),

                  // 예문
                  if (item.example.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                LucideIcons.lightbulb,
                                size: 14,
                                color: Colors.white.withOpacity(0.5),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '예문',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: Colors.white.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.example,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white.withOpacity(0.8),
                              height: 1.5,
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
      ),
    );
  }

  Widget _buildCardBtn({
    required IconData icon,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive ? activeColor : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: isActive ? null : Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isActive ? Colors.white : Colors.white.withOpacity(0.6),
        ),
      ),
    );
  }
}

class _StudyItem {
  final String title;
  final String subtitle;
  final String example;

  const _StudyItem(this.title, this.subtitle, this.example);
}