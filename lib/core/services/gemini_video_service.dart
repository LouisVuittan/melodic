import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

/// Gemini API를 이용한 YouTube 영상 검색 서비스
/// AI가 맥락을 이해하고 정확한 공식 영상을 찾아줌
class GeminiVideoService {
  final Dio _dio;

  static const String _apiKey = 'AIzaSyB_NdZxk7YQCt9Pb8BA3zR7ZGNiIyCmIA4';
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta';
  static const String _model = 'gemini-2.5-flash-preview-05-20';

  GeminiVideoService({Dio? dio}) : _dio = dio ?? Dio();

  /// 곡에 맞는 YouTube 영상 찾기
  Future<GeminiVideoResult?> findOfficialVideo({
    required String trackName,
    required String artistName,
  }) async {
    debugPrint('[Gemini] ========================================');
    debugPrint('[Gemini] 검색: $trackName - $artistName');
    debugPrint('[Gemini] ========================================');

    final prompt = _buildPrompt(trackName, artistName);

    try {
      final response = await _dio.post(
        '$_baseUrl/models/$_model:generateContent',
        queryParameters: {'key': _apiKey},
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
        data: {
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.1, // 낮은 temperature로 일관된 응답
            'maxOutputTokens': 500,
          }
        },
      );

      dynamic data = response.data;
      if (data is String) data = jsonDecode(data);

      // 응답 파싱
      final candidates = data['candidates'] as List<dynamic>?;
      if (candidates == null || candidates.isEmpty) {
        debugPrint('[Gemini] 응답 없음');
        return null;
      }

      final content = candidates[0]['content'] as Map<String, dynamic>?;
      final parts = content?['parts'] as List<dynamic>?;
      if (parts == null || parts.isEmpty) {
        debugPrint('[Gemini] 파트 없음');
        return null;
      }

      final text = parts[0]['text']?.toString() ?? '';
      debugPrint('[Gemini] 응답: $text');

      // JSON 응답 파싱
      return _parseResponse(text);

    } on DioException catch (e) {
      debugPrint('[Gemini] API 오류: ${e.response?.statusCode}');
      debugPrint('[Gemini] 오류 내용: ${e.response?.data}');
      return null;
    } catch (e) {
      debugPrint('[Gemini] 오류: $e');
      return null;
    }
  }

  /// 프롬프트 생성
  String _buildPrompt(String trackName, String artistName) {
    return '''
You are a YouTube music video search assistant. Find the official music video for this song.

Song: $trackName
Artist: $artistName

Search Priority (in order):
1. Official Music Video from the artist's official channel (VEVO, official, 公式)
2. If it's an anime OST, the anime studio's official MV is also acceptable (like TOHO animation, Aniplex, etc.)
3. If no official MV exists, find the official audio from YouTube Music Topic channel (e.g., "Artist - Topic")
4. Never return covers, reactions, live performances, remixes, or fan-made videos

Return ONLY a JSON object in this exact format (no markdown, no explanation):
{"videoId": "YOUTUBE_VIDEO_ID", "title": "Video Title", "channel": "Channel Name", "type": "mv" or "audio"}

If you cannot find any official video, return:
{"videoId": null, "title": null, "channel": null, "type": null}
''';
  }

  /// 응답 파싱
  GeminiVideoResult? _parseResponse(String text) {
    try {
      // JSON 부분만 추출 (마크다운 코드블록 제거)
      String jsonStr = text.trim();

      // ```json ... ``` 형식 제거
      if (jsonStr.contains('```')) {
        final jsonMatch = RegExp(r'\{[^}]+\}').firstMatch(jsonStr);
        if (jsonMatch != null) {
          jsonStr = jsonMatch.group(0)!;
        }
      }

      final json = jsonDecode(jsonStr) as Map<String, dynamic>;

      final videoId = json['videoId']?.toString();
      if (videoId == null || videoId == 'null' || videoId.isEmpty) {
        debugPrint('[Gemini] 영상 못 찾음');
        return null;
      }

      debugPrint('[Gemini] ✓ 찾음: $videoId');
      debugPrint('[Gemini] 제목: ${json['title']}');
      debugPrint('[Gemini] 채널: ${json['channel']}');
      debugPrint('[Gemini] 타입: ${json['type']}');

      return GeminiVideoResult(
        videoId: videoId,
        title: json['title']?.toString() ?? '',
        channelName: json['channel']?.toString() ?? '',
        type: json['type']?.toString() ?? 'unknown',
      );
    } catch (e) {
      debugPrint('[Gemini] 파싱 오류: $e');
      debugPrint('[Gemini] 원본: $text');
      return null;
    }
  }
}

/// Gemini 검색 결과
class GeminiVideoResult {
  final String videoId;
  final String title;
  final String channelName;
  final String type; // 'mv' or 'audio'

  GeminiVideoResult({
    required this.videoId,
    required this.title,
    required this.channelName,
    required this.type,
  });

  bool get isMusicVideo => type == 'mv';
  bool get isOfficialAudio => type == 'audio';

  String get youtubeUrl => 'https://www.youtube.com/watch?v=$videoId';

  @override
  String toString() => 'GeminiVideoResult(videoId: $videoId, title: $title, type: $type)';
}