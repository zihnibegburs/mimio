import 'package:mimio/core/models/adhd_models.dart';
import 'package:mimio/core/models/recurrence.dart';

enum TaskStatus { pending, inProgress, paused, completed, skipped }

class AuthResponse {
  final String token;
  final String userId;
  final String email;
  final String displayName;
  final String avatarColor;

  const AuthResponse({
    required this.token,
    required this.userId,
    required this.email,
    required this.displayName,
    required this.avatarColor,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        token: json['token'] as String,
        userId: json['userId'] as String,
        email: json['email'] as String,
        displayName: json['displayName'] as String,
        avatarColor: json['avatarColor'] as String,
      );

  String get firstName {
    final trimmed = displayName.trim();
    if (trimmed.isEmpty) return '';
    return trimmed.split(RegExp(r'\s+')).first;
  }

  AuthResponse copyWith({
    String? token,
    String? userId,
    String? email,
    String? displayName,
    String? avatarColor,
  }) =>
      AuthResponse(
        token: token ?? this.token,
        userId: userId ?? this.userId,
        email: email ?? this.email,
        displayName: displayName ?? this.displayName,
        avatarColor: avatarColor ?? this.avatarColor,
      );
}

class TaskModel {
  final String id;
  final String title;
  final String? description;
  final String color;
  final String icon;
  final int durationMinutes;
  final DateTime? scheduledAt;
  final TaskStatus status;
  final int sortOrder;
  final bool isInbox;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? parentTaskId;
  final List<TaskModel> subtasks;
  final String? reward;
  final EnergyLevel? energyLevel;
  final String? motivation;
  final int transitionBufferMinutes;
  final RecurrenceType recurrenceType;
  final String? recurrenceSeriesId;

  const TaskModel({
    required this.id,
    required this.title,
    this.description,
    required this.color,
    required this.icon,
    required this.durationMinutes,
    this.scheduledAt,
    required this.status,
    required this.sortOrder,
    required this.isInbox,
    this.startedAt,
    this.completedAt,
    this.parentTaskId,
    this.subtasks = const [],
    this.reward,
    this.energyLevel,
    this.motivation,
    this.transitionBufferMinutes = 0,
    this.recurrenceType = RecurrenceType.none,
    this.recurrenceSeriesId,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        color: json['color'] as String,
        icon: json['icon'] as String,
        durationMinutes: json['durationMinutes'] as int,
        scheduledAt: json['scheduledAt'] != null
            ? DateTime.parse(json['scheduledAt'] as String)
            : null,
        status: _parseStatus(json['status'] as String),
        sortOrder: json['sortOrder'] as int,
        isInbox: json['isInbox'] as bool,
        startedAt: json['startedAt'] != null
            ? DateTime.parse(json['startedAt'] as String)
            : null,
        completedAt: json['completedAt'] != null
            ? DateTime.parse(json['completedAt'] as String)
            : null,
        parentTaskId: json['parentTaskId'] as String?,
        subtasks: json['subtasks'] != null
            ? (json['subtasks'] as List)
                .map((t) => TaskModel.fromJson(t as Map<String, dynamic>))
                .toList()
            : const [],
        reward: json['reward'] as String?,
        energyLevel: EnergyLevelX.fromApiNullable(json['energyLevel'] as String?),
        motivation: json['motivation'] as String?,
        transitionBufferMinutes: json['transitionBufferMinutes'] as int? ?? 0,
        recurrenceType: _parseRecurrenceType(json['recurrenceType'] as String?),
        recurrenceSeriesId: json['recurrenceSeriesId'] as String?,
      );

  static RecurrenceType _parseRecurrenceType(String? value) => switch (value) {
        'DAILY' => RecurrenceType.daily,
        'WEEKLY' => RecurrenceType.weekly,
        'MONTHLY' => RecurrenceType.monthly,
        'YEARLY' => RecurrenceType.yearly,
        'CUSTOM' => RecurrenceType.custom,
        _ => RecurrenceType.none,
      };

  static TaskStatus _parseStatus(String status) => switch (status) {
        'PENDING' => TaskStatus.pending,
        'IN_PROGRESS' => TaskStatus.inProgress,
        'PAUSED' => TaskStatus.paused,
        'COMPLETED' => TaskStatus.completed,
        'SKIPPED' => TaskStatus.skipped,
        _ => TaskStatus.pending,
      };

  bool get isActive => status == TaskStatus.inProgress;
  bool get isCompleted => status == TaskStatus.completed;
  bool get hasSubtasks => subtasks.isNotEmpty;
  bool get hasReward => reward != null && reward!.isNotEmpty;
  bool get hasMotivation => motivation != null && motivation!.isNotEmpty;
  bool get isRecurring =>
      recurrenceSeriesId != null || recurrenceType != RecurrenceType.none;

  int get completedSubtaskCount => subtasks.where((s) => s.isCompleted).length;

  DateTime get endTime {
    final start = scheduledAt ?? DateTime.now();
    return start.add(Duration(minutes: durationMinutes + transitionBufferMinutes));
  }

  DateTime get taskEndTime {
    final start = scheduledAt ?? DateTime.now();
    return start.add(Duration(minutes: durationMinutes));
  }
}

class TimelineModel {
  final DateTime date;
  final List<TaskModel> tasks;
  final TaskModel? activeTask;

  const TimelineModel({
    required this.date,
    required this.tasks,
    this.activeTask,
  });

  factory TimelineModel.fromJson(Map<String, dynamic> json) => TimelineModel(
        date: DateTime.parse(json['date'] as String),
        tasks: (json['tasks'] as List)
            .map((t) => TaskModel.fromJson(t as Map<String, dynamic>))
            .toList(),
        activeTask: json['activeTask'] != null
            ? TaskModel.fromJson(json['activeTask'] as Map<String, dynamic>)
            : null,
      );
}

class FocusSessionModel {
  static const standaloneTaskId = '__standalone__';

  final String taskId;
  final String title;
  final String color;
  final int durationMinutes;
  final TaskStatus status;
  final DateTime startedAt;
  final int elapsedSeconds;
  final int remainingSeconds;
  final double progressPercent;

  const FocusSessionModel({
    required this.taskId,
    required this.title,
    required this.color,
    required this.durationMinutes,
    required this.status,
    required this.startedAt,
    required this.elapsedSeconds,
    required this.remainingSeconds,
    required this.progressPercent,
  });

  factory FocusSessionModel.fromJson(Map<String, dynamic> json) => FocusSessionModel(
        taskId: json['taskId'] as String,
        title: json['title'] as String,
        color: json['color'] as String,
        durationMinutes: json['durationMinutes'] as int,
        status: TaskModel._parseStatus(json['status'] as String),
        startedAt: DateTime.parse(json['startedAt'] as String),
        elapsedSeconds: json['elapsedSeconds'] as int,
        remainingSeconds: json['remainingSeconds'] as int,
        progressPercent: (json['progressPercent'] as num).toDouble(),
      );

  bool get isStandalone => taskId == standaloneTaskId;
  bool get isPaused => status == TaskStatus.paused;
  bool get isActive => status == TaskStatus.inProgress;

  String get remainingFormatted {
    final m = remainingSeconds ~/ 60;
    final s = remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
