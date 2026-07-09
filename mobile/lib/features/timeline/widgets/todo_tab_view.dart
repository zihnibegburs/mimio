import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mimio/core/l10n/app_strings.dart';
import 'package:mimio/core/theme/mimio_theme.dart';
import 'package:mimio/features/providers.dart';
import 'package:mimio/features/timeline/widgets/todo_item.dart';

class TodoTabView extends ConsumerStatefulWidget {
  const TodoTabView({super.key, this.addFocusNode});

  final FocusNode? addFocusNode;

  @override
  ConsumerState<TodoTabView> createState() => TodoTabViewState();
}

class TodoTabViewState extends ConsumerState<TodoTabView> {
  final _titleController = TextEditingController();
  late final FocusNode _focusNode;
  bool _adding = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.addFocusNode ?? FocusNode();
  }

  @override
  void dispose() {
    _titleController.dispose();
    if (widget.addFocusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void focusAddField() => _focusNode.requestFocus();

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _titleController,
                  focusNode: _focusNode,
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
        ),
        Expanded(
          child: inboxAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      s.friendlyTaskActionError(e),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: context.palette.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(inboxProvider),
                      child: Text(s.retry),
                    ),
                  ],
                ),
              ),
            ),
            data: (tasks) {
              if (tasks.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: MimioColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.checklist_rounded,
                            size: 36,
                            color: MimioColors.primary.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          s.emptyTodo,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          s.inboxHint,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: context.palette.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => ref.read(inboxProvider.notifier).refresh(),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) =>
                      TodoItem(task: tasks[index]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
