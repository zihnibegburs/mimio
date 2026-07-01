import 'dart:async';
import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

class CelebrationOverlay extends StatefulWidget {
  const CelebrationOverlay({
    super.key,
    required this.child,
    this.trigger = false,
    this.onComplete,
  });

  final Widget child;
  final bool trigger;
  final VoidCallback? onComplete;

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay> {
  late ConfettiController _controller;
  bool _wasTriggered = false;

  @override
  void initState() {
    super.initState();
    _controller = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void didUpdateWidget(CelebrationOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger && !_wasTriggered) {
      _wasTriggered = true;
      _controller.play();
      Future.delayed(const Duration(seconds: 2), () {
        widget.onComplete?.call();
        if (mounted) setState(() => _wasTriggered = false);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _controller,
            blastDirection: pi / 2,
            maxBlastForce: 20,
            minBlastForce: 8,
            emissionFrequency: 0.04,
            numberOfParticles: 30,
            gravity: 0.15,
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
