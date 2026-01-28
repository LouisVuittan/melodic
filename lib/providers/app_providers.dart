import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/itunes_service.dart';

/// iTunes 서비스 프로바이더 (API 키 불필요!)
final iTunesServiceProvider = Provider<iTunesService>((ref) {
  return iTunesService();
});

/// 일본 Top 100 차트 프로바이더
final japanTopChartProvider = FutureProvider<List<iTunesTrack>>((ref) async {
  final service = ref.watch(iTunesServiceProvider);
  return service.getJapanTopChart(limit: 50);
});

/// 오늘의 추천곡 (1위 곡)
final featuredTrackProvider = FutureProvider<iTunesTrack?>((ref) async {
  final chart = await ref.watch(japanTopChartProvider.future);
  if (chart.isEmpty) return null;
  return chart.first; // 1위 곡
});

/// 검색 쿼리 상태
final searchQueryProvider = StateProvider<String>((ref) => '');

/// 검색 결과 프로바이더
final searchResultsProvider = FutureProvider<List<iTunesTrack>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return [];

  final service = ref.watch(iTunesServiceProvider);
  return service.searchJapaneseMusic(query: query);
});

/// 현재 선택된 트랙
final selectedTrackProvider = StateProvider<iTunesTrack?>((ref) => null);

/// 하단 네비게이션 인덱스
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

/// 학습 진행률 (임시 - 나중에 로컬 저장소와 연동)
final learningProgressProvider = StateProvider<Map<String, double>>((ref) => {});

/// 저장된 노래 목록
final savedSongsProvider = StateProvider<List<iTunesTrack>>((ref) => []);

/// 최근 검색어
final recentSearchesProvider = StateProvider<List<String>>((ref) => []);
