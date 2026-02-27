import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html_parser;
import 'itunes_service.dart';

class KoreaChartService {
  final Dio _dio;

  KoreaChartService({Dio? dio}) : _dio = dio ?? Dio();

  /// 멜론 J-POP 인기순 스크래핑 + iTunes 일본어 원어 세탁 🇯🇵
  Future<List<iTunesTrack>> getMelonJPopChart({int limit = 50}) async {
    try {
      // 1. 멜론에서 일단 랭킹과 임시 제목들을 싹 긁어옵니다.
      final response = await _dio.get(
        'https://www.melon.com/genre/song_list.htm?gnrCode=GN1900&dtlGnrCode=&orderBy=POP',
        options: Options(
          headers: {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
          },
        ),
      );

      final document = html_parser.parse(response.data);
      final List<iTunesTrack> rawTracks = [];

      // 🚫 K-Pop 아이돌 필터 (이전과 동일)
      final List<String> kpopFilter = [
        'TWICE', '트와이스', 'BTS', '방탄소년단', 'SEVENTEEN', '세븐틴',
        'Stray Kids', '스트레이 키즈', 'ENHYPEN', '엔하이픈', 'TXT', '투모로우바이투게더',
        'LE SSERAFIM', '르세라핌', 'IVE', '아이브', 'NewJeans', '뉴진스',
        'aespa', '에스파', 'BLACKPINK', '블랙핑크', 'NCT', '엔시티',
        'TREASURE', '트레저', 'ITZY', '있지', 'NMIXX', '엔믹스',
        'Kep1er', '케플러', 'ZEROBASEONE', '제로베이스원', 'RIIZE', '라이즈',
        'BOYNEXTDOOR', '보이넥스트도어', 'ATEEZ', '에이티즈', 'THE BOYZ', '더보이즈',
        'STAYC', '스테이씨', 'TWS', '투어스', 'ILLIT', '아일릿', 'BABYMONSTER', '베이비몬스터',
        'KARA', '카라', 'Girls\' Generation', '소녀시대', 'BoA', '보아',
        'TVXQ', '동방신기', 'SHINee', '샤이니', 'EXO', '엑소', 'Red Velvet', '레드벨벳',
        '투애니원', '2NE1', '빅뱅', 'BIGBANG', '이창섭'
      ];

      final rows = document.querySelectorAll('tbody > tr');

      for (int i = 0; i < rows.length; i++) {
        if (rawTracks.length >= limit) break;

        final row = rows[i];
        final title = row.querySelector('div.ellipsis.rank01 a')?.text.trim() ?? '';
        final artist = row.querySelector('div.ellipsis.rank02 a')?.text.trim() ?? '';

        bool isKpop = kpopFilter.any((keyword) => artist.toUpperCase().contains(keyword.toUpperCase()));
        if (isKpop) continue;

        final imgElement = row.querySelector('a.image_typeAll img');
        String? imageUrl = imgElement?.attributes['src'];

        if (title.isNotEmpty && artist.isNotEmpty) {
          rawTracks.add(
            iTunesTrack(
              id: 'melon_temp_${rawTracks.length + 1}',
              name: title,
              artistName: artist,
              artistId: 0,
              albumId: 0,
              albumName: 'Melon J-Pop',
              albumImageUrl: imageUrl,
              durationMs: 0,
              rank: rawTracks.length + 1, // 🌟 멜론 랭킹 순위 부여!
            ),
          );
        }
      }

      // =========================================================
      // 2. 🚀 데이터 세탁: 멜론 데이터를 일본 iTunes API에 검색해서 원어로 바꿈!
      // =========================================================

      // Future.wait를 써서 50곡을 동시에 병렬로 검색합니다 (속도 최적화)
      final enrichedTracks = await Future.wait(rawTracks.map((track) async {
        try {
          final searchRes = await _dio.get(
            'https://itunes.apple.com/search',
            queryParameters: {
              'term': '${track.name} ${track.artistName}', // 멜론 이름으로 검색
              'country': 'jp',
              'media': 'music',
              'limit': 1,
              'lang': 'ja_jp', // 🌟 핵심: 결과를 무조건 일본어로 달라고 강제함
            },
          );

          dynamic data = searchRes.data;
          if (data is String) data = jsonDecode(data);

          if (data != null && data['results'] != null && (data['results'] as List).isNotEmpty) {
            final jpData = data['results'][0];

            String? imageUrl = jpData['artworkUrl100'];
            String? imageLargeUrl;
            if (imageUrl != null) {
              imageLargeUrl = imageUrl.replaceAll(RegExp(r'\d+x\d+'), '500x500'); // 404 에러 방지용 500 사이즈
            }

            // 🌟 멜론의 랭킹(rank)은 유지하되, 나머지는 전부 고품질 애플 데이터로 교체
            return iTunesTrack(
              id: jpData['trackId'].toString(),
              name: jpData['trackName'] ?? track.name,
              artistName: jpData['artistName'] ?? track.artistName,
              artistId: jpData['artistId'] ?? 0,
              albumId: jpData['collectionId'] ?? 0,
              albumName: jpData['collectionName'] ?? '',
              albumImageUrl: imageUrl ?? track.albumImageUrl,
              albumImageUrlLarge: imageLargeUrl ?? track.albumImageUrl,
              previewUrl: jpData['previewUrl'],
              durationMs: jpData['trackTimeMillis'] ?? 0,
              trackViewUrl: jpData['trackViewUrl'],
              rank: track.rank, // 멜론 랭킹 유지
              genre: jpData['primaryGenreName'],
            );
          }
        } catch (e) {
          // 검색 중 에러가 나면 튕기지 않고 그냥 멜론 원본 데이터를 반환
        }
        return track;
      }));

      return enrichedTracks;

    } catch (e) {
      throw Exception('한국 J-Pop 차트를 불러오는데 실패했습니다: $e');
    }
  }
}