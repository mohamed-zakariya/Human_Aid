import 'package:flutter/material.dart';
import '../models/level.dart';
import '../models/game.dart';
import '../models/learner.dart';
import '../../generated/l10n.dart';

class GamesScreen extends StatefulWidget {
  final Level level;
  final Learner learner;

  const GamesScreen({
    Key? key,
    required this.level,
    required this.learner,
  }) : super(key: key);

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  final Color _primaryColor = const Color(0xFF6C63FF);

  @override
  Widget build(BuildContext context) {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final levelTitle = isArabic ? widget.level.arabicName : widget.level.name;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar
          SliverAppBar(
            expandedHeight: 180.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                '${S.of(context).level} ${widget.level.levelNumber}: $levelTitle',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      _primaryColor,
                      _primaryColor.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Decorative shapes
                    Positioned(
                      right: -50,
                      top: -20,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -30,
                      bottom: -10,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Games content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Games section title
                  Text(
                    S.of(context).games,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    S.of(context).selectGameToPlay,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Games list
                  if (widget.level.games.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.videogame_asset_off,
                              color: Colors.grey[400],
                              size: 60,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              S.of(context).noGamesAvailable,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.level.games.length,
                      itemBuilder: (context, index) {
                        final game = widget.level.games[index];
                        return _buildGameCard(context, game, index);
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard(BuildContext context, Game game, int index) {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final String title = isArabic ? game.arabicName : game.name;
    final String description = isArabic ? game.arabicDescription : game.description;

    // Define a list of difficulty colors
    final Map<String, Color> difficultyColors = {
      'easy': Colors.green,
      'medium': Colors.orange,
      'hard': Colors.red,
    };

    final Color difficultyColor = difficultyColors[game.difficulty.toLowerCase()] ?? Colors.blue;

    // Different background colors for cards
    final List<List<Color>> cardGradients = [
      [const Color(0xFF6C63FF), const Color(0xFF584DFF)], // Purple
      [const Color(0xFF4A80F0), const Color(0xFF1A56F0)], // Blue
      [const Color(0xFF3AA8A8), const Color(0xFF2A8A8A)], // Teal
      [const Color(0xFFFF6C8F), const Color(0xFFFF4A73)], // Pink
      [const Color(0xFFFFAA33), const Color(0xFFFF8800)], // Orange
    ];

    final List<Color> gradient = cardGradients[index % cardGradients.length];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shadowColor: gradient[0].withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to game
          // Navigator.push(...);

          // For now, just print
          print('Starting game: ${game.gameId}');
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Game image
              if (game.imageUrl != null && game.imageUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    game.imageUrl!,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 150,
                        width: double.infinity,
                        color: Colors.white.withOpacity(0.1),
                        child: const Icon(
                          Icons.videogame_asset,
                          color: Colors.white,
                          size: 48,
                        ),
                      );
                    },
                  ),
                ),

              // Game info
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and difficulty pill
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: difficultyColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            game.difficulty,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Description
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 16),

                    // Play button
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Navigate to game
                          print('Starting game: ${game.gameId}');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: gradient[0],
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        icon: const Icon(Icons.play_arrow),
                        label: Text(S.of(context).playGame),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}