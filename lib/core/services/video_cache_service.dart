import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';

/// 영상 매칭 캐시 서비스
/// 한번 찾은 영상은 저장해서 API 쿼터 절약
class VideoCacheService {
  static const String _boxName = 'video_cache';
  Box<Map>? _box;

  /// 초기화
  Future<void> init() async {
    if (_box != null && _box!.isOpen) return;

    try {
      _box = await Hive.openBox<Map>(_boxName);
      debugPrint('[VideoCache] 초기화 완료 (${_box!.length}개 캐시됨)');
    } catch (e) {
      debugPrint('[VideoCache] 초기화 실패: $e');
    }
  }

  /// 캐시 키 생성
  String _generateKey(String trackId) => 'track_$trackId';

  /// 캐시된 영상 정보 가져오기
  CachedVideo? get(String trackId) {
    if (_box == null || !_box!.isOpen) return null;

    final key = _generateKey(trackId);
    final data = _box!.get(key);

    if (data == null) return null;

    try {
      final cached = CachedVideo.fromMap(Map<String, dynamic>.from(data));

      // 캐시 유효기간 체크 (30일)
      final age = DateTime.now().difference(cached.cachedAt);
      if (age.inDays > 30) {
        debugPrint('[VideoCache] 캐시 만료: $trackId');
        delete(trackId);
        return null;
      }

      debugPrint('[VideoCache] 캐시 히트: $trackId → ${cached.videoId}');
      return cached;
    } catch (e) {
      debugPrint('[VideoCache] 파싱 실패: $e');
      return null;
    }
  }

  /// 영상 정보 저장
  Future<void> save(String trackId, CachedVideo video) async {
    if (_box == null || !_box!.isOpen) {
      await init();
    }

    final key = _generateKey(trackId);
    await _box?.put(key, video.toMap());
    debugPrint('[VideoCache] 저장: $trackId → ${video.videoId}');
  }

  /// 캐시 삭제
  Future<void> delete(String trackId) async {
    if (_box == null || !_box!.isOpen) return;

    final key = _generateKey(trackId);
    await _box?.delete(key);
  }

  /// 전체 캐시 삭제
  Future<void> clearAll() async {
    if (_box == null || !_box!.isOpen) return;
    await _box?.clear();
    debugPrint('[VideoCache] 전체 삭제');
  }

  /// 캐시 통계
  int get cacheCount => _box?.length ?? 0;
}

/// 캐시된 영상 정보 모델
class CachedVideo {
  final String videoId;
  final String title;
  final String channelTitle;
  final String thumbnailUrl;
  final int durationMs;
  final int matchScore;
  final DateTime cachedAt;
  final String videoType; // 'mv', 'audio', 'fallback'

  CachedVideo({
    required this.videoId,
    required this.title,
    required this.channelTitle,
    required this.thumbnailUrl,
    required this.durationMs,
    required this.matchScore,
    required this.cachedAt,
    required this.videoType,
  });

  factory CachedVideo.fromMap(Map<String, dynamic> map) {
    return CachedVideo(
      videoId: map['videoId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      channelTitle: map['channelTitle'] as String? ?? '',
      thumbnailUrl: map['thumbnailUrl'] as String? ?? '',
      durationMs: map['durationMs'] as int? ?? 0,
      matchScore: map['matchScore'] as int? ?? 0,
      cachedAt: DateTime.tryParse(map['cachedAt'] as String? ?? '') ?? DateTime.now(),
      videoType: map['videoType'] as String? ?? 'unknown',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'videoId': videoId,
      'title': title,
      'channelTitle': channelTitle,
      'thumbnailUrl': thumbnailUrl,
      'durationMs': durationMs,
      'matchScore': matchScore,
      'cachedAt': cachedAt.toIso8601String(),
      'videoType': videoType,
    };
  }

  @override
  String toString() => 'CachedVideo($videoId: $title)';
}