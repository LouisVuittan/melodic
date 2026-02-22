import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
/// 하이브리드 영상 검색 서비스
/// YouTube API로 조회수 상위 5개 검색 → Gemini가 최적 영상 선택
class YouTubeService {
  final Dio _dio;

  // API Keys
  static String get _geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  static List<String> get _youtubeApiKeys => [
    dotenv.env['YOUTUBE_KEY_PRIMARY'] ?? '',
    dotenv.env['YOUTUBE_KEY_SECONDARY'] ?? '',
  ];
  int _currentYoutubeKeyIndex = 0;

  // API URLs
  static const String _geminiUrl = 'https://generativelanguage.googleapis.com/v1beta';
  static const String _youtubeUrl = 'https://www.googleapis.com/youtube/v3';
  static const String _geminiModel = 'gemini-3-flash-preview';

  YouTubeService({Dio? dio}) : _dio = dio ?? Dio();

  String get _currentYoutubeKey => _youtubeApiKeys[_currentYoutubeKeyIndex];

  void _rotateYoutubeKey() {
    _currentYoutubeKeyIndex = (_currentYoutubeKeyIndex + 1) % _youtubeApiKeys.length;
    debugPrint('[YouTube] API 키 전환: $_currentYoutubeKeyIndex');
  }

  /// 곡에 맞는 YouTube 영상 찾기 (하이브리드)
  Future<YouTubeMatchResult?> findOfficialVideo({
    required String trackName,
    required String artistName,
  }) async {
    debugPrint('[Hybrid] ========================================');
    debugPrint('[Hybrid] 검색: $trackName - $artistName');
    debugPrint('[Hybrid] ========================================');

    // Step 1: YouTube API로 조회수 상위 5개 검색
    final candidates = await _searchYouTubeByViews(trackName, artistName);

    if (candidates.isEmpty) {
      debugPrint('[Hybrid] YouTube 검색 결과 없음');
      return null;
    }

    debugPrint('[Hybrid] 후보 ${candidates.length}개 발견');
    for (int i = 0; i < candidates.length; i++) {
      debugPrint('[Hybrid] #${i + 1}: ${candidates[i].title} (${_formatViews(candidates[i].viewCount)})');
    }

    // Step 2: Gemini에게 최적 영상 선택 요청
    final selected = await _askGeminiToSelect(trackName, artistName, candidates);

    if (selected == null) {
      debugPrint('[Hybrid] Gemini 선택 실패, 조회수 1위 반환');
      // Fallback: 조회수 1위 반환
      final top = candidates.first;
      return YouTubeMatchResult(
        videoId: top.videoId,
        title: top.title,
        channelName: top.channelTitle,
        type: 'fallback',
      );
    }

    return selected;
  }

  /// YouTube API로 조회수 순 검색
  Future<List<YouTubeCandidate>> _searchYouTubeByViews(String trackName, String artistName) async {
    final query = '$trackName $artistName';

    try {
      // 검색 (조회수 순)
      final searchResponse = await _dio.get(
        '$_youtubeUrl/search',
        queryParameters: {
          'part': 'snippet',
          'q': query,
          'type': 'video',
          'order': 'viewCount', // 조회수 순!
          'maxResults': 10, // 여유있게 10개 (필터링 후 5개)
          'key': _currentYoutubeKey,
        },
      );

      dynamic searchData = searchResponse.data;
      if (searchData is String) searchData = jsonDecode(searchData);

      final items = searchData['items'] as List<dynamic>? ?? [];
      final videoIds = items
          .map((item) => item['id']?['videoId']?.toString())
          .where((id) => id != null && id.isNotEmpty)
          .cast<String>()
          .toList();

      if (videoIds.isEmpty) return [];

      // 상세 정보 가져오기 (status 포함해서 embeddable 체크)
      final detailsResponse = await _dio.get(
        '$_youtubeUrl/videos',
        queryParameters: {
          'part': 'snippet,statistics,contentDetails,status',
          'id': videoIds.join(','),
          'key': _currentYoutubeKey,
        },
      );

      dynamic detailsData = detailsResponse.data;
      if (detailsData is String) detailsData = jsonDecode(detailsData);

      final detailItems = detailsData['items'] as List<dynamic>? ?? [];

      final candidates = <YouTubeCandidate>[];

      for (final item in detailItems) {
        final snippet = item['snippet'] as Map<String, dynamic>? ?? {};
        final statistics = item['statistics'] as Map<String, dynamic>? ?? {};
        final contentDetails = item['contentDetails'] as Map<String, dynamic>? ?? {};
        final status = item['status'] as Map<String, dynamic>? ?? {};

        // embeddable 체크 - 외부 앱에서 재생 가능한지
        final embeddable = status['embeddable'] as bool? ?? false;
        if (!embeddable) {
          debugPrint('[YouTube] 제외 (embed 불가): ${snippet['title']}');
          continue;
        }

        final durationStr = contentDetails['duration']?.toString() ?? '';
        final durationSec = _parseDuration(durationStr);

        // 필터: 1분 이상, 15분 이하
        if (durationSec < 60 || durationSec > 900) continue;

        final title = snippet['title']?.toString() ?? '';
        final titleLower = title.toLowerCase();

        // 필터: 리액션, 커버 제외
        if (_isExcluded(titleLower)) continue;

        candidates.add(YouTubeCandidate(
          videoId: item['id']?.toString() ?? '',
          title: title,
          channelTitle: snippet['channelTitle']?.toString() ?? '',
          viewCount: int.tryParse(statistics['viewCount']?.toString() ?? '0') ?? 0,
          durationSec: durationSec,
        ));

        // 상위 5개만
        if (candidates.length >= 5) break;
      }

      return candidates;

    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        debugPrint('[YouTube] 쿼터 초과, 키 전환');
        _rotateYoutubeKey();
      }
      debugPrint('[YouTube] 오류: ${e.message}');
      return [];
    } catch (e) {
      debugPrint('[YouTube] 오류: $e');
      return [];
    }
  }

  /// 제외 키워드 체크
  bool _isExcluded(String titleLower) {
    const excludeKeywords = [
      'reaction', 'react', 'リアクション', '反応', '리액션',
      'cover', '커버', '歌ってみた', 'カバー',
      'piano', 'guitar', 'drum', 'acoustic', 'instrumental',
      '踊ってみた', 'dance practice', 'dance cover',
      'remix', 'リミックス',
      'live', 'concert', 'ライブ', '라이브',
      'tutorial', 'lesson',
      'shorts', '#shorts',
      'nightcore', 'slowed', '8d audio',
    ];

    for (final kw in excludeKeywords) {
      if (titleLower.contains(kw)) return true;
    }
    return false;
  }

  /// ISO 8601 duration 파싱 (초 단위)
  int _parseDuration(String duration) {
    if (duration.isEmpty) return 0;
    final regex = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?');
    final match = regex.firstMatch(duration);
    if (match == null) return 0;

    final hours = int.tryParse(match.group(1) ?? '0') ?? 0;
    final minutes = int.tryParse(match.group(2) ?? '0') ?? 0;
    final seconds = int.tryParse(match.group(3) ?? '0') ?? 0;

    return hours * 3600 + minutes * 60 + seconds;
  }

  /// 조회수 포맷
  String _formatViews(int views) {
    if (views >= 100000000) return '${(views / 100000000).toStringAsFixed(1)}억';
    if (views >= 10000) return '${(views / 10000).toStringAsFixed(1)}만';
    if (views >= 1000) return '${(views / 1000).toStringAsFixed(1)}천';
    return '$views';
  }

  /// Gemini에게 최적 영상 선택 요청
  Future<YouTubeMatchResult?> _askGeminiToSelect(
      String trackName,
      String artistName,
      List<YouTubeCandidate> candidates,
      ) async {
    final prompt = _buildSelectionPrompt(trackName, artistName, candidates);

    try {
      final response = await _dio.post(
        '$_geminiUrl/models/$_geminiModel:generateContent',
        queryParameters: {'key': _geminiApiKey},
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
        data: {
          'contents': [
            {
              'parts': [{'text': prompt}]
            }
          ],
          'generationConfig': {
            'temperature': 0.1,
            'maxOutputTokens': 200,
          }
        },
      );

      dynamic data = response.data;
      if (data is String) data = jsonDecode(data);

      final candidatesList = data['candidates'] as List<dynamic>?;
      if (candidatesList == null || candidatesList.isEmpty) return null;

      final content = candidatesList[0]['content'] as Map<String, dynamic>?;
      final parts = content?['parts'] as List<dynamic>?;
      if (parts == null || parts.isEmpty) return null;

      final text = parts[0]['text']?.toString() ?? '';
      debugPrint('[Gemini] 응답: $text');

      return _parseGeminiSelection(text, candidates);

    } catch (e) {
      debugPrint('[Gemini] 오류: $e');
      return null;
    }
  }

  /// Gemini 선택 프롬프트
  String _buildSelectionPrompt(String trackName, String artistName, List<YouTubeCandidate> candidates) {
    final candidatesList = candidates.asMap().entries.map((e) {
      final i = e.key + 1;
      final c = e.value;
      return '$i. "${c.title}" - Channel: ${c.channelTitle} (${_formatViews(c.viewCount)} views)';
    }).join('\n');

    return '''
You are selecting the best official music video for a song.

Song: $trackName
Artist: $artistName

Here are the top YouTube search results (sorted by view count):
$candidatesList

Selection Priority:
1. Official Music Video from artist's channel (look for: official, VEVO, 公式, MV, Music Video)
2. If anime OST, anime studio's official MV is acceptable (TOHO animation, Aniplex, Sony Music, etc.)
3. If no MV exists, official audio from Topic channel or record label is acceptable
4. NEVER select: covers, reactions, fan-made content, live performances, remixes

Return ONLY a JSON object (no markdown, no explanation):
{"number": 1, "type": "mv"}

Where:
- number: The candidate number (1-${candidates.length})
- type: "mv" (music video) or "audio" (official audio only)

If none are acceptable official content, return:
{"number": null, "type": null}
''';
  }

  /// Gemini 응답 파싱
  YouTubeMatchResult? _parseGeminiSelection(String text, List<YouTubeCandidate> candidates) {
    try {
      String jsonStr = text.trim();

      // 마크다운 제거
      if (jsonStr.contains('```')) {
        final match = RegExp(r'\{[^}]+\}').firstMatch(jsonStr);
        if (match != null) jsonStr = match.group(0)!;
      }

      // 불완전한 JSON 처리 - number만 추출
      int? number;
      String type = 'mv'; // 기본값

      // number 추출 시도
      final numberMatch = RegExp(r'"number"\s*:\s*(\d+)').firstMatch(jsonStr);
      if (numberMatch != null) {
        number = int.tryParse(numberMatch.group(1) ?? '');
      }

      // type 추출 시도
      final typeMatch = RegExp(r'"type"\s*:\s*"(\w+)"').firstMatch(jsonStr);
      if (typeMatch != null) {
        type = typeMatch.group(1) ?? 'mv';
      }

      if (number == null) {
        debugPrint('[Gemini] number 추출 실패');
        return null;
      }

      final index = number - 1;
      if (index < 0 || index >= candidates.length) {
        debugPrint('[Gemini] 잘못된 index: $index');
        return null;
      }

      final selected = candidates[index];

      debugPrint('[Gemini] ✓ 선택: #$number ${selected.title} ($type)');

      return YouTubeMatchResult(
        videoId: selected.videoId,
        title: selected.title,
        channelName: selected.channelTitle,
        type: type,
      );
    } catch (e) {
      debugPrint('[Gemini] 파싱 오류: $e');
      return null;
    }
  }
}

/// YouTube 검색 후보
class YouTubeCandidate {
  final String videoId;
  final String title;
  final String channelTitle;
  final int viewCount;
  final int durationSec;

  YouTubeCandidate({
    required this.videoId,
    required this.title,
    required this.channelTitle,
    required this.viewCount,
    required this.durationSec,
  });
}

/// YouTube 매칭 결과
class YouTubeMatchResult {
  final String videoId;
  final String title;
  final String channelName;
  final String type; // 'mv', 'audio', 'fallback'

  YouTubeMatchResult({
    required this.videoId,
    required this.title,
    required this.channelName,
    required this.type,
  });

  bool get isMusicVideo => type == 'mv';
  bool get isOfficialAudio => type == 'audio';
  bool get isFallback => type == 'fallback';

  String get youtubeUrl => 'https://www.youtube.com/watch?v=$videoId';

  @override
  String toString() => 'YouTubeMatchResult(videoId: $videoId, type: $type)';
}