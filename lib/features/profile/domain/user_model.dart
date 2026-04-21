import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String country;
  final String avatarUrl;
  final int level;
  final int xp;
  final int totalMatches;
  final int wins;
  final int losses;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.country,
    required this.avatarUrl,
    this.level = 1,
    this.xp = 0,
    this.totalMatches = 0,
    this.wins = 0,
    this.losses = 0,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      name: json['name'] as String,
      country: json['country'] as String,
      avatarUrl: json['avatarUrl'] as String,
      level: json['level'] as int? ?? 1,
      xp: json['xp'] as int? ?? 0,
      totalMatches: json['totalMatches'] as int? ?? 0,
      wins: json['wins'] as int? ?? 0,
      losses: json['losses'] as int? ?? 0,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'country': country,
      'avatarUrl': avatarUrl,
      'level': level,
      'xp': xp,
      'totalMatches': totalMatches,
      'wins': wins,
      'losses': losses,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
