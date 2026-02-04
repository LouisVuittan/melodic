import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

/// Deezer API 서비스
/// 아티스트 이미지 제공 (무료, API 키 불필요!)
class ArtistImageService {
  final Dio _dio;
  static const String _baseUrl = 'https://api.deezer.com';

  ArtistImageService({Dio? dio}) : _dio = dio ?? Dio();

  /// 아티스트 이미지 URL 가져오기
  Future<String?> getArtistImageUrl(String artistName) async {
    try {
      debugPrint('[Deezer] Fetching image for: $artistName');

      final response = await _dio.get(
        '$_baseUrl/search/artist',
        queryParameters: {
          'q': artistName,
        },
      );

      dynamic data = response.data;
      if (data is String) {
        data = jsonDecode(data);
      }

      if (data is! Map<String, dynamic>) {
        debugPrint('[Deezer] Invalid data format');
        return null;
      }

      final results = data['data'];
      if (results is! List || results.isEmpty) {
        debugPrint('[Deezer] No results found');
        return null;
      }

      // 첫 번째 결과 사용
      final artist = results.first;
      if (artist is! Map<String, dynamic>) {
        return null;
      }

      // picture_xl이 가장 큰 이미지 (1000x1000)
      // picture_big (500x500), picture_medium (250x250), picture (56x56)
      final imageUrl = artist['picture_xl']?.toString()
          ?? artist['picture_big']?.toString()
          ?? artist['picture_medium']?.toString();

      debugPrint('[Deezer] Found image: $imageUrl');

      return imageUrl;
    } catch (e) {
      debugPrint('[Deezer] Error: $e');
      return null;
    }
  }

  /// 아티스트 정보 전체 가져오기
  Future<DeezerArtist?> getArtistInfo(String artistName) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/search/artist',
        queryParameters: {
          'q': artistName,
        },
      );

      dynamic data = response.data;
      if (data is String) {
        data = jsonDecode(data);
      }

      if (data is! Map<String, dynamic>) {
        return null;
      }

      final results = data['data'];
      if (results is! List || results.isEmpty) {
        return null;
      }

      final artist = results.first;
      if (artist is! Map<String, dynamic>) {
        return null;
      }

      return DeezerArtist.fromJson(artist);
    } catch (e) {
      return null;
    }
  }
}

/// Deezer 아티스트 모델
class DeezerArtist {
  final int id;
  final String name;
  final String? imageUrl;
  final int? fans;

  DeezerArtist({
    required this.id,
    required this.name,
    this.imageUrl,
    this.fans,
  });

  factory DeezerArtist.fromJson(Map<String, dynamic> json) {
    return DeezerArtist(
      id: json['id'] as int? ?? 0,
      name: json['name']?.toString() ?? '',
      imageUrl: json['picture_xl']?.toString()
          ?? json['picture_big']?.toString()
          ?? json['picture_medium']?.toString(),
      fans: json['nb_fan'] as int?,
    );
  }
}