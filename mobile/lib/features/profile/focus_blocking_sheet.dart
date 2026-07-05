import 'package:flutter/material.dart';
import 'package:mimio/core/theme/mimio_theme.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mimio/core/l10n/app_strings.dart';

Future<void> showFocusBlockingSheet(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => const _FocusBlockingSheet(),
  );
}

class _FocusBlockingSheet extends ConsumerWidget {
  const _FocusBlockingSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);

    return Container(
      decoration: BoxDecoration(
        color: context.palette.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(s.focusBlocking, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Text(s.focusBlockingHint, style: const TextStyle(height: 1.5)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                try {
                  await const MethodChannel('com.mimio/settings').invokeMethod('openFocusSettings');
                } catch (_) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(s.openSettings)),
                    );
                  }
                }
              },
              icon: const Icon(Icons.settings_rounded),
              label: Text(s.openSettings),
            ),
          ),
        ],
      ),
    );
  }
}
