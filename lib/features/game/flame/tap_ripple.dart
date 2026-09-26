import 'dart:ui';

import 'package:flame/components.dart';

import '../../../core/theme/stillroom_palette.dart';

/// A faint ring of gaslight spreading from a tap on the scene, so every
/// touch is answered even when nothing is there. Removes itself.
class TapRipple extends PositionComponent {
  TapRipple({required super.position})
    : super(anchor: Anchor.center, priority: 900);

  static const duration = 0.45;

  /// Largest radius, in logical pixels (the scene is 1920 wide).
  static const reach = 56.0;

  double _age = 0;

  @override
  void update(double dt) {
    _age += dt;
    if (_age >= duration) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final t = (_age / duration).clamp(0.0, 1.0);
    final eased = 1 - (1 - t) * (1 - t);
    final fade = 1 - t;
    canvas
      ..drawCircle(
        Offset.zero,
        reach * eased,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3 * fade + 0.5
          ..color = StillroomPalette.gaslight.withValues(alpha: 0.45 * fade),
      )
      ..drawCircle(
        Offset.zero,
        reach * 0.35 * eased,
        Paint()
          ..color = StillroomPalette.gaslight.withValues(alpha: 0.12 * fade),
      );
  }
}
