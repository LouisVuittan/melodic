import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../../core/theme/app_text_styles.dart';

// J-POP 컬러 팔레트
class JPopColors {
  static const neonPink = Color(0xFFFF4F9A);
  static const electricBlue = Color(0xFF5B9CFF);
  static const softPurple = Color(0xFF8A6CFF);
  static const darkNavy = Color(0xFF0E0E2C);
  static const deepPurple = Color(0xFF1A1A3E);

  static const profileGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [neonPink, softPurple, electricBlue],
  );
}

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage>
    with TickerProviderStateMixin {
  late AnimationController _lpRotationController;
  late AnimationController _waveController;
  late AnimationController _pulseController;

  // 터치된 웨이브 바 인덱스
  int? _selectedDayIndex;

  // 더미 데이터
  final int _stageLevel = 12;
  final int _fanPower = 2450;
  final int _maxFanPower = 3000;
  final int _streakDays = 7;

  final List<Map<String, dynamic>> _weeklyData = [
    {'day': '월', 'minutes': 25, 'lines': 12, 'words': 8},
    {'day': '화', 'minutes': 15, 'lines': 8, 'words': 5},
    {'day': '수', 'minutes': 40, 'lines': 20, 'words': 12},
    {'day': '목', 'minutes': 0, 'lines': 0, 'words': 0},
    {'day': '금', 'minutes': 30, 'lines': 15, 'words': 9},
    {'day': '토', 'minutes': 45, 'lines': 22, 'words': 14},
    {'day': '일', 'minutes': 20, 'lines': 10, 'words': 6},
  ];

  final List<Map<String, dynamic>> _recentSongs = [
    {'title': 'アイドル', 'artist': 'YOASOBI', 'progress': 0.85, 'color': JPopColors.neonPink},
    {'title': 'ベテルギウス', 'artist': 'Yuuri', 'progress': 0.6, 'color': JPopColors.electricBlue},
    {'title': '唱', 'artist': 'Ado', 'progress': 0.45, 'color': JPopColors.softPurple},
  ];

  @override
  void initState() {
    super.initState();

    _lpRotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _lpRotationController.dispose();
    _waveController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JPopColors.darkNavy,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 프로필 헤더 (LP판)
            _buildProfileHeader(),

            // Learning Rhythm (터치 인터랙션)
            _buildRhythmChart(),
            const SizedBox(height: 24),

            // Live Tour (스트릭)
            _buildLiveTour(),
            const SizedBox(height: 24),

            // Playlist Progress (디스크)
            _buildPlaylistProgress(),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        bottom: 30,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            JPopColors.softPurple.withOpacity(0.3),
            JPopColors.darkNavy,
          ],
        ),
      ),
      child: Column(
        children: [
          // LP판 프로필
          Stack(
            alignment: Alignment.center,
            children: [
              // 글로우 효과
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: 140 + (_pulseController.value * 10),
                    height: 140 + (_pulseController.value * 10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: JPopColors.neonPink.withOpacity(0.3),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                  );
                },
              ),

              // LP판 (회전)
              AnimatedBuilder(
                animation: _lpRotationController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _lpRotationController.value * 2 * math.pi,
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            JPopColors.deepPurple,
                            Colors.black,
                            JPopColors.deepPurple.withOpacity(0.8),
                            Colors.black87,
                          ],
                          stops: const [0.0, 0.3, 0.6, 1.0],
                        ),
                        border: Border.all(
                          color: JPopColors.softPurple.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // LP 홈 (동심원)
                          ...List.generate(5, (i) => Container(
                            width: 30.0 + (i * 20),
                            height: 30.0 + (i * 20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.05),
                                width: 1,
                              ),
                            ),
                          )),
                          // 중앙 레이블
                          Container(
                            width: 45,
                            height: 45,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: JPopColors.profileGradient,
                            ),
                            child: const Center(
                              child: Text(
                                '밍',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 닉네임 + 일본어
          Text(
            '밍밍이',
            style: AppTextStyles.headlineMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            'ミンミン',
            style: AppTextStyles.bodySmall.copyWith(
              color: JPopColors.neonPink.withOpacity(0.8),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),

          // Stage Lv. + Fan Power
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatChip('🎤', 'Stage Lv.$_stageLevel'),
              const SizedBox(width: 12),
              _buildStatChip('💗', '$_fanPower FP'),
            ],
          ),
          const SizedBox(height: 16),

          // Fan Power 게이지
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Next Stage',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white38,
                      ),
                    ),
                    Text(
                      '$_fanPower / $_maxFanPower',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: JPopColors.neonPink,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _fanPower / _maxFanPower,
                    minHeight: 6,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: const AlwaysStoppedAnimation(JPopColors.neonPink),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String emoji, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(
            text,
            style: AppTextStyles.labelMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRhythmChart() {
    final maxMinutes = _weeklyData
        .map((d) => d['minutes'] as int)
        .reduce((a, b) => a > b ? a : b);
    final today = DateTime.now().weekday - 1;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🎼', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                'Learning Rhythm',
                style: AppTextStyles.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '이번 주 학습 리듬',
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white38,
            ),
          ),
          const SizedBox(height: 20),

          // 웨이브폼 차트 (터치 인터랙션)
          Container(
            height: 130,
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // 웨이브 바들
                AnimatedBuilder(
                  animation: _waveController,
                  builder: (context, _) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(_weeklyData.length, (index) {
                        final data = _weeklyData[index];
                        final minutes = data['minutes'] as int;
                        final isToday = index == today;
                        final isSelected = _selectedDayIndex == index;
                        final normalizedHeight = maxMinutes > 0
                            ? (minutes / maxMinutes)
                            : 0.0;

                        final waveOffset = math.sin(
                            (_waveController.value * 2 * math.pi) + (index * 0.8)
                        ) * 0.05;
                        final animatedHeight = (normalizedHeight + waveOffset).clamp(0.08, 1.0);

                        return Expanded(
                          child: GestureDetector(
                            onTapDown: (_) => setState(() => _selectedDayIndex = index),
                            onTapUp: (_) => Future.delayed(
                              const Duration(seconds: 2),
                                  () {
                                if (mounted) setState(() => _selectedDayIndex = null);
                              },
                            ),
                            onTapCancel: () => setState(() => _selectedDayIndex = null),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    height: 80 * animatedHeight + 8,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: isToday
                                            ? [JPopColors.neonPink, JPopColors.neonPink.withOpacity(0.6)]
                                            : minutes > 0
                                            ? [JPopColors.softPurple.withOpacity(0.8), JPopColors.softPurple.withOpacity(0.4)]
                                            : [Colors.white.withOpacity(0.15), Colors.white.withOpacity(0.05)],
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                      border: isSelected
                                          ? Border.all(color: Colors.white, width: 2)
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    data['day'],
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: isToday ? JPopColors.neonPink : Colors.white38,
                                      fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),

                // 툴팁 (선택된 날)
                if (_selectedDayIndex != null)
                  Positioned(
                    top: -45,
                    left: _getTooltipPosition(_selectedDayIndex!),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: JPopColors.deepPurple,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: JPopColors.softPurple.withOpacity(0.5)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${_weeklyData[_selectedDayIndex!]['minutes']}분 학습',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '가사 ${_weeklyData[_selectedDayIndex!]['lines']}줄 · 단어 ${_weeklyData[_selectedDayIndex!]['words']}개',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: Colors.white54,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // 총 학습 시간
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '총 ${_weeklyData.map((d) => d['minutes'] as int).reduce((a, b) => a + b)}분',
                style: AppTextStyles.labelSmall.copyWith(
                  color: Colors.white38,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  double _getTooltipPosition(int index) {
    final screenWidth = MediaQuery.of(context).size.width - 56; // 패딩 제외
    final barWidth = screenWidth / 7;
    final basePosition = index * barWidth;

    // 툴팁이 화면 밖으로 나가지 않도록 조정
    if (index <= 1) return basePosition;
    if (index >= 5) return basePosition - 60;
    return basePosition - 30;
  }

  Widget _buildLiveTour() {
    String tourStatus;
    String tourEmoji;
    Color tourColor;

    if (_streakDays >= 30) {
      tourStatus = 'Arena Tour 🏟️';
      tourEmoji = '🏟️';
      tourColor = JPopColors.neonPink;
    } else if (_streakDays >= 7) {
      tourStatus = 'Mini Live';
      tourEmoji = '🎤';
      tourColor = JPopColors.electricBlue;
    } else {
      tourStatus = 'Rehearsal';
      tourEmoji = '🎸';
      tourColor = JPopColors.softPurple;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              tourColor.withOpacity(0.2),
              tourColor.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: tourColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            // 투어 포스터 스타일
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: tourColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(tourEmoji, style: const TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tourStatus,
                    style: AppTextStyles.titleSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$_streakDays일 연속 공연 중!',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: tourColor,
                    ),
                  ),
                ],
              ),
            ),

            // 다음 목표
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Next',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Colors.white30,
                    fontSize: 10,
                  ),
                ),
                Text(
                  _streakDays >= 30 ? 'World Tour' : _streakDays >= 7 ? 'Arena Tour' : 'Mini Live',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Colors.white54,
                  ),
                ),
                Text(
                  _streakDays >= 30 ? '90일' : _streakDays >= 7 ? '${30 - _streakDays}일' : '${7 - _streakDays}일',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: tourColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaylistProgress() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('📀', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(
                    'My Playlist',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                '${_recentSongs.length}곡 학습 중',
                style: AppTextStyles.labelSmall.copyWith(
                  color: Colors.white38,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 디스크 카드 (가로 스크롤)
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _recentSongs.length,
              itemBuilder: (context, index) {
                final song = _recentSongs[index];
                return _VinylDiskCard(
                  title: song['title'],
                  artist: song['artist'],
                  progress: song['progress'],
                  color: song['color'],
                  rotationController: _lpRotationController,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// 바이닐 디스크 카드
class _VinylDiskCard extends StatelessWidget {
  final String title;
  final String artist;
  final double progress;
  final Color color;
  final AnimationController rotationController;

  const _VinylDiskCard({
    required this.title,
    required this.artist,
    required this.progress,
    required this.color,
    required this.rotationController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          // 디스크 (회전)
          Stack(
            alignment: Alignment.center,
            children: [
              // 진행률 링
              SizedBox(
                width: 70,
                height: 70,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 4,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
              // CD
              AnimatedBuilder(
                animation: rotationController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: rotationController.value * 2 * math.pi * 0.3,
                    child: Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withOpacity(0.1),
                            color.withOpacity(0.3),
                            JPopColors.darkNavy,
                          ],
                          stops: const [0.0, 0.3, 1.0],
                        ),
                        border: Border.all(
                          color: color.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 제목
          Text(
            title,
            style: AppTextStyles.labelMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            artist,
            style: AppTextStyles.labelSmall.copyWith(
              color: Colors.white38,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 6),

          // 진행률
          Text(
            '${(progress * 100).toInt()}%',
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}