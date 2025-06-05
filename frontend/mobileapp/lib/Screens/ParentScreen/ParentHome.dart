import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      duration: const Duration(milliseconds: 1000),
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
        "subtitle": "Helpful tips for learning",
        "icon": Icons.lightbulb_outline,
        "color": const Color(0xFF6C5CE7),
        "screen": () => const TipsScreen()
      },
      {
        "title": S.of(context).learner_members,
        "subtitle": "Manage your learners",
        "icon": Icons.group_outlined,
        "color": const Color(0xFFE84393),
        "screen": () => LearnerDetails(parent: parent)
      },
      {
        "title": S.of(context).add_word,
        "subtitle": "Add new vocabulary",
        "icon": Icons.add_circle_outline,
        "color": const Color(0xFF00B894),
        "screen": () => const AddWordScreen()
      },
      {
        "title": S.of(context).learner_progress,
        "subtitle": "Track learning progress",
        "icon": Icons.trending_up_outlined,
        "color": const Color(0xFF00CEC9),
        "screen": () => ProgressDetails(parent: parent)
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                _buildHeaderSection(),

                const SizedBox(height: 24),

                // Search Bar
                _buildSearchBar(),

                const SizedBox(height: 32),

                // Categories Section
                _buildSectionTitle(S.of(context).categories),

                const SizedBox(height: 16),

                // Categories Grid
                _buildCategoriesGrid(categoryItems),

                const SizedBox(height: 32),

                // Recent Activity Section (Optional)
                _buildSectionTitle("Recent Activity"),

                const SizedBox(height: 16),

                _buildRecentActivityCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF6C5CE7),
                width: 2,
              ),
            ),
            child: const CircleAvatar(
              radius: 28,
              backgroundImage: AssetImage("assets/images/boy.jpeg"),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${S.of(context).welcome_message}",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${parent!.name}!",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3436),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  S.of(context).explore_message,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF6C5CE7).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: Color(0xFF6C5CE7),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Search for activities...",
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontSize: 16,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey[400],
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3436),
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: () {},
          child: Text(
            "View All",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesGrid(List<Map<String, dynamic>> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            final double animationValue = Curves.easeOut.transform(
              (_animationController.value - (index * 0.1)).clamp(0.0, 1.0),
            );
            return Transform.translate(
              offset: Offset(0, 50 * (1 - animationValue)),
              child: Opacity(
                opacity: animationValue,
                child: _buildCategoryCard(items[index]),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        createRouteParentHome(item['screen']),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey[100]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: item['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    item['icon'],
                    size: 24,
                    color: item['color'],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  item['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3436),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  item['subtitle'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Text(
                    "Explore",
                    style: TextStyle(
                      color: item['color'],
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: item['color'],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivityCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[100]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF00B894).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.trending_up,
                  size: 20,
                  color: Color(0xFF00B894),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Great Progress!",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3436),
                      ),
                    ),
                    Text(
                      "Your learners completed 5 activities today",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "Today",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
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
    backgroundColor: const Color(0xFFF8F9FA),
    appBar: AppBar(
      title: Text(title),
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF2D3436),
      elevation: 0,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    ),
    body: Center(
      child: Text(
        "Welcome to $title Page",
        style: const TextStyle(
          fontSize: 24,
          color: Color(0xFF2D3436),
        ),
      ),
    ),
  );
}