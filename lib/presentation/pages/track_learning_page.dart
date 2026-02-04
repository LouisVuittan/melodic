import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/services/itunes_service.dart';
import '../../core/services/video_matcher_service.dart';
import '../../providers/app_providers.dart';

/// 트랙 기반 학습 페이지
/// iTunes 트랙 정보 → YouTube 영상 매칭 → 학습
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

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  void _initYoutubePlayer(String videoId) {
    if (_youtubeController != null) return;

    _youtubeController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        enableCaption: true,
        captionLanguage: 'ja', // 일본어 자막 우선
      ),
    )..addListener(() {
      if (_youtubeController!.value.isReady && !_isPlayerReady) {
        setState(() {
          _isPlayerReady = true;
        });
      }
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
            // 상단 바
            _buildAppBar(context),

            // 영상 영역
            Expanded(
              child: videoMatchAsync.when(
                loading: () => _buildLoadingState(),
                error: (e, _) => _buildErrorState(e.toString()),
                data: (result) {
                  if (!result.found) {
                    return _buildNotFoundState();
                  }

                  // YouTube 플레이어 초기화
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
          const SizedBox(height: 8),
          Text(
            '${widget.track.name} - ${widget.track.artistName}',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textTertiary,
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
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.invalidate(videoMatchProvider(widget.track));
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
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '이 곡의 공식 영상이 YouTube에 없거나\n검색 결과가 없습니다.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(VideoMatchResult result) {
    return Column(
      children: [
        // YouTube 플레이어
        if (_youtubeController != null)
          YoutubePlayerBuilder(
            player: YoutubePlayer(
              controller: _youtubeController!,
              showVideoProgressIndicator: true,
              progressIndicatorColor: AppColors.accent500,
              progressColors: const ProgressBarColors(
                playedColor: AppColors.accent500,
                handleColor: AppColors.accent400,
              ),
            ),
            builder: (context, player) {
              return Column(
                children: [
                  // 영상
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: player,
                  ),

                  // 영상 정보
                  _buildVideoInfo(result),
                ],
              );
            },
          ),

        // 가사 학습 영역 (추후 구현)
        Expanded(
          child: _buildLyricsSection(),
        ),
      ],
    );
  }

  Widget _buildVideoInfo(VideoMatchResult result) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // 캐시 히트 표시
              if (result.fromCache)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.zap, size: 12, color: AppColors.success),
                      const SizedBox(width: 4),
                      Text(
                        '캐시',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),

              // 매칭 스코어
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent500.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '매칭 ${result.matchScore}점',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.accent500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 영상 제목
          Text(
            result.title ?? '',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),

          // 채널명
          Text(
            result.channelTitle ?? '',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLyricsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.music, size: 20, color: AppColors.accent500),
              const SizedBox(width: 8),
              Text(
                '가사 학습',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    LucideIcons.construction,
                    size: 48,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '가사 학습 기능 준비 중...',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '자막 동기화 및 학습 기능이\n곧 추가될 예정입니다.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}