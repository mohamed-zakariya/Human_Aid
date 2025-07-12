// lib/screens/games_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/level.dart';
import '../models/game.dart';
import '../models/learner.dart';
import '../../generated/l10n.dart';

class LevelScreen extends StatefulWidget {
  final Level   level;
  final Learner learner;
  final String  exerciseId;
  final String  levelObjectId; // MongoDB ObjectId for mutation
  final String  exerciseImageUrl;

  const LevelScreen({
    Key? key,
    required this.level,
    required this.learner,
    required this.exerciseId,
    required this.levelObjectId,
    required this.exerciseImageUrl,
  }) : super(key: key);

  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {
  final Color _primaryColor = const Color(0xFF6C63FF);

  // Gradients used for game cards
  static const List<List<Color>> _cardGradients = [
    [Color(0xFF6C63FF), Color(0xFF584DFF)],
    [Color(0xFF4A80F0), Color(0xFF1A56F0)],
    [Color(0xFF3AA8A8), Color(0xFF2A8A8A)],
    [Color(0xFFFF6C8F), Color(0xFFFF4A73)],
    [Color(0xFFFFAA33), Color(0xFFFF8800)],
  ];

  // Locked game gradient (grey)
  static const List<Color> _lockedGradient = [
    Color(0xFF9E9E9E), 
    Color(0xFF757575)
  ];

  // ---- helpers -------------------------------------------------------------

  /// Returns a *non-null* game name in the active locale,
  /// falling back to a sensible default if missing.
  String _safeGameName(Game game, BuildContext ctx) {
    final bool isArabic = Localizations.localeOf(ctx).languageCode == 'ar';
    final String? candidate =
        isArabic ? game.arabicName : game.name; // either may be null

    // Arabic fallback is just the English "Game" transliterated; adjust if needed.
    return candidate?.trim().isNotEmpty == true
        ? candidate!
        : (isArabic ? 'لعبة' : 'Game');
  }

  /// Check if a game is unlocked
  bool _isGameUnlocked(Game game) {
    return game.unlocked ?? false;
  }

  // ---- UI ------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final levelTitle   = isArabic ? widget.level.arabicName : widget.level.name;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // APP-BAR
          SliverAppBar(
            expandedHeight: 180,
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
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.1,
                        child: Image.network(
                          widget.exerciseImageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // CONTENT
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildExerciseCard(context),
                  const SizedBox(height: 24),
                  Text(
                    S.of(context).games,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    S.of(context).selectGameToPlay,
                    style:
                        TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 24),

                  // LIST OF GAMES
                  if (widget.level.games.isEmpty)
                    _buildNoGamesPlaceholder(context)
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.level.games.length,
                      itemBuilder: (ctx, i) =>
                          _buildGameCard(ctx, widget.level.games[i], i),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------- widgets ------------------------------------------

  Widget _buildNoGamesPlaceholder(BuildContext ctx) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.videogame_asset_off,
                  color: Colors.grey.shade400, size: 60),
              const SizedBox(height: 16),
              Text(
                S.of(ctx).noGamesAvailable,
                style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );

  // Exercise card that opens the exercise itself
  Widget _buildExerciseCard(BuildContext ctx) {
    final bool isArabic = Localizations.localeOf(ctx).languageCode == 'ar';
    final String title =
        isArabic ? S.of(ctx).startExercise : 'Start Exercise'; // adjust if needed
    final List<Color> g = _cardGradients[0];

    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      elevation: 4,
      shadowColor: g[0].withOpacity(.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          ctx,
          '/${widget.level.levelId}',
            arguments: {
            'learner':    widget.learner,
            'exerciseId': widget.exerciseId,
            'levelId':    widget.levelObjectId,
          },
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
                    color: Colors.white,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white, size: 28),
            ],
          ),
        ),
      ),
    );
  }

  // Game card (tap area + Play Now button)
  Widget _buildGameCard(BuildContext ctx, Game game, int index) {
    final bool   isArabic     = Localizations.localeOf(ctx).languageCode == 'ar';
    final String title        = _safeGameName(game, ctx);
    final String description  = isArabic
        ? game.arabicDescription
        : game.description;
    final bool   isUnlocked   = _isGameUnlocked(game);

    // Use locked gradient if game is locked, otherwise use normal gradient
    final List<Color> gradient = isUnlocked 
        ? _cardGradients[index % _cardGradients.length]
        : _lockedGradient;
    
    Future<void> _navigate() async {
      // Don't navigate if game is locked
      if (!isUnlocked) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            content: Text(S.of(ctx).gameLockedMessage),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Persist minimal context if you need it later
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('exerciseId', widget.exerciseId);
      await prefs.setString('levelId',    widget.level.id);
      await prefs.setString('learnerId',  widget.learner.id ?? '');
      await prefs.setString('gameId',     game.id);
      await prefs.setString('levelGameId', game.gameId);

      String roundKey = '${widget.level.id}_${game.id}_${game.gameId}_round';
      if (!prefs.containsKey(roundKey)) {
        await prefs.setInt(roundKey, 1);
      }

      String scoreKey = '${widget.level.id}_${game.id}_${game.gameId}_score';
      if (!prefs.containsKey(scoreKey)) {
        await prefs.setInt(scoreKey, 0);
      }

      Navigator.pushNamed(
        ctx,
        '/${game.gameId}',
        arguments: {
          'gameId'   : game.gameId,
          'gameName' : title,            // <- guaranteed non-null
          'learner'  : widget.learner,
          'exerciseId' : widget.exerciseId,
        },
      );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isUnlocked ? 4 : 2,
      shadowColor: gradient.first.withOpacity(.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: _navigate,
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
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (game.imageUrl?.isNotEmpty == true)
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(16)),
                      child: ColorFiltered(
                        colorFilter: isUnlocked 
                            ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
                            : ColorFilter.mode(Colors.grey.withOpacity(0.6), BlendMode.saturation),
                        child: Image.network(
                          game.imageUrl!,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 150,
                            width: double.infinity,
                            color: Colors.white.withOpacity(.1),
                            child: Icon(
                              Icons.videogame_asset,
                              color: isUnlocked ? Colors.white : Colors.grey.shade400,
                            ),
                          ),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // title
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: TextStyle(
                                  color: isUnlocked ? Colors.white : Colors.grey.shade300,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // description
                        Text(
                          description,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isUnlocked 
                                ? Colors.white.withOpacity(.9)
                                : Colors.grey.shade400,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Play Now button
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: isUnlocked ? _navigate : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isUnlocked ? Colors.white : Colors.grey.shade300,
                              foregroundColor: isUnlocked ? gradient.first : Colors.grey.shade600,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            icon: Icon(isUnlocked ? Icons.play_arrow : Icons.lock),
                            label: Text(isUnlocked ? S.of(ctx).playGame : S.of(ctx).locked),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Lock overlay for locked games
              if (!isUnlocked)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.lock,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}