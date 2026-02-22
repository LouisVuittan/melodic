import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/services/itunes_service.dart';
import '../../core/services/video_matcher_service.dart';
import '../../core/services/caption_service.dart';
import '../../providers/app_providers.dart';

/// 트랙 기반 학습 페이지
/// iTunes 트랙 정보 → YouTube 영상 매칭 → 자막 학습
class TrackLearningPage extends ConsumerStatefulWidget {
  final iTunesTrack track;

  const TrackLearningPage({
    super.key,
    required this.track,
  });

  @override
  ConsumerState<TrackLearningPage> createState() => _TrackLearningPageState();
}

class _TrackLearningPageState extends ConsumerState<TrackLearningPage> {
  YoutubePlayerController? _youtubeController;
  bool _isPlayerReady = false;
  String? _currentVideoId;

  // 자막 관련 상태
  List<LyricCaption>? _captions;
  int _currentCaptionIndex = -1;
  bool _isRepeatMode = false;
  Timer? _positionTimer;

  // 스크롤 컨트롤러
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _positionTimer?.cancel();
    _youtubeController?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _initYoutubePlayer(String videoId) {
    if (_youtubeController != null && _currentVideoId == videoId) return;

    _currentVideoId = videoId;
    _youtubeController?.dispose();

    _youtubeController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        enableCaption: false, // 우리 자막 사용
        forceHD: false,
        isLive: false,
      ),
    )..addListener(_onPlayerStateChange);

    // 포지션 추적 타이머 시작
    _startPositionTimer();
  }

  void _onPlayerStateChange() {
    if (_youtubeController == null) return;

    final value = _youtubeController!.value;

    if (value.isReady && !_isPlayerReady) {
      setState(() {
        _isPlayerReady = true;
      });
    }
  }

  void _startPositionTimer() {
    _positionTimer?.cancel();
    // 50ms 간격으로 더 빠르게 체크 (기존 200ms)
    _positionTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      _updateCurrentCaption();
    });
  }

  void _updateCurrentCaption() {
    if (_youtubeController == null || _captions == null || _captions!.isEmpty) return;

    final positionMs = (_youtubeController!.value.position.inMilliseconds).toDouble();

    // 구간 반복 모드: 끝나기 300ms 전에 미리 처음으로 이동 (버퍼링 방지)
    if (_isRepeatMode && _currentCaptionIndex >= 0) {
      final currentCaption = _captions![_currentCaptionIndex];
      final endMs = currentCaption.startMs + currentCaption.durationMs;

      // 끝나기 300ms 전에 미리 seekTo
      if (positionMs >= endMs - 300 && positionMs < endMs + 100) {
        _youtubeController!.seekTo(Duration(milliseconds: currentCaption.startMs));
        return; // 자막 인덱스 변경 방지
      }
    }

    // 현재 자막 찾기
    int newIndex = -1;
    for (int i = 0; i < _captions!.length; i++) {
      final caption = _captions![i];
      if (positionMs >= caption.startMs && positionMs < caption.startMs + caption.durationMs) {
        newIndex = i;
        break;
      }
    }

    if (newIndex != _currentCaptionIndex) {
      setState(() {
        _currentCaptionIndex = newIndex;
      });

      // 자동 스크롤
      if (newIndex >= 0) {
        _scrollToCaption(newIndex);
      }
    }
  }

  void _scrollToCaption(int index) {
    if (!_scrollController.hasClients) return;

    final itemHeight = 80.0; // 대략적인 아이템 높이
    final targetOffset = index * itemHeight - 100; // 약간 위에 위치하도록

    _scrollController.animateTo(
      targetOffset.clamp(0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _seekToCaption(int index) {
    if (_youtubeController == null || _captions == null) return;
    if (index < 0 || index >= _captions!.length) return;

    final caption = _captions![index];
    final wasPlaying = _youtubeController!.value.playerState == PlayerState.playing;

    // 먼저 상태 업데이트 (UI 반응 빠르게)
    setState(() {
      _currentCaptionIndex = index;
    });

    // seekTo 실행
    _youtubeController!.seekTo(Duration(milliseconds: caption.startMs));

    // 재생 중이었으면 계속 재생 (seekTo 후 일시정지 될 수 있어서)
    if (wasPlaying) {
      _youtubeController!.play();
    }
  }

  void _previousCaption() {
    if (_currentCaptionIndex > 0) {
      _seekToCaption(_currentCaptionIndex - 1);
    } else if (_captions != null && _captions!.isNotEmpty) {
      // 처음이면 현재 구간 처음으로
      _seekToCaption(0);
    }
  }

  void _nextCaption() {
    if (_captions != null && _currentCaptionIndex < _captions!.length - 1) {
      _seekToCaption(_currentCaptionIndex + 1);
    }
  }

  void _toggleRepeatMode() {
    setState(() {
      _isRepeatMode = !_isRepeatMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final videoMatchAsync = ref.watch(videoMatchProvider(widget.track));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: videoMatchAsync.when(
                loading: () => _buildLoadingState(),
                error: (e, _) => _buildErrorState(e.toString()),
                data: (result) {
                  if (!result.found) {
                    return _buildNotFoundState();
                  }
                  _initYoutubePlayer(result.videoId!);
                  return _buildContent(result);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textPrimary),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.track.name,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  widget.track.artistName,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.accent500),
          const SizedBox(height: 24),
          Text(
            '영상을 찾고 있어요...',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
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
            const Icon(LucideIcons.alertTriangle, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              '영상을 불러올 수 없습니다',
              style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(error, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(videoMatchProvider(widget.track)),
              icon: const Icon(LucideIcons.refreshCw, size: 18),
              label: const Text('다시 시도'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent500,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFoundState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.videoOff, size: 48, color: AppColors.textTertiary),
            const SizedBox(height: 16),
            Text(
              '영상을 찾을 수 없습니다',
              style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(VideoMatchResult result) {
    // 자막 로드
    final captionAsync = ref.watch(captionProvider(result.videoId!));

    return Column(
      children: [
        // YouTube 플레이어
        if (_youtubeController != null)
          AspectRatio(
            aspectRatio: 16 / 9,
            child: YoutubePlayerBuilder(
              player: YoutubePlayer(
                controller: _youtubeController!,
                showVideoProgressIndicator: true,
                progressIndicatorColor: AppColors.accent500,
              ),
              builder: (context, player) => player,
            ),
          ),

        // 컨트롤 바
        _buildControlBar(),

        // 자막 영역
        Expanded(
          child: captionAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.accent500),
            ),
            error: (e, _) => _buildNoCaptionState(),
            data: (captions) {
              if (captions == null || captions.isEmpty) {
                return _buildNoCaptionState();
              }
              _captions = captions;
              return _buildCaptionList(captions);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildControlBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppColors.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 이전 구간
          IconButton(
            onPressed: _previousCaption,
            icon: const Icon(LucideIcons.skipBack),
            color: AppColors.textPrimary,
            tooltip: '이전 구간',
          ),

          const SizedBox(width: 16),

          // 구간 반복
          Container(
            decoration: BoxDecoration(
              color: _isRepeatMode ? AppColors.accent500 : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _isRepeatMode ? AppColors.accent500 : AppColors.textTertiary,
              ),
            ),
            child: IconButton(
              onPressed: _toggleRepeatMode,
              icon: const Icon(LucideIcons.repeat1),
              color: _isRepeatMode ? Colors.white : AppColors.textTertiary,
              tooltip: '구간 반복',
            ),
          ),

          const SizedBox(width: 16),

          // 다음 구간
          IconButton(
            onPressed: _nextCaption,
            icon: const Icon(LucideIcons.skipForward),
            color: AppColors.textPrimary,
            tooltip: '다음 구간',
          ),
        ],
      ),
    );
  }

  Widget _buildNoCaptionState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.subtitles, size: 48, color: AppColors.textTertiary),
            const SizedBox(height: 16),
            Text(
              '자막이 없습니다',
              style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              '이 영상은 자막을 지원하지 않아\n구간 학습이 불가능합니다.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaptionList(List<LyricCaption> captions) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: captions.length,
      itemBuilder: (context, index) {
        final caption = captions[index];
        final isCurrentCaption = index == _currentCaptionIndex;

        return GestureDetector(
          onTap: () => _seekToCaption(index),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isCurrentCaption
                  ? AppColors.accent500.withOpacity(0.15)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: isCurrentCaption
                  ? Border.all(color: AppColors.accent500, width: 2)
                  : null,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 타임스탬프
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isCurrentCaption
                        ? AppColors.accent500
                        : AppColors.textTertiary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    caption.formattedStart,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isCurrentCaption ? Colors.white : AppColors.textSecondary,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // 자막 텍스트
                Expanded(
                  child: Text(
                    caption.text,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isCurrentCaption
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontWeight: isCurrentCaption ? FontWeight.w600 : FontWeight.normal,
                      height: 1.5,
                    ),
                  ),
                ),

                // 현재 재생 중 표시
                if (isCurrentCaption)
                  const Icon(
                    LucideIcons.volume2,
                    size: 18,
                    color: AppColors.accent500,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}