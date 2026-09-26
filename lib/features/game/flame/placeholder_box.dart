import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

import '../../../core/theme/placeholder_palette.dart';
import '../../../core/theme/stillroom_palette.dart';

/// Stand-in for art that has not been delivered yet (PRD §9A): a colored box
/// labelled with the content id. Dropping the real image at the path from
/// the JSON replaces it.
class PlaceholderBox extends PositionComponent {
  PlaceholderBox({
    required this.label,
    required this.background,
    super.position,
    super.size,
  }) : _fill = Paint()..color = placeholderColor(label, background: background),
       _stroke = Paint()
         ..style = PaintingStyle.stroke
         ..strokeWidth = background ? 0 : 3
         ..color = StillroomPalette.paperShade.withValues(alpha: 0.55),
       _text = TextPaint(
         style: TextStyle(
           color: StillroomPalette.paper.withValues(alpha: 0.8),
           fontFamily: 'IMFell',
           fontSize: background ? 56 : 26,
           fontWeight: FontWeight.w400,
         ),
       );

  final String label;

  /// Scene backgrounds are drawn darker, without a border.
  final bool background;
  final Paint _fill;
  final Paint _stroke;
  final TextPaint _text;

  @override
  void render(Canvas canvas) {
    final rect = size.toRect();
    canvas.drawRect(rect, _fill);
    if (!background) canvas.drawRect(rect, _stroke);
    _text.render(
      canvas,
      label,
      background ? Vector2(size.x / 2, 48) : size / 2,
      anchor: background ? Anchor.topCenter : Anchor.center,
    );
  }
}
