// lib/models/learner_profile.dart

import 'dart:convert';

class LearnerProfile {
  final String name;
  final String? email;
  final String username;
  final String nationality;
  final String birthdate;
  final String gender;
  final String parentName;
  final int totalTimeSpent;
  final String? profileImage;
  final String joinedDate;
  final int coursesCompleted;
  final int badgesEarned;
  final int currentStreak;
  final int totalPoints;
  final int level;
  final UserPreferences preferences;
  final List<Achievement> achievements;
  final List<RecentActivity> recentActivity;

  LearnerProfile({
    required this.name,
    this.email,
    required this.username,
    required this.nationality,
    required this.birthdate,
    required this.gender,
    required this.parentName,
    required this.totalTimeSpent,
    this.profileImage,
    required this.joinedDate,
    required this.coursesCompleted,
    required this.badgesEarned,
    required this.currentStreak,
    required this.totalPoints,
    required this.level,
    required this.preferences,
    required this.achievements,
    required this.recentActivity,
  });

  factory LearnerProfile.fromJson(Map<String, dynamic> json) {
    return LearnerProfile(
      name: json['name'] ?? '',
      email: json['email'],
      username: json['username'] ?? '',
      nationality: json['nationality'] ?? '',
      birthdate: json['birthdate'] ?? '',
      gender: json['gender'] ?? '',
      parentName: json['parentName'] ?? '',
      totalTimeSpent: json['totalTimeSpent'] ?? 0,
      profileImage: json['profileImage'],
      joinedDate: json['joinedDate'] ?? '',
      coursesCompleted: json['coursesCompleted'] ?? 0,
      badgesEarned: json['badgesEarned'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
      totalPoints: json['totalPoints'] ?? 0,
      level: json['level'] ?? 1,
      preferences: UserPreferences.fromJson(json['preferences'] ?? {}),
      achievements: (json['achievements'] as List<dynamic>?)
          ?.map((item) => Achievement.fromJson(item))
          .toList() ?? [],
      recentActivity: (json['recentActivity'] as List<dynamic>?)
          ?.map((item) => RecentActivity.fromJson(item))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'username': username,
      'nationality': nationality,
      'birthdate': birthdate,
      'gender': gender,
      'parentName': parentName,
      'totalTimeSpent': totalTimeSpent,
      'profileImage': profileImage,
      'joinedDate': joinedDate,
      'coursesCompleted': coursesCompleted,
      'badgesEarned': badgesEarned,
      'currentStreak': currentStreak,
      'totalPoints': totalPoints,
      'level': level,
      'preferences': preferences.toJson(),
      'achievements': achievements.map((a) => a.toJson()).toList(),
      'recentActivity': recentActivity.map((r) => r.toJson()).toList(),
    };
  }

  String toJsonString() => json.encode(toJson());

  factory LearnerProfile.fromJsonString(String jsonString) {
    return LearnerProfile.fromJson(json.decode(jsonString));
  }
}

class UserPreferences {
  final String language;
  final bool notifications;
  final String theme;

  UserPreferences({
    required this.language,
    required this.notifications,
    required this.theme,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      language: json['language'] ?? 'en',
      notifications: json['notifications'] ?? true,
      theme: json['theme'] ?? 'light',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'notifications': notifications,
      'theme': theme,
    };
  }
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final String earnedDate;
  final String icon;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.earnedDate,
    required this.icon,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      earnedDate: json['earnedDate'] ?? '',
      icon: json['icon'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'earnedDate': earnedDate,
      'icon': icon,
    };
  }
}

class RecentActivity {
  final String id;
  final String type;
  final String description;
  final String timestamp;

  RecentActivity({
    required this.id,
    required this.type,
    required this.description,
    required this.timestamp,
  });

  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    return RecentActivity(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      description: json['description'] ?? '',
      timestamp: json['timestamp'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'description': description,
      'timestamp': timestamp,
    };
  }
}