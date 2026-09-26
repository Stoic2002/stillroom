import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

import '../../../engine/engine.dart';

/// Debug overlay: outlines and ids of the visible hotspots and exit areas.
class HotspotOutlines extends PositionComponent {
  HotspotOutlines({super.size}) : super(priority: 100);

  static const _hotspotColor = Color(0xFF4CFF7A);
  static const _exitColor = Color(0xFFFFA23C);

  List<Hotspot> hotspots = const [];
  List<SceneExit> exits = const [];
  bool enabled = false;

  final _text = TextPaint(
    style: const TextStyle(
      color: Color(0xFFFFFFFF),
      fontSize: 22,
      backgroundColor: Color(0xAA000000),
    ),
  );

  @override
  void render(Canvas canvas) {
    if (!enabled) return;
    for (final h in hotspots) {
      _draw(canvas, h.rect, h.id, _hotspotColor);
    }
    for (final e in exits) {
      if (e.rect case final rect?) {
        _draw(canvas, rect, 'exit ${e.id}', _exitColor);
      }
    }
  }

  void _draw(Canvas canvas, NormalizedRect r, String label, Color color) {
    final rect = Rect.fromLTWH(
      r.x * size.x,
      r.y * size.y,
      r.width * size.x,
      r.height * size.y,
    );
    canvas
      ..drawRect(rect, Paint()..color = color.withValues(alpha: 0.15))
      ..drawRect(
        rect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = color,
      );
    _text.render(canvas, ' $label ', Vector2(rect.left + 4, rect.top + 4));
  }
}
