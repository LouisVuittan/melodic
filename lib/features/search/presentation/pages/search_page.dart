import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/theme.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isSearching = false;
  List<Map<String, String>> _searchResults = [];
  List<String> _recentSearches = ['夜に駆ける', 'Lemon', 'Shape of You'];

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    // 샘플 검색 결과 - 나중에 실제 API로 교체
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isSearching = false;
          _searchResults = [
            {
              'title': '夜に駆ける',
              'artist': 'YOASOBI',
              'language': 'JP',
            },
            {
              'title': 'Blinding Lights',
              'artist': 'The Weeknd',
              'language': 'EN',
            },
            {
              'title': 'Lemon',
              'artist': '米津玄師',
              'language': 'JP',
            },
          ];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 검색 헤더
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // 뒤로가기 버튼
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.gray800,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        LucideIcons.arrowLeft,
                        color: AppColors.textPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 검색 입력 필드
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.gray800,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _focusNode,
                        onChanged: _performSearch,
                        style: AppTextStyles.bodyLarge,
                        decoration: InputDecoration(
                          hintText: '노래 제목 또는 아티스트 검색',
                          hintStyle: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.gray500,
                          ),
                          prefixIcon: const Icon(
                            LucideIcons.search,
                            color: AppColors.gray500,
                            size: 20,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    _searchController.clear();
                                    _performSearch('');
                                  },
                                  child: const Icon(
                                    LucideIcons.x,
                                    color: AppColors.gray500,
                                    size: 18,
                                  ),
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 검색 결과 또는 최근 검색
            Expanded(
              child: _searchController.text.isEmpty
                  ? _buildRecentSearches()
                  : _buildSearchResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSearches() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '최근 검색',
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.gray400,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() => _recentSearches = []);
                },
                child: Text(
                  '전체 삭제',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.gray500,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _recentSearches.length,
            itemBuilder: (context, index) {
              final search = _recentSearches[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  LucideIcons.history,
                  color: AppColors.gray500,
                  size: 20,
                ),
                title: Text(
                  search,
                  style: AppTextStyles.bodyMedium,
                ),
                trailing: GestureDetector(
                  onTap: () {
                    setState(() {
                      _recentSearches.removeAt(index);
                    });
                  },
                  child: const Icon(
                    LucideIcons.x,
                    color: AppColors.gray500,
                    size: 18,
                  ),
                ),
                onTap: () {
                  _searchController.text = search;
                  _performSearch(search);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.accent500,
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.searchX,
              color: AppColors.gray600,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              '검색 결과가 없습니다',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.gray400,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final song = _searchResults[index];
        return _buildSearchResultItem(song);
      },
    );
  }

  Widget _buildSearchResultItem(Map<String, String> song) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.gray900,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.gray800,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // 앨범 아트 플레이스홀더
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.gray800,
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  AppColors.primary500.withOpacity(0.3),
                  AppColors.accent500.withOpacity(0.3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(
              LucideIcons.music2,
              color: AppColors.gray400,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          // 노래 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        song['title']!,
                        style: AppTextStyles.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: song['language'] == 'JP'
                            ? AppColors.error.withOpacity(0.9)
                            : AppColors.info.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        song['language']!,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  song['artist']!,
                  style: AppTextStyles.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // 학습 시작 버튼
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.accent500,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              LucideIcons.play,
              color: Colors.white,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}
