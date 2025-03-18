class LearnerProgress {
  final String id;
  final List<ExerciseProgress> progress;

  LearnerProgress({
    required this.id,
    required this.progress,
  });

  factory LearnerProgress.fromJson(Map<String, dynamic> json) {
    return LearnerProgress(
      id: json["id"] ?? "",
      progress: (json["progress"] as List<dynamic>? ?? [])
          .map((e) => ExerciseProgress.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // ✅ Convert object to dictionary
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "progress": progress.map((e) => e.toJson()).toList(),
    };
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
      exerciseId: json["exercise_id"] ?? "",
      userId: json["user_id"] ?? "",
      correctWords: (json["correct_words"] as List<dynamic>? ?? []).cast<String>(),
      incorrectWords: (json["incorrect_words"] as List<dynamic>? ?? [])
          .map((e) => IncorrectWord.fromJson(e as Map<String, dynamic>))
          .toList(),
      exerciseTimeSpent: (json["exercise_time_spent"] as List<dynamic>? ?? [])
          .map((e) => ExerciseTimeSpent.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // ✅ Convert object to dictionary
  Map<String, dynamic> toJson() {
    return {
      "exercise_id": exerciseId,
      "user_id": userId,
      "correct_words": correctWords,
      "incorrect_words": incorrectWords.map((e) => e.toJson()).toList(),
      "exercise_time_spent": exerciseTimeSpent.map((e) => e.toJson()).toList(),
    };
  }
}

class IncorrectWord {
  final String incorrectWord;

  IncorrectWord({required this.incorrectWord});

  factory IncorrectWord.fromJson(Map<String, dynamic> json) {
    return IncorrectWord(
      incorrectWord: json["incorrect_word"] ?? "",
    );
  }

  // ✅ Convert object to dictionary
  Map<String, dynamic> toJson() {
    return {
      "incorrect_word": incorrectWord,
    };
  }
}

class ExerciseTimeSpent {
  final String date;

  ExerciseTimeSpent({required this.date});

  factory ExerciseTimeSpent.fromJson(Map<String, dynamic> json) {
    return ExerciseTimeSpent(
      date: json["date"] ?? "",
    );
  }

  // ✅ Convert object to dictionary
  Map<String, dynamic> toJson() {
    return {
      "date": date,
    };
  }
}
