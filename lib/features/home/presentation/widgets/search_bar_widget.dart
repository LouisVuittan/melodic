import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';

/// 검색 결과 모델
class SearchResultItem {
  final String id;
  final String title;
  final String artist;
  final String? albumImageUrl;
  final String type; // 'track', 'artist', 'album'

  SearchResultItem({
    required this.id,
    required this.title,
    required this.artist,
    this.albumImageUrl,
    this.type = 'track',
  });
}

/// 멜로딕 검색바 위젯
/// Next.js SearchBar 컴포넌트를 Flutter로 마이그레이션
class MelodicSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback? onSearchStart;
  final VoidCallback? onSearchEnd;
  final ValueChanged<SearchResultItem>? onSongSelected;

  const MelodicSearchBar({
    super.key,
    required this.controller,
    this.onSearchStart,
    this.onSearchEnd,
    this.onSongSelected,
  });

  @override
  State<MelodicSearchBar> createState() => _MelodicSearchBarState();
}

class _MelodicSearchBarState extends State<MelodicSearchBar> {
  final _focusNode = FocusNode();
  bool _isFocused = false;
  bool _isLoading = false;
  bool _isProcessing = false;
  List<SearchResultItem> _results = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
    if (_focusNode.hasFocus) {
      widget.onSearchStart?.call();
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.length < 2) {
      setState(() {
        _results = [];
        _errorMessage = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // TODO: Spotify API 연동
      // 임시 더미 데이터
      await Future.delayed(const Duration(milliseconds: 500));
      
      setState(() {
        _results = [
          SearchResultItem(
            id: '1',
            title: 'Shape of You',
            artist: 'Ed Sheeran',
            albumImageUrl: null,
          ),
          SearchResultItem(
            id: '2',
            title: 'Blinding Lights',
            artist: 'The Weeknd',
            albumImageUrl: null,
          ),
          SearchResultItem(
            id: '3',
            title: 'Lemon',
            artist: '米津玄師',
            albumImageUrl: null,
          ),
        ].where((item) => 
          item.title.toLowerCase().contains(query.toLowerCase()) ||
          item.artist.toLowerCase().contains(query.toLowerCase())
        ).toList();
      });
    } catch (e) {
      setState(() {
        _errorMessage = '검색 중 오류가 발생했습니다';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onResultTap(SearchResultItem result) async {
    setState(() {
      _isProcessing = true;
    });

    widget.onSongSelected?.call(result);

    // 검색 상태 초기화
    setState(() {
      _isProcessing = false;
      _isFocused = false;
      _results = [];
    });
    widget.controller.clear();
    _focusNode.unfocus();
    widget.onSearchEnd?.call();
  }

  void _clearSearch() {
    widget.controller.clear();
    setState(() {
      _results = [];
      _errorMessage = null;
    });
  }

  void _closeSearch() {
    _focusNode.unfocus();
    setState(() {
      _isFocused = false;
      _results = [];
    });
    widget.onSearchEnd?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 검색 입력 필드
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _isFocused ? AppColors.surfaceVariant : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isFocused ? AppColors.accent500 : AppColors.border,
              width: _isFocused ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Icon(
                LucideIcons.search,
                size: 20,
                color: _isFocused ? AppColors.accent500 : AppColors.gray400,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  onChanged: _performSearch,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                  ),
                  decoration: const InputDecoration(
                    hintText: '노래 또는 아티스트 검색...',
                    hintStyle: TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              if (widget.controller.text.isNotEmpty)
                IconButton(
                  icon: const Icon(LucideIcons.x, size: 20),
                  color: AppColors.gray400,
                  onPressed: _clearSearch,
                ),
              if (_isFocused)
                TextButton(
                  onPressed: _closeSearch,
                  child: const Text(
                    '취소',
                    style: TextStyle(
                      color: AppColors.accent400,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // 검색 결과
        if (_isFocused && (widget.controller.text.isNotEmpty || _results.isNotEmpty))
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            constraints: const BoxConstraints(maxHeight: 400),
            child: _buildResultsList(),
          ),
      ],
    );
  }

  Widget _buildResultsList() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.accent500,
          ),
        ),
      );
    }

    if (_isProcessing) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.accent500,
            ),
            const SizedBox(height: 16),
            Text(
              '영상과 가사를 찾는 중...',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              LucideIcons.alertCircle,
              color: AppColors.error,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    if (_results.isEmpty && widget.controller.text.length >= 2) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Text(
            '검색 결과가 없습니다',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final result = _results[index];
        return _SearchResultTile(
          result: result,
          onTap: () => _onResultTap(result),
        );
      },
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  final SearchResultItem result;
  final VoidCallback onTap;

  const _SearchResultTile({
    required this.result,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // 앨범 커버
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: result.albumImageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        result.albumImageUrl!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Icon(
                      LucideIcons.music,
                      color: AppColors.gray500,
                      size: 24,
                    ),
            ),
            const SizedBox(width: 12),
            // 노래 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    result.artist,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // 타입 아이콘
            const Icon(
              LucideIcons.chevronRight,
              size: 20,
              color: AppColors.gray500,
            ),
          ],
        ),
      ),
    );
  }
}
