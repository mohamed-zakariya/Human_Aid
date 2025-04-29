class Sentence {
  final String id;
  final String text;   // the sentence text itself
  final String level;

  Sentence({
    required this.id,
    required this.text,
    required this.level,
  });

  /// Construct from raw JSON coming back from GraphQL
  factory Sentence.fromJson(Map<String, dynamic> json) {
    return Sentence(
      id: json['_id'],
      text: json['sentence'],
      level: json['level'],
    );
  }

  /// Handy if you ever need to send it back
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'sentence': text,
      'level': level,
    };
  }
}
