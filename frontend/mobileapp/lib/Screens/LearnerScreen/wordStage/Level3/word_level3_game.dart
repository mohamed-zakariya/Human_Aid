import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';
import 'package:mobileapp/Services/tts_service.dart';
import 'package:mobileapp/generated/l10n.dart';

class MonthsOrderGameScreen extends StatefulWidget {
  const MonthsOrderGameScreen({super.key});

  @override
  State<MonthsOrderGameScreen> createState() => _MonthsOrderGameScreenState();
}

class _MonthsOrderGameScreenState extends State<MonthsOrderGameScreen> with TickerProviderStateMixin {
  // Audio players for different sound effects
  final AudioPlayer _correctPlayer = AudioPlayer();
  final AudioPlayer _incorrectPlayer = AudioPlayer();
  final AudioPlayer _clickPlayer = AudioPlayer();
  final AudioPlayer _dropPlayer = AudioPlayer();
  final AudioPlayer _successPlayer = AudioPlayer();
  final TTSService ttsService = TTSService();

  // Month data
  final List<MonthData> arabicMonths = [
    MonthData('يناير', 'كانون الثاني', 'شهر البداية'),
    MonthData('فبراير', 'شباط', 'شهر قصير'),
    MonthData('مارس', 'آذار', 'بداية الربيع'),
    MonthData('أبريل', 'نيسان', 'شهر الزهور'),
    MonthData('مايو', 'أيار', 'شهر الخضرة'),
    MonthData('يونيو', 'حزيران', 'بداية الصيف'),
    MonthData('يوليو', 'تموز', 'شهر الحرارة'),
    MonthData('أغسطس', 'آب', 'شهر السفر'),
    MonthData('سبتمبر', 'أيلول', 'شهر العودة للمدرسة'),
    MonthData('أكتوبر', 'تشرين الأول', 'بداية الخريف'),
    MonthData('نوفمبر', 'تشرين الثاني', 'شهر تساقط الأوراق'),
    MonthData('ديسمبر', 'كانون الأول', 'شهر نهاية العام'),
  ];

  bool showingLevadant = false; // Toggle between Arabic names and Levant names
  late List<MonthData> shuffledMonths;
  late List<MonthData?> orderedMonths;
  int score = 0;
  int currentLevel = 1;
  int totalLevels = 3;
  bool isLevelComplete = false;
  
  // Animation controllers
  late AnimationController _successAnimationController;
  late AnimationController _levelCompleteController;
  late Animation<double> _scaleAnimation;
  
  // Game variables
  late int monthsToOrder; // Number of months to order in current level

  @override
  void initState() {
    super.initState();
    
    _successAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _levelCompleteController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _levelCompleteController,
        curve: Curves.elasticOut,
      ),
    );
    
    _initSoundEffects();
    _loadLevel();
  }

  Future<void> _initSoundEffects() async {
    try {
      await _correctPlayer.setSource(AssetSource('sounds/correct.wav'));
      await _incorrectPlayer.setSource(AssetSource('sounds/incorrect.wav'));
      await _clickPlayer.setSource(AssetSource('sounds/click.wav'));
      await _successPlayer.setSource(AssetSource('sounds/success.wav'));
    } catch (e) {
      debugPrint('Failed to load sound assets: $e');
    }
    
    // Initialize TTS service with a try-catch to handle potential errors
    try {
      await ttsService.initialize(language: "ar");
    } catch (e) {
      debugPrint('Failed to initialize TTS: $e');
    }
  }

  @override
  void dispose() {
    _correctPlayer.dispose();
    _incorrectPlayer.dispose();
    _clickPlayer.dispose();
    _dropPlayer.dispose();
    _successPlayer.dispose();
    ttsService.stop();
    _successAnimationController.dispose();
    _levelCompleteController.dispose();
    super.dispose();
  }

  void _loadLevel() {
    // Set number of months based on current level
    switch (currentLevel) {
      case 1:
        monthsToOrder = 4; // First 4 months
        break;
      case 2:
        monthsToOrder = 8; // First 8 months
        break;
      case 3:
        monthsToOrder = 12; // All 12 months
        break;
      default:
        monthsToOrder = 4;
    }
    
    // Get subset of months based on level
    List<MonthData> levelMonths = arabicMonths.sublist(0, monthsToOrder);
    
    // Shuffle months for this level
    shuffledMonths = List.from(levelMonths)..shuffle(Random());
    
    // Initialize ordered months list with nulls
    orderedMonths = List.filled(monthsToOrder, null);
    
    // Reset level completion status
    isLevelComplete = false;
    
    // Reset animations
    _successAnimationController.reset();
    _levelCompleteController.reset();
  }

  void _checkOrderCorrectness() {
    // Check if all months are placed
    if (!orderedMonths.contains(null)) {
      bool isCorrect = true;
      
      // Check if months are in correct order
      for (int i = 0; i < orderedMonths.length; i++) {
        if (orderedMonths[i]!.name != arabicMonths[i].name) {
          isCorrect = false;
          break;
        }
      }
      
      if (isCorrect) {
        // Play success sound
        try {
          _successPlayer.resume();
        } catch (e) {
          debugPrint('Error playing success sound: $e');
        }
        
        setState(() {
          isLevelComplete = true;
          score++;
        });
        
        _levelCompleteController.forward();
        
        // Pronounce all months in order with delay
        Future.delayed(const Duration(milliseconds: 500), () {
          _pronounceOrderedMonths();
        });
      } else {
        // Play incorrect sound
        try {
          _incorrectPlayer.resume();
        } catch (e) {
          debugPrint('Error playing incorrect sound: $e');
        }
        
        // Shake the months to indicate wrong order
        _shakeMonthsForIncorrectOrder();
      }
    }
  }

  void _pronounceOrderedMonths() async {
    for (int i = 0; i < orderedMonths.length; i++) {
      await Future.delayed(const Duration(milliseconds: 800));
      // Fix the null check error by ensuring the month isn't null before accessing it
      if (orderedMonths[i] != null) {
        try {
          ttsService.speak(orderedMonths[i]!.name);
        } catch (e) {
          debugPrint('TTS error: $e');
        }
      }
    }
  }

  void _shakeMonthsForIncorrectOrder() {
    // Reset all months back to shuffled list after a short delay
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        // Add non-null months back to shuffled list
        shuffledMonths = List.from(shuffledMonths)
          ..addAll(orderedMonths.whereType<MonthData>().toList());
        orderedMonths = List.filled(monthsToOrder, null);
      });
    });
  }

  void _moveToNextLevel() {
    try {
      _clickPlayer.resume();
    } catch (e) {
      debugPrint('Error playing click sound: $e');
    }
    
    if (currentLevel < totalLevels) {
      setState(() {
        currentLevel++;
        _loadLevel();
      });
    } else {
      _showGameCompletionDialog();
    }
  }

  void _showGameCompletionDialog() {
    final l10n = S.of(context);
    try {
      _successPlayer.resume();
    } catch (e) {
      debugPrint('Error playing success sound: $e');
    }
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.gameCompletionTitle, textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            const Icon(
              Icons.emoji_events,
              size: 100,
              color: Color(0xFFFFD700),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.gameCompletionScore(score, totalLevels),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                try {
                  _clickPlayer.resume();
                } catch (e) {
                  debugPrint('Error playing click sound: $e');
                }
                Navigator.pop(context);
                setState(() {
                  score = 0;
                  currentLevel = 1;
                  _loadLevel();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7F73FF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: Text(l10n.playAgain, style: const TextStyle(fontSize: 16)),
            ),
          ],
        ),
        backgroundColor: Colors.white,
      ),
    );
  }

  void _toggleMonthNames() {
    setState(() {
      showingLevadant = !showingLevadant;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    // Calculate the appropriate grid settings based on screen size and level
    final size = MediaQuery.of(context).size;
    int crossAxisCount;
    double childAspectRatio;
    
    // Adapt grid layout based on level and screen width
    if (monthsToOrder > 8) {
      // Level 3 (12 months)
      crossAxisCount = size.width > 600 ? 4 : 2;
      childAspectRatio = size.width > 600 ? 3.0 : 2.2;
    } else if (monthsToOrder > 4) {
      // Level 2 (8 months)
      crossAxisCount = size.width > 600 ? 4 : 2;
      childAspectRatio = size.width > 600 ? 3.0 : 2.5;
    } else {
      // Level 1 (4 months)
      crossAxisCount = 2;
      childAspectRatio = 2.5;
    }
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FF),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(l10n.monthsOrderTitle),
        centerTitle: true,
        backgroundColor: const Color(0xFF7F73FF),
        elevation: 0,
        actions: [
          // Toggle between Arabic and Levant month names
          IconButton(
            icon: const Icon(Icons.translate, color: Colors.white),
            onPressed: _toggleMonthNames,
            tooltip: l10n.translateMonthsTooltip,
          ),
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: () {
              try {
                _clickPlayer.resume();
              } catch (e) {
                debugPrint('Error playing click sound: $e');
              }
              _showHelpDialog(context, l10n);
            },
          )
        ],
      ),
      body: Column(
        children: [
          // Header with level information
          Container(
            height: 100,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF7F73FF),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x29000000),
                  offset: Offset(0, 3),
                  blurRadius: 6,
                )
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l10n.wordsGame3Title, // Use as a getter, not a function
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.monthsOrderHeader(monthsToOrder == 12 ? l10n.all : monthsToOrder.toString()),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    totalLevels,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 24,
                      height: 8,
                      decoration: BoxDecoration(
                        color: index < currentLevel ? Colors.white : Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main content area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Month drop area with calendar visualization
                  Expanded(
                    flex: 3,  // Increased flex to give more space to this area
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        // Replace the image with a simple gradient
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.white, Color(0xFFF0F0FF)],
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: const BoxDecoration(
                              color: Color(0xFF7F73FF),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                            ),
                            child: Text(
                              l10n.orderMonthsCorrectly,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Expanded(
                            child: GridView.builder(
                              shrinkWrap: true,  // Add shrinkWrap
                              padding: const EdgeInsets.all(16),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                childAspectRatio: childAspectRatio,  // Use dynamic ratio
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                              itemCount: monthsToOrder,
                              itemBuilder: (context, index) {
                                return DragTarget<MonthData>(
                                  builder: (context, candidateData, rejectedData) {
                                    return AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      decoration: BoxDecoration(
                                        color: orderedMonths[index] != null
                                            ? const Color(0xFFE6F0FF)
                                            : const Color(0xFFEEEEFF),
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(
                                          color: orderedMonths[index] != null
                                              ? const Color(0xFF7F73FF)
                                              : Colors.grey.withOpacity(0.3),
                                          width: 2,
                                        ),
                                        boxShadow: orderedMonths[index] != null
                                            ? [
                                                BoxShadow(
                                                  color: const Color(0xFF7F73FF).withOpacity(0.3),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                )
                                              ]
                                            : null,
                                      ),
                                      child: orderedMonths[index] != null
                                          ? MonthCard(
                                              month: orderedMonths[index]!,
                                              showingLevadant: showingLevadant,
                                              isDraggable: !isLevelComplete,
                                              index: index + 1,
                                              onTap: () {
                                                if (!isLevelComplete) {
                                                  try {
                                                    ttsService.speak(orderedMonths[index]!.name);
                                                    _clickPlayer.resume();
                                                  } catch (e) {
                                                    debugPrint('Error with sound: $e');
                                                  }
                                                  setState(() {
                                                    shuffledMonths.add(orderedMonths[index]!);
                                                    orderedMonths[index] = null;
                                                  });
                                                }
                                              },
                                            )
                                          : Center(
                                              child: Text(
                                                "${index + 1}",
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.grey.withOpacity(0.7),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                    );
                                  },
                                  onAccept: (data) {
                                    try {
                                      _dropPlayer.resume();
                                    } catch (e) {
                                      debugPrint('Error playing drop sound: $e');
                                    }
                                    setState(() {
                                      // Remove from shuffled if it's there
                                      shuffledMonths.removeWhere((m) => m.name == data.name);
                                      
                                      // If there was already a month in this position, move it back to shuffled
                                      if (orderedMonths[index] != null) {
                                        shuffledMonths.add(orderedMonths[index]!);
                                      }
                                      
                                      // Place the month in position
                                      orderedMonths[index] = data;
                                      
                                      // Check if ordering is complete and correct
                                      _checkOrderCorrectness();
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Month selection area (shuffled months)
                  Container(
                    height: 90,  // Reduced height slightly
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: isLevelComplete
                        ? Center(
                            child: ScaleTransition(
                              scale: _scaleAnimation,
                              child: ElevatedButton(
                                onPressed: _moveToNextLevel,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF7F73FF),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                ),
                                child: Text(
                                  currentLevel < totalLevels
                                      ? l10n.next
                                      : l10n.gameCompleted,
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ),
                            ),
                          )
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: shuffledMonths.length,
                            itemBuilder: (context, index) {
                              final month = shuffledMonths[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                child: Draggable<MonthData>(
                                  data: month,
                                  feedback: Material(  // Wrap in Material for proper text rendering
                                    color: Colors.transparent,
                                    child: Container(
                                      width: 120,
                                      height: 65,  // Reduced height slightly
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE6F0FF),
                                        borderRadius: BorderRadius.circular(15),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.2),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          showingLevadant ? month.levantName : month.name,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF7F73FF),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  childWhenDragging: Opacity(
                                    opacity: 0.2,
                                    child: MonthCard(
                                      month: month,
                                      showingLevadant: showingLevadant,
                                      isDraggable: true,
                                      index: null,
                                      onTap: () {},
                                    ),
                                  ),
                                  onDragStarted: () {
                                    try {
                                      _clickPlayer.resume();
                                    } catch (e) {
                                      debugPrint('Error playing click sound: $e');
                                    }
                                  },
                                  child: MonthCard(
                                    month: month,
                                    showingLevadant: showingLevadant,
                                    isDraggable: true,
                                    index: null,
                                    onTap: () {
                                      try {
                                        ttsService.speak(month.name);
                                      } catch (e) {
                                        debugPrint('TTS error: $e');
                                      }
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context, S l10n) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.help_outline, color: Color(0xFF7F73FF)),
            const SizedBox(width: 10),
            Text(l10n.howToPlayTitle, style: const TextStyle(color: Color(0xFF7F73FF))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.drag_indicator, color: Color(0xFF7F73FF)),
              title: Text(l10n.monthsOrderHelpDrag),
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month, color: Color(0xFF7F73FF)),
              title: Text(l10n.monthsOrderHelpOrder),
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              leading: const Icon(Icons.volume_up, color: Color(0xFF7F73FF)),
              title: Text(l10n.monthsOrderHelpListen),
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              leading: const Icon(Icons.translate, color: Color(0xFF7F73FF)),
              title: Text(l10n.monthsOrderHelpTranslate),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  try {
                    _clickPlayer.resume();
                  } catch (e) {
                    debugPrint('Error playing click sound: $e');
                  }
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7F73FF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: Text(l10n.gotIt, style: const TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
      ),
    );
  }
}

// Month data model - simplified to remove image dependency
class MonthData {
  final String name; // Arabic name
  final String levantName; // Levant Arabic name
  final String description;

  MonthData(this.name, this.levantName, this.description);
}

// Month card widget - simplified with no image
class MonthCard extends StatelessWidget {
  final MonthData month;
  final bool showingLevadant;
  final bool isDraggable;
  final int? index;
  final VoidCallback onTap;

  const MonthCard({
    super.key,
    required this.month,
    required this.showingLevadant,
    required this.isDraggable,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 120,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),  // Reduced padding
        decoration: BoxDecoration(
          color: const Color(0xFFE6F0FF),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7F73FF).withOpacity(0.2),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,  // Make it take minimum space
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (index != null)
              Text(
                "$index",
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7F73FF),
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    showingLevadant ? month.levantName : month.name,
                    style: const TextStyle(
                      fontSize: 16,  // Reduced font size slightly
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 3),  // Reduced padding
                const Icon(
                  Icons.volume_up,
                  size: 14,  // Smaller icon
                  color: Color(0xFF7F73FF),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}