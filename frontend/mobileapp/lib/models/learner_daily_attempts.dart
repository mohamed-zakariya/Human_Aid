class LearnerDailyAttempts {
  final String date;
  final List<UserProgress> users;

  LearnerDailyAttempts({
    required this.date,
    required this.users,
  });

  factory LearnerDailyAttempts.fromJson(Map<String, dynamic> json) {
    return LearnerDailyAttempts(
      date: json["date"] ?? "",  // Ensure a non-null string
      users: (json["users"] as List<dynamic>?)
          ?.map((user) => UserProgress.fromJson(user as Map<String, dynamic>))
          .toList() ?? [],
    );
  }


  Map<String, dynamic> toJson() {
    return {
      "date": date,
      "users": users.map((user) => user.toJson()).toList(),
    };
  }
}

class UserProgress {
  final String userId;
  final String name;
  final String username;
  final List<WordAttempt> correctWords;
  final List<WordAttempt> incorrectWords;

  UserProgress({
    required this.userId,
    required this.name,
    required this.username,
    required this.correctWords,
    required this.incorrectWords,
  });

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      userId: json["user_id"]?.toString() ?? "",
      name: json["name"]?.toString() ?? "Unknown",
      username: json["username"]?.toString() ?? "Unknown",
      correctWords: (json["correct_words"] is List)
          ? (json["correct_words"] as List)
          .map((word) => WordAttempt.fromJson(word as Map<String, dynamic>))
          .toList()
          : [],
      incorrectWords: (json["incorrect_words"] is List)
          ? (json["incorrect_words"] as List)
          .map((word) => WordAttempt.fromJson(word as Map<String, dynamic>))
          .toList()
          : [],
    );
  }



  Map<String, dynamic> toJson() {
    return {
      "user_id": userId,
      "name": name,
      "username": username,
      "correct_words": correctWords.map((word) => word.toJson()).toList(),
      "incorrect_words": incorrectWords.map((word) => word.toJson()).toList(),
    };
  }
}

class WordAttempt {
  final String wordId;
  final String spokenWord;
  final String? correctWord; // Nullable since it's only for incorrect words

  WordAttempt({
    required this.wordId,
    required this.spokenWord,
    this.correctWord, // Optional
  });

  factory WordAttempt.fromJson(Map<String, dynamic> json) {
    return WordAttempt(
      wordId: json["word_id"]?.toString() ?? "", // Ensure it's always a String
      spokenWord: json["spoken_word"]?.toString() ?? "", // Force empty string if null
      correctWord: json["correct_word"]?.toString(), // This remains nullable
    );
  }


  Map<String, dynamic> toJson() {
    return {
      "word_id": wordId,
      "spoken_word": spokenWord,
      if (correctWord != null) "correct_word": correctWord, // Only include if available
    };
  }
}

