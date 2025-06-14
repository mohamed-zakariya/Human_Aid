class Word {
  final String id;
  final String text;
  final String level;
  final String? imageUrl; // ✅ nullable

  Word({
    required this.id,
    required this.text,
    required this.level,
    this.imageUrl, // ✅ nullable
  });

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      id: json['_id'],
      text: json['word'],
      level: json['level'],
      imageUrl: json['imageUrl'], // may be null
    );
  }
}
