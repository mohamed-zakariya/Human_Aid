import 'package:flutter/material.dart';
import 'package:mobileapp/Screens/LearnerScreen/NavBarLearner.dart';
import 'package:mobileapp/models/learner.dart';
import '../../generated/l10n.dart';

// Your pages
import 'learner_dashboard_page.dart';
import 'learner_courses_page.dart';
import 'learner_profile_page.dart';

class LearnerHomeScreen extends StatefulWidget {
  final Function(Locale) onLocaleChange;
  final Learner? learner;

  const LearnerHomeScreen({
    Key? key,
    required this.onLocaleChange,
    required this.learner,
  }) : super(key: key);

  @override
  State<LearnerHomeScreen> createState() => _LearnerHomeScreenState();
}

class _LearnerHomeScreenState extends State<LearnerHomeScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  final Color _primaryColor = const Color(0xFF6C63FF);

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _selectPage(int pageIndex) {
    setState(() {
      _currentIndex = pageIndex;
    });
    _pageController.animateToPage(
      pageIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBarLearner(
        learner: widget.learner,
        onLocaleChange: widget.onLocaleChange,
      ),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        // We replace the simple title with a Row containing
        // the greeting (on the left) and the profile avatar (on the right).
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Greeting
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  S.of(context).helloLabel,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.learner?.name ?? 'User',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            // Profile Avatar
            const CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 22,
                backgroundImage: NetworkImage(
                  'https://images.pexels.com/photos/5428148/pexels-photo-5428148.jpeg',
                ),
              ),
            ),
          ],
        ),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        children: [
          LearnerDashboardPage(
            learner: widget.learner,
            onLocaleChange: widget.onLocaleChange,
            onSelectPage: _selectPage,
          ),
          LearnerCoursesPage(learner: widget.learner), // Pass learner here
          const LearnerProfilePage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _selectPage,
        selectedItemColor: _primaryColor,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: S.of(context).bottomNavHome,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.menu_book_outlined),
            activeIcon: const Icon(Icons.menu_book),
            label: S.of(context).bottomNavCourses,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person),
            label: S.of(context).bottomNavProfile,
          ),
        ],
      ),
    );
  }
}
