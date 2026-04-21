import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../lobby/data/room_repository.dart';
import '../../auth/data/auth_repository.dart';
import 'widgets/toss_widget.dart';
import 'widgets/number_picker_widget.dart';
import 'widgets/scoreboard_widget.dart';
import 'widgets/ball_result_overlay.dart';

class GameScreen extends ConsumerStatefulWidget {
  final String roomCode;
  const GameScreen({super.key, required this.roomCode});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  String? _lastBallResult;
  bool _showOverlay = false;

  @override
  Widget build(BuildContext context) {
    final roomAsync = ref.watch(roomStreamProvider(widget.roomCode));

    ref.listen(roomStreamProvider(widget.roomCode), (previous, next) {
      final room = next.value;
      if (room != null && room.status == 'finished') {
        if (mounted) {
          context.go('/result/${widget.roomCode}');
        }
      }

      // Ball result overlay
      if (room != null && previous?.value != null) {
        final prevRoom = previous!.value!;
        for (int i = 0; i < room.innings.length && i < prevRoom.innings.length; i++) {
          if (room.innings[i].ballHistory.length > prevRoom.innings[i].ballHistory.length) {
            final lastBall = room.innings[i].ballHistory.last;
            setState(() {
              _lastBallResult = lastBall.result;
              _showOverlay = true;
            });
            Future.delayed(const Duration(milliseconds: 1500), () {
              if (mounted) setState(() => _showOverlay = false);
            });
            break;
          }
        }
        // New inning started
        if (room.innings.length > prevRoom.innings.length && prevRoom.innings.isNotEmpty) {
          final lastInning = prevRoom.innings.last;
          if (lastInning.ballHistory.isNotEmpty) {
            final lastBall = lastInning.ballHistory.last;
            setState(() {
              _lastBallResult = lastBall.result;
              _showOverlay = true;
            });
            Future.delayed(const Duration(milliseconds: 1500), () {
              if (mounted) setState(() => _showOverlay = false);
            });
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
                return LayoutBuilder(
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
                );
              }

              return const Center(child: Text('Loading game...'));
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
          if (_showOverlay && _lastBallResult != null)
            BallResultOverlay(result: _lastBallResult!),
        ],
      ),
    );
  }
}
