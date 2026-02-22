import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// 아티스트 이미지 서비스 (Deezer API)
/// Last.fm이 이미지 제공 중단해서 Deezer로 대체
class ArtistImageService {
  final Dio _dio;

  ArtistImageService({Dio? dio}) : _dio = dio ?? Dio();

  /// 아티스트 프로필 이미지 URL 가져오기
  Future<String?> getArtistImageUrl(String artistName) async {
    try {
      final response = await _dio.get(
        'https://api.deezer.com/search/artist',
        queryParameters: {
          'q': artistName,
          'limit': 1,
        },
      );

      final data = response.data;
      if (data == null) return null;

      final artists = data['data'] as List<dynamic>?;
      if (artists == null || artists.isEmpty) return null;

      final artist = artists.first as Map<String, dynamic>;

      // picture_xl이 가장 큰 이미지 (1000x1000)
      // picture_big (500x500), picture_medium (250x250), picture (56x56)
      final imageUrl = artist['picture_xl'] as String? ??
          artist['picture_big'] as String? ??
          artist['picture_medium'] as String?;

      debugPrint('[ArtistImage] $artistName → $imageUrl');
      return imageUrl;
    } catch (e) {
      debugPrint('[ArtistImage] 오류: $e');
      return null;
    }
  }
}