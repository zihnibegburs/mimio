import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mimio/core/models/models.dart';
import 'package:mimio/core/theme/mimio_theme.dart';

typedef SubtaskAction = void Function(TaskModel subtask);

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    this.onStart,
    this.onPause,
    this.onComplete,
    this.onDelete,
    this.onSubtaskStart,
    this.onSubtaskPause,
    this.onSubtaskComplete,
  });

  final TaskModel task;
  final VoidCallback? onStart;
  final VoidCallback? onPause;
  final VoidCallback? onComplete;
  final VoidCallback? onDelete;
  final SubtaskAction? onSubtaskStart;
  final SubtaskAction? onSubtaskPause;
  final SubtaskAction? onSubtaskComplete;

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
                    if (task.hasSubtasks) ...[
                      const SizedBox(height: 12),
                      ...task.subtasks.map((sub) => _SubtaskRow(
                            subtask: sub,
                            parentColor: color,
                            onStart: onSubtaskStart != null ? () => onSubtaskStart!(sub) : null,
                            onPause: onSubtaskPause != null ? () => onSubtaskPause!(sub) : null,
                            onComplete: onSubtaskComplete != null ? () => onSubtaskComplete!(sub) : null,
                          )),
                    ],
                    if (!task.hasSubtasks && task.isActive) ...[
                      const SizedBox(height: 12),
                      _ActiveControls(
                        onPause: onPause,
                        onComplete: onComplete,
                      ),
                    ] else if (!task.hasSubtasks && !task.isCompleted) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _ActionChip(
                            label: 'Başlat',
                            icon: Icons.play_arrow_rounded,
                            color: color,
                            onTap: onStart,
                          ),
                          const SizedBox(width: 8),
                          _ActionChip(
                            label: 'Tamamla',
                            icon: Icons.check_rounded,
                            color: MimioColors.success,
                            onTap: onComplete,
                          ),
                        ],
                      ),
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
    this.onStart,
    this.onPause,
    this.onComplete,
  });

  final TaskModel subtask;
  final Color parentColor;
  final VoidCallback? onStart;
  final VoidCallback? onPause;
  final VoidCallback? onComplete;

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
          if (subtask.isActive) ...[
            _MiniAction(icon: Icons.pause_rounded, color: MimioColors.warning, onTap: onPause),
            const SizedBox(width: 4),
            _MiniAction(icon: Icons.check_rounded, color: MimioColors.success, onTap: onComplete),
          ] else if (!subtask.isCompleted) ...[
            _MiniAction(icon: Icons.play_arrow_rounded, color: parentColor, onTap: onStart),
            const SizedBox(width: 4),
            _MiniAction(icon: Icons.check_rounded, color: MimioColors.success, onTap: onComplete),
          ],
        ],
      ),
    );
  }
}

class _MiniAction extends StatelessWidget {
  const _MiniAction({required this.icon, required this.color, this.onTap});

  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}

class _ActiveControls extends StatelessWidget {
  const _ActiveControls({this.onPause, this.onComplete});

  final VoidCallback? onPause;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onPause,
            icon: const Icon(Icons.pause_rounded, size: 18),
            label: const Text('Duraklat'),
            style: ElevatedButton.styleFrom(
              backgroundColor: MimioColors.warning,
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onComplete,
            icon: const Icon(Icons.check_rounded, size: 18),
            label: const Text('Bitir'),
            style: ElevatedButton.styleFrom(
              backgroundColor: MimioColors.success,
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.label,
    required this.icon,
    required this.color,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}
