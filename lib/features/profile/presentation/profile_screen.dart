import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/data/auth_repository.dart';
import '../data/profile_repository.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final user = ref.watch(authStateProvider).value;

    return Scaffold(
      appBar: AppBar(title: const Text('PROFILE')),
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) return const Center(child: Text('Profile not found'));

          final winRate = profile.totalMatches > 0
              ? ((profile.wins / profile.totalMatches) * 100).toStringAsFixed(1)
              : '0.0';
          final isGoogle = user != null && !user.isAnonymous;

          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: constraints.maxWidth > 600 ? constraints.maxWidth * 0.15 : 24,
                  vertical: 24,
                ),
                child: Column(
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.player1Blue.withValues(alpha: 0.3),
                      child: Text(
                        profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?',
                        style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
                    const SizedBox(height: 16),
                    Text(
                      profile.name,
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                    ).animate().fadeIn(delay: 100.ms),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.accentGold.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Level ${profile.level}',
                            style: const TextStyle(color: AppColors.accentGold, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (isGoogle)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.successGreen.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.verified, size: 12, color: AppColors.successGreen),
                                SizedBox(width: 4),
                                Text('Google', style: TextStyle(color: AppColors.successGreen, fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.textGrey.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text('Guest', style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                          ),
                      ],
                    ).animate().fadeIn(delay: 200.ms),

                    const SizedBox(height: 32),

                    // Stats grid
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('STATISTICS', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, color: AppColors.textGrey, fontSize: 12)),
                          const SizedBox(height: 16),
                          _StatRow(icon: Icons.sports_esports, label: 'Total Matches', value: profile.totalMatches.toString(), color: AppColors.player1Blue),
                          const Divider(height: 24, color: Colors.white10),
                          _StatRow(icon: Icons.emoji_events, label: 'Wins', value: profile.wins.toString(), color: AppColors.successGreen),
                          const Divider(height: 24, color: Colors.white10),
                          _StatRow(icon: Icons.close, label: 'Losses', value: profile.losses.toString(), color: AppColors.player2Red),
                          const Divider(height: 24, color: Colors.white10),
                          _StatRow(icon: Icons.trending_up, label: 'Win Rate', value: '$winRate%', color: AppColors.accentGold),
                          const Divider(height: 24, color: Colors.white10),
                          _StatRow(icon: Icons.star, label: 'XP', value: profile.xp.toString(), color: AppColors.accentGold),
                          const Divider(height: 24, color: Colors.white10),
                          _StatRow(icon: Icons.flag, label: 'Country', value: profile.country, color: AppColors.textGrey),
                        ],
                      ),
                    ).animate().fadeIn(delay: 300.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),

                    const SizedBox(height: 16),

                    // Member since
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16, color: AppColors.textGrey),
                          const SizedBox(width: 10),
                          const Text('Member since', style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
                          const Spacer(),
                          Text(
                            '${profile.createdAt.day}/${profile.createdAt.month}/${profile.createdAt.year}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 400.ms),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatRow({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 14, color: Colors.white70))),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}
