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

  // Global keys for tutorial targets
  final GlobalKey _drawerKey = GlobalKey();
  final GlobalKey _profileKey = GlobalKey();
  final GlobalKey _coursesKey = GlobalKey();

  // Add this variable to track tutorial state
  bool _isTutorialActive = false;

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
    setState(() {
      _isTutorialActive = true;
    });

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted || !_isTutorialActive) return;

      TutorialCoachMark(
        targets: _createTargets(),
        colorShadow: Colors.black.withOpacity(0.8),
        textSkip: S.of(context).tutorialSkip,
        paddingFocus: 10,
        alignSkip: Alignment.bottomRight,
        onFinish: () {
          print("Tutorial finished");
          Future.microtask(() {
            if (mounted) {
              setState(() {
                _isTutorialActive = false;
              });
            }
          });
        },
        onClickTarget: (target) {
          print('onClickTarget: ${target.identify}');
          // Handle specific target clicks if needed
          switch (target.identify) {
            case "CoursesTab":
              _selectPage(1);
              break;
          // Profile tab just highlights, no navigation
          }
        },
        onSkip: () {
          print("Tutorial skipped");
          Future.microtask(() {
            if (mounted) {
              setState(() {
                _isTutorialActive = false;
              });
            }
          });
          return true;
        },
      ).show(context: context);
    });
  }

  List<TargetFocus> _createTargets() {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return [
      // Step 1: Drawer menu
      TargetFocus(
        identify: "DrawerMenu",
        keyTarget: _drawerKey,
        alignSkip: isRtl ? Alignment.topLeft : Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).drawerMenuTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      S.of(context).drawerMenuDescription,
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

      // Step 2: Profile tab
      TargetFocus(
        identify: "ProfileTab",
        keyTarget: _profileKey,
        alignSkip: isRtl ? Alignment.topRight : Alignment.topLeft,
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
                      S.of(context).profileTabTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      S.of(context).profileTabDescription,
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

      // Step 3: Courses tab
      TargetFocus(
        identify: "CoursesTab",
        keyTarget: _coursesKey,
        alignSkip: isRtl ? Alignment.topRight : Alignment.topLeft,
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
                      S.of(context).coursesTabTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      S.of(context).coursesTabDescription,
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
    // Allow page changes during tutorial only for courses
    if (_isTutorialActive && pageIndex != 1) {
      return;
    }

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
    return Stack(
      children: [
        Scaffold(
          drawer: NavBarLearner(
            learner: widget.learner,
            onLocaleChange: widget.onLocaleChange,
            onPageSelected: _selectPage, // Pass the _selectPage function here
          ),
          appBar: AppBar(
            elevation: 0,
            backgroundColor: _primaryColor,
            iconTheme: const IconThemeData(color: Colors.white),
            leading: Builder(
              builder: (context) => IconButton(
                key: _drawerKey,
                icon: const Icon(Icons.menu),
                onPressed: _isTutorialActive
                    ? null
                    : () => Scaffold.of(context).openDrawer(),
              ),
            ),
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
          body: AbsorbPointer(
            absorbing: _isTutorialActive,
            child: PageView(
              controller: _pageController,
              physics: _isTutorialActive
                  ? const NeverScrollableScrollPhysics()
                  : null,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              children: [
                // Wrap the dashboard page to add tutorial keys
                _buildDashboardWithTutorialKeys(),
                LearnerCoursesPage(learner: widget.learner),
                LearnerProfilePage(learnerId: widget.learner?.id), 
              ],
            ),
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
                icon: Container(
                  key: _profileKey,
                  child: const Icon(Icons.person_outline),
                ),
                activeIcon: const Icon(Icons.person),
                label: S.of(context).bottomNavProfile,
              ),
            ],
          ),
        ),
        // Selective overlay to allow specific interactions during tutorial
        if (_isTutorialActive)
          Positioned.fill(
            child: Container(
              color: Colors.transparent,
              child: Stack(
                children: [
                  // Block most interactions
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () {}, // Absorb taps
                      child: Container(color: Colors.transparent),
                    ),
                  ),
                  // Allow bottom navigation interactions
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: kBottomNavigationBarHeight,
                    child: Container(
                      color: Colors.transparent,
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {}, // Block home button
                              child: Container(color: Colors.transparent),
                            ),
                          ),
                          Expanded(
                            child: Container(), // Allow courses button
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {}, // Block profile button navigation
                              child: Container(color: Colors.transparent),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDashboardWithTutorialKeys() {
    // Return the dashboard without tutorial key overlays since we removed those steps
    return LearnerDashboardPage(
      learner: widget.learner,
      onLocaleChange: widget.onLocaleChange,
      onSelectPage: _selectPage,
    );
  }
}