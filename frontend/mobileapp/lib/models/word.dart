// models/word.dart
class Word {
  final String id;
  final String text;
  final String level;

  Word({required this.id, required this.text, required this.level});

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      id: json['_id'],
      text: json['word'],
      level: json['level'],
    );
  }
}
