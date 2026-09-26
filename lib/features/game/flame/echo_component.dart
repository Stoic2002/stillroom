import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

/// A faceless figure of memory (scene `echoes`): it fades in a moment after
/// the scene appears, breathes and drifts a little, and dissolves when the
/// player taps near it or after a while. Purely visual: taps pass through.
class EchoComponent extends PositionComponent {
  EchoComponent({
    required this.image,
    required Vector2 drift,
    required math.Random random,
    required Vector2 position,
    super.size,
  }) : _start = position.clone(),
       _drift = drift,
       _delay = 0.6 + random.nextDouble() * 1.5,
       _life = 12 + random.nextDouble() * 6,
       super(position: position, priority: 500);

  final Image image;
  final Vector2 _start;
  final Vector2 _drift;
  final double _delay;
  final double _life;

  static const maxOpacity = 0.55;
  static const fadeIn = 1.6;
  static const fadeOut = 0.9;

  double _age = 0;
  double? _leaving;

  static final _paint = Paint()..filterQuality = FilterQuality.medium;

  /// The player reached for it: it goes.
  void dissolve() => _leaving ??= 0;

  bool get isVisible => _age > _delay && _leaving == null;

  @override
  void update(double dt) {
    _age += dt;
    final leaving = _leaving;
    if (leaving != null) {
      _leaving = leaving + dt;
      if (_leaving! >= fadeOut) removeFromParent();
    } else if (_age > _delay + _life) {
      dissolve();
    }
    final t = ((_age - _delay) / _life).clamp(0.0, 1.0);
    position = _start + _drift * t;
  }

  double get _opacity {
    final shown = _age - _delay;
    if (shown <= 0) return 0;
    var o = maxOpacity * math.min(1, shown / fadeIn);
    // A slow breath.
    o *= 0.8 + 0.2 * math.sin(_age * 1.3);
    final leaving = _leaving;
    if (leaving != null) o *= 1 - leaving / fadeOut;
    return o.clamp(0.0, 1.0);
  }

  @override
  void render(Canvas canvas) {
    final opacity = _opacity;
    if (opacity <= 0) return;
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Offset.zero & size.toSize(),
      _paint..color = Color.fromRGBO(0, 0, 0, opacity),
    );
  }
}
