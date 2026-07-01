import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mimio/core/models/models.dart';
import 'package:mimio/core/platform/live_activity_service.dart';
import 'package:mimio/core/platform/widget_sync_service.dart';
import 'package:mimio/core/repositories/repositories.dart';

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

final celebrationTriggerProvider = StateProvider<bool>((ref) => false);

final focusSessionProvider =
    AsyncNotifierProvider<FocusSessionNotifier, FocusSessionModel?>(FocusSessionNotifier.new);

class FocusSessionNotifier extends AsyncNotifier<FocusSessionModel?> {
  Timer? _pollTimer;

  @override
  Future<FocusSessionModel?> build() async {
    ref.onDispose(() => _pollTimer?.cancel());

    final session = await ref.read(taskRepositoryProvider).getFocusSession();

    if (session != null && session.isActive) {
      await ref.read(liveActivityServiceProvider).syncFocusSession(session);
    }

    _pollTimer?.cancel();
    if (session != null && session.isActive) {
      _pollTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        ref.invalidateSelf();
      });
    }

    return session;
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
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

  Future<void> refresh() async {
    state = const AsyncLoading();
    final date = ref.read(selectedDateProvider);
    state = await AsyncValue.guard(() async {
      return ref.read(taskRepositoryProvider).getTimeline(date);
    });
    ref.invalidate(focusSessionProvider);
    final timeline = state.valueOrNull;
    if (timeline != null) await _syncPlatform(timeline);
  }

  Future<void> _syncPlatform(TimelineModel timeline) async {
    try {
      FocusSessionModel? session;
      try {
        session = await ref.read(taskRepositoryProvider).getFocusSession();
      } catch (_) {}
      await WidgetSyncService.syncTimeline(timeline, session: session);
      if (session != null && session.isActive) {
        await ref.read(liveActivityServiceProvider).syncFocusSession(session);
      } else if (timeline.activeTask == null) {
        await ref.read(liveActivityServiceProvider).endActivity();
      }
    } catch (e) {
      debugPrint('Platform sync skipped: $e');
    }
  }

  Future<void> createTask({
    required String title,
    int durationMinutes = 30,
    String color = '#6C63FF',
    DateTime? scheduledAt,
  }) async {
    await ref.read(taskRepositoryProvider).createTask(
          title: title,
          durationMinutes: durationMinutes,
          color: color,
          scheduledAt: scheduledAt,
        );
    await refresh();
  }

  Future<void> createTaskWithSubtasks({
    required String title,
    required DateTime scheduledAt,
    String color = '#6C63FF',
    required List<({String title, int durationMinutes, String color})> subtasks,
  }) async {
    await ref.read(taskRepositoryProvider).createTaskWithSubtasks(
          title: title,
          scheduledAt: scheduledAt,
          color: color,
          subtasks: subtasks,
        );
    await refresh();
  }

  Future<void> updateTask({
    required String id,
    String? title,
    String? description,
    String? color,
    int? durationMinutes,
    DateTime? scheduledAt,
  }) async {
    await ref.read(taskRepositoryProvider).updateTask(
          id: id,
          title: title,
          description: description,
          color: color,
          durationMinutes: durationMinutes,
          scheduledAt: scheduledAt,
        );
    await refresh();
  }

  Future<void> addSubtasksToTask({
    required String parentId,
    required List<({String title, int durationMinutes, String color})> subtasks,
  }) async {
    await ref.read(taskRepositoryProvider).addSubtasksToTask(
          parentId: parentId,
          subtasks: subtasks,
        );
    await refresh();
  }

  Future<void> startTask(String id) async {
    await ref.read(taskRepositoryProvider).startTask(id);
    await refresh();
    final session = await ref.read(taskRepositoryProvider).getFocusSession();
    await ref.read(liveActivityServiceProvider).syncFocusSession(session);
  }

  Future<void> pauseTask(String id) async {
    await ref.read(taskRepositoryProvider).pauseTask(id);
    await refresh();
  }

  Future<bool> completeTask(String id) async {
    await ref.read(taskRepositoryProvider).completeTask(id);
    await ref.read(liveActivityServiceProvider).endActivity();
    await refresh();
    return true;
  }

  Future<void> deleteTask(String id) async {
    await ref.read(taskRepositoryProvider).deleteTask(id);
    await refresh();
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
