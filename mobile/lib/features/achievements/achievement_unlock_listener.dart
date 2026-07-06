import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mimio/core/l10n/app_strings.dart';
import 'package:mimio/core/models/achievement.dart';
import 'package:mimio/core/storage/adhd_settings_storage.dart';
import 'package:mimio/core/theme/mimio_theme.dart';
import 'package:mimio/core/widgets/mimio_soft_overlay.dart';
import 'package:mimio/features/achievements/achievements_screen.dart';

class AchievementUnlockListener extends ConsumerStatefulWidget {
  const AchievementUnlockListener({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AchievementUnlockListener> createState() => _AchievementUnlockListenerState();
}

class _AchievementUnlockListenerState extends ConsumerState<AchievementUnlockListener> {
  Set<String> _knownUnlocked = {};
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadKnown();
  }

  Future<void> _loadKnown() async {
    _knownUnlocked = await ref.read(adhdSettingsStorageProvider).loadUnlockedAchievementIds();
    if (mounted) setState(() => _loaded = true);
  }

  void _checkUnlocks(AchievementStats stats) {
    if (!_loaded) return;
    for (final def in achievementDefinitions) {
      final id = def.id.name;
      if (def.isUnlocked(stats) && !_knownUnlocked.contains(id)) {
        _knownUnlocked = {..._knownUnlocked, id};
        ref.read(adhdSettingsStorageProvider).saveUnlockedAchievementIds(_knownUnlocked);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _showUnlock(def);
        });
      }
    }
  }

  void _showUnlock(AchievementDefinition def) {
    final s = ref.read(stringsProvider);
    showMimioSoftDialog(
      context: context,
      builder: (dialogCtx) => MimioSoftCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(def.icon, size: 36, color: def.color),
            const SizedBox(height: 10),
            Text(
              s.achievementUnlocked,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: dialogCtx.palette.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              s.achievementTitle(def.id),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: dialogCtx.palette.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: MimioSoftTextButton(
                label: s.awesome,
                onPressed: () => Navigator.pop(dialogCtx),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(achievementStatsProvider, (prev, next) {
      final stats = next.valueOrNull;
      if (stats != null) _checkUnlocks(stats);
    });
    return widget.child;
  }
}
