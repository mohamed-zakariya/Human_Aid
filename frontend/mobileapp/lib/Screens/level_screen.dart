// lib/screens/games_screen.dart
import 'package:flutter/material.dart';
import '../models/level.dart';
import '../models/game.dart';
import '../models/learner.dart';
import '../../generated/l10n.dart';

class LevelScreen extends StatefulWidget {
  final Level level;
  final Learner learner;
  final String exerciseId;
  const LevelScreen({
    Key? key,
    required this.level,
    required this.learner, required this.exerciseId,
  }) : super(key: key);

  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {
  final Color _primaryColor = const Color(0xFF6C63FF);

  // -------------------------------------------------------------------------
  // PRETTY CARD GRADIENTS (same list you already used)
  // -------------------------------------------------------------------------
  static const List<List<Color>> _cardGradients = [
    [Color(0xFF6C63FF), Color(0xFF584DFF)],
    [Color(0xFF4A80F0), Color(0xFF1A56F0)],
    [Color(0xFF3AA8A8), Color(0xFF2A8A8A)],
    [Color(0xFFFF6C8F), Color(0xFFFF4A73)],
    [Color(0xFFFFAA33), Color(0xFFFF8800)],
  ];

  @override
  Widget build(BuildContext context) {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final levelTitle = isArabic ? widget.level.arabicName : widget.level.name;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ---------------------- APP-BAR -----------------------------------
          SliverAppBar(
            expandedHeight: 180.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                '${S.of(context).level} ${widget.level.levelNumber}: $levelTitle',
                style: const TextStyle(color: Colors.white),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_primaryColor, _primaryColor.withOpacity(.7)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),

          // ---------------------- CONTENT -----------------------------------
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---------- NEW ➊  LEVEL-EXERCISE CARD --------------------
                  _buildExerciseCard(context),

                  // ---------- SECTION TITLE --------------------------------
                  const SizedBox(height: 24),
                  Text(
                    S.of(context).games,
                    style:
                        const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    S.of(context).selectGameToPlay,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),

                  // ---------- LIST OF GAMES -------------------------------
                  if (widget.level.games.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          children: [
                            Icon(Icons.videogame_asset_off,
                                color: Colors.grey[400], size: 60),
                            const SizedBox(height: 16),
                            Text(
                              S.of(context).noGamesAvailable,
                              style:
                                  TextStyle(fontSize: 18, color: Colors.grey[600]),
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
                      itemBuilder: (context, index) =>
                          _buildGameCard(context, widget.level.games[index], index),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // EXERCISE CARD  (added piece)
  // =========================================================================
  Widget _buildExerciseCard(BuildContext ctx) {
    final bool isArabic = Localizations.localeOf(ctx).languageCode == 'ar';
    final String title =
        isArabic ? S.of(ctx).playGame /* adjust string if needed */ : 'Start Exercise';
    final List<Color> g = _cardGradients[0]; // first gradient for consistency

    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      elevation: 4,
      shadowColor: g[0].withOpacity(.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          ctx,
          '/${widget.level.levelId}',   // e.g. "/letters_level_1"
          arguments: {'learner': widget.learner, 'exerciseId': widget.exerciseId},
        ),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: g,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.school, color: Colors.white, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white, size: 28),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // EXISTING GAME CARD (unchanged)
  // =========================================================================
  Widget _buildGameCard(BuildContext context, Game game, int index) {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final String title = isArabic ? game.arabicName : game.name;
    final String description =
        isArabic ? game.arabicDescription : game.description;

    // map difficulty colours
    final Map<String, Color> difficultyColors = {
      'easy': Colors.green,
      'medium': Colors.orange,
      'hard': Colors.red,
    };
    final Color difficultyColor =
        difficultyColors[game.difficulty.toLowerCase()] ?? Colors.blue;

    final List<Color> gradient = _cardGradients[index % _cardGradients.length];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shadowColor: gradient[0].withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/${game.gameId}', // Route directly to the gameId as defined in main.dart
            arguments: {'gameId': game.gameId, 'learner': widget.learner},
          );
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
              // game image
              if (game.imageUrl != null && game.imageUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    game.imageUrl!,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 150,
                      width: double.infinity,
                      color: Colors.white.withOpacity(0.1),
                      child:
                          const Icon(Icons.videogame_asset, color: Colors.white),
                    ),
                  ),
                ),
              // game info
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // title & difficulty
                    Row(
                      children: [
                        Expanded(
                          child: Text(title,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: difficultyColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            game.difficulty,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // description
                    Text(description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.white.withOpacity(.9), fontSize: 14)),
                    const SizedBox(height: 16),
                    // play button
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/${game.gameId}',
                            arguments: {
                              'gameId': game.gameId,
                              'learner': widget.learner
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: gradient[0],
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
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
