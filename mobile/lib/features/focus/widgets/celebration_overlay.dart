import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mimio/core/l10n/app_strings.dart';
import 'package:mimio/core/theme/mimio_theme.dart';
import 'package:mimio/features/providers.dart';

class CelebrationOverlay extends ConsumerStatefulWidget {
  const CelebrationOverlay({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  ConsumerState<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends ConsumerState<CelebrationOverlay> {
  late ConfettiController _controller;
  CelebrationEvent? _activeEvent;

  @override
  void initState() {
    super.initState();
    _controller = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    _controller.stop();
    setState(() => _activeEvent = null);
    ref.read(celebrationEventProvider.notifier).state = null;
  }

  void _showCelebration(CelebrationEvent event) {
    setState(() => _activeEvent = event);
    _controller.play();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<CelebrationEvent?>(celebrationEventProvider, (previous, next) {
      if (next != null && next != _activeEvent) {
        _showCelebration(next);
      }
    });

    final event = _activeEvent;
    final s = ref.watch(stringsProvider);

    return Stack(
      children: [
        widget.child,
        if (event != null)
          Positioned.fill(
            child: GestureDetector(
              onTap: _dismiss,
              child: ColoredBox(
                color: Colors.black.withValues(alpha: 0.45),
                child: Center(
                  child: GestureDetector(
                    onTap: () {},
                    child: _CelebrationCard(
                      event: event,
                      strings: s,
                      onDismiss: _dismiss,
                    ),
                  ),
                ),
              ),
            ),
          ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _controller,
            blastDirection: pi / 2,
            maxBlastForce: 24,
            minBlastForce: 10,
            emissionFrequency: 0.04,
            numberOfParticles: 36,
            gravity: 0.12,
            colors: const [
              Color(0xFF6C63FF),
              Color(0xFFFF6B9D),
              Color(0xFF4ECDC4),
              Color(0xFFFFE66D),
              Color(0xFF2ECC71),
            ],
          ),
        ),
      ],
    );
  }
}

class _CelebrationCard extends StatelessWidget {
  const _CelebrationCard({
    required this.event,
    required this.strings,
    required this.onDismiss,
  });

  final CelebrationEvent event;
  final S strings;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: min(MediaQuery.sizeOf(context).width - 48, 360),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: MimioColors.primary.withValues(alpha: 0.18),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  MimioColors.primary.withValues(alpha: 0.15),
                  MimioColors.primaryLight.withValues(alpha: 0.25),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              event.hasReward ? Icons.card_giftcard_rounded : Icons.celebration_rounded,
              size: 36,
              color: MimioColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            strings.taskCompletedTitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: MimioColors.textPrimary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            strings.taskCompletedSubtitle(event.taskTitle),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: MimioColors.textSecondary,
              height: 1.4,
            ),
          ),
          if (event.hasReward) ...[
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFFE66D).withValues(alpha: 0.35),
                    const Color(0xFFFF6B9D).withValues(alpha: 0.2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFFFE66D).withValues(alpha: 0.6)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.emoji_events_rounded, color: Color(0xFFE6A800), size: 20),
                      const SizedBox(width: 6),
                      Text(
                        strings.yourReward,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFB8860B),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    event.reward!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: MimioColors.textPrimary,
                          height: 1.35,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              strings.rewardReminder,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: MimioColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onDismiss,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(strings.awesome),
            ),
          ),
        ],
      ),
    );
  }
}
