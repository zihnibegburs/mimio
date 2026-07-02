import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mimio/core/l10n/app_strings.dart';
import 'package:mimio/core/models/ai_models.dart';
import 'package:mimio/core/models/models.dart';
import 'package:mimio/core/repositories/ai_repository.dart';
import 'package:mimio/core/theme/mimio_theme.dart';
import 'package:mimio/features/providers.dart';

class EditTaskSheet extends ConsumerStatefulWidget {
  const EditTaskSheet({
    super.key,
    required this.task,
    required this.selectedDate,
    this.showAiBreakdown = false,
  });

  final TaskModel task;
  final DateTime selectedDate;
  final bool showAiBreakdown;

  @override
  ConsumerState<EditTaskSheet> createState() => _EditTaskSheetState();
}

class _EditTaskSheetState extends ConsumerState<EditTaskSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _rewardController;
  late int _duration;
  late String _selectedColor;
  late TimeOfDay _time;
  bool _loadingPreview = false;
  bool _submitting = false;
  bool _breakingDown = false;
  List<AiStepModel>? _previewSteps;
  String? _error;

  bool get _isSubtask => widget.task.parentTaskId != null;
  bool get _canBreakdown => widget.showAiBreakdown && !_isSubtask && !widget.task.hasSubtasks;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _rewardController = TextEditingController(text: widget.task.reward ?? '');
    _duration = widget.task.durationMinutes;
    _selectedColor = widget.task.color;
    if (widget.task.scheduledAt != null) {
      final local = widget.task.scheduledAt!.toLocal();
      _time = TimeOfDay(hour: local.hour, minute: local.minute);
    } else {
      _time = TimeOfDay.now();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _rewardController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  DateTime get _scheduledAt => DateTime(
        widget.selectedDate.year,
        widget.selectedDate.month,
        widget.selectedDate.day,
        _time.hour,
        _time.minute,
      );

  Future<void> _loadPreview() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    setState(() {
      _loadingPreview = true;
      _error = null;
      _previewSteps = null;
    });

    try {
      final result = await ref.read(aiRepositoryProvider).breakdown(title);
      if (mounted) setState(() => _previewSteps = result.steps);
    } catch (e) {
      if (mounted) setState(() => _error = _friendlyError(e));
    } finally {
      if (mounted) setState(() => _loadingPreview = false);
    }
  }

  String _friendlyError(Object e) => ref.read(stringsProvider).friendlyAiError(e);

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) return;

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      await ref.read(timelineProvider.notifier).updateTask(
            id: widget.task.id,
            title: _titleController.text.trim(),
            color: _selectedColor,
            durationMinutes: _isSubtask || !widget.task.hasSubtasks ? _duration : null,
            scheduledAt: _scheduledAt,
            reward: _isSubtask || widget.task.hasSubtasks ? null : _rewardController.text.trim(),
          );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) setState(() => _error = _friendlyError(e));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _applyBreakdown() async {
    setState(() {
      _breakingDown = true;
      _error = null;
    });

    try {
      var steps = _previewSteps;
      if (steps == null || steps.isEmpty) {
        final result = await ref.read(aiRepositoryProvider).breakdown(_titleController.text.trim());
        steps = result.steps;
      }

      await ref.read(timelineProvider.notifier).updateTask(
            id: widget.task.id,
            title: _titleController.text.trim(),
            color: _selectedColor,
            scheduledAt: _scheduledAt,
          );

      await ref.read(timelineProvider.notifier).addSubtasksToTask(
            parentId: widget.task.id,
            subtasks: steps
                .map((s) => (title: s.title, durationMinutes: s.durationMinutes, color: s.color))
                .toList(),
          );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) setState(() => _error = _friendlyError(e));
    } finally {
      if (mounted) setState(() => _breakingDown = false);
    }
  }

  Future<void> _delete() async {
    final s = ref.read(stringsProvider);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.deleteTask),
        content: Text(s.deleteTaskConfirm(widget.task.title)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(s.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(s.delete),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _submitting = true);
    try {
      await ref.read(timelineProvider.notifier).deleteTask(widget.task.id);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) setState(() => _error = _friendlyError(e));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = _submitting || _breakingDown;
    final s = ref.watch(stringsProvider);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _isSubtask ? s.editStep : s.editTask,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                  onPressed: busy ? null : _delete,
                  tooltip: s.delete,
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(hintText: s.taskNameHint),
              onChanged: (_) {
                if (_previewSteps != null) setState(() => _previewSteps = null);
              },
            ),
            if (!_isSubtask && !widget.task.hasSubtasks) ...[
              const SizedBox(height: 20),
              Text(s.rewardLabel, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 4),
              Text(
                s.rewardOptionalHint,
                style: const TextStyle(fontSize: 12, color: MimioColors.textSecondary),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _rewardController,
                decoration: InputDecoration(
                  hintText: s.rewardHint,
                  prefixIcon: const Icon(Icons.card_giftcard_rounded, color: MimioColors.primary),
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
            ],
            if (!_isSubtask && !widget.task.hasSubtasks) ...[
              const SizedBox(height: 20),
              Text(s.duration, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [15, 30, 45, 60, 90].map((min) {
                  final selected = _duration == min;
                  return ChoiceChip(
                    label: Text(s.minutesShort(min)),
                    selected: selected,
                    onSelected: (_) => setState(() => _duration = min),
                    selectedColor: MimioColors.primary.withValues(alpha: 0.2),
                  );
                }).toList(),
              ),
            ] else if (_isSubtask) ...[
              const SizedBox(height: 20),
              Text(s.duration, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [5, 10, 15, 20, 30, 45].map((min) {
                  final selected = _duration == min;
                  return ChoiceChip(
                    label: Text(s.minutesShort(min)),
                    selected: selected,
                    onSelected: (_) => setState(() => _duration = min),
                    selectedColor: MimioColors.primary.withValues(alpha: 0.2),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 20),
            Text(s.time, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickTime,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE8E8F0)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time_rounded, color: MimioColors.primary),
                    const SizedBox(width: 12),
                    Text(
                      _time.format(context),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(s.color, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: MimioColors.taskColors.map((hex) {
                final color = MimioColors.fromHex(hex);
                final selected = _selectedColor == hex;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = hex),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: selected ? Border.all(color: MimioColors.textPrimary, width: 3) : null,
                    ),
                    child: selected ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
                  ),
                );
              }).toList(),
            ),
            if (_canBreakdown) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.auto_awesome_rounded, color: MimioColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    s.aiBreakdown,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                s.aiBreakdownHint,
                style: const TextStyle(fontSize: 13, color: MimioColors.textSecondary),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _loadingPreview || _titleController.text.trim().isEmpty ? null : _loadPreview,
                  icon: _loadingPreview
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.visibility_rounded, size: 18),
                  label: Text(_loadingPreview ? s.aiThinking : s.previewSteps),
                ),
              ),
              if (_previewSteps != null) ...[
                const SizedBox(height: 12),
                ..._previewSteps!.asMap().entries.map((e) => Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: MimioColors.fromHex(e.value.color).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Text(
                            '${e.key + 1}.',
                            style: const TextStyle(fontWeight: FontWeight.w700, color: MimioColors.textSecondary),
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(e.value.title, style: const TextStyle(fontWeight: FontWeight.w600))),
                          Text(
                            s.minutesShort(e.value.durationMinutes),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: MimioColors.fromHex(e.value.color),
                            ),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: busy ? null : _applyBreakdown,
                    icon: _breakingDown
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.auto_awesome_rounded, size: 18),
                    label: Text(_breakingDown ? s.applyingSteps : s.applySteps),
                  ),
                ),
              ],
            ],
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!, style: TextStyle(color: Colors.red.shade700, fontSize: 13)),
            ],
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: busy ? null : _save,
                child: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(s.save),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
