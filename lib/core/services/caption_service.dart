import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

/// YouTube 자막 서비스
/// YouTube 자막 없으면 → Uta-Net + AI로 자동 생성
class CaptionService {
  final Dio _dio;

  // 백엔드 서버 URL (ngrok 또는 로컬)
  // TODO: 실제 배포 시 환경변수로 변경
  static const String _proxyUrl = 'https://afdd-2406-5900-11a4-65d4-e004-1550-d7ac-5245.ngrok-free.app';

  CaptionService() : _dio = Dio();

  /// 스마트 자막 가져오기
  /// 1. YouTube 자막 있으면 → 바로 반환
  /// 2. YouTube 자막 없으면 → Uta-Net 가사 + AI 타임스탬프 생성
  Future<CaptionResult?> getSmartCaptions({
    required String videoId,
    required String artist,
    required String title,
  }) async {
    debugPrint('[Caption] ========================================');
    debugPrint('[Caption] 스마트 자막 로드 시작');
    debugPrint('[Caption] VideoId: $videoId');
    debugPrint('[Caption] Artist: $artist, Title: $title');
    debugPrint('[Caption] ========================================');

    try {
      // Smart Caption API 호출
      final url = '$_proxyUrl/api/captions/smart/$videoId';
      debugPrint('[Caption] 요청 URL: $url');

      final response = await _dio.get(
        url,
        queryParameters: {
          'artist': artist,
          'title': title,
        },
        options: Options(
          headers: {
            'ngrok-skip-browser-warning': 'true',
          },
          validateStatus: (status) => true,
          receiveTimeout: const Duration(minutes: 5), // AI 처리 시간 고려
          sendTimeout: const Duration(minutes: 1),
        ),
      );

      debugPrint('[Caption] 응답 상태: ${response.statusCode}');

      if (response.statusCode != 200) {
        debugPrint('[Caption] HTTP 에러: ${response.statusCode}');
        debugPrint('[Caption] 응답: ${response.data}');
        return null;
      }

      final data = response.data;

      if (data['success'] != true) {
        debugPrint('[Caption] API 에러: ${data['error'] ?? data['message']}');
        return null;
      }

      final source = data['source'] as String? ?? 'unknown';
      final subtitles = data['data'] as List<dynamic>?;

      if (subtitles == null || subtitles.isEmpty) {
        debugPrint('[Caption] 자막 데이터 없음');
        return null;
      }

      debugPrint('[Caption] 소스: $source');
      debugPrint('[Caption] 자막 ${subtitles.length}개 수신');

      // LyricCaption 리스트로 변환
      final captions = subtitles.map((sub) {
        final start = double.tryParse(sub['start']?.toString() ?? '0') ?? 0;
        final dur = double.tryParse(sub['dur']?.toString() ?? '3') ?? 3;

        return LyricCaption(
          text: sub['text']?.toString() ?? '',
          startMs: (start * 1000).round(),
          durationMs: (dur * 1000).round(),
        );
      }).where((c) => c.text.isNotEmpty).toList();

      debugPrint('[Caption] ✓ 자막 로드 완료: ${captions.length}개 ($source)');

      return CaptionResult(
        captions: captions,
        source: source == 'youtube' ? CaptionSource.youtube : CaptionSource.ai,
      );
    } catch (e, stack) {
      debugPrint('[Caption] 예외 발생: $e');
      debugPrint('[Caption] 스택: $stack');
      return null;
    }
  }

  /// 기존 호환용 - YouTube 자막만 가져오기
  Future<List<LyricCaption>?> getCaptions(String videoId) async {
    debugPrint('[Caption] ========================================');
    debugPrint('[Caption] 자막 로드 시작: $videoId');
    debugPrint('[Caption] ========================================');

    try {
      final url = '$_proxyUrl/api/captions/$videoId';
      debugPrint('[Caption] 프록시 요청: $url');

      final response = await _dio.get(
        url,
        options: Options(
          headers: {
            'ngrok-skip-browser-warning': 'true',
          },
          validateStatus: (status) => true,
        ),
      );

      debugPrint('[Caption] 응답 상태: ${response.statusCode}');

      if (response.statusCode != 200) {
        debugPrint('[Caption] HTTP 에러: ${response.statusCode}');
        return null;
      }

      final data = response.data;

      if (data['success'] != true) {
        debugPrint('[Caption] API 에러: ${data['message']}');
        return null;
      }

      final subtitles = data['data'] as List<dynamic>?;
      if (subtitles == null) {
        debugPrint('[Caption] data 필드 없음');
        return null;
      }
      debugPrint('[Caption] 자막 ${subtitles.length}개 수신');

      // LyricCaption 리스트로 변환
      final captions = subtitles.map((sub) {
        final start = double.tryParse(sub['start']?.toString() ?? '0') ?? 0;
        final dur = double.tryParse(sub['dur']?.toString() ?? '3') ?? 3;

        return LyricCaption(
          text: sub['text']?.toString() ?? '',
          startMs: (start * 1000).round(),
          durationMs: (dur * 1000).round(),
        );
      }).where((c) => c.text.isNotEmpty).toList();

      debugPrint('[Caption] ✓ 자막 로드 완료: ${captions.length}개');
      return captions;
    } catch (e, stack) {
      debugPrint('[Caption] 예외 발생: $e');
      debugPrint('[Caption] 스택: $stack');
      return null;
    }
  }

  void dispose() {}
}

/// 자막 소스
enum CaptionSource {
  youtube,  // YouTube 공식 자막
  ai,       // AI 생성 (Uta-Net + stable-whisper)
}

/// 자막 결과
class CaptionResult {
  final List<LyricCaption> captions;
  final CaptionSource source;

  CaptionResult({
    required this.captions,
    required this.source,
  });

  bool get isFromYouTube => source == CaptionSource.youtube;
  bool get isFromAI => source == CaptionSource.ai;
}

/// 자막 데이터 모델
class LyricCaption {
  final String text;
  final int startMs;
  final int durationMs;

  LyricCaption({
    required this.text,
    required this.startMs,
    required this.durationMs,
  });

  double get startSec => startMs / 1000.0;
  double get endSec => (startMs + durationMs) / 1000.0;
  Duration get start => Duration(milliseconds: startMs);
  Duration get end => Duration(milliseconds: startMs + durationMs);

  String get formattedStart {
    final mins = (startMs / 60000).floor();
    final secs = ((startMs % 60000) / 1000).floor();
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }

  @override
  String toString() => 'LyricCaption($formattedStart: $text)';
}