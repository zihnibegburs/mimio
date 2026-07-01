import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mimio/core/models/ai_models.dart';
import 'package:mimio/core/repositories/ai_repository.dart';
import 'package:mimio/core/theme/mimio_theme.dart';
import 'package:mimio/features/providers.dart';

class AddTaskSheet extends ConsumerStatefulWidget {
  const AddTaskSheet({super.key, required this.selectedDate});

  final DateTime selectedDate;

  @override
  ConsumerState<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends ConsumerState<AddTaskSheet> {
  final _titleController = TextEditingController();
  int _duration = 30;
  String _selectedColor = MimioColors.taskColors.first;
  TimeOfDay _time = TimeOfDay.now();
  bool _splitIntoSubtasks = false;
  List<AiStepModel>? _previewSteps;
  bool _loadingPreview = false;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _titleController.dispose();
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
        setState(() => _error = _friendlyError(e));
      }
    } finally {
      if (mounted) setState(() => _loadingPreview = false);
    }
  }

  String _friendlyError(Object e) {
    if (e is DioException) {
      final status = e.response?.statusCode;
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        return data['message'] as String;
      }
      if (status == 401) return 'Oturum süresi doldu. Tekrar giriş yapın.';
      if (status == 403) {
        return 'AI isteği reddedildi. Backend\'i yeniden başlatın (./gradlew bootRun).';
      }
    }
    final msg = e.toString();
    if (msg.contains('Ollama')) return 'Ollama çalışmıyor. Terminalde: ollama serve';
    return msg.replaceFirst('Exception: ', '');
  }

  Future<void> _submit() async {
    if (_titleController.text.trim().isEmpty) return;

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
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
        await ref.read(timelineProvider.notifier).createTask(
              title: _titleController.text.trim(),
              durationMinutes: _duration,
              color: _selectedColor,
              scheduledAt: _scheduledAt,
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
              'Yeni Görev',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Görev adı...'),
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
                title: const Text('Adımlara böl', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text(
                  'AI görevi küçük adımlara ayırır',
                  style: TextStyle(fontSize: 12, color: MimioColors.textSecondary),
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
                  label: Text(_loadingPreview ? 'AI düşünüyor...' : 'Adımları Önizle'),
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
                            '${e.value.durationMinutes} dk',
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
              Text('Süre', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [15, 30, 45, 60, 90].map((min) {
                  final selected = _duration == min;
                  return ChoiceChip(
                    label: Text('$min dk'),
                    selected: selected,
                    onSelected: (_) => setState(() => _duration = min),
                    selectedColor: MimioColors.primary.withValues(alpha: 0.2),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 20),
            Text('Saat', style: Theme.of(context).textTheme.labelLarge),
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
            Text('Renk', style: Theme.of(context).textTheme.labelLarge),
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
                    : Text(_splitIntoSubtasks ? 'Görev ve Adımları Ekle' : 'Görevi Ekle'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
