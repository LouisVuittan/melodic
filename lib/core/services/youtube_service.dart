import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

/// YouTube Data API 서비스 - J-Pop & Anime OST 최적화 버전
class YouTubeService {
  final Dio _dio;

  static const List<String> _apiKeys = [
    'AIzaSyANyLYDxQnmS9TGDAlijvCwchUyBYJO6d8',
    'AIzaSyD6uD91NYeitWit30P5bHbSWRefI03EWdg',
  ];

  int _currentKeyIndex = 0;
  static const String _baseUrl = 'https://www.googleapis.com/youtube/v3';

  // [개선] 애니메이션 관련 공식 채널 목록
  static const List<String> _animeOfficialChannels = [
    'Aniplex', 'TOHO animation', 'Lantis', 'KADOKAWA', 'avex', 'flying DOG',
    'Sony Music', 'Warner Bros. Japan', 'ponycanyon', 'Victor Entertainment'
  ];

  // [개선] 제외 키워드 유지 및 강화
  static const List<String> _excludeKeywords = [
    'reaction', 'react', 'cover', 'covered', '歌ってみた', '踊ってみた', 'dance cover',
    'piano', 'guitar', 'drum', 'bass', 'instrumental', 'inst', 'karaoke', '노래방',
    'remix', 'bootleg', 'tutorial', 'lesson', 'fan made', 'fanmade', 'shorts'
  ];

  YouTubeService({Dio? dio}) : _dio = dio ?? Dio();

  String get _currentApiKey => _apiKeys[_currentKeyIndex];

  void _rotateApiKey() {
    _currentKeyIndex = (_currentKeyIndex + 1) % _apiKeys.length;
    debugPrint('[YouTube] API 키 전환: $_currentKeyIndex');
  }

  /// [핵심] 곡에 맞는 최적의 매칭 검색
  Future<YouTubeMatchResult?> findBestMatch({
    required String trackName,
    required String artistName,
    required int trackDurationMs,
    bool isAnimeOST = false, // 애니메이션 곡 여부 플래그 추가
  }) async {
    debugPrint('[YouTube] 검색 시작: $trackName - $artistName');

    // 전략 1: 공식 MV 및 오피셜 키워드 검색 (가장 높은 우선순위)
    final mvResult = await _searchWithStrategy(
      query: '"$trackName" $artistName "Official Music Video" OR "公式MV" OR "公式ミュージックビデオ"',
      trackName: trackName,
      artistName: artistName,
      trackDurationMs: trackDurationMs,
      strategyName: 'Official MV',
    );
    if (mvResult != null && mvResult.score >= 150) return mvResult; // 확정급 점수면 즉시 반환

    // 전략 2: 애니메이션 특화 검색 (요청 시 또는 1단계 실패 시)
    if (isAnimeOST || mvResult == null) {
      final animeResult = await _searchWithStrategy(
        query: '$trackName "$artistName" OP OR ED OR "主題歌" OR "アニメ 公式"',
        trackName: trackName,
        artistName: artistName,
        trackDurationMs: trackDurationMs,
        strategyName: 'Anime OST',
      );
      if (animeResult != null && animeResult.score >= 130) return animeResult;
    }

    // 전략 3: Fallback - 조회수 기반 일반 검색 (검증된 채널 위주)
    return await _searchWithStrategy(
      query: '$trackName $artistName',
      trackName: trackName,
      artistName: artistName,
      trackDurationMs: trackDurationMs,
      strategyName: 'General Fallback',
      useViewCountOrder: true,
    );
  }

  /// 공통 검색 실행 로직
  Future<YouTubeMatchResult?> _searchWithStrategy({
    required String query,
    required String trackName,
    required String artistName,
    required int trackDurationMs,
    required String strategyName,
    bool useViewCountOrder = false,
  }) async {
    try {
      debugPrint('[YouTube] [$strategyName] 시도 중...');
      final videos = await _search(query, order: useViewCountOrder ? 'viewCount' : 'relevance');

      if (videos.isEmpty) return null;

      final filtered = _filterAndScoreVideos(
          videos, trackName, artistName, trackDurationMs, strategyName
      );

      if (filtered.isEmpty) return null;

      // 점수 순 정렬 후 최상단 반환
      filtered.sort((a, b) => b.score.compareTo(a.score));
      return YouTubeMatchResult(
        video: filtered.first.video,
        score: filtered.first.score,
      );
    } catch (e) {
      debugPrint('[YouTube] $strategyName 에러: $e');
      return null;
    }
  }

  /// [개선] 필터링 및 점수화 알고리즘
  List<ScoredVideo> _filterAndScoreVideos(
      List<YouTubeVideo> videos,
      String trackName,
      String artistName,
      int trackDurationMs,
      String strategy,
      ) {
    List<ScoredVideo> results = [];

    for (var video in videos) {
      final title = video.title.toLowerCase();
      final channel = video.channelTitle.toLowerCase();
      int score = 0;

      // 1. 제외 키워드 필터링 (강력 제외)
      if (_excludeKeywords.any((k) => title.contains(k))) continue;

      // 2. [필수] 제목에 곡명 포함 여부 (최소한의 일치)
      if (!title.contains(trackName.toLowerCase())) continue;

      // 3. 점수 가산점 (요청 반영)

      // A. MV 확정 키워드 (즉시 채택급 가산점)
      if (title.contains('official music video') ||
          title.contains('公式mv') ||
          title.contains('promo')) {
        score += 150;
      }

      // B. OST 판별 키워드
      if (title.contains('op') || title.contains('ed') ||
          title.contains('opening') || title.contains('ending') ||
          title.contains('主題歌') || title.contains('ノンクレジット')) {
        score += 80;
      }

      // C. 공식 채널 및 검증된 채널
      if (_animeOfficialChannels.any((c) => channel.contains(c.toLowerCase()))) {
        score += 100; // 대형 애니메이션 제작사 채널
      }
      if (channel.contains('topic') || channel.contains('official')) {
        score += 50;
      }

      // D. 재생 시간 매칭 (10% 이내 오차 시 가산점)
      if (trackDurationMs > 0) {
        final diff = (video.durationMs - trackDurationMs).abs();
        if (diff < 15000) score += 40; // 15초 이내
        else if (diff < 30000) score += 20; // 30초 이내
      }

      // E. 조회수 가산점 (Top 3 영향력)
      if (video.viewCount > 1000000) score += 30;
      else if (video.viewCount > 100000) score += 15;

      results.add(ScoredVideo(video: video, score: score));
    }

    return results;
  }

  /// YouTube API 호출 (기본 파라미터 적용)
  Future<List<YouTubeVideo>> _search(String query, {String order = 'relevance'}) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/search',
        queryParameters: {
          'part': 'snippet',
          'q': query,
          'type': 'video',
          'videoCategoryId': '10', // Music 카테고리 고정
          'order': order,           // viewCount 또는 relevance
          'maxResults': 10,
          'key': _currentApiKey,
        },
      );

      final items = response.data['items'] as List<dynamic>? ?? [];
      final videoIds = items.map((i) => i['id']['videoId'].toString()).toList();

      if (videoIds.isEmpty) return [];
      return await _getVideoDetails(videoIds);
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        _rotateApiKey();
      }
      return [];
    }
  }

  /// 영상 상세 정보 (ContentDetails에서 재생 시간 획득)
  Future<List<YouTubeVideo>> _getVideoDetails(List<String> videoIds) async {
    final response = await _dio.get(
      '$_baseUrl/videos',
      queryParameters: {
        'part': 'snippet,contentDetails,statistics',
        'id': videoIds.join(','),
        'key': _currentApiKey,
      },
    );

    final items = response.data['items'] as List<dynamic>? ?? [];
    return items.map((item) => YouTubeVideo.fromJson(item)).toList();
  }
}

// --- 모델 클래스 (기존 구조 유지) ---

class YouTubeVideo {
  final String videoId;
  final String title;
  final String channelTitle;
  final int durationMs;
  final int viewCount;
  final String thumbnailUrl;

  YouTubeVideo({
    required this.videoId,
    required this.title,
    required this.channelTitle,
    required this.durationMs,
    required this.viewCount,
    required this.thumbnailUrl,
  });

  factory YouTubeVideo.fromJson(Map<String, dynamic> json) {
    final snippet = json['snippet'];
    final contentDetails = json['contentDetails'];
    final statistics = json['statistics'];

    return YouTubeVideo(
      videoId: json['id'],
      title: snippet['title'],
      channelTitle: snippet['channelTitle'],
      durationMs: _parseDuration(contentDetails['duration']),
      viewCount: int.tryParse(statistics['viewCount'] ?? '0') ?? 0,
      thumbnailUrl: snippet['thumbnails']['high']?['url'] ?? '',
    );
  }

  static int _parseDuration(String duration) {
    final regex = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?');
    final match = regex.firstMatch(duration);
    if (match == null) return 0;
    final h = int.parse(match.group(1) ?? '0');
    final m = int.parse(match.group(2) ?? '0');
    final s = int.parse(match.group(3) ?? '0');
    return (h * 3600 + m * 60 + s) * 1000;
  }
}

class ScoredVideo {
  final YouTubeVideo video;
  final int score;
  ScoredVideo({required this.video, required this.score});
}

class YouTubeMatchResult {
  final YouTubeVideo video;
  final int score;
  YouTubeMatchResult({required this.video, required this.score});
}