import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:melodic_app/core/theme/app_colors.dart';

class LyricsScreen extends StatefulWidget {
  final String id;
  final String title;
  final String artist;
  final String? albumCover;

  const LyricsScreen({
    super.key,
    required this.id,
    required this.title,
    required this.artist,
    this.albumCover,
  });

  @override
  State<LyricsScreen> createState() => _LyricsScreenState();
}

class _LyricsScreenState extends State<LyricsScreen> {
  int _currentLineIndex = 0;
  bool _isPlaying = false;

  // 임시 가사 데이터
  final List<_LyricLine> _lyrics = [
    _LyricLine(
      original: '君の夢が叶うのは',
      translated: '네 꿈이 이루어지는 건',
      romanized: 'Kimi no yume ga kanau no wa',
      timestamp: Duration(seconds: 0),
    ),
    _LyricLine(
      original: '誰かの影になれたとき',
      translated: '누군가의 그림자가 되었을 때',
      romanized: 'Dareka no kage ni nareta toki',
      timestamp: Duration(seconds: 5),
    ),
    _LyricLine(
      original: '僕の幸せは',
      translated: '나의 행복은',
      romanized: 'Boku no shiawase wa',
      timestamp: Duration(seconds: 10),
    ),
    _LyricLine(
      original: '君が僕を忘れる事',
      translated: '네가 나를 잊는 것',
      romanized: 'Kimi ga boku wo wasureru koto',
      timestamp: Duration(seconds: 15),
    ),
    _LyricLine(
      original: 'ベテルギウスのように',
      translated: '베텔게우스처럼',
      romanized: 'Beterugiusu no you ni',
      timestamp: Duration(seconds: 20),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          // 배경 이미지 (블러)
          if (widget.albumCover != null)
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: widget.albumCover!,
                fit: BoxFit.cover,
                color: Colors.black.withOpacity(0.7),
                colorBlendMode: BlendMode.darken,
              ),
            ),

          // 메인 컨텐츠
          SafeArea(
            child: Column(
              children: [
                // 앱바
                _buildAppBar(context),

                // 비디오 플레이어 영역
                _buildVideoPlayer(),

                // 가사 영역
                Expanded(
                  child: _buildLyricsSection(),
                ),

                // 하단 컨트롤
                _buildBottomControls(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          // 뒤로가기
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(
              LucideIcons.chevronLeft,
              color: AppColors.textPrimary,
              size: 24,
            ),
          ),

          // 제목
          Expanded(
            child: Column(
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  widget.artist,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // 더보기 메뉴
          IconButton(
            onPressed: () {
              // TODO: 메뉴 표시
            },
            icon: const Icon(
              LucideIcons.moreVertical,
              color: AppColors.textPrimary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // 임시 플레이스홀더
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  LucideIcons.youtube,
                  size: 48,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(height: 8),
                Text(
                  'YouTube 플레이어',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),

          // 플레이 버튼 오버레이
          Positioned.fill(
            child: Center(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isPlaying = !_isPlaying;
                  });
                },
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isPlaying ? LucideIcons.pause : LucideIcons.play,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLyricsSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: ListView.builder(
        itemCount: _lyrics.length,
        itemBuilder: (context, index) {
          final lyric = _lyrics[index];
          final isCurrentLine = index == _currentLineIndex;

          return GestureDetector(
            onTap: () {
              setState(() {
                _currentLineIndex = index;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isCurrentLine
                    ? AppColors.primary500.withOpacity(0.15)
                    : AppColors.backgroundCard.withOpacity(0.6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isCurrentLine
                      ? AppColors.primary500.withOpacity(0.5)
                      : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 원문
                  Text(
                    lyric.original,
                    style: TextStyle(
                      fontSize: isCurrentLine ? 20 : 18,
                      fontWeight: isCurrentLine ? FontWeight.w700 : FontWeight.w600,
                      color: isCurrentLine
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // 로마자 발음
                  Text(
                    lyric.romanized,
                    style: TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: isCurrentLine
                          ? AppColors.primary400
                          : AppColors.textTertiary,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // 번역
                  Text(
                    lyric.translated,
                    style: TextStyle(
                      fontSize: 15,
                      color: isCurrentLine
                          ? AppColors.textPrimary
                          : AppColors.textTertiary,
                    ),
                  ),

                  // 액션 버튼 (현재 라인일 때만)
                  if (isCurrentLine) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildActionChip(
                          icon: LucideIcons.bookOpen,
                          label: '단어 분석',
                          onTap: () {},
                        ),
                        const SizedBox(width: 8),
                        _buildActionChip(
                          icon: LucideIcons.bookmark,
                          label: '저장',
                          onTap: () {},
                        ),
                        const SizedBox(width: 8),
                        _buildActionChip(
                          icon: LucideIcons.repeat,
                          label: '반복',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceMedium,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: AppColors.primary400,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        border: Border(
          top: BorderSide(
            color: AppColors.borderMedium.withOpacity(0.5),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // 이전
            _buildControlButton(
              icon: LucideIcons.skipBack,
              onTap: () {
                if (_currentLineIndex > 0) {
                  setState(() {
                    _currentLineIndex--;
                  });
                }
              },
            ),

            // 재생/일시정지
            GestureDetector(
              onTap: () {
                setState(() {
                  _isPlaying = !_isPlaying;
                });
              },
              child: Container(
                width: 64,
                height: 64,
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
                child: Icon(
                  _isPlaying ? LucideIcons.pause : LucideIcons.play,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),

            // 다음
            _buildControlButton(
              icon: LucideIcons.skipForward,
              onTap: () {
                if (_currentLineIndex < _lyrics.length - 1) {
                  setState(() {
                    _currentLineIndex++;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.surfaceMedium,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: AppColors.textPrimary,
          size: 22,
        ),
      ),
    );
  }
}

class _LyricLine {
  final String original;
  final String translated;
  final String romanized;
  final Duration timestamp;

  _LyricLine({
    required this.original,
    required this.translated,
    required this.romanized,
    required this.timestamp,
  });
}
