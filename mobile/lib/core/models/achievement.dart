import 'package:flutter/material.dart';

enum AchievementId {
  firstTask,
  fiveTasks,
  twentyFiveTasks,
  hundredTasks,
  focusHour,
  focusMarathon,
  perfectDay,
  streak3,
  streak7,
  rewardCollector,
  planner,
  earlyBird,
  nightOwl,
  calendarImporter,
  aiWhisperer,
  hatTrick,
  twoWeekStreak,
}

class AchievementDefinition {
  const AchievementDefinition({
    required this.id,
    required this.icon,
    required this.color,
    required this.target,
    required this.progressOf,
  });

  final AchievementId id;
  final IconData icon;
  final Color color;
  final int target;
  final int Function(AchievementStats stats) progressOf;

  bool isUnlocked(AchievementStats stats) => progressOf(stats) >= target;
  double progress(AchievementStats stats) => (progressOf(stats) / target).clamp(0.0, 1.0);
}

class AchievementStats {
  const AchievementStats({
    this.tasksCompleted = 0,
    this.tasksCreated = 0,
    this.totalFocusMinutes = 0,
    this.rewardsClaimed = 0,
    this.perfectDays = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.calendarImports = 0,
    this.earlyBirdCompletions = 0,
    this.nightOwlCompletions = 0,
    this.lastCompletionDate,
    this.aiPlansApplied = 0,
    this.maxDailyCompletions = 0,
    this.completionsToday = 0,
    this.weekendCompletions = 0,
  });

  final int tasksCompleted;
  final int tasksCreated;
  final int totalFocusMinutes;
  final int rewardsClaimed;
  final int perfectDays;
  final int currentStreak;
  final int longestStreak;
  final int calendarImports;
  final int earlyBirdCompletions;
  final int nightOwlCompletions;
  final String? lastCompletionDate;
  final int aiPlansApplied;
  final int maxDailyCompletions;
  final int completionsToday;
  final int weekendCompletions;

  AchievementStats copyWith({
    int? tasksCompleted,
    int? tasksCreated,
    int? totalFocusMinutes,
    int? rewardsClaimed,
    int? perfectDays,
    int? currentStreak,
    int? longestStreak,
    int? calendarImports,
    int? earlyBirdCompletions,
    int? nightOwlCompletions,
    String? lastCompletionDate,
    int? aiPlansApplied,
    int? maxDailyCompletions,
    int? completionsToday,
    int? weekendCompletions,
  }) {
    return AchievementStats(
      tasksCompleted: tasksCompleted ?? this.tasksCompleted,
      tasksCreated: tasksCreated ?? this.tasksCreated,
      totalFocusMinutes: totalFocusMinutes ?? this.totalFocusMinutes,
      rewardsClaimed: rewardsClaimed ?? this.rewardsClaimed,
      perfectDays: perfectDays ?? this.perfectDays,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      calendarImports: calendarImports ?? this.calendarImports,
      earlyBirdCompletions: earlyBirdCompletions ?? this.earlyBirdCompletions,
      nightOwlCompletions: nightOwlCompletions ?? this.nightOwlCompletions,
      lastCompletionDate: lastCompletionDate ?? this.lastCompletionDate,
      aiPlansApplied: aiPlansApplied ?? this.aiPlansApplied,
      maxDailyCompletions: maxDailyCompletions ?? this.maxDailyCompletions,
      completionsToday: completionsToday ?? this.completionsToday,
      weekendCompletions: weekendCompletions ?? this.weekendCompletions,
    );
  }

  Map<String, dynamic> toJson() => {
        'tasksCompleted': tasksCompleted,
        'tasksCreated': tasksCreated,
        'totalFocusMinutes': totalFocusMinutes,
        'rewardsClaimed': rewardsClaimed,
        'perfectDays': perfectDays,
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'calendarImports': calendarImports,
        'earlyBirdCompletions': earlyBirdCompletions,
        'nightOwlCompletions': nightOwlCompletions,
        'lastCompletionDate': lastCompletionDate,
        'aiPlansApplied': aiPlansApplied,
        'maxDailyCompletions': maxDailyCompletions,
        'completionsToday': completionsToday,
        'weekendCompletions': weekendCompletions,
      };

  factory AchievementStats.fromJson(Map<String, dynamic> json) => AchievementStats(
        tasksCompleted: json['tasksCompleted'] as int? ?? 0,
        tasksCreated: json['tasksCreated'] as int? ?? 0,
        totalFocusMinutes: json['totalFocusMinutes'] as int? ?? 0,
        rewardsClaimed: json['rewardsClaimed'] as int? ?? 0,
        perfectDays: json['perfectDays'] as int? ?? 0,
        currentStreak: json['currentStreak'] as int? ?? 0,
        longestStreak: json['longestStreak'] as int? ?? 0,
        calendarImports: json['calendarImports'] as int? ?? 0,
        earlyBirdCompletions: json['earlyBirdCompletions'] as int? ?? 0,
        nightOwlCompletions: json['nightOwlCompletions'] as int? ?? 0,
        lastCompletionDate: json['lastCompletionDate'] as String?,
        aiPlansApplied: json['aiPlansApplied'] as int? ?? 0,
        maxDailyCompletions: json['maxDailyCompletions'] as int? ?? 0,
        completionsToday: json['completionsToday'] as int? ?? 0,
        weekendCompletions: json['weekendCompletions'] as int? ?? 0,
      );
}

const achievementDefinitions = [
  AchievementDefinition(
    id: AchievementId.firstTask,
    icon: Icons.flag_rounded,
    color: Color(0xFF6C63FF),
    target: 1,
    progressOf: _tasksCompleted,
  ),
  AchievementDefinition(
    id: AchievementId.fiveTasks,
    icon: Icons.bolt_rounded,
    color: Color(0xFF4ECDC4),
    target: 5,
    progressOf: _tasksCompleted,
  ),
  AchievementDefinition(
    id: AchievementId.twentyFiveTasks,
    icon: Icons.auto_awesome_rounded,
    color: Color(0xFFFF6B9D),
    target: 25,
    progressOf: _tasksCompleted,
  ),
  AchievementDefinition(
    id: AchievementId.hundredTasks,
    icon: Icons.emoji_events_rounded,
    color: Color(0xFFFFE66D),
    target: 100,
    progressOf: _tasksCompleted,
  ),
  AchievementDefinition(
    id: AchievementId.focusHour,
    icon: Icons.timer_rounded,
    color: Color(0xFF3498DB),
    target: 60,
    progressOf: _focusMinutes,
  ),
  AchievementDefinition(
    id: AchievementId.focusMarathon,
    icon: Icons.fitness_center_rounded,
    color: Color(0xFF2ECC71),
    target: 300,
    progressOf: _focusMinutes,
  ),
  AchievementDefinition(
    id: AchievementId.perfectDay,
    icon: Icons.check_circle_rounded,
    color: Color(0xFF9B59B6),
    target: 1,
    progressOf: _perfectDays,
  ),
  AchievementDefinition(
    id: AchievementId.streak3,
    icon: Icons.local_fire_department_rounded,
    color: Color(0xFFFF8B5A),
    target: 3,
    progressOf: _longestStreak,
  ),
  AchievementDefinition(
    id: AchievementId.streak7,
    icon: Icons.whatshot_rounded,
    color: Color(0xFFE74C3C),
    target: 7,
    progressOf: _longestStreak,
  ),
  AchievementDefinition(
    id: AchievementId.rewardCollector,
    icon: Icons.card_giftcard_rounded,
    color: Color(0xFFFFB74D),
    target: 5,
    progressOf: _rewardsClaimed,
  ),
  AchievementDefinition(
    id: AchievementId.planner,
    icon: Icons.edit_calendar_rounded,
    color: Color(0xFF87CEEB),
    target: 10,
    progressOf: _tasksCreated,
  ),
  AchievementDefinition(
    id: AchievementId.earlyBird,
    icon: Icons.wb_sunny_rounded,
    color: Color(0xFFF7DC6F),
    target: 1,
    progressOf: _earlyBird,
  ),
  AchievementDefinition(
    id: AchievementId.nightOwl,
    icon: Icons.nightlight_round_rounded,
    color: Color(0xFF5D6D7E),
    target: 1,
    progressOf: _nightOwl,
  ),
  AchievementDefinition(
    id: AchievementId.calendarImporter,
    icon: Icons.calendar_month_rounded,
    color: Color(0xFF6C63FF),
    target: 1,
    progressOf: _calendarImports,
  ),
  AchievementDefinition(
    id: AchievementId.aiWhisperer,
    icon: Icons.psychology_rounded,
    color: Color(0xFFAB47BC),
    target: 1,
    progressOf: _aiPlansApplied,
  ),
  AchievementDefinition(
    id: AchievementId.hatTrick,
    icon: Icons.looks_3_rounded,
    color: Color(0xFF26A69A),
    target: 3,
    progressOf: _maxDailyCompletions,
  ),
  AchievementDefinition(
    id: AchievementId.twoWeekStreak,
    icon: Icons.military_tech_rounded,
    color: Color(0xFFFF7043),
    target: 14,
    progressOf: _longestStreak,
  ),
];

int _tasksCompleted(AchievementStats stats) => stats.tasksCompleted;
int _focusMinutes(AchievementStats stats) => stats.totalFocusMinutes;
int _perfectDays(AchievementStats stats) => stats.perfectDays;
int _longestStreak(AchievementStats stats) => stats.longestStreak;
int _rewardsClaimed(AchievementStats stats) => stats.rewardsClaimed;
int _tasksCreated(AchievementStats stats) => stats.tasksCreated;
int _earlyBird(AchievementStats stats) => stats.earlyBirdCompletions;
int _nightOwl(AchievementStats stats) => stats.nightOwlCompletions;
int _calendarImports(AchievementStats stats) => stats.calendarImports;
int _aiPlansApplied(AchievementStats stats) => stats.aiPlansApplied;
int _maxDailyCompletions(AchievementStats stats) => stats.maxDailyCompletions;
