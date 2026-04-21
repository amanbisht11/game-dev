class TossModel {
  final String? caller;
  final String? winner; // 'player1' or 'player2'
  final String? choice; // 'bat' or 'bowl'
  final int? resultNumber;

  TossModel({this.caller, this.winner, this.choice, this.resultNumber});

  factory TossModel.fromJson(Map<String, dynamic> json) {
    return TossModel(
      caller: json['caller'] as String?,
      winner: json['winner'] as String?,
      choice: json['choice'] as String?,
      resultNumber: json['resultNumber'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'caller': caller,
      'winner': winner,
      'choice': choice,
      'resultNumber': resultNumber,
    };
  }
}

class BallHistoryModel {
  final int batsmanNum;
  final int bowlerNum;
  final String result; // 'runs' or 'out'
  final int runsOnBall;

  BallHistoryModel({
    required this.batsmanNum,
    required this.bowlerNum,
    required this.result,
    required this.runsOnBall,
  });

  factory BallHistoryModel.fromJson(Map<String, dynamic> json) {
    return BallHistoryModel(
      batsmanNum: json['batsmanNum'] as int? ?? 0,
      bowlerNum: json['bowlerNum'] as int? ?? 0,
      result: json['result'] as String? ?? 'runs',
      runsOnBall: json['runsOnBall'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'batsmanNum': batsmanNum,
      'bowlerNum': bowlerNum,
      'result': result,
      'runsOnBall': runsOnBall,
    };
  }
}

class InningModel {
  final String battingPlayer; // 'player1' or 'player2'
  final String bowlingPlayer;
  final int ballsPlayed;
  final int runsScored;
  final bool isOut;
  final List<BallHistoryModel> ballHistory;

  InningModel({
    required this.battingPlayer,
    required this.bowlingPlayer,
    this.ballsPlayed = 0,
    this.runsScored = 0,
    this.isOut = false,
    this.ballHistory = const [],
  });

  factory InningModel.fromJson(Map<String, dynamic> json) {
    var historyList = json['ballHistory'] as List? ?? [];
    return InningModel(
      battingPlayer: json['battingPlayer'] as String? ?? '',
      bowlingPlayer: json['bowlingPlayer'] as String? ?? '',
      ballsPlayed: json['ballsPlayed'] as int? ?? 0,
      runsScored: json['runsScored'] as int? ?? 0,
      isOut: json['isOut'] as bool? ?? false,
      ballHistory: historyList.map((e) => BallHistoryModel.fromJson(Map<String, dynamic>.from(e))).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'battingPlayer': battingPlayer,
      'bowlingPlayer': bowlingPlayer,
      'ballsPlayed': ballsPlayed,
      'runsScored': runsScored,
      'isOut': isOut,
      'ballHistory': ballHistory.map((e) => e.toJson()).toList(),
    };
  }
}

class CurrentBallStateModel {
  final int? batsmanChoice;
  final int? bowlerChoice;
  final int? timerStart;

  CurrentBallStateModel({this.batsmanChoice, this.bowlerChoice, this.timerStart});

  factory CurrentBallStateModel.fromJson(Map<String, dynamic> json) {
    return CurrentBallStateModel(
      batsmanChoice: json['batsmanChoice'] as int?,
      bowlerChoice: json['bowlerChoice'] as int?,
      timerStart: json['timerStart'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (batsmanChoice != null) 'batsmanChoice': batsmanChoice,
      if (bowlerChoice != null) 'bowlerChoice': bowlerChoice,
      if (timerStart != null) 'timerStart': timerStart,
    };
  }
}
