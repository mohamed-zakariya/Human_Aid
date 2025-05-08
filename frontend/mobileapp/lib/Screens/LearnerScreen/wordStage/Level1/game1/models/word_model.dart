class WordModel {
  final String word;
  final String image;
  final List<String> synonymChoices;
  final String correctSynonym;

  WordModel({
    required this.word,
    required this.image,
    required this.synonymChoices,
    required this.correctSynonym,
  });
}
