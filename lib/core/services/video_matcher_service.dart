import 'package:flutter/foundation.dart';
import 'youtube_service.dart';
import 'video_cache_service.dart';
import 'itunes_service.dart';

/// 영상 매칭 서비스
/// 캐시 확인 → 없으면 YouTube 검색 → 캐시 저장
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
  /// 캐시 히트 시 빠르게 반환, 없으면 API 검색
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
      );
    }

    // 2. YouTube 검색
    debugPrint('[VideoMatcher] 캐시 미스, YouTube 검색 시작...');

    final result = await _youtubeService.findBestMatch(
      trackName: track.name,
      artistName: track.artistName,
      trackDurationMs: track.durationMs,
    );

    stopwatch.stop();

    if (result == null) {
      debugPrint('[VideoMatcher] 매칭 실패 (${stopwatch.elapsedMilliseconds}ms)');
      return VideoMatchResult.notFound();
    }

    // 3. 캐시 저장
    final cachedVideo = CachedVideo(
      videoId: result.video.videoId,
      title: result.video.title,
      channelTitle: result.video.channelTitle,
      thumbnailUrl: result.video.thumbnailUrl,
      durationMs: result.video.durationMs,
      matchScore: result.score,
      cachedAt: DateTime.now(),
    );

    await _cacheService.save(track.id, cachedVideo);

    debugPrint('[VideoMatcher] 매칭 완료! (${stopwatch.elapsedMilliseconds}ms)');
    debugPrint('[VideoMatcher] → ${result.video.title} (${result.score}점)');

    return VideoMatchResult(
      videoId: result.video.videoId,
      title: result.video.title,
      channelTitle: result.video.channelTitle,
      thumbnailUrl: result.video.thumbnailUrl,
      durationMs: result.video.durationMs,
      matchScore: result.score,
      fromCache: false,
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

  VideoMatchResult({
    this.videoId,
    this.title,
    this.channelTitle,
    this.thumbnailUrl,
    this.durationMs = 0,
    this.matchScore = 0,
    this.fromCache = false,
  }) : found = videoId != null;

  factory VideoMatchResult.notFound() {
    return VideoMatchResult();
  }

  /// YouTube 영상 URL
  String? get youtubeUrl => videoId != null
      ? 'https://www.youtube.com/watch?v=$videoId'
      : null;

  @override
  String toString() => 'VideoMatchResult(found: $found, videoId: $videoId, score: $matchScore)';
}