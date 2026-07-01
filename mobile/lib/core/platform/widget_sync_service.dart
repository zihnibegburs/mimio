import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import 'package:mimio/core/config/platform_config.dart';
import 'package:mimio/core/models/models.dart';

class WidgetSyncService {
  static const _activeTitle = 'active_task_title';
  static const _activeRemaining = 'active_task_remaining';
  static const _nextTitle = 'next_task_title';
  static const _nextTime = 'next_task_time';
  static const _taskCount = 'task_count';
  static const _dateLabel = 'date_label';
  static const _subtitle = 'widget_subtitle';

  static bool _available = false;

  static bool get isAvailable => _available;

  static Future<void> initialize() async {
    if (kIsWeb) return;
    try {
      await HomeWidget.setAppGroupId(PlatformConfig.appGroupId);
      _available = true;
    } on PlatformException catch (e) {
      _available = false;
      debugPrint('Widget init skipped (App Group not configured): ${e.message}');
    } catch (e) {
      _available = false;
      debugPrint('Widget init: $e');
    }
  }

  static Future<void> syncTimeline(TimelineModel timeline, {FocusSessionModel? session}) async {
    if (kIsWeb || !_available) return;

    try {
      final pending = timeline.tasks.where((t) => !t.isCompleted).toList();
      final next = pending.isEmpty
          ? null
          : pending.firstWhere(
              (t) => !t.isActive && t.status != TaskStatus.paused,
              orElse: () => pending.first,
            );

      final dateLabel = DateFormat('d MMM', 'tr_TR').format(timeline.date);
      String subtitle;
      String title;

      if (timeline.activeTask != null) {
        title = timeline.activeTask!.title;
        final remaining = session?.remainingFormatted ?? '${timeline.activeTask!.durationMinutes} dk';
        subtitle = session?.isPaused == true ? 'Duraklatıldı · $remaining' : 'Aktif · $remaining kaldı';
        await HomeWidget.saveWidgetData<String>(_activeTitle, title);
        await HomeWidget.saveWidgetData<String>(_activeRemaining, remaining);
      } else if (next != null) {
        title = next.title;
        final time = next.scheduledAt != null
            ? DateFormat('HH:mm').format(next.scheduledAt!.toLocal())
            : '--:--';
        subtitle = 'Sıradaki · $time';
        await HomeWidget.saveWidgetData<String>(_nextTitle, title);
        await HomeWidget.saveWidgetData<String>(_nextTime, time);
      } else {
        title = 'Bugün plan yok';
        subtitle = 'Mimio · $dateLabel';
      }

      await HomeWidget.saveWidgetData<String>(_subtitle, subtitle);
      await HomeWidget.saveWidgetData<int>(_taskCount, timeline.tasks.length);
      await HomeWidget.saveWidgetData<String>(_dateLabel, dateLabel);
      await HomeWidget.saveWidgetData<String>(
        'tasks_json',
        jsonEncode(timeline.tasks.take(5).map((t) => {
              'title': t.title,
              'time': t.scheduledAt != null
                  ? DateFormat('HH:mm').format(t.scheduledAt!.toLocal())
                  : '--:--',
              'color': t.color,
              'done': t.isCompleted,
            }).toList()),
      );

      await HomeWidget.updateWidget(
        name: PlatformConfig.iosWidgetName,
        androidName: PlatformConfig.androidWidgetClass,
      );
    } on PlatformException catch (e) {
      debugPrint('Widget sync skipped: ${e.message}');
    } catch (e) {
      debugPrint('Widget sync error: $e');
    }
  }
}
