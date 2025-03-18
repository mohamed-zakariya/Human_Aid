class UserDailyAttempts {
  final String id;
  final String userId;
  final String exerciseId;
  final DateTime date;
  final List<Attempt> attempts;

  UserDailyAttempts({
    required this.id,
    required this.userId,
    required this.exerciseId,
    required this.date,
    required this.attempts,
  });

  // Factory constructor to convert JSON to Dart object
  factory UserDailyAttempts.fromJson(Map<String, dynamic> json) {
    return UserDailyAttempts(
      id: json["_id"],
      userId: json["user_id"],
      exerciseId: json["exercise_id"],
      date: DateTime.parse(json["date"]),
      attempts: (json["attempts"] as List<dynamic>)
          .map((attempt) => Attempt.fromJson(attempt))
          .toList(),
    );
  }

  // Convert Dart object to JSON (useful for API requests)
  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "user_id": userId,
      "exercise_id": exerciseId,
      "date": date.toIso8601String(),
      "attempts": attempts.map((attempt) => attempt.toJson()).toList(),
    };
  }
}

// **Sub-model for Attempts**
class Attempt {
  final String wordId;
  final String correctWord;
  final String spokenWord;
  final bool isCorrect;
  final int attemptsNumber;

  Attempt({
    required this.wordId,
    required this.correctWord,
    required this.spokenWord,
    required this.isCorrect,
    required this.attemptsNumber,
  });

  factory Attempt.fromJson(Map<String, dynamic> json) {
    return Attempt(
      wordId: json["word_id"],
      correctWord: json["correct_word"],
      spokenWord: json["spoken_word"],
      isCorrect: json["is_correct"],
      attemptsNumber: json["attempts_number"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "word_id": wordId,
      "correct_word": correctWord,
      "spoken_word": spokenWord,
      "is_correct": isCorrect,
      "attempts_number": attemptsNumber,
    };
  }
}
