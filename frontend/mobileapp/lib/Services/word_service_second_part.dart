import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobileapp/graphql/graphql_client.dart';
import 'dart:math';

class Word {
  final String word;
  final String? synonym;
  final String imageUrl;

  Word({
    required this.word,
    this.synonym,
    required this.imageUrl,
  });

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      word: json['word'] ?? '',
      synonym: json['synonym'],
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'synonym': synonym,
      'imageUrl': imageUrl,
    };
  }
}

class GameWords {
  final Word mainWord;
  final List<Word> synonymChoices;

  GameWords({
    required this.mainWord,
    required this.synonymChoices,
  });
}

class WordsService {
  static Future<List<Word>?> getWordsByLevel(String level) async {
    final client = await GraphQLService.getClient();

    const String query = r'''
      query getWordsByLevel($level: String!) {
        getWordsByLevel(level: $level) {
          word
          synonym
          imageUrl
        }
      }
    ''';

    final QueryResult result = await client.query(
      QueryOptions(
        document: gql(query),
        variables: {'level': level},
      ),
    );

    final QueryResult? finalResult = await GraphQLService.handleAuthErrors(
      result: result,
      role: "learner", // Assuming learner role for words access
      retryRequest: () async {
        final retryClient = await GraphQLService.getClient();
        return await retryClient.query(
          QueryOptions(
            document: gql(query),
            variables: {'level': level},
          ),
        );
      },
    );

    if (finalResult == null || finalResult.hasException) {
      print("Get Words Error: ${finalResult?.exception?.toString()}");
      return null;
    }

    final data = finalResult.data?["getWordsByLevel"];
    if (data == null) {
      print("No words data found for level: $level");
      return null;
    }

    final List<dynamic> wordsData = data as List<dynamic>;
    return wordsData.map((wordData) => Word.fromJson(wordData)).toList();
  }

  static Future<GameWords?> getFourRandomWords(String level) async {
    try {
      final allWords = await getWordsByLevel(level);

      if (allWords == null || allWords.isEmpty) {
        print("No words available for level: $level");
        return null;
      }

      if (allWords.length < 4) {
        print("Not enough words available for level: $level. Found: ${allWords.length}, Required: 4");
        return null;
      }

      // Shuffle and get 4 random words
      final shuffledWords = List<Word>.from(allWords);
      shuffledWords.shuffle(Random());
      final selectedWords = shuffledWords.take(4).toList();

      // Randomly select one as the main word
      final random = Random();
      final mainWordIndex = random.nextInt(selectedWords.length);
      final mainWord = selectedWords[mainWordIndex];

      return GameWords(
        mainWord: mainWord,
        synonymChoices: selectedWords,
      );
    } catch (e) {
      print("Error getting four random words: $e");
      return null;
    }
  }

  static Future<List<GameWords>?> getMultipleGameWords(String level, int count) async {
    try {
      final allWords = await getWordsByLevel(level);

      if (allWords == null || allWords.isEmpty) {
        print("No words available for level: $level");
        return null;
      }

      if (allWords.length < count * 4) {
        print("Not enough words available for level: $level. Found: ${allWords.length}, Required: ${count * 4}");
        return null;
      }

      final List<GameWords> gameWordsList = [];
      final shuffledWords = List<Word>.from(allWords);
      shuffledWords.shuffle(Random());

      for (int i = 0; i < count; i++) {
        final startIndex = i * 4;
        if (startIndex + 4 > shuffledWords.length) break;

        final selectedWords = shuffledWords.sublist(startIndex, startIndex + 4);

        // Randomly select one as the main word
        final random = Random();
        final mainWordIndex = random.nextInt(selectedWords.length);
        final mainWord = selectedWords[mainWordIndex];

        gameWordsList.add(GameWords(
          mainWord: mainWord,
          synonymChoices: selectedWords,
        ));
      }

      return gameWordsList.isEmpty ? null : gameWordsList;
    } catch (e) {
      print("Error getting multiple game words: $e");
      return null;
    }
  }
}