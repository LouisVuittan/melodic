import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';

/// 가사 라인 모델
class LyricLine {
  final String original;
  final String? translated;
  final double startTime;
  final double endTime;
  final List<String> words;
  final List<String> grammar;

  LyricLine({
    required this.original,
    this.translated,
    required this.startTime,
    required this.endTime,
    this.words = const [],
    this.grammar = const [],
  });
}

/// 가사 학습 화면
class LyricsScreen extends StatefulWidget {
  final String videoId;
  final String title;
  final String artist;
  final String? coverUrl;

  const LyricsScreen({
    super.key,
    required this.videoId,
    required this.title,
    required this.artist,
    this.coverUrl,
  });

  @override
  State<LyricsScreen> createState() => _LyricsScreenState();
}

class _LyricsScreenState extends State<LyricsScreen> {
  bool _isLoading = true;
  bool _isFavorite = false;
  int _currentLineIndex = 0;
  double _currentTime = 0;
  bool _showTranslation = true;

  // TODO: 실제 가사 데이터 연동
  final List<LyricLine> _lyrics = [
    LyricLine(
      original: 'Is it the look in your eyes',
      translated: '그건 네 눈빛인가요',
      startTime: 0,
      endTime: 3,
      words: ['look', 'eyes'],
    ),
    LyricLine(
      original: 'Or is it this dancing juice',
      translated: '아니면 이 춤추는 술인가요',
      startTime: 3,
      endTime: 6,
      words: ['dancing', 'juice'],
    ),
    LyricLine(
      original: 'Who cares baby, I think I wanna marry you',
      translated: '상관없어요, 당신과 결혼하고 싶어요',
      startTime: 6,
      endTime: 10,
      words: ['marry'],
      grammar: ['wanna'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadLyrics();
  }

  Future<void> _loadLyrics() async {
    // TODO: 실제 가사 로딩 로직
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      _isLoading = false;
    });
  }

  void _onTimeUpdate(double time) {
    setState(() {
      _currentTime = time;
      // 현재 시간에 해당하는 가사 라인 찾기
      for (int i = 0; i < _lyrics.length; i++) {
        if (time >= _lyrics[i].startTime && time < _lyrics[i].endTime) {
          _currentLineIndex = i;
          break;
        }
      }
    });
  }

  void _onLineTap(int index) {
    // TODO: 해당 시간으로 영상 이동
    setState(() {
      _currentLineIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            _buildHeader(),

            // YouTube 플레이어 영역
            _buildVideoPlayer(),

            // 가사 영역
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.accent500,
                      ),
                    )
                  : _buildLyricsSection(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: [
          // 뒤로가기
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(LucideIcons.chevronLeft, color: Colors.white),
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
                Text(
                  widget.artist,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // 좋아요
          IconButton(
            onPressed: () {
              setState(() {
                _isFavorite = !_isFavorite;
              });
            },
            icon: Icon(
              _isFavorite ? LucideIcons.heart : LucideIcons.heart,
              color: _isFavorite ? AppColors.error : AppColors.gray400,
            ),
          ),

          // 더보기
          IconButton(
            onPressed: () {
              _showOptionsSheet();
            },
            icon: const Icon(LucideIcons.moreVertical, color: AppColors.gray400),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return Container(
      color: Colors.black,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 배경 (앨범 커버 또는 플레이스홀더)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.gray800,
                    AppColors.gray900,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LucideIcons.youtube,
                      size: 48,
                      color: Colors.red.withOpacity(0.8),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'YouTube 플레이어',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // TODO: 실제 YouTube 플레이어 위젯
            // YouTubePlayer(
            //   videoId: widget.videoId,
            //   onTimeUpdate: _onTimeUpdate,
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildLyricsSection() {
    return Column(
      children: [
        // 컨트롤 바
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(
              bottom: BorderSide(color: AppColors.border),
            ),
          ),
          child: Row(
            children: [
              // 번역 토글
              InkWell(
                onTap: () {
                  setState(() {
                    _showTranslation = !_showTranslation;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _showTranslation
                        ? AppColors.accent500.withOpacity(0.1)
                        : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.languages,
                        size: 16,
                        color: _showTranslation
                            ? AppColors.accent400
                            : AppColors.gray400,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '번역',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: _showTranslation
                              ? AppColors.accent400
                              : AppColors.gray400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),

              // 가사 소스 표시
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      '📝',
                      style: TextStyle(fontSize: 12),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Genius',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.purple,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 가사 리스트
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: _lyrics.length,
            itemBuilder: (context, index) {
              return _LyricLineWidget(
                line: _lyrics[index],
                isActive: index == _currentLineIndex,
                showTranslation: _showTranslation,
                onTap: () => _onLineTap(index),
                onWordTap: (word) => _showWordDetail(word),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showOptionsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 핸들
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.gray600,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              ListTile(
                leading: const Icon(LucideIcons.share2, color: AppColors.gray400),
                title: const Text('공유하기'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.download, color: AppColors.gray400),
                title: const Text('가사 저장하기'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.flag, color: AppColors.gray400),
                title: const Text('가사 오류 신고'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showWordDetail(String word) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.3,
        maxChildSize: 0.7,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 핸들
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.gray600,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 단어
              Text(
                word,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),

              // 발음 (예시)
              const Text(
                '/wɜːrd/',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.accent400,
                ),
              ),
              const SizedBox(height: 16),

              // 의미 (예시)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '테스트중입니다\n실제 AI 분석 결과가 여기에 표시됩니다.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 버튼들
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: 단어장에 추가
                        Navigator.pop(context);
                      },
                      icon: const Icon(LucideIcons.plus, size: 18),
                      label: const Text('단어장에 추가'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: () {
                      // TODO: 숨기기
                      Navigator.pop(context);
                    },
                    child: const Icon(LucideIcons.eyeOff, size: 18),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LyricLineWidget extends StatelessWidget {
  final LyricLine line;
  final bool isActive;
  final bool showTranslation;
  final VoidCallback? onTap;
  final ValueChanged<String>? onWordTap;

  const _LyricLineWidget({
    required this.line,
    this.isActive = false,
    this.showTranslation = true,
    this.onTap,
    this.onWordTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.accent500.withOpacity(0.1)
              : Colors.transparent,
          border: isActive
              ? const Border(
                  left: BorderSide(
                    color: AppColors.accent500,
                    width: 3,
                  ),
                )
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 원문 가사
            _buildHighlightedText(
              line.original,
              line.words,
              isActive,
            ),

            // 번역
            if (showTranslation && line.translated != null) ...[
              const SizedBox(height: 6),
              Text(
                line.translated!,
                style: TextStyle(
                  fontSize: 14,
                  color: isActive
                      ? AppColors.accent300
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightedText(
    String text,
    List<String> highlights,
    bool isActive,
  ) {
    // 간단한 하이라이트 구현
    // TODO: 더 정교한 하이라이트 로직
    final words = text.split(' ');
    
    return Wrap(
      children: words.map((word) {
        final isHighlight = highlights.any(
          (h) => word.toLowerCase().contains(h.toLowerCase()),
        );

        return GestureDetector(
          onTap: () => onWordTap?.call(word),
          child: Container(
            margin: const EdgeInsets.only(right: 4),
            padding: isHighlight
                ? const EdgeInsets.symmetric(horizontal: 2)
                : EdgeInsets.zero,
            decoration: isHighlight
                ? BoxDecoration(
                    color: AppColors.accent500.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  )
                : null,
            child: Text(
              word,
              style: TextStyle(
                fontSize: isActive ? 18 : 16,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
