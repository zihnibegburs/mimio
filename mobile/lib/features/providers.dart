import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mimio/core/l10n/app_strings.dart';
import 'package:mimio/core/models/models.dart';
import 'package:mimio/core/models/recurrence.dart';
import 'package:mimio/core/platform/live_activity_service.dart';
import 'package:mimio/core/platform/widget_sync_service.dart';
import 'package:mimio/core/repositories/repositories.dart';
import 'package:mimio/core/storage/local_focus_storage.dart';

final localFocusStorageProvider = Provider<LocalFocusStorage>((ref) => LocalFocusStorage());

final liveActivityServiceProvider = Provider<LiveActivityService>((ref) => LiveActivityService.instance);

final authStateProvider =
    AsyncNotifierProvider<AuthNotifier, AuthResponse?>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<AuthResponse?> {
  @override
  Future<AuthResponse?> build() async {
    return ref.read(authRepositoryProvider).getMe();
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return ref.read(authRepositoryProvider).login(
            email: email,
            password: password,
          );
    });
  }

  Future<void> register(String email, String password, String displayName) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return ref.read(authRepositoryProvider).register(
            email: email,
            password: password,
            displayName: displayName,
          );
    });
  }

  Future<void> logout() async {
    await ref.read(focusSessionProvider.notifier).clearSession();
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(null);
  }

  Future<void> updateProfile({
    String? displayName,
    String? avatarColor,
  }) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final updated = await ref.read(authRepositoryProvider).updateProfile(
          displayName: displayName,
          avatarColor: avatarColor,
        );
    state = AsyncData(updated);
  }
}

final selectedDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

enum TimelineViewMode { list, grid }

final timelineViewModeProvider = StateProvider<TimelineViewMode>((ref) => TimelineViewMode.list);

final celebrationEventProvider = StateProvider<CelebrationEvent?>((ref) => null);

class CelebrationEvent {
  const CelebrationEvent({required this.taskTitle, this.reward});

  final String taskTitle;
  final String? reward;

  bool get hasReward => reward != null && reward!.isNotEmpty;
}

void showTaskCelebration(WidgetRef ref, TaskModel task) {
  ref.read(celebrationEventProvider.notifier).state = CelebrationEvent(
    taskTitle: task.title,
    reward: task.reward,
  );
}

TaskModel? findTaskInTimeline(TimelineModel timeline, String id) {
  for (final task in timeline.tasks) {
    if (task.id == id) return task;
    for (final sub in task.subtasks) {
      if (sub.id == id) return sub;
    }
  }
  return null;
}

final focusSessionProvider =
    AsyncNotifierProvider<FocusSessionNotifier, FocusSessionModel?>(FocusSessionNotifier.new);

class FocusSessionNotifier extends AsyncNotifier<FocusSessionModel?> {
  Timer? _tickTimer;
  LocalFocusSessionData? _session;

  @override
  Future<FocusSessionModel?> build() async {
    ref.onDispose(() => _tickTimer?.cancel());

    _session = await ref.read(localFocusStorageProvider).load();
    _syncTickTimer();
    if (_session != null) {
      final lang = ref.read(appLanguageProvider).valueOrNull ?? 'tr';
      await ref.read(liveActivityServiceProvider).syncSession(_session!, language: lang);
    }
    return _session?.toFocusSessionModel();
  }

  Future<void> startWithTask(TaskModel task) async {
    _session = LocalFocusSessionData.fromTask(task);
    await _persistAndSync();
    _syncTickTimer();
  }

  Future<void> pause() async {
    final session = _session;
    if (session == null || session.isPaused) return;
    _session = session.copyWith(pausedAt: DateTime.now());
    await _persistAndSync();
    _tickTimer?.cancel();
  }

  Future<void> resume() async {
    final session = _session;
    if (session == null || !session.isPaused || session.pausedAt == null) return;
    final pauseMs = DateTime.now().difference(session.pausedAt!).inMilliseconds;
    _session = session.copyWith(
      accumulatedPauseMs: session.accumulatedPauseMs + pauseMs,
      clearPausedAt: true,
    );
    await _persistAndSync();
    _syncTickTimer();
  }

  Future<void> clearSession() async {
    _tickTimer?.cancel();
    _session = null;
    state = const AsyncData(null);
    await ref.read(localFocusStorageProvider).clear();
    try {
      await ref.read(liveActivityServiceProvider).endActivity();
    } catch (e) {
      debugPrint('Live activity end skipped: $e');
    }
  }

  Future<void> _persistAndSync() async {
    final session = _session;
    if (session == null) return;
    await ref.read(localFocusStorageProvider).save(session);
    state = AsyncData(session.toFocusSessionModel());
    final lang = ref.read(appLanguageProvider).valueOrNull ?? 'tr';
    await ref.read(liveActivityServiceProvider).syncSession(session, language: lang);
    ref.invalidate(timelineProvider);
  }

  void _syncTickTimer() {
    _tickTimer?.cancel();
    final session = _session;
    if (session == null || session.isPaused) return;
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final current = _session;
      if (current == null) return;
      state = AsyncData(current.toFocusSessionModel());
    });
  }
}

final timelineProvider =
    AsyncNotifierProvider<TimelineNotifier, TimelineModel>(TimelineNotifier.new);

class TimelineNotifier extends AsyncNotifier<TimelineModel> {
  @override
  Future<TimelineModel> build() async {
    final date = ref.watch(selectedDateProvider);
    final timeline = await ref.read(taskRepositoryProvider).getTimeline(date);
    await _syncPlatform(timeline);
    return timeline;
  }

  Future<void> refresh({bool showLoading = true}) async {
    if (showLoading) state = const AsyncLoading();
    final date = ref.read(selectedDateProvider);
    state = await AsyncValue.guard(() async {
      return ref.read(taskRepositoryProvider).getTimeline(date);
    });
    final timeline = state.valueOrNull;
    if (timeline != null) await _syncPlatform(timeline);
  }

  Future<void> _refreshAfterAction() async {
    final date = ref.read(selectedDateProvider);
    final previous = state.valueOrNull;
    try {
      final timeline = await ref.read(taskRepositoryProvider).getTimeline(date);
      state = AsyncData(timeline);
      await _syncPlatform(timeline);
    } catch (e, st) {
      debugPrint('Refresh after task action failed: $e\n$st');
      if (previous != null) state = AsyncData(previous);
      rethrow;
    }
  }

  Future<void> _syncPlatform(TimelineModel timeline) async {
    try {
      final session = ref.read(focusSessionProvider).valueOrNull;
      final lang = ref.read(appLanguageProvider).valueOrNull ?? 'tr';
      await WidgetSyncService.syncTimeline(timeline, session: session, language: lang);
    } catch (e) {
      debugPrint('Platform sync skipped: $e');
    }
  }

  Future<void> createTask({
    required String title,
    int durationMinutes = 30,
    String color = '#6C63FF',
    DateTime? scheduledAt,
    RecurrenceSelection recurrence = const RecurrenceSelection(),
    String? reward,
    bool autoStart = true,
  }) async {
    final task = await ref.read(taskRepositoryProvider).createTask(
          title: title,
          durationMinutes: durationMinutes,
          color: color,
          scheduledAt: scheduledAt,
          recurrence: recurrence,
          reward: reward,
        );
    if (autoStart) {
      await ref.read(focusSessionProvider.notifier).startWithTask(task);
    }
    await refresh(showLoading: false);
  }

  Future<void> createTaskWithSubtasks({
    required String title,
    required DateTime scheduledAt,
    String color = '#6C63FF',
    required List<({String title, int durationMinutes, String color})> subtasks,
    bool autoStart = true,
  }) async {
    final task = await ref.read(taskRepositoryProvider).createTaskWithSubtasks(
          title: title,
          scheduledAt: scheduledAt,
          color: color,
          subtasks: subtasks,
        );
    if (autoStart) {
      final firstSubtask = task.subtasks.isNotEmpty ? task.subtasks.first : task;
      await ref.read(focusSessionProvider.notifier).startWithTask(firstSubtask);
    }
    await refresh(showLoading: false);
  }

  Future<void> updateTask({
    required String id,
    String? title,
    String? description,
    String? color,
    int? durationMinutes,
    DateTime? scheduledAt,
    String? reward,
  }) async {
    await ref.read(taskRepositoryProvider).updateTask(
          id: id,
          title: title,
          description: description,
          color: color,
          durationMinutes: durationMinutes,
          scheduledAt: scheduledAt,
          reward: reward,
        );
    await refresh(showLoading: false);
  }

  Future<void> addSubtasksToTask({
    required String parentId,
    required List<({String title, int durationMinutes, String color})> subtasks,
  }) async {
    await ref.read(taskRepositoryProvider).addSubtasksToTask(
          parentId: parentId,
          subtasks: subtasks,
        );
    await refresh(showLoading: false);
  }

  Future<void> startTask(String id) async {
    final timeline = state.valueOrNull;
    if (timeline == null) {
      await refresh(showLoading: false);
    }
    final current = state.valueOrNull;
    if (current == null) return;

    final task = findTaskInTimeline(current, id);
    if (task == null) {
      throw StateError('Task not found');
    }
    await ref.read(focusSessionProvider.notifier).startWithTask(task);
    await _syncPlatform(current);
  }

  Future<void> pauseTask(String id) async {
    final session = ref.read(focusSessionProvider).valueOrNull;
    if (session?.taskId != id) return;
    await ref.read(focusSessionProvider.notifier).pause();
    final timeline = state.valueOrNull;
    if (timeline != null) await _syncPlatform(timeline);
  }

  Future<void> resumeTask(String id) async {
    final session = ref.read(focusSessionProvider).valueOrNull;
    if (session?.taskId != id) return;
    await ref.read(focusSessionProvider.notifier).resume();
    final timeline = state.valueOrNull;
    if (timeline != null) await _syncPlatform(timeline);
  }

  Future<TaskModel> completeTask(String id) async {
    await ref.read(focusSessionProvider.notifier).clearSession();
    final completed = await ref.read(taskRepositoryProvider).completeTask(id);
    await _refreshAfterAction();
    return completed;
  }

  Future<void> deleteTask(String id) async {
    final session = ref.read(focusSessionProvider).valueOrNull;
    if (session?.taskId == id) {
      await ref.read(focusSessionProvider.notifier).clearSession();
    }
    await ref.read(taskRepositoryProvider).deleteTask(id);
    await refresh(showLoading: false);
  }
}

final weeklyTimelineProvider =
    FutureProvider<List<TimelineModel>>((ref) async {
  final selected = ref.watch(selectedDateProvider);
  final monday = selected.subtract(Duration(days: selected.weekday - 1));
  final repo = ref.read(taskRepositoryProvider);
  final futures = List.generate(7, (i) => repo.getTimeline(monday.add(Duration(days: i))));
  return Future.wait(futures);
});
