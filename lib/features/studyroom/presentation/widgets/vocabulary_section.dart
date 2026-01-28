import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';

/// 단어 모델
class VocabularyWord {
  final String id;
  final String word;
  final String meaning;
  final String? pronunciation;
  final String? example;
  final String songTitle;
  final String level; // N5, N4, N3... or Beginner, Intermediate...

  VocabularyWord({
    required this.id,
    required this.word,
    required this.meaning,
    this.pronunciation,
    this.example,
    required this.songTitle,
    this.level = 'N5',
  });
}

/// 단어 컬렉션 모델
class VocabularyCollection {
  final String id;
  final String name;
  final int wordCount;
  final DateTime? lastStudied;
  final List<VocabularyWord> words;

  VocabularyCollection({
    required this.id,
    required this.name,
    this.wordCount = 0,
    this.lastStudied,
    this.words = const [],
  });
}

/// 단어장 섹션
class VocabularySection extends StatefulWidget {
  const VocabularySection({super.key});

  @override
  State<VocabularySection> createState() => _VocabularySectionState();
}

class _VocabularySectionState extends State<VocabularySection> {
  // TODO: 실제 데이터 연동
  final List<VocabularyCollection> _collections = [
    VocabularyCollection(
      id: '1',
      name: '기본 단어',
      wordCount: 15,
      lastStudied: DateTime.now().subtract(const Duration(hours: 3)),
      words: [
        VocabularyWord(
          id: '1',
          word: '愛',
          meaning: '사랑',
          pronunciation: 'あい (ai)',
          example: '愛してる',
          songTitle: 'Lemon',
          level: 'N4',
        ),
        VocabularyWord(
          id: '2',
          word: '夢',
          meaning: '꿈',
          pronunciation: 'ゆめ (yume)',
          example: '夢を見る',
          songTitle: 'Lemon',
          level: 'N5',
        ),
      ],
    ),
    VocabularyCollection(
      id: '2',
      name: 'Ed Sheeran 노래',
      wordCount: 8,
      lastStudied: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    if (_collections.isEmpty) {
      return _EmptyState();
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 통계 카드
        _StatsCard(collections: _collections),
        const SizedBox(height: 20),

        // 컬렉션 리스트
        ..._collections.map((collection) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _CollectionCard(
            collection: collection,
            onTap: () => _openCollection(collection),
            onStudy: () => _startStudy(collection),
          ),
        )),

        // 새 컬렉션 추가 버튼
        _AddCollectionButton(
          onTap: () {
            // TODO: 새 컬렉션 추가
          },
        ),
      ],
    );
  }

  void _openCollection(VocabularyCollection collection) {
    // TODO: 컬렉션 상세 페이지
    debugPrint('Open collection: ${collection.name}');
  }

  void _startStudy(VocabularyCollection collection) {
    // TODO: 학습 모드 시작
    debugPrint('Start study: ${collection.name}');
  }
}

class _StatsCard extends StatelessWidget {
  final List<VocabularyCollection> collections;

  const _StatsCard({required this.collections});

  @override
  Widget build(BuildContext context) {
    final totalWords = collections.fold<int>(
      0, (sum, c) => sum + c.wordCount,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.accentGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '총 저장된 단어',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$totalWords개',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: const [
                Icon(LucideIcons.graduationCap, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text(
                  '학습하기',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CollectionCard extends StatelessWidget {
  final VocabularyCollection collection;
  final VoidCallback? onTap;
  final VoidCallback? onStudy;

  const _CollectionCard({
    required this.collection,
    this.onTap,
    this.onStudy,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // 아이콘
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.accent500.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                LucideIcons.bookMarked,
                color: AppColors.accent400,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),

            // 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    collection.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${collection.wordCount}개 단어',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // 학습 버튼
            IconButton(
              onPressed: onStudy,
              icon: const Icon(
                LucideIcons.play,
                color: AppColors.accent500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddCollectionButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _AddCollectionButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.border,
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              LucideIcons.plus,
              color: AppColors.accent400,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              '새 컬렉션 추가',
              style: TextStyle(
                color: AppColors.accent400,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                LucideIcons.bookOpen,
                size: 40,
                color: AppColors.gray500,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '저장된 단어가 없어요',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '가사에서 모르는 단어를 탭해서\n단어장에 추가해보세요!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
