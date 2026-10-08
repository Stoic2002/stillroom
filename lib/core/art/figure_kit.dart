import 'dart:math' as math;
import 'dart:ui';

import 'art_kit.dart';

/// People drawn with a body and a face (2026-10-08: the developer found the
/// faceless, shapeless echoes thin). A figure stands in its own rect, feet
/// at the bottom, lit from the left. [paintFigure] draws it as an echo:
/// a little translucent and cool, with a pale rim, so it still reads as a
/// memory of the place.

/// What a figure wears on the head.
enum Hat {
  none,
  souwester,
  tricorn,
  helmet,
  flatCap,
  bowler,
  pointedCap,
  turban,
  wideBrim,
  furHat,
  flapCap,
  hardHat,
  headcloth,
  hood,
  cushion,
  roundCap,
  headband,

  /// A linen cap gathered over the head, a ruffle round the face.
  mobCap,
}

/// Where an arm is: its elbow and hand.
enum Pose {
  /// Hanging at the side.
  down,

  /// Held a little out and down, carrying something that hangs (a lantern).
  out,

  /// The hand at the chest.
  chest,

  /// The hand up at the shoulder, steadying a load or a shouldered pole.
  shoulder,

  /// Raised above the head.
  high,

  /// The hand at the mouth.
  mouth,

  /// Gripping a long tool in front, high.
  grip,

  /// Gripping a long tool in front, low.
  low,
}

/// What a figure carries.
enum Prop {
  lantern,
  keys,
  basket,
  ladle,
  composingStick,
  clipboard,
  spear,
  oilLamp,
  block,
  rifle,
  probe,
  print,
  trowel,
  broom,
  trumpet,
  spade,
  rope,
  tablet,
  charcoal,
  stone,
}

/// A person's look: skin, hair, clothes, how they stand, what they carry.
final class Figure {
  const Figure({
    required this.top,
    this.skin = const Color(0xFFD9AE8C),
    this.hair = const Color(0xFF3A2A1E),
    this.longHair = false,
    this.hat = Hat.none,
    this.hatColor = const Color(0xFF2A2420),
    this.hem = 0.74,
    this.sleeves,
    this.inner,
    this.bareChest = false,
    this.wrap,
    this.legs = const Color(0xFF3A3430),
    this.breeches = false,
    this.stockings,
    this.shoes = const Color(0xFF1E1A18),
    this.apron,
    this.cape,
    this.stole,
    this.belt,
    this.buttons,
    this.left = Pose.down,
    this.right = Pose.down,
    this.props = const [],
    this.lean = 0,
    this.child = false,
    this.mask = false,
  });

  final Color skin;
  final Color hair;
  final bool longHair;
  final Hat hat;
  final Color hatColor;

  /// The coat, robe, tunic or jacket.
  final Color top;

  /// How far down the [top] reaches (0.5 the hip, 0.74 the knee, 0.92 the
  /// ankle).
  final double hem;

  /// The sleeves, if not of [top] (the skin for bare arms).
  final Color? sleeves;

  /// A shirt or waistcoat showing down the front.
  final Color? inner;

  /// Bare from the waist up.
  final bool bareChest;

  /// A cloth wrapped from the waist to [hem] (a sarong, a loincloth).
  final Color? wrap;

  /// Trousers, or the skin for bare legs.
  final Color legs;

  /// Wide breeches to the knee, [stockings] below.
  final bool breeches;
  final Color? stockings;

  /// Shoes, or null for bare feet.
  final Color? shoes;
  final Color? apron;
  final Color? cape;

  /// A band from one shoulder across the body.
  final Color? stole;
  final Color? belt;
  final Color? buttons;
  final Pose left;
  final Pose right;
  final List<Prop> props;

  /// Leaning forward (radians), as into a load.
  final double lean;

  /// A child: a bigger head for the body.
  final bool child;

  /// The face hidden by a black mask.
  final bool mask;
}

const _echoTint = Color(0xFFD5DEE2);
const _ink = Art.outline;
const _lampLight = Color(0xFFF2C66A);

/// Draws [f] standing in [a]'s rect as an echo: the figure itself, a cool
/// veil over it, and a pale halo behind.
void paintFigure(Art a, Figure f, {bool echo = true}) {
  // Room round the rect for what sticks out of it: a spear, a lamp's glow.
  final bounds = (Offset.zero & a.size).inflate(a.size.width * 0.6);
  // Its shadow on the floor, under the feet.
  a.canvas.drawOval(
    a.r(0.06, 0.955, 0.88, 0.04),
    Paint()
      ..color = const Color(0x55000000)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, a.size.width * 0.05),
  );
  if (echo) {
    a.canvas
      ..drawOval(
        a.r(0.05, 0.02, 0.9, 0.95),
        Paint()
          ..color = _echoTint.withValues(alpha: 0.16)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, a.size.width * 0.18),
      )
      ..saveLayer(bounds, Paint()..color = const Color(0xE6FFFFFF));
  } else {
    a.canvas.save();
  }
  if (f.lean != 0) {
    // Leaning about the feet, shifted back so the figure stays in its rect.
    final foot = a.p(0.5, 0.97);
    a.canvas
      ..translate(-math.sin(f.lean) * a.size.height * 0.45, 0)
      ..translate(foot.dx, foot.dy)
      ..rotate(f.lean)
      ..translate(-foot.dx, -foot.dy);
  }
  _Painter(a, f).paint();
  if (echo) {
    a.canvas.drawRect(
      bounds,
      Paint()
        ..blendMode = BlendMode.srcATop
        ..shader = Gradient.linear(Offset.zero, Offset(0, a.size.height), [
          _echoTint.withValues(alpha: 0.3),
          _echoTint.withValues(alpha: 0.1),
        ]),
    );
  }
  a.canvas.restore();
}

final class _Painter {
  _Painter(this.a, this.f)
    : w = a.size.width,
      h = a.size.height,
      lineW = a.size.width * 0.018;

  final Art a;
  final Figure f;
  final double w;
  final double h;
  final double lineW;

  Canvas get c => a.canvas;
  Offset p(double x, double y) => Offset(x * w, y * h);
  Path poly(List<(double, double)> pts) =>
      Path()..addPolygon([for (final (x, y) in pts) p(x, y)], true);

  /// The head's box: bigger for a child.
  Rect get head => f.child
      ? Rect.fromLTRB(0.3 * w, 0.025 * h, 0.7 * w, 0.17 * h)
      : Rect.fromLTRB(0.34 * w, 0.03 * h, 0.66 * w, 0.145 * h);
  double get shoulderY => f.child ? 0.2 : 0.17;

  void outline(Path path) => c.drawPath(
    path,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineW
      ..strokeJoin = StrokeJoin.round
      ..color = _ink,
  );

  /// Fills [path], shades its right side (the light is from the left), and
  /// inks it.
  void fill(Path path, Color color, {double shade = 0.38}) {
    c.drawPath(path, Paint()..color = color);
    final b = path.getBounds();
    c
      ..save()
      ..clipPath(path)
      ..drawRect(
        b,
        Paint()
          ..shader = Gradient.linear(
            b.centerLeft,
            b.centerRight,
            [
              const Color(0x1AFFFFFF),
              const Color(0x00000000),
              Color.fromRGBO(0, 0, 0, shade),
            ],
            [0, 0.45, 1],
          ),
      )
      ..restore();
    outline(path);
  }

  void line(Offset from, Offset to, Color color, double width) => c.drawLine(
    from,
    to,
    Paint()
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..color = color,
  );

  /// A thick stroke inked round: a pole, a limb.
  void stick(List<Offset> points, Color color, double width) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final q in points.skip(1)) {
      path.lineTo(q.dx, q.dy);
    }
    c
      ..drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = width + lineW * 2
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = _ink,
      )
      ..drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = width
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = color,
      );
  }

  /// The elbow and hand of an arm in [pose]; the left mirrors the right.
  (Offset, Offset) arm(Pose pose, {required bool right}) {
    final (ex, ey, hx, hy) = switch (pose) {
      Pose.down => (0.8, 0.36, 0.8, 0.53),
      Pose.out => (0.86, 0.35, 0.88, 0.5),
      Pose.chest => (0.8, 0.37, 0.58, 0.35),
      Pose.shoulder => (0.9, 0.28, 0.8, 0.13),
      Pose.high => (0.9, 0.14, 0.84, 0.03),
      Pose.mouth => (0.84, 0.28, 0.6, 0.13),
      Pose.grip => (0.86, 0.32, 0.74, 0.42),
      Pose.low => (0.84, 0.4, 0.66, 0.56),
    };
    final mx = right ? 1.0 : -1.0;
    Offset at(double x, double y) => p(0.5 + (x - 0.5) * mx, y);
    return (at(ex, ey), at(hx, hy));
  }

  Offset hand({required bool right}) =>
      arm(right ? f.right : f.left, right: right).$2;

  void paint() {
    _legs();
    _torso();
    _heldBehind();
    for (final right in [false, true]) {
      _arm(right: right);
    }
    _head();
    _hat();
    _held();
  }

  Path quad(
    double x0,
    double y0,
    double x1,
    double y1,
    double x2,
    double y2,
    double x3,
    double y3,
  ) => poly([(x0, y0), (x1, y1), (x2, y2), (x3, y3)]);

  void _legs() {
    final hem = f.hem;
    for (final (x0, x1) in [(0.3, 0.48), (0.52, 0.7)]) {
      if (f.breeches) {
        fill(
          quad(
            x0 - 0.04,
            0.5,
            x1 + 0.04,
            0.5,
            x1 + 0.02,
            0.76,
            x0 - 0.02,
            0.76,
          ),
          f.legs,
        );
        fill(
          quad(
            x0 + 0.02,
            0.76,
            x1 - 0.02,
            0.76,
            x1 - 0.03,
            0.93,
            x0 + 0.04,
            0.93,
          ),
          f.stockings ?? f.legs,
          shade: 0.3,
        );
      } else {
        final top = math.min(0.5, hem);
        fill(quad(x0, top, x1, top, x1 - 0.02, 0.93, x0 + 0.03, 0.93), f.legs);
        if (f.stockings != null) {
          fill(
            quad(
              x0 + 0.01,
              0.78,
              x1 - 0.01,
              0.78,
              x1 - 0.02,
              0.93,
              x0 + 0.03,
              0.93,
            ),
            f.stockings!,
            shade: 0.3,
          );
        }
      }
      final foot = Path()
        ..addOval(
          Rect.fromLTRB((x0 - 0.02) * w, 0.915 * h, (x1 + 0.05) * w, 0.975 * h),
        );
      fill(foot, f.shoes ?? f.skin, shade: 0.2);
    }
  }

  void _torso() {
    final sy = shoulderY;
    final hem = f.hem;
    final flare = hem > 0.8 ? 0.1 : (hem > 0.6 ? 0.12 : 0.2);
    final body = Path()
      ..moveTo(0.36 * w, (sy - 0.005) * h)
      ..quadraticBezierTo(0.18 * w, sy * h, 0.17 * w, (sy + 0.07) * h)
      ..lineTo(0.22 * w, 0.46 * h)
      ..lineTo(flare * w, hem * h)
      ..quadraticBezierTo(0.5 * w, (hem + 0.025) * h, (1 - flare) * w, hem * h)
      ..lineTo(0.78 * w, 0.46 * h)
      ..lineTo(0.83 * w, (sy + 0.07) * h)
      ..quadraticBezierTo(0.82 * w, sy * h, 0.64 * w, (sy - 0.005) * h)
      ..close();
    if (f.bareChest) {
      final chest = Path()
        ..moveTo(0.36 * w, (sy - 0.005) * h)
        ..quadraticBezierTo(0.18 * w, sy * h, 0.17 * w, (sy + 0.07) * h)
        ..lineTo(0.26 * w, 0.5 * h)
        ..lineTo(0.74 * w, 0.5 * h)
        ..lineTo(0.83 * w, (sy + 0.07) * h)
        ..quadraticBezierTo(0.82 * w, sy * h, 0.64 * w, (sy - 0.005) * h)
        ..close();
      fill(chest, f.skin, shade: 0.35);
    } else {
      fill(body, f.top);
    }
    if (f.inner != null) {
      fill(
        poly([
          (0.42, sy + 0.01),
          (0.58, sy + 0.01),
          (0.6, 0.46),
          (0.5, 0.5),
          (0.4, 0.46),
        ]),
        f.inner!,
        shade: 0.25,
      );
    }
    if (f.wrap != null) {
      fill(quad(0.24, 0.46, 0.76, 0.46, 0.8, hem, 0.2, hem), f.wrap!);
      line(
        p(0.6, 0.47),
        p(0.64, hem),
        Color.lerp(f.wrap, _ink, 0.4)!,
        lineW * 0.7,
      );
    }
    if (f.apron != null) {
      fill(
        quad(0.33, 0.3, 0.67, 0.3, 0.72, 0.82, 0.28, 0.82),
        f.apron!,
        shade: 0.3,
      );
    }
    if (f.cape != null) {
      fill(
        Path()
          ..moveTo(0.36 * w, (sy - 0.005) * h)
          ..quadraticBezierTo(0.14 * w, sy * h, 0.12 * w, 0.42 * h)
          ..quadraticBezierTo(0.5 * w, 0.46 * h, 0.88 * w, 0.42 * h)
          ..quadraticBezierTo(0.86 * w, sy * h, 0.64 * w, (sy - 0.005) * h)
          ..close(),
        f.cape!,
      );
    }
    if (f.stole != null) {
      fill(
        quad(0.3, sy + 0.005, 0.42, sy, 0.78, 0.52, 0.68, 0.56),
        f.stole!,
        shade: 0.3,
      );
    }
    if (f.belt != null) {
      fill(
        quad(0.22, 0.45, 0.78, 0.45, 0.78, 0.47, 0.22, 0.47),
        f.belt!,
        shade: 0.1,
      );
    }
    if (!f.bareChest && f.inner == null && f.apron == null) {
      line(
        p(0.5, sy + 0.03),
        p(0.5, hem),
        Color.lerp(f.top, _ink, 0.5)!,
        lineW * 0.7,
      );
    }
    if (f.buttons != null) {
      for (var i = 0; i < 5; i++) {
        c.drawCircle(
          p(0.455, sy + 0.06 + i * 0.05),
          w * 0.025,
          Paint()..color = f.buttons!,
        );
      }
    }
  }

  void _arm({required bool right}) {
    final pose = right ? f.right : f.left;
    final (elbow, at) = arm(pose, right: right);
    final shoulder = p(right ? 0.76 : 0.24, shoulderY + 0.035);
    final sleeve = f.bareChest ? f.skin : (f.sleeves ?? f.top);
    stick(
      [shoulder, elbow, at],
      Color.lerp(sleeve, _ink, right ? 0.14 : 0.04)!,
      w * 0.13,
    );
    fill(
      Path()..addOval(
        Rect.fromCenter(center: at, width: w * 0.13, height: h * 0.038),
      ),
      f.skin,
      shade: 0.3,
    );
  }

  void _head() {
    final hd = head;
    final chin = hd.bottom / h;
    fill(
      quad(
        0.44,
        chin - 0.02,
        0.56,
        chin - 0.02,
        0.57,
        shoulderY,
        0.43,
        shoulderY,
      ),
      Color.lerp(f.skin, _ink, 0.12)!,
    );
    if (f.longHair) {
      fill(
        Path()..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTRB(
              hd.left - w * 0.03,
              hd.top + hd.height * 0.3,
              hd.right + w * 0.03,
              hd.bottom + h * 0.04,
            ),
            Radius.circular(w * 0.08),
          ),
        ),
        f.hair,
        shade: 0.3,
      );
    }
    fill(Path()..addOval(hd), f.skin, shade: 0.32);
    if (f.hair != f.skin) {
      // Hair over the top of the head, down to the ears.
      c.drawPath(
        Path()
          ..moveTo(hd.left, hd.top + hd.height * 0.48)
          ..quadraticBezierTo(
            hd.left + hd.width * 0.04,
            hd.top,
            hd.center.dx,
            hd.top,
          )
          ..quadraticBezierTo(
            hd.right - hd.width * 0.04,
            hd.top,
            hd.right,
            hd.top + hd.height * 0.48,
          )
          ..lineTo(hd.right - hd.width * 0.12, hd.top + hd.height * 0.28)
          ..quadraticBezierTo(
            hd.center.dx,
            hd.top + hd.height * 0.18,
            hd.left + hd.width * 0.12,
            hd.top + hd.height * 0.28,
          )
          ..close(),
        Paint()..color = f.hair,
      );
    }
    if (f.mask) {
      // The black velvet mask over the face, two eyeholes.
      c.drawOval(
        Rect.fromLTRB(
          hd.left + hd.width * 0.08,
          hd.top + hd.height * 0.3,
          hd.right - hd.width * 0.08,
          hd.bottom - hd.height * 0.04,
        ),
        Paint()..color = const Color(0xFF141114),
      );
      for (final x in [0.36, 0.64]) {
        c.drawOval(
          Rect.fromCenter(
            center: Offset(hd.left + hd.width * x, hd.top + hd.height * 0.52),
            width: hd.width * 0.12,
            height: hd.height * 0.06,
          ),
          Paint()..color = const Color(0xFF3A3430),
        );
      }
    } else {
      faceIn(c, hd, f.skin);
    }
  }

  /// A path through points in the head's box (x, y fractions of it).
  Path _inHead(List<(double, double)> pts, {bool curved = false}) {
    final hd = head;
    Offset q((double, double) t) =>
        Offset(hd.left + hd.width * t.$1, hd.top + hd.height * t.$2);
    if (!curved) return Path()..addPolygon([for (final t in pts) q(t)], true);
    // Every two points after the first: a control point and an end.
    final path = Path()..moveTo(q(pts.first).dx, q(pts.first).dy);
    for (var i = 1; i + 1 < pts.length; i += 2) {
      final ctrl = q(pts[i]);
      final end = q(pts[i + 1]);
      path.quadraticBezierTo(ctrl.dx, ctrl.dy, end.dx, end.dy);
    }
    return path..close();
  }

  void _hat() {
    final hd = head;
    final col = f.hatColor;
    final dark = Color.lerp(col, _ink, 0.15)!;
    Path dome(double bottom, double top, {double inset = 0}) => _inHead([
      (inset, bottom),
      (inset + 0.02, top),
      (0.5, top),
      (0.98 - inset, top),
      (1 - inset, bottom),
    ], curved: true);
    Path band(double x0, double x1, double y0, double y1) =>
        _inHead([(x0, y0), (x1, y0), (x1, y1), (x0, y1)]);
    switch (f.hat) {
      case Hat.none:
        break;
      case Hat.souwester:
        fill(dome(0.4, -0.18), col, shade: 0.3);
        // The brim, long at the back, sloping down.
        fill(
          _inHead([
            (-0.3, 0.55),
            (0.5, 0.25),
            (1.35, 0.6),
            (1.38, 0.68),
            (1.4, 0.75),
            (0.5, 0.42),
            (-0.34, 0.7),
          ], curved: true),
          dark,
          shade: 0.3,
        );
      case Hat.tricorn:
        fill(
          _inHead([
            (-0.4, 0.3),
            (-0.1, -0.35),
            (0.5, -0.2),
            (1.1, -0.35),
            (1.4, 0.3),
            (0.5, 0.12),
            (-0.4, 0.3),
          ], curved: true),
          col,
          shade: 0.25,
        );
      case Hat.helmet:
        fill(dome(0.42, -0.55, inset: -0.05), col, shade: 0.3);
        fill(band(-0.15, 1.15, 0.36, 0.46), col, shade: 0.2);
        c.drawCircle(
          Offset(hd.center.dx, hd.top - hd.height * 0.05),
          hd.width * 0.09,
          Paint()..color = const Color(0xFFB8BCC0),
        );
      case Hat.flatCap:
        fill(
          _inHead([
            (-0.06, 0.38),
            (0.2, -0.1),
            (0.75, -0.02),
            (1.15, 0.1),
            (1.35, 0.4),
            (0.6, 0.34),
            (-0.06, 0.38),
          ], curved: true),
          col,
          shade: 0.3,
        );
      case Hat.bowler:
        fill(dome(0.32, -0.42, inset: 0.06), col, shade: 0.3);
        fill(
          _inHead([(-0.2, 0.3), (1.2, 0.3), (1.15, 0.4), (-0.15, 0.4)]),
          col,
          shade: 0.2,
        );
      case Hat.pointedCap:
        fill(
          _inHead([(-0.04, 0.4), (0.5, -0.8), (1.04, 0.4)]),
          col,
          shade: 0.3,
        );
        fill(band(-0.08, 1.08, 0.32, 0.44), dark, shade: 0.2);
      case Hat.turban:
        fill(
          Path()..addOval(
            Rect.fromLTRB(
              hd.left - hd.width * 0.12,
              hd.top - hd.height * 0.32,
              hd.right + hd.width * 0.12,
              hd.top + hd.height * 0.48,
            ),
          ),
          col,
          shade: 0.3,
        );
        for (var i = 0; i < 3; i++) {
          line(
            Offset(hd.left, hd.top + hd.height * (0.3 - i * 0.18)),
            Offset(hd.right, hd.top + hd.height * (0.0 - i * 0.18)),
            Color.lerp(col, _ink, 0.3)!,
            lineW * 0.6,
          );
        }
      case Hat.wideBrim:
        fill(dome(0.3, -0.35, inset: 0.1), col, shade: 0.3);
        fill(
          Path()..addOval(
            Rect.fromCenter(
              center: Offset(hd.center.dx, hd.top + hd.height * 0.32),
              width: hd.width * 2,
              height: hd.height * 0.24,
            ),
          ),
          dark,
          shade: 0.3,
        );
      case Hat.furHat:
        fill(
          Path()..addRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTRB(
                hd.left - hd.width * 0.1,
                hd.top - hd.height * 0.3,
                hd.right + hd.width * 0.1,
                hd.top + hd.height * 0.45,
              ),
              Radius.circular(hd.width * 0.3),
            ),
          ),
          col,
          shade: 0.3,
        );
      case Hat.flapCap:
        fill(dome(0.45, -0.3), col, shade: 0.3);
        for (final x in [-0.06, 0.88]) {
          fill(
            _inHead([
              (x, 0.35),
              (x + 0.18, 0.35),
              (x + 0.16, 0.8),
              (x + 0.02, 0.8),
            ]),
            dark,
            shade: 0.2,
          );
        }
      case Hat.hardHat:
        fill(dome(0.35, -0.4), col, shade: 0.3);
        fill(band(-0.15, 1.15, 0.3, 0.4), col, shade: 0.2);
      case Hat.headcloth:
        fill(
          _inHead([
            (-0.04, 0.42),
            (0.05, -0.15),
            (0.5, -0.15),
            (0.95, -0.15),
            (1.04, 0.42),
            (0.5, 0.25),
            (-0.04, 0.42),
          ], curved: true),
          col,
          shade: 0.3,
        );
      case Hat.hood:
        fill(
          _inHead([
            (-0.12, 1.0),
            (-0.2, -0.3),
            (0.5, -0.3),
            (1.2, -0.3),
            (1.12, 1.0),
            (1.04, 1.0),
            (0.95, 1.0),
            (0.95, 0.12),
            (0.5, 0.12),
            (0.05, 0.12),
            (0.05, 1.0),
          ], curved: true),
          col,
          shade: 0.3,
        );
      case Hat.cushion:
        fill(
          Path()..addRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTRB(
                hd.left - hd.width * 0.3,
                hd.top - hd.height * 0.24,
                hd.right + hd.width * 0.3,
                hd.top + hd.height * 0.14,
              ),
              Radius.circular(hd.height * 0.19),
            ),
          ),
          col,
          shade: 0.3,
        );
        // The cloth tying it on, under the chin.
        for (final x in [0.08, 0.92]) {
          line(
            Offset(hd.left + hd.width * x, hd.top + hd.height * 0.05),
            Offset(hd.left + hd.width * (0.5 + (x - 0.5) * 0.7), hd.bottom),
            const Color(0xFFD8CCB4),
            lineW * 1.2,
          );
        }
      case Hat.roundCap:
        fill(dome(0.38, -0.32, inset: -0.02), col, shade: 0.3);
      case Hat.headband:
        fill(band(0, 1, 0.24, 0.34), col, shade: 0.2);
      case Hat.mobCap:
        fill(dome(0.42, -0.42, inset: -0.12), col, shade: 0.22);
        // The ruffle framing the face, and the lappets at the sides.
        fill(
          _inHead([
            (-0.06, 0.46),
            (0.5, 0.05),
            (1.06, 0.46),
            (1.0, 0.3),
            (0.5, -0.08),
            (0.0, 0.3),
          ]),
          Color.lerp(col, const Color(0xFFFFFFFF), 0.3)!,
          shade: 0.15,
        );
        for (final x in [-0.1, 0.96]) {
          fill(
            _inHead([
              (x, 0.4),
              (x + 0.14, 0.4),
              (x + 0.12, 1.15),
              (x + 0.02, 1.15),
            ]),
            col,
            shade: 0.2,
          );
        }
    }
  }

  /// What is carried behind the arms: poles over the shoulder, a rope.
  void _heldBehind() {
    final at = hand(right: true);
    for (final prop in f.props) {
      switch (prop) {
        case Prop.spear:
          stick(
            [at.translate(-w * 0.2, h * 0.08), p(0.98, -0.02)],
            const Color(0xFF6A4E34),
            w * 0.05,
          );
          c.drawPath(
            poly([(0.95, 0.0), (1.02, -0.06), (1.0, 0.02)]),
            Paint()..color = const Color(0xFFB0B4B8),
          );
        case Prop.rifle:
          stick(
            [at.translate(-w * 0.08, h * 0.1), p(0.95, -0.03)],
            const Color(0xFF2A2420),
            w * 0.05,
          );
          stick(
            [
              at.translate(-w * 0.08, h * 0.1),
              at.translate(w * 0.02, h * 0.02),
            ],
            const Color(0xFF6A4226),
            w * 0.09,
          );
        case Prop.probe:
          stick(
            [
              Offset(at.dx + w * 0.04, -h * 0.02),
              Offset(at.dx + w * 0.06, 0.97 * h),
            ],
            const Color(0xFF8A8A8E),
            w * 0.04,
          );
        case Prop.rope:
          stick(
            [p(0.7, 0.22), p(0.98, 0.5), p(1.2, 0.8)],
            const Color(0xFF8A7A5A),
            w * 0.04,
          );
        default:
          break;
      }
    }
  }

  /// A box in fractions of the figure around [at] (dx0..dx1, dy0..dy1).
  Path near(Offset at, double dx0, double dy0, double dx1, double dy1) {
    final x = at.dx / w;
    final y = at.dy / h;
    return quad(
      x + dx0,
      y + dy0,
      x + dx1,
      y + dy0,
      x + dx1,
      y + dy1,
      x + dx0,
      y + dy1,
    );
  }

  /// What is carried in front: in the hands, on the shoulder, at the belt.
  void _held() {
    final at = hand(right: true);
    for (final prop in f.props) {
      switch (prop) {
        case Prop.lantern:
          c.drawCircle(
            at.translate(0, h * 0.08),
            w * 0.55,
            Paint()
              ..color = _lampLight.withValues(alpha: 0.35)
              ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.25),
          );
          line(at, at.translate(0, h * 0.03), _ink, lineW);
          final x = at.dx / w;
          final y = at.dy / h + 0.03;
          fill(
            quad(
              x - 0.1,
              y,
              x + 0.1,
              y,
              x + 0.12,
              y + 0.09,
              x - 0.12,
              y + 0.09,
            ),
            const Color(0xFFF2D27A),
            shade: 0.15,
          );
          fill(
            quad(
              x - 0.11,
              y - 0.012,
              x + 0.11,
              y - 0.012,
              x + 0.09,
              y + 0.004,
              x - 0.09,
              y + 0.004,
            ),
            const Color(0xFF2A2620),
            shade: 0.1,
          );
          fill(
            quad(
              x - 0.12,
              y + 0.09,
              x + 0.12,
              y + 0.09,
              x + 0.1,
              y + 0.115,
              x - 0.1,
              y + 0.115,
            ),
            const Color(0xFF2A2620),
            shade: 0.1,
          );
        case Prop.oilLamp:
          c.drawCircle(
            at.translate(0, -h * 0.02),
            w * 0.45,
            Paint()
              ..color = _lampLight.withValues(alpha: 0.4)
              ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.2),
          );
          fill(
            Path()..addOval(
              Rect.fromCenter(
                center: at.translate(0, -h * 0.012),
                width: w * 0.24,
                height: h * 0.022,
              ),
            ),
            const Color(0xFFA0643E),
            shade: 0.2,
          );
          c.drawOval(
            Rect.fromCenter(
              center: at.translate(w * 0.1, -h * 0.032),
              width: w * 0.05,
              height: h * 0.02,
            ),
            Paint()..color = const Color(0xFFFFE7A0),
          );
        case Prop.keys:
          final ring = p(0.3, 0.47);
          c.drawCircle(
            ring,
            w * 0.05,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = lineW
              ..color = const Color(0xFF6A6460),
          );
          for (final dx in [-0.03, 0.0, 0.03]) {
            line(
              ring.translate(dx * w, h * 0.012),
              ring.translate(dx * w * 1.6, h * 0.06),
              const Color(0xFF6A6460),
              lineW * 1.2,
            );
          }
        case Prop.basket:
          fill(
            near(at, -0.3, -0.05, 0.2, 0.035),
            const Color(0xFF9C7A4E),
            shade: 0.3,
          );
          c.drawOval(
            Rect.fromLTRB(
              at.dx - w * 0.3,
              at.dy - h * 0.065,
              at.dx + w * 0.2,
              at.dy - h * 0.035,
            ),
            Paint()..color = const Color(0xFF5A4A36),
          );
        case Prop.ladle:
          stick(
            [at.translate(-w * 0.1, -h * 0.06), p(0.95, 0.92)],
            const Color(0xFF5A4232),
            w * 0.05,
          );
          fill(
            Path()..addOval(
              Rect.fromCenter(
                center: p(0.95, 0.93),
                width: w * 0.22,
                height: h * 0.03,
              ),
            ),
            const Color(0xFF3A3A3A),
            shade: 0.2,
          );
        case Prop.composingStick:
          fill(
            near(hand(right: false), -0.02, -0.012, 0.2, 0.01),
            const Color(0xFF8A8A8E),
            shade: 0.2,
          );
        case Prop.clipboard:
          fill(
            quad(0.36, 0.28, 0.64, 0.28, 0.64, 0.42, 0.36, 0.42),
            const Color(0xFF8A6A44),
            shade: 0.2,
          );
          fill(
            quad(0.38, 0.295, 0.62, 0.295, 0.62, 0.41, 0.38, 0.41),
            const Color(0xFFF0EEE8),
            shade: 0.1,
          );
          for (var i = 0; i < 4; i++) {
            line(
              p(0.41, 0.315 + i * 0.022),
              p(0.59, 0.315 + i * 0.022),
              const Color(0x88404040),
              lineW * 0.4,
            );
          }
        case Prop.block || Prop.stone:
          fill(
            near(at, -0.36, -0.035, 0.12, 0.045),
            prop == Prop.block
                ? const Color(0xFFA9A190)
                : const Color(0xFF8A8478),
            shade: 0.35,
          );
        case Prop.print:
          fill(
            near(at, -0.16, -0.06, 0.12, 0.01),
            const Color(0xFFE8E4DA),
            shade: 0.1,
          );
          fill(
            near(at, -0.13, -0.05, 0.09, 0.0),
            const Color(0xFF5A5A5E),
            shade: 0.1,
          );
        case Prop.trowel:
          final x = at.dx / w;
          final y = at.dy / h;
          fill(
            poly([
              (x - 0.04, y + 0.01),
              (x + 0.06, y + 0.01),
              (x + 0.01, y + 0.07),
            ]),
            const Color(0xFF9A9CA0),
            shade: 0.2,
          );
        case Prop.broom:
          stick(
            [at.translate(w * 0.06, -h * 0.04), p(0.18, 0.92)],
            const Color(0xFFB8A070),
            w * 0.04,
          );
          fill(
            quad(0.24, 0.88, 0.3, 0.98, -0.06, 0.98, 0.12, 0.88),
            const Color(0xFF9A8A5A),
            shade: 0.2,
          );
        case Prop.trumpet:
          stick(
            [p(0.56, 0.12), Offset(at.dx + w * 0.34, at.dy - h * 0.01)],
            const Color(0xFFC8A04A),
            w * 0.035,
          );
          fill(
            near(at, 0.3, -0.035, 0.42, 0.02),
            const Color(0xFFD8B05A),
            shade: 0.2,
          );
        case Prop.spade:
          stick(
            [at.translate(w * 0.04, -h * 0.05), p(0.62, 0.86)],
            const Color(0xFF7A5634),
            w * 0.045,
          );
          fill(
            quad(0.52, 0.85, 0.74, 0.85, 0.7, 0.96, 0.56, 0.96),
            const Color(0xFF7A7E80),
            shade: 0.2,
          );
        case Prop.tablet:
          fill(
            quad(0.38, 0.3, 0.62, 0.3, 0.62, 0.38, 0.38, 0.38),
            const Color(0xFF2A2C30),
            shade: 0.1,
          );
          fill(
            quad(0.4, 0.31, 0.6, 0.31, 0.6, 0.37, 0.4, 0.37),
            const Color(0xFF6A9AB8),
            shade: 0.1,
          );
        case Prop.charcoal:
          line(
            at.translate(-w * 0.02, h * 0.01),
            at.translate(w * 0.08, -h * 0.02),
            const Color(0xFF15110D),
            lineW * 2.2,
          );
        default:
          break;
      }
    }
  }
}

/// A small face in [head] (the head's oval): brows, eyes, the nose's
/// shadow, a mouth, a little colour in the cheeks.
void faceIn(Canvas c, Rect head, Color skin) {
  final w = head.width;
  final h = head.height;
  Offset q(double x, double y) => Offset(head.left + w * x, head.top + h * y);
  final dark = Color.lerp(skin, _ink, 0.7)!;
  final cheek = Paint()
    ..color = const Color(0x33C0503A)
    ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.08);
  c
    ..drawCircle(q(0.3, 0.68), w * 0.11, cheek)
    ..drawCircle(q(0.7, 0.68), w * 0.11, cheek);
  final stroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeWidth = w * 0.045
    ..color = dark;
  c
    ..drawLine(q(0.24, 0.42), q(0.42, 0.4), stroke)
    ..drawLine(q(0.58, 0.4), q(0.76, 0.42), stroke);
  for (final x in [0.33, 0.67]) {
    c
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
  c
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
        ..color = Color.lerp(skin, _ink, 0.45)!,
    )
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
