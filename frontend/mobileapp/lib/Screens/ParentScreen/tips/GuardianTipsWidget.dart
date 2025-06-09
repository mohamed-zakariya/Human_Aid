import 'package:flutter/material.dart';

class GuardianTipsWidget extends StatefulWidget {
  @override
  _GuardianTipsWidgetState createState() => _GuardianTipsWidgetState();
}

class _GuardianTipsWidgetState extends State<GuardianTipsWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentStep = 0;

  final List<GuardianTipStep> _steps = [
    GuardianTipStep(
      title: "Main Dashboard - Mohamed's Interface",
      screenshot: "assets/images/dashboard_screenshot.png", // Image 1
      highlights: [
        TipHighlight(
          area: const Rect.fromLTWH(50, 100, 300, 80),
          title: "Profile Section",
          description: "Show learner their name 'Mohamed' and profile picture at the top",
        ),
        TipHighlight(
          area: Rect.fromLTWH(30, 200, 340, 50),
          title: "Search Bar",
          description: "Explain how to search for activities using Arabic text",
        ),
        TipHighlight(
          area: Rect.fromLTWH(20, 300, 360, 200),
          title: "Activity Categories",
          description: "Point out the different learning categories with icons",
        ),
      ],
      instructions: [
        "Start by showing Mohamed his personalized dashboard",
        "Point to his name and profile picture to make it personal",
        "Explain the search functionality in Arabic",
        "Show the different learning activities available",
      ],
    ),
    GuardianTipStep(
      title: "Navigate to Courses",
      screenshot: "assets/images/courses_navigation.png", // Bottom nav from images
      highlights: [
        TipHighlight(
          area: Rect.fromLTWH(100, 700, 100, 60),
          title: "Courses Button",
          description: "Tap here to access all learning courses",
        ),
      ],
      instructions: [
        "Guide learner to look at the bottom of the screen",
        "Show them the 'Courses' button in the navigation bar",
        "Explain this is where all lessons are located",
        "Let them tap it themselves to build confidence",
      ],
    ),
    GuardianTipStep(
      title: "Choose Exercise - Words Exercise",
      screenshot: "assets/images/exercise_selection.png", // Image 2
      highlights: [
        TipHighlight(
          area: Rect.fromLTWH(20, 150, 360, 100),
          title: "Words Exercise Card",
          description: "This shows the exercise name and description",
        ),
        TipHighlight(
          area: Rect.fromLTWH(320, 170, 40, 40),
          title: "Enter Button",
          description: "Click this arrow to enter the exercise",
        ),
        TipHighlight(
          area: Rect.fromLTWH(40, 180, 280, 60),
          title: "Exercise Description",
          description: "Explains what learner will practice - 'Try to say the word you see'",
        ),
      ],
      instructions: [
        "Point out the 'Words Exercise' title",
        "Read the description: 'Try to say the word you see. You'll get up to 3 tries'",
        "Show the right arrow button to enter the course",
        "Explain they can listen to pronunciation",
      ],
    ),
    GuardianTipStep(
      title: "Understanding Levels Structure",
      screenshot: "assets/images/levels_view.png", // Image 2 lower part
      highlights: [
        TipHighlight(
          area: Rect.fromLTWH(20, 300, 360, 120),
          title: "Level 1 Section",
          description: "Each level is clearly numbered and organized",
        ),
        TipHighlight(
          area: Rect.fromLTWH(330, 320, 30, 30),
          title: "Faculty Icon",
          description: "This graduation cap icon indicates educational content",
        ),
        TipHighlight(
          area: Rect.fromLTWH(20, 450, 360, 120),
          title: "Level 2 Section",
          description: "Shows progression to next difficulty level",
        ),
      ],
      instructions: [
        "Explain that courses are divided into levels",
        "Level 1 is for beginners, Level 2 is more advanced",
        "Each level has its own games and practices",
        "The levels expand to show content without changing pages",
      ],
    ),
    GuardianTipStep(
      title: "Starting Practice Activities",
      screenshot: "assets/images/practice_buttons.png", // Image 5
      highlights: [
        TipHighlight(
          area: Rect.fromLTWH(80, 380, 150, 40),
          title: "Basic Words Button",
          description: "Click this to start Level 1 practice",
        ),
        TipHighlight(
          area: Rect.fromLTWH(80, 500, 200, 40),
          title: "Arrow Recognition Game",
          description: "Different practice type for Level 2",
        ),
      ],
      instructions: [
        "Show the blue practice buttons under each level",
        "Level 1 has 'Basic Words' practice",
        "Level 2 has 'Arrow Recognition Game'",
        "These buttons start the actual learning exercises",
        "Each practice type teaches different skills",
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _steps.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Guardian Navigation Guide',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.blue[100],
          tabs: _steps.asMap().entries.map((entry) {
            IconData stepIcon;
            switch (entry.key) {
              case 0:
                stepIcon = Icons.dashboard;
                break;
              case 1:
                stepIcon = Icons.menu_book;
                break;
              case 2:
                stepIcon = Icons.assignment;
                break;
              case 3:
                stepIcon = Icons.stairs;
                break;
              case 4:
                stepIcon = Icons.play_circle;
                break;
              default:
                stepIcon = Icons.circle;
            }
            return Tab(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(stepIcon),
                  Text('Step ${entry.key + 1}'),
                ],
              ),
            );
          }).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _steps.map((step) => _buildStepContent(step)).toList(),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton.icon(
              onPressed: _currentStep > 0
                  ? () {
                setState(() {
                  _currentStep--;
                  _tabController.animateTo(_currentStep);
                });
              }
                  : null,
              icon: Icon(Icons.arrow_back),
              label: Text('Previous'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[600],
                foregroundColor: Colors.white,
              ),
            ),
            Text(
              'Step ${_currentStep + 1} of ${_steps.length}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            ElevatedButton.icon(
              onPressed: _currentStep < _steps.length - 1
                  ? () {
                setState(() {
                  _currentStep++;
                  _tabController.animateTo(_currentStep);
                });
              }
                  : null,
              icon: Icon(Icons.arrow_forward),
              label: Text('Next'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent(GuardianTipStep step) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step Title
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[100]!, Colors.purple[100]!],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              step.title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),

          SizedBox(height: 20),

          // Screenshot with Highlights
          Container(
            height: 500,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  // App Screenshot
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.grey[200],
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.phone_android,
                            size: 100,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16),
                          Text(
                            'App Screenshot',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            step.title,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Highlight Overlays
                  ...step.highlights.map((highlight) =>
                      _buildHighlightOverlay(highlight)
                  ).toList(),
                ],
              ),
            ),
          ),

          SizedBox(height: 24),

          // Highlighted Features
          Text(
            'Key Features to Point Out:',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),

          SizedBox(height: 12),

          ...step.highlights.asMap().entries.map((entry) {
            final highlight = entry.value;
            return Container(
              margin: EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border(
                  left: BorderSide(
                    color: Colors.blue[600]!,
                    width: 4,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.blue[600],
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${entry.key + 1}',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          highlight.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    highlight.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),

          SizedBox(height: 24),

          // Guardian Instructions
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.people,
                      color: Colors.green[600],
                      size: 24,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'How to Guide Your Learner:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                ...step.instructions.asMap().entries.map((entry) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          margin: EdgeInsets.only(top: 2),
                          decoration: BoxDecoration(
                            color: Colors.green[600],
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${entry.key + 1}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightOverlay(TipHighlight highlight) {
    return Positioned(
      left: highlight.area.left,
      top: highlight.area.top,
      width: highlight.area.width,
      height: highlight.area.height,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.red,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
          color: Colors.red.withOpacity(0.1),
        ),
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              highlight.title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GuardianTipStep {
  final String title;
  final String screenshot;
  final List<TipHighlight> highlights;
  final List<String> instructions;

  GuardianTipStep({
    required this.title,
    required this.screenshot,
    required this.highlights,
    required this.instructions,
  });
}

class TipHighlight {
  final Rect area;
  final String title;
  final String description;

  TipHighlight({
    required this.area,
    required this.title,
    required this.description,
  });
}