import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mimio/core/l10n/app_strings.dart';
import 'package:mimio/core/models/ai_models.dart';
import 'package:mimio/core/models/recurrence.dart';
import 'package:mimio/core/platform/notification_service.dart';
import 'package:mimio/core/repositories/ai_repository.dart';
import 'package:mimio/core/theme/mimio_theme.dart';
import 'package:mimio/features/providers.dart';
import 'package:mimio/features/timeline/widgets/recurrence_picker.dart';

class AddTaskSheet extends ConsumerStatefulWidget {
  const AddTaskSheet({super.key, required this.selectedDate});

  final DateTime selectedDate;

  @override
  ConsumerState<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends ConsumerState<AddTaskSheet> {
  final _titleController = TextEditingController();
  final _rewardController = TextEditingController();
  bool _useAiDuration = true;
  int _duration = 30;
  String _selectedColor = MimioColors.taskColors.first;
  TimeOfDay _time = TimeOfDay.now();
  RecurrenceSelection _recurrence = const RecurrenceSelection();
  bool _splitIntoSubtasks = false;
  bool _remind10Min = false;
  bool _remind1Min = false;
  List<AiStepModel>? _previewSteps;
  bool _loadingPreview = false;
  bool _submitting = false;
  String? _error;

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
      if (mounted) {
        setState(() => _previewSteps = result.steps);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = ref.read(stringsProvider).friendlyAiError(e, includeBootRunHint: true));
      }
    } finally {
      if (mounted) setState(() => _loadingPreview = false);
    }
  }

  String _friendlyError(Object e) => ref.read(stringsProvider).friendlyAiError(e, includeBootRunHint: true);

  Future<void> _submit() async {
    if (_titleController.text.trim().isEmpty || _submitting) return;

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final reminders = TaskReminderSettings(remind10Min: _remind10Min, remind1Min: _remind1Min);
      if (_splitIntoSubtasks) {
        var steps = _previewSteps;
        if (steps == null || steps.isEmpty) {
          final result = await ref.read(aiRepositoryProvider).breakdown(_titleController.text.trim());
          steps = result.steps;
        }

        await ref.read(timelineProvider.notifier).createTaskWithSubtasks(
              title: _titleController.text.trim(),
              scheduledAt: _scheduledAt,
              color: _selectedColor,
              subtasks: steps
                  .map((s) => (title: s.title, durationMinutes: s.durationMinutes, color: s.color))
                  .toList(),
            );
      } else {
        var duration = _duration;
        if (_useAiDuration) {
          final result = await ref.read(aiRepositoryProvider).breakdown(_titleController.text.trim());
          duration = result.steps.fold<int>(0, (sum, step) => sum + step.durationMinutes);
          if (duration <= 0) duration = 30;
        }

        await ref.read(timelineProvider.notifier).createTask(
              title: _titleController.text.trim(),
              durationMinutes: duration,
              color: _selectedColor,
              scheduledAt: _scheduledAt,
              recurrence: _recurrence,
              reward: _rewardController.text.trim().isEmpty ? null : _rewardController.text.trim(),
              reminders: reminders,
            );
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) setState(() => _error = _friendlyError(e));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
            Text(
              s.newTask,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              autofocus: true,
              decoration: InputDecoration(hintText: s.taskNameHint),
              onChanged: (_) {
                if (_previewSteps != null) {
                  setState(() => _previewSteps = null);
                }
              },
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE8E8F0)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: SwitchListTile(
                title: Text(s.splitIntoSteps, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                  s.splitIntoStepsHint,
                  style: const TextStyle(fontSize: 12, color: MimioColors.textSecondary),
                ),
                secondary: const Icon(Icons.auto_awesome_rounded, color: MimioColors.primary),
                value: _splitIntoSubtasks,
                onChanged: (v) => setState(() {
                  _splitIntoSubtasks = v;
                  if (!v) _previewSteps = null;
                }),
              ),
            ),
            if (_splitIntoSubtasks) ...[
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
              ],
            ],
            if (!_splitIntoSubtasks) ...[
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
            if (!_splitIntoSubtasks) ...[
              const SizedBox(height: 20),
              Text(s.duration, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    avatar: const Icon(Icons.auto_awesome_rounded, size: 16),
                    label: Text(s.aiDuration),
                    selected: _useAiDuration,
                    onSelected: (_) => setState(() => _useAiDuration = true),
                    selectedColor: MimioColors.primary.withValues(alpha: 0.2),
                  ),
                  ...[15, 30, 45, 60, 90].map((min) {
                    final selected = !_useAiDuration && _duration == min;
                    return ChoiceChip(
                      label: Text(s.minutesShort(min)),
                      selected: selected,
                      onSelected: (_) => setState(() {
                        _useAiDuration = false;
                        _duration = min;
                      }),
                      selectedColor: MimioColors.primary.withValues(alpha: 0.2),
                    );
                  }),
                ],
              ),
            ],
            if (!_splitIntoSubtasks) ...[
              const SizedBox(height: 16),
              Text(s.taskReminders, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(s.remind10Min, style: const TextStyle(fontWeight: FontWeight.w600)),
                value: _remind10Min,
                onChanged: (v) => setState(() => _remind10Min = v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(s.remind1Min, style: const TextStyle(fontWeight: FontWeight.w600)),
                value: _remind1Min,
                onChanged: (v) => setState(() => _remind1Min = v),
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
            if (!_splitIntoSubtasks) ...[
              const SizedBox(height: 20),
              RecurrencePicker(
                value: _recurrence,
                onChanged: (value) => setState(() => _recurrence = value),
              ),
            ],
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
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!, style: TextStyle(color: Colors.red.shade700, fontSize: 13)),
            ],
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(_splitIntoSubtasks ? s.addTaskAndSteps : s.addTaskButton),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
