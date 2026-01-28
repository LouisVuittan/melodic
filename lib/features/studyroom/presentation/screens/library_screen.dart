import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// 학습 아이템 모델
class LibraryItem {
  final String id;
  final String title;
  final String subtitle;
  final String? imageUrl;
  final String type; // 'vocabulary', 'grammar', 'song'
  final int itemCount;

  LibraryItem({
    required this.id,
    required this.title,
    required this.subtitle,
    this.imageUrl,
    required this.type,
    this.itemCount = 0,
  });
}

/// 트렌디한 라이브러리 화면
/// 카테고리 탭 + 그리드 카드 레이아웃
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  final List<String> _tabs = ['전체', '단어장', '문법', '노래'];

  // TODO: 실제 데이터 연동
  final List<LibraryItem> _items = [
    LibraryItem(
      id: '1',
      title: 'Ed Sheeran 노래',
      subtitle: '15 words',
      type: 'vocabulary',
      itemCount: 15,
      imageUrl: 'https://picsum.photos/400/400?random=10',
    ),
    LibraryItem(
      id: '2',
      title: 'N4 문법 정리',
      subtitle: '8 patterns',
      type: 'grammar',
      itemCount: 8,
      imageUrl: 'https://picsum.photos/400/400?random=11',
    ),
    LibraryItem(
      id: '3',
      title: 'Perfect',
      subtitle: 'Ed Sheeran',
      type: 'song',
      imageUrl: 'https://picsum.photos/400/400?random=12',
    ),
    LibraryItem(
      id: '4',
      title: '일상 회화',
      subtitle: '32 words',
      type: 'vocabulary',
      itemCount: 32,
      imageUrl: 'https://picsum.photos/400/400?random=13',
    ),
    LibraryItem(
      id: '5',
      title: 'Lemon',
      subtitle: '米津玄師',
      type: 'song',
      imageUrl: 'https://picsum.photos/400/400?random=14',
    ),
    LibraryItem(
      id: '6',
      title: '~ている 패턴',
      subtitle: '5 examples',
      type: 'grammar',
      itemCount: 5,
      imageUrl: 'https://picsum.photos/400/400?random=15',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<LibraryItem> _getFilteredItems(int tabIndex) {
    if (tabIndex == 0) return _items;
    final types = ['', 'vocabulary', 'grammar', 'song'];
    return _items.where((item) => item.type == types[tabIndex]).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            // 헤더
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Library',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -1,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.search_rounded,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 카테고리 탭
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  labelPadding: const EdgeInsets.symmetric(horizontal: 6),
                  indicatorSize: TabBarIndicatorSize.label,
                  indicator: const BoxDecoration(), // 인디케이터 제거
                  dividerColor: Colors.transparent,
                  labelColor: AppColors.accentOnDark,
                  unselectedLabelColor: AppColors.textSecondary,
                  labelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  tabs: _tabs.map((tab) {
                    final index = _tabs.indexOf(tab);
                    return Tab(
                      child: AnimatedBuilder(
                        animation: _tabController,
                        builder: (context, child) {
                          final isSelected = _tabController.index == index;
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.accent
                                  : AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(tab),
                          );
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            children: List.generate(
              _tabs.length,
              (index) => _LibraryGrid(items: _getFilteredItems(index)),
            ),
          ),
        ),
      ),
    );
  }
}

/// 스티키 탭바 델리게이트
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _StickyTabBarDelegate(this.tabBar);

  @override
  double get minExtent => 60;

  @override
  double get maxExtent => 60;

  @override
  Widget build(context, shrinkOffset, overlapsContent) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant _StickyTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}

/// 그리드 레이아웃
class _LibraryGrid extends StatelessWidget {
  final List<LibraryItem> items;

  const _LibraryGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.folder_open_rounded,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 16),
            const Text(
              '아직 저장된 항목이 없어요',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => _LibraryCard(item: items[index]),
    );
  }
}

/// 라이브러리 카드
class _LibraryCard extends StatelessWidget {
  final LibraryItem item;

  const _LibraryCard({required this.item});

  Color get _typeColor {
    switch (item.type) {
      case 'vocabulary':
        return AppColors.brandCyan;
      case 'grammar':
        return AppColors.brandPink;
      case 'song':
        return AppColors.brandPurple;
      default:
        return AppColors.accent;
    }
  }

  IconData get _typeIcon {
    switch (item.type) {
      case 'vocabulary':
        return Icons.book_rounded;
      case 'grammar':
        return Icons.auto_awesome_rounded;
      case 'song':
        return Icons.music_note_rounded;
      default:
        return Icons.folder_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: 상세 페이지로 이동
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지 영역
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // 배경 이미지/그라디언트
                    item.imageUrl != null
                        ? Image.network(
                            item.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildGradientBg(),
                          )
                        : _buildGradientBg(),
                    
                    // 오버레이
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.5),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),

                    // 타입 아이콘
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _typeColor.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          _typeIcon,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    // 더보기 버튼
                    Positioned(
                      top: 8,
                      left: 8,
                      child: IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.more_vert_rounded,
                          color: Colors.white70,
                          size: 20,
                        ),
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 텍스트 영역
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientBg() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _typeColor.withOpacity(0.8),
            _typeColor.withOpacity(0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          _typeIcon,
          size: 40,
          color: Colors.white.withOpacity(0.5),
        ),
      ),
    );
  }
}
