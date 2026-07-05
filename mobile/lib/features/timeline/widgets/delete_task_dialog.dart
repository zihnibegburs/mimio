import 'package:flutter/material.dart';
import 'package:mimio/core/l10n/app_strings.dart';
import 'package:mimio/core/models/models.dart';
import 'package:mimio/core/models/recurrence.dart';

Future<DeleteRecurrenceScope?> showDeleteTaskDialog({
  required BuildContext context,
  required S s,
  required TaskModel task,
}) {
  if (!task.isRecurring) {
    return showDialog<DeleteRecurrenceScope>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(s.deleteTask),
        content: Text(s.deleteTaskConfirm(task.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(s.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, DeleteRecurrenceScope.thisOccurrence),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(s.delete),
          ),
        ],
      ),
    );
  }

  return showDialog<DeleteRecurrenceScope>(
    context: context,
    builder: (dialogCtx) => AlertDialog(
      title: Text(s.deleteRecurringTask),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            s.deleteRecurringTaskPrompt(task.title),
            style: const TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 16),
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
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogCtx),
          child: Text(s.cancel),
        ),
      ],
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          alignment: Alignment.centerLeft,
          foregroundColor: destructive ? Colors.red.shade400 : null,
        ),
        child: Text(label),
      ),
    );
  }
}
