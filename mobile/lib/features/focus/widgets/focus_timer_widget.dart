import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mimio/core/l10n/app_strings.dart';
import 'package:mimio/core/models/models.dart';
import 'package:mimio/core/theme/mimio_theme.dart';
import 'package:mimio/features/providers.dart';

class FocusTimerWidget extends ConsumerStatefulWidget {
  const FocusTimerWidget({
    super.key,
    required this.session,
    this.size = 220,
    this.showLabel = true,
    this.inverted = false,
    this.interactive = false,
  });

  final FocusSessionModel session;
  final double size;
  final bool showLabel;
  final bool inverted;
  final bool interactive;

  @override
  ConsumerState<FocusTimerWidget> createState() => _FocusTimerWidgetState();
}

class _FocusTimerWidgetState extends ConsumerState<FocusTimerWidget> {
  bool _dragging = false;

  double get _strokeWidth => widget.size * 0.06;

  double _progressFromOffset(Offset local) {
    final center = Offset(widget.size / 2, widget.size / 2);
    final v = local - center;
    var angle = atan2(v.dy, v.dx);
    var progress = (angle + pi / 2) / (2 * pi);
    if (progress < 0) progress += 1;
    return progress.clamp(0.0, 1.0);
  }

  bool _isOnRing(Offset local) {
    final center = Offset(widget.size / 2, widget.size / 2);
    final dist = (local - center).distance;
    final radius = (widget.size - _strokeWidth) / 2;
    return (dist - radius).abs() <= _strokeWidth * 1.4;
  }

  void _handleSeek(Offset local) {
    if (!widget.interactive) return;
    final progress = _progressFromOffset(local);
    ref.read(focusSessionProvider.notifier).seekToProgress(progress);
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final session = widget.interactive ? ref.watch(focusSessionProvider).valueOrNull ?? widget.session : widget.session;
    final color = widget.inverted ? Colors.white : MimioColors.fromHex(session.color);
    final trackColor = widget.inverted
        ? Colors.white.withValues(alpha: 0.25)
        : MimioColors.fromHex(session.color).withValues(alpha: 0.15);
    final textColor = widget.inverted ? Colors.white : MimioColors.textPrimary;
    final subtextColor = widget.inverted ? Colors.white70 : MimioColors.textSecondary;
    final progress = session.progressPercent / 100;
    final knobAngle = -pi / 2 + 2 * pi * progress;
    final radius = (widget.size - _strokeWidth) / 2;
    final knobX = widget.size / 2 + radius * cos(knobAngle);
    final knobY = widget.size / 2 + radius * sin(knobAngle);

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: GestureDetector(
        onPanStart: widget.interactive
            ? (details) {
                if (_isOnRing(details.localPosition)) {
                  setState(() => _dragging = true);
                  _handleSeek(details.localPosition);
                }
              }
            : null,
        onPanUpdate: widget.interactive
            ? (details) {
                if (_dragging) _handleSeek(details.localPosition);
              }
            : null,
        onPanEnd: widget.interactive ? (_) => setState(() => _dragging = false) : null,
        onPanCancel: widget.interactive ? () => setState(() => _dragging = false) : null,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: widget.size,
              height: widget.size,
              child: CustomPaint(
                painter: _TimerRingPainter(
                  progress: progress,
                  color: color,
                  trackColor: trackColor,
                  strokeWidth: _strokeWidth,
                ),
              ),
            ),
            if (widget.interactive)
              Positioned(
                left: knobX - 14,
                top: knobY - 14,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: _dragging ? 0.45 : 0.25),
                        blurRadius: _dragging ? 12 : 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
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
                    child: Text(
                      s.pausedUpper,
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
                    fontSize: widget.size * 0.18,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                if (widget.showLabel) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.interactive ? s.timerDragHint : s.remainingTime,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: widget.size * 0.045,
                      color: subtextColor,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
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
