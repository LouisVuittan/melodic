import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:melodic_app/core/theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // 로고 및 타이틀
              _buildLogoSection(),

              const Spacer(flex: 1),

              // 소셜 로그인 버튼들
              _buildLoginButtons(),

              const SizedBox(height: 32),

              // 이용약관
              _buildTermsText(),

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        // 로고 아이콘
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary500.withOpacity(0.3),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            LucideIcons.music2,
            color: Colors.white,
            size: 40,
          ),
        ),

        const SizedBox(height: 24),

        // 앱 이름
        ShaderMask(
          shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
          child: const Text(
            'Melodic',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
        ),

        const SizedBox(height: 12),

        // 서브타이틀
        Text(
          '음악으로 시작하는 새로운 언어 학습',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginButtons() {
    return Column(
      children: [
        // 카카오 로그인
        _buildSocialButton(
          onTap: () => _handleSocialLogin('kakao'),
          backgroundColor: const Color(0xFFFEE500),
          textColor: const Color(0xFF391B1B),
          icon: 'K',
          label: '카카오로 시작하기',
        ),

        const SizedBox(height: 12),

        // 네이버 로그인
        _buildSocialButton(
          onTap: () => _handleSocialLogin('naver'),
          backgroundColor: const Color(0xFF03C75A),
          textColor: Colors.white,
          icon: 'N',
          label: '네이버로 시작하기',
        ),

        const SizedBox(height: 12),

        // Google 로그인
        _buildSocialButton(
          onTap: () => _handleSocialLogin('google'),
          backgroundColor: Colors.white,
          textColor: Colors.black87,
          iconWidget: Image.network(
            'https://www.google.com/favicon.ico',
            width: 20,
            height: 20,
            errorBuilder: (context, error, stackTrace) => const Icon(
              LucideIcons.globe,
              size: 20,
              color: Colors.black54,
            ),
          ),
          label: 'Google로 시작하기',
        ),

        const SizedBox(height: 12),

        // Apple 로그인
        _buildSocialButton(
          onTap: () => _handleSocialLogin('apple'),
          backgroundColor: Colors.white,
          textColor: Colors.black87,
          iconWidget: const Icon(
            LucideIcons.apple,
            size: 20,
            color: Colors.black,
          ),
          label: 'Apple로 시작하기',
        ),

        const SizedBox(height: 24),

        // 구분선
        Row(
          children: [
            Expanded(
              child: Divider(
                color: AppColors.borderLight,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '또는',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: AppColors.borderLight,
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // 이메일 로그인
        _buildSocialButton(
          onTap: () => _handleEmailLogin(),
          backgroundColor: AppColors.surfaceMedium,
          textColor: AppColors.textPrimary,
          iconWidget: const Icon(
            LucideIcons.mail,
            size: 20,
            color: AppColors.textSecondary,
          ),
          label: '이메일로 시작하기',
          outlined: true,
        ),

        const SizedBox(height: 16),

        // 둘러보기
        TextButton(
          onPressed: () {
            context.go('/');
          },
          child: Text(
            '먼저 둘러볼게요',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textTertiary,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required VoidCallback onTap,
    required Color backgroundColor,
    required Color textColor,
    String? icon,
    Widget? iconWidget,
    required String label,
    bool outlined = false,
  }) {
    return GestureDetector(
      onTap: _isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : backgroundColor,
          borderRadius: BorderRadius.circular(14),
          border: outlined
              ? Border.all(color: AppColors.borderLight)
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (iconWidget != null)
              iconWidget
            else if (icon != null)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: textColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    icon,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                  ),
                ),
              ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: outlined ? AppColors.textPrimary : textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsText() {
    return Text.rich(
      TextSpan(
        style: TextStyle(
          fontSize: 12,
          color: AppColors.textTertiary,
          height: 1.5,
        ),
        children: [
          const TextSpan(text: '계속 진행하면 '),
          TextSpan(
            text: '이용약관',
            style: TextStyle(
              color: AppColors.primary400,
              decoration: TextDecoration.underline,
            ),
          ),
          const TextSpan(text: ' 및 '),
          TextSpan(
            text: '개인정보처리방침',
            style: TextStyle(
              color: AppColors.primary400,
              decoration: TextDecoration.underline,
            ),
          ),
          const TextSpan(text: '에 동의하는 것으로 간주됩니다.'),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  Future<void> _handleSocialLogin(String provider) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: 실제 소셜 로그인 구현
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        context.go('/');
      }
    } catch (e) {
      // 에러 처리
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('로그인 실패: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleEmailLogin() {
    // TODO: 이메일 로그인 화면으로 이동
  }
}
