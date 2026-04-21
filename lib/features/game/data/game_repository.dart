import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../lobby/data/room_repository.dart';
import '../domain/game_models.dart';

part 'game_repository.g.dart';

class GameRepository {
  final FirebaseDatabase _db;
  GameRepository(this._db);

  /// Start the game by transitioning to the toss phase
  Future<void> startGame(String roomCode) async {
    final rnd = Random.secure();
    final caller = rnd.nextBool() ? 'player1' : 'player2';

    await _db.ref('rooms/$roomCode').update({
      'status': 'toss',
      'toss': {
        'caller': caller,
        'winner': null,
        'choice': null,
        'resultNumber': null,
      },
    });
  }

  /// Caller picks odd or even, game resolves who won
  Future<void> submitTossCall(String roomCode, String caller, String call) async {
    final rnd = Random.secure();
    final resultNumber = rnd.nextInt(6) + 1;
    final isResultEven = resultNumber % 2 == 0;
    final isCallEven = call == 'even';
    final winner = isResultEven == isCallEven ? caller : (caller == 'player1' ? 'player2' : 'player1');

    await _db.ref('rooms/$roomCode/toss').update({
      'winner': winner,
      'resultNumber': resultNumber,
    });
  }

  /// Toss winner picks bat or bowl, then setup innings1
  Future<void> submitTossChoice(String roomCode, String choice) async {
    final snapshot = await _db.ref('rooms/$roomCode').get();
    if (!snapshot.exists) return;
    final data = Map<String, dynamic>.from(snapshot.value as Map);
    final tossWinner = data['toss']?['winner'] as String?;
    if (tossWinner == null) return;

    String battingPlayer;
    String bowlingPlayer;

    if (choice == 'bat') {
      battingPlayer = tossWinner;
      bowlingPlayer = tossWinner == 'player1' ? 'player2' : 'player1';
    } else {
      bowlingPlayer = tossWinner;
      battingPlayer = tossWinner == 'player1' ? 'player2' : 'player1';
    }

    await _db.ref('rooms/$roomCode').update({
      'status': 'innings1',
      'toss/choice': choice,
      'currentInning': 0,
      'currentBall': 0,
      'scores': {'player1': 0, 'player2': 0},
      'innings': [
        InningModel(
          battingPlayer: battingPlayer,
          bowlingPlayer: bowlingPlayer,
        ).toJson(),
      ],
      'currentBallState': {
        'batsmanChoice': null,
        'bowlerChoice': null,
        'timerStart': ServerValue.timestamp,
      },
    });
  }

  /// Submit a number choice for current ball — uses transaction to prevent race conditions
  Future<void> submitBallChoice(String roomCode, String playerRole, int choice) async {
    final field = playerRole == 'batsman' ? 'batsmanChoice' : 'bowlerChoice';
    
    debugPrint('[GameRepo] submitBallChoice: $playerRole picked $choice');

    // Use a transaction on the entire room to atomically check and resolve
    final roomRef = _db.ref('rooms/$roomCode');
    
    await roomRef.runTransaction((Object? currentData) {
      if (currentData == null) return Transaction.abort();
      
      final data = Map<String, dynamic>.from(currentData as Map);
      final ballState = data['currentBallState'];
      if (ballState == null) return Transaction.abort();
      
      final ballStateMap = Map<String, dynamic>.from(ballState as Map);
      
      // Set our choice
      ballStateMap[field] = choice;
      data['currentBallState'] = ballStateMap;
      
      final batsmanChoice = ballStateMap['batsmanChoice'];
      final bowlerChoice = ballStateMap['bowlerChoice'];
      
      // If both choices are in, resolve the ball right here in the transaction
      if (batsmanChoice != null && bowlerChoice != null) {
        debugPrint('[GameRepo] Both picked! Batsman: $batsmanChoice, Bowler: $bowlerChoice');
        _resolveBallInTransaction(data, batsmanChoice as int, bowlerChoice as int);
      }
      
      return Transaction.success(data);
    });
  }

  /// Core game logic: resolve a ball — runs INSIDE a transaction (no race condition)
  void _resolveBallInTransaction(Map<String, dynamic> data, int batsmanNum, int bowlerNum) {
    final currentInningIdx = data['currentInning'] as int? ?? 0;
    final rawInnings = data['innings'];
    if (rawInnings == null) return;
    
    final inningsList = (rawInnings as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
    if (inningsList.isEmpty || currentInningIdx >= inningsList.length) return;

    final inningData = Map<String, dynamic>.from(inningsList[currentInningIdx]);
    final battingPlayer = inningData['battingPlayer'] as String;
    final bowlingPlayer = inningData['bowlingPlayer'] as String;
    final ballsPlayed = (inningData['ballsPlayed'] as int? ?? 0);
    var inningRuns = inningData['runsScored'] as int? ?? 0;
    
    final rawHistory = inningData['ballHistory'] as List? ?? [];
    final history = rawHistory.map((e) => Map<String, dynamic>.from(e as Map)).toList();

    // Check for wide ball (0 = timed out)
    final isWide = batsmanNum == 0 || bowlerNum == 0;
    final isOut = !isWide && batsmanNum == bowlerNum;
    final runsOnBall = (isWide || isOut) ? 0 : batsmanNum;

    String result;
    if (isWide) {
      result = 'wide';
    } else if (isOut) {
      result = 'out';
    } else {
      result = 'runs';
    }

    debugPrint('[GameRepo] Ball result: $result (batsman: $batsmanNum, bowler: $bowlerNum)');

    // Add ball to history
    history.add({
      'batsmanNum': batsmanNum,
      'bowlerNum': bowlerNum,
      'result': result,
      'runsOnBall': runsOnBall,
    });

    inningRuns += runsOnBall;
    final newBallsPlayed = ballsPlayed + 1;

    // Update the inning data
    inningData['ballsPlayed'] = newBallsPlayed;
    inningData['runsScored'] = inningRuns;
    inningData['isOut'] = isOut;
    inningData['ballHistory'] = history;
    inningsList[currentInningIdx] = inningData;

    // Recalculate TOTAL scores from ALL innings for each player
    final scores = <String, int>{'player1': 0, 'player2': 0};
    for (final inn in inningsList) {
      final bp = inn['battingPlayer'] as String;
      final runs = inn['runsScored'] as int? ?? 0;
      scores[bp] = (scores[bp] ?? 0) + runs;
    }

    // Check if inning is over (out or 6 balls)
    final inningOver = isOut || newBallsPlayed >= 6;

    if (inningOver) {
      final nextInningIdx = currentInningIdx + 1;

      if (nextInningIdx >= 5) {
        // Game over
        final p1Score = scores['player1'] ?? 0;
        final p2Score = scores['player2'] ?? 0;
        String? winner;
        if (p1Score > p2Score) {
          winner = 'player1';
        } else if (p2Score > p1Score) {
          winner = 'player2';
        }

        debugPrint('[GameRepo] GAME OVER! P1: $p1Score, P2: $p2Score, Winner: $winner');

        data['status'] = 'finished';
        data['innings'] = inningsList;
        data['scores'] = scores;
        data['winner'] = winner;
        data['currentBallState'] = null;
      } else {
        // Start next inning — swap batting/bowling
        debugPrint('[GameRepo] Inning $nextInningIdx starting. $bowlingPlayer now bats.');

        inningsList.add(InningModel(
          battingPlayer: bowlingPlayer,
          bowlingPlayer: battingPlayer,
        ).toJson());

        data['status'] = 'innings${nextInningIdx + 1}';
        data['currentInning'] = nextInningIdx;
        data['currentBall'] = 0;
        data['innings'] = inningsList;
        data['scores'] = scores;
        data['currentBallState'] = {
          'batsmanChoice': null,
          'bowlerChoice': null,
          'timerStart': DateTime.now().millisecondsSinceEpoch,
        };
      }
    } else {
      // Continue same inning, next ball
      data['currentBall'] = newBallsPlayed;
      data['innings'] = inningsList;
      data['scores'] = scores;
      data['currentBallState'] = {
        'batsmanChoice': null,
        'bowlerChoice': null,
        'timerStart': DateTime.now().millisecondsSinceEpoch,
      };
    }
  }
}

@riverpod
GameRepository gameRepository(GameRepositoryRef ref) {
  return GameRepository(ref.watch(firebaseDatabaseProvider));
}
