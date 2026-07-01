import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mimio/core/models/models.dart';
import 'package:mimio/core/network/dio_provider.dart';
import 'package:mimio/core/storage/token_storage.dart';

class AuthRepository {
  AuthRepository(this._dio, this._storage);

  final Dio _dio;
  final TokenStorage _storage;

  Future<AuthResponse> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final response = await _dio.post('/auth/register', data: {
      'email': email,
      'password': password,
      'displayName': displayName,
    });
    final auth = AuthResponse.fromJson(response.data as Map<String, dynamic>);
    await _storage.saveToken(auth.token);
    return auth;
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    final auth = AuthResponse.fromJson(response.data as Map<String, dynamic>);
    await _storage.saveToken(auth.token);
    return auth;
  }

  Future<AuthResponse?> getMe() async {
    final token = await _storage.getToken();
    if (token == null) return null;
    try {
      final response = await _dio.get('/auth/me');
      return AuthResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (_) {
      await _storage.clearToken();
      return null;
    }
  }

  Future<void> logout() => _storage.clearToken();

  Future<AuthResponse> updateProfile({
    String? displayName,
    String? avatarColor,
  }) async {
    final response = await _dio.patch('/auth/me', data: {
      if (displayName != null) 'displayName': displayName,
      if (avatarColor != null) 'avatarColor': avatarColor,
    });
    final updated = AuthResponse.fromJson(response.data as Map<String, dynamic>);
    final token = await _storage.getToken();
    return updated.copyWith(token: token ?? updated.token);
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(dioProvider),
    ref.watch(tokenStorageProvider),
  );
});

class TaskRepository {
  TaskRepository(this._dio);

  final Dio _dio;

  Future<TimelineModel> getTimeline(DateTime date) async {
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final response = await _dio.get('/timeline', queryParameters: {'date': dateStr});
    return TimelineModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<TaskModel> createTask({
    required String title,
    String? description,
    String color = '#6C63FF',
    String icon = 'task',
    int durationMinutes = 30,
    DateTime? scheduledAt,
    bool isInbox = false,
  }) async {
    final response = await _dio.post('/tasks', data: {
      'title': title,
      'description': description,
      'color': color,
      'icon': icon,
      'durationMinutes': durationMinutes,
      if (scheduledAt != null) 'scheduledAt': scheduledAt.toUtc().toIso8601String(),
      'isInbox': isInbox,
    });
    return TaskModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<TaskModel> createTaskWithSubtasks({
    required String title,
    required DateTime scheduledAt,
    String color = '#6C63FF',
    required List<({String title, int durationMinutes, String color})> subtasks,
  }) async {
    final response = await _dio.post('/tasks/with-subtasks', data: {
      'title': title,
      'color': color,
      'scheduledAt': scheduledAt.toUtc().toIso8601String(),
      'subtasks': subtasks
          .map((s) => {
                'title': s.title,
                'durationMinutes': s.durationMinutes,
                'color': s.color,
              })
          .toList(),
    });
    return TaskModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<TaskModel> updateTask({
    required String id,
    String? title,
    String? description,
    String? color,
    int? durationMinutes,
    DateTime? scheduledAt,
  }) async {
    final response = await _dio.put('/tasks/$id', data: {
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (color != null) 'color': color,
      if (durationMinutes != null) 'durationMinutes': durationMinutes,
      if (scheduledAt != null) 'scheduledAt': scheduledAt.toUtc().toIso8601String(),
    });
    return TaskModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<TaskModel> addSubtasksToTask({
    required String parentId,
    required List<({String title, int durationMinutes, String color})> subtasks,
  }) async {
    final response = await _dio.post('/tasks/$parentId/subtasks', data: {
      'subtasks': subtasks
          .map((s) => {
                'title': s.title,
                'durationMinutes': s.durationMinutes,
                'color': s.color,
              })
          .toList(),
    });
    return TaskModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<TaskModel> startTask(String id) async {
    final response = await _dio.post('/tasks/$id/start');
    return TaskModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<TaskModel> pauseTask(String id) async {
    final response = await _dio.post('/tasks/$id/pause');
    return TaskModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<TaskModel> completeTask(String id) async {
    final response = await _dio.post('/tasks/$id/complete');
    return TaskModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteTask(String id) async {
    await _dio.delete('/tasks/$id');
  }

  Future<FocusSessionModel?> getFocusSession() async {
    final response = await _dio.get('/focus/session');
    if (response.statusCode == 204 || response.data == null || response.data == '') {
      return null;
    }
    return FocusSessionModel.fromJson(response.data as Map<String, dynamic>);
  }
}

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository(ref.watch(dioProvider));
});
