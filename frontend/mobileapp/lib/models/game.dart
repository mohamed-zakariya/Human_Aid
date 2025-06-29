class Game {
  final String id;
  final String gameId;
  final String name;
  final String arabicName;
  final String description;
  final String arabicDescription;
  final String difficulty;
  final String? imageUrl;
  final bool? unlocked; // Add this property
  
  Game({
    required this.id,
    required this.gameId,
    required this.name,
    required this.arabicName,
    required this.description,
    required this.arabicDescription,
    required this.difficulty,
    this.imageUrl,
    this.unlocked, // Add this parameter
  });
  
  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['_id'] ?? '',
      gameId: json['game_id'] ?? '',
      name: json['name'] ?? '',
      arabicName: json['arabic_name'] ?? '',
      description: json['description'] ?? '',
      arabicDescription: json['arabic_description'] ?? '',
      difficulty: json['difficulty'] ?? 'medium',
      imageUrl: json['image_url'],
      unlocked: json['unlocked'], // Add this line
    );
  }

}
