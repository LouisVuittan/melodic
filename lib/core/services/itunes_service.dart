import 'package:dio/dio.dart';
import 'dart:convert';

/// iTunes/Apple Music API 서비스
/// API 키 불필요 - 바로 사용 가능
class iTunesService {
  final Dio _dio;

  iTunesService({Dio? dio}) : _dio = dio ?? Dio();

  /// 일본 Top 100 차트 가져오기
  Future<List<iTunesTrack>> getJapanTopChart({int limit = 50}) async {
    try {
      final response = await _dio.get(
        'https://itunes.apple.com/jp/rss/topsongs/limit=$limit/json',
      );

      // response.data가 String이면 JSON 파싱
      dynamic data = response.data;
      if (data is String) {
        data = jsonDecode(data);
      }

      if (data is! Map<String, dynamic>) {
        throw iTunesException('잘못된 응답 형식');
      }

      final feed = data['feed'];
      if (feed is! Map<String, dynamic>) {
        throw iTunesException('feed 데이터 없음');
      }

      final entryData = feed['entry'];

      // entry가 단일 객체일 수도 있고 배열일 수도 있음
      List<dynamic> entryList;
      if (entryData is List) {
        entryList = entryData;
      } else if (entryData is Map) {
        entryList = [entryData];
      } else {
        entryList = [];
      }

      final List<iTunesTrack> tracks = [];
      for (int i = 0; i < entryList.length; i++) {
        try {
          final item = entryList[i];
          if (item is Map<String, dynamic>) {
            tracks.add(iTunesTrack.fromRssJson(item, rank: i + 1));
          }
        } catch (e) {
          // 개별 트랙 파싱 실패해도 계속 진행
          continue;
        }
      }
      return tracks;
    } catch (e) {
      if (e is iTunesException) rethrow;
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

      dynamic data = response.data;
      if (data is String) {
        data = jsonDecode(data);
      }

      if (data is! Map<String, dynamic>) {
        return [];
      }

      final results = data['results'];
      if (results is! List) {
        return [];
      }

      final List<iTunesTrack> tracks = [];
      for (final item in results) {
        try {
          if (item is Map<String, dynamic>) {
            tracks.add(iTunesTrack.fromSearchJson(item));
          }
        } catch (_) {
          continue;
        }
      }
      return tracks;
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

      dynamic data = response.data;
      if (data is String) {
        data = jsonDecode(data);
      }

      if (data is! Map<String, dynamic>) {
        return [];
      }

      final results = data['results'];
      if (results is! List) {
        return [];
      }

      // 첫 번째는 아티스트 정보이므로 제외
      final List<iTunesTrack> tracks = [];
      for (int i = 1; i < results.length; i++) {
        try {
          final item = results[i];
          if (item is Map<String, dynamic>) {
            tracks.add(iTunesTrack.fromSearchJson(item));
          }
        } catch (_) {
          continue;
        }
      }
      return tracks;
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
  final int albumId;
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
    required this.albumId,
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

  /// RSS 피드 JSON에서 생성 (차트용)
  factory iTunesTrack.fromRssJson(Map<String, dynamic> json, {int? rank}) {
    // 이미지 URL 추출 (여러 사이즈 중 가장 큰 것)
    String? imageUrl;
    String? imageLargeUrl;

    try {
      final imagesData = json['im:image'];
      if (imagesData is List && imagesData.isNotEmpty) {
        final lastImage = imagesData.last;
        if (lastImage is Map) {
          imageUrl = lastImage['label']?.toString();
          // 더 큰 이미지로 변환 (170x170 -> 600x600)
          imageLargeUrl = imageUrl?.replaceAll('170x170', '600x600');
        }
      }
    } catch (_) {}

    // 아티스트 정보
    int artistIdParsed = 0;
    try {
      final artistData = json['im:artist'];
      if (artistData is Map) {
        final attrs = artistData['attributes'];
        if (attrs is Map) {
          final href = attrs['href']?.toString() ?? '';
          final artistIdMatch = RegExp(r'/id(\d+)').firstMatch(href);
          artistIdParsed = int.tryParse(artistIdMatch?.group(1) ?? '') ?? 0;
        }
      }
    } catch (_) {}

    // 트랙 ID 추출
    String trackIdStr = '';
    try {
      final idData = json['id'];
      if (idData is Map) {
        final attrs = idData['attributes'];
        if (attrs is Map) {
          trackIdStr = attrs['im:id']?.toString() ?? '';
        }
      }
    } catch (_) {}

    // 장르
    String? genreStr;
    try {
      final categoryData = json['category'];
      if (categoryData is Map) {
        final attrs = categoryData['attributes'];
        if (attrs is Map) {
          genreStr = attrs['label']?.toString();
        }
      }
    } catch (_) {}

    // 릴리즈 날짜
    DateTime? releaseDate;
    try {
      final releaseDateData = json['im:releaseDate'];
      if (releaseDateData is Map) {
        final dateStr = releaseDateData['label']?.toString();
        if (dateStr != null && dateStr.isNotEmpty) {
          releaseDate = DateTime.parse(dateStr);
        }
      }
    } catch (_) {}

    // 트랙 URL
    String? trackUrl;
    try {
      final idData = json['id'];
      if (idData is Map) {
        trackUrl = idData['label']?.toString();
      }
    } catch (_) {}

    // 앨범명
    String albumName = '';
    try {
      final collectionData = json['im:collection'];
      if (collectionData is Map) {
        albumName = _extractLabel(collectionData['im:name']);
      }
    } catch (_) {}

    return iTunesTrack(
      id: trackIdStr,
      name: _extractLabel(json['im:name']),
      artistName: _extractLabel(json['im:artist']),
      artistId: artistIdParsed,
      albumId: 0, // RSS에는 앨범 ID 없음
      albumName: albumName,
      albumImageUrl: imageUrl,
      albumImageUrlLarge: imageLargeUrl,
      previewUrl: null, // RSS에는 미리듣기 URL 없음
      durationMs: 0,
      trackViewUrl: trackUrl,
      rank: rank,
      genre: genreStr,
      releaseDate: releaseDate,
    );
  }

  /// 검색 결과 JSON에서 생성
  factory iTunesTrack.fromSearchJson(Map<String, dynamic> json) {
    String? imageUrl = json['artworkUrl100'] as String?;
    String? imageLargeUrl = imageUrl?.replaceAll('100x100', '600x600');

    return iTunesTrack(
      id: (json['trackId'] ?? 0).toString(),
      name: json['trackName'] as String? ?? '',
      artistName: json['artistName'] as String? ?? '',
      artistId: json['artistId'] as int? ?? 0,
      albumId: json['collectionId'] as int? ?? 0,
      albumName: json['collectionName'] as String? ?? '',
      albumImageUrl: imageUrl,
      albumImageUrlLarge: imageLargeUrl,
      previewUrl: json['previewUrl'] as String?,
      durationMs: json['trackTimeMillis'] as int? ?? 0,
      trackViewUrl: json['trackViewUrl'] as String?,
      genre: json['primaryGenreName'] as String?,
      releaseDate: _parseDate(json['releaseDate'] as String?),
    );
  }

  /// 재생 시간 포맷 (mm:ss)
  String get formattedDuration {
    if (durationMs == 0) return '--:--';
    final minutes = (durationMs / 60000).floor();
    final seconds = ((durationMs % 60000) / 1000).floor();
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// JSON label 추출 헬퍼
  static String _extractLabel(dynamic data) {
    if (data == null) return '';
    if (data is String) return data;
    if (data is Map) {
      final label = data['label'];
      if (label is String) return label;
      return label?.toString() ?? '';
    }
    return data.toString();
  }

  /// 날짜 파싱 헬퍼
  static DateTime? _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      return DateTime.parse(dateStr);
    } catch (_) {
      return null;
    }
  }

  @override
  String toString() => 'iTunesTrack(id: $id, name: $name, artist: $artistName)';
}

/// iTunes API 예외
class iTunesException implements Exception {
  final String message;
  iTunesException(this.message);

  @override
  String toString() => 'iTunesException: $message';
}