import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 하이브리드 영상 검색 서비스
/// YouTube API로 검색 + 점수제로 필터링/정렬 → Gemini가 최적 영상 최종 선택
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

  /// 곡에 맞는 YouTube 영상 찾기 (하이브리드: 점수제 + Gemini)
  Future<YouTubeMatchResult?> findOfficialVideo({
    required String trackName,
    required String artistName,
  }) async {
    debugPrint('[Hybrid] ========================================');
    debugPrint('[Hybrid] 검색: $trackName - $artistName');
    debugPrint('[Hybrid] ========================================');

    // Step 1: YouTube API 검색 및 점수제 평가/정렬
    final candidates = await _searchYouTubeAndScore(trackName, artistName);

    if (candidates.isEmpty) {
      debugPrint('[Hybrid] YouTube 검색 결과 없음');
      return null;
    }

    debugPrint('[Hybrid] 점수제 평가 상위 ${candidates.length}개 후보');
    for (int i = 0; i < candidates.length; i++) {
      debugPrint('[Hybrid] #${i + 1} [${candidates[i].score}점]: ${candidates[i].title} (${_formatViews(candidates[i].viewCount)})');
    }

    // ⭐ [속도 개선 1] 하이패스 (Fast Pass) 로직
    final topCandidate = candidates[0];
    final secondScore = candidates.length > 1 ? candidates[1].score : 0;

    // 조건 1: 절대 평가 (90점 이상이면 확실한 공식 MV)
    final isAbsoluteWinner = topCandidate.score >= 90;
    // 조건 2: 상대 평가 (70점 이상이면서 2등과 30점 이상 차이 나면 독보적 1등)
    final isRelativeWinner = topCandidate.score >= 70 && (topCandidate.score - secondScore >= 30);

    if (candidates.length == 1 || isAbsoluteWinner || isRelativeWinner) {
      debugPrint('[Hybrid] ⚡ 하이패스 발동! Gemini 생략하고 1등 바로 선택: ${topCandidate.title}');

      // 제목에 mv, official 등이 있으면 mv, 아니면 audio로 간주
      final titleLower = topCandidate.title.toLowerCase();
      final type = (titleLower.contains('mv') || titleLower.contains('official') || titleLower.contains('公式')) ? 'mv' : 'audio';

      return YouTubeMatchResult(
        videoId: topCandidate.videoId,
        title: topCandidate.title,
        channelName: topCandidate.channelTitle,
        type: type,
      );
    }

    // Step 2: 애매할 때만 Gemini에게 최적 영상 선택 요청 (후보군 Top 3로 축소)
    final top3Candidates = candidates.take(3).toList();
    final selected = await _askGeminiToSelect(trackName, artistName, top3Candidates);

    if (selected == null) {
      debugPrint('[Hybrid] Gemini 선택 실패, 점수 1위 반환');
      return YouTubeMatchResult(
        videoId: topCandidate.videoId,
        title: topCandidate.title,
        channelName: topCandidate.channelTitle,
        type: 'fallback',
      );
    }

    return selected;
  }

  /// YouTube API 검색 후 HTML 로직 기반 점수제로 평가 및 정렬
  Future<List<YouTubeCandidate>> _searchYouTubeAndScore(String trackName, String artistName) async {
    final query = '$trackName $artistName';

    try {
      final searchResponse = await _dio.get(
        '$_youtubeUrl/search',
        queryParameters: {
          'part': 'snippet',
          'q': query,
          'type': 'video',
          'order': 'relevance',
          'maxResults': 30,
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

        final embeddable = status['embeddable'] as bool? ?? false;
        if (!embeddable) continue;

        final contentRating = contentDetails['contentRating'] as Map<String, dynamic>? ?? {};
        final isAgeRestricted = contentRating.containsKey('ytRating') &&
            contentRating['ytRating'] == 'ytAgeRestricted';

        if (isAgeRestricted) {
          debugPrint('[YouTube] 컷! ✂️ 제외 (연령 제한/민감한 콘텐츠): ${snippet['title']}');
          continue;
        }
        final durationStr = contentDetails['duration']?.toString() ?? '';
        final durationSec = _parseDuration(durationStr);

        if (durationSec < 60 || durationSec > 900) continue;

        final title = snippet['title']?.toString() ?? '';
        final titleLower = title.toLowerCase();

        if (_isExcluded(titleLower)) continue;

        final channelTitle = snippet['channelTitle']?.toString() ?? '';
        final viewCount = int.tryParse(statistics['viewCount']?.toString() ?? '0') ?? 0;

        final score = _calculateScore(
          title: title,
          channelTitle: channelTitle,
          viewCount: viewCount,
          trackName: trackName,
          artistName: artistName,
        );

        candidates.add(YouTubeCandidate(
          videoId: item['id']?.toString() ?? '',
          title: title,
          channelTitle: channelTitle,
          viewCount: viewCount,
          durationSec: durationSec,
          score: score,
        ));
      }

      candidates.sort((a, b) => b.score.compareTo(a.score));

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

  /// HTML 로직 기반 점수 계산기
  int _calculateScore({
    required String title,
    required String channelTitle,
    required int viewCount,
    required String trackName,
    required String artistName,
  }) {
    int score = 0;
    final titleLower = title.toLowerCase();
    final channelLower = channelTitle.toLowerCase();
    final trackLower = trackName.toLowerCase();
    final artistLower = artistName.toLowerCase();

    // 공식 채널
    if (channelLower.contains('official') || channelLower.contains('vevo') || channelLower.contains('公式')) score += 50;
    // Topic 채널
    if (channelLower.contains('topic')) score += 40;
    // 제목에 official
    if (titleLower.contains('official') || titleLower.contains('公式')) score += 30;
    // 제목에 MV
    if (titleLower.contains('mv') || titleLower.contains('music video') || titleLower.contains('ミュージックビデオ')) score += 25;
    // 곡명 포함
    if (titleLower.contains(trackLower) || title.contains(trackName)) score += 20;
    // 아티스트명 포함
    if (titleLower.contains(artistLower) || title.contains(artistName) || channelLower.contains(artistLower) || channelTitle.contains(artistName)) score += 15;

    // 조회수 보너스
    if (viewCount > 100000000) score += 20;
    else if (viewCount > 10000000) score += 15;
    else if (viewCount > 1000000) score += 10;

    return score;
  }

  bool _isExcluded(String titleLower) {
    const excludeKeywords = [
      'reaction', 'react', 'reacting', 'リアクション', '反応', '리액션', 'リアクト',
      'first time', 'first listen', '처음',
      'cover', 'covered', '커버', '歌ってみた', '불러봤', '노래해봤', 'カバー',
      'sing', 'sang', 'singing',
      '踊ってみた', 'dance practice', 'dance cover', '안무', '춤춰봤', 'choreography',
      'piano', 'guitar', 'drum', 'bass', 'acoustic', 'instrumental',
      '연주', '피아노', '기타', 'inst', 'karaoke', '노래방',
      'remix', 'リミックス', '리믹스', 'bootleg',
      'live', 'concert', 'ライブ', '라이브', '콘서트', 'fancam', '직캠', 'stage',
      'tutorial', '강의', 'lesson', 'how to',
      'teaser', 'preview', 'trailer',
      'short', 'shorts', '#shorts', 'tiktok', 'vertical',
      'amv', 'mad', 'gmv', 'mmv', 'fmv',
      'nightcore', 'slowed', 'reverb', '8d audio', 'speed up',
      'mashup', '매쉬업', 'medley',
      'parody', '패러디',
      'unboxing', 'review', '리뷰', 'ranking', '순위',
      'compilation', '모음', 'best of', 'top 10',
      'behind', 'making', '메이킹', 'vlog',
      'fan made', 'fanmade', '팬메이드',
      'lyrics video', 'lyric video'
    ];

    for (final kw in excludeKeywords) {
      if (titleLower.contains(kw)) return true;
    }
    return false;
  }

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
            'maxOutputTokens': 100,
            // ⭐ [속도 개선 2] 제미나이를 완벽한 JSON 머신으로 만듭니다.
            'responseMimeType': 'application/json',
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
      debugPrint('[Gemini] 원본 응답: $text');

      return _parseGeminiSelection(text, candidates);

    } catch (e) {
      debugPrint('[Gemini] API 오류: $e');
      return null;
    }
  }

  String _buildSelectionPrompt(String trackName, String artistName, List<YouTubeCandidate> candidates) {
    final candidatesList = candidates.asMap().entries.map((e) {
      final i = e.key + 1;
      final c = e.value;
      return '$i. "${c.title}" - Channel: ${c.channelTitle} (${_formatViews(c.viewCount)} views) [Score: ${c.score}]';
    }).join('\n');

    return '''
You are selecting the best official music video for a song.
Song: $trackName
Artist: $artistName

Top candidates:
$candidatesList

Selection Priority:
1. Official Music Video from artist's channel
2. Official anime OST MV from studio
3. Official audio from Topic channel or label
4. NEVER select covers, lives, or fan-made.

Return a JSON object with this EXACT format:
{"number": 1, "type": "mv"}

"number" is the chosen candidate (1-${candidates.length}). "type" is "mv" or "audio". If none are good, return {"number": null, "type": null}.
''';
  }

  /// ⭐ [속도 개선 3] 정규식 파싱을 버리고 빠르고 정확한 JSON 디코딩 적용
  YouTubeMatchResult? _parseGeminiSelection(String text, List<YouTubeCandidate> candidates) {
    try {
      final Map<String, dynamic> jsonResponse = jsonDecode(text.trim());

      final number = jsonResponse['number'];
      final type = jsonResponse['type']?.toString() ?? 'mv';

      if (number == null || number is! int) {
        debugPrint('[Gemini] 적합한 영상 없음으로 판단됨 (number is null)');
        return null;
      }

      final index = number - 1;
      if (index < 0 || index >= candidates.length) {
        debugPrint('[Gemini] 잘못된 index 반환: $index');
        return null;
      }

      final selected = candidates[index];
      debugPrint('[Gemini] ✓ 최종 선택: #$number ${selected.title} ($type) [${selected.score}점]');

      return YouTubeMatchResult(
        videoId: selected.videoId,
        title: selected.title,
        channelName: selected.channelTitle,
        type: type,
      );
    } catch (e) {
      debugPrint('[Gemini] JSON 디코딩 오류: $e \n원문: $text');
      return null;
    }
  }
}

class YouTubeCandidate {
  final String videoId;
  final String title;
  final String channelTitle;
  final int viewCount;
  final int durationSec;
  final int score;

  YouTubeCandidate({
    required this.videoId,
    required this.title,
    required this.channelTitle,
    required this.viewCount,
    required this.durationSec,
    required this.score,
  });
}

class YouTubeMatchResult {
  final String videoId;
  final String title;
  final String channelName;
  final String type;

  YouTubeMatchResult({
    required this.videoId,
    required this.title,
    required this.channelName,
    required this.type,
  });

  bool get isMusicVideo => type == 'mv';
  bool get isOfficialAudio => type == 'audio';
  bool get isFallback => type == 'fallback';

  String get youtubeUrl => '[https://www.youtube.com/watch?v=$videoId](https://www.youtube.com/watch?v=$videoId)';

  @override
  String toString() => 'YouTubeMatchResult(videoId: $videoId, type: $type)';
}