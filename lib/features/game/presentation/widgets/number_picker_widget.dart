import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../lobby/domain/room_model.dart';
import '../../data/game_repository.dart';

class NumberPickerWidget extends ConsumerStatefulWidget {
  final String roomCode;
  final RoomModel room;
  final bool isPlayer1;

  const NumberPickerWidget({super.key, required this.roomCode, required this.room, required this.isPlayer1});

  @override
  ConsumerState<NumberPickerWidget> createState() => _NumberPickerWidgetState();
}

class _NumberPickerWidgetState extends ConsumerState<NumberPickerWidget> with SingleTickerProviderStateMixin {
  static const _timerDuration = 10; // seconds

  int? _selectedNumber;
  bool _submitted = false;
  late AnimationController _timerController;
  int? _lastTimerStart;

  @override
  void initState() {
    super.initState();
    _timerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: _timerDuration),
    );
    
    _timerController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_submitted) {
        _autoSelectNumber();
      }
    });

    // Start timer if ball state exists
    final timer = widget.room.currentBallState?.timerStart;
    if (timer != null) {
      _lastTimerStart = timer;
      _timerController.forward(from: 0);
    }
  }

  @override
  void didUpdateWidget(NumberPickerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    final newTimer = widget.room.currentBallState?.timerStart;
    
    // New ball started — reset everything
    if (newTimer != null && newTimer != _lastTimerStart) {
      _lastTimerStart = newTimer;
      setState(() {
        _selectedNumber = null;
        _submitted = false;
      });
      _timerController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _timerController.dispose();
    super.dispose();
  }

  int get _currentBallCounter {
    // Read the ballCounter from the room data (stored in RTDB)
    // We need to get it from a field — since RoomModel might not have it,
    // we fallback to computing it from inning state.
    // The game_repository sets this as 'ballCounter' in the room.
    // For now, use currentInning * 6 + currentBall as an approximation
    // that matches the actual ballCounter.
    return _getBallCounterFromRoom();
  }

  int _getBallCounterFromRoom() {
    // Count total balls played across all innings + current ball position
    int total = 0;
    for (int i = 0; i < widget.room.currentInning && i < widget.room.innings.length; i++) {
      total += widget.room.innings[i].ballsPlayed;
    }
    total += widget.room.currentBall;
    return total;
  }

  void _autoSelectNumber() {
    // Timeout = wide ball, submit 0 as the "wide" signal
    if (_submitted) return;
    setState(() {
      _selectedNumber = 0; // 0 means wide
      _submitted = true;
    });

    final myRole = widget.isPlayer1 ? 'player1' : 'player2';
    final currentInning = widget.room.innings.isNotEmpty && widget.room.currentInning < widget.room.innings.length 
        ? widget.room.innings[widget.room.currentInning] 
        : null;
    final amIBatting = currentInning?.battingPlayer == myRole;
    final role = amIBatting ? 'batsman' : 'bowler';
    
    ref.read(gameRepositoryProvider).submitBallChoice(widget.roomCode, role, 0, _currentBallCounter);
  }

  void _selectNumber(int number) {
    if (_submitted) return;
    
    setState(() {
      _selectedNumber = number;
      _submitted = true;
    });
    _timerController.stop();

    final myRole = widget.isPlayer1 ? 'player1' : 'player2';
    final currentInning = widget.room.innings.isNotEmpty && widget.room.currentInning < widget.room.innings.length 
        ? widget.room.innings[widget.room.currentInning] 
        : null;
        
    final amIBatting = currentInning?.battingPlayer == myRole;
    final role = amIBatting ? 'batsman' : 'bowler';
    
    ref.read(gameRepositoryProvider).submitBallChoice(widget.roomCode, role, number, _currentBallCounter);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final gridSize = (screenWidth > 600 ? 400.0 : screenWidth - 48).clamp(200.0, 400.0);

    final myRole = widget.isPlayer1 ? 'player1' : 'player2';
    final currentInning = widget.room.innings.isNotEmpty && widget.room.currentInning < widget.room.innings.length
        ? widget.room.innings[widget.room.currentInning]
        : null;
    final amIBatting = currentInning?.battingPlayer == myRole;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Role indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: amIBatting ? AppColors.successGreen.withValues(alpha: 0.2) : AppColors.player2Red.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              amIBatting ? '🏏 YOU ARE BATTING' : '⚾ YOU ARE BOWLING',
              style: TextStyle(
                color: amIBatting ? AppColors.successGreen : AppColors.player2Red,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 20),

          if (_submitted)
            Column(
              children: [
                const Text('WAITING FOR OPPONENT...', style: TextStyle(color: AppColors.textGrey, letterSpacing: 2, fontSize: 13)),
                const SizedBox(height: 12),
                if (_selectedNumber == 0)
                  Text('⚠️ WIDE! (Timed out)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.accentGold))
                else
                  Text('You picked: $_selectedNumber', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            )
          else
            AnimatedBuilder(
              animation: _timerController,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 52,
                      height: 52,
                      child: CircularProgressIndicator(
                        value: 1 - _timerController.value,
                        backgroundColor: AppColors.surfaceDark,
                        color: _timerController.value > 0.6 ? AppColors.player2Red : AppColors.successGreen,
                        strokeWidth: 5,
                      ),
                    ),
                    Text(
                      (_timerDuration - (_timerController.value * _timerDuration)).ceil().toString(),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                );
              },
            ),
          
          const SizedBox(height: 20),
          
          if (!_submitted) 
            const Text('PICK A NUMBER', style: TextStyle(color: AppColors.textGrey, letterSpacing: 1, fontSize: 12)),
          const SizedBox(height: 12),
          
          SizedBox(
            width: gridSize,
            child: GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              physics: const NeverScrollableScrollPhysics(),
              children: List.generate(6, (index) {
                final number = index + 1;
                final isSelected = _selectedNumber == number;
                
                return GestureDetector(
                  onTap: _submitted ? null : () => _selectNumber(number),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.player1Blue : AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.white10,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected ? [
                        BoxShadow(color: AppColors.player1Blue.withValues(alpha: 0.5), blurRadius: 10, spreadRadius: 2)
                      ] : null,
                    ),
                    child: Center(
                      child: Text(
                        number.toString(),
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : (_submitted ? Colors.white24 : Colors.white70),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
