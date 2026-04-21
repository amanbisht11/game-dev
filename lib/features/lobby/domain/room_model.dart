import '../../game/domain/game_models.dart';

class PlayerModel {
  final String uid;
  final String name;
  final String avatarUrl;
  final bool ready;

  PlayerModel({
    required this.uid,
    required this.name,
    required this.avatarUrl,
    this.ready = false,
  });

  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    return PlayerModel(
      uid: json['uid'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String,
      ready: json['ready'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'avatarUrl': avatarUrl,
      'ready': ready,
    };
  }
}

class RoomModel {
  final String roomCode;
  final String status; // waiting, toss, innings1, ..., finished
  final DateTime createdAt;
  final bool isPrivate;
  final PlayerModel? player1;
  final PlayerModel? player2;
  final String? winner;
  
  // Game state fields
  final TossModel? toss;
  final List<InningModel> innings;
  final int currentInning;
  final int currentBall;
  final CurrentBallStateModel? currentBallState;
  final Map<String, int> scores;

  RoomModel({
    required this.roomCode,
    required this.status,
    required this.createdAt,
    required this.isPrivate,
    this.player1,
    this.player2,
    this.winner,
    this.toss,
    this.innings = const [],
    this.currentInning = 0,
    this.currentBall = 0,
    this.currentBallState,
    this.scores = const {'player1': 0, 'player2': 0},
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    var inningsList = json['innings'] as List? ?? [];
    
    return RoomModel(
      roomCode: json['roomCode'] as String,
      status: json['status'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      isPrivate: json['isPrivate'] as bool? ?? true,
      player1: json['players']?['player1'] != null 
          ? PlayerModel.fromJson(Map<String, dynamic>.from(json['players']['player1'])) 
          : null,
      player2: json['players']?['player2'] != null 
          ? PlayerModel.fromJson(Map<String, dynamic>.from(json['players']['player2'])) 
          : null,
      winner: json['winner'] as String?,
      toss: json['toss'] != null ? TossModel.fromJson(Map<String, dynamic>.from(json['toss'])) : null,
      innings: inningsList.map((e) => InningModel.fromJson(Map<String, dynamic>.from(e))).toList(),
      currentInning: json['currentInning'] as int? ?? 0,
      currentBall: json['currentBall'] as int? ?? 0,
      currentBallState: json['currentBallState'] != null 
          ? CurrentBallStateModel.fromJson(Map<String, dynamic>.from(json['currentBallState'])) 
          : null,
      scores: json['scores'] != null 
          ? Map<String, int>.from(json['scores']) 
          : {'player1': 0, 'player2': 0},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roomCode': roomCode,
      'status': status,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isPrivate': isPrivate,
      'players': {
        if (player1 != null) 'player1': player1!.toJson(),
        if (player2 != null) 'player2': player2!.toJson(),
      },
      'winner': winner,
      if (toss != null) 'toss': toss!.toJson(),
      'innings': innings.map((e) => e.toJson()).toList(),
      'currentInning': currentInning,
      'currentBall': currentBall,
      if (currentBallState != null) 'currentBallState': currentBallState!.toJson(),
      'scores': scores,
    };
  }
}
