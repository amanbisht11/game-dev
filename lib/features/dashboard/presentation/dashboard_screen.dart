import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/routes.dart';

import '../../profile/data/profile_repository.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) return const Center(child: CircularProgressIndicator());

          final winRate = profile.totalMatches > 0
              ? ((profile.wins / profile.totalMatches) * 100).toStringAsFixed(0)
              : '0';

          return SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: constraints.maxWidth > 600 ? constraints.maxWidth * 0.1 : 20,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Top bar with profile & settings
                      Row(
                        children: [
                          // Logo / Title
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: const TextSpan(
                                    children: [
                                      TextSpan(text: 'NUM', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.player1Blue, letterSpacing: 2)),
                                      TextSpan(text: 'CRICKET', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.player2Red, letterSpacing: 2)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Settings icon
                          IconButton(
                            onPressed: () => context.push('/settings'),
                            icon: const Icon(Icons.settings_outlined, color: AppColors.textGrey),
                            tooltip: 'Settings',
                          ),
                          // Profile icon
                          GestureDetector(
                            onTap: () => context.push('/profile'),
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: AppColors.player1Blue.withValues(alpha: 0.3),
                              child: Text(
                                profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.player1Blue, fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(duration: 300.ms),

                      const SizedBox(height: 28),

                      // Welcome card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.player1Blue.withValues(alpha: 0.2), AppColors.surfaceDark],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.player1Blue.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome back,',
                                    style: TextStyle(color: AppColors.textGrey, fontSize: 14),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    profile.name,
                                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.accentGold.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Level ${profile.level} • ${profile.xp} XP',
                                      style: const TextStyle(color: AppColors.accentGold, fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            CircleAvatar(
                              radius: 32,
                              backgroundColor: AppColors.player1Blue.withValues(alpha: 0.3),
                              child: Text(
                                profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?',
                                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),

                      const SizedBox(height: 24),

                      // Stats row
                      Row(
                        children: [
                          _StatCard(
                            icon: Icons.sports_esports,
                            label: 'PLAYED',
                            value: profile.totalMatches.toString(),
                            color: AppColors.player1Blue,
                          ),
                          const SizedBox(width: 12),
                          _StatCard(
                            icon: Icons.emoji_events,
                            label: 'WINS',
                            value: profile.wins.toString(),
                            color: AppColors.successGreen,
                          ),
                          const SizedBox(width: 12),
                          _StatCard(
                            icon: Icons.close,
                            label: 'LOSSES',
                            value: profile.losses.toString(),
                            color: AppColors.player2Red,
                          ),
                        ],
                      ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),

                      const SizedBox(height: 12),

                      // Win rate
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceDark,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.trending_up, color: AppColors.accentGold, size: 20),
                            const SizedBox(width: 10),
                            const Text('Win Rate', style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
                            const Spacer(),
                            Text(
                              '$winRate%',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.accentGold),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

                      const SizedBox(height: 32),

                      // Play button
                      GestureDetector(
                        onTap: () => context.push(AppRoutes.lobby),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.player1Blue, Color(0xFF1A5DAB)],
                            ),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(color: AppColors.player1Blue.withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 6)),
                            ],
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.play_arrow_rounded, color: Colors.white, size: 32),
                              SizedBox(width: 10),
                              Text(
                                'PLAY GAME',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 2),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: 400.ms, duration: 500.ms).scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),

                      const SizedBox(height: 20),

                      // Quick match (coming soon)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceDark,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.flash_on, color: AppColors.accentGold, size: 24),
                            SizedBox(width: 10),
                            Text(
                              'QUICK MATCH',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textGrey, letterSpacing: 1),
                            ),
                            SizedBox(width: 8),
                            Text('(Coming Soon)', style: TextStyle(fontSize: 11, color: AppColors.textGrey)),
                          ],
                        ),
                      ).animate().fadeIn(delay: 500.ms, duration: 400.ms),

                      const SizedBox(height: 24),
                    ],
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 9, color: AppColors.textGrey, letterSpacing: 1)),
          ],
        ),
      ),
    );
  }
}
