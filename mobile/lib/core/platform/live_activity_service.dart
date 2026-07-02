import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:live_activities/live_activities.dart';
import 'package:mimio/core/config/platform_config.dart';
import 'package:mimio/core/l10n/app_strings.dart';
import 'package:mimio/core/storage/local_focus_storage.dart';

class LiveActivityService {
  LiveActivityService._();
  static final LiveActivityService instance = LiveActivityService._();

  final LiveActivities _plugin = LiveActivities();
  String? _activityId;
  bool _initialized = false;

  Future<void> initialize() async {
    if (kIsWeb) return;
    try {
      await _plugin.init(
        appGroupId: PlatformConfig.appGroupId,
        urlScheme: 'mimio',
        requestAndroidNotificationPermission: false,
      );
      _initialized = true;
    } on PlatformException catch (e) {
      _initialized = false;
      debugPrint('Live Activity init skipped: ${e.message}');
    } catch (e) {
      _initialized = false;
      debugPrint('Live Activity init: $e');
    }
  }

  Future<void> syncSession(LocalFocusSessionData data, {String language = 'tr'}) async {
    if (!_initialized) return;

    final session = data.toFocusSessionModel();
    final s = S(language);
    final now = DateTime.now();
    final timerEndDate = data.isPaused
        ? now.add(Duration(seconds: session.remainingSeconds))
        : data.timerEndDate;

    final payload = <String, dynamic>{
      'taskTitle': data.title,
      'remaining': session.remainingFormatted,
      'progress': session.progressPercent,
      'color': data.color,
      'paused': data.isPaused ? 1 : 0,
      'statusLabel': data.isPaused ? s.paused : s.focus,
      'timerStartDate': data.startedAt.millisecondsSinceEpoch,
      'timerEndDate': timerEndDate.millisecondsSinceEpoch,
    };

    try {
      final enabled = await _plugin.areActivitiesEnabled();
      if (!enabled) return;

      if (_activityId != null && _activityId != data.taskId) {
        await endActivity();
      }

      if (_activityId == null) {
        _activityId = await _plugin.createActivity(
          data.taskId,
          payload,
          activityTag: 'mimio_focus',
          removeWhenAppIsKilled: false,
        );
      } else {
        await _plugin.updateActivity(_activityId!, payload, activityTag: 'mimio_focus');
      }
    } on PlatformException catch (e) {
      debugPrint('Live Activity sync skipped: ${e.message}');
    } catch (e) {
      debugPrint('Live Activity sync: $e');
    }
  }

  Future<void> endActivity() async {
    if (!_initialized || _activityId == null) return;
    try {
      await _plugin.endActivity(_activityId!, activityTag: 'mimio_focus');
    } on PlatformException catch (e) {
      debugPrint('Live Activity end skipped: ${e.message}');
    } catch (e) {
      debugPrint('Live Activity end: $e');
    } finally {
      _activityId = null;
    }
  }

  LiveActivities get plugin => _plugin;
  bool get isInitialized => _initialized;
}
