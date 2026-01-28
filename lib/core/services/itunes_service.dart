import 'dart:convert';
import 'package:dio/dio.dart';

/// iTunes API 서비스
class iTunesService {
  final Dio _dio;

  iTunesService({Dio? dio}) : _dio = dio ?? Dio();

  /// 일본 Top 100 차트 가져오기
  Future<List<iTunesTrack>> getJapanTopChart({int limit = 50}) async {
    try {
      final response = await _dio.get(
        'https://itunes.apple.com/jp/rss/topsongs/limit=$limit/json',
      );

      // 응답 데이터가 String일 경우를 대비해 Map으로 변환
      final Map<String, dynamic> data = response.data is String
          ? jsonDecode(response.data)
          : response.data;

      final feed = data['feed'];
      if (feed == null) return [];

      final entryData = feed['entry'];
      if (entryData == null) return [];

      // entry가 단일 객체일 수도 있고 배열일 수도 있음
      List<dynamic> entryList;
      if (entryData is List) {
        entryList = entryData;
      } else {
        entryList = [entryData];
      }

      final List<iTunesTrack> tracks = [];
      for (int i = 0; i < entryList.length; i++) {
        final item = entryList[i];
        if (item is Map<String, dynamic>) {
          tracks.add(iTunesTrack.fromRssJson(item, rank: i + 1));
        }
      }
      return tracks;
    } catch (e) {
      print('iTunes Chart Error: $e');
      throw iTunesException('차트를 불러오는데 실패했습니다: $e');
    }
  }

  /// 일본 음악 검색
  Future<List<iTunesTrack>> searchJapaneseMusic({
    required String query,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        'https://itunes.apple.com/search',
        queryParameters: {
          'term': query,
          'country': 'jp',
          'media': 'music',
          'limit': limit,
          'lang': 'ja_jp',
        },
      );

      final Map<String, dynamic> data = response.data is String
          ? jsonDecode(response.data)
          : response.data;

      final results = data['results'] as List<dynamic>? ?? [];

      return results
          .whereType<Map<String, dynamic>>()
          .map((item) => iTunesTrack.fromSearchJson(item))
          .toList();
    } catch (e) {
      throw iTunesException('검색에 실패했습니다: $e');
    }
  }

  /// 아티스트의 다른 곡 가져오기
  Future<List<iTunesTrack>> getArtistTracks({
    required int artistId,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        'https://itunes.apple.com/lookup',
        queryParameters: {
          'id': artistId,
          'country': 'jp',
          'media': 'music',
          'entity': 'song',
          'limit': limit,
        },
      );

      final Map<String, dynamic> data = response.data is String
          ? jsonDecode(response.data)
          : response.data;

      final results = data['results'] as List<dynamic>? ?? [];

      return results
          .skip(1) // 첫 번째는 아티스트 정보이므로 스킵
          .whereType<Map<String, dynamic>>()
          .map((item) => iTunesTrack.fromSearchJson(item))
          .toList();
    } catch (e) {
      throw iTunesException('아티스트 곡을 불러오는데 실패했습니다: $e');
    }
  }
}

/// iTunes 트랙 모델
class iTunesTrack {
  final String id;
  final String name;
  final String artistName;
  final int artistId;
  final String albumName;
  final String? albumImageUrl;
  final String? albumImageUrlLarge;
  final String? previewUrl;
  final int durationMs;
  final String? trackViewUrl;
  final int? rank;
  final String? genre;
  final DateTime? releaseDate;

  const iTunesTrack({
    required this.id,
    required this.name,
    required this.artistName,
    required this.artistId,
    required this.albumName,
    this.albumImageUrl,
    this.albumImageUrlLarge,
    this.previewUrl,
    required this.durationMs,
    this.trackViewUrl,
    this.rank,
    this.genre,
    this.releaseDate,
  });

  /// [UI용] 재생 시간 포맷 게터 (mm:ss)
  String get formattedDuration {
    if (durationMs <= 0) return '--:--';
    final minutes = (durationMs / 60000).floor();
    final seconds = ((durationMs % 60000) / 1000).floor();
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// RSS 피드 JSON에서 생성 (차트용)
  factory iTunesTrack.fromRssJson(Map<String, dynamic> json, {int? rank}) {
    String? imageUrl;
    String? imageLargeUrl;

    final imagesData = json['im:image'];
    if (imagesData is List && imagesData.isNotEmpty) {
      imageUrl = _extractLabel(imagesData.last);
      // 어떤 해상도가 오든 600x600 고화질로 변경
      imageLargeUrl = imageUrl.replaceAll(RegExp(r'\d+x\d+'), '600x600');
    }

    int artistIdParsed = 0;
    final artistData = json['im:artist'];
    if (artistData is Map && artistData['attributes'] is Map) {
      final String href = artistData['attributes']['href']?.toString() ?? '';
      final artistIdMatch = RegExp(r'/id(\d+)').firstMatch(href);
      artistIdParsed = int.tryParse(artistIdMatch?.group(1) ?? '') ?? 0;
    }

    String trackIdStr = '';
    final idData = json['id'];
    if (idData is Map && idData['attributes'] is Map) {
      trackIdStr = idData['attributes']['im:id']?.toString() ?? '';
    }

    return iTunesTrack(
      id: trackIdStr,
      name: _extractLabel(json['im:name']),
      artistName: _extractLabel(json['im:artist']),
      artistId: artistIdParsed,
      albumName: _extractLabel(json['im:collection']),
      albumImageUrl: imageUrl,
      albumImageUrlLarge: imageLargeUrl,
      previewUrl: null,
      durationMs: 0,
      trackViewUrl: _extractLabel(json['id']),
      rank: rank,
      genre: json['category']?['attributes']?['label']?.toString(),
      releaseDate: _parseDate(json['im:releaseDate']?['label']?.toString()),
    );
  }

  /// 검색 결과 JSON에서 생성
  factory iTunesTrack.fromSearchJson(Map<String, dynamic> json) {
    final String? imageUrl = json['artworkUrl100'] as String?;
    final String? imageLargeUrl = imageUrl?.replaceAll('100x100', '600x600');

    return iTunesTrack(
      id: (json['trackId'] ?? 0).toString(),
      name: json['trackName']?.toString() ?? '',
      artistName: json['artistName']?.toString() ?? '',
      artistId: json['artistId'] as int? ?? 0,
      albumName: json['collectionName']?.toString() ?? '',
      albumImageUrl: imageUrl,
      albumImageUrlLarge: imageLargeUrl,
      previewUrl: json['previewUrl'] as String?,
      durationMs: json['trackTimeMillis'] as int? ?? 0,
      trackViewUrl: json['trackViewUrl'] as String?,
      genre: json['primaryGenreName']?.toString(),
      releaseDate: _parseDate(json['releaseDate']?.toString()),
    );
  }

  /// JSON label 추출 헬퍼 (구조가 Map이든 String이든 안전하게 처리)
  static String _extractLabel(dynamic data) {
    if (data == null) return '';
    if (data is String) return data;
    if (data is Map) {
      return data['label']?.toString() ?? '';
    }
    return data.toString();
  }

  static DateTime? _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    return DateTime.tryParse(dateStr);
  }
}

class iTunesException implements Exception {
  final String message;
  iTunesException(this.message);
  @override
  String toString() => 'iTunesException: $message';
}