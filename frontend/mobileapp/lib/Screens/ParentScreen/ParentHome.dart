import 'package:flutter/material.dart';
import 'package:mobileapp/Screens/ParentScreen/learnerMembersTab/LearnerDetails.dart';
import 'package:mobileapp/Screens/ParentScreen/LearnersProgress/ProgressDetails.dart';
import 'package:mobileapp/global/fns.dart';
import 'package:mobileapp/models/parent.dart';

import '../../generated/l10n.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.parent});

  final Parent parent;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

Parent? parent;

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    parent = widget.parent;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> categoryItems = [
      {
        "title": S.of(context).tips,
        "imagePath": "assets/images/tips.png",
        "gradient": [const Color(0xFF667eea), const Color(0xFF764ba2)],
        "icon": Icons.lightbulb_outline,
        "screen": () => const TipsScreen()
      },
      {
        "title": S.of(context).learner_members,
        "imagePath": "assets/images/LearnerMembers.png",
        "gradient": [const Color(0xFFf093fb), const Color(0xFFF1C6D7)],
        "icon": Icons.group,
        "screen": () => LearnerDetails(parent: parent)
      },
      {
        "title": S.of(context).add_word,
        "imagePath": "assets/images/addWord.jpg",
        "gradient": [const Color(0xFF4facfe), const Color(0xFF00f2fe)],
        "icon": Icons.add_circle_outline,
        "screen": () => const AddWordScreen()
      },
      {
        "title": S.of(context).learner_progress,
        "imagePath": "assets/images/progress2.png",
        "gradient": [const Color(0xFFa8edea), const Color(0xFFfed6e3)],
        "icon": Icons.trending_up,
        "screen": () => ProgressDetails(parent: parent)
      },
    ];

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF6C5CE7),
            Color(0xFFA29BFE),
            Color(0xFFDDD6FE),
          ],
        ),
      ),
      child: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Enhanced Intro Section
                _buildEnhancedIntroSection(),

                const SizedBox(height: 30),

                // Search Bar
                _buildSearchBar(),

                const SizedBox(height: 25),

                // Categories Title with Animation
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      S.of(context).categories,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Enhanced Grid Layout
                Expanded(
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: categoryItems.length,
                    itemBuilder: (context, index) {
                      return AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          final double animationValue = Curves.elasticOut.transform(
                            (_animationController.value - (index * 0.1)).clamp(0.0, 1.0),
                          );
                          return Transform.scale(
                            scale: animationValue,
                            child: _buildEnhancedGridItem(
                              context,
                              categoryItems[index],
                              index,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedIntroSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 3,
              ),
            ),
            child: const CircleAvatar(
              radius: 35,
              backgroundImage: AssetImage("assets/images/boy.jpeg"),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${S.of(context).welcome_message}",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${parent!.name}!",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  S.of(context).explore_message,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: Colors.grey[600],
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Search for activities...",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedGridItem(
      BuildContext context, Map<String, dynamic> item, int index) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        createRouteParentHome(item['screen']),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: item['gradient'],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: item['gradient'][0].withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              bottom: -10,
              left: -10,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icon with background
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      item['icon'],
                      size: 30,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Title
                  Text(
                    item['title'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Action button
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Explore",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Dummy Screens for Each Category
class TipsScreen extends StatelessWidget {
  const TipsScreen({super.key});

  @override
  Widget build(BuildContext context) => _buildScreen(context, "Tips");
}

class AddWordScreen extends StatelessWidget {
  const AddWordScreen({super.key});

  @override
  Widget build(BuildContext context) => _buildScreen(context, "Add Word");
}

Widget _buildScreen(BuildContext context, String title) {
  return Scaffold(
    appBar: AppBar(
      title: Text(title),
      backgroundColor: const Color(0xFF6C5CE7),
      foregroundColor: Colors.white,
    ),
    body: Center(
      child: Text(
        "Welcome to $title Page",
        style: const TextStyle(fontSize: 24),
      ),
    ),
  );
}