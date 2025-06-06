import 'game.dart';

class Level {
  final String id;
  final String levelId;
  final int levelNumber;
  final String name;
  final String arabicName;
  final List<Game> games;
  
  Level({
    required this.id,
    required this.levelId,
    required this.levelNumber,
    required this.name,
    required this.arabicName,
    required this.games,
  });
  
  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      id: json['_id'] ?? '',
      levelId: json['level_id'] ?? '',
      levelNumber: json['level_number'] ?? 0,
      name: json['name'] ?? '',
      arabicName: json['arabic_name'] ?? '',
      games: (json['games'] as List<dynamic>?)
          ?.map((gameJson) => Game.fromJson(gameJson))
          .toList() ?? [],
    );
  }
}