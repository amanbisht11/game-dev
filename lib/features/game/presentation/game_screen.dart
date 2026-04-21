import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../lobby/data/room_repository.dart';
import '../../auth/data/auth_repository.dart';
import '../../profile/data/profile_repository.dart';
import 'widgets/toss_widget.dart';
import 'widgets/number_picker_widget.dart';
import 'widgets/scoreboard_widget.dart';
import 'widgets/ball_result_overlay.dart';
import 'widgets/inning_transition_overlay.dart';

class GameScreen extends ConsumerStatefulWidget {
  final String roomCode;
  const GameScreen({super.key, required this.roomCode});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  String? _lastBallResult;
  int? _lastBatsmanNum;
  int? _lastBowlerNum;
  bool _showOverlay = false;
  bool _navigatedToResult = false;

  // Inning transition state
  bool _showInningTransition = false;
  String _transitionTitle = '';
  String _transitionSubtitle = '';
  bool _isBattingTransition = false;

  void _triggerInningTransition(String title, String subtitle, bool isBatting) {
    if (!mounted) return;
    setState(() {
      _transitionTitle = title;
      _transitionSubtitle = subtitle;
      _isBattingTransition = isBatting;
      _showInningTransition = true;
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showInningTransition = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final roomAsync = ref.watch(roomStreamProvider(widget.roomCode));

    ref.listen(roomStreamProvider(widget.roomCode), (previous, next) {
      final room = next.value;
      final prevRoom = previous?.value;
      if (room == null) return;

      // Handle game finish
      if (room.status == 'finished' && !_navigatedToResult) {
        if (mounted) {
          _navigatedToResult = true;
          context.go('/result/${widget.roomCode}');
        }
        return;
      }

      final currentUser = ref.read(authStateProvider).value;
      if (currentUser == null) return;
      final isPlayer1 = currentUser.uid == room.player1?.uid;
      final myRole = isPlayer1 ? 'player1' : 'player2';

      // Detect Inning Transitions
      if (prevRoom != null) {
        // Transition to Inning 1
        if (prevRoom.status == 'toss' && room.status == 'innings1') {
          final inning = room.innings.first;
          final amIBatting = inning.battingPlayer == myRole;
          _triggerInningTransition(
            'Inning 1 Started',
            amIBatting ? 'Your turn to Bat' : 'Your turn to Bowl',
            amIBatting,
          );
        }
        // Transition to Inning 2
        else if (prevRoom.status == 'innings1' && room.status == 'innings2') {
          final inning = room.innings[1];
          final amIBatting = inning.battingPlayer == myRole;
          _triggerInningTransition(
            'Inning 2 Started',
            amIBatting ? 'Your turn to Bat' : 'Your turn to Bowl',
            amIBatting,
          );
        }
      }

      // Ball result overlay logic
      if (prevRoom != null && !_showInningTransition) {
        for (int i = 0; i < room.innings.length && i < prevRoom.innings.length; i++) {
          if (room.innings[i].ballHistory.length > prevRoom.innings[i].ballHistory.length) {
            final lastBall = room.innings[i].ballHistory.last;
            setState(() {
              _lastBallResult = lastBall.result;
              _lastBatsmanNum = lastBall.batsmanNum;
              _lastBowlerNum = lastBall.bowlerNum;
              _showOverlay = true;
            });
            Future.delayed(const Duration(milliseconds: 2500), () {
              if (mounted) setState(() => _showOverlay = false);
            });
            break;
          }
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('ROOM: ${widget.roomCode}'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          roomAsync.when(
            data: (room) {
              if (room == null) return const Center(child: Text('Room lost'));
              
              final currentUser = ref.watch(authStateProvider).value;
              final isPlayer1 = currentUser?.uid == room.player1?.uid;

              if (room.status == 'toss') {
                return TossWidget(roomCode: widget.roomCode, room: room, isPlayer1: isPlayer1);
              } else if (room.status.startsWith('innings')) {
                return Consumer(
                  builder: (context, ref, child) {
                    final profile = ref.watch(userProfileProvider).value;
                    final team = profile?.favoriteTeam;
                    
                    return Stack(
                      children: [
                        if (team != null)
                          Positioned.fill(
                            child: Center(
                              child: Opacity(
                                opacity: 0.05,
                                child: Text(
                                  'GO\n$team!',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 100,
                                    fontWeight: FontWeight.w900,
                                    height: 1.0,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return Column(
                              children: [
                                ScoreboardWidget(room: room, isPlayer1: isPlayer1),
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: constraints.maxWidth > 600 ? constraints.maxWidth * 0.15 : 16,
                                      ),
                                      child: NumberPickerWidget(roomCode: widget.roomCode, room: room, isPlayer1: isPlayer1),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    );
                  },
                );
              }

              return const Center(child: Text('Loading game...'));
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
          // Ball Result Overlay
          if (_showOverlay && _lastBallResult != null && !_showInningTransition)
            Builder(
              builder: (context) {
                final room = roomAsync.value;
                if (room == null) return const SizedBox.shrink();
                final currentUser = ref.watch(authStateProvider).value;
                final isPlayer1 = currentUser?.uid == room.player1?.uid;
                final myRole = isPlayer1 ? 'player1' : 'player2';
                final currentInning = room.innings.isNotEmpty && room.currentInning < room.innings.length
                    ? room.innings[room.currentInning]
                    : null;
                final amIBatting = currentInning?.battingPlayer == myRole;
                return BallResultOverlay(
                  result: _lastBallResult!,
                  batsmanNum: _lastBatsmanNum ?? 0,
                  bowlerNum: _lastBowlerNum ?? 0,
                  amIBatting: amIBatting,
                );
              }
            ),

          // Inning Transition Overlay
          if (_showInningTransition)
            InningTransitionOverlay(
              title: _transitionTitle,
              subtitle: _transitionSubtitle,
              isBatting: _isBattingTransition,
            ),
        ],
      ),
    );
  }
}
