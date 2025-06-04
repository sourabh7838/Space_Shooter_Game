import 'dart:convert';

class LeaderboardEntry {
  final String playerName;
  final int score;
  final DateTime date;

  LeaderboardEntry({
    required this.playerName,
    required this.score,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'playerName': playerName,
    'score': score,
    'date': date.toIso8601String(),
  };

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      playerName: json['playerName'] as String,
      score: json['score'] as int,
      date: DateTime.parse(json['date'] as String),
    );
  }
} 