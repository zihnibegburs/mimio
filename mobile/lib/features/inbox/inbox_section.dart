import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mimio/core/l10n/app_strings.dart';
import 'package:mimio/core/models/models.dart';
import 'package:mimio/core/theme/mimio_theme.dart';
import 'package:mimio/core/utils/task_icons.dart';
import 'package:mimio/features/providers.dart';
import 'package:mimio/core/widgets/mimio_soft_overlay.dart';
import 'package:mimio/features/timeline/widgets/edit_task_sheet.dart';

class InboxSection extends ConsumerWidget {
  const InboxSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inboxAsync = ref.watch(inboxProvider);
    final s = ref.watch(stringsProvider);

    return inboxAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (tasks) {
        if (tasks.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.inboxTitle, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
              Text(s.inboxHint, style: TextStyle(fontSize: 12, color: context.palette.textSecondary)),
              const SizedBox(height: 8),
              ...tasks.map((task) => _InboxTile(task: task)),
            ],
          ),
        );
      },
    );
  }
}

class _InboxTile extends ConsumerWidget {
  const _InboxTile({required this.task});

  final TaskModel task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final color = MimioColors.fromHex(task.color);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: context.palette.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.palette.border),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(TaskIcons.iconForTask(title: task.title, icon: task.icon), color: color, size: 20),
        ),
        title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: TextButton(
          onPressed: () => _schedule(context, ref),
          child: Text(s.scheduleTask),
        ),
        onTap: () => showMimioBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) => EditTaskSheet(
            task: task,
            selectedDate: DateTime.now(),
          ),
        ),
      ),
    );
  }

  Future<void> _schedule(BuildContext context, WidgetRef ref) async {
    final s = ref.read(stringsProvider);
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time == null) return;
    final now = DateTime.now();
    final scheduled = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    try {
      await ref.read(inboxProvider.notifier).scheduleTask(task.id, scheduled);
      ref.invalidate(timelineProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(s.friendlyTaskActionError(e))),
        );
      }
    }
  }
}
