import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../theme/stillroom_palette.dart';

/// The keeper's mark: a small four-pointed brass star (drawn, since the
/// bundled fonts have no star glyph).
class KeeperStar extends StatelessWidget {
  const KeeperStar({this.size = 14, this.glow = true, super.key});

  final double size;
  final bool glow;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: CustomPaint(painter: _StarPainter(glow: glow)),
  );
}

class _StarPainter extends CustomPainter {
  _StarPainter({required this.glow});

  final bool glow;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    final star = Path();
    for (var i = 0; i < 8; i++) {
      final a = i * math.pi / 4 - math.pi / 2;
      final len = i.isEven ? r : r * 0.3;
      final p = c + Offset(math.cos(a), math.sin(a)) * len;
      i == 0 ? star.moveTo(p.dx, p.dy) : star.lineTo(p.dx, p.dy);
    }
    star.close();
    if (glow) {
      canvas.drawPath(
        star,
        Paint()
          ..color = StillroomPalette.gaslight
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.5),
      );
    }
    canvas.drawPath(star, Paint()..color = StillroomPalette.gaslight);
  }

  @override
  bool shouldRepaint(_StarPainter old) => old.glow != glow;
}
