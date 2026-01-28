import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:ui';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class StudyPage extends ConsumerStatefulWidget {
  const StudyPage({super.key});

  @override
  ConsumerState<StudyPage> createState() => _StudyPageState();
}

class _StudyPageState extends ConsumerState<StudyPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() => _selectedTab = _tabController.index);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 히어로 통계 섹션
            const _HeroStatsSection(),

            const SizedBox(height: 28),

            // 탭 네비게이션
            _buildTabBar(),

            const SizedBox(height: 24),

            // 탭 컨텐츠
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: TabBarView(
                controller: _tabController,
                children: const [
                  _VocabularyTab(),
                  _GrammarTab(),
                  _HiddenTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    final tabs = [
      {'icon': LucideIcons.bookOpen, 'label': '단어장'},
      {'icon': LucideIcons.fileText, 'label': '문법 노트'},
      {'icon': LucideIcons.eyeOff, 'label': '숨김'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: tabs.asMap().entries.map((entry) {
            final index = entry.key;
            final tab = entry.value;
            final isSelected = _selectedTab == index;

            return Expanded(
              child: GestureDetector(
                onTap: () => _tabController.animateTo(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(colors: [AppColors.accent500, AppColors.accent600])
                        : null,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isSelected
                        ? [BoxShadow(color: AppColors.accent500.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        tab['icon'] as IconData,
                        size: 16,
                        color: isSelected ? Colors.white : AppColors.textTertiary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        tab['label'] as String,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: isSelected ? Colors.white : AppColors.textTertiary,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// 히어로 통계 섹션
class _HeroStatsSection extends StatelessWidget {
  const _HeroStatsSection();

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.fromLTRB(20, topPadding + 20, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accent500.withOpacity(0.15),
            AppColors.primary500.withOpacity(0.08),
            AppColors.background,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('공부방', style: AppTextStyles.headlineLarge),
              // 연속 학습 배지
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF6B6B).withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.flame, color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      '7일 연속',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '오늘도 일본어 실력을 키워볼까요?',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),

          // 통계 카드들
          Row(
            children: [
              Expanded(child: _StatCard(
                icon: LucideIcons.bookOpen,
                value: '124',
                label: '학습 단어',
                color: AppColors.accent500,
              )),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(
                icon: LucideIcons.messageSquare,
                value: '28',
                label: '학습 문법',
                color: AppColors.primary500,
              )),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(
                icon: LucideIcons.music,
                value: '5',
                label: '완료 곡',
                color: AppColors.secondary500,
              )),
            ],
          ),
        ],
      ),
    );
  }
}

/// 통계 카드
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// 단어장 탭
class _VocabularyTab extends StatelessWidget {
  const _VocabularyTab();

  @override
  Widget build(BuildContext context) {
    final songs = [
      {'title': 'アイドル', 'artist': 'YOASOBI', 'words': 48, 'progress': 0.75, 'image': 'https://is1-ssl.mzstatic.com/image/thumb/Music116/v4/7e/bd/c5/7ebdc5e4-8ea1-4a80-b9bf-f917a2085574/cover.jpg/600x600bb.jpg'},
      {'title': '夜に駆ける', 'artist': 'YOASOBI', 'words': 36, 'progress': 0.45, 'image': 'https://is1-ssl.mzstatic.com/image/thumb/Music125/v4/73/ac/e9/73ace9ed-d663-6bc1-3b21-6b40f67e0bca/cover.jpg/600x600bb.jpg'},
      {'title': 'Lemon', 'artist': '米津玄師', 'words': 42, 'progress': 0.90, 'image': 'https://is1-ssl.mzstatic.com/image/thumb/Music118/v4/c4/7c/52/c47c52b6-efed-40d4-3ea8-0ea5f9e3b367/cover.jpg/600x600bb.jpg'},
      {'title': '可愛くてごめん', 'artist': 'HoneyWorks', 'words': 31, 'progress': 0.20, 'image': 'https://is1-ssl.mzstatic.com/image/thumb/Music126/v4/c5/0b/7b/c50b7b39-4015-d9d1-7fd3-5a507a4334f0/cover.jpg/600x600bb.jpg'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
      itemCount: songs.length,
      itemBuilder: (context, index) {
        final song = songs[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _SongStudyCard(
            title: song['title'] as String,
            artist: song['artist'] as String,
            count: song['words'] as int,
            progress: song['progress'] as double,
            imageUrl: song['image'] as String,
            label: '단어',
          ),
        );
      },
    );
  }
}

/// 문법 노트 탭
class _GrammarTab extends StatelessWidget {
  const _GrammarTab();

  @override
  Widget build(BuildContext context) {
    final songs = [
      {'title': 'アイドル', 'artist': 'YOASOBI', 'grammars': 12, 'progress': 0.60, 'image': 'https://is1-ssl.mzstatic.com/image/thumb/Music116/v4/7e/bd/c5/7ebdc5e4-8ea1-4a80-b9bf-f917a2085574/cover.jpg/600x600bb.jpg'},
      {'title': '夜に駆ける', 'artist': 'YOASOBI', 'grammars': 8, 'progress': 0.80, 'image': 'https://is1-ssl.mzstatic.com/image/thumb/Music125/v4/73/ac/e9/73ace9ed-d663-6bc1-3b21-6b40f67e0bca/cover.jpg/600x600bb.jpg'},
      {'title': 'Lemon', 'artist': '米津玄師', 'grammars': 15, 'progress': 0.35, 'image': 'https://is1-ssl.mzstatic.com/image/thumb/Music118/v4/c4/7c/52/c47c52b6-efed-40d4-3ea8-0ea5f9e3b367/cover.jpg/600x600bb.jpg'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
      itemCount: songs.length,
      itemBuilder: (context, index) {
        final song = songs[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _SongStudyCard(
            title: song['title'] as String,
            artist: song['artist'] as String,
            count: song['grammars'] as int,
            progress: song['progress'] as double,
            imageUrl: song['image'] as String,
            label: '문법',
            accentColor: AppColors.primary500,
          ),
        );
      },
    );
  }
}

/// 숨김 탭
class _HiddenTab extends StatefulWidget {
  const _HiddenTab();

  @override
  State<_HiddenTab> createState() => _HiddenTabState();
}

class _HiddenTabState extends State<_HiddenTab> {
  bool _isWordView = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 단어/문법 토글
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isWordView = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _isWordView ? AppColors.surface : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '숨긴 단어',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: _isWordView ? AppColors.textPrimary : AppColors.textTertiary,
                          fontWeight: _isWordView ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isWordView = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: !_isWordView ? AppColors.surface : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '숨긴 문법',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: !_isWordView ? AppColors.textPrimary : AppColors.textTertiary,
                          fontWeight: !_isWordView ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 리스트
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
            children: _isWordView
                ? [
              _HiddenItemCard(word: '開く', reading: 'ひらく', meaning: '열다'),
              const SizedBox(height: 10),
              _HiddenItemCard(word: '届ける', reading: 'とどける', meaning: '전하다, 배달하다'),
              const SizedBox(height: 10),
              _HiddenItemCard(word: '揺れる', reading: 'ゆれる', meaning: '흔들리다'),
            ]
                : [
              _HiddenItemCard(word: 'てしまう', reading: '~해버리다', meaning: '완료/후회의 의미', isGrammar: true),
              const SizedBox(height: 10),
              _HiddenItemCard(word: 'ようにする', reading: '~하도록 하다', meaning: '습관/노력의 의미', isGrammar: true),
            ],
          ),
        ),
      ],
    );
  }
}

/// 노래별 학습 카드 (트렌디 버전)
class _SongStudyCard extends StatelessWidget {
  final String title;
  final String artist;
  final int count;
  final double progress;
  final String imageUrl;
  final String label;
  final Color accentColor;

  const _SongStudyCard({
    required this.title,
    required this.artist,
    required this.count,
    required this.progress,
    required this.imageUrl,
    required this.label,
    this.accentColor = AppColors.accent500,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 배경 이미지
              CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: AppColors.surfaceLight),
                errorWidget: (_, __, ___) => Container(color: AppColors.surfaceLight),
              ),

              // 어두운 오버레이
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black.withOpacity(0.85),
                      Colors.black.withOpacity(0.6),
                      Colors.black.withOpacity(0.3),
                    ],
                  ),
                ),
              ),

              // 컨텐츠
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // 앨범 썸네일
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // 정보
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            title,
                            style: AppTextStyles.titleSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            artist,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 10),
                          // 진행률 바
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(3),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    minHeight: 5,
                                    backgroundColor: Colors.white.withOpacity(0.2),
                                    valueColor: AlwaysStoppedAnimation(accentColor),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '${(progress * 100).toInt()}%',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: accentColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    // 우측: 카운트 + 버튼
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 카운트 배지
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: accentColor.withOpacity(0.3)),
                          ),
                          child: Text(
                            '$count$label',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: accentColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // 학습 버튼
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [accentColor, accentColor.withOpacity(0.8)]),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: accentColor.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(LucideIcons.play, size: 16, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 숨긴 아이템 카드
class _HiddenItemCard extends StatelessWidget {
  final String word;
  final String reading;
  final String meaning;
  final bool isGrammar;

  const _HiddenItemCard({
    required this.word,
    required this.reading,
    required this.meaning,
    this.isGrammar = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 아이콘
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isGrammar
                  ? AppColors.primary500.withOpacity(0.15)
                  : AppColors.accent500.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isGrammar ? LucideIcons.fileText : LucideIcons.bookOpen,
              size: 18,
              color: isGrammar ? AppColors.primary500 : AppColors.accent500,
            ),
          ),
          const SizedBox(width: 14),

          // 단어/문법 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      word,
                      style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      reading,
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  meaning,
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),

          // 복원 버튼
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                LucideIcons.eye,
                size: 18,
                color: AppColors.success,
              ),
            ),
          ),
        ],
      ),
    );
  }
}