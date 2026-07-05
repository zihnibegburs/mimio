import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mimio/core/l10n/app_strings.dart';
import 'package:mimio/core/models/models.dart';
import 'package:mimio/core/theme/mimio_theme.dart';

class DayProgressCard extends ConsumerWidget {
  const DayProgressCard({super.key, required this.tasks});

  final List<TaskModel> tasks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final total = tasks.length;
    final completed = tasks.where((t) => t.isCompleted).length;
    final active = tasks.where((t) => t.isActive).length;
    final progress = total == 0 ? 0.0 : completed / total;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            MimioColors.primary.withValues(alpha: 0.12),
            MimioColors.primaryLight.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: MimioColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 52,
            height: 52,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 5,
                  backgroundColor: MimioColors.primary.withValues(alpha: 0.15),
                  color: MimioColors.primary,
                ),
                Text(
                  total == 0 ? '—' : '${(progress * 100).round()}%',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  total == 0 ? s.dayEmpty : s.tasksCompleted(completed, total),
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  active > 0
                      ? s.oneTaskActive
                      : total == 0
                          ? s.addFirstTaskHint
                          : s.tasksRemaining(total - completed),
                  style: TextStyle(color: context.palette.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          if (active > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: MimioColors.success.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.play_arrow_rounded, size: 16, color: MimioColors.success),
                  Text(s.active, style: const TextStyle(color: MimioColors.success, fontWeight: FontWeight.w700, fontSize: 12)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
