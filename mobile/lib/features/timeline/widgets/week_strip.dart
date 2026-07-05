import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mimio/core/theme/mimio_theme.dart';
import 'package:mimio/features/providers.dart';

class WeekStrip extends ConsumerWidget {
  const WeekStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekAsync = ref.watch(weeklyTimelineProvider);
    final selected = ref.watch(selectedDateProvider);
    final today = DateTime.now();

    return weekAsync.when(
      loading: () => const SizedBox(height: 88, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
      error: (_, __) => const SizedBox.shrink(),
      data: (days) => SizedBox(
        height: 88,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: days.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final day = days[index];
            final isSelected = _sameDay(day.date, selected);
            final isToday = _sameDay(day.date, today);
            final completed = day.tasks.where((t) => t.isCompleted).length;
            final total = day.tasks.length;

            return GestureDetector(
              onTap: () {
                ref.read(selectedDateProvider.notifier).state = day.date;
                ref.invalidate(timelineProvider);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 56,
                decoration: BoxDecoration(
                  color: isSelected ? MimioColors.primary : context.palette.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isToday && !isSelected ? MimioColors.primary : context.palette.border,
                    width: isToday ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [BoxShadow(color: MimioColors.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('EEE', 'tr_TR').format(day.date).toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white70 : context.palette.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('d').format(day.date),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: isSelected ? Colors.white : context.palette.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (total > 0)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(total.clamp(0, 4), (i) {
                          final done = i < completed;
                          return Container(
                            width: 5,
                            height: 5,
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: done
                                  ? (isSelected ? Colors.white : MimioColors.success)
                                  : (isSelected ? Colors.white38 : MimioColors.primary.withValues(alpha: 0.3)),
                            ),
                          );
                        }),
                      )
                    else
                      const SizedBox(height: 5),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
