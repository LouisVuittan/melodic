import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

/// YouTube 자막 서비스
/// Next.js 백엔드 프록시를 통해 자막 가져오기
class CaptionService {
  final Dio _dio;

  // 백엔드 서버 URL (ngrok 또는 로컬)
  // TODO: 실제 배포 시 환경변수로 변경
  static const String _proxyUrl = 'https://cce5-211-179-133-167.ngrok-free.app'; // Android 에뮬레이터용
  // static const String _proxyUrl = 'http://localhost:4000'; // iOS 시뮬레이터용
  // static const String _proxyUrl = 'https://your-ngrok-url.ngrok.io'; // 실제 기기용

  CaptionService() : _dio = Dio();

  /// 자막 가져오기 (일본어 우선)
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
      debugPrint('[Caption] 응답 데이터: $data');
      debugPrint('[Caption] 응답 타입: ${data.runtimeType}');

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

      if (subtitles.isNotEmpty) {
        debugPrint('[Caption] 첫 번째 자막: ${subtitles.first}');
      }

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