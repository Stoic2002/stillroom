import 'dart:math' as math;
import 'dart:ui';

import 'art_kit.dart';

/// Code-drawn art for the keeper's own tale (docs/episodes/
/// stillroom_keeper.md). Hester Croft is an invented person: a stillroom
/// maid of about 1720, the room's keeper before the player.

const _skin = Color(0xFFE6C2A2);
const _skinShade = Color(0xFFB98A6E);
const _hair = Color(0xFF5A3A26);
const _linen = Color(0xFFEDE6D8);
const _linenShade = Color(0xFFB4AEA6);
const _bodice = Color(0xFF3E3430);
const _gilt = Color(0xFFB08A3A);

/// Her portrait, whole: half-length in an oval gilt frame, candle light
/// from the left, a linen cap and a crossed kerchief, a dark bodice, the
/// eyes on the one who looks at her.
void paintKeeperPortrait(Art a) {
  final w = a.size.width;
  final h = a.size.height;
  Offset p(double x, double y) => Offset(x * w, y * h);
  final oval = Rect.fromLTRB(0.06 * w, 0.04 * h, 0.94 * w, 0.96 * h);

  // The frame: gilt, its moulding lit from the left.
  a.canvas
    ..drawOval(
      oval.inflate(w * 0.05),
      Paint()
        ..shader = Gradient.linear(
          oval.topLeft,
          oval.bottomRight,
          [const Color(0xFFE2C070), _gilt, const Color(0xFF6A4E1E)],
          [0, 0.5, 1],
        ),
    )
    ..drawOval(
      oval.inflate(w * 0.05),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.006
        ..color = Art.outline,
    )
    ..drawOval(
      oval.inflate(w * 0.012),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.012
        ..color = const Color(0xFF7A5A26),
    )
    ..save()
    ..clipPath(Path()..addOval(oval));

  // The dark ground, warm where the candle is.
  a.canvas.drawRect(
    oval,
    Paint()
      ..shader = Gradient.radial(
        p(0.2, 0.35),
        w * 0.95,
        [
          const Color(0xFF5A4232),
          const Color(0xFF2A1E18),
          const Color(0xFF140E0A),
        ],
        [0, 0.45, 1],
      ),
  );

  void shaded(Path path, Color light, Color dark, {Offset? from, Offset? to}) {
    final b = path.getBounds();
    a.canvas.drawPath(
      path,
      Paint()
        ..shader = Gradient.linear(
          from ?? b.centerLeft,
          to ?? b.centerRight,
          [light, light, dark],
          [0, 0.35, 1],
        ),
    );
  }

  // Shoulders and bodice: sloping shoulders, the dark stuff of her gown.
  final bodice = Path()
    ..moveTo(0.02 * w, 1.0 * h)
    ..quadraticBezierTo(0.06 * w, 0.76 * h, 0.26 * w, 0.71 * h)
    ..quadraticBezierTo(0.38 * w, 0.68 * h, 0.5 * w, 0.68 * h)
    ..quadraticBezierTo(0.62 * w, 0.68 * h, 0.74 * w, 0.71 * h)
    ..quadraticBezierTo(0.94 * w, 0.76 * h, 0.98 * w, 1.0 * h)
    ..close();
  shaded(bodice, const Color(0xFF5E5048), _bodice);
  // The neck, its shadow under the jaw.
  final neck = Path()
    ..moveTo(0.435 * w, 0.56 * h)
    ..lineTo(0.565 * w, 0.56 * h)
    ..quadraticBezierTo(0.57 * w, 0.64 * h, 0.6 * w, 0.69 * h)
    ..lineTo(0.4 * w, 0.69 * h)
    ..quadraticBezierTo(0.43 * w, 0.64 * h, 0.435 * w, 0.56 * h)
    ..close();
  shaded(neck, _skin, _skinShade);
  a.canvas.drawRect(
    Rect.fromLTRB(0.4 * w, 0.56 * h, 0.6 * w, 0.62 * h),
    Paint()
      ..shader = Gradient.linear(p(0, 0.56), p(0, 0.62), [
        const Color(0x77402818),
        const Color(0x00402818),
      ]),
  );
  // The kerchief over the shoulders, its ends crossed on the breast and
  // tucked into the bodice.
  for (final side in [1.0, -1.0]) {
    final fold = Path()
      ..moveTo((0.5 + side * 0.05) * w, 0.665 * h)
      ..quadraticBezierTo(
        (0.5 + side * 0.17) * w,
        0.665 * h,
        (0.5 + side * 0.28) * w,
        0.72 * h,
      )
      ..quadraticBezierTo(
        (0.5 + side * 0.3) * w,
        0.79 * h,
        (0.5 + side * 0.2) * w,
        0.83 * h,
      )
      ..quadraticBezierTo(
        (0.5 + side * 0.08) * w,
        0.88 * h,
        (0.5 - side * 0.07) * w,
        0.95 * h,
      )
      ..lineTo((0.5 - side * 0.03) * w, 0.8 * h)
      ..quadraticBezierTo(
        (0.5 + side * 0.03) * w,
        0.72 * h,
        (0.5 + side * 0.05) * w,
        0.665 * h,
      )
      ..close();
    shaded(fold, _linen, _linenShade);
    final folds = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.003
      ..color = const Color(0x55403830);
    a.canvas
      ..drawPath(fold, folds)
      ..drawPath(
        Path()
          ..moveTo((0.5 + side * 0.24) * w, 0.735 * h)
          ..quadraticBezierTo(
            (0.5 + side * 0.18) * w,
            0.8 * h,
            (0.5 + side * 0.04) * w,
            0.86 * h,
          ),
        folds,
      );
  }

  // The face: an oval narrowing to the chin, lit from the left.
  final face = Path()
    ..moveTo(0.5 * w, 0.27 * h)
    ..cubicTo(0.66 * w, 0.27 * h, 0.7 * w, 0.37 * h, 0.68 * w, 0.45 * h)
    ..cubicTo(0.66 * w, 0.53 * h, 0.59 * w, 0.595 * h, 0.5 * w, 0.6 * h)
    ..cubicTo(0.41 * w, 0.595 * h, 0.34 * w, 0.53 * h, 0.32 * w, 0.45 * h)
    ..cubicTo(0.3 * w, 0.37 * h, 0.34 * w, 0.27 * h, 0.5 * w, 0.27 * h)
    ..close();
  a.canvas
    ..drawPath(
      face,
      Paint()
        ..shader = Gradient.linear(
          p(0.33, 0.4),
          p(0.68, 0.45),
          [const Color(0xFFF0D2B6), _skin, _skinShade],
          [0, 0.45, 1],
        ),
    )
    ..save()
    ..clipPath(face);
  // The cheeks' colour, the shadow along the far side of the jaw.
  final blush = Paint()
    ..color = const Color(0x40C8604A)
    ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.035);
  final soft = Paint()
    ..color = const Color(0x22603020)
    ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.02);
  a.canvas
    ..drawCircle(p(0.4, 0.49), w * 0.05, blush)
    ..drawCircle(p(0.6, 0.49), w * 0.045, blush)
    // Under the eyes, beside the nose, under the lip.
    ..drawOval(
      Rect.fromCenter(
        center: p(0.43, 0.45),
        width: w * 0.07,
        height: h * 0.012,
      ),
      soft,
    )
    ..drawOval(
      Rect.fromCenter(
        center: p(0.58, 0.45),
        width: w * 0.07,
        height: h * 0.012,
      ),
      soft,
    )
    ..drawOval(
      Rect.fromCenter(center: p(0.5, 0.578), width: w * 0.05, height: h * 0.01),
      soft,
    )
    // Light on the brow, the cheekbone and the chin.
    ..drawCircle(
      p(0.44, 0.33),
      w * 0.06,
      Paint()
        ..color = const Color(0x22FFF4E6)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.03),
    )
    ..drawCircle(
      p(0.49, 0.59),
      w * 0.02,
      Paint()
        ..color = const Color(0x22FFF4E6)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.01),
    )
    ..drawPath(
      Path()
        ..moveTo(0.62 * w, 0.3 * h)
        ..quadraticBezierTo(0.7 * w, 0.45 * h, 0.52 * w, 0.62 * h)
        ..lineTo(0.7 * w, 0.62 * h)
        ..lineTo(0.7 * w, 0.3 * h)
        ..close(),
      Paint()
        ..color = const Color(0x33402418)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.02),
    )
    ..restore();

  // Hair parted in the middle, swept back over the temples under the cap.
  final hair = Path()
    ..moveTo(0.32 * w, 0.42 * h)
    ..cubicTo(0.3 * w, 0.32 * h, 0.38 * w, 0.27 * h, 0.5 * w, 0.27 * h)
    ..cubicTo(0.62 * w, 0.27 * h, 0.7 * w, 0.32 * h, 0.68 * w, 0.42 * h)
    ..cubicTo(0.66 * w, 0.35 * h, 0.6 * w, 0.31 * h, 0.505 * w, 0.305 * h)
    ..lineTo(0.495 * w, 0.305 * h)
    ..cubicTo(0.4 * w, 0.31 * h, 0.34 * w, 0.35 * h, 0.32 * w, 0.42 * h)
    ..close();
  shaded(hair, const Color(0xFF7A5236), _hair);
  for (var k = 0; k < 4; k++) {
    for (final side in [-1.0, 1.0]) {
      a.canvas.drawPath(
        Path()
          ..moveTo(0.5 * w, (0.285 + k * 0.004) * h)
          ..quadraticBezierTo(
            (0.5 + side * (0.1 + k * 0.02)) * w,
            (0.29 + k * 0.01) * h,
            (0.5 + side * (0.16 + k * 0.01)) * w,
            (0.35 + k * 0.015) * h,
          ),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.0025
          ..color = const Color(0x663A2416),
      );
    }
  }

  // The lappets: two linen bands from the cap, falling behind the cheeks.
  for (final side in [-1.0, 1.0]) {
    final lappet = Path()
      ..moveTo((0.5 + side * 0.19) * w, 0.3 * h)
      ..quadraticBezierTo(
        (0.5 + side * 0.215) * w,
        0.45 * h,
        (0.5 + side * 0.19) * w,
        0.58 * h,
      )
      ..quadraticBezierTo(
        (0.5 + side * 0.215) * w,
        0.6 * h,
        (0.5 + side * 0.235) * w,
        0.585 * h,
      )
      ..quadraticBezierTo(
        (0.5 + side * 0.255) * w,
        0.44 * h,
        (0.5 + side * 0.235) * w,
        0.3 * h,
      )
      ..close();
    shaded(lappet, _linen, _linenShade);
  }
  // The cap: a soft linen crown gathered over the back of the head, a
  // ruffled band framing the brow.
  final crown = Path()
    ..moveTo(0.29 * w, 0.33 * h)
    ..cubicTo(0.24 * w, 0.22 * h, 0.34 * w, 0.14 * h, 0.5 * w, 0.14 * h)
    ..cubicTo(0.66 * w, 0.14 * h, 0.76 * w, 0.22 * h, 0.71 * w, 0.33 * h)
    ..quadraticBezierTo(0.5 * w, 0.255 * h, 0.29 * w, 0.33 * h)
    ..close();
  shaded(crown, _linen, _linenShade);
  for (final (x0, y0, x1, y1) in [
    (0.34, 0.2, 0.4, 0.27),
    (0.42, 0.16, 0.46, 0.25),
    (0.54, 0.16, 0.54, 0.25),
    (0.64, 0.2, 0.6, 0.27),
  ]) {
    a.canvas.drawPath(
      Path()
        ..moveTo(x0 * w, y0 * h)
        ..quadraticBezierTo(
          (x0 + x1) / 2 * w,
          (y0 + y1) / 2 * h + h * 0.01,
          x1 * w,
          y1 * h,
        ),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.004
        ..color = const Color(0x557A7470),
    );
  }
  // The ruffle: a scalloped edge round the face.
  final ruffle = Path()..moveTo(0.28 * w, 0.345 * h);
  const scallops = 14;
  double edgeY(double t) => 0.345 - 0.09 * math.sin(math.pi * t);
  for (var i = 0; i < scallops; i++) {
    final t0 = i / scallops;
    final t1 = (i + 1) / scallops;
    final x0 = 0.28 + 0.44 * t0;
    final x1 = 0.28 + 0.44 * t1;
    ruffle.quadraticBezierTo(
      (x0 + x1) / 2 * w,
      (edgeY((t0 + t1) / 2) - 0.022) * h,
      x1 * w,
      edgeY(t1) * h,
    );
  }
  ruffle
    ..lineTo(0.69 * w, 0.36 * h)
    ..cubicTo(0.66 * w, 0.29 * h, 0.58 * w, 0.27 * h, 0.5 * w, 0.27 * h)
    ..cubicTo(0.42 * w, 0.27 * h, 0.34 * w, 0.29 * h, 0.31 * w, 0.36 * h)
    ..close();
  shaded(ruffle, const Color(0xFFF8F2E8), _linenShade);
  a.canvas.drawPath(
    ruffle,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.003
      ..color = const Color(0x66605850),
  );

  // Brows.
  final brow = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..color = const Color(0xFF4A3020);
  for (final side in [-1.0, 1.0]) {
    a.canvas.drawPath(
      Path()
        ..moveTo((0.5 + side * 0.035) * w, 0.385 * h)
        ..quadraticBezierTo(
          (0.5 + side * 0.08) * w,
          0.37 * h,
          (0.5 + side * 0.125) * w,
          0.385 * h,
        ),
      brow..strokeWidth = w * 0.009,
    );
  }
  // Eyes: lids, whites, brown irises turned to the viewer, a glint.
  for (final side in [-1.0, 1.0]) {
    final c = p(0.5 + side * 0.078, 0.425);
    final eye = Path()
      ..moveTo(c.dx - w * 0.042, c.dy)
      ..quadraticBezierTo(c.dx, c.dy - h * 0.022, c.dx + w * 0.042, c.dy)
      ..quadraticBezierTo(c.dx, c.dy + h * 0.016, c.dx - w * 0.042, c.dy)
      ..close();
    a.canvas
      ..drawPath(eye, Paint()..color = const Color(0xFFF4EEE6))
      ..save()
      ..clipPath(eye)
      ..drawCircle(
        c.translate(-side * w * 0.004, 0),
        w * 0.019,
        Paint()
          ..shader = Gradient.radial(c, w * 0.02, [
            const Color(0xFF8A5A34),
            const Color(0xFF4A2E1C),
          ]),
      )
      ..drawCircle(
        c.translate(-side * w * 0.004, 0),
        w * 0.008,
        Paint()..color = const Color(0xFF140C08),
      )
      ..restore()
      ..drawCircle(
        c.translate(-side * w * 0.004 - w * 0.007, -h * 0.005),
        w * 0.004,
        Paint()..color = const Color(0xEEFFFFFF),
      )
      ..drawPath(
        Path()
          ..moveTo(c.dx - w * 0.045, c.dy + h * 0.001)
          ..quadraticBezierTo(
            c.dx,
            c.dy - h * 0.024,
            c.dx + w * 0.045,
            c.dy + h * 0.002,
          ),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = w * 0.007
          ..color = const Color(0xFF2A1A12),
      )
      ..drawPath(
        Path()
          ..moveTo(c.dx - w * 0.03, c.dy + h * 0.012)
          ..quadraticBezierTo(
            c.dx,
            c.dy + h * 0.019,
            c.dx + w * 0.03,
            c.dy + h * 0.011,
          ),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.003
          ..color = const Color(0x664A3020),
      );
  }
  // The nose: light down its bridge, shadow on the far side, the nostrils.
  a.canvas
    ..drawPath(
      Path()
        ..moveTo(0.515 * w, 0.43 * h)
        ..quadraticBezierTo(0.54 * w, 0.48 * h, 0.535 * w, 0.505 * h)
        ..quadraticBezierTo(0.51 * w, 0.52 * h, 0.49 * w, 0.512 * h),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = w * 0.007
        ..color = const Color(0x99996448),
    )
    ..drawLine(
      p(0.495, 0.44),
      p(0.493, 0.49),
      Paint()
        ..strokeCap = StrokeCap.round
        ..strokeWidth = w * 0.008
        ..color = const Color(0x55FFF4E8),
    );
  for (final x in [0.482, 0.522]) {
    a.canvas.drawOval(
      Rect.fromCenter(center: p(x, 0.51), width: w * 0.012, height: h * 0.006),
      Paint()..color = const Color(0x886A3A28),
    );
  }
  // The mouth: closed, the corners lifted a little.
  final upper = Path()
    ..moveTo(0.455 * w, 0.548 * h)
    ..quadraticBezierTo(0.48 * w, 0.538 * h, 0.5 * w, 0.543 * h)
    ..quadraticBezierTo(0.52 * w, 0.538 * h, 0.545 * w, 0.548 * h)
    ..quadraticBezierTo(0.5 * w, 0.552 * h, 0.455 * w, 0.548 * h)
    ..close();
  final lower = Path()
    ..moveTo(0.462 * w, 0.55 * h)
    ..quadraticBezierTo(0.5 * w, 0.554 * h, 0.538 * w, 0.55 * h)
    ..quadraticBezierTo(0.5 * w, 0.568 * h, 0.462 * w, 0.55 * h)
    ..close();
  a.canvas
    ..drawPath(upper, Paint()..color = const Color(0xFFA85A4C))
    ..drawPath(lower, Paint()..color = const Color(0xFFC07264))
    ..drawLine(
      p(0.49, 0.556),
      p(0.51, 0.556),
      Paint()
        ..strokeCap = StrokeCap.round
        ..strokeWidth = w * 0.005
        ..color = const Color(0x55FFFFFF),
    )
    ..drawLine(
      p(0.455, 0.549),
      p(0.545, 0.549),
      Paint()
        ..strokeCap = StrokeCap.round
        ..strokeWidth = w * 0.004
        ..color = const Color(0xAA5A2A20),
    );

  // Old varnish: a warm veil, darker at the edges, fine cracks.
  a.canvas
    ..drawRect(
      oval,
      Paint()
        ..shader = Gradient.radial(
          p(0.45, 0.45),
          w * 0.6,
          [
            const Color(0x00000000),
            const Color(0x22301808),
            const Color(0x88140A04),
          ],
          [0, 0.6, 1],
        ),
    )
    ..drawRect(oval, Paint()..color = const Color(0x14C89A40));
  final random = math.Random(1720);
  for (var i = 0; i < 40; i++) {
    final s = p(random.nextDouble(), random.nextDouble());
    final angle = random.nextDouble() * math.pi;
    final len = w * (0.02 + random.nextDouble() * 0.04);
    a.canvas.drawLine(
      s,
      s + Offset(math.cos(angle), math.sin(angle)) * len,
      Paint()
        ..strokeWidth = w * 0.0015
        ..color = const Color(0x22000000),
    );
  }
  a.canvas.restore();
}
