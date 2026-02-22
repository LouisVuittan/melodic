import 'package:flutter/foundation.dart';
import 'youtube_service.dart';
import 'video_cache_service.dart';
import 'itunes_service.dart';

/// 영상 매칭 서비스
/// YouTube + Gemini 하이브리드로 정확한 공식 영상 찾기
class VideoMatcherService {
  final YouTubeService _youtubeService;
  final VideoCacheService _cacheService;

  VideoMatcherService({
    required YouTubeService youtubeService,
    required VideoCacheService cacheService,
  })  : _youtubeService = youtubeService,
        _cacheService = cacheService;

  /// 초기화
  Future<void> init() async {
    await _cacheService.init();
  }

  /// 트랙에 맞는 YouTube 영상 찾기
  Future<VideoMatchResult> findVideoForTrack(iTunesTrack track) async {
    final stopwatch = Stopwatch()..start();

    // 1. 캐시 확인
    final cached = _cacheService.get(track.id);
    if (cached != null) {
      stopwatch.stop();
      debugPrint('[VideoMatcher] 캐시 히트! (${stopwatch.elapsedMilliseconds}ms)');

      return VideoMatchResult(
        videoId: cached.videoId,
        title: cached.title,
        channelTitle: cached.channelTitle,
        thumbnailUrl: cached.thumbnailUrl,
        durationMs: cached.durationMs,
        matchScore: cached.matchScore,
        fromCache: true,
        videoType: 'cached',
      );
    }

    // 2. YouTube + Gemini로 검색
    debugPrint('[VideoMatcher] 캐시 미스, YouTube 검색 시작...');

    final result = await _youtubeService.findOfficialVideo(
      trackName: track.name,
      artistName: track.artistName,
    );

    stopwatch.stop();

    if (result == null) {
      debugPrint('[VideoMatcher] 매칭 실패 (${stopwatch.elapsedMilliseconds}ms)');
      return VideoMatchResult.notFound();
    }

    // 3. 캐시 저장
    final cachedVideo = CachedVideo(
      videoId: result.videoId,
      title: result.title,
      channelTitle: result.channelName,
      thumbnailUrl: 'https://img.youtube.com/vi/${result.videoId}/maxresdefault.jpg',
      durationMs: 0,
      matchScore: result.isMusicVideo ? 100 : 80,
      cachedAt: DateTime.now(),
      videoType: result.type,
    );

    await _cacheService.save(track.id, cachedVideo);

    debugPrint('[VideoMatcher] 매칭 완료! (${stopwatch.elapsedMilliseconds}ms)');
    debugPrint('[VideoMatcher] → ${result.title} (${result.type})');

    return VideoMatchResult(
      videoId: result.videoId,
      title: result.title,
      channelTitle: result.channelName,
      thumbnailUrl: 'https://img.youtube.com/vi/${result.videoId}/maxresdefault.jpg',
      durationMs: 0,
      matchScore: result.isMusicVideo ? 100 : 80,
      fromCache: false,
      videoType: result.type,
    );
  }

  /// 캐시 통계
  int get cacheCount => _cacheService.cacheCount;

  /// 캐시 전체 삭제
  Future<void> clearCache() => _cacheService.clearAll();
}

/// 영상 매칭 결과
class VideoMatchResult {
  final String? videoId;
  final String? title;
  final String? channelTitle;
  final String? thumbnailUrl;
  final int durationMs;
  final int matchScore;
  final bool fromCache;
  final bool found;
  final String videoType; // 'mv', 'audio', 'cached', 'fallback', 'unknown'

  VideoMatchResult({
    this.videoId,
    this.title,
    this.channelTitle,
    this.thumbnailUrl,
    this.durationMs = 0,
    this.matchScore = 0,
    this.fromCache = false,
    this.videoType = 'unknown',
  }) : found = videoId != null;

  factory VideoMatchResult.notFound() {
    return VideoMatchResult();
  }

  /// YouTube 영상 URL
  String? get youtubeUrl => videoId != null
      ? 'https://www.youtube.com/watch?v=$videoId'
      : null;

  /// 뮤직비디오 여부
  bool get isMusicVideo => videoType == 'mv';

  /// 공식 음원 여부
  bool get isOfficialAudio => videoType == 'audio';

  @override
  String toString() => 'VideoMatchResult(found: $found, videoId: $videoId, type: $videoType)';
}