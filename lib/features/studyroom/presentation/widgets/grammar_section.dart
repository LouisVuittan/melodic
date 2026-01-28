import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';

/// 문법 아이템 모델
class GrammarItem {
  final String id;
  final String pattern;
  final String meaning;
  final String level;
  final List<String> tags;
  final String? explanation;
  final String songTitle;

  GrammarItem({
    required this.id,
    required this.pattern,
    required this.meaning,
    this.level = 'N4',
    this.tags = const [],
    this.explanation,
    required this.songTitle,
  });
}

/// 문법 노트 섹션
class GrammarSection extends StatefulWidget {
  const GrammarSection({super.key});

  @override
  State<GrammarSection> createState() => _GrammarSectionState();
}

class _GrammarSectionState extends State<GrammarSection> {
  // TODO: 실제 데이터 연동
  final List<GrammarItem> _grammarItems = [
    GrammarItem(
      id: '1',
      pattern: '〜てしまう',
      meaning: '~해 버리다 (완료/후회)',
      level: 'N4',
      tags: ['조동사', '완료', '후회'],
      explanation: '동작이 완전히 끝났음을 나타내거나, 의도치 않은 결과나 후회를 표현할 때 사용합니다.',
      songTitle: 'Lemon',
    ),
    GrammarItem(
      id: '2',
      pattern: '〜ている',
      meaning: '~하고 있다 (진행/상태)',
      level: 'N5',
      tags: ['조동사', '진행', '상태'],
      explanation: '동작이 진행 중이거나, 결과적 상태가 지속됨을 나타냅니다.',
      songTitle: 'Perfect',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    if (_grammarItems.isEmpty) {
      return _EmptyState();
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 통계 카드
        _StatsCard(itemCount: _grammarItems.length),
        const SizedBox(height: 20),

        // 문법 리스트
        ..._grammarItems.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _GrammarCard(
            item: item,
            onTap: () => _openDetail(item),
          ),
        )),
      ],
    );
  }

  void _openDetail(GrammarItem item) {
    // TODO: 문법 상세 모달
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _GrammarDetailSheet(item: item),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final int itemCount;

  const _StatsCard({required this.itemCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary500.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary500.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary500.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              LucideIcons.fileText,
              color: AppColors.primary400,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '저장된 문법',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$itemCount개 패턴',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
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

class _GrammarCard extends StatelessWidget {
  final GrammarItem item;
  final VoidCallback? onTap;

  const _GrammarCard({
    required this.item,
    this.onTap,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 레벨 + 패턴
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accent500.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.level,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accent400,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  item.songTitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 패턴
            Text(
              item.pattern,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),

            // 의미
            Text(
              item.meaning,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.accent400,
              ),
            ),
            const SizedBox(height: 12),

            // 태그
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: item.tags.map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _GrammarDetailSheet extends StatelessWidget {
  final GrammarItem item;

  const _GrammarDetailSheet({required this.item});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 핸들
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.gray600,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 레벨
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.accent500.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.level,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent400,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 패턴
              Text(
                item.pattern,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),

              // 의미
              Text(
                item.meaning,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.accent400,
                ),
              ),
              const SizedBox(height: 24),

              // 설명
              if (item.explanation != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(
                            LucideIcons.lightbulb,
                            size: 18,
                            color: AppColors.accent400,
                          ),
                          SizedBox(width: 8),
                          Text(
                            '설명',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        item.explanation!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 출처 노래
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(
                      LucideIcons.music,
                      size: 18,
                      color: AppColors.gray400,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '출처: ${item.songTitle}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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
                LucideIcons.fileText,
                size: 40,
                color: AppColors.gray500,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '저장된 문법이 없어요',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '가사에서 문법 패턴을 탭해서\n문법 노트에 추가해보세요!',
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
