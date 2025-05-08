import 'GameAttempt.dart';
import 'learner_daily_attempts.dart';
class User {
  final String userId;
  final String username;
  final String name;
  final List<Letter> correctLetters;
  final List<Letter> incorrectLetters;
  final List<Word> correctWords;
  final List<Word> incorrectWords;
  final List<Sentence> correctSentences;
  final List<Sentence> incorrectSentences;
  final List<GameAttempt> gameAttempts;

  User({
    required this.userId,
    required this.username,
    required this.name,
    required this.correctLetters,
    required this.incorrectLetters,
    required this.correctWords,
    required this.incorrectWords,
    required this.correctSentences,
    required this.incorrectSentences,
    required this.gameAttempts,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'],
      username: json['username'],
      name: json['name'],
      correctLetters: (json['correct_letters'] as List)
          .map((e) => Letter.fromJson(e))
          .toList(),
      incorrectLetters: (json['incorrect_letters'] as List)
          .map((e) => Letter.fromJson(e))
          .toList(),
      correctWords: (json['correct_words'] as List)
          .map((e) => Word.fromJson(e))
          .toList(),
      incorrectWords: (json['incorrect_words'] as List)
          .map((e) => Word.fromJson(e))
          .toList(),
      correctSentences: (json['correct_sentences'] as List)
          .map((e) => Sentence.fromJson(e))
          .toList(),
      incorrectSentences: (json['incorrect_sentences'] as List)
          .map((e) => Sentence.fromJson(e))
          .toList(),
      gameAttempts: (json['game_attempts'] as List)
          .map((e) => GameAttempt.fromJson(e))
          .toList(),
    );
  }

  // You can now use toMap for each of the lists
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'username': username,
      'name': name,
      'correct_letters': correctLetters.map((e) => e.toMap()).toList(),
      'incorrect_letters': incorrectLetters.map((e) => e.toMap()).toList(),
      'correct_words': correctWords.map((e) => e.toMap()).toList(),
      'incorrect_words': incorrectWords.map((e) => e.toMap()).toList(),
      'correct_sentences': correctSentences.map((e) => e.toMap()).toList(),
      'incorrect_sentences': incorrectSentences.map((e) => e.toMap()).toList(),
      'game_attempts': gameAttempts.map((e) => e.toMap()).toList(),
    };
  }


  // Override the toString method for better representation
  @override
  String toString() {
    return 'User(userId: $userId, username: $username, name: $name, '
        'correctLetters: $correctLetters, incorrectLetters: $incorrectLetters, '
        'correctWords: $correctWords, incorrectWords: $incorrectWords, '
        'correctSentences: $correctSentences, incorrectSentences: $incorrectSentences, '
        'gameAttempts: $gameAttempts)';
  }
}
