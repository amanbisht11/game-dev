import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../data/room_repository.dart';
import '../../game/data/game_repository.dart';
import '../../auth/data/auth_repository.dart';

class WaitingScreen extends ConsumerStatefulWidget {
  final String roomCode;
  const WaitingScreen({super.key, required this.roomCode});

  @override
  ConsumerState<WaitingScreen> createState() => _WaitingScreenState();
}

class _WaitingScreenState extends ConsumerState<WaitingScreen> {
  bool _isHost = false;
  bool _gameStarted = false;

  @override
  Widget build(BuildContext context) {
    final roomAsync = ref.watch(roomStreamProvider(widget.roomCode));

    ref.listen(roomStreamProvider(widget.roomCode), (previous, next) {
      final room = next.value;
      if (room != null && room.status != 'waiting') {
        _gameStarted = true;
        if (mounted) {
          context.go('/game/${widget.roomCode}');
        }
      }
      // If room was deleted by host while guest is waiting
      if (room == null && previous?.value != null && !_gameStarted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Room was closed by the host.')),
          );
          context.pop();
        }
      }
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (!_gameStarted) {
          await _cleanupRoom();
        }
        if (context.mounted) context.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('WAITING ROOM'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (!_gameStarted) {
                await _cleanupRoom();
              }
              if (context.mounted) context.pop();
            },
          ),
        ),
        body: roomAsync.when(
          data: (room) {
            if (room == null) {
              return const Center(child: Text('Room not found'));
            }

            final player1 = room.player1;
            final player2 = room.player2;
            final currentUser = ref.watch(authStateProvider).value;
            _isHost = currentUser?.uid == player1?.uid;

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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Top section
                        Column(
                          children: [
                            const Text('SHARE THIS CODE', style: TextStyle(color: AppColors.textGrey, letterSpacing: 1)),
                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: widget.roomCode));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Code copied to clipboard!')),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 28),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceDark,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.accentGold),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      widget.roomCode,
                                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 4),
                                    ),
                                    const SizedBox(width: 12),
                                    const Icon(Icons.copy, size: 20, color: AppColors.accentGold),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        // Players section
                        Row(
                          children: [
                            _PlayerSlot(player: player1, label: 'HOST'),
                            const SizedBox(width: 16),
                            const Text('VS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: AppColors.accentGold)),
                            const SizedBox(width: 16),
                            _PlayerSlot(player: player2, label: 'GUEST'),
                          ],
                        ),
                        const SizedBox(height: 32),
                        // Bottom section
                        if (player2 == null)
                          const Column(
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text('Waiting for opponent...', style: TextStyle(fontStyle: FontStyle.italic, color: AppColors.textGrey)),
                            ],
                          )
                        else if (_isHost)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                try {
                                  await ref.read(gameRepositoryProvider).startGame(widget.roomCode);
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.successGreen,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: const Text('START MATCH', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          )
                        else
                          const Text('Waiting for host to start...', style: TextStyle(fontStyle: FontStyle.italic, color: AppColors.textGrey)),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }

  Future<void> _cleanupRoom() async {
    try {
      final repo = ref.read(roomRepositoryProvider);
      if (_isHost) {
        debugPrint('[WaitingScreen] Host leaving — deleting room ${widget.roomCode}');
        await repo.deleteRoom(widget.roomCode);
      } else {
        debugPrint('[WaitingScreen] Guest leaving — removing from room ${widget.roomCode}');
        await repo.leaveRoom(widget.roomCode);
      }
    } catch (e) {
      debugPrint('[WaitingScreen] Cleanup error: $e');
    }
  }
}

class _PlayerSlot extends StatelessWidget {
  final dynamic player;
  final String label;

  const _PlayerSlot({required this.player, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: AppColors.surfaceDark,
            child: player == null
                ? const Icon(Icons.person_add, size: 32, color: AppColors.textGrey)
                : Text(
                    (player!.name as String).isNotEmpty ? (player!.name as String)[0].toUpperCase() : '?',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
          ),
          const SizedBox(height: 10),
          Text(
            player?.name ?? 'WAITING...',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: player != null ? Colors.white : AppColors.textGrey,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textGrey)),
        ],
      ),
    );
  }
}
