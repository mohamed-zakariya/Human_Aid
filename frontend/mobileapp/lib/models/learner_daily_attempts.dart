class LearnerDailyAttempts {
  final String date;
  final List<UserProgress> users;

  LearnerDailyAttempts({
    required this.date,
    required this.users,
  });

  factory LearnerDailyAttempts.fromJson(Map<String, dynamic> json) {
    return LearnerDailyAttempts(
      date: json["date"],
      users: (json["users"] as List<dynamic>)
          .map((user) => UserProgress.fromJson(user))
          .toList(),
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
      userId: json["user_id"],
      name: json["name"],
      username: json["username"],
      correctWords: (json["correct_words"] as List<dynamic>)
          .map((word) => WordAttempt.fromJson(word))
          .toList(),
      incorrectWords: (json["incorrect_words"] as List<dynamic>)
          .map((word) => WordAttempt.fromJson(word))
          .toList(),
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

  WordAttempt({
    required this.wordId,
    required this.spokenWord,
  });

  factory WordAttempt.fromJson(Map<String, dynamic> json) {
    return WordAttempt(
      wordId: json["word_id"],
      spokenWord: json["spoken_word"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "word_id": wordId,
      "spoken_word": spokenWord,
    };
  }
}
