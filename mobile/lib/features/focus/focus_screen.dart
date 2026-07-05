import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mimio/core/l10n/app_strings.dart';
import 'package:mimio/core/theme/mimio_theme.dart';
import 'package:mimio/features/focus/widgets/focus_timer_widget.dart';
import 'package:mimio/features/focus/widgets/celebration_dialog.dart';
import 'package:mimio/features/providers.dart';

class FocusScreen extends ConsumerWidget {
  const FocusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(focusSessionProvider);
    final s = ref.watch(stringsProvider);
    final color = sessionAsync.valueOrNull != null
        ? MimioColors.fromHex(sessionAsync.value!.color)
        : MimioColors.primary;

    return Scaffold(
      backgroundColor: context.palette.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(s.focusMode),
      ),
      body: sessionAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(s.errorPrefix(e))),
        data: (session) {
          if (session == null) {
            return Center(
              child: Text(s.noActiveTask, style: TextStyle(color: context.palette.textSecondary)),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(),
                FocusTimerWidget(session: session, size: 260, interactive: true),
                const SizedBox(height: 32),
                Text(
                  session.title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  s.durationTask(session.durationMinutes),
                  style: TextStyle(color: context.palette.textSecondary),
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: session.isActive
                            ? () async {
                                final s = ref.read(stringsProvider);
                                try {
                                  await ref.read(timelineProvider.notifier).pauseTask(session.taskId);
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(s.friendlyTaskActionError(e)),
                                        backgroundColor: Colors.red.shade400,
                                      ),
                                    );
                                  }
                                }
                              }
                            : () async {
                                final s = ref.read(stringsProvider);
                                try {
                                  await ref.read(timelineProvider.notifier).resumeTask(session.taskId);
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(s.friendlyTaskActionError(e)),
                                        backgroundColor: Colors.red.shade400,
                                      ),
                                    );
                                  }
                                }
                              },
                        icon: Icon(session.isActive ? Icons.pause_rounded : Icons.play_arrow_rounded),
                        label: Text(session.isActive ? s.pause : s.resume),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: color),
                          foregroundColor: color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final s = ref.read(stringsProvider);
                          final taskId = session.taskId;
                          try {
                            final completed = await ref.read(timelineProvider.notifier).completeTask(taskId);
                            if (!context.mounted) return;
                            if (completed.hasReward) {
                              await showTaskCelebration(ref, completed, context);
                            }
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(s.taskCompletedUndo),
                                duration: const Duration(seconds: 5),
                                action: SnackBarAction(
                                  label: s.undo,
                                  onPressed: () async {
                                    try {
                                      await ref.read(timelineProvider.notifier).uncompleteTask(taskId);
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(s.friendlyTaskActionError(e)),
                                            backgroundColor: Colors.red.shade400,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                ),
                              ),
                            );
                            if (context.mounted) context.pop();
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(s.friendlyTaskActionError(e)),
                                  backgroundColor: Colors.red.shade400,
                                ),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.check_rounded),
                        label: Text(s.complete),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MimioColors.success,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
