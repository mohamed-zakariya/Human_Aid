class LearnerProgress {
  final String id;
  final List<ExerciseProgress> progress;

  LearnerProgress({
    required this.id,
    required this.progress,
  });

  factory LearnerProgress.fromJson(Map<String, dynamic> json) {
    return LearnerProgress(
      id: json["id"],
      progress: (json["progress"] as List<dynamic>? ?? []) // Ensure progress is always a list
          .map((e) => ExerciseProgress.fromJson(e))
          .toList(),
    );
  }
}

class ExerciseProgress {
  final String exerciseId;
  final String userId;
  final List<String> correctWords;
  final List<IncorrectWord> incorrectWords;
  final List<ExerciseTimeSpent> exerciseTimeSpent;

  ExerciseProgress({
    required this.exerciseId,
    required this.userId,
    required this.correctWords,
    required this.incorrectWords,
    required this.exerciseTimeSpent,
  });

  factory ExerciseProgress.fromJson(Map<String, dynamic> json) {
    return ExerciseProgress(
      exerciseId: json["exercise_id"],
      userId: json["user_id"],
      correctWords: (json["correct_words"] as List<dynamic>? ?? []).cast<String>(), // Ensure list
      incorrectWords: (json["incorrect_words"] as List<dynamic>? ?? [])
          .map((e) => IncorrectWord.fromJson(e))
          .toList(),
      exerciseTimeSpent: (json["exercise_time_spent"] as List<dynamic>? ?? [])
          .map((e) => ExerciseTimeSpent.fromJson(e))
          .toList(),
    );
  }
}

class IncorrectWord {
  final String incorrectWord;

  IncorrectWord({required this.incorrectWord});

  factory IncorrectWord.fromJson(Map<String, dynamic> json) {
    return IncorrectWord(
      incorrectWord: json["incorrect_word"],
    );
  }
}

class ExerciseTimeSpent {
  final String date;

  ExerciseTimeSpent({required this.date});

  factory ExerciseTimeSpent.fromJson(Map<String, dynamic> json) {
    return ExerciseTimeSpent(
      date: json["date"],
    );
  }
}
