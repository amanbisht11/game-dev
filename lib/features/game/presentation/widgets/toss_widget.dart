import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../lobby/domain/room_model.dart';
import '../../data/game_repository.dart';

class TossWidget extends ConsumerWidget {
  final String roomCode;
  final RoomModel room;
  final bool isPlayer1;

  const TossWidget({super.key, required this.roomCode, required this.room, required this.isPlayer1});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final caller = room.toss?.caller;
    final winner = room.toss?.winner;
    final choice = room.toss?.choice;
    final resultNumber = room.toss?.resultNumber;
    
    final myRole = isPlayer1 ? 'player1' : 'player2';
    final amICaller = caller == myRole;
    final amIWinner = winner == myRole;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: constraints.maxWidth > 600 ? constraints.maxWidth * 0.15 : 24,
            vertical: 24,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('THE TOSS', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 4), textAlign: TextAlign.center),
                const SizedBox(height: 40),
                
                if (winner == null) ...[
                  if (amICaller) ...[
                    const Text('You are the caller!', style: TextStyle(fontSize: 18), textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => ref.read(gameRepositoryProvider).submitTossCall(roomCode, myRole, 'odd'),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.player1Blue, padding: const EdgeInsets.symmetric(vertical: 18)),
                            child: const Text('ODD', style: TextStyle(fontSize: 20, color: Colors.white)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => ref.read(gameRepositoryProvider).submitTossCall(roomCode, myRole, 'even'),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.player2Red, padding: const EdgeInsets.symmetric(vertical: 18)),
                            child: const Text('EVEN', style: TextStyle(fontSize: 20, color: Colors.white)),
                          ),
                        ),
                      ],
                    )
                  ] else ...[
                    Text('Opponent is calling the toss...', style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic, color: AppColors.textGrey), textAlign: TextAlign.center),
                    const SizedBox(height: 20),
                    const Center(child: CircularProgressIndicator()),
                  ],
                ] else if (choice == null) ...[
                  Text('Number rolled: $resultNumber', style: TextStyle(fontSize: 22, color: AppColors.accentGold), textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  if (amIWinner) ...[
                    const Text('You won the toss! What will you do?', style: TextStyle(fontSize: 18), textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => ref.read(gameRepositoryProvider).submitTossChoice(roomCode, 'bat'),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.successGreen, padding: const EdgeInsets.symmetric(vertical: 18)),
                            child: const Text('BAT', style: TextStyle(fontSize: 20, color: Colors.white)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => ref.read(gameRepositoryProvider).submitTossChoice(roomCode, 'bowl'),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.player2Red, padding: const EdgeInsets.symmetric(vertical: 18)),
                            child: const Text('BOWL', style: TextStyle(fontSize: 20, color: Colors.white)),
                          ),
                        ),
                      ],
                    )
                  ] else ...[
                    Text('Opponent won the toss and is choosing...', style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic, color: AppColors.textGrey), textAlign: TextAlign.center),
                    const SizedBox(height: 20),
                    const Center(child: CircularProgressIndicator()),
                  ]
                ] else ...[
                  const Text('Starting match...', style: TextStyle(fontSize: 18), textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  const Center(child: CircularProgressIndicator()),
                ]
              ],
            ),
          ),
        );
      },
    );
  }
}
