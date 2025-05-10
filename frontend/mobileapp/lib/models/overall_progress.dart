class OverallProgress {
  final String id;
  final List<UserExerciseProgress> progress;

  OverallProgress({required this.id, required this.progress});

  factory OverallProgress.fromJson(Map<String, dynamic> json) {
    return OverallProgress(
      id: json['id']?.toString() ?? '',
      progress: (json['progress'] as List<dynamic>?)
          ?.map((p) => UserExerciseProgress.fromJson(p))
          .toList() ??
          [],
    );
  }
}

class UserExerciseProgress {
  final String userId;
  final String name;
  final String username;
  final List<ExerciseProgress> progressByExercise;
  final OverallStats overallStats;

  UserExerciseProgress({
    required this.userId,
    required this.name,
    required this.username,
    required this.progressByExercise,
    required this.overallStats,
  });

  factory UserExerciseProgress.fromJson(Map<String, dynamic> json) {
    return UserExerciseProgress(
      userId: json['user_id'] ?? '',
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      progressByExercise: (json['progress_by_exercise'] as List<dynamic>?)
          ?.map((e) => ExerciseProgress.fromJson(e))
          .toList() ??
          [],
      overallStats: OverallStats.fromJson(json['overall_stats'] ?? {}),
    );
  }
}

class ExerciseProgress {
  final String exerciseId;
  final ExerciseStats stats;

  ExerciseProgress({
    required this.exerciseId,
    required this.stats,
  });

  factory ExerciseProgress.fromJson(Map<String, dynamic> json) {
    return ExerciseProgress(
      exerciseId: json['exercise_id'] ?? '',
      stats: ExerciseStats.fromJson(json['stats'] ?? {}),
    );
  }
}

class ExerciseStats {
  final StatDetail totalCorrect;
  final StatDetail totalIncorrect;
  final int totalItemsAttempted;
  final double accuracyPercentage;
  final double averageGameScore;
  final int timeSpentSeconds;

  ExerciseStats({
    required this.totalCorrect,
    required this.totalIncorrect,
    required this.totalItemsAttempted,
    required this.accuracyPercentage,
    required this.averageGameScore,
    required this.timeSpentSeconds,
  });

  factory ExerciseStats.fromJson(Map<String, dynamic> json) {
    return ExerciseStats(
      totalCorrect: StatDetail.fromJson(json['total_correct'] ?? {}),
      totalIncorrect: StatDetail.fromJson(json['total_incorrect'] ?? {}),
      totalItemsAttempted: json['total_items_attempted'] ?? 0,
      accuracyPercentage:
      (json['accuracy_percentage'] as num?)?.toDouble() ?? 0.0,
      averageGameScore:
      (json['average_game_score'] as num?)?.toDouble() ?? 0.0,
      timeSpentSeconds: json['time_spent_seconds'] ?? 0,
    );
  }
}

class StatDetail {
  final int count;
  final List<String> items;

  StatDetail({required this.count, required this.items});

  factory StatDetail.fromJson(Map<String, dynamic> json) {
    return StatDetail(
      count: json['count'] ?? 0,
      items:
      (json['items'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          [],
    );
  }
}

class OverallStats {
  final int totalTimeSpent;
  final double combinedAccuracy;
  final double averageScoreAll;

  OverallStats({
    required this.totalTimeSpent,
    required this.combinedAccuracy,
    required this.averageScoreAll,
  });

  factory OverallStats.fromJson(Map<String, dynamic> json) {
    return OverallStats(
      totalTimeSpent: json['total_time_spent'] ?? 0,
      combinedAccuracy: (json['combined_accuracy'] as num?)?.toDouble() ?? 0.0,
      averageScoreAll: (json['average_score_all'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
