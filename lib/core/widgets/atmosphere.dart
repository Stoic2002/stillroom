import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' show PointMode;

import 'package:flutter/widgets.dart';

/// Darkened edges and a fine film grain over [child] (docs/art_style_guide.md).
/// Purely visual: it never receives taps.
///
/// The grain is static (drawn once per size) to stay cheap on low-end
/// phones (NFR-01).
class Atmosphere extends StatelessWidget {
  const Atmosphere({
    this.child,
    this.vignette = 0.85,
    this.grain = 0.05,
    super.key,
  });

  final Widget? child;

  /// Edge darkness, 0–1.
  final double vignette;

  /// Grain opacity, 0–1.
  final double grain;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ?child,
        IgnorePointer(
          child: RepaintBoundary(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  radius: 0.95,
                  colors: [
                    const Color(0x00000000),
                    const Color(0x00000000),
                    Color.fromRGBO(0, 0, 0, vignette),
                  ],
                  stops: const [0, 0.55, 1],
                ),
              ),
              child: CustomPaint(painter: _GrainPainter(grain)),
            ),
          ),
        ),
      ],
    );
  }
}

class _GrainPainter extends CustomPainter {
  _GrainPainter(this.opacity);

  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0 || size.isEmpty) return;
    // Fixed seed: the same grain every frame, no shimmer.
    final random = math.Random(1888);
    final count = (size.width * size.height / 90).round().clamp(0, 60000);
    final light = Float32List(count);
    final dark = Float32List(count);
    var l = 0;
    var d = 0;
    for (var i = 0; i < count ~/ 2; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      if (random.nextBool()) {
        light[l++] = x;
        light[l++] = y;
      } else {
        dark[d++] = x;
        dark[d++] = y;
      }
    }
    final paint = Paint()
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.square;
    canvas
      ..drawRawPoints(
        PointMode.points,
        Float32List.sublistView(light, 0, l),
        paint..color = Color.fromRGBO(255, 240, 210, opacity),
      )
      ..drawRawPoints(
        PointMode.points,
        Float32List.sublistView(dark, 0, d),
        paint..color = Color.fromRGBO(0, 0, 0, opacity * 1.6),
      );
  }

  @override
  bool shouldRepaint(_GrainPainter old) => old.opacity != opacity;
}
