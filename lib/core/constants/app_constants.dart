/// Spotify API 설정
class SpotifyConfig {
  SpotifyConfig._();

  /// Spotify API 기본 URL
  static const String baseUrl = 'https://api.spotify.com/v1';
  
  /// 인증 URL
  static const String authUrl = 'https://accounts.spotify.com/api/token';
  
  /// Japan Top 50 플레이리스트 ID (공식 Spotify)
  static const String japanTop50PlaylistId = '37i9dQZEVXbKXQ4mDTEBXq';
  
  /// Japan Viral 50 플레이리스트 ID
  static const String japanViral50PlaylistId = '37i9dQZEVXbKqiTGXuCOsB';
  
  /// Top Tracks of 2025 Japan
  static const String japanTop2025PlaylistId = '37i9dQZF1DWYYQb2mqFd5I';
  
  /// 일본어 장르 키워드
  static const List<String> japaneseGenres = [
    'j-pop',
    'j-rock',
    'japanese',
    'anime',
    'vocaloid',
    'city pop',
    'visual kei',
    'japanese r&b',
    'japanese hip hop',
    'enka',
  ];
  
  /// 일본 마켓 코드
  static const String japanMarket = 'JP';
}

/// 앱 상수
class AppConstants {
  AppConstants._();
  
  /// 앱 이름
  static const String appName = 'Melodic';
  
  /// 앱 슬로건
  static const String appTagline = '音楽で学ぶ日本語';
  static const String appTaglineKr = '음악으로 배우는 일본어';
  
  /// 애니메이션 duration
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  
  /// 페이지네이션
  static const int defaultPageSize = 20;
  static const int maxSearchResults = 50;
}

/// 로컬 스토리지 키
class StorageKeys {
  StorageKeys._();
  
  static const String spotifyAccessToken = 'spotify_access_token';
  static const String spotifyTokenExpiry = 'spotify_token_expiry';
  static const String recentSearches = 'recent_searches';
  static const String savedSongs = 'saved_songs';
  static const String learningProgress = 'learning_progress';
}
