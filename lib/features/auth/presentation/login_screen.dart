import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../data/auth_repository.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.backgroundDark, AppColors.surfaceDark],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo or Game Title
            Text(
              'NUM',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: AppColors.player1Blue,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 8,
                  ),
            ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
            Text(
              'CRICKET',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: AppColors.player2Red,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                  ),
            ).animate().fadeIn(delay: 300.ms, duration: 600.ms).slideY(begin: 0.2, end: 0),
            
            const SizedBox(height: 80),
            
            // Login Buttons
            _LoginButton(
              onTap: () async {
                // Anonymous Sign In for now
                try {
                  await ref.read(authRepositoryProvider).signInAnonymously();
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
              icon: Icons.person_outline,
              label: 'PLAY AS GUEST',
              color: AppColors.textGrey,
            ).animate().fadeIn(delay: 600.ms).scale(delay: 600.ms),
            
            const SizedBox(height: 20),
            
            _LoginButton(
              onTap: () async {
                try {
                  final result = await ref.read(authRepositoryProvider).signInWithGoogle();
                  if (result == null && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Google sign-in cancelled')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
              icon: Icons.login,
              label: 'SIGN IN WITH GOOGLE',
              color: AppColors.player1Blue,
              isPrimary: true,
            ).animate().fadeIn(delay: 800.ms).scale(delay: 800.ms),
          ],
        ),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final String label;
  final Color color;
  final bool isPrimary;

  const _LoginButton({
    required this.onTap,
    required this.icon,
    required this.label,
    required this.color,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 280,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          decoration: BoxDecoration(
            border: Border.all(color: color.withValues(alpha: 0.5)),
            borderRadius: BorderRadius.circular(12),
            color: isPrimary ? color.withValues(alpha: 0.1) : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
