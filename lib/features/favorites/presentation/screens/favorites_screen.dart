import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// 즐겨찾기 아이템 모델
class FavoriteItem {
  final String id;
  final String title;
  final String artist;
  final String? imageUrl;
  final int progress;
  final DateTime addedAt;

  FavoriteItem({
    required this.id,
    required this.title,
    required this.artist,
    this.imageUrl,
    this.progress = 0,
    required this.addedAt,
  });
}

/// 즐겨찾기 화면
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  // TODO: 실제 데이터 연동
  List<FavoriteItem> get _favorites => [
    FavoriteItem(
      id: '1',
      title: 'Perfect',
      artist: 'Ed Sheeran',
      progress: 85,
      addedAt: DateTime.now().subtract(const Duration(days: 2)),
      imageUrl: 'https://picsum.photos/200/200?random=20',
    ),
    FavoriteItem(
      id: '2',
      title: 'Lemon',
      artist: '米津玄師',
      progress: 45,
      addedAt: DateTime.now().subtract(const Duration(days: 5)),
      imageUrl: 'https://picsum.photos/200/200?random=21',
    ),
    FavoriteItem(
      id: '3',
      title: 'Dynamite',
      artist: 'BTS',
      progress: 100,
      addedAt: DateTime.now().subtract(const Duration(days: 7)),
      imageUrl: 'https://picsum.photos/200/200?random=22',
    ),
    FavoriteItem(
      id: '4',
      title: 'Blinding Lights',
      artist: 'The Weeknd',
      progress: 20,
      addedAt: DateTime.now().subtract(const Duration(days: 10)),
      imageUrl: 'https://picsum.photos/200/200?random=23',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 헤더
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: const Text(
                  'Favorites',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -1,
                  ),
                ),
              ),
            ),

            // 통계 카드
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.brandPink.withOpacity(0.3),
                        AppColors.brandPurple.withOpacity(0.3),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.brandPink.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.brandPink.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.favorite_rounded,
                          color: AppColors.brandPink,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_favorites.length} songs',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'in your collection',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 노래 리스트
            if (_favorites.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.favorite_outline_rounded,
                        size: 64,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No favorites yet',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = _favorites[index];
                    return _FavoriteListTile(item: item);
                  },
                  childCount: _favorites.length,
                ),
              ),

            // 하단 여백
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteListTile extends StatelessWidget {
  final FavoriteItem item;

  const _FavoriteListTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: item.imageUrl != null
              ? Image.network(
                  item.imageUrl!,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildPlaceholder(),
                )
              : _buildPlaceholder(),
        ),
        title: Text(
          item.title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              item.artist,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: item.progress / 100,
                      backgroundColor: AppColors.surfaceVariant,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        item.progress == 100
                            ? AppColors.success
                            : AppColors.brandCyan,
                      ),
                      minHeight: 3,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${item.progress}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: item.progress == 100
                        ? AppColors.success
                        : AppColors.brandCyan,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          onPressed: () {
            // TODO: 플레이
          },
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.play_arrow_rounded,
              color: AppColors.accentOnDark,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: AppColors.cyanPurpleGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.music_note_rounded,
        color: Colors.white,
      ),
    );
  }
}
