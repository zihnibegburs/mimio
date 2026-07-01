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
      );

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

  int get completedSubtaskCount => subtasks.where((s) => s.isCompleted).length;

  DateTime get endTime {
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

  bool get isPaused => status == TaskStatus.paused;
  bool get isActive => status == TaskStatus.inProgress;

  String get remainingFormatted {
    final m = remainingSeconds ~/ 60;
    final s = remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
