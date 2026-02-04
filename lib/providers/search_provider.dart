import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/itunes_service.dart';
import 'app_providers.dart';

/// 검색어 상태
final searchQueryProvider = StateProvider<String>((ref) => '');

/// 검색 활성화 상태
final isSearchActiveProvider = StateProvider<bool>((ref) => false);

/// 검색 결과 Provider (debounce 적용)
final searchResultsProvider = FutureProvider.autoDispose<List<iTunesTrack>>((ref) async {
  final query = ref.watch(searchQueryProvider);

  // 2글자 미만이면 빈 결과
  if (query.length < 2) {
    return [];
  }

  // Debounce 300ms
  await Future.delayed(const Duration(milliseconds: 300));

  // 취소 체크 (새로운 검색어가 들어왔으면 취소)
  if (ref.read(searchQueryProvider) != query) {
    throw Exception('cancelled');
  }

  final service = ref.read(iTunesServiceProvider);

  try {
    // iTunes 일본 검색 (20개 가져와서 필터링 후 5개)
    final results = await service.searchJapaneseMusic(
      query: query,
      limit: 20,
    );

    // 일본 노래만 필터링 (히라가나, 카타카나, 한자 포함 여부)
    final japaneseOnly = results.where(_isJapaneseSong).toList();

    // 상위 5개만 반환
    return japaneseOnly.take(5).toList();
  } catch (e) {
    if (e.toString().contains('cancelled')) {
      return [];
    }
    rethrow;
  }
});

/// 일본 노래인지 확인 (아티스트명 또는 트랙명에 일본어 포함)
bool _isJapaneseSong(iTunesTrack track) {
  final text = '${track.name}${track.artistName}';
  return _containsJapanese(text);
}

/// 일본어 문자 포함 여부 체크
bool _containsJapanese(String text) {
  // 히라가나: \u3040-\u309F
  // 카타카나: \u30A0-\u30FF
  // 한자 (CJK): \u4E00-\u9FAF
  final japaneseRegex = RegExp(r'[\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FAF]');
  return japaneseRegex.hasMatch(text);
}

/// 검색 초기화
void clearSearch(WidgetRef ref) {
  ref.read(searchQueryProvider.notifier).state = '';
  ref.read(isSearchActiveProvider.notifier).state = false;
}