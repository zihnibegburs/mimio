import 'package:flutter/material.dart';
import 'package:mimio/core/config/platform_config.dart';
import 'package:mimio/core/theme/mimio_theme.dart';
import 'package:mimio/features/web/weekly_view.dart';

class WebShell extends StatelessWidget {
  const WebShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!PlatformConfig.isWeb) return child;

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: MediaQuery.sizeOf(context).width > 1100,
            backgroundColor: Colors.white,
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
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.calendar_view_week_outlined),
                selectedIcon: Icon(Icons.calendar_view_week_rounded),
                label: Text('Hafta'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.view_day_outlined),
                selectedIcon: Icon(Icons.view_day_rounded),
                label: Text('Gün'),
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
