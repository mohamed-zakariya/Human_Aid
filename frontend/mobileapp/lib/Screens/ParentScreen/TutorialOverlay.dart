import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class TutorialService {
  static const String _parentTutorialKey = 'parentTutorialSeen';
  static List<TargetFocus> targets = [];

  static Future<bool> shouldShowParentTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_parentTutorialKey) ?? false);
  }



  static Future<void> markParentTutorialSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_parentTutorialKey, true);
  }

  static Future<void> resetParentTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_parentTutorialKey, false);
  }

  static void createTutorialTargets({
    required GlobalKey menuButtonKey,
    required GlobalKey searchBarKey,
    required GlobalKey tipsCategoryKey,
    required GlobalKey learnersCategoryKey,
    required GlobalKey addWordCategoryKey,
    required GlobalKey progressCategoryKey,
  }) {
    targets.clear();

    targets.addAll([
      // Menu Button Tutorial
      TargetFocus(
        identify: "MenuButton",
        keyTarget: menuButtonKey,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return TutorialContent(
                title: "Navigation Menu",
                description: "Tap here to access your profile, settings, and logout options.",
                onSkip: () => controller.skip(),
                onNext: () => controller.next(),
                isFirst: true,
                currentStep: 1,
                totalSteps: 6,
              );
            },
          ),
        ],
      ),

      // Search Bar Tutorial
      TargetFocus(
        identify: "SearchBar",
        keyTarget: searchBarKey,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return TutorialContent(
                title: "Search Activities",
                description: "Use this search bar to quickly find specific activities or content.",
                onSkip: () => controller.skip(),
                onNext: () => controller.next(),
                onPrevious: () => controller.previous(),
                currentStep: 2,
                totalSteps: 6,
              );
            },
          ),
        ],
      ),

      // Tips Category Tutorial
      TargetFocus(
        identify: "TipsCategory",
        keyTarget: tipsCategoryKey,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return TutorialContent(
                title: "Helpful Tips",
                description: "Access guardian tips and educational guidance to help your learners succeed.",
                onSkip: () => controller.skip(),
                onNext: () => controller.next(),
                onPrevious: () => controller.previous(),
                currentStep: 3,
                totalSteps: 6,
              );
            },
          ),
        ],
      ),

      // Learners Category Tutorial
      TargetFocus(
        identify: "LearnersCategory",
        keyTarget: learnersCategoryKey,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return TutorialContent(
                title: "Learner Members",
                description: "Manage your learners - view details, add new learners, or remove existing ones.",
                onSkip: () => controller.skip(),
                onNext: () => controller.next(),
                onPrevious: () => controller.previous(),
                currentStep: 4,
                totalSteps: 6,
              );
            },
          ),
        ],
      ),

      // Add Word Category Tutorial
      TargetFocus(
        identify: "AddWordCategory",
        keyTarget: addWordCategoryKey,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return TutorialContent(
                title: "Add Vocabulary",
                description: "Add new words to expand your learners' vocabulary collection.",
                onSkip: () => controller.skip(),
                onNext: () => controller.next(),
                onPrevious: () => controller.previous(),
                currentStep: 5,
                totalSteps: 6,
              );
            },
          ),
        ],
      ),

      // Progress Category Tutorial
      TargetFocus(
        identify: "ProgressCategory",
        keyTarget: progressCategoryKey,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return TutorialContent(
                title: "Track Progress",
                description: "Monitor each learner's progress over the last 7 days - correct/incorrect words, game scores, and attempts.",
                onSkip: () => controller.skip(),
                onNext: () => controller.next(),
                onPrevious: () => controller.previous(),
                isLast: true,
                currentStep: 6,
                totalSteps: 6,
              );
            },
          ),
        ],
      ),
    ]);
  }

  static void showTutorial({
    required BuildContext context,
    required VoidCallback onFinish,
    required VoidCallback onSkip,
  }) {
    TutorialCoachMark(
      targets: targets,
      colorShadow: const Color(0xFF6C63FF),
      textSkip: "SKIP TOUR",
      paddingFocus: 10,
      opacityShadow: 0.8,
      imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      onFinish: () {
        markParentTutorialSeen();
        onFinish();
      },
      onSkip: () {
        markParentTutorialSeen();
        onSkip();
      },
      onClickTarget: (target) {
        // Handle target clicks if needed
      },
      onClickTargetWithTapPosition: (target, tapDetails) {
        // Handle target clicks with position if needed
      },
    ).show(context: context);
  }
}

class TutorialContent extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onSkip;
  final VoidCallback onNext;
  final VoidCallback? onPrevious;
  final bool isFirst;
  final bool isLast;
  final int currentStep;
  final int totalSteps;

  const TutorialContent({
    super.key,
    required this.title,
    required this.description,
    required this.onSkip,
    required this.onNext,
    this.onPrevious,
    this.isFirst = false,
    this.isLast = false,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            spreadRadius: 5,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.lightbulb,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$currentStep/$totalSteps',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6C63FF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            description,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF64748B),
              height: 1.5,
            ),
          ),

          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              if (!isFirst && onPrevious != null)
                TextButton(
                  onPressed: onPrevious,
                  child: const Text(
                    'Previous',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

              TextButton(
                onPressed: onSkip,
                child: const Text(
                  'Skip Tour',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const Spacer(),

              ElevatedButton(
                onPressed: onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  isLast ? 'Finish' : 'Next',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}