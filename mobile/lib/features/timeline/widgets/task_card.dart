import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mimio/core/l10n/app_strings.dart';
import 'package:mimio/core/models/models.dart';
import 'package:mimio/core/theme/mimio_theme.dart';
import 'package:mimio/features/providers.dart';

typedef SubtaskAction = void Function(TaskModel subtask);

class TaskCard extends ConsumerWidget {
  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onStart,
    this.onPause,
    this.onComplete,
    this.onSubtaskTap,
    this.onSubtaskStart,
    this.onSubtaskPause,
    this.onSubtaskComplete,
  });

  final TaskModel task;
  final VoidCallback? onTap;
  final VoidCallback? onStart;
  final VoidCallback? onPause;
  final VoidCallback? onComplete;
  final SubtaskAction? onSubtaskTap;
  final SubtaskAction? onSubtaskStart;
  final SubtaskAction? onSubtaskPause;
  final SubtaskAction? onSubtaskComplete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final session = ref.watch(focusSessionProvider).valueOrNull;
    final isFocused = session?.taskId == task.id;
    final isActive = isFocused && (session?.isActive ?? false);
    final isPaused = isFocused && (session?.isPaused ?? false);
    final color = MimioColors.fromHex(task.color);
    final timeFormat = DateFormat('HH:mm');
    final startTime = task.scheduledAt != null ? timeFormat.format(task.scheduledAt!.toLocal()) : '--:--';
    final endTime = task.scheduledAt != null ? timeFormat.format(task.endTime.toLocal()) : '--:--';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isActive || isPaused
            ? Border.all(color: color, width: 2)
            : Border.all(color: const Color(0xFFE8E8F0)),
        boxShadow: [
          if (isActive || isPaused)
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
                                    s.minutesShort(task.durationMinutes),
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
                                        s.stepsProgress(task.completedSubtaskCount, task.subtasks.length),
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
                              if (task.hasReward && !task.isCompleted) ...[
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.card_giftcard_rounded,
                                      size: 14,
                                      color: const Color(0xFFE6A800).withValues(alpha: 0.9),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        task.reward!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFFB8860B),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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
                            s: s,
                            focusSession: session,
                            onTap: onSubtaskTap != null ? () => onSubtaskTap!(sub) : null,
                            onStart: onSubtaskStart != null ? () => onSubtaskStart!(sub) : null,
                            onPause: onSubtaskPause != null ? () => onSubtaskPause!(sub) : null,
                            onComplete: onSubtaskComplete != null ? () => onSubtaskComplete!(sub) : null,
                          )),
                    ],
                    if ((isActive || isPaused) && !task.hasSubtasks) ...[
                      const SizedBox(height: 12),
                      _ActiveControls(
                        pauseLabel: isPaused ? s.continueLabel : s.pause,
                        finishLabel: s.finish,
                        onPause: onPause,
                        onComplete: onComplete,
                      ),
                    ] else if (!task.isCompleted && !task.hasSubtasks && !isFocused) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _ActionChip(
                            label: s.start,
                            icon: Icons.play_arrow_rounded,
                            color: color,
                            onTap: onStart,
                          ),
                          const SizedBox(width: 8),
                          _ActionChip(
                            label: s.complete,
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
    required this.s,
    this.focusSession,
    this.onTap,
    this.onStart,
    this.onPause,
    this.onComplete,
  });

  final TaskModel subtask;
  final Color parentColor;
  final S s;
  final FocusSessionModel? focusSession;
  final VoidCallback? onTap;
  final VoidCallback? onStart;
  final VoidCallback? onPause;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    final subColor = MimioColors.fromHex(subtask.color);
    final isFocused = focusSession?.taskId == subtask.id;
    final isActive = isFocused && (focusSession?.isActive ?? false);
    final isPaused = isFocused && (focusSession?.isPaused ?? false);
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
        border: isActive || isPaused ? Border.all(color: subColor, width: 1.5) : null,
      ),
      child: Row(
        children: [
          Icon(
            subtask.isCompleted
                ? Icons.check_circle_rounded
                : isActive || isPaused
                    ? Icons.play_circle_rounded
                    : Icons.circle_outlined,
            size: 18,
            color: subtask.isCompleted
                ? MimioColors.success
                : isActive || isPaused
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
                          '$timeLabel · ${s.minutesShort(subtask.durationMinutes)}',
                          style: const TextStyle(fontSize: 11, color: MimioColors.textSecondary),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (isActive || isPaused) ...[
            _MiniAction(icon: Icons.pause_rounded, color: MimioColors.warning, onTap: onPause),
            const SizedBox(width: 4),
            _MiniAction(icon: Icons.check_rounded, color: MimioColors.success, onTap: onComplete),
          ] else if (!subtask.isCompleted && !isFocused) ...[
            _MiniAction(icon: Icons.play_arrow_rounded, color: parentColor, onTap: onStart),
            const SizedBox(width: 4),
            _MiniAction(icon: Icons.check_rounded, color: MimioColors.success, onTap: onComplete),
          ],
          if (onTap != null) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onTap,
              child: Icon(Icons.more_horiz_rounded, size: 16, color: MimioColors.textSecondary.withValues(alpha: 0.5)),
            ),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(6),
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          child: Icon(icon, size: 16, color: color),
        ),
      ),
    );
  }
}

class _ActiveControls extends StatelessWidget {
  const _ActiveControls({
    required this.pauseLabel,
    required this.finishLabel,
    this.onPause,
    this.onComplete,
  });

  final String pauseLabel;
  final String finishLabel;
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
            label: Text(pauseLabel),
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
            label: Text(finishLabel),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
      ),
    );
  }
}
