import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mimio/core/models/models.dart';
import 'package:mimio/core/theme/mimio_theme.dart';

typedef SubtaskAction = void Function(TaskModel subtask);

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onSubtaskTap,
  });

  final TaskModel task;
  final VoidCallback? onTap;
  final SubtaskAction? onSubtaskTap;

  @override
  Widget build(BuildContext context) {
    final color = MimioColors.fromHex(task.color);
    final timeFormat = DateFormat('HH:mm');
    final startTime = task.scheduledAt != null ? timeFormat.format(task.scheduledAt!.toLocal()) : '--:--';
    final endTime = task.scheduledAt != null ? timeFormat.format(task.endTime.toLocal()) : '--:--';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: task.isActive
            ? Border.all(color: color, width: 2)
            : Border.all(color: const Color(0xFFE8E8F0)),
        boxShadow: [
          if (task.isActive)
            BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 6,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onTap,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '$startTime – $endTime',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: color,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${task.durationMinutes} dk',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: MimioColors.textSecondary,
                                    ),
                                  ),
                                  if (task.hasSubtasks) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: MimioColors.primary.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '${task.completedSubtaskCount}/${task.subtasks.length} adım',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: MimioColors.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                  const Spacer(),
                                  if (task.isCompleted)
                                    Icon(Icons.check_circle_rounded, color: MimioColors.success, size: 20),
                                  if (onTap != null)
                                    Icon(Icons.more_horiz_rounded, size: 18, color: MimioColors.textSecondary.withValues(alpha: 0.6)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                task.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: task.isCompleted ? MimioColors.textSecondary : MimioColors.textPrimary,
                                  decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (task.hasSubtasks) ...[
                      const SizedBox(height: 12),
                      ...task.subtasks.map((sub) => _SubtaskRow(
                            subtask: sub,
                            parentColor: color,
                            onTap: onSubtaskTap != null ? () => onSubtaskTap!(sub) : null,
                          )),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubtaskRow extends StatelessWidget {
  const _SubtaskRow({
    required this.subtask,
    required this.parentColor,
    this.onTap,
  });

  final TaskModel subtask;
  final Color parentColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final subColor = MimioColors.fromHex(subtask.color);
    final timeFormat = DateFormat('HH:mm');
    final timeLabel = subtask.scheduledAt != null
        ? timeFormat.format(subtask.scheduledAt!.toLocal())
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8FC),
        borderRadius: BorderRadius.circular(12),
        border: subtask.isActive ? Border.all(color: subColor, width: 1.5) : null,
      ),
      child: Row(
        children: [
          Icon(
            subtask.isCompleted
                ? Icons.check_circle_rounded
                : subtask.isActive
                    ? Icons.play_circle_rounded
                    : Icons.circle_outlined,
            size: 18,
            color: subtask.isCompleted
                ? MimioColors.success
                : subtask.isActive
                    ? subColor
                    : MimioColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subtask.title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          decoration: subtask.isCompleted ? TextDecoration.lineThrough : null,
                          color: subtask.isCompleted ? MimioColors.textSecondary : MimioColors.textPrimary,
                        ),
                      ),
                      if (timeLabel.isNotEmpty)
                        Text(
                          '$timeLabel · ${subtask.durationMinutes} dk',
                          style: const TextStyle(fontSize: 11, color: MimioColors.textSecondary),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (onTap != null)
            Icon(Icons.more_horiz_rounded, size: 16, color: MimioColors.textSecondary.withValues(alpha: 0.5)),
        ],
      ),
    );
  }
}

