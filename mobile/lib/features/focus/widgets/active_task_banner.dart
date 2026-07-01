import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mimio/core/models/models.dart';
import 'package:mimio/core/theme/mimio_theme.dart';
import 'package:mimio/features/focus/widgets/focus_timer_widget.dart';
import 'package:mimio/features/providers.dart';

class ActiveTaskBanner extends ConsumerWidget {
  const ActiveTaskBanner({super.key, required this.task});

  final TaskModel task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(focusSessionProvider);
    final color = MimioColors.fromHex(task.color);

    return GestureDetector(
      onTap: () => context.push('/focus'),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.75)]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6)),
          ],
        ),
        child: Row(
          children: [
            sessionAsync.when(
              loading: () => const SizedBox(
                width: 56,
                height: 56,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              error: (_, __) => const Icon(Icons.play_circle_filled_rounded, color: Colors.white, size: 48),
              data: (session) {
                if (session == null) {
                  return const Icon(Icons.play_circle_filled_rounded, color: Colors.white, size: 48);
                }
                return FocusTimerWidget(session: session, size: 72, showLabel: false, inverted: true);
              },
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.isActive ? 'Şu an aktif' : 'Duraklatıldı',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    task.title,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  if (sessionAsync.valueOrNull != null)
                    Text(
                      '${sessionAsync.value!.remainingFormatted} kaldı',
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white70),
          ],
        ),
      ),
    );
  }
}
