class Question {
  final String question;
  final List<String> choices;
  final int correctIndex;

  Question({
    required this.question,
    required this.choices,
    required this.correctIndex,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      question: json['question'],
      choices: List<String>.from(json['choices']),
      correctIndex: json['correctIndex'],
    );
  }
}