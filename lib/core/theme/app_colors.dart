import 'package:flutter/material.dart';

/// Melodic 앱 색상 팔레트 - 일본어 학습 특화
class AppColors {
  AppColors._();

  // ============================================
  // Background (다크 테마)
  // ============================================
  static const Color background = Color(0xFF0A0A0F);      // 더 깊은 다크
  static const Color surface = Color(0xFF12121A);         // 카드 배경
  static const Color surfaceLight = Color(0xFF1A1A25);    // 밝은 서피스
  static const Color surfaceBright = Color(0xFF252532);   // 하이라이트 서피스

  // ============================================
  // Primary (보라/바이올렛 계열)
  // ============================================
  static const Color primary100 = Color(0xFFEDE9FE);
  static const Color primary200 = Color(0xFFDDD6FE);
  static const Color primary300 = Color(0xFFC4B5FD);
  static const Color primary400 = Color(0xFFA78BFA);
  static const Color primary500 = Color(0xFF8B5CF6);      // 메인
  static const Color primary600 = Color(0xFF7C3AED);
  static const Color primary700 = Color(0xFF6D28D9);

  // ============================================
  // Accent (시안/틸 - 일본 네온 느낌)
  // ============================================
  static const Color accent100 = Color(0xFFCFFAFE);
  static const Color accent200 = Color(0xFFA5F3FC);
  static const Color accent300 = Color(0xFF67E8F9);
  static const Color accent400 = Color(0xFF22D3EE);
  static const Color accent500 = Color(0xFF06B6D4);       // 메인
  static const Color accent600 = Color(0xFF0891B2);

  // ============================================
  // Secondary (핑크/마젠타 - 일본 팝 느낌)
  // ============================================
  static const Color secondary300 = Color(0xFFF9A8D4);
  static const Color secondary400 = Color(0xFFF472B6);
  static const Color secondary500 = Color(0xFFEC4899);    // 메인
  static const Color secondary600 = Color(0xFFDB2777);

  // ============================================
  // Text Colors
  // ============================================
  static const Color textPrimary = Color(0xFFFAFAFA);     // 거의 흰색
  static const Color textSecondary = Color(0xFFA1A1AA);   // 중간 회색
  static const Color textTertiary = Color(0xFF71717A);    // 어두운 회색
  static const Color textMuted = Color(0xFF52525B);       // 뮤트

  // ============================================
  // Border & Divider
  // ============================================
  static const Color border = Color(0xFF27272A);
  static const Color borderLight = Color(0xFF3F3F46);
  
  // ============================================
  // Semantic
  // ============================================
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFFBBF24);
  static const Color error = Color(0xFFEF4444);

  // ============================================
  // Glass Effect Colors
  // ============================================
  static Color glassBackground = Colors.white.withOpacity(0.05);
  static Color glassBorder = Colors.white.withOpacity(0.1);
  static Color glassHighlight = Colors.white.withOpacity(0.15);

  // ============================================
  // Gradients
  // ============================================
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary500, accent500],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.transparent,
      Color(0x40000000),
      Color(0xCC0A0A0F),
      Color(0xFF0A0A0F),
    ],
    stops: [0.0, 0.3, 0.7, 1.0],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1A1A25),
      Color(0xFF12121A),
    ],
  );

  static LinearGradient neonGlow(Color color) => LinearGradient(
    colors: [
      color.withOpacity(0.0),
      color.withOpacity(0.3),
      color.withOpacity(0.0),
    ],
  );
}
