class GameAttempt {
  final String gameId;
  final String levelId;
  final String? gameName;
  final String? gameArabicName;
  final String? levelName;
  final String? levelArabicName;
  final List<Attempt> attempts;

  GameAttempt({
    required this.gameId,
    required this.levelId,
    this.gameName,
    this.gameArabicName,
    this.levelName,
    this.levelArabicName,
    required this.attempts,
  });

  factory GameAttempt.fromJson(Map<String, dynamic> json) {
    return GameAttempt(
      gameId: json['game_id'] ?? '',
      levelId: json['level_id'] ?? '',
      gameName: json['game_name'] ?? '',
      gameArabicName: json['game_arabic_name'] ?? '',
      levelName: json['level_name'] ?? '',
      levelArabicName: json['level_arabic_name'] ?? '',
      attempts: (json['attempts'] as List? ?? [])
          .map((e) => Attempt.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'game_id': gameId,
      'level_id': levelId,
      'game_name': gameName,
      'game_arabic_name': gameArabicName,
      'level_name': levelName,
      'level_arabic_name': levelArabicName,
      'attempts': attempts.map((e) => e.toMap()).toList(),
    };
  }

  @override
  String toString() {
    return 'GameAttempt(gameId: $gameId, levelId: $levelId, gameName: $gameName, gameArabicName: $gameArabicName, levelName: $levelName, levelArabicName: $levelArabicName, attempts: $attempts)';
  }
}

class Attempt {
  final int score;
  final String? timestamp;

  Attempt({
    required this.score,
    this.timestamp,
  });

  factory Attempt.fromJson(Map<String, dynamic> json) {
    return Attempt(
      score: json['score'] ?? 0,
      timestamp: json['timestamp'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'score': score,
      'timestamp': timestamp,
    };
  }

  @override
  String toString() {
    return 'Attempt(score: $score, timestamp: $timestamp)';
  }
}