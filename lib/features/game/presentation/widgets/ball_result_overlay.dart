import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';

class BallResultOverlay extends StatelessWidget {
  final String result;

  const BallResultOverlay({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    String emoji;
    String text;
    Color color;

    switch (result) {
      case 'out':
        emoji = '💥';
        text = 'OUT!';
        color = AppColors.player2Red;
        break;
      case 'wide':
        emoji = '⚠️';
        text = 'WIDE!';
        color = AppColors.accentGold;
        break;
      default:
        emoji = '🏏';
        text = 'RUNS!';
        color = AppColors.successGreen;
    }

    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          color: Colors.black54,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 72))
                    .animate()
                    .scale(begin: const Offset(0.3, 0.3), end: const Offset(1.0, 1.0), duration: 300.ms, curve: Curves.elasticOut),
                const SizedBox(height: 16),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: color,
                    letterSpacing: 6,
                    shadows: [
                      Shadow(color: color.withValues(alpha: 0.5), blurRadius: 20),
                    ],
                  ),
                ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.3, end: 0, duration: 300.ms),
              ],
            ),
          ),
        ).animate().fadeIn(duration: 200.ms).then().fadeOut(delay: 1000.ms, duration: 300.ms),
      ),
    );
  }
}
