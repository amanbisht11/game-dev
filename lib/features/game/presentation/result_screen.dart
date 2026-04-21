import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../lobby/data/room_repository.dart';
import '../../lobby/domain/room_model.dart';
import '../../auth/data/auth_repository.dart';
import '../../profile/data/profile_repository.dart';
import '../data/game_repository.dart';

class ResultScreen extends ConsumerStatefulWidget {
  final String roomCode;
  const ResultScreen({super.key, required this.roomCode});

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  bool _statsUpdated = false;
  bool _waitingForRematch = false;
  String? _rematchRoomCode;
  Timer? _rematchTimer;
  StreamSubscription? _rematchSub;
  StreamSubscription? _rematchRoomSub;

  @override
  void dispose() {
    _rematchTimer?.cancel();
    _rematchSub?.cancel();
    _rematchRoomSub?.cancel();
    super.dispose();
  }

  Future<void> _handlePlayAgain(RoomModel room) async {
    final currentUser = ref.read(authStateProvider).value;
    if (currentUser == null) return;

    setState(() => _waitingForRematch = true);

    final isPlayer1 = currentUser.uid == room.player1?.uid;
    final myPlayer = isPlayer1 ? room.player1 : room.player2;
    if (myPlayer == null) return;

    final host = PlayerModel(uid: myPlayer.uid, name: myPlayer.name, avatarUrl: myPlayer.avatarUrl);
    final repo = ref.read(roomRepositoryProvider);

    // Check if the other player already created a rematch room
    final existingRematchCode = await ref.read(roomRepositoryProvider)
        .watchRematchCode(widget.roomCode)
        .first;

    if (existingRematchCode != null) {
      // Other player already waiting — join their room
      await repo.joinRoom(existingRematchCode, host);
      // Auto-start the game since both players are ready
      await ref.read(gameRepositoryProvider).startGame(existingRematchCode);
      if (mounted) {
        context.go('/game/$existingRematchCode');
      }
      return;
    }

    // I'm the first to tap Play Again — create a rematch room
    final newRoomCode = await repo.createRematchRoom(widget.roomCode, host);
    setState(() => _rematchRoomCode = newRoomCode);

    // Watch for the other player joining
    _rematchRoomSub = repo.watchRoom(newRoomCode).listen((rematchRoom) {
      if (rematchRoom != null && rematchRoom.player2 != null && mounted) {
        _rematchTimer?.cancel();
        // Other player joined! Start the game.
        ref.read(gameRepositoryProvider).startGame(newRoomCode).then((_) {
          if (mounted) context.go('/game/$newRoomCode');
        });
      }
    });

    // 20 second timeout
    _rematchTimer = Timer(const Duration(seconds: 20), () {
      if (mounted && _waitingForRematch) {
        _rematchRoomSub?.cancel();
        // Clean up the room we created
        repo.deleteRoom(newRoomCode);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No opponent found. Returning home.')),
        );
        context.go('/dashboard');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final roomAsync = ref.watch(roomStreamProvider(widget.roomCode));

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

          // Update stats once when game is finished
          if (room.status == 'finished' && !_statsUpdated && currentUser != null) {
            _statsUpdated = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.read(profileRepositoryProvider).updateStats(
                uid: currentUser.uid,
                roomCode: widget.roomCode,
                won: iWon,
                xpGained: iWon ? 50 : (isDraw ? 20 : 10),
              );
            });
          }

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

                        // Rematch waiting state
                        if (_waitingForRematch)
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceDark,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.3)),
                            ),
                            child: Column(
                              children: [
                                const CircularProgressIndicator(color: AppColors.accentGold),
                                const SizedBox(height: 16),
                                const Text(
                                  'WAITING FOR OPPONENT...',
                                  style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, color: AppColors.accentGold),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Auto-return to home in 20 seconds',
                                  style: TextStyle(color: AppColors.textGrey, fontSize: 12),
                                ),
                                const SizedBox(height: 16),
                                TextButton(
                                  onPressed: () {
                                    _rematchTimer?.cancel();
                                    _rematchRoomSub?.cancel();
                                    if (_rematchRoomCode != null) {
                                      ref.read(roomRepositoryProvider).deleteRoom(_rematchRoomCode!);
                                    }
                                    setState(() => _waitingForRematch = false);
                                  },
                                  child: const Text('CANCEL', style: TextStyle(color: AppColors.player2Red)),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(duration: 300.ms)
                        else ...[
                          // Play Again button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => _handlePlayAgain(room),
                              icon: const Icon(Icons.replay),
                              label: const Text('PLAY AGAIN', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accentGold,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ).animate().fadeIn(delay: 1000.ms, duration: 500.ms),

                          const SizedBox(height: 12),

                          // Back to home
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => context.go('/dashboard'),
                              icon: const Icon(Icons.home),
                              label: const Text('BACK TO HOME', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white70,
                                side: const BorderSide(color: Colors.white24),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ).animate().fadeIn(delay: 1100.ms, duration: 500.ms),
                        ],
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

  const _PlayerScoreCard({required this.name, required this.score, required this.color, required this.isWinner});

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
