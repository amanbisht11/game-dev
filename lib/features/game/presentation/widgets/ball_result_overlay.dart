import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import 'hand_image_widget.dart';

class BallResultOverlay extends StatelessWidget {
  final String result;
  final int batsmanNum;
  final int bowlerNum;
  final bool amIBatting;

  const BallResultOverlay({
    super.key,
    required this.result,
    required this.batsmanNum,
    required this.bowlerNum,
    required this.amIBatting,
  });

  @override
  Widget build(BuildContext context) {
    String text;
    Color color;

    switch (result) {
      case 'out':
        text = 'OUT!';
        color = AppColors.player2Red;
        break;
      case 'wide':
        text = 'WIDE!';
        color = AppColors.accentGold;
        break;
      default:
        text = '+$result RUNS!';
        color = AppColors.successGreen;
    }

    final myNum = amIBatting ? batsmanNum : bowlerNum;
    final oppNum = amIBatting ? bowlerNum : batsmanNum;

    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          color: Colors.black54,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Hands clash
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        const Text('YOU', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
                        const SizedBox(height: 8),
                        HandImageWidget(number: myNum, size: 120),
                      ],
                    ).animate().slideX(begin: -1, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),
                    
                    const SizedBox(width: 40),
                    
                    Column(
                      children: [
                        const Text('OPPONENT', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
                        const SizedBox(height: 8),
                        HandImageWidget(number: oppNum, size: 120, mirror: true),
                      ],
                    ).animate().slideX(begin: 1, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),
                  ],
                ),
                
                const SizedBox(height: 40),
                
                // Result text
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
                ).animate()
                 .fadeIn(delay: 200.ms, duration: 300.ms)
                 .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1), curve: Curves.elasticOut, duration: 600.ms),
              ],
            ),
          ),
        ).animate().fadeIn(duration: 200.ms).then().fadeOut(delay: 2000.ms, duration: 300.ms),
      ),
    );
  }
}
