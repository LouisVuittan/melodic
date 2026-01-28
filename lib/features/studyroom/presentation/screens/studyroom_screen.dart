import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/vocabulary_section.dart';
import '../widgets/grammar_section.dart';
import '../widgets/hidden_section.dart';

/// 공부방 화면
/// Next.js studyroom 페이지를 Flutter로 마이그레이션
class StudyRoomScreen extends StatefulWidget {
  const StudyRoomScreen({super.key});

  @override
  State<StudyRoomScreen> createState() => _StudyRoomScreenState();
}

class _StudyRoomScreenState extends State<StudyRoomScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<_TabItem> _tabs = [
    _TabItem(label: '단어장', icon: LucideIcons.bookOpen),
    _TabItem(label: '문법 노트', icon: LucideIcons.fileText),
    _TabItem(label: '숨김 목록', icon: LucideIcons.eyeOff),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: const [
                  Text(
                    '📖',
                    style: TextStyle(fontSize: 24),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '공부방',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // 커스텀 탭 바
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppColors.accent600,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: AppColors.textPrimary,
                  unselectedLabelColor: AppColors.gray400,
                  labelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  tabs: _tabs.map((tab) => Tab(text: tab.label)).toList(),
                ),
              ),
            ),

            // 탭 컨텐츠
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  VocabularySection(),
                  GrammarSection(),
                  HiddenSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabItem {
  final String label;
  final IconData icon;

  _TabItem({required this.label, required this.icon});
}
