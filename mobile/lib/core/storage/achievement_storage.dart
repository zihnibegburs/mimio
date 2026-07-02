import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mimio/core/models/achievement.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AchievementStorage {
  static const _statsKey = 'achievement_stats';

  Future<AchievementStats> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_statsKey);
    if (raw == null) return const AchievementStats();
    try {
      return AchievementStats.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const AchievementStats();
    }
  }

  Future<void> save(AchievementStats stats) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_statsKey, jsonEncode(stats.toJson()));
  }

  String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  AchievementStats recordTaskCompleted(
    AchievementStats current, {
    required int durationMinutes,
    required bool hasReward,
    required DateTime completedAt,
    required bool perfectDay,
  }) {
    final today = _dateKey(completedAt);
    final yesterday = _dateKey(completedAt.subtract(const Duration(days: 1)));

    var streak = current.currentStreak;
    if (current.lastCompletionDate != today) {
      if (current.lastCompletionDate == yesterday) {
        streak = current.currentStreak + 1;
      } else {
        streak = 1;
      }
    }

    final longest = streak > current.longestStreak ? streak : current.longestStreak;
    final hour = completedAt.hour;

    return current.copyWith(
      tasksCompleted: current.tasksCompleted + 1,
      totalFocusMinutes: current.totalFocusMinutes + durationMinutes,
      rewardsClaimed: hasReward ? current.rewardsClaimed + 1 : current.rewardsClaimed,
      perfectDays: perfectDay ? current.perfectDays + 1 : current.perfectDays,
      currentStreak: streak,
      longestStreak: longest,
      earlyBirdCompletions: hour < 9 ? current.earlyBirdCompletions + 1 : current.earlyBirdCompletions,
      nightOwlCompletions: hour >= 21 ? current.nightOwlCompletions + 1 : current.nightOwlCompletions,
      lastCompletionDate: today,
    );
  }

  AchievementStats recordTaskCreated(AchievementStats current) {
    return current.copyWith(tasksCreated: current.tasksCreated + 1);
  }

  AchievementStats recordCalendarImport(AchievementStats current, int count) {
    return current.copyWith(
      calendarImports: current.calendarImports + count,
      tasksCreated: current.tasksCreated + count,
    );
  }
}

final achievementStorageProvider = Provider<AchievementStorage>((ref) => AchievementStorage());
