import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';

class InningTransitionOverlay extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isBatting;

  const InningTransitionOverlay({
    super.key,
    required this.title,
    required this.subtitle,
    required this.isBatting,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon animation
            Icon(
              isBatting ? Icons.sports_cricket : Icons.sports_baseball,
              size: 100,
              color: isBatting ? AppColors.successGreen : AppColors.player2Red,
            ).animate()
              .scale(duration: 600.ms, curve: Curves.elasticOut)
              .rotate(begin: -0.2, end: 0, duration: 600.ms)
              .shimmer(delay: 800.ms, duration: 1200.ms),

            const SizedBox(height: 24),

            // Inning Title
            Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.accentGold,
                letterSpacing: 4,
              ),
            ).animate()
              .fadeIn(delay: 200.ms, duration: 400.ms)
              .slideY(begin: 0.5, end: 0, curve: Curves.easeOut),

            const SizedBox(height: 8),

            // Role Subtitle
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: (isBatting ? AppColors.successGreen : AppColors.player2Red).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isBatting ? AppColors.successGreen : AppColors.player2Red,
                  width: 2,
                ),
              ),
              child: Text(
                subtitle.toUpperCase(),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: isBatting ? AppColors.successGreen : AppColors.player2Red,
                  letterSpacing: 2,
                ),
              ),
            ).animate()
              .fadeIn(delay: 400.ms, duration: 400.ms)
              .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), curve: Curves.elasticOut)
              .shimmer(delay: 1500.ms, duration: 1000.ms),
          ],
        ),
      ),
    );
  }
}
