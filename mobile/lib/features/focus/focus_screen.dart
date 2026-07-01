import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mimio/core/theme/mimio_theme.dart';
import 'package:mimio/features/focus/widgets/focus_timer_widget.dart';
import 'package:mimio/features/providers.dart';

class FocusScreen extends ConsumerWidget {
  const FocusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(focusSessionProvider);
    final color = sessionAsync.valueOrNull != null
        ? MimioColors.fromHex(sessionAsync.value!.color)
        : MimioColors.primary;

    return Scaffold(
      backgroundColor: MimioColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Odak Modu'),
      ),
      body: sessionAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
        data: (session) {
          if (session == null) {
            return const Center(
              child: Text('Aktif görev yok', style: TextStyle(color: MimioColors.textSecondary)),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(),
                FocusTimerWidget(session: session, size: 260),
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
                  '${session.durationMinutes} dakikalık görev',
                  style: const TextStyle(color: MimioColors.textSecondary),
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: session.isActive
                            ? () async {
                                await ref.read(timelineProvider.notifier).pauseTask(session.taskId);
                                ref.invalidate(focusSessionProvider);
                              }
                            : () async {
                                await ref.read(timelineProvider.notifier).startTask(session.taskId);
                                ref.invalidate(focusSessionProvider);
                              },
                        icon: Icon(session.isActive ? Icons.pause_rounded : Icons.play_arrow_rounded),
                        label: Text(session.isActive ? 'Duraklat' : 'Devam Et'),
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
                          await ref.read(timelineProvider.notifier).completeTask(session.taskId);
                          ref.read(celebrationTriggerProvider.notifier).state = true;
                          if (context.mounted) context.pop();
                        },
                        icon: const Icon(Icons.check_rounded),
                        label: const Text('Tamamla'),
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
