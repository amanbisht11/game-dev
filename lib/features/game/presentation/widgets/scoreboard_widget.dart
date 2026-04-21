import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../lobby/domain/room_model.dart';
import '../../domain/game_models.dart';

class ScoreboardWidget extends StatelessWidget {
  final RoomModel room;
  final bool isPlayer1;

  const ScoreboardWidget({super.key, required this.room, required this.isPlayer1});

  @override
  Widget build(BuildContext context) {
    final player1Score = room.scores['player1'] ?? 0;
    final player2Score = room.scores['player2'] ?? 0;
    
    final myScore = isPlayer1 ? player1Score : player2Score;
    final opponentScore = isPlayer1 ? player2Score : player1Score;
    
    final myName = isPlayer1 ? room.player1?.name : room.player2?.name;
    final opponentName = isPlayer1 ? room.player2?.name : room.player1?.name;

    final currentInningIndex = room.currentInning;
    final innings = room.innings;
    final currentInning = innings.length > currentInningIndex ? innings[currentInningIndex] : null;

    final myRole = isPlayer1 ? 'player1' : 'player2';
    final amIBatting = currentInning?.battingPlayer == myRole;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'INNING ${currentInningIndex + 1} / 2',
              style: TextStyle(color: AppColors.accentGold, fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 12),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _ScorePill(
                    name: myName ?? 'YOU',
                    score: myScore,
                    color: AppColors.player1Blue,
                    isBatting: amIBatting,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('VS', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textGrey, fontSize: 12)),
                ),
                Expanded(
                  child: _ScorePill(
                    name: opponentName ?? 'OPP',
                    score: opponentScore,
                    color: AppColors.player2Red,
                    isBatting: !amIBatting,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (currentInning != null)
              _BallHistoryRow(history: currentInning.ballHistory, currentBall: room.currentBall),
          ],
        ),
      ),
    );
  }
}

class _ScorePill extends StatelessWidget {
  final String name;
  final int score;
  final Color color;
  final bool isBatting;

  const _ScorePill({required this.name, required this.score, required this.color, required this.isBatting});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: isBatting ? 2 : 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isBatting) const Icon(Icons.sports_cricket, size: 14, color: Colors.white),
          if (isBatting) const SizedBox(width: 6),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name.toUpperCase(), style: const TextStyle(fontSize: 9, color: Colors.white70), overflow: TextOverflow.ellipsis),
                Text(score.toString(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BallHistoryRow extends StatelessWidget {
  final List<BallHistoryModel> history;
  final int currentBall;

  const _BallHistoryRow({required this.history, required this.currentBall});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        final isPlayed = index < history.length;
        final isCurrent = index == history.length;
        
        Color dotColor = AppColors.surfaceDark;
        String dotText = '';
        
        if (isPlayed) {
          final ball = history[index];
          if (ball.result == 'out') {
            dotColor = AppColors.player2Red;
            dotText = 'W';
          } else if (ball.result == 'wide') {
            dotColor = AppColors.accentGold;
            dotText = 'WD';
          } else {
            dotColor = AppColors.successGreen;
            dotText = ball.runsOnBall.toString();
          }
        } else if (isCurrent) {
          dotColor = AppColors.accentGold.withValues(alpha: 0.5);
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: dotColor,
            border: Border.all(color: isCurrent ? AppColors.accentGold : Colors.white24),
          ),
          alignment: Alignment.center,
          child: Text(dotText, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12)),
        );
      }),
    );
  }
}
