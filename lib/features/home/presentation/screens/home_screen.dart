import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// 추천 곡 모델
class FeaturedSong {
  final String id;
  final String title;
  final String artist;
  final String imageUrl;
  final String tag;
  final String heroText;

  FeaturedSong({
    required this.id,
    required this.title,
    required this.artist,
    required this.imageUrl,
    required this.tag,
    required this.heroText,
  });
}

/// 트렌디한 홈 화면
/// 풀스크린 비주얼 카드 + 큰 타이포그래피
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.92);
  int _currentPage = 0;

  // TODO: 실제 데이터 연동
  final List<FeaturedSong> _featuredSongs = [
    FeaturedSong(
      id: '1',
      title: 'Shape of You',
      artist: 'Ed Sheeran',
      imageUrl: 'https://picsum.photos/800/1200?random=1',
      tag: '#English',
      heroText: 'LEARN\nENGLISH\nWITH MUSIC',
    ),
    FeaturedSong(
      id: '2',
      title: 'Lemon',
      artist: '米津玄師',
      imageUrl: 'https://picsum.photos/800/1200?random=2',
      tag: '#日本語',
      heroText: 'JAPANESE\nLYRICS\nMASTERY',
    ),
    FeaturedSong(
      id: '3',
      title: 'Dynamite',
      artist: 'BTS',
      imageUrl: 'https://picsum.photos/800/1200?random=3',
      tag: '#K-Pop',
      heroText: 'GLOBAL\nHITS,\nLOCAL VIBES',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 메인 콘텐츠
          CustomScrollView(
            slivers: [
              // 상단 헤더 (검색 아이콘)
              SliverAppBar(
                floating: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                toolbarHeight: 56,
                actions: [
                  IconButton(
                    onPressed: () {
                      // TODO: 검색 화면으로 이동
                    },
                    icon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.textPrimary,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),

              // 풀스크린 비주얼 카드 슬라이더
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.65,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemCount: _featuredSongs.length,
                    itemBuilder: (context, index) {
                      return _FeaturedCard(
                        song: _featuredSongs[index],
                        isActive: index == _currentPage,
                        onTap: () => _onSongTap(_featuredSongs[index]),
                      );
                    },
                  ),
                ),
              ),

              // 페이지 인디케이터
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _featuredSongs.length,
                      (index) => _PageIndicator(isActive: index == _currentPage),
                    ),
                  ),
                ),
              ),

              // Quick Access 섹션
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _QuickAccessSection(),
                ),
              ),

              // 하단 여백
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _onSongTap(FeaturedSong song) {
    // TODO: 가사 페이지로 이동
    debugPrint('Selected: ${song.title}');
  }
}

/// 풀스크린 피처드 카드
class _FeaturedCard extends StatelessWidget {
  final FeaturedSong song;
  final bool isActive;
  final VoidCallback? onTap;

  const _FeaturedCard({
    required this.song,
    required this.isActive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        margin: EdgeInsets.symmetric(
          horizontal: 8,
          vertical: isActive ? 0 : 16,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.brandPurple.withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 배경 이미지
              Image.network(
                song.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.brandPurple.withOpacity(0.8),
                        AppColors.brandCyan.withOpacity(0.6),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),

              // 그라디언트 오버레이
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.8),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),

              // 콘텐츠
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(),

                    // 태그 칩
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            song.tag,
                            style: const TextStyle(
                              color: AppColors.accentOnDark,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: AppColors.accentOnDark,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 히어로 텍스트
                    Text(
                      song.heroText,
                      style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.05,
                        letterSpacing: -1.5,
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),

              // 우측 상단 페이지 색상 인디케이터 (레퍼런스 앱의 사이드 라인)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 4,
                  margin: const EdgeInsets.symmetric(vertical: 40),
                  decoration: BoxDecoration(
                    color: isActive 
                        ? AppColors.accent 
                        : AppColors.textTertiary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 페이지 인디케이터 도트
class _PageIndicator extends StatelessWidget {
  final bool isActive;

  const _PageIndicator({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.accent : AppColors.gray700,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

/// 퀵 액세스 섹션
class _QuickAccessSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Continue Learning',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 16),

        // 가로 스크롤 카드
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _QuickAccessCard(
                title: 'Perfect',
                subtitle: 'Ed Sheeran',
                progress: 0.7,
                color: AppColors.brandPink,
              ),
              _QuickAccessCard(
                title: 'Lemon',
                subtitle: '米津玄師',
                progress: 0.3,
                color: AppColors.brandCyan,
              ),
              _QuickAccessCard(
                title: 'Blinding Lights',
                subtitle: 'The Weeknd',
                progress: 0.9,
                color: AppColors.brandPurple,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double progress;
  final Color color;

  const _QuickAccessCard({
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          // 프로그레스 바
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 3,
            ),
          ),
        ],
      ),
    );
  }
}
