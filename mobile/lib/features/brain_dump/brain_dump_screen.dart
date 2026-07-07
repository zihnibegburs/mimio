import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mimio/core/l10n/app_strings.dart';
import 'package:mimio/core/models/ai_models.dart';
import 'package:mimio/core/repositories/ai_repository.dart';
import 'package:mimio/core/theme/mimio_theme.dart';
import 'package:mimio/core/utils/task_icons.dart';
import 'package:mimio/core/widgets/speech_text_field.dart';
import 'package:mimio/features/providers.dart';

class BrainDumpScreen extends ConsumerStatefulWidget {
  const BrainDumpScreen({super.key});

  @override
  ConsumerState<BrainDumpScreen> createState() => _BrainDumpScreenState();
}

class _BrainDumpScreenState extends ConsumerState<BrainDumpScreen> {
  final _controller = TextEditingController();
  bool _loading = false;
  bool _applying = false;
  AiPlanModel? _plan;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _organize() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
      _plan = null;
    });

    try {
      final date = ref.read(selectedDateProvider);
      final result = await ref.read(aiRepositoryProvider).plan(
            'Organize this brain dump into a realistic daily schedule with breaks:\n$text',
            date: date,
          );
      setState(() => _plan = result);
    } catch (e) {
      setState(() => _error = ref.read(stringsProvider).friendlyAiError(e));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _apply() async {
    if (_plan == null || _applying) return;
    setState(() => _applying = true);
    try {
      for (final task in _plan!.tasks) {
        await ref.read(timelineProvider.notifier).createTask(
              title: task.title,
              durationMinutes: task.durationMinutes,
              color: task.color,
              icon: TaskIcons.inferName(task.title),
              scheduledAt: task.scheduledAt(_plan!.date),
            );
      }
      if (mounted) context.pop();
    } catch (e) {
      setState(() => _error = ref.read(stringsProvider).friendlyAiError(e));
    } finally {
      if (mounted) setState(() => _applying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);

    return Scaffold(
      backgroundColor: context.palette.background,
      appBar: AppBar(
        title: Text(s.brainDump),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(s.brainDumpHint, style: TextStyle(color: context.palette.textSecondary)),
          const SizedBox(height: 16),
          SpeechTextField(
            controller: _controller,
            maxLines: 8,
            decoration: InputDecoration(hintText: s.brainDumpHint),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _loading ? null : _organize,
              icon: _loading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.auto_awesome_rounded),
              label: Text(s.aiPlanner),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: Colors.red.shade700)),
          ],
          if (_plan != null) ...[
            const SizedBox(height: 24),
            ..._plan!.tasks.map((t) => ListTile(
                  title: Text(t.title),
                  trailing: Text('${t.durationMinutes}m'),
                )),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _applying ? null : _apply,
              child: Text(_applying ? s.saving : s.applySteps),
            ),
          ],
        ],
      ),
    );
  }
}
