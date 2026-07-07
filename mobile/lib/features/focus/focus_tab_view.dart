import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mimio/core/l10n/app_strings.dart';
import 'package:mimio/core/models/models.dart';
import 'package:mimio/core/theme/mimio_theme.dart';
import 'package:mimio/features/focus/focus_session_actions.dart';
import 'package:mimio/features/focus/widgets/focus_timer_widget.dart';
import 'package:mimio/features/focus/widgets/body_doubling_panel.dart';
import 'package:mimio/features/focus/widgets/start_focus_sheet.dart';
import 'package:mimio/features/providers.dart';

class FocusTabView extends ConsumerWidget {
  const FocusTabView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(focusSessionProvider);
    final timeline = ref.watch(timelineProvider).valueOrNull;
    final s = ref.watch(stringsProvider);

    return sessionAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(s.errorPrefix(e))),
      data: (session) {
        if (session == null) {
          return _NoActiveFocus(tasks: timeline?.tasks ?? [], s: s);
        }

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const BodyDoublingPanel(),
              const SizedBox(height: 8),
              FocusTimerWidget(session: session, size: 260, interactive: true),
              const SizedBox(height: 24),
              Text(
                session.title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                session.isPaused ? s.paused : s.focusModeOn,
                style: TextStyle(color: context.palette.textSecondary),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => toggleFocusPause(context, ref, session),
                      icon: Icon(session.isActive ? Icons.pause_rounded : Icons.play_arrow_rounded),
                      label: Text(session.isActive ? s.pause : s.continueLabel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => finishFocusSession(context, ref, session),
                      icon: const Icon(Icons.check_rounded),
                      label: Text(s.finish),
                      style: ElevatedButton.styleFrom(backgroundColor: MimioColors.success),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NoActiveFocus extends ConsumerWidget {
  const _NoActiveFocus({required this.tasks, required this.s});

  final List<TaskModel> tasks;
  final S s;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeId = ref.watch(focusSessionProvider).valueOrNull?.taskId;
    final pending = tasks.where((t) => !t.isCompleted && t.id != activeId).toList();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.self_improvement_rounded, size: 72, color: MimioColors.primary.withValues(alpha: 0.4)),
            const SizedBox(height: 24),
            Text(
              s.focusModeOff,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              s.focusModeHint,
              textAlign: TextAlign.center,
              style: TextStyle(color: context.palette.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => showStartFocusSheet(context, ref),
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(s.startFocus),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
            ),
            if (pending.isNotEmpty) ...[
              const SizedBox(height: 32),
              Text(s.quickStart, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 12),
              ...pending.take(3).map((task) {
                final color = MimioColors.fromHex(task.color);
                return ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  tileColor: context.palette.surface,
                  leading: CircleAvatar(
                    backgroundColor: color.withValues(alpha: 0.2),
                    child: Icon(Icons.play_arrow_rounded, color: color),
                  ),
                  title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => startTaskAndOpenFocus(context, ref, task.id),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}
