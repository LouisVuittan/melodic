import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/itunes_service.dart';
import '../core/services/youtube_service.dart';
import '../core/services/video_cache_service.dart';
import '../core/services/video_matcher_service.dart';
import '../core/services/artist_image_service.dart';
import '../core/services/caption_service.dart';

/// iTunes 서비스 프로바이더 (API 키 불필요!)
final iTunesServiceProvider = Provider<iTunesService>((ref) {
  return iTunesService();
});

/// 일본 Top 100 차트 프로바이더
final japanTopChartProvider = FutureProvider<List<iTunesTrack>>((ref) async {
  final service = ref.watch(iTunesServiceProvider);
  return service.getJapanTopChart(limit: 50);
});

/// 오늘의 추천곡 (1위 곡)
final featuredTrackProvider = FutureProvider<iTunesTrack?>((ref) async {
  final chart = await ref.watch(japanTopChartProvider.future);
  if (chart.isEmpty) return null;
  return chart.first; // 1위 곡
});

/// 현재 선택된 트랙
final selectedTrackProvider = StateProvider<iTunesTrack?>((ref) => null);

/// 하단 네비게이션 인덱스
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

/// 학습 진행률 (임시 - 나중에 로컬 저장소와 연동)
final learningProgressProvider = StateProvider<Map<String, double>>((ref) => {});

/// 저장된 노래 목록
final savedSongsProvider = StateProvider<List<iTunesTrack>>((ref) => []);

/// 최근 검색어
final recentSearchesProvider = StateProvider<List<String>>((ref) => []);

// ============ 아티스트 이미지 관련 Providers ============

/// 아티스트 이미지 서비스 프로바이더 (Deezer API)
final artistImageServiceProvider = Provider<ArtistImageService>((ref) {
  return ArtistImageService();
});

/// 아티스트 이미지 URL Provider
final artistImageProvider = FutureProvider.family<String?, String>((ref, artistName) async {
  final service = ref.read(artistImageServiceProvider);
  return service.getArtistImageUrl(artistName);
});

// ============ 영상 매칭 관련 Providers ============

/// YouTube 서비스 프로바이더 (YouTube API + Gemini 하이브리드)
final youtubeServiceProvider = Provider<YouTubeService>((ref) {
  return YouTubeService();
});

/// 영상 캐시 서비스 프로바이더
final videoCacheServiceProvider = Provider<VideoCacheService>((ref) {
  return VideoCacheService();
});

/// 영상 매칭 서비스 프로바이더
final videoMatcherServiceProvider = Provider<VideoMatcherService>((ref) {
  return VideoMatcherService(
    youtubeService: ref.read(youtubeServiceProvider),
    cacheService: ref.read(videoCacheServiceProvider),
  );
});

/// 트랙에 대한 YouTube 영상 매칭 Provider
/// 캐시 확인 → 없으면 YouTube + Gemini로 검색
final videoMatchProvider = FutureProvider.family<VideoMatchResult, iTunesTrack>((ref, track) async {
  final matcher = ref.read(videoMatcherServiceProvider);
  await matcher.init();
  return matcher.findVideoForTrack(track);
});

// ============ 자막 관련 Providers ============

/// 자막 서비스 프로바이더
final captionServiceProvider = Provider<CaptionService>((ref) {
  return CaptionService();
});

/// 비디오 ID로 자막 가져오기
final captionProvider = FutureProvider.family<List<LyricCaption>?, String>((ref, videoId) async {
  final service = ref.read(captionServiceProvider);
  return service.getCaptions(videoId);
});