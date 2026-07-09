import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mimio/core/l10n/app_strings.dart';
import 'package:mimio/core/theme/mimio_theme.dart';
import 'package:mimio/core/widgets/liquid_glass.dart';
import 'package:mimio/features/providers.dart';
import 'package:mimio/features/timeline/widgets/todo_item.dart';

class TodoSheet extends ConsumerStatefulWidget {
  const TodoSheet({super.key});

  @override
  ConsumerState<TodoSheet> createState() => _TodoSheetState();
}

class _TodoSheetState extends ConsumerState<TodoSheet> {
  final _titleController = TextEditingController();
  bool _adding = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _addInboxTask() async {
    if (_adding || _titleController.text.trim().isEmpty) return;
    setState(() => _adding = true);
    final s = ref.read(stringsProvider);

    try {
      await ref
          .read(inboxProvider.notifier)
          .addToInbox(title: _titleController.text.trim());
      _titleController.clear();
      if (mounted) setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(s.friendlyTaskActionError(e))));
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final inboxAsync = ref.watch(inboxProvider);
    final maxHeight = MediaQuery.sizeOf(context).height * 0.78;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: LiquidGlass(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        blur: true,
        blurSigma: LiquidGlassTokens.blurSigmaChrome,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: SafeArea(
          top: false,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                const SizedBox(height: 14),
                Text(
                  s.inboxTitle,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                Text(
                  s.inboxHint,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.palette.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _titleController,
                        decoration: InputDecoration(hintText: s.taskNameHint),
                        onChanged: (_) => setState(() {}),
                        onSubmitted: (_) => _addInboxTask(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _adding || _titleController.text.trim().isEmpty
                          ? null
                          : _addInboxTask,
                      child: _adding
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.add_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: inboxAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (e, _) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        s.friendlyTaskActionError(e),
                        style: TextStyle(color: context.palette.textSecondary),
                      ),
                    ),
                    data: (tasks) {
                      if (tasks.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Text(
                            s.emptyTodo,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: context.palette.textSecondary,
                            ),
                          ),
                        );
                      }
                      return ListView.builder(
                        itemCount: tasks.length,
                        itemBuilder: (context, index) =>
                            TodoItem(task: tasks[index]),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
