/// Spotify 트랙 모델
class SpotifyTrack {
  final String id;
  final String name;
  final String artistName;
  final String artistId;
  final String albumName;
  final String albumId;
  final String? albumImageUrl;
  final String? previewUrl;
  final int durationMs;
  final int popularity;
  final bool explicit;
  final String? spotifyUrl;

  const SpotifyTrack({
    required this.id,
    required this.name,
    required this.artistName,
    required this.artistId,
    required this.albumName,
    required this.albumId,
    this.albumImageUrl,
    this.previewUrl,
    required this.durationMs,
    required this.popularity,
    required this.explicit,
    this.spotifyUrl,
  });

  factory SpotifyTrack.fromJson(Map<String, dynamic> json) {
    final track = json['track'] ?? json;
    final album = track['album'] as Map<String, dynamic>?;
    final artists = track['artists'] as List<dynamic>?;
    final artist = artists?.isNotEmpty == true ? artists!.first : null;
    
    // 앨범 이미지 - 가장 큰 이미지 선택
    String? imageUrl;
    if (album != null && album['images'] != null) {
      final images = album['images'] as List<dynamic>;
      if (images.isNotEmpty) {
        imageUrl = images.first['url'] as String?;
      }
    }

    return SpotifyTrack(
      id: track['id'] as String? ?? '',
      name: track['name'] as String? ?? '',
      artistName: artist?['name'] as String? ?? 'Unknown Artist',
      artistId: artist?['id'] as String? ?? '',
      albumName: album?['name'] as String? ?? '',
      albumId: album?['id'] as String? ?? '',
      albumImageUrl: imageUrl,
      previewUrl: track['preview_url'] as String?,
      durationMs: track['duration_ms'] as int? ?? 0,
      popularity: track['popularity'] as int? ?? 0,
      explicit: track['explicit'] as bool? ?? false,
      spotifyUrl: track['external_urls']?['spotify'] as String?,
    );
  }

  /// 재생 시간을 포맷된 문자열로 반환 (mm:ss)
  String get formattedDuration {
    final minutes = (durationMs / 60000).floor();
    final seconds = ((durationMs % 60000) / 1000).floor();
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  String toString() => 'SpotifyTrack(id: $id, name: $name, artist: $artistName)';
}

/// 플레이리스트 모델
class SpotifyPlaylist {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final int totalTracks;
  final List<SpotifyTrack> tracks;

  const SpotifyPlaylist({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.totalTracks,
    required this.tracks,
  });

  factory SpotifyPlaylist.fromJson(Map<String, dynamic> json) {
    final images = json['images'] as List<dynamic>?;
    final tracksData = json['tracks'] as Map<String, dynamic>?;
    final items = tracksData?['items'] as List<dynamic>? ?? [];

    return SpotifyPlaylist(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      imageUrl: images?.isNotEmpty == true ? images!.first['url'] as String? : null,
      totalTracks: tracksData?['total'] as int? ?? 0,
      tracks: items
          .where((item) => item['track'] != null)
          .map((item) => SpotifyTrack.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// 검색 결과 모델
class SearchResult {
  final List<SpotifyTrack> tracks;
  final int total;
  final int offset;
  final int limit;

  const SearchResult({
    required this.tracks,
    required this.total,
    required this.offset,
    required this.limit,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    final tracksData = json['tracks'] as Map<String, dynamic>?;
    final items = tracksData?['items'] as List<dynamic>? ?? [];

    return SearchResult(
      tracks: items
          .map((item) => SpotifyTrack.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: tracksData?['total'] as int? ?? 0,
      offset: tracksData?['offset'] as int? ?? 0,
      limit: tracksData?['limit'] as int? ?? 20,
    );
  }

  bool get hasMore => offset + limit < total;
}

/// 아티스트 모델
class SpotifyArtist {
  final String id;
  final String name;
  final String? imageUrl;
  final List<String> genres;
  final int followers;
  final int popularity;

  const SpotifyArtist({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.genres,
    required this.followers,
    required this.popularity,
  });

  factory SpotifyArtist.fromJson(Map<String, dynamic> json) {
    final images = json['images'] as List<dynamic>?;
    final genres = json['genres'] as List<dynamic>?;

    return SpotifyArtist(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      imageUrl: images?.isNotEmpty == true ? images!.first['url'] as String? : null,
      genres: genres?.map((g) => g as String).toList() ?? [],
      followers: json['followers']?['total'] as int? ?? 0,
      popularity: json['popularity'] as int? ?? 0,
    );
  }

  /// 일본 아티스트인지 확인
  bool get isJapanese {
    const japaneseGenres = [
      'j-pop', 'j-rock', 'japanese', 'anime', 'vocaloid',
      'city pop', 'visual kei', 'enka',
    ];
    return genres.any((g) => 
      japaneseGenres.any((jg) => g.toLowerCase().contains(jg))
    );
  }
}
