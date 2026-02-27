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
  CaptionSource? _captionSource;
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
    // 50ms 간격으로 더 빠르게 체크
    _positionTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      _updateCurrentCaption();
    });
  }

  void _updateCurrentCaption() {
    if (_youtubeController == null || _captions == null || _captions!.isEmpty) return;

    final positionMs = (_youtubeController!.value.position.inMilliseconds).toDouble();

    // ==========================================
    // 1. 구간 반복 모드 방어 로직 (오버랩 체인 방지)
    // ==========================================
    if (_isRepeatMode && _currentCaptionIndex >= 0) {
      final currentCaption = _captions![_currentCaptionIndex];
      final endMs = currentCaption.startMs + currentCaption.durationMs;

      // 끝나기 300ms 전에 미리 처음으로 이동 (버퍼링 방지)
      if (positionMs >= endMs - 300 && positionMs < endMs + 100) {
        _youtubeController!.seekTo(Duration(milliseconds: currentCaption.startMs));
        return; // 자막 인덱스 변경 방지
      }

      // [핵심 방어선] 구간 반복 중에는 현재 가사의 시간 범위 안에 있다면 절대 인덱스를 바꾸지 않고 '고정(Lock)' 합니다!
      // 오버랩 구간에 진입해도 다른 가사로 튕기는 것을 완벽하게 막아줍니다.
      if (positionMs >= currentCaption.startMs - 500 && positionMs <= endMs) {
        return;
      }
    }

    // ==========================================
    // 2. 일반 재생 모드 로직 (역순 탐색)
    // ==========================================
    int newIndex = -1;

    // [핵심 변경] 앞에서부터 찾지 않고 리스트의 '끝'에서부터 거꾸로 찾습니다!
    // 이렇게 하면 1번 가사와 2번 가사가 겹치는 1.8초 구간에 진입했을 때,
    // 예전 가사(1번)로 돌아가지 않고 무조건 새로 시작하는 가사(2번)를 우선적으로 잡습니다.
    for (int i = _captions!.length - 1; i >= 0; i--) {
      final caption = _captions![i];
      if (positionMs >= caption.startMs && positionMs < caption.startMs + caption.durationMs) {
        newIndex = i;
        break;
      }
    }

    if (newIndex != -1 && newIndex != _currentCaptionIndex) {
      setState(() {
        _currentCaptionIndex = newIndex;
      });

      // 자동 스크롤
      _scrollToCaption(newIndex);
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

    // 재생 중이었으면 계속 재생
    if (wasPlaying) {
      _youtubeController!.play();
    }
  }

  void _previousCaption() {
    if (_currentCaptionIndex > 0) {
      _seekToCaption(_currentCaptionIndex - 1);
    } else if (_captions != null && _captions!.isNotEmpty) {
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.track.name,
                  style: AppTextStyles.titleSmall.copyWith(color: AppColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  widget.track.artistName,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // 자막 소스 표시
          if (_captionSource != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _captionSource == CaptionSource.youtube
                    ? Colors.red.withOpacity(0.2)
                    : AppColors.accent500.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _captionSource == CaptionSource.youtube
                        ? LucideIcons.youtube
                        : LucideIcons.sparkles,
                    size: 14,
                    color: _captionSource == CaptionSource.youtube
                        ? Colors.red
                        : AppColors.accent500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _captionSource == CaptionSource.youtube ? 'YouTube' : 'AI',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: _captionSource == CaptionSource.youtube
                          ? Colors.red
                          : AppColors.accent500,
                    ),
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
          const SizedBox(height: 16),
          Text(
            '영상을 찾고 있습니다...',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
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
            const Icon(LucideIcons.alertCircle, size: 48, color: AppColors.textTertiary),
            const SizedBox(height: 16),
            Text(
              '오류가 발생했습니다',
              style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
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
    // 스마트 자막 로드 (YouTube 자막 없으면 AI 생성)
    final captionAsync = ref.watch(smartCaptionProvider(SmartCaptionParams(
      videoId: result.videoId!,
      artist: widget.track.artistName,
      title: widget.track.name,
    )));

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
            loading: () => _buildCaptionLoadingState(),
            error: (e, _) => _buildNoCaptionState(),
            data: (captionResult) {
              if (captionResult == null || captionResult.captions.isEmpty) {
                return _buildNoCaptionState();
              }
              _captions = captionResult.captions;

              // 자막 소스 업데이트 (한 번만)
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_captionSource != captionResult.source) {
                  setState(() {
                    _captionSource = captionResult.source;
                  });
                }
              });

              return _buildCaptionList(captionResult.captions);
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

  Widget _buildCaptionLoadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.accent500),
          const SizedBox(height: 16),
          Text(
            '자막을 불러오는 중...',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'YouTube 자막이 없으면 AI가 생성합니다\n(최대 2-3분 소요)',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary),
            textAlign: TextAlign.center,
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
              '자막을 불러올 수 없습니다',
              style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'YouTube 자막이 없고\n가사 정보도 찾을 수 없습니다.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.invalidate(smartCaptionProvider(SmartCaptionParams(
                  videoId: _currentVideoId!,
                  artist: widget.track.artistName,
                  title: widget.track.name,
                )));
              },
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
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    caption.formattedStart,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isCurrentCaption ? Colors.white : AppColors.textTertiary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // 가사 텍스트
                Expanded(
                  child: Text(
                    caption.text,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: isCurrentCaption ? AppColors.textPrimary : AppColors.textSecondary,
                      fontWeight: isCurrentCaption ? FontWeight.w600 : FontWeight.normal,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}