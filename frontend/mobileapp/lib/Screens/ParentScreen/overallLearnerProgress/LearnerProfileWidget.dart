import 'package:flutter/material.dart';
import 'package:mobileapp/models/learner.dart';
import 'package:mobileapp/models/dailyAttempts/learner_daily_attempts.dart';
import '../../../models/overall_progress.dart';

class LearnerProfileWidget extends StatefulWidget {
  final Learner learner;
  final UserExerciseProgress? userProgress;

  const LearnerProfileWidget({super.key, required this.learner, this.userProgress});

  @override
  State<LearnerProfileWidget> createState() => _LearnerProfileWidgetState();
}

class _LearnerProfileWidgetState extends State<LearnerProfileWidget> {
  // Exercise IDs mapping
  static const String wordsExerciseId = "67c66a0e3387a31ba1ee4a72";
  static const String sentencesExerciseId = "67c66a0e3387a31ba1ee4a73";
  static const String lettersExerciseId = "67c66a0e3387a31ba1ee4a74";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double progress = widget.userProgress?.overallStats.combinedAccuracy ?? 0.0;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Profile Header Card
          _buildProfileHeader(progress),

          const SizedBox(height: 20),

          // Exercise Progress Cards
          _buildExerciseProgressSection(),

          const SizedBox(height: 20),

          // Overall Stats Row
          _buildOverallStatsRow(),

          const SizedBox(height: 20),

          // Detailed Progress by Exercise
          _buildDetailedProgressSection(),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(double progress) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Picture with Progress Ring
          Stack(
            alignment: Alignment.center,
            children: [
              // Progress Ring
              SizedBox(
                width: 100,
                height: 100,
                child: CircularProgressIndicator(
                  value: progress / 100,
                  strokeWidth: 4,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress >= 80 ? Colors.green :
                    progress >= 50 ? Colors.orange : Colors.red,
                  ),
                ),
              ),
              // Profile Picture
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: CircleAvatar(
                  backgroundImage: AssetImage(
                    widget.learner.gender == 'male'
                        ? "assets/images/boy.jpeg"
                        : "assets/images/girl.jpeg",
                  ),
                  radius: 40,
                ),
              ),
              // Progress Badge
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: progress >= 80 ? Colors.green :
                    progress >= 50 ? Colors.orange : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Text(
                    '${progress.toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Name and Username
          Text(
            widget.learner.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '@${widget.learner.username}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseProgressSection() {
    if (widget.userProgress == null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(Icons.school_outlined, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              "No Progress Yet",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Start learning to track progress!",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Exercise Progress",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildExerciseCard("Words", wordsExerciseId, Icons.menu_book, Colors.blue),
        const SizedBox(height: 12),
        _buildExerciseCard("Sentences", sentencesExerciseId, Icons.format_quote, Colors.purple),
        const SizedBox(height: 12),
        _buildExerciseCard("Letters", lettersExerciseId, Icons.text_fields, Colors.teal),
      ],
    );
  }

  Widget _buildExerciseCard(String title, String exerciseId, IconData icon, Color color) {
    var exerciseProgress = widget.userProgress?.progressByExercise
        ?.where((e) => e.exerciseId == exerciseId).firstOrNull;

    bool hasProgress = exerciseProgress != null;
    int correctCount = exerciseProgress?.stats.totalCorrect.count ?? 0;
    int totalAttempts = exerciseProgress?.stats.totalItemsAttempted ?? 0;
    double accuracy = exerciseProgress?.stats.accuracyPercentage ?? 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                if (hasProgress) ...[
                  Text(
                    "$correctCount correct • $totalAttempts attempts",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ] else ...[
                  Text(
                    "Not started yet",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (hasProgress) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: accuracy >= 80 ? Colors.green :
                accuracy >= 50 ? Colors.orange : Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "${accuracy.toInt()}%",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "0%",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOverallStatsRow() {
    if (widget.userProgress == null) return const SizedBox.shrink();

    int totalCorrect = 0;
    int totalIncorrect = 0;

    if (widget.userProgress!.progressByExercise != null) {
      for (var exercise in widget.userProgress!.progressByExercise!) {
        totalCorrect += exercise.stats.totalCorrect.count;
        totalIncorrect += exercise.stats.totalIncorrect.count;
      }
    }

    int totalTime = widget.userProgress!.overallStats.totalTimeSpent ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(child: _buildStatCard("✅", "Correct", "$totalCorrect", Colors.green)),
          const SizedBox(width: 12),
          Expanded(child: _buildStatCard("❌", "Incorrect", "$totalIncorrect", Colors.red)),
          const SizedBox(width: 12),
          Expanded(child: _buildStatCard("⏱️", "Time", "${(totalTime / 60).toInt()}m", Colors.blue)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String emoji, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedProgressSection() {
    if (widget.userProgress == null || widget.userProgress!.progressByExercise == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Detailed Progress",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...widget.userProgress!.progressByExercise!.map((exercise) {
          String exerciseName = _getExerciseName(exercise.exerciseId);
          return _buildDetailedExerciseCard(exerciseName, exercise);
        }).toList(),
      ],
    );
  }

  String _getExerciseName(String exerciseId) {
    switch (exerciseId) {
      case wordsExerciseId:
        return "Words";
      case sentencesExerciseId:
        return "Sentences";
      case lettersExerciseId:
        return "Letters";
      default:
        return "Unknown";
    }
  }

  Widget _buildDetailedExerciseCard(String exerciseName, dynamic exercise) {
    List<String> correctItems = List<String>.from(exercise.stats.totalCorrect.items ?? []);
    List<String> incorrectItems = List<String>.from(exercise.stats.totalIncorrect.items ?? []);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
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
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getExerciseColor(exerciseName).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getExerciseIcon(exerciseName),
            color: _getExerciseColor(exerciseName),
            size: 20,
          ),
        ),
        title: Text(
          exerciseName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          "${correctItems.length} correct • ${incorrectItems.length} incorrect",
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (correctItems.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "${correctItems.length}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (correctItems.isNotEmpty && incorrectItems.isNotEmpty)
              const SizedBox(width: 4),
            if (incorrectItems.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "${incorrectItems.length}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (correctItems.isEmpty && incorrectItems.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "0",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            Icon(Icons.expand_more, color: Colors.grey.shade400),
          ],
        ),
        children: [
          if (correctItems.isNotEmpty || incorrectItems.isNotEmpty) ...[
            if (correctItems.isNotEmpty) ...[
              Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    "Correct (${correctItems.length})",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: correctItems.map((item) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 16),
            ],
            if (incorrectItems.isNotEmpty) ...[
              Row(
                children: [
                  Icon(Icons.cancel, color: Colors.red, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    "Incorrect (${incorrectItems.length})",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: incorrectItems.map((item) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                )).toList(),
              ),
            ],
          ] else ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      Icons.pending_outlined,
                      size: 32,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "No attempts yet",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getExerciseColor(String exerciseName) {
    switch (exerciseName) {
      case "Words":
        return Colors.blue;
      case "Sentences":
        return Colors.purple;
      case "Letters":
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getExerciseIcon(String exerciseName) {
    switch (exerciseName) {
      case "Words":
        return Icons.menu_book;
      case "Sentences":
        return Icons.format_quote;
      case "Letters":
        return Icons.text_fields;
      default:
        return Icons.school;
    }
  }
}