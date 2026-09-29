import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import '../../../core/theme/stillroom_palette.dart';
import '../../../engine/engine.dart';
import 'scene_view.dart';

/// The lens between eras (scene `lens`): a brass-rimmed circle the player
/// pushes around the scene. Inside it the lens scene shows, its background
/// and visible layers, as the same place looked in another year. It only
/// draws; the game routes taps inside it to the lens scene.
class LensView extends PositionComponent {
  LensView({
    required this.scene,
    required this.sprites,
    required GameState state,
    required double radius,
    required super.size,
  }) : _state = state,
       _radius = radius,
       lensCenter = Vector2(size!.x * 0.5, size.y * 0.45),
       super(priority: 900);

  /// The scene seen through the lens.
  final Scene scene;
  final Map<String, Sprite> sprites;
  final double _radius;
  GameState _state;
  final _layers = Component();

  /// Middle of the lens, in logical pixels.
  final Vector2 lensCenter;

  /// Whether the player has the lens raised; it opens and closes smoothly.
  bool shown = false;
  double _open = 0;
  double _time = 0;

  static const openSeconds = 0.3;

  double get radius => _radius * _open;

  /// Whether the logical point [p] is inside the raised lens.
  bool holds(Vector2 p) =>
      shown && _open > 0.5 && p.distanceTo(lensCenter) <= _radius;

  void moveBy(Vector2 delta) {
    if (!shown) return;
    lensCenter
      ..add(delta)
      ..clamp(Vector2.zero(), size);
  }

  @override
  Future<void> onLoad() async {
    add(
      sceneVisual(
        sprites,
        path: scene.background,
        label: scene.id,
        position: Vector2.zero(),
        size: size,
        background: true,
      ),
    );
    add(_layers);
    _rebuild();
  }

  void refresh(GameState state) {
    _state = state;
    if (isLoaded) _rebuild();
  }

  void _rebuild() {
    _layers.removeAll(_layers.children);
    for (final layer in scene.layers) {
      if (!layer.when.allMet(_state)) continue;
      final r = layer.rect;
      _layers.add(
        sceneVisual(
          sprites,
          path: layer.image,
          label: layer.id,
          position: Vector2(r.x * size.x, r.y * size.y),
          size: Vector2(r.width * size.x, r.height * size.y),
          background: false,
        ),
      );
    }
  }

  @override
  void update(double dt) {
    _time += dt;
    final target = shown ? 1.0 : 0.0;
    if (_open != target) {
      final step = dt / openSeconds;
      _open = shown ? math.min(1, _open + step) : math.max(0, _open - step);
    }
  }

  @override
  void renderTree(Canvas canvas) {
    if (_open <= 0) return;
    // Ease out, so the glass swings up quickly and settles.
    final r = _radius * (1 - math.pow(1 - _open, 3));
    final c = lensCenter.toOffset();
    final circle = Rect.fromCircle(center: c, radius: r);
    canvas
      ..save()
      ..clipPath(Path()..addOval(circle));
    super.renderTree(canvas);
    // Old glass: warm at the middle, darker towards the rim.
    canvas
      ..drawRect(
        circle,
        Paint()
          ..shader = Gradient.radial(
            c,
            r,
            [
              const Color(0x00000000),
              const Color(0x10F2D9A0),
              const Color(0x66140C06),
            ],
            const [0, 0.7, 1],
          ),
      )
      ..restore();
    _rim(canvas, c, r);
  }

  void _rim(Canvas canvas, Offset c, double r) {
    final w = _radius * 0.07;
    canvas
      ..drawCircle(
        c,
        r + w * 0.5,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 1.6
          ..color = const Color(0x66000000)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      )
      ..drawCircle(
        c,
        r + w * 0.5,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = w
          ..shader = Gradient.sweep(c, [
            StillroomPalette.brass,
            const Color(0xFFF0D594),
            StillroomPalette.brass,
            const Color(0xFF6E5424),
            StillroomPalette.brass,
          ]),
      )
      ..drawCircle(
        c,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = const Color(0xAA3A2A12),
      );
    // A glint that slides slowly round the glass.
    final a = -math.pi * 0.75 + 0.2 * math.sin(_time * 0.7);
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r * 0.86),
      a,
      0.5,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.035
        ..strokeCap = StrokeCap.round
        ..color = const Color(0x40FFF6DC),
    );
  }
}
