class GameAttempt {
  final String gameId;
  final String levelId;
  final List<Attempt> attempts;

  GameAttempt({
    required this.gameId,
    required this.levelId,
    required this.attempts,
  });

  factory GameAttempt.fromJson(Map<String, dynamic> json) {
    return GameAttempt(
      gameId: json['game_id'],
      levelId: json['level_id'],
      attempts: (json['attempts'] as List)
          .map((e) => Attempt.fromJson(e))
          .toList(),
    );
  }

  // Method to convert GameAttempt object to a map
  Map<String, dynamic> toMap() {
    return {
      'game_id': gameId,
      'level_id': levelId,
      'attempts': attempts.map((e) => e.toMap()).toList(),
    };
  }

  // Override the toString method for better representation
  @override
  String toString() {
    return 'GameAttempt(gameId: $gameId, levelId: $levelId, attempts: $attempts)';
  }
}

class Attempt {
  final int score;

  Attempt({required this.score});

  factory Attempt.fromJson(Map<String, dynamic> json) {
    return Attempt(score: json['score']);
  }

  // Method to convert Attempt object to a map
  Map<String, dynamic> toMap() {
    return {
      'score': score,
    };
  }

  // Override the toString method for better representation
  @override
  String toString() {
    return 'Attempt(score: $score)';
  }
}
