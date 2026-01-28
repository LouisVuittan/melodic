import 'dart:convert';
import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../../data/models/spotify_models.dart';

/// Spotify API 서비스
/// 일본 음악 전용 필터링 및 데이터 가져오기
class SpotifyService {
  final Dio _dio;
  String? _accessToken;
  DateTime? _tokenExpiry;

  // Spotify API 자격 증명 (실제 앱에서는 환경변수 또는 보안 저장소 사용)
  final String _clientId;
  final String _clientSecret;

  SpotifyService({
    required String clientId,
    required String clientSecret,
    Dio? dio,
  })  : _clientId = clientId,
        _clientSecret = clientSecret,
        _dio = dio ?? Dio();

  /// 액세스 토큰 가져오기 (Client Credentials Flow)
  Future<String> _getAccessToken() async {
    // 캐시된 토큰이 유효하면 재사용
    if (_accessToken != null && 
        _tokenExpiry != null && 
        DateTime.now().isBefore(_tokenExpiry!)) {
      return _accessToken!;
    }

    try {
      final credentials = base64Encode(utf8.encode('$_clientId:$_clientSecret'));
      
      final response = await _dio.post(
        SpotifyConfig.authUrl,
        data: {'grant_type': 'client_credentials'},
        options: Options(
          headers: {
            'Authorization': 'Basic $credentials',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
      );

      _accessToken = response.data['access_token'];
      final expiresIn = response.data['expires_in'] as int;
      _tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn - 60)); // 1분 여유

      return _accessToken!;
    } catch (e) {
      throw SpotifyException('Failed to get access token: $e');
    }
  }

  /// API 요청 헤더
  Future<Options> _getAuthOptions() async {
    final token = await _getAccessToken();
    return Options(
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  /// Japan Top 50 플레이리스트 가져오기
  Future<SpotifyPlaylist> getJapanTop50() async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get(
        '${SpotifyConfig.baseUrl}/playlists/${SpotifyConfig.japanTop50PlaylistId}',
        queryParameters: {
          'market': SpotifyConfig.japanMarket,
          'fields': 'id,name,description,images,tracks(total,items(track(id,name,artists,album,duration_ms,popularity,explicit,preview_url,external_urls)))',
        },
        options: options,
      );

      return SpotifyPlaylist.fromJson(response.data);
    } catch (e) {
      throw SpotifyException('Failed to fetch Japan Top 50: $e');
    }
  }

  /// Japan Viral 50 플레이리스트 가져오기
  Future<SpotifyPlaylist> getJapanViral50() async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get(
        '${SpotifyConfig.baseUrl}/playlists/${SpotifyConfig.japanViral50PlaylistId}',
        queryParameters: {
          'market': SpotifyConfig.japanMarket,
          'fields': 'id,name,description,images,tracks(total,items(track(id,name,artists,album,duration_ms,popularity,explicit,preview_url,external_urls)))',
        },
        options: options,
      );

      return SpotifyPlaylist.fromJson(response.data);
    } catch (e) {
      throw SpotifyException('Failed to fetch Japan Viral 50: $e');
    }
  }

  /// 일본 노래 검색
  /// genre:j-pop 필터를 사용하여 일본 음악만 검색
  Future<SearchResult> searchJapaneseTracks({
    required String query,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final options = await _getAuthOptions();
      
      // 검색 쿼리에 일본 장르 필터 추가
      final searchQuery = '$query genre:j-pop OR genre:j-rock OR genre:anime';
      
      final response = await _dio.get(
        '${SpotifyConfig.baseUrl}/search',
        queryParameters: {
          'q': searchQuery,
          'type': 'track',
          'market': SpotifyConfig.japanMarket,
          'limit': limit,
          'offset': offset,
        },
        options: options,
      );

      return SearchResult.fromJson(response.data);
    } catch (e) {
      throw SpotifyException('Failed to search tracks: $e');
    }
  }

  /// 트랙 상세 정보 가져오기
  Future<SpotifyTrack> getTrack(String trackId) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get(
        '${SpotifyConfig.baseUrl}/tracks/$trackId',
        queryParameters: {'market': SpotifyConfig.japanMarket},
        options: options,
      );

      return SpotifyTrack.fromJson(response.data);
    } catch (e) {
      throw SpotifyException('Failed to fetch track: $e');
    }
  }

  /// 아티스트 정보 가져오기
  Future<SpotifyArtist> getArtist(String artistId) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get(
        '${SpotifyConfig.baseUrl}/artists/$artistId',
        options: options,
      );

      return SpotifyArtist.fromJson(response.data);
    } catch (e) {
      throw SpotifyException('Failed to fetch artist: $e');
    }
  }

  /// 추천 트랙 가져오기 (일본 음악 시드 기반)
  Future<List<SpotifyTrack>> getRecommendations({
    List<String>? seedTracks,
    List<String>? seedArtists,
    int limit = 20,
  }) async {
    try {
      final options = await _getAuthOptions();
      
      final queryParams = <String, dynamic>{
        'limit': limit,
        'market': SpotifyConfig.japanMarket,
        // J-Pop 장르 시드
        'seed_genres': 'j-pop,anime',
      };

      if (seedTracks != null && seedTracks.isNotEmpty) {
        queryParams['seed_tracks'] = seedTracks.take(2).join(',');
      }
      if (seedArtists != null && seedArtists.isNotEmpty) {
        queryParams['seed_artists'] = seedArtists.take(2).join(',');
      }

      final response = await _dio.get(
        '${SpotifyConfig.baseUrl}/recommendations',
        queryParameters: queryParams,
        options: options,
      );

      final tracks = response.data['tracks'] as List<dynamic>;
      return tracks
          .map((t) => SpotifyTrack.fromJson(t as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw SpotifyException('Failed to get recommendations: $e');
    }
  }

  /// 새 릴리즈 (일본) 가져오기
  Future<List<SpotifyTrack>> getNewReleases({int limit = 20}) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get(
        '${SpotifyConfig.baseUrl}/browse/new-releases',
        queryParameters: {
          'country': SpotifyConfig.japanMarket,
          'limit': limit,
        },
        options: options,
      );

      final albums = response.data['albums']['items'] as List<dynamic>;
      
      // 각 앨범의 첫 번째 트랙 가져오기
      final tracks = <SpotifyTrack>[];
      for (final album in albums.take(limit)) {
        final albumId = album['id'] as String;
        try {
          final albumTracks = await _getAlbumTracks(albumId);
          if (albumTracks.isNotEmpty) {
            tracks.add(albumTracks.first);
          }
        } catch (_) {
          // 개별 앨범 실패는 무시
        }
      }

      return tracks;
    } catch (e) {
      throw SpotifyException('Failed to get new releases: $e');
    }
  }

  /// 앨범 트랙 가져오기
  Future<List<SpotifyTrack>> _getAlbumTracks(String albumId) async {
    final options = await _getAuthOptions();
    final response = await _dio.get(
      '${SpotifyConfig.baseUrl}/albums/$albumId/tracks',
      queryParameters: {'market': SpotifyConfig.japanMarket, 'limit': 1},
      options: options,
    );

    final items = response.data['items'] as List<dynamic>;
    return items
        .map((t) => SpotifyTrack.fromJson(t as Map<String, dynamic>))
        .toList();
  }
}

/// Spotify API 예외
class SpotifyException implements Exception {
  final String message;
  SpotifyException(this.message);

  @override
  String toString() => 'SpotifyException: $message';
}
