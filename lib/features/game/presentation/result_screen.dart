import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../lobby/data/room_repository.dart';

import '../../auth/data/auth_repository.dart';

class ResultScreen extends ConsumerWidget {
  final String roomCode;
  const ResultScreen({super.key, required this.roomCode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomAsync = ref.watch(roomStreamProvider(roomCode));

    return Scaffold(
      body: roomAsync.when(
        data: (room) {
          if (room == null) return const Center(child: Text('Room data not available'));

          final currentUser = ref.watch(authStateProvider).value;
          final isPlayer1 = currentUser?.uid == room.player1?.uid;
          final myRole = isPlayer1 ? 'player1' : 'player2';

          final p1Score = room.scores['player1'] ?? 0;
          final p2Score = room.scores['player2'] ?? 0;
          final myScore = isPlayer1 ? p1Score : p2Score;
          final oppScore = isPlayer1 ? p2Score : p1Score;
          final myName = isPlayer1 ? room.player1?.name : room.player2?.name;
          final oppName = isPlayer1 ? room.player2?.name : room.player1?.name;

          final iWon = room.winner == myRole;
          final isDraw = room.winner == null;

          return Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: iWon
                    ? [const Color(0xFF1B5E20), AppColors.backgroundDark]
                    : isDraw
                        ? [const Color(0xFF4A4A2E), AppColors.backgroundDark]
                        : [const Color(0xFF4A1A1A), AppColors.backgroundDark],
              ),
            ),
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: constraints.maxWidth > 600 ? constraints.maxWidth * 0.15 : 24,
                      vertical: 32,
                    ),
                    child: Column(
                      children: [
                        // Result header
                        Text(
                          isDraw ? '🤝' : (iWon ? '🏆' : '😞'),
                          style: const TextStyle(fontSize: 64),
                        ).animate().scale(delay: 200.ms, duration: 500.ms, curve: Curves.elasticOut),
                        const SizedBox(height: 16),
                        Text(
                          isDraw ? 'MATCH DRAWN!' : (iWon ? 'YOU WON!' : 'YOU LOST!'),
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 4,
                            color: isDraw ? AppColors.accentGold : (iWon ? AppColors.successGreen : AppColors.player2Red),
                          ),
                        ).animate().fadeIn(delay: 400.ms, duration: 500.ms).slideY(begin: 0.3, end: 0),

                        const SizedBox(height: 40),

                        // Score comparison
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceDark,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _PlayerScoreCard(
                                  name: myName ?? 'YOU',
                                  score: myScore,
                                  color: AppColors.player1Blue,
                                  isWinner: iWon,
                                  label: 'YOU',
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                child: const Text('VS', style: TextStyle(color: AppColors.textGrey, fontWeight: FontWeight.bold)),
                              ),
                              Expanded(
                                child: _PlayerScoreCard(
                                  name: oppName ?? 'OPP',
                                  score: oppScore,
                                  color: AppColors.player2Red,
                                  isWinner: !iWon && !isDraw,
                                  label: 'OPP',
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 600.ms, duration: 500.ms).slideY(begin: 0.2, end: 0),

                        const SizedBox(height: 24),

                        // Inning breakdown
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceDark,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text('INNINGS BREAKDOWN', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 12, color: AppColors.textGrey), textAlign: TextAlign.center),
                              const SizedBox(height: 16),
                              ...room.innings.asMap().entries.map((entry) {
                                final idx = entry.key;
                                final inning = entry.value;
                                final wasBatting = inning.battingPlayer == myRole;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 60,
                                        child: Text('INN ${idx + 1}', style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
                                      ),
                                      Icon(
                                        wasBatting ? Icons.sports_cricket : Icons.sports_baseball,
                                        size: 14,
                                        color: wasBatting ? AppColors.successGreen : AppColors.player2Red,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        wasBatting ? 'Batted' : 'Bowled',
                                        style: TextStyle(fontSize: 12, color: wasBatting ? AppColors.successGreen : AppColors.player2Red),
                                      ),
                                      const Spacer(),
                                      Text(
                                        '${inning.runsScored} runs (${inning.ballsPlayed} balls)',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                      if (inning.isOut)
                                        const Text(' • OUT', style: TextStyle(color: AppColors.player2Red, fontSize: 11, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ).animate().fadeIn(delay: 800.ms, duration: 500.ms),

                        const SizedBox(height: 40),

                        // Actions
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => context.go('/dashboard'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.player1Blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('BACK TO HOME', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                          ),
                        ).animate().fadeIn(delay: 1000.ms, duration: 500.ms),

                        const SizedBox(height: 12),

                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => context.go('/lobby'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.accentGold,
                              side: const BorderSide(color: AppColors.accentGold),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('PLAY AGAIN', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                          ),
                        ).animate().fadeIn(delay: 1100.ms, duration: 500.ms),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _PlayerScoreCard extends StatelessWidget {
  final String name;
  final int score;
  final Color color;
  final bool isWinner;
  final String label;

  const _PlayerScoreCard({required this.name, required this.score, required this.color, required this.isWinner, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: color.withValues(alpha: 0.3),
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
          ),
        ),
        const SizedBox(height: 8),
        Text(name.toUpperCase(), style: const TextStyle(fontSize: 11, color: Colors.white70), overflow: TextOverflow.ellipsis),
        const SizedBox(height: 4),
        Text(
          score.toString(),
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: isWinner ? color : Colors.white,
          ),
        ),
        if (isWinner)
          Text('WINNER', style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold, letterSpacing: 1)),
      ],
    );
  }
}
