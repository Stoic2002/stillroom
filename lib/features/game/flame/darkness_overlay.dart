import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

import '../../../core/theme/stillroom_palette.dart';

/// Covers a dark scene in black, except a circle of lantern light that
/// follows the player's finger (scene `dark`). Does nothing when [radius] is
/// `null`.
class DarknessOverlay extends PositionComponent {
  DarknessOverlay({required super.size}) : super(priority: 950);

  /// Light radius in logical pixels, or `null` when the scene is lit.
  double? radius;

  /// Where the lantern is, in logical pixels.
  late Vector2 light = Vector2(size.x * 0.5, size.y * 0.6);

  double _time = 0;

  @override
  void update(double dt) => _time += dt;

  @override
  void render(Canvas canvas) {
    final r0 = radius;
    if (r0 == null) return;
    // A small flicker, like a flame behind glass.
    final r =
        r0 * (1 + 0.025 * math.sin(_time * 9) + 0.015 * math.sin(_time * 23));
    final rect = Offset.zero & size.toSize();
    final center = light.toOffset();
    final circle = Rect.fromCircle(center: center, radius: r);
    canvas
      ..saveLayer(rect, Paint())
      ..drawRect(rect, Paint()..color = const Color(0xF7040302))
      ..drawCircle(
        center,
        r,
        Paint()
          ..blendMode = BlendMode.dstOut
          ..shader = const RadialGradient(
            colors: [Color(0xFF000000), Color(0xEE000000), Color(0x00000000)],
            stops: [0, 0.55, 1],
          ).createShader(circle),
      )
      ..restore()
      ..drawCircle(
        center,
        r,
        Paint()
          ..shader = RadialGradient(
            colors: [
              StillroomPalette.gaslight.withValues(alpha: 0.14),
              StillroomPalette.gaslight.withValues(alpha: 0),
            ],
          ).createShader(circle),
      );
  }
}
