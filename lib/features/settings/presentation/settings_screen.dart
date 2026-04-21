import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/data/auth_repository.dart';
import '../../profile/data/profile_repository.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('SETTINGS')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: constraints.maxWidth > 600 ? constraints.maxWidth * 0.15 : 20,
              vertical: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profile header
                profileAsync.when(
                  data: (profile) {
                    if (profile == null) return const SizedBox.shrink();
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => context.push('/profile'),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceDark,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 32,
                                backgroundColor: AppColors.player1Blue.withValues(alpha: 0.3),
                                child: Text(
                                  profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?',
                                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(profile.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                                    const SizedBox(height: 4),
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
                              const Icon(Icons.chevron_right, color: AppColors.textGrey),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (e, s) => const SizedBox.shrink(),
                ),

                const SizedBox(height: 24),

                // Account section
                const _SectionLabel(text: 'ACCOUNT'),
                const SizedBox(height: 8),
                _SettingsTile(
                  icon: Icons.person_outline,
                  title: 'Edit Profile',
                  subtitle: 'Change your name and country',
                  onTap: () => context.push('/settings/edit-profile'),
                ),
                _SettingsTile(
                  icon: Icons.shield_outlined,
                  title: 'Privacy & Policy',
                  subtitle: 'Read our privacy policy',
                  onTap: () => _showInfoDialog(context, 'Privacy & Policy',
                      'Your data is stored securely in Firebase. We do not share your personal information with third parties.\n\nWe collect minimal data: your name, country, and game statistics to provide you with the best gaming experience.\n\nYou can delete your account at any time by contacting support.'),
                ),

                const SizedBox(height: 24),

                // App section
                const _SectionLabel(text: 'APP'),
                const SizedBox(height: 8),
                _SettingsTile(
                  icon: Icons.info_outline,
                  title: 'About Us',
                  subtitle: 'Learn more about NumCricket',
                  onTap: () => _showInfoDialog(context, 'About NumCricket',
                      'NumCricket is a real-time multiplayer number cricket game where players compete against each other using strategy and quick thinking.\n\nPick numbers, score runs, and take wickets in this fast-paced digital version of hand cricket!\n\nBuilt with ❤️ using Flutter & Firebase.'),
                ),
                _SettingsTile(
                  icon: Icons.code,
                  title: 'Version',
                  subtitle: '1.0.0 (Build 1)',
                  onTap: null,
                ),

                const SizedBox(height: 32),

                // Sign out
                ElevatedButton.icon(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: AppColors.surfaceDark,
                        title: const Text('Sign Out'),
                        content: const Text('Are you sure you want to sign out?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Sign Out', style: TextStyle(color: AppColors.player2Red)),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await ref.read(authRepositoryProvider).signOut();
                      if (context.mounted) context.go('/login');
                    }
                  },
                  icon: const Icon(Icons.logout, size: 20),
                  label: const Text('SIGN OUT', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.player2Red.withValues(alpha: 0.2),
                    foregroundColor: AppColors.player2Red,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showInfoDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: Text(title),
        content: Text(content, style: const TextStyle(color: Colors.white70, height: 1.5)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textGrey, letterSpacing: 1.5));
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _SettingsTile({required this.icon, required this.title, required this.subtitle, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        margin: const EdgeInsets.only(bottom: 2),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: AppColors.player1Blue),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  Text(subtitle, style: const TextStyle(color: AppColors.textGrey, fontSize: 11)),
                ],
              ),
            ),
            if (onTap != null) const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textGrey),
          ],
        ),
      ),
    );
  }
}
