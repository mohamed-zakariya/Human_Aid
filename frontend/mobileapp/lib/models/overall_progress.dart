import 'dart:convert';

class OverallProgress {
  final String id;
  final List<UserExerciseProgress> progress;

  OverallProgress({
    required this.id,
    required this.progress,
  });

  factory OverallProgress.fromJson(Map<String, dynamic> json) {
    return OverallProgress(
      id: json["id"]?.toString() ?? "",
      progress: (json["progress"] as List<dynamic>?)
          ?.whereType<Map<String, dynamic>>()
          .map((exercise) => UserExerciseProgress.fromJson(exercise))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "progress": progress.map((e) => e.toJson()).toList(),
    };
  }
}

class UserExerciseProgress {
  final String userId;
  final List<WordAttempt> correctWords;
  final List<WordAttempt> incorrectWords;
  final double accuracyPercentage;

  UserExerciseProgress({
    required this.userId,
    required this.correctWords,
    required this.incorrectWords,
    required this.accuracyPercentage,
  });

  factory UserExerciseProgress.fromJson(Map<String, dynamic> json) {
    return UserExerciseProgress(
      userId: json["user_id"]?.toString() ?? "",
      accuracyPercentage: (json["average_accuracy"] as num?)?.toDouble() ?? 0.0,

      // Extract words from "total_correct_words.words"
      correctWords: (json["total_correct_words"]?["words"] as List<dynamic>?)
          ?.map((word) => WordAttempt(wordId: "", spokenWord: word.toString()))
          .toList() ??
          [],

      // Extract words from "total_incorrect_words.words"
      incorrectWords: (json["total_incorrect_words"]?["words"] as List<dynamic>?)
          ?.map((word) => WordAttempt(wordId: "", spokenWord: word.toString()))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "user_id": userId,
      "correct_words": correctWords.map((word) => word.toJson()).toList(),
      "incorrect_words": incorrectWords.map((word) => word.toJson()).toList(),
      "accuracy_percentage": accuracyPercentage,
    };
  }
}

class WordAttempt {
  final String wordId;
  final String spokenWord;

  WordAttempt({
    required this.wordId,
    required this.spokenWord,
  });

  factory WordAttempt.fromJson(Map<String, dynamic> json) {
    return WordAttempt(
      wordId: json["word_id"]?.toString() ?? "",
      spokenWord: json["incorrect_word"]?.toString() ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "word_id": wordId,
      "spoken_word": spokenWord,
    };
  }
}
