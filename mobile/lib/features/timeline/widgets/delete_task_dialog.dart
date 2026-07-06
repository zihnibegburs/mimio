import 'package:flutter/material.dart';
import 'package:mimio/core/l10n/app_strings.dart';
import 'package:mimio/core/models/models.dart';
import 'package:mimio/core/models/recurrence.dart';
import 'package:mimio/core/theme/mimio_theme.dart';
import 'package:mimio/core/widgets/mimio_soft_overlay.dart';

Future<DeleteRecurrenceScope?> showDeleteTaskDialog({
  required BuildContext context,
  required S s,
  required TaskModel task,
}) {
  if (!task.isRecurring) {
    return showMimioSoftDialog<DeleteRecurrenceScope>(
      context: context,
      builder: (dialogCtx) => MimioSoftCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              s.deleteTask,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: dialogCtx.palette.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              s.deleteTaskConfirm(task.title),
              style: TextStyle(
                fontSize: 13,
                height: 1.35,
                color: dialogCtx.palette.textPrimary,
              ),
            ),
            const SizedBox(height: 14),
            MimioSoftDialogActions(
              actions: [
                MimioSoftTextButton(
                  label: s.cancel,
                  onPressed: () => Navigator.pop(dialogCtx),
                ),
                MimioSoftTextButton(
                  label: s.delete,
                  destructive: true,
                  onPressed: () =>
                      Navigator.pop(dialogCtx, DeleteRecurrenceScope.thisOccurrence),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  return showMimioSoftDialog<DeleteRecurrenceScope>(
    context: context,
    maxWidth: 320,
    builder: (dialogCtx) => MimioSoftCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            s.deleteRecurringTask,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: dialogCtx.palette.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            s.deleteRecurringTaskPrompt(task.title),
            style: TextStyle(
              fontSize: 13,
              height: 1.35,
              color: dialogCtx.palette.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          _ScopeOption(
            label: s.deleteRecurringThis,
            onTap: () => Navigator.pop(dialogCtx, DeleteRecurrenceScope.thisOccurrence),
          ),
          _ScopeOption(
            label: s.deleteRecurringFuture,
            onTap: () => Navigator.pop(dialogCtx, DeleteRecurrenceScope.future),
          ),
          _ScopeOption(
            label: s.deleteRecurringAll,
            destructive: true,
            onTap: () => Navigator.pop(dialogCtx, DeleteRecurrenceScope.all),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: MimioSoftTextButton(
              label: s.cancel,
              onPressed: () => Navigator.pop(dialogCtx),
            ),
          ),
        ],
      ),
    ),
  );
}

class _ScopeOption extends StatelessWidget {
  const _ScopeOption({
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: destructive
                  ? MimioColors.accent.withValues(alpha: 0.9)
                  : context.palette.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
