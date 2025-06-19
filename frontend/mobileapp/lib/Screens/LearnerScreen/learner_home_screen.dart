import 'package:flutter/material.dart';
import 'package:mobileapp/Screens/LearnerScreen/NavBarLearner.dart';
import 'package:mobileapp/models/learner.dart';
import 'package:shared_preferences/shared_preferences.dart';


import '../../generated/l10n.dart';
import 'learner_dashboard_page.dart';
import 'learner_courses_page.dart';
import 'learner_profile_page.dart';


import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';



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

  final GlobalKey _coursesKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowTutorial();
    });


  }

  Future<void> _checkAndShowTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final hasShown = prefs.getBool('hasShownCourseTutorial') ?? false;

    if (!hasShown) {
      await prefs.setBool('hasShownCourseTutorial', true);
      _showTutorial();
    }
  }

  void _showTutorial() {
    TutorialCoachMark(
      targets: _createTargets(),
      colorShadow: Colors.black.withOpacity(0.8),
      textSkip: S.of(context).tutorialSkip,
      paddingFocus: 8,
      alignSkip: Alignment.bottomRight,
      onFinish: () {
        print("Tutorial finished");
      },
      onClickTarget: (target) {
        print('onClickTarget: $target');
      },
      onSkip: () {
        print("Tutorial skipped");
        return true;
      },
    ).show(context: context);
  }

  List<TargetFocus> _createTargets() {
    return [
      TargetFocus(
        identify: "CoursesTab",
        keyTarget: _coursesKey,
        alignSkip: Alignment.topLeft,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).tutorialCourseTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      S.of(context).tutorialCourseSubtitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    ];
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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
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
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white,
                child: ClipOval(
                  child: Image.asset(
                    widget.learner!.gender == 'male'
                        ? 'assets/images/child2.png'
                        : 'assets/images/child1.png',
                    width: 65,
                    height: 65,
                    fit: BoxFit.cover,
                  ),
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
          LearnerCoursesPage(learner: widget.learner),
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
            icon: Container(
              key: _coursesKey,
              child: const Icon(Icons.menu_book_outlined),
            ),
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
