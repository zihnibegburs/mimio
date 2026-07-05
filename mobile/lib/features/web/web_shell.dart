import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mimio/core/config/platform_config.dart';
import 'package:mimio/core/l10n/app_strings.dart';
import 'package:mimio/core/theme/mimio_theme.dart';
import 'package:mimio/features/web/weekly_view.dart';

class WebShell extends ConsumerWidget {
  const WebShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!PlatformConfig.isWeb) return child;

    final s = ref.watch(stringsProvider);
    final palette = context.palette;

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: MediaQuery.sizeOf(context).width > 1100,
            backgroundColor: palette.surface,
            selectedIndex: 0,
            labelType: NavigationRailLabelType.none,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: MimioColors.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.schedule_rounded, color: Colors.white),
                  ),
                  const SizedBox(width: 12, height: 12),
                  if (MediaQuery.sizeOf(context).width > 1100)
                    const Text('Mimio', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                ],
              ),
            ),
            destinations: [
              NavigationRailDestination(
                icon: const Icon(Icons.calendar_view_week_outlined),
                selectedIcon: const Icon(Icons.calendar_view_week_rounded),
                label: Text(s.week),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.view_day_outlined),
                selectedIcon: const Icon(Icons.view_day_rounded),
                label: Text(s.day),
              ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Column(
              children: [
                if (MediaQuery.sizeOf(context).width >= 900)
                  const Padding(
                    padding: EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: SizedBox(height: 160, child: WeeklyView(compact: true)),
                  ),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
