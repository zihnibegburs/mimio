import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mimio/core/l10n/app_strings.dart';
import 'package:mimio/core/models/models.dart';
import 'package:mimio/core/theme/mimio_theme.dart';
import 'package:mimio/features/focus/focus_tab_view.dart';
import 'package:mimio/features/focus/widgets/active_task_banner.dart';
import 'package:mimio/features/focus/widgets/celebration_overlay.dart';
import 'package:mimio/features/providers.dart';
import 'package:mimio/features/timeline/home_tab.dart';
import 'package:mimio/features/timeline/widgets/add_task_sheet.dart';
import 'package:mimio/features/timeline/widgets/day_progress_card.dart';
import 'package:mimio/features/timeline/widgets/task_action_sheet.dart';
import 'package:mimio/features/timeline/widgets/task_card.dart';
import 'package:mimio/features/timeline/widgets/timeline_hour_grid.dart';
import 'package:mimio/features/timeline/widgets/week_strip.dart';
import 'package:mimio/features/web/weekly_view.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(homeTabProvider);
    final celebration = ref.watch(celebrationTriggerProvider);
    final auth = ref.watch(authStateProvider).value;
    final selectedDate = ref.watch(selectedDateProvider);
    final s = ref.watch(stringsProvider);

    return CelebrationOverlay(
      trigger: celebration,
      onComplete: () => ref.read(celebrationTriggerProvider.notifier).state = false,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.hello(auth?.displayName ?? '')),
              Text(
                _tabSubtitle(tab, selectedDate, ref, s),
                style: const TextStyle(
                  fontSize: 13,
                  color: MimioColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.auto_awesome_rounded),
              tooltip: s.aiPlanner,
              onPressed: () => context.push('/ai'),
            ),
            if (tab == HomeTab.today)
              Consumer(
                builder: (context, ref, _) {
                  final viewMode = ref.watch(timelineViewModeProvider);
                  return IconButton(
                    icon: Icon(viewMode == TimelineViewMode.list
                        ? Icons.view_timeline_rounded
                        : Icons.view_list_rounded),
                    tooltip: viewMode == TimelineViewMode.list ? s.hourView : s.listView,
                    onPressed: () {
                      ref.read(timelineViewModeProvider.notifier).state =
                          viewMode == TimelineViewMode.list ? TimelineViewMode.grid : TimelineViewMode.list;
                    },
                  );
                },
              ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => context.push('/profile'),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: auth != null
                      ? MimioColors.fromHex(auth.avatarColor)
                      : MimioColors.primary,
                  child: Text(
                    (auth?.displayName.isNotEmpty ?? false) ? auth!.displayName[0].toUpperCase() : '?',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: IndexedStack(
          index: tab.index,
          children: const [
            _TodayTab(),
            WeeklyView(),
            FocusTabView(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: tab.index,
          onDestinationSelected: (i) => ref.read(homeTabProvider.notifier).state = HomeTab.values[i],
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.today_outlined),
              selectedIcon: const Icon(Icons.today_rounded),
              label: s.today,
            ),
            NavigationDestination(
              icon: const Icon(Icons.calendar_view_week_outlined),
              selectedIcon: const Icon(Icons.calendar_view_week_rounded),
              label: s.week,
            ),
            NavigationDestination(
              icon: const Icon(Icons.timer_outlined),
              selectedIcon: const Icon(Icons.timer_rounded),
              label: s.focus,
            ),
          ],
        ),
        floatingActionButton: tab == HomeTab.today
            ? FloatingActionButton.extended(
                onPressed: () {
                  final date = ref.read(selectedDateProvider);
                  _showAddTask(context, ref, date);
                },
                icon: const Icon(Icons.add_rounded),
                label: Text(s.addTask),
              )
            : null,
      ),
    );
  }

  String _tabSubtitle(HomeTab tab, DateTime selectedDate, WidgetRef ref, S s) {
    final lang = ref.watch(appLanguageProvider).valueOrNull ?? 'tr';
    final locale = dateLocaleFor(lang);
    return switch (tab) {
      HomeTab.today => DateFormat('d MMMM yyyy, EEEE', locale).format(selectedDate),
      HomeTab.week => s.weeklyPlanSummary,
      HomeTab.focus => s.focusTimer,
    };
  }

  void _showAddTask(BuildContext context, WidgetRef ref, DateTime date) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddTaskSheet(selectedDate: date),
    );
  }
}

class _TodayTab extends ConsumerWidget {
  const _TodayTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timelineAsync = ref.watch(timelineProvider);
    final viewMode = ref.watch(timelineViewModeProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final s = ref.watch(stringsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const WeekStrip(),
        Expanded(
          child: timelineAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => _ErrorView(error: '$e', onRetry: () => ref.invalidate(timelineProvider), s: s),
            data: (timeline) => RefreshIndicator(
              onRefresh: () => ref.read(timelineProvider.notifier).refresh(),
              child: CustomScrollView(
                slivers: [
                  if (timeline.activeTask != null)
                    SliverToBoxAdapter(child: ActiveTaskBanner(task: timeline.activeTask!)),
                  SliverToBoxAdapter(child: DayProgressCard(tasks: timeline.tasks)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                      child: Row(
                        children: [
                          Text(
                            s.todaysPlan,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const Spacer(),
                          Text(
                            s.taskCount(timeline.tasks.length),
                            style: const TextStyle(color: MimioColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (timeline.tasks.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptyTimeline(
                        onAdd: () => _showAddTask(context, ref, selectedDate),
                        s: s,
                      ),
                    )
                  else if (viewMode == TimelineViewMode.grid)
                    SliverToBoxAdapter(
                      child: TimelineHourGrid(
                        tasks: timeline.tasks,
                        onTaskTap: (task) => _handleTaskTap(context, ref, task),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final task = timeline.tasks[index];
                            return TaskCard(
                              task: task,
                              onTap: () => _showTaskActions(context, ref, task, selectedDate),
                              onStart: () => _startTask(context, ref, task.id),
                              onPause: () => ref.read(timelineProvider.notifier).pauseTask(task.id),
                              onComplete: () => _completeTask(context, ref, task.id),
                              onSubtaskTap: (sub) => _showTaskActions(context, ref, sub, selectedDate),
                              onSubtaskStart: (sub) => _startTask(context, ref, sub.id),
                              onSubtaskPause: (sub) => ref.read(timelineProvider.notifier).pauseTask(sub.id),
                              onSubtaskComplete: (sub) => _completeTask(context, ref, sub.id),
                            );
                          },
                          childCount: timeline.tasks.length,
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 88)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _startTask(BuildContext context, WidgetRef ref, String id) async {
    final s = ref.read(stringsProvider);
    try {
      await ref.read(timelineProvider.notifier).startTask(id);
      ref.read(homeTabProvider.notifier).state = HomeTab.focus;
      ref.invalidate(focusSessionProvider);
      if (context.mounted) context.push('/focus');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(s.friendlyTaskActionError(e)),
            backgroundColor: Colors.red.shade400,
          ),
        );
      }
    }
  }

  Future<void> _completeTask(BuildContext context, WidgetRef ref, String id) async {
    final s = ref.read(stringsProvider);
    try {
      await ref.read(timelineProvider.notifier).completeTask(id);
      ref.invalidate(focusSessionProvider);
      ref.read(celebrationTriggerProvider.notifier).state = true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(s.friendlyTaskActionError(e)),
            backgroundColor: Colors.red.shade400,
          ),
        );
      }
    }
  }

  void _handleTaskTap(BuildContext context, WidgetRef ref, TaskModel task) {
    final date = ref.read(selectedDateProvider);
    _showTaskActions(context, ref, task, date);
  }

  void _showTaskActions(BuildContext context, WidgetRef ref, TaskModel task, DateTime date) {
    showTaskActionSheet(
      context: context,
      ref: ref,
      task: task,
      selectedDate: date,
      onStart: () => _startTask(context, ref, task.id),
      onPause: () => ref.read(timelineProvider.notifier).pauseTask(task.id),
      onComplete: () => _completeTask(context, ref, task.id),
      onDelete: () => ref.read(timelineProvider.notifier).deleteTask(task.id),
      onFocus: (task.isActive || task.status == TaskStatus.paused)
          ? () => context.push('/focus')
          : null,
    );
  }

  void _showAddTask(BuildContext context, WidgetRef ref, DateTime date) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddTaskSheet(selectedDate: date),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.onRetry, required this.s});

  final String error;
  final VoidCallback onRetry;
  final S s;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off_rounded, size: 48, color: MimioColors.textSecondary),
          const SizedBox(height: 16),
          Text(s.connectionError, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(error, textAlign: TextAlign.center, style: const TextStyle(color: MimioColors.textSecondary)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: Text(s.retry)),
        ],
      ),
    );
  }
}

class _EmptyTimeline extends StatelessWidget {
  const _EmptyTimeline({required this.onAdd, required this.s});

  final VoidCallback onAdd;
  final S s;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wb_sunny_rounded, size: 64, color: MimioColors.primary.withValues(alpha: 0.5)),
            const SizedBox(height: 24),
            Text(
              s.noPlanToday,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              s.emptyPlanHint,
              textAlign: TextAlign.center,
              style: const TextStyle(color: MimioColors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: Text(s.addFirstTask),
            ),
          ],
        ),
      ),
    );
  }
}
