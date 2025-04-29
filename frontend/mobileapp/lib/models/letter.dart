class Letter {
  final String id;
  final String letter;
  final String? color; // Made the color field nullable
  final String group;

  Letter({
    required this.id,
    required this.letter,
    this.color, // Color is now optional
    required this.group,
  });

  factory Letter.fromJson(Map<String, dynamic> json) {
    return Letter(
      id: json["_id"] ?? '',
      letter: json["letter"] ?? '',
      color: json["color"], // Color can be null here
      group: json["group"] ?? '',
    );
  }

  @override
  String toString() {
    return 'Letter(id: $id, letter: $letter, group: $group)';
  }
}
