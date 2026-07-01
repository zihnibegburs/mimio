import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mimio/core/models/models.dart';
import 'package:mimio/core/theme/mimio_theme.dart';
import 'package:mimio/features/focus/widgets/focus_timer_widget.dart';
import 'package:mimio/features/providers.dart';
import 'package:mimio/features/timeline/home_tab.dart';

class FocusTabView extends ConsumerWidget {
  const FocusTabView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(focusSessionProvider);
    final timeline = ref.watch(timelineProvider).valueOrNull;

    return sessionAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Hata: $e')),
      data: (session) {
        if (session == null) {
          return _NoActiveFocus(tasks: timeline?.tasks ?? []);
        }

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              FocusTimerWidget(session: session, size: 260),
              const SizedBox(height: 24),
              Text(
                session.title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                session.isPaused ? 'Duraklatıldı' : 'Odak modundasın — devam et!',
                style: const TextStyle(color: MimioColors.textSecondary),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        if (session.isActive) {
                          await ref.read(timelineProvider.notifier).pauseTask(session.taskId);
                        } else {
                          await ref.read(timelineProvider.notifier).startTask(session.taskId);
                        }
                        ref.invalidate(focusSessionProvider);
                      },
                      icon: Icon(session.isActive ? Icons.pause_rounded : Icons.play_arrow_rounded),
                      label: Text(session.isActive ? 'Duraklat' : 'Devam'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await ref.read(timelineProvider.notifier).completeTask(session.taskId);
                        ref.read(celebrationTriggerProvider.notifier).state = true;
                      },
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Bitir'),
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
  const _NoActiveFocus({required this.tasks});

  final List<TaskModel> tasks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = tasks.where((t) => !t.isCompleted && !t.isActive).toList();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.self_improvement_rounded, size: 72, color: MimioColors.primary.withValues(alpha: 0.4)),
            const SizedBox(height: 24),
            Text(
              'Odak modu kapalı',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Bir görevi başlattığında zamanlayıcı burada görünür.\nWidget ile kilit ekranından da takip edebilirsin.',
              textAlign: TextAlign.center,
              style: TextStyle(color: MimioColors.textSecondary, height: 1.5),
            ),
            if (pending.isNotEmpty) ...[
              const SizedBox(height: 32),
              Text('Hızlı başlat', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 12),
              ...pending.take(3).map((task) {
                final color = MimioColors.fromHex(task.color);
                return ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  tileColor: Colors.white,
                  leading: CircleAvatar(
                    backgroundColor: color.withValues(alpha: 0.2),
                    child: Icon(Icons.play_arrow_rounded, color: color),
                  ),
                  title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () async {
                    await ref.read(timelineProvider.notifier).startTask(task.id);
                    ref.read(homeTabProvider.notifier).state = HomeTab.focus;
                    ref.invalidate(focusSessionProvider);
                  },
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}
