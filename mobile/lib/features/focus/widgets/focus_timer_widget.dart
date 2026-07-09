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
  double? _dragProgress;

  double get _strokeWidth => widget.size * 0.095;
  double get _knobSize => widget.size * 0.16;
  double get _knobHitRadius => _knobSize * 0.72;
  double get _ringPadding => _knobSize * 0.5 + 4;
  double get _canvasSize => widget.size + (_ringPadding * 2);

  double _progressFromOffset(Offset local) {
    final center = Offset(_canvasSize / 2, _canvasSize / 2);
    final v = local - center;
    var angle = atan2(v.dy, v.dx);
    var progress = (angle + pi / 2) / (2 * pi);
    if (progress < 0) progress += 1;
    return progress.clamp(0.0, 1.0);
  }

  bool _isSeekable(Offset local, double progress) {
    final center = Offset(_canvasSize / 2, _canvasSize / 2);
    final dist = (local - center).distance;
    final radius = (widget.size - _strokeWidth) / 2;
    final onRing = (dist - radius).abs() <= _strokeWidth * 1.8;

    final knobAngle = -pi / 2 + 2 * pi * progress;
    final knobCenter = center + Offset(radius * cos(knobAngle), radius * sin(knobAngle));
    final onKnob = (local - knobCenter).distance <= _knobHitRadius;

    final innerDeadZone = widget.size * 0.24;
    return (onRing || onKnob) && dist >= innerDeadZone;
  }

  void _handleSeek(Offset local, {required bool persist}) {
    if (!widget.interactive) return;
    final progress = _progressFromOffset(local);
    setState(() => _dragProgress = progress);
    ref.read(focusSessionProvider.notifier).seekToProgress(progress, persist: persist);
  }

  void _endDrag() {
    if (!_dragging) return;
    setState(() {
      _dragging = false;
      _dragProgress = null;
    });
    ref.read(focusSessionProvider.notifier).persistSession();
  }

  String _remainingFormatted(FocusSessionModel session, double progress) {
    final total = session.durationMinutes * 60;
    final remaining = ((1 - progress) * total).round().clamp(0, total);
    final minutes = remaining ~/ 60;
    final seconds = remaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final session = widget.interactive ? ref.watch(focusSessionProvider).valueOrNull ?? widget.session : widget.session;
    final color = widget.inverted ? Colors.white : MimioColors.fromHex(session.color);
    final trackColor = widget.inverted
        ? Colors.white.withValues(alpha: 0.25)
        : MimioColors.fromHex(session.color).withValues(alpha: 0.15);
    final textColor = widget.inverted ? Colors.white : context.palette.textPrimary;
    final subtextColor = widget.inverted ? Colors.white70 : context.palette.textSecondary;
    final progress = _dragProgress ?? session.progressPercent / 100;
    final displayRemaining = _dragging
        ? _remainingFormatted(session, progress)
        : session.remainingFormatted;
    final knobAngle = -pi / 2 + 2 * pi * progress;
    final radius = (widget.size - _strokeWidth) / 2;
    final knobX = _canvasSize / 2 + radius * cos(knobAngle);
    final knobY = _canvasSize / 2 + radius * sin(knobAngle);
    final knobSize = _knobSize;

    return SizedBox(
      width: _canvasSize,
      height: _canvasSize,
      child: GestureDetector(
        onPanStart: widget.interactive
            ? (details) {
                if (_isSeekable(details.localPosition, progress)) {
                  setState(() => _dragging = true);
                  _handleSeek(details.localPosition, persist: false);
                }
              }
            : null,
        onPanUpdate: widget.interactive
            ? (details) {
                if (_dragging) _handleSeek(details.localPosition, persist: false);
              }
            : null,
        onPanEnd: widget.interactive ? (_) => _endDrag() : null,
        onPanCancel: widget.interactive ? () => _endDrag() : null,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
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
                left: knobX - knobSize / 2,
                top: knobY - knobSize / 2,
                child: AnimatedScale(
                  scale: _dragging ? 1.12 : 1.0,
                  duration: const Duration(milliseconds: 160),
                  curve: Curves.easeOutBack,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: knobSize,
                    height: knobSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        center: const Alignment(-0.35, -0.4),
                        radius: 0.95,
                        colors: [
                          Colors.white,
                          color.withValues(alpha: 0.08),
                          color.withValues(alpha: 0.16),
                        ],
                        stops: const [0.0, 0.55, 1.0],
                      ),
                      border: Border.all(
                        color: color.withValues(alpha: 0.72),
                        width: knobSize * 0.11,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: _dragging ? 0.24 : 0.14),
                          blurRadius: _dragging ? 12 : 6,
                          spreadRadius: _dragging ? 0.5 : 0,
                          offset: const Offset(0, 2),
                        ),
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.65),
                          blurRadius: 0,
                          spreadRadius: -knobSize * 0.1,
                          offset: Offset.zero,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: knobSize * 0.22,
                        height: knobSize * 0.22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: _dragging ? 0.95 : 0.75),
                        ),
                      ),
                    ),
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
                  displayRemaining,
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
    final clampedProgress = progress.clamp(0, 1);

    final outerGlowPaint = Paint()
      ..color = trackColor.withValues(alpha: 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 2
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final innerTrackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 0.35
      ..strokeCap = StrokeCap.round;

    final progressGlowPaint = Paint()
      ..shader = SweepGradient(
        startAngle: -pi / 2,
        endAngle: 3 * pi / 2,
        colors: [
          color.withValues(alpha: 0.08),
          color.withValues(alpha: 0.24),
          color.withValues(alpha: 0.08),
        ],
        stops: const [0.0, 0.5, 1.0],
        transform: GradientRotation(-pi / 2),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 3
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    final progressPaint = Paint()
      ..shader = SweepGradient(
        startAngle: -pi / 2,
        endAngle: 3 * pi / 2,
        colors: [
          color.withValues(alpha: 0.62),
          color,
          color.withValues(alpha: 0.72),
        ],
        stops: const [0.0, 0.55, 1.0],
        transform: GradientRotation(-pi / 2),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressHighlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 0.2
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, 0, 2 * pi, false, outerGlowPaint);
    canvas.drawArc(rect, 0, 2 * pi, false, trackPaint);
    canvas.drawArc(rect, 0, 2 * pi, false, innerTrackPaint);

    if (clampedProgress > 0) {
      final sweep = 2 * pi * clampedProgress;
      canvas.drawArc(rect, -pi / 2, sweep, false, progressGlowPaint);
      canvas.drawArc(rect, -pi / 2, sweep, false, progressPaint);
      canvas.drawArc(rect, -pi / 2, sweep, false, progressHighlightPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TimerRingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.color != color ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.strokeWidth != strokeWidth;
}
