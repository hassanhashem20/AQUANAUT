import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nasa2/core/services/web_storage_service.dart';
import 'dart:html' as html;

class UserProgress {
  final int level;
  final int xp;
  final int totalXp;
  final Set<String> completedMissions;
  final Set<String> achievements;
  final int trainingSessionsCompleted;

  UserProgress({
    this.level = 1,
    this.xp = 0,
    this.totalXp = 0,
    Set<String>? completedMissions,
    Set<String>? achievements,
    this.trainingSessionsCompleted = 0,
  })  : completedMissions = completedMissions ?? {},
        achievements = achievements ?? {};

  int get xpForNextLevel => level * 100;
  double get progressToNextLevel => xp / xpForNextLevel;

  UserProgress copyWith({
    int? level,
    int? xp,
    int? totalXp,
    Set<String>? completedMissions,
    Set<String>? achievements,
    int? trainingSessionsCompleted,
  }) {
    return UserProgress(
      level: level ?? this.level,
      xp: xp ?? this.xp,
      totalXp: totalXp ?? this.totalXp,
      completedMissions: completedMissions ?? this.completedMissions,
      achievements: achievements ?? this.achievements,
      trainingSessionsCompleted: trainingSessionsCompleted ?? this.trainingSessionsCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'xp': xp,
      'totalXp': totalXp,
      'completedMissions': completedMissions.toList(),
      'achievements': achievements.toList(),
      'trainingSessionsCompleted': trainingSessionsCompleted,
    };
  }

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      level: json['level'] ?? 1,
      xp: json['xp'] ?? 0,
      totalXp: json['totalXp'] ?? 0,
      completedMissions: (json['completedMissions'] as List?)?.cast<String>().toSet() ?? {},
      achievements: (json['achievements'] as List?)?.cast<String>().toSet() ?? {},
      trainingSessionsCompleted: json['trainingSessionsCompleted'] ?? 0,
    );
  }
}

class UserProgressNotifier extends StateNotifier<UserProgress> {
  UserProgressNotifier() : super(UserProgress()) {
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    try {
      // Check if running on web
      if (html.window.navigator.userAgent.contains('Mozilla')) {
        // Use web storage
        final level = await WebStorageService.getInt('level') ?? 1;
        final xp = await WebStorageService.getInt('xp') ?? 0;
        final totalXp = await WebStorageService.getInt('totalXp') ?? 0;
        final completedMissionsList = await WebStorageService.getStringList('completedMissions');
        final achievementsList = await WebStorageService.getStringList('achievements');
        final completedMissions = completedMissionsList?.toSet() ?? {};
        final achievements = achievementsList?.toSet() ?? {};
        final trainingSessionsCompleted = await WebStorageService.getInt('trainingSessionsCompleted') ?? 0;

        state = UserProgress(
          level: level,
          xp: xp,
          totalXp: totalXp,
          completedMissions: completedMissions,
          achievements: achievements,
          trainingSessionsCompleted: trainingSessionsCompleted,
        );
      } else {
        // Use SharedPreferences for mobile
        final prefs = await SharedPreferences.getInstance();
        final level = prefs.getInt('level') ?? 1;
        final xp = prefs.getInt('xp') ?? 0;
        final totalXp = prefs.getInt('totalXp') ?? 0;
        final completedMissions = prefs.getStringList('completedMissions')?.toSet() ?? {};
        final achievements = prefs.getStringList('achievements')?.toSet() ?? {};
        final trainingSessionsCompleted = prefs.getInt('trainingSessionsCompleted') ?? 0;

        state = UserProgress(
          level: level,
          xp: xp,
          totalXp: totalXp,
          completedMissions: completedMissions,
          achievements: achievements,
          trainingSessionsCompleted: trainingSessionsCompleted,
        );
      }
    } catch (e) {
      print('Error loading progress: $e');
    }
  }

  Future<void> _saveProgress() async {
    try {
      // Check if running on web
      if (html.window.navigator.userAgent.contains('Mozilla')) {
        // Use web storage
        await WebStorageService.setInt('level', state.level);
        await WebStorageService.setInt('xp', state.xp);
        await WebStorageService.setInt('totalXp', state.totalXp);
        await WebStorageService.setStringList('completedMissions', state.completedMissions.toList());
        await WebStorageService.setStringList('achievements', state.achievements.toList());
        await WebStorageService.setInt('trainingSessionsCompleted', state.trainingSessionsCompleted);
      } else {
        // Use SharedPreferences for mobile
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('level', state.level);
        await prefs.setInt('xp', state.xp);
        await prefs.setInt('totalXp', state.totalXp);
        await prefs.setStringList('completedMissions', state.completedMissions.toList());
        await prefs.setStringList('achievements', state.achievements.toList());
        await prefs.setInt('trainingSessionsCompleted', state.trainingSessionsCompleted);
      }
    } catch (e) {
      print('Error saving progress: $e');
    }
  }

  void addXP(int amount) {
    var newXP = state.xp + amount;
    var newTotalXP = state.totalXp + amount;
    var newLevel = state.level;

    // Level up logic
    while (newXP >= newLevel * 100) {
      newXP -= newLevel * 100;
      newLevel++;
    }

    state = state.copyWith(
      xp: newXP,
      totalXp: newTotalXP,
      level: newLevel,
    );
    _saveProgress();
  }

  void completeMission(String missionId, int xpReward) {
    if (!state.completedMissions.contains(missionId)) {
      final newCompletedMissions = Set<String>.from(state.completedMissions)..add(missionId);
      state = state.copyWith(completedMissions: newCompletedMissions);
      addXP(xpReward);
    }
  }

  void unlockAchievement(String achievementId) {
    if (!state.achievements.contains(achievementId)) {
      final newAchievements = Set<String>.from(state.achievements)..add(achievementId);
      state = state.copyWith(achievements: newAchievements);
      addXP(50); // Achievement bonus XP
      _saveProgress();
    }
  }

  void incrementTrainingSessions() {
    state = state.copyWith(
      trainingSessionsCompleted: state.trainingSessionsCompleted + 1,
    );
    _saveProgress();
  }

  void resetProgress() {
    state = UserProgress();
    _saveProgress();
  }
}

final userProgressProvider = StateNotifierProvider<UserProgressNotifier, UserProgress>((ref) {
  return UserProgressNotifier();
});
