import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mimio/core/models/models.dart';
import 'package:mimio/core/theme/mimio_theme.dart';

class FocusTimerWidget extends StatelessWidget {
  const FocusTimerWidget({
    super.key,
    required this.session,
    this.size = 220,
    this.showLabel = true,
    this.inverted = false,
  });

  final FocusSessionModel session;
  final double size;
  final bool showLabel;
  final bool inverted;

  @override
  Widget build(BuildContext context) {
    final color = inverted ? Colors.white : MimioColors.fromHex(session.color);
    final trackColor = inverted
        ? Colors.white.withValues(alpha: 0.25)
        : MimioColors.fromHex(session.color).withValues(alpha: 0.15);
    final textColor = inverted ? Colors.white : MimioColors.textPrimary;
    final subtextColor = inverted ? Colors.white70 : MimioColors.textSecondary;
    final progress = session.progressPercent / 100;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _TimerRingPainter(
                progress: progress,
                color: color,
                trackColor: trackColor,
                strokeWidth: size * 0.06,
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (session.isPaused)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: MimioColors.warning.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'DURAKLATILDI',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: MimioColors.warning,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              if (session.isPaused) const SizedBox(height: 8),
              Text(
                session.remainingFormatted,
                style: TextStyle(
                  fontSize: size * 0.18,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              if (showLabel) ...[
                const SizedBox(height: 4),
                Text(
                  'kalan süre',
                  style: TextStyle(
                    fontSize: size * 0.05,
                    color: subtextColor,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _TimerRingPainter extends CustomPainter {
  _TimerRingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, 0, 2 * pi, false, trackPaint);
    canvas.drawArc(rect, -pi / 2, 2 * pi * progress.clamp(0, 1), false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _TimerRingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
