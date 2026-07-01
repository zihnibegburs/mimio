import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:live_activities/live_activities.dart';
import 'package:mimio/core/config/platform_config.dart';
import 'package:mimio/core/models/models.dart';

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

  Future<void> syncFocusSession(FocusSessionModel? session) async {
    if (!_initialized || session == null) return;

    final data = <String, dynamic>{
      'taskTitle': session.title,
      'remaining': session.remainingFormatted,
      'progress': session.progressPercent,
      'color': session.color,
      'paused': session.isPaused,
    };

    final activityId = session.taskId;

    try {
      if (_activityId == null) {
        final enabled = await _plugin.areActivitiesEnabled();
        if (!enabled) return;
        _activityId = await _plugin.createActivity(activityId, data, activityTag: 'mimio_focus');
      } else {
        await _plugin.updateActivity(_activityId!, data, activityTag: 'mimio_focus');
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
}
