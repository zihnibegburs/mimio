import 'package:flutter/material.dart';

enum AchievementScope { weekly, allTime }

enum AchievementId {
  weeklyFirstTask,
  weeklyFiveTasks,
  weeklyTenTasks,
  weeklyTwentyTasks,
  firstTask,
  fiveTasks,
  twentyFiveTasks,
  hundredTasks,
}

class AchievementDefinition {
  const AchievementDefinition({
    required this.id,
    required this.scope,
    required this.icon,
    required this.color,
    required this.target,
    required this.progressOf,
  });

  final AchievementId id;
  final AchievementScope scope;
  final IconData icon;
  final Color color;
  final int target;
  final int Function(AchievementStats stats) progressOf;

  bool isUnlocked(AchievementStats stats) => progressOf(stats) >= target;
  double progress(AchievementStats stats) => (progressOf(stats) / target).clamp(0.0, 1.0);

  String unlockKey(AchievementStats stats) =>
      scope == AchievementScope.weekly ? '${id.name}_${stats.weekKey}' : id.name;
}

class AchievementStats {
  const AchievementStats({
    this.tasksCompleted = 0,
    this.tasksCompletedThisWeek = 0,
    this.weekKey,
  });

  final int tasksCompleted;
  final int tasksCompletedThisWeek;
  final String? weekKey;

  AchievementStats copyWith({
    int? tasksCompleted,
    int? tasksCompletedThisWeek,
    String? weekKey,
  }) {
    return AchievementStats(
      tasksCompleted: tasksCompleted ?? this.tasksCompleted,
      tasksCompletedThisWeek: tasksCompletedThisWeek ?? this.tasksCompletedThisWeek,
      weekKey: weekKey ?? this.weekKey,
    );
  }

  Map<String, dynamic> toJson() => {
        'tasksCompleted': tasksCompleted,
        'tasksCompletedThisWeek': tasksCompletedThisWeek,
        'weekKey': weekKey,
      };

  factory AchievementStats.fromJson(Map<String, dynamic> json) => AchievementStats(
        tasksCompleted: json['tasksCompleted'] as int? ?? 0,
        tasksCompletedThisWeek: json['tasksCompletedThisWeek'] as int? ?? 0,
        weekKey: json['weekKey'] as String?,
      );
}

String weekKeyFor(DateTime date) {
  final monday = date.subtract(Duration(days: date.weekday - 1));
  return '${monday.year}-${monday.month.toString().padLeft(2, '0')}-${monday.day.toString().padLeft(2, '0')}';
}

const weeklyAchievementDefinitions = [
  AchievementDefinition(
    id: AchievementId.weeklyFirstTask,
    scope: AchievementScope.weekly,
    icon: Icons.wb_sunny_rounded,
    color: Color(0xFF3D9B87),
    target: 1,
    progressOf: _weeklyTasksCompleted,
  ),
  AchievementDefinition(
    id: AchievementId.weeklyFiveTasks,
    scope: AchievementScope.weekly,
    icon: Icons.bolt_rounded,
    color: Color(0xFF4ECDC4),
    target: 5,
    progressOf: _weeklyTasksCompleted,
  ),
  AchievementDefinition(
    id: AchievementId.weeklyTenTasks,
    scope: AchievementScope.weekly,
    icon: Icons.auto_awesome_rounded,
    color: Color(0xFFFF6B9D),
    target: 10,
    progressOf: _weeklyTasksCompleted,
  ),
  AchievementDefinition(
    id: AchievementId.weeklyTwentyTasks,
    scope: AchievementScope.weekly,
    icon: Icons.emoji_events_rounded,
    color: Color(0xFFFFE66D),
    target: 20,
    progressOf: _weeklyTasksCompleted,
  ),
];

const allTimeAchievementDefinitions = [
  AchievementDefinition(
    id: AchievementId.firstTask,
    scope: AchievementScope.allTime,
    icon: Icons.flag_rounded,
    color: Color(0xFF3D9B87),
    target: 1,
    progressOf: _tasksCompleted,
  ),
  AchievementDefinition(
    id: AchievementId.fiveTasks,
    scope: AchievementScope.allTime,
    icon: Icons.bolt_rounded,
    color: Color(0xFF4ECDC4),
    target: 5,
    progressOf: _tasksCompleted,
  ),
  AchievementDefinition(
    id: AchievementId.twentyFiveTasks,
    scope: AchievementScope.allTime,
    icon: Icons.auto_awesome_rounded,
    color: Color(0xFFFF6B9D),
    target: 25,
    progressOf: _tasksCompleted,
  ),
  AchievementDefinition(
    id: AchievementId.hundredTasks,
    scope: AchievementScope.allTime,
    icon: Icons.emoji_events_rounded,
    color: Color(0xFFFFE66D),
    target: 100,
    progressOf: _tasksCompleted,
  ),
];

const achievementDefinitions = [
  ...weeklyAchievementDefinitions,
  ...allTimeAchievementDefinitions,
];

int _tasksCompleted(AchievementStats stats) => stats.tasksCompleted;
int _weeklyTasksCompleted(AchievementStats stats) => stats.tasksCompletedThisWeek;
