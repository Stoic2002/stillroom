import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/stillroom_palette.dart';

/// A bell's ring drawn as a trace running left to right: loud at the strike,
/// fading, and swelling and fading in waves (the beat) as deep as [swell].
/// The trace is drawn up to [progress] (0–1) of its [length], which is the
/// ring's share of the whole panel. An optional [mark] is a line the ring
/// must reach.
class BellTracePainter extends CustomPainter {
  const BellTracePainter({
    required this.progress,
    required this.length,
    required this.swell,
    this.waves = 5,
    this.mark,
  });

  final double progress;
  final double length;
  final double swell;

  /// How many swells fit across the whole panel.
  final double waves;
  final double? mark;

  /// The ring's loudness at [x] (0–1 across the panel), 0 to 1.
  static double loudness(double x, double length, double swell, double waves) {
    if (length <= 0 || x > length) return 0;
    final fade = math.pow(1 - x / length, 0.8).toDouble();
    final beat = 1 - swell * (0.5 - 0.5 * math.cos(2 * math.pi * waves * x));
    return fade * beat;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final mid = size.height / 2;
    canvas
      ..drawRRect(
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(6)),
        Paint()..color = const Color(0xCC0E0B09),
      )
      ..drawLine(
        Offset(0, mid),
        Offset(size.width, mid),
        Paint()
          ..strokeWidth = 1
          ..color = const Color(0x33D8C9A8),
      );
    final m = mark;
    if (m != null) {
      final x = m * size.width;
      canvas.drawLine(
        Offset(x, 4),
        Offset(x, size.height - 4),
        Paint()
          ..strokeWidth = 2
          ..color = StillroomPalette.gaslight,
      );
    }
    final end = math.min(progress, 1.0) * length;
    if (end <= 0) return;
    final top = Path()..moveTo(0, mid);
    final bottom = Path()..moveTo(0, mid);
    const steps = 240;
    for (var i = 0; i <= steps; i++) {
      final x = end * i / steps;
      final a = loudness(x, length, swell, waves) * (size.height / 2 - 6);
      top.lineTo(x * size.width, mid - a);
      bottom.lineTo(x * size.width, mid + a);
    }
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0xFFE0C08A);
    canvas
      ..drawPath(top, ring)
      ..drawPath(bottom, ring);
    // A soft fill between the two, like a sound seen on glass.
    final fill = Path()..addPath(top, Offset.zero);
    for (var i = steps; i >= 0; i--) {
      final x = end * i / steps;
      final a = loudness(x, length, swell, waves) * (size.height / 2 - 6);
      fill.lineTo(x * size.width, mid + a);
    }
    canvas.drawPath(fill..close(), Paint()..color = const Color(0x33E0C08A));
  }

  @override
  bool shouldRepaint(BellTracePainter old) =>
      old.progress != progress ||
      old.length != length ||
      old.swell != swell ||
      old.mark != mark;
}
