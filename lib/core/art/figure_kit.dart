import 'dart:ui';

import 'art_kit.dart';

/// People drawn with a body and a face (2026-10-08: the developer found the
/// faceless, shapeless echoes thin). A figure stands in its own rect, feet
/// at the bottom, lit from the left; [paintFigure] draws it as an echo, a
/// little translucent and cool, with a pale rim, so it still reads as a
/// memory of the place.

/// What a figure wears on the head.
enum Hat { none, souwester, tricorn }

/// How long the coat is: to the hip, the knee, or the ankle.
enum CoatLength { hip, knee, ankle }

/// What a figure holds.
enum Prop { none, lantern, lanternAndKeys }

/// A person's look: skin, hair, clothes, what they carry.
final class Figure {
  const Figure({
    required this.coat,
    this.skin = const Color(0xFFD9AE8C),
    this.hair = const Color(0xFF4A3424),
    this.hat = Hat.none,
    this.hatColor = const Color(0xFF2A2420),
    this.coatLength = CoatLength.knee,
    this.waistcoat,
    this.legs = const Color(0xFF3A3430),
    this.stockings,
    this.shoes = const Color(0xFF1E1A18),
    this.buttons,
    this.prop = Prop.none,
  });

  final Color skin;
  final Color hair;
  final Hat hat;
  final Color hatColor;
  final Color coat;
  final CoatLength coatLength;

  /// A waistcoat showing between the coat's fronts, if any.
  final Color? waistcoat;

  /// Trousers or breeches.
  final Color legs;

  /// Stockings below knee breeches, if any (otherwise trousers to the foot).
  final Color? stockings;
  final Color shoes;

  /// Buttons down the coat's front, if any.
  final Color? buttons;
  final Prop prop;
}

const _echoTint = Color(0xFFD5DEE2);

/// Draws [f] standing in [a]'s rect, as an echo: the figure itself, then a
/// cool veil over it and a pale rim round it.
void paintFigure(Art a, Figure f, {bool echo = true}) {
  final bounds = Offset.zero & a.size;
  // Its shadow on the floor, under the feet.
  a.canvas.drawOval(
    a.r(0.08, 0.955, 0.84, 0.04),
    Paint()
      ..color = const Color(0x55000000)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, a.size.width * 0.05),
  );
  if (echo) {
    // A soft pale halo behind, the memory's glow.
    a.canvas.drawOval(
      a.r(0.05, 0.02, 0.9, 0.95),
      Paint()
        ..color = _echoTint.withValues(alpha: 0.18)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, a.size.width * 0.18),
    );
    a.canvas.saveLayer(bounds, Paint()..color = const Color(0xE6FFFFFF));
  } else {
    a.canvas.save();
  }
  _body(a, f);
  if (echo) {
    // A cool veil over the colours, lighter towards the top.
    a.canvas.drawRect(
      bounds,
      Paint()
        ..blendMode = BlendMode.srcATop
        ..shader = Gradient.linear(Offset.zero, Offset(0, a.size.height), [
          _echoTint.withValues(alpha: 0.32),
          _echoTint.withValues(alpha: 0.12),
        ]),
    );
  }
  a.canvas.restore();
}

/// Shade the right side of [path] (light from the left), within it.
void _shade(Art a, Path path, {double strength = 0.38, double from = 0.45}) {
  final b = path.getBounds();
  a.canvas
    ..save()
    ..clipPath(path)
    ..drawRect(
      b,
      Paint()
        ..shader = Gradient.linear(
          b.centerLeft,
          b.centerRight,
          [
            const Color(0x18FFFFFF),
            const Color(0x00000000),
            Color.fromRGBO(0, 0, 0, strength),
          ],
          [0, from, 1],
        ),
    )
    ..restore();
}

void _body(Art a, Figure f) {
  final w = a.size.width;
  final h = a.size.height;
  Offset p(double x, double y) => Offset(x * w, y * h);
  Path poly(List<(double, double)> pts) =>
      Path()..addPolygon([for (final (x, y) in pts) p(x, y)], true);
  final ink = Art.outline;
  final lineW = w * 0.018;
  void outline(Path path) => a.canvas.drawPath(
    path,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineW
      ..strokeJoin = StrokeJoin.round
      ..color = ink,
  );
  void fillPath(Path path, Color color, {double shade = 0.38}) {
    a.canvas.drawPath(path, Paint()..color = color);
    _shade(a, path, strength: shade);
    outline(path);
  }

  final hem = switch (f.coatLength) {
    CoatLength.hip => 0.55,
    CoatLength.knee => 0.74,
    CoatLength.ankle => 0.9,
  };

  // Legs: breeches and stockings, or trousers to the foot.
  for (final (x0, x1) in [(0.3, 0.48), (0.52, 0.7)]) {
    final leg = poly([
      (x0, 0.5),
      (x1, 0.5),
      (x1 - 0.02, 0.93),
      (x0 + 0.03, 0.93),
    ]);
    fillPath(leg, f.legs);
    if (f.stockings != null) {
      fillPath(
        poly([
          (x0 + 0.01, 0.76),
          (x1 - 0.01, 0.76),
          (x1 - 0.02, 0.93),
          (x0 + 0.03, 0.93),
        ]),
        f.stockings!,
        shade: 0.3,
      );
    }
    // The shoe.
    final shoe = Path()
      ..addOval(
        Rect.fromLTRB((x0 - 0.02) * w, 0.915 * h, (x1 + 0.04) * w, 0.975 * h),
      );
    fillPath(shoe, f.shoes, shade: 0.2);
  }

  // The coat: shoulders, body, flaring to its hem.
  final coat = Path()
    ..moveTo(0.34 * w, 0.165 * h)
    ..quadraticBezierTo(0.18 * w, 0.17 * h, 0.17 * w, 0.24 * h)
    ..lineTo(0.22 * w, 0.46 * h)
    ..lineTo(0.12 * w, hem * h)
    ..quadraticBezierTo(0.5 * w, (hem + 0.025) * h, 0.88 * w, hem * h)
    ..lineTo(0.78 * w, 0.46 * h)
    ..lineTo(0.83 * w, 0.24 * h)
    ..quadraticBezierTo(0.82 * w, 0.17 * h, 0.66 * w, 0.165 * h)
    ..close();
  fillPath(coat, f.coat);
  if (f.waistcoat != null) {
    fillPath(
      poly([(0.42, 0.18), (0.58, 0.18), (0.6, 0.46), (0.5, 0.5), (0.4, 0.46)]),
      f.waistcoat!,
      shade: 0.25,
    );
  }
  // The opening down the front, and the buttons.
  a.canvas.drawLine(
    p(0.5, 0.2),
    p(0.5, hem),
    Paint()
      ..strokeWidth = lineW * 0.8
      ..color = Color.lerp(f.coat, ink, 0.55)!,
  );
  if (f.buttons != null) {
    for (var i = 0; i < 5; i++) {
      a.canvas.drawCircle(
        p(0.455, 0.23 + i * 0.05),
        w * 0.025,
        Paint()..color = f.buttons!,
      );
    }
  }

  // Arms: the left down at the side, the right holding the lantern out.
  final leftArm = poly([
    (0.19, 0.2),
    (0.29, 0.21),
    (0.27, 0.38),
    (0.25, 0.52),
    (0.15, 0.52),
    (0.14, 0.38),
  ]);
  fillPath(leftArm, Color.lerp(f.coat, ink, 0.05)!);
  final rightArm = poly([
    (0.71, 0.21),
    (0.82, 0.2),
    (0.88, 0.36),
    (0.9, 0.48),
    (0.8, 0.5),
    (0.76, 0.37),
  ]);
  fillPath(rightArm, Color.lerp(f.coat, ink, 0.12)!);
  // Hands.
  for (final c in [p(0.2, 0.545), p(0.85, 0.52)]) {
    final hand = Path()
      ..addOval(Rect.fromCenter(center: c, width: w * 0.13, height: h * 0.04));
    fillPath(hand, f.skin, shade: 0.3);
  }

  // The neck, the head, the face.
  fillPath(
    poly([(0.44, 0.12), (0.56, 0.12), (0.57, 0.17), (0.43, 0.17)]),
    Color.lerp(f.skin, ink, 0.12)!,
  );
  final head = Path()
    ..addOval(Rect.fromLTRB(0.34 * w, 0.03 * h, 0.66 * w, 0.145 * h));
  fillPath(head, f.skin, shade: 0.32);
  // Hair under the hat, over the ears.
  a.canvas.drawPath(
    Path()
      ..moveTo(0.34 * w, 0.085 * h)
      ..quadraticBezierTo(0.35 * w, 0.03 * h, 0.5 * w, 0.03 * h)
      ..quadraticBezierTo(0.65 * w, 0.03 * h, 0.66 * w, 0.085 * h)
      ..lineTo(0.62 * w, 0.06 * h)
      ..quadraticBezierTo(0.5 * w, 0.05 * h, 0.38 * w, 0.06 * h)
      ..close(),
    Paint()..color = f.hair,
  );
  _face(a, Rect.fromLTRB(0.34 * w, 0.03 * h, 0.66 * w, 0.145 * h), f.skin);

  // The hat.
  switch (f.hat) {
    case Hat.none:
      break;
    case Hat.souwester:
      final brim = Path()
        ..moveTo(0.22 * w, 0.075 * h)
        ..quadraticBezierTo(0.5 * w, 0.045 * h, 0.8 * w, 0.085 * h)
        ..lineTo(0.84 * w, 0.105 * h)
        ..quadraticBezierTo(0.5 * w, 0.075 * h, 0.2 * w, 0.09 * h)
        ..close();
      final crown = Path()
        ..moveTo(0.34 * w, 0.07 * h)
        ..quadraticBezierTo(0.36 * w, 0.005 * h, 0.5 * w, 0.005 * h)
        ..quadraticBezierTo(0.64 * w, 0.005 * h, 0.66 * w, 0.07 * h)
        ..close();
      fillPath(crown, f.hatColor, shade: 0.3);
      fillPath(brim, Color.lerp(f.hatColor, ink, 0.1)!, shade: 0.3);
    case Hat.tricorn:
      final hat = Path()
        ..moveTo(0.22 * w, 0.06 * h)
        ..quadraticBezierTo(0.3 * w, 0.0, 0.5 * w, 0.012 * h)
        ..quadraticBezierTo(0.7 * w, 0.0, 0.78 * w, 0.06 * h)
        ..quadraticBezierTo(0.5 * w, 0.045 * h, 0.22 * w, 0.06 * h)
        ..close();
      fillPath(hat, f.hatColor, shade: 0.25);
  }

  // What they carry.
  if (f.prop == Prop.lantern || f.prop == Prop.lanternAndKeys) {
    final top = p(0.85, 0.53);
    a.canvas
      ..drawLine(
        top,
        top.translate(0, h * 0.03),
        Paint()
          ..strokeWidth = lineW
          ..color = ink,
      )
      ..drawCircle(
        top.translate(0, h * 0.08),
        w * 0.5,
        Paint()
          ..color = const Color(0x55F2C66A)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.25),
      );
    fillPath(
      poly([(0.75, 0.56), (0.95, 0.56), (0.97, 0.65), (0.73, 0.65)]),
      const Color(0xFFF2D27A),
      shade: 0.15,
    );
    fillPath(
      poly([(0.74, 0.55), (0.96, 0.55), (0.94, 0.565), (0.76, 0.565)]),
      const Color(0xFF2A2620),
      shade: 0.1,
    );
    fillPath(
      poly([(0.73, 0.65), (0.97, 0.65), (0.95, 0.675), (0.75, 0.675)]),
      const Color(0xFF2A2620),
      shade: 0.1,
    );
  }
  if (f.prop == Prop.lanternAndKeys) {
    // A ring of keys at the belt.
    final ring = p(0.3, 0.47);
    a.canvas.drawCircle(
      ring,
      w * 0.05,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = lineW
        ..color = const Color(0xFF6A6460),
    );
    for (final dx in [-0.03, 0.0, 0.03]) {
      a.canvas.drawLine(
        ring.translate(dx * w, h * 0.012),
        ring.translate(dx * w * 1.6, h * 0.06),
        Paint()
          ..strokeWidth = lineW * 1.2
          ..color = const Color(0xFF6A6460),
      );
    }
  }
}

/// A small face in [head] (the head's oval): brows, eyes, the nose's
/// shadow, a mouth, a little colour in the cheeks.
void _face(Art a, Rect head, Color skin) {
  final w = head.width;
  final h = head.height;
  Offset q(double x, double y) => Offset(head.left + w * x, head.top + h * y);
  final dark = Color.lerp(skin, Art.outline, 0.7)!;
  final cheek = Paint()
    ..color = const Color(0x33C0503A)
    ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.08);
  a.canvas
    ..drawCircle(q(0.3, 0.68), w * 0.11, cheek)
    ..drawCircle(q(0.7, 0.68), w * 0.11, cheek);
  final stroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeWidth = w * 0.045
    ..color = dark;
  // Brows.
  a.canvas
    ..drawLine(q(0.24, 0.42), q(0.42, 0.4), stroke)
    ..drawLine(q(0.58, 0.4), q(0.76, 0.42), stroke);
  // Eyes: a dark iris with a glint.
  for (final x in [0.33, 0.67]) {
    a.canvas
      ..drawOval(
        Rect.fromCenter(center: q(x, 0.53), width: w * 0.16, height: h * 0.1),
        Paint()..color = const Color(0xFFF2EAE0),
      )
      ..drawCircle(
        q(x, 0.535),
        w * 0.055,
        Paint()..color = const Color(0xFF2A1E18),
      )
      ..drawCircle(
        q(x - 0.02, 0.515),
        w * 0.018,
        Paint()..color = const Color(0xCCFFFFFF),
      )
      ..drawLine(
        q(x - 0.09, 0.5),
        q(x + 0.09, 0.5),
        stroke..strokeWidth = w * 0.035,
      );
  }
  // The nose: its shadow on the side away from the light.
  a.canvas
    ..drawPath(
      Path()
        ..moveTo(q(0.52, 0.52).dx, q(0.52, 0.52).dy)
        ..quadraticBezierTo(
          q(0.6, 0.7).dx,
          q(0.6, 0.7).dy,
          q(0.55, 0.76).dx,
          q(0.55, 0.76).dy,
        )
        ..lineTo(q(0.46, 0.76).dx, q(0.46, 0.76).dy),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = w * 0.035
        ..color = Color.lerp(skin, Art.outline, 0.45)!,
    )
    // The mouth.
    ..drawPath(
      Path()
        ..moveTo(q(0.38, 0.85).dx, q(0.38, 0.85).dy)
        ..quadraticBezierTo(
          q(0.5, 0.89).dx,
          q(0.5, 0.89).dy,
          q(0.62, 0.85).dx,
          q(0.62, 0.85).dy,
        ),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = w * 0.045
        ..color = const Color(0xFF8A4A40),
    );
}
