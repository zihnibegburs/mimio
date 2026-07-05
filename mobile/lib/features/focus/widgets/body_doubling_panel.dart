import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mimio/core/l10n/app_strings.dart';
import 'package:mimio/core/storage/adhd_settings_storage.dart';
import 'package:mimio/core/theme/mimio_theme.dart';

class BodyDoublingPanel extends ConsumerStatefulWidget {
  const BodyDoublingPanel({super.key});

  @override
  ConsumerState<BodyDoublingPanel> createState() => _BodyDoublingPanelState();
}

class _BodyDoublingPanelState extends ConsumerState<BodyDoublingPanel> {
  Timer? _pulseTimer;
  int _virtualBuddies = 12;

  @override
  void initState() {
    super.initState();
    _pulseTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (mounted) {
        setState(() => _virtualBuddies = 8 + Random().nextInt(20));
      }
    });
  }

  @override
  void dispose() {
    _pulseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final enabled = ref.watch(adhdPreferencesProvider).valueOrNull?.bodyDoublingEnabled ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MimioColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MimioColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.people_rounded, color: MimioColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(s.bodyDoubling, style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
              Switch(
                value: enabled,
                onChanged: (v) => ref.read(adhdPreferencesProvider.notifier).patch((p) => p.copyWith(bodyDoublingEnabled: v)),
              ),
            ],
          ),
          if (enabled) ...[
            const SizedBox(height: 8),
            Text(s.bodyDoublingHint, style: TextStyle(fontSize: 13, color: context.palette.textSecondary)),
            const SizedBox(height: 8),
            Row(
              children: [
                ...List.generate(3, (i) => Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: MimioColors.taskColors[i % MimioColors.taskColors.length].startsWith('#')
                            ? MimioColors.fromHex(MimioColors.taskColors[i % MimioColors.taskColors.length])
                            : MimioColors.primary,
                        child: Text('${i + 1}', style: const TextStyle(fontSize: 10, color: Colors.white)),
                      ),
                    )),
                Text(
                  '+$_virtualBuddies',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: MimioColors.primary),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
