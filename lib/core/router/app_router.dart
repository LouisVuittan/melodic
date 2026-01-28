import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:melodic_app/features/home/screens/home_screen.dart';
import 'package:melodic_app/features/studyroom/screens/studyroom_screen.dart';
import 'package:melodic_app/features/settings/screens/settings_screen.dart';
import 'package:melodic_app/features/lyrics/screens/lyrics_screen.dart';
import 'package:melodic_app/features/auth/screens/login_screen.dart';
import 'package:melodic_app/shared/widgets/main_shell.dart';

/// 앱 라우터 설정
class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,

    routes: [
      // 메인 셸 (하단 네비게이션 포함)
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          // 홈
          GoRoute(
            path: '/',
            name: 'home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          // 공부방
          GoRoute(
            path: '/studyroom',
            name: 'studyroom',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: StudyroomScreen(),
            ),
          ),
          // 설정
          GoRoute(
            path: '/settings',
            name: 'settings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsScreen(),
            ),
          ),
        ],
      ),

      // 가사 학습 화면 (전체 화면)
      GoRoute(
        path: '/lyrics/:id',
        name: 'lyrics',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          final title = state.uri.queryParameters['title'] ?? '';
          final artist = state.uri.queryParameters['artist'] ?? '';
          final albumCover = state.uri.queryParameters['albumCover'];
          
          return LyricsScreen(
            id: id,
            title: title,
            artist: artist,
            albumCover: albumCover,
          );
        },
      ),

      // 로그인 화면
      GoRoute(
        path: '/login',
        name: 'login',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LoginScreen(),
      ),
    ],

    // 에러 페이지
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              '페이지를 찾을 수 없습니다',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              state.error?.message ?? '알 수 없는 오류',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('홈으로 돌아가기'),
            ),
          ],
        ),
      ),
    ),
  );
}
