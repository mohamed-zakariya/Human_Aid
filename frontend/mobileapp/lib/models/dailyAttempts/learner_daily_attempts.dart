import 'UserProgress.dart';

class LearnerDailyAttempts {
  final String date;
  final List<User> users;

  LearnerDailyAttempts({required this.date, required this.users});

  factory LearnerDailyAttempts.fromJson(Map<String, dynamic> json) {
    return LearnerDailyAttempts(
      date: json['date'],
      users: (json['users'] as List)
          .map((userJson) => User.fromJson(userJson))
          .toList(),
    );
  }

  @override
  String toString() {
    return 'LearnerDailyAttempts{date: $date, users: $users}';
  }
}


class Letter {
  final String correctLetter;
  final String? spokenLetter;
  // other properties...

  Letter({required this.correctLetter, required this.spokenLetter});

  // Method to convert Letter object to a map
  Map<String, dynamic> toMap() {
    return {
      'correct_letter': correctLetter,
      'spoken_letter': spokenLetter,
      // add other properties here if needed
    };
  }

  factory Letter.fromJson(Map<String, dynamic> json) {
    return Letter(correctLetter: json['correct_letter'], spokenLetter: json['spoken_letter']);
  }

  @override
  String toString() {
    return 'Letter{correctLetter: $correctLetter, spokenLetter: $spokenLetter}';
  }
}


class Word {
  final String correctWord;
  final String? spokenWord;
  // other properties...

  Word({required this.correctWord, required this.spokenWord});

  // Method to convert Word object to a map
  Map<String, dynamic> toMap() {
    return {
      'correct_word': correctWord,
      'spoken_word': spokenWord,

      // add other properties here if needed
    };
  }

  // If you don't already have a `fromJson` method, you can implement it similarly
  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(correctWord: json['correct_word'], spokenWord: json['spoken_word']);
  }

  @override
  String toString() {
    return 'Word{correctWord: $correctWord, spoken_word: $spokenWord}';
  }


}



class Sentence {
  final String correctSentence;
  final String? spokenSentence;
  final List<Word> incorrectSentences;

  Sentence({
    required this.correctSentence,
    this.spokenSentence,
    required this.incorrectSentences,
  });

  Map<String, dynamic> toMap() {
    return {
      'correct_sentence': correctSentence,
      'spoken_sentence': spokenSentence,
      'incorrect_sentences': incorrectSentences.map((e) => e.toMap()).toList(),
    };
  }

  factory Sentence.fromJson(Map<String, dynamic> json) {
    return Sentence(
      correctSentence: json['correct_sentence'] ?? '',
      spokenSentence: json['spoken_sentence'],
      incorrectSentences: (json['incorrect_sentences'] as List? ?? [])
          .map((e) => Word.fromJson(e))
          .toList(),
    );
  }

  @override
  String toString() {
    return 'Sentence{correctSentence: $correctSentence, spokenSentence: $spokenSentence, incorrectSentences: $incorrectSentences}';
  }
}

