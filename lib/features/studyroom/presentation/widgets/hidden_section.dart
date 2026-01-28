import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';

/// 숨김 아이템 타입
enum HiddenItemType { word, grammar }

/// 숨김 아이템 모델
class HiddenItem {
  final String id;
  final String content;
  final String meaning;
  final HiddenItemType type;
  final String songTitle;
  final DateTime hiddenAt;

  HiddenItem({
    required this.id,
    required this.content,
    required this.meaning,
    required this.type,
    required this.songTitle,
    required this.hiddenAt,
  });
}

/// 숨김 목록 섹션
class HiddenSection extends StatefulWidget {
  const HiddenSection({super.key});

  @override
  State<HiddenSection> createState() => _HiddenSectionState();
}

class _HiddenSectionState extends State<HiddenSection> {
  // TODO: 실제 데이터 연동
  List<HiddenItem> _hiddenItems = [
    HiddenItem(
      id: '1',
      content: '忘れる',
      meaning: '잊다',
      type: HiddenItemType.word,
      songTitle: 'Lemon',
      hiddenAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    HiddenItem(
      id: '2',
      content: '〜なければならない',
      meaning: '~해야 한다',
      type: HiddenItemType.grammar,
      songTitle: 'Perfect',
      hiddenAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  void _restoreItem(HiddenItem item) {
    setState(() {
      _hiddenItems.removeWhere((i) => i.id == item.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.content}가 복원되었습니다'),
        action: SnackBarAction(
          label: '실행 취소',
          onPressed: () {
            setState(() {
              _hiddenItems.add(item);
            });
          },
        ),
      ),
    );
  }

  void _deleteItem(HiddenItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('완전히 삭제할까요?'),
        content: Text('${item.content}을(를) 완전히 삭제합니다.\n이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _hiddenItems.removeWhere((i) => i.id == item.id);
              });
            },
            child: const Text(
              '삭제',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_hiddenItems.isEmpty) {
      return _EmptyState();
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 안내 카드
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.gray600,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  LucideIcons.eyeOff,
                  color: AppColors.gray300,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      '숨긴 항목',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '이미 알고 있는 단어나 문법을 숨겨두세요',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 숨김 항목 리스트
        ..._hiddenItems.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _HiddenItemCard(
            item: item,
            onRestore: () => _restoreItem(item),
            onDelete: () => _deleteItem(item),
          ),
        )),
      ],
    );
  }
}

class _HiddenItemCard extends StatelessWidget {
  final HiddenItem item;
  final VoidCallback? onRestore;
  final VoidCallback? onDelete;

  const _HiddenItemCard({
    required this.item,
    this.onRestore,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // 타입 태그
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: item.type == HiddenItemType.word
                      ? AppColors.accent500.withOpacity(0.1)
                      : AppColors.primary500.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.type == HiddenItemType.word ? '단어' : '문법',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: item.type == HiddenItemType.word
                        ? AppColors.accent400
                        : AppColors.primary400,
                  ),
                ),
              ),
              const Spacer(),
              // 출처
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

          // 내용
          Text(
            item.content,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.meaning,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),

          // 버튼들
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onRestore,
                  icon: const Icon(LucideIcons.eye, size: 18),
                  label: const Text('복원'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accent400,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(LucideIcons.trash2, size: 18),
                  label: const Text('삭제'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
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
                LucideIcons.checkCircle,
                size: 40,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '숨긴 항목이 없어요',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '이미 아는 단어나 문법을\n숨기면 여기에 표시됩니다',
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
