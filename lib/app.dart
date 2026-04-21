import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/constants/routes.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/onboarding_screen.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';
import 'features/profile/data/profile_repository.dart';
import 'features/profile/presentation/profile_screen.dart';
import 'features/lobby/presentation/lobby_screen.dart';
import 'features/lobby/presentation/waiting_screen.dart';
import 'features/game/presentation/game_screen.dart';
import 'features/game/presentation/result_screen.dart';
import 'features/settings/presentation/settings_screen.dart';
import 'features/settings/presentation/edit_profile_screen.dart';

/// Notifier that tells GoRouter to re-evaluate redirects
/// without recreating the entire router instance.
class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(Ref ref) {
    ref.listen(authStateProvider, (prev, next) => notifyListeners());
    ref.listen(userProfileProvider, (prev, next) => notifyListeners());
  }
}

final _routerNotifierProvider = Provider<_RouterNotifier>((ref) {
  return _RouterNotifier(ref);
});

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(_routerNotifierProvider);

  return GoRouter(
    initialLocation: AppRoutes.login,
    refreshListenable: notifier,
    redirect: (context, state) {
      // Use ref.read (not watch) inside redirect — the refreshListenable
      // handles re-triggering when auth/profile changes.
      final authState = ref.read(authStateProvider);
      final profileState = ref.read(userProfileProvider);

      final user = authState.value;

      if (authState.isLoading) return null;

      final isLoggingIn = state.matchedLocation == AppRoutes.login;

      if (user == null) {
        return isLoggingIn ? null : AppRoutes.login;
      }

      final profile = profileState.value;
      final isOnboarding = state.matchedLocation == AppRoutes.onboarding;

      if (profileState.isLoading) return null;

      if (profile == null) {
        return isOnboarding ? null : AppRoutes.onboarding;
      }

      if (isLoggingIn || isOnboarding) {
        return AppRoutes.dashboard;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/settings/edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.lobby,
        builder: (context, state) => const LobbyScreen(),
        routes: [
          GoRoute(
            path: 'waiting/:roomCode',
            builder: (context, state) {
              final roomCode = state.pathParameters['roomCode'] ?? '';
              return WaitingScreen(roomCode: roomCode);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/game/:roomCode',
        builder: (context, state) {
          final roomCode = state.pathParameters['roomCode'] ?? '';
          return GameScreen(roomCode: roomCode);
        },
      ),
      GoRoute(
        path: '/result/:roomCode',
        builder: (context, state) {
          final roomCode = state.pathParameters['roomCode'] ?? '';
          return ResultScreen(roomCode: roomCode);
        },
      ),
    ],
  );
});

class NumCricketApp extends ConsumerWidget {
  const NumCricketApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'NumCricket',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1A1A2E),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3B7DD8),
          brightness: Brightness.dark,
        ),
      ),
      routerConfig: router,
    );
  }
}
