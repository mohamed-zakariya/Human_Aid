import 'package:flutter/material.dart';

class GuardianTipsWidget extends StatefulWidget {
  const GuardianTipsWidget({Key? key}) : super(key: key);

  @override
  State<GuardianTipsWidget> createState() => _GuardianTipsWidgetState();
}

class _GuardianTipsWidgetState extends State<GuardianTipsWidget> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<GuardianTip> _tips = [
    GuardianTip(
        title: "Identifying Reading Difficulties",
        description: "Watch for signs like slow reading pace, difficulty with word recognition, or avoidance of reading tasks.",
        icon: Icons.visibility_outlined,
        color: const Color(0xFF6C63FF),
        detailedTips: [
          "• Observe if the learner frequently loses their place while reading",
          "• Notice if they substitute similar-looking words (like 'was' for 'saw')",
          "• Check if they struggle to sound out unfamiliar words",
          "• Look for signs of fatigue or frustration during reading activities"
        ],
        reference: "International Dyslexia Association - Reading Assessment Guidelines"
    ),
    GuardianTip(
        title: "Supportive Communication Strategies",
        description: "Use clear, patient communication and provide multiple ways to receive and express information.",
        icon: Icons.chat_bubble_outline,
        color: const Color(0xFFFF6B9D),
        detailedTips: [
          "• Break instructions into smaller, manageable steps",
          "• Use visual aids and diagrams alongside verbal explanations",
          "• Allow extra processing time before expecting responses",
          "• Praise effort and progress rather than just correct answers"
        ],
        reference: "British Dyslexia Association - Communication Best Practices"
    ),
  ];

  // Helper method to determine if device is tablet
  bool _isTablet(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth >= 600; // Common tablet breakpoint
  }

  @override
  Widget build(BuildContext context) {
    final bool isTablet = _isTablet(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.school_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Learning Support',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Guardian Resources',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Show help or info dialog
            },
            icon: const Icon(
              Icons.help_outline,
              color: Colors.white,
            ),
            tooltip: 'Help & Information',
          ),
          IconButton(
            onPressed: () {
              // Show settings or more options
            },
            icon: const Icon(
              Icons.more_vert,
              color: Colors.white,
            ),
            tooltip: 'More Options',
          ),
        ],
      ),
      body: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(isTablet),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemCount: _tips.length,
                itemBuilder: (context, index) {
                  return _buildTipCard(_tips[index], isTablet);
                },
              ),
            ),
            _buildPageIndicator(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isTablet) {
    return Padding(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      child: Row(
        children: [
          Container(
            width: isTablet ? 48 : 40,
            height: isTablet ? 48 : 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.lightbulb_outline,
              color: const Color(0xFF6C63FF),
              size: isTablet ? 28 : 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Guardian Tips',
                  style: TextStyle(
                    fontSize: isTablet ? 22 : 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D3748),
                  ),
                ),
                Text(
                  'Assess and support dyslexic learners',
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    color: const Color(0xFF718096),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              // Navigate to view all tips
            },
            child: Text(
              'View All',
              style: TextStyle(
                color: const Color(0xFF6C63FF),
                fontWeight: FontWeight.w500,
                fontSize: isTablet ? 16 : 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard(GuardianTip tip, bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 20),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8), // Add some top spacing
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(isTablet ? 24 : 20),
              decoration: BoxDecoration(
                color: tip.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: tip.color.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: isTablet ? 56 : 48,
                        height: isTablet ? 56 : 48,
                        decoration: BoxDecoration(
                          color: tip.color,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          tip.icon,
                          color: Colors.white,
                          size: isTablet ? 28 : 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tip.title,
                              style: TextStyle(
                                fontSize: isTablet ? 18 : 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2D3748),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tip.description,
                              style: TextStyle(
                                fontSize: isTablet ? 14 : 12,
                                color: const Color(0xFF718096),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(isTablet ? 20 : 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Key Points:',
                          style: TextStyle(
                            fontSize: isTablet ? 16 : 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2D3748),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...tip.detailedTips.map((tipText) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            tipText,
                            style: TextStyle(
                              fontSize: isTablet ? 14 : 12,
                              color: const Color(0xFF4A5568),
                              height: 1.5,
                            ),
                          ),
                        )),
                        const SizedBox(height: 16),
                        Container(
                          padding: EdgeInsets.all(isTablet ? 12 : 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7FAFC),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: isTablet ? 16 : 14,
                                color: const Color(0xFF718096),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Reference: ${tip.reference}',
                                  style: TextStyle(
                                    fontSize: isTablet ? 12 : 10,
                                    color: const Color(0xFF718096),
                                    fontStyle: FontStyle.italic,
                                    height: 1.4,
                                  ),
                                ),
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
            const SizedBox(height: 16), // Add some bottom spacing
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          _tips.length,
              (index) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: _currentIndex == index ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: _currentIndex == index
                  ? const Color(0xFF6C63FF)
                  : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class GuardianTip {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<String> detailedTips;
  final String reference;

  GuardianTip({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.detailedTips,
    required this.reference,
  });
}