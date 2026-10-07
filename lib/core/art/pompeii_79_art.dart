import 'dart:math' as math;
import 'dart:ui';

import '../theme/stillroom_palette.dart';
import 'art_kit.dart';
import 'depth_kit.dart';
import 'echo_art.dart';

/// Code-drawn art for "Pompeii, 79" (docs/episodes/pompeii_79.md): a baker's
/// house as the diggers left it in 1863, pale and dusty under a mild sky,
/// and the same places through the lens, painted red and ochre under a
/// darkening bronze sky, the pine-shaped cloud over the mountain.
const _s = 'images/scenes/pompeii_79';
const _o = 'images/objects/pompeii_79';
const _i = 'images/items/pompeii_79';

final Map<String, ArtPainter> pompeiiArt = {
  // Scenes (1863) and what the lens shows (79).
  '$_s/street.png': (c, s) => _street(Art(c, s)),
  '$_s/street_79.png': (c, s) => _street79(Art(c, s)),
  '$_s/hut.png': (c, s) => _hut(Art(c, s)),
  '$_s/bakery.png': (c, s) => _bakery(Art(c, s)),
  '$_s/bakery_79.png': (c, s) => _bakery79(Art(c, s)),
  '$_s/atrium.png': (c, s) => _atrium(Art(c, s)),
  '$_s/atrium_79_morning.png': (c, s) => _atrium79(Art(c, s), _Hour.morning),
  '$_s/atrium_79_noon.png': (c, s) => _atrium79(Art(c, s), _Hour.noon),
  '$_s/atrium_79.png': (c, s) => _atrium79(Art(c, s), _Hour.afternoon),
  '$_s/garden.png': (c, s) => _garden(Art(c, s)),
  '$_s/garden_79.png': (c, s) => _garden79(Art(c, s)),
  // Puzzle boards.
  '$_s/tracing_board.png': (c, s) => _tracingBoard(Art(c, s)),
  '$_s/label_section.png': (c, s) => _labelSection(Art(c, s)),
  '$_s/fresco_board.png': (c, s) => _frescoBoard(Art(c, s)),
  '$_s/tablet_board.png': (c, s) => _tabletBoard(Art(c, s)),
  // Objects.
  '$_o/ash_bank_sprite.png': (c, s) => _ashBank(Art(c, s)),
  '$_o/lens_sprite.png': (c, s) => _lens(Art(c, s)),
  '$_o/shovel_sprite.png': (c, s) => _shovel(Art(c, s)),
  '$_o/oven_open_sprite.png': (c, s) => _ovenOpen(Art(c, s)),
  '$_o/tracings_sprite.png': (c, s) => _tube(Art(c, s)),
  '$_o/tracings_done_sprite.png': (c, s) => _drawingDone(Art(c, s)),
  '$_o/label_sprite.png': (c, s) => _labelTag(Art(c, s)),
  '$_o/horse_sprite.png': (c, s) => _horse(Art(c, s)),
  '$_o/sheet_boat.png': (c, s) => _sheet(Art(c, s), _boat),
  '$_o/sheet_people.png': (c, s) => _sheet(Art(c, s), _people),
  '$_o/sheet_words.png': (c, s) => _sheet(Art(c, s), _words),
  '$_o/echo_digger.png': (c, s) => paintEcho(Art(c, s), EchoFigure.digger),
  '$_o/echo_citizens.png': (c, s) => _group(Art(c, s), const [
    (EchoFigure.citizen, 0.0, 0.0, 0.3, 1.0),
    (EchoFigure.citizen, 0.34, 0.06, 0.28, 0.94),
    (EchoFigure.passerby, 0.68, 0.02, 0.3, 0.98),
  ]),
  '$_o/echo_family.png': (c, s) => _group(Art(c, s), const [
    (EchoFigure.cushioned, 0.0, 0.0, 0.56, 1.0),
    (EchoFigure.child, 0.52, 0.34, 0.46, 0.66),
  ]),
  '$_o/echo_mother.png': (c, s) => paintEcho(Art(c, s), EchoFigure.cushioned),
  '$_o/echo_child_play.png': (c, s) => paintEcho(Art(c, s), EchoFigure.girl),
  '$_o/echo_family_noon.png': (c, s) => _group(Art(c, s), const [
    (EchoFigure.citizen, 0.0, 0.0, 0.34, 1.0),
    (EchoFigure.citizen, 0.32, 0.03, 0.32, 0.97),
    (EchoFigure.girl, 0.66, 0.4, 0.28, 0.6),
  ]),
  '$_o/fresco_fallen_sprite.png': (c, s) => _frescoFallen(Art(c, s)),
  '$_o/fresco_whole_sprite.png': (c, s) => _fresco(Art(c, s)),
  for (var i = 0; i < 6; i++)
    '$_o/fresco_piece_${i + 1}.png': (c, s) => _frescoPiece(Art(c, s), i),
  '$_o/arca_closed_sprite.png': (c, s) => _arca(Art(c, s), open: false),
  '$_o/arca_open_sprite.png': (c, s) => _arca(Art(c, s), open: true),
  '$_o/wax_tablet_surface.png': (c, s) => _tabletSurface(Art(c, s)),
  '$_o/wax_tablet_marks.png': (c, s) => _tabletMarks(Art(c, s)),
  '$_o/sheet_gate.png': (c, s) => _sheet(Art(c, s), _gate),
  // Items.
  '$_i/era_lens.png': (c, s) => _lens(Art(c, s)),
  '$_i/shovel.png': (c, s) => _shovelIcon(Art(c, s)),
  '$_i/tracings.png': (c, s) => _tube(Art(c, s)),
  '$_i/arca_key.png': (c, s) => _key(Art(c, s)),
  '$_i/wax_tablet.png': (c, s) => _tabletSurface(Art(c, s)),
  // The jar on the shelf.
  'images/ui/jar_pompeii_79.png': (c, s) => _jar(Art(c, s)),
};

// ---------------------------------------------------------------------------
// Palette

// 1863: sun-bleached ruins under a mild sky.
const _skyTop = Color(0xFF8FA6B8);
const _skyLow = Color(0xFFD8CCB2);
const _mountain = Color(0xFF6A6570);
const _plaster = Color(0xFFC6B597);
const _plasterDark = Color(0xFFA8977B);
const _fadedRed = Color(0xFF9A5E4C);
const _ash = Color(0xFF8E8983);
const _ashDark = Color(0xFF6A655F);
const _pumice = Color(0xFFD2C9B6);
const _basalt = Color(0xFF4B4845);
const _lavaStone = Color(0xFF57524C);
const _soil = Color(0xFF4A3B2C);
const _weed = Color(0xFF6F7A48);
const _plank = Color(0xFF7A5C3E);
const _paper = Color(0xFFE9DFC6);

// 79: colour still on the walls, and the sky going dark.
const _dusk79 = Color(0xFF2E2622);
const _sky79Top = Color(0xFF3A302C);
const _sky79Low = Color(0xFFA9714A);
const _cloud = Color(0xFFC9BCA8);
const _cloudShade = Color(0xFF8C8073);
const _red79 = Color(0xFF8E2B1E);
const _yellow79 = Color(0xFFC9962E);
const _black79 = Color(0xFF2A2320);
const _tile = Color(0xFFA5552F);
const _green79 = Color(0xFF4E6B3A);
const _leaf = Color(0xFF3B5530);
const _charcoal = Color(0xFF2A2420);
const _pomegranate = Color(0xFFA3322A);

// ---------------------------------------------------------------------------
// Shared pieces

/// A calm sky of 1863 down to [horizon].
void _sky1863(Art a, {double horizon = 0.5}) =>
    a.fade(a.r(0, 0, 1, horizon), _skyTop, _skyLow);

/// The sky of the afternoon in 79: bronze low down, darkening overhead.
void _sky79(Art a, {double horizon = 0.5}) =>
    a.fade(a.r(0, 0, 1, horizon), _sky79Top, _sky79Low);

/// Vesuvius, its peak at ([x], [y]), filling down to [base]: the cone with
/// its crater, the old ridge of Somma on its left shoulder, gullies down
/// its flanks, and the lit side towards the afternoon sun on the right.
void _vesuvius(Art a, double x, double y, double base, {Color? color}) {
  final body = color ?? _mountain;
  final h = base - y;
  final outline = a.poly([
    a.p(x - 0.28, base),
    a.p(x - 0.2, base - h * 0.5),
    a.p(x - 0.15, base - h * 0.7),
    a.p(x - 0.11, base - h * 0.64),
    a.p(x - 0.06, base - h * 0.86),
    a.p(x - 0.025, y),
    a.p(x, y + h * 0.05),
    a.p(x + 0.025, y + h * 0.01),
    a.p(x + 0.09, base - h * 0.55),
    a.p(x + 0.16, base - h * 0.28),
    a.p(x + 0.28, base),
  ]);
  a.path(outline, body, line: 0);
  a.canvas
    ..save()
    ..clipPath(outline);
  // The sunlit flank.
  a.path(
    a.poly([a.p(x + 0.012, y), a.p(x + 0.3, base), a.p(x - 0.02, base)]),
    Color.lerp(body, const Color(0xFFE8DCC8), 0.22)!,
    line: 0,
  );
  // Gullies running down from the rim.
  final gully = Color.lerp(body, Art.outline, 0.35)!;
  for (var i = 0; i < 9; i++) {
    final t = (i - 4) / 4;
    final top = a.p(x + t * 0.02, y + h * 0.08);
    final bottom = a.p(x + t * 0.2, base);
    final bend = a.p(x + t * 0.07 + 0.01, y + h * 0.5);
    a.canvas.drawPath(
      Path()
        ..moveTo(top.dx, top.dy)
        ..quadraticBezierTo(bend.dx, bend.dy, bottom.dx, bottom.dy),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = a.u * 0.25
        ..color = gully.withValues(alpha: 0.55),
    );
  }
  // Somma's old wall, a darker ridge.
  a.canvas.drawPath(
    Path()
      ..moveTo(a.p(x - 0.25, base).dx, a.p(0, base).dy)
      ..lineTo(a.p(x - 0.15, base - h * 0.7).dx, a.p(0, base - h * 0.7).dy)
      ..lineTo(a.p(x - 0.11, base - h * 0.64).dx, a.p(0, base - h * 0.64).dy)
      ..lineTo(a.p(x - 0.08, base).dx, a.p(0, base).dy)
      ..close(),
    Paint()..color = gully.withValues(alpha: 0.35),
  );
  // The crater's dark lip.
  a.canvas.drawOval(
    Rect.fromCenter(
      center: a.p(x, y + h * 0.03),
      width: a.size.width * 0.045,
      height: a.size.height * h * 0.06,
    ),
    Paint()..color = gully,
  );
  // Haze at the foot.
  a.fade(
    a.r(x - 0.3, base - h * 0.25, 0.6, h * 0.25),
    body.withValues(alpha: 0),
    Color.lerp(body, _skyLow, 0.5)!.withValues(alpha: 0.7),
  );
  a.canvas.restore();
  a.canvas.drawPath(
    outline,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = a.u * 0.4
      ..color = Art.outline,
  );
}

/// A thin thread of smoke from the peak, drifting right (1863).
void _smoke(Art a, double x, double y) {
  for (var i = 0; i < 7; i++) {
    a.glow(
      a.p(x + i * 0.012 + i * i * 0.002, y - i * 0.018),
      a.size.width * (0.012 + i * 0.004),
      const Color(0xFFE6E2DA),
      strength: 0.35 - i * 0.035,
    );
  }
}

/// Pliny's cloud: a tall trunk spreading into a canopy, like an umbrella
/// pine, rising from the peak at ([x], [y]) to [top].
void _pineCloud(Art a, double x, double y, double top, double spread) {
  final trunk = Path()
    ..moveTo(a.p(x - 0.012, y).dx, a.p(x, y).dy)
    ..quadraticBezierTo(
      a.p(x - 0.02, (y + top) / 2).dx,
      a.p(x, (y + top) / 2).dy,
      a.p(x - 0.03, top + 0.06).dx,
      a.p(x, top + 0.06).dy,
    )
    ..lineTo(a.p(x + 0.03, top + 0.06).dx, a.p(x, top + 0.06).dy)
    ..quadraticBezierTo(
      a.p(x + 0.02, (y + top) / 2).dx,
      a.p(x, (y + top) / 2).dy,
      a.p(x + 0.012, y).dx,
      a.p(x, y).dy,
    )
    ..close();
  a.path(trunk, _cloudShade, line: 0);
  // The canopy: overlapping billows.
  final random = math.Random(79);
  for (var i = 0; i < 14; i++) {
    final t = i / 13;
    final cx = x - spread / 2 + spread * t;
    final cy =
        top +
        0.03 +
        math.sin(t * math.pi) * -0.025 +
        random.nextDouble() * 0.02;
    final r = a.size.width * (0.03 + random.nextDouble() * 0.025);
    a.canvas.drawCircle(a.p(cx, cy + 0.015), r, Paint()..color = _cloudShade);
    a.canvas.drawCircle(a.p(cx, cy), r * 0.92, Paint()..color = _cloud);
  }
}

/// Pale stones falling through the air of 79.
void _falling(Art a, {int count = 60, int seed = 7, Rect? inside}) {
  final random = math.Random(seed);
  final area = inside ?? Offset.zero & a.size;
  final paint = Paint()..color = _pumice.withValues(alpha: 0.75);
  for (var i = 0; i < count; i++) {
    final p = Offset(
      area.left + random.nextDouble() * area.width,
      area.top + random.nextDouble() * area.height,
    );
    final r = a.u * (0.2 + random.nextDouble() * 0.35);
    a.canvas
      ..drawCircle(p, r, paint)
      ..drawLine(
        p.translate(0, -r * 5),
        p,
        Paint()
          ..color = _pumice.withValues(alpha: 0.2)
          ..strokeWidth = r,
      );
  }
}

/// Paving of basalt blocks between [top] and the bottom of the picture.
void _paving(Art a, double top, {Color color = _basalt, Offset? vp}) {
  a.fill(a.r(0, top, 1, 1 - top), color);
  // Joints run back to the vanishing point [vp], if there is one.
  double run(double x, double y, double y2) =>
      vp == null ? x : vp.dx + (x - vp.dx) * (y2 - vp.dy) / (y - vp.dy);
  final dark = Color.lerp(color, Art.outline, 0.45)!;
  final random = math.Random(11);
  var y = top;
  var row = 0;
  while (y < 1) {
    final h = 0.03 + row * 0.012;
    a.hairline(a.p(0, y), a.p(1, y), dark, 0.25);
    var x = random.nextDouble() * 0.08;
    while (x < 1) {
      a.hairline(a.p(x, y), a.p(run(x, y, y + h), y + h), dark, 0.25);
      x += 0.06 + random.nextDouble() * 0.06 + row * 0.02;
    }
    y += h;
    row++;
  }
}

/// A ruined wall top: plaster up to a broken edge.
void _ruinWall(
  Art a,
  Rect rect, {
  Color color = _plaster,
  int seed = 1,
  double jag = 0.05,
}) {
  final random = math.Random(seed);
  final points = <Offset>[Offset(rect.left, rect.bottom)];
  const steps = 10;
  for (var i = 0; i <= steps; i++) {
    final x = rect.left + rect.width * i / steps;
    points.add(Offset(x, rect.top + random.nextDouble() * a.size.height * jag));
  }
  points.add(Offset(rect.right, rect.bottom));
  a.path(a.poly(points), color, line: 0.5);
}

/// Plaster fading off in patches, showing the rubble beneath.
void _flaking(Art a, Rect rect, {int seed = 3, int count = 12}) {
  final random = math.Random(seed);
  for (var i = 0; i < count; i++) {
    final c = Offset(
      rect.left + random.nextDouble() * rect.width,
      rect.top + random.nextDouble() * rect.height,
    );
    a.canvas.drawOval(
      Rect.fromCenter(
        center: c,
        width: a.u * (2 + random.nextDouble() * 5),
        height: a.u * (1 + random.nextDouble() * 3),
      ),
      Paint()..color = _plasterDark.withValues(alpha: 0.6),
    );
  }
}

/// Wall panels in the fourth style: coloured fields framed by thin lines.
void _panels(
  Art a,
  Rect rect, {
  required Color field,
  required Color frame,
  required Color dado,
  int count = 3,
}) {
  final dadoTop = rect.top + rect.height * 0.72;
  a
    ..fill(rect, field)
    ..fill(Rect.fromLTRB(rect.left, dadoTop, rect.right, rect.bottom), dado);
  final w = rect.width / count;
  for (var i = 0; i < count; i++) {
    final panel = Rect.fromLTWH(
      rect.left + w * i + w * 0.1,
      rect.top + rect.height * 0.12,
      w * 0.8,
      rect.height * 0.5,
    );
    a.canvas.drawRect(
      panel,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = a.u * 0.4
        ..color = frame,
    );
  }
  a.hairline(
    Offset(rect.left, dadoTop),
    Offset(rect.right, dadoTop),
    Art.outline,
    0.4,
  );
}

/// Faceless figures side by side: (figure, x, y, width, height) within the
/// picture.
void _group(Art a, List<(EchoFigure, double, double, double, double)> who) {
  for (final (figure, x, y, w, h) in who) {
    final box = a.r(x, y, w, h);
    a.canvas
      ..save()
      ..translate(box.left, box.top);
    paintEcho(Art(a.canvas, box.size), figure);
    a.canvas.restore();
  }
}

/// Weeds along a wall foot.
void _weeds(Art a, Rect rect, {int seed = 5}) {
  final random = math.Random(seed);
  for (var i = 0; i < 18; i++) {
    final x = rect.left + random.nextDouble() * rect.width;
    final h = rect.height * (0.4 + random.nextDouble() * 0.6);
    a.line(
      Offset(x, rect.bottom),
      Offset(x + (random.nextDouble() - 0.5) * h * 0.5, rect.bottom - h),
      _weed,
      width: 0.4,
    );
  }
}

// ---------------------------------------------------------------------------
// The street

/// The street running away between the houses, down to its far end at
/// [horizon]: kerbs converging, houses closing it off.
void _farStreet(Art a, {required double horizon, required bool ruin}) {
  final road = ruin ? const Color(0xFF55514D) : const Color(0xFF4F4B47);
  final kerb = ruin ? const Color(0xFF8A837A) : const Color(0xFF948B80);
  a
    ..fill(a.r(0.44, horizon, 0.22, 0.8 - horizon), kerb)
    ..path(
      a.poly([
        a.p(0.4, 0.8),
        a.p(0.53, horizon),
        a.p(0.57, horizon),
        a.p(0.7, 0.8),
      ]),
      road,
      line: 0,
    );
  for (var i = 1; i < 6; i++) {
    final t = i / 6;
    final y = horizon + (0.8 - horizon) * t * t;
    a.hairline(
      a.p(0.53 - 0.13 * t * t, y),
      a.p(0.57 + 0.13 * t * t, y),
      Color.lerp(road, Art.outline, 0.4)!,
      0.2,
    );
  }
  a
    ..hairline(a.p(0.4, 0.8), a.p(0.53, horizon), Art.outline, 0.3)
    ..hairline(a.p(0.7, 0.8), a.p(0.57, horizon), Art.outline, 0.3);
}

/// Where the street runs to: its vanishing point, for both its years.
const _streetEye = Offset(0.55, 0.54);

/// The return of a building's front, the wall's thickness turning back
/// along the street towards [_streetEye]: from the front's [edge] (its x),
/// [top] to [bottom], [t] of the way to the vanishing point.
void _streetReturn(
  Art a,
  double edge,
  double top,
  double bottom,
  Color color, {
  double t = 0.14,
}) {
  final vp = a.p(_streetEye.dx, _streetEye.dy);
  final upper = a.p(edge, top);
  final lower = a.p(edge, bottom);
  a.path(
    a.poly([
      upper,
      Offset.lerp(upper, vp, t)!,
      Offset.lerp(lower, vp, t)!,
      lower,
    ]),
    color,
    line: 0.4,
  );
}

/// A soft shadow along the foot of something standing on the street.
void _footOf(Art a, double x0, double x1, double y) => a.canvas.drawOval(
  Rect.fromLTRB(
    a.p(x0, 0).dx,
    a.p(0, y).dy - a.u * 1.5,
    a.p(x1, 0).dx,
    a.p(0, y).dy + a.u * 2,
  ),
  Paint()
    ..color = const Color(0x66000000)
    ..maskFilter = MaskFilter.blur(BlurStyle.normal, a.u * 1.5),
);

void _street(Art a) {
  _sky1863(a, horizon: 0.52);
  _vesuvius(a, 0.18, 0.17, 0.46);
  _smoke(a, 0.19, 0.16);
  // Spoil heaps where the diggers have not cleared yet.
  a.fill(a.r(0, 0.5, 1, 0.3), _ash);
  // Ruins far down the street.
  _ruinWall(a, a.r(0.36, 0.34, 0.34, 0.2), color: _plasterDark, seed: 4);
  _farStreet(a, horizon: 0.54, ruin: true);
  _paving(a, 0.8, vp: _streetEye);
  // Left: the baker's shopfront, roofless, to the shoulder.
  _streetReturn(a, 0.46, 0.27, 0.82, _plasterDark, t: 0.16);
  _ruinWall(a, a.r(0, 0.24, 0.46, 0.58), seed: 2, jag: 0.06);
  a.fill(a.r(0, 0.64, 0.46, 0.18), _fadedRed);
  _flaking(a, a.r(0, 0.3, 0.46, 0.5), seed: 9, count: 20);
  a
    ..fill(a.r(0.18, 0.42, 0.16, 0.36), const Color(0xFF2B2622))
    ..ink(a.r(0.18, 0.42, 0.16, 0.36))
    ..box(a.r(0.17, 0.4, 0.18, 0.025), _plasterDark, line: 0.4);
  // The election notice, faded red.
  a.label(
    'PISTORES',
    a.p(0.11, 0.37),
    a.size.height * 0.022,
    _fadedRed.withValues(alpha: 0.9),
  );
  a.label(
    'ROG · AED',
    a.p(0.11, 0.41),
    a.size.height * 0.02,
    _fadedRed.withValues(alpha: 0.7),
  );
  // Sidewalk and kerb.
  a
    ..fill(a.r(0, 0.8, 0.46, 0.04), const Color(0xFF7E776E))
    ..hairline(a.p(0, 0.84), a.p(0.46, 0.84), Art.outline, 0.5);
  _ruts(a);
  _steppingStones(a, const Color(0xFF7A736B));
  // The diggers' hut on the right, its side running back along the street.
  _footOf(a, 0.6, 0.95, 0.76);
  _streetReturn(a, 0.8, 0.22, 0.31, const Color(0xFF4A3A2C), t: 0.3);
  _streetReturn(a, 0.66, 0.31, 0.76, const Color(0xFF5E4630), t: 0.3);
  a
    ..wood(a.r(0.66, 0.3, 0.28, 0.46), base: _plank, vertical: true, grain: 8)
    ..path(
      a.poly([a.p(0.64, 0.31), a.p(0.8, 0.22), a.p(0.96, 0.31)]),
      const Color(0xFF5A4636),
    )
    ..box(a.r(0.72, 0.42, 0.1, 0.32), const Color(0xFF221A14))
    ..box(a.r(0.84, 0.4, 0.07, 0.08), const Color(0xFFBFD0DA), line: 0.4);
  // The diggers' baskets for carrying spoil, by the hut.
  _basket(a, a.r(0.855, 0.68, 0.06, 0.08));
  _basket(a, a.r(0.905, 0.7, 0.06, 0.07));
  // The diggers' board on its post.
  _footOf(a, 0.55, 0.59, 0.8);
  a
    ..line(a.p(0.57, 0.54), a.p(0.57, 0.8), const Color(0xFF4A3828), width: 0.9)
    ..box(a.r(0.52, 0.44, 0.1, 0.1), const Color(0xFFD9C9A2), line: 0.5)
    ..label('SCAVI', a.p(0.57, 0.475), a.size.height * 0.022, _charcoal)
    ..label('1748', a.p(0.57, 0.51), a.size.height * 0.02, _charcoal);
  _weeds(a, a.r(0, 0.76, 0.14, 0.04));
}

/// Two grooves worn into the paving by cart wheels, running into the
/// picture, with the light catching their far edges.
void _ruts(Art a) {
  for (final (bottom, top) in [(0.4, 0.49), (0.66, 0.6)]) {
    final groove = a.poly([
      a.p(bottom - 0.018, 1),
      a.p(bottom + 0.018, 1),
      a.p(top + 0.006, 0.845),
      a.p(top - 0.006, 0.845),
    ]);
    a.path(groove, const Color(0xFF2B2824), line: 0);
    a
      ..hairline(
        a.p(bottom + 0.018, 1),
        a.p(top + 0.006, 0.845),
        const Color(0xFF8E877E),
        0.4,
      )
      ..hairline(
        a.p(bottom - 0.018, 1),
        a.p(top - 0.006, 0.845),
        Art.outline,
        0.3,
      );
  }
}

/// Raised stepping stones across the street, so no one had to wade.
void _steppingStones(Art a, Color stone) {
  final side = Color.lerp(stone, Art.outline, 0.4)!;
  for (final x in [0.465, 0.53, 0.595]) {
    a
      ..box(a.r(x - 0.026, 0.8, 0.052, 0.02), side, line: 0.4)
      ..oval(a.r(x - 0.028, 0.786, 0.056, 0.028), stone, line: 0.4);
  }
}

/// A wicker basket for carrying spoil.
void _basket(Art a, Rect rect) {
  const wicker = Color(0xFF9C7A4E);
  final body = Path()
    ..moveTo(rect.left, rect.top + rect.height * 0.2)
    ..lineTo(rect.right, rect.top + rect.height * 0.2)
    ..lineTo(rect.right - rect.width * 0.12, rect.bottom)
    ..lineTo(rect.left + rect.width * 0.12, rect.bottom)
    ..close();
  a.path(body, wicker, line: 0.4);
  final weave = Color.lerp(wicker, Art.outline, 0.45)!;
  for (var i = 1; i < 4; i++) {
    final y = rect.top + rect.height * (0.2 + 0.2 * i);
    a.hairline(
      Offset(rect.left + rect.width * 0.04 * i, y),
      Offset(rect.right - rect.width * 0.04 * i, y),
      weave,
      0.25,
    );
  }
  a.oval(
    Rect.fromLTWH(
      rect.left,
      rect.top + rect.height * 0.1,
      rect.width,
      rect.height * 0.2,
    ),
    Color.lerp(wicker, Art.outline, 0.25)!,
    line: 0.4,
  );
}

/// Grey ash banked against the shop's doorway, set hard as mortar: the
/// layers it fell in, a crust on top, lumps broken off at its foot.
void _ashBank(Art a) {
  final random = math.Random(21);
  final top = <Offset>[a.p(0, 1)];
  for (var i = 0; i <= 12; i++) {
    final x = i / 12;
    top.add(
      a.p(x, 0.12 + math.pow(x - 0.45, 2) * 0.9 + random.nextDouble() * 0.06),
    );
  }
  top.add(a.p(1, 1));
  final bank = a.poly(top);
  a.path(bank, _ash, line: 0);
  a.canvas
    ..save()
    ..clipPath(bank);
  // The layers it fell in: bands of darker ash and paler pumice.
  for (var i = 0; i < 6; i++) {
    final y = 0.3 + i * 0.12;
    final band = Path()..moveTo(0, a.p(0, y).dy);
    for (var j = 1; j <= 8; j++) {
      band.lineTo(
        a.p(j / 8, 0).dx,
        a.p(0, y + math.sin(j * 1.3 + i) * 0.015).dy,
      );
    }
    band
      ..lineTo(a.size.width, a.p(0, y + 0.06).dy)
      ..lineTo(0, a.p(0, y + 0.06).dy)
      ..close();
    a.canvas.drawPath(
      band,
      Paint()..color = (i.isEven ? _ashDark : _pumice).withValues(alpha: 0.45),
    );
  }
  // The weathered crust along the top.
  a.canvas.drawPath(
    Path()..addPolygon(top.sublist(1, top.length - 1), false),
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = a.u * 2.2
      ..color = Color.lerp(_ash, _plasterDark, 0.5)!,
  );
  // Shadow where it meets the street.
  a.fade(a.r(0, 0.82, 1, 0.18), _ash.withValues(alpha: 0), _ashDark);
  a.canvas.restore();
  a.path(bank, const Color(0x00000000), line: 0.5);
  // Lumps broken off at its foot.
  for (final (x, w) in [(0.08, 0.1), (0.7, 0.13), (0.86, 0.08)]) {
    a.path(
      a.poly([
        a.p(x, 0.98),
        a.p(x + w * 0.2, 0.9),
        a.p(x + w * 0.7, 0.88),
        a.p(x + w, 0.98),
      ]),
      _ashDark,
      line: 0.35,
    );
  }
}

void _street79(Art a) {
  _sky79(a, horizon: 0.52);
  a.fill(a.r(0, 0.5, 1, 0.3), const Color(0xFF8E7A62));
  _vesuvius(a, 0.18, 0.2, 0.46, color: const Color(0xFF4E4046));
  _pineCloud(a, 0.19, 0.2, 0.02, 0.34);
  // Houses far down the street, roofed.
  a
    ..fill(a.r(0.36, 0.34, 0.34, 0.2), const Color(0xFFB88E5C))
    ..fill(a.r(0.36, 0.32, 0.34, 0.03), _tile);
  _farStreet(a, horizon: 0.54, ruin: false);
  _paving(a, 0.8, vp: _streetEye);
  // The shopfront, whole: yellow above, red below, a tiled roof.
  _streetReturn(a, 0.46, 0.22, 0.82, const Color(0xFF9A7228), t: 0.16);
  a
    ..box(a.r(0, 0.22, 0.46, 0.6), _yellow79)
    ..fill(a.r(0, 0.64, 0.46, 0.18), _red79)
    ..box(a.r(0, 0.18, 0.48, 0.05), _tile, line: 0.5);
  for (var i = 0; i < 12; i++) {
    a.hairline(a.p(i * 0.04, 0.18), a.p(i * 0.04, 0.23), Art.outline, 0.3);
  }
  // The shop, open: a counter and stacked loaves.
  a
    ..fill(a.r(0.18, 0.42, 0.16, 0.36), const Color(0xFF3A2A1E))
    ..box(a.r(0.18, 0.6, 0.16, 0.08), const Color(0xFFE2DACB), line: 0.5);
  for (var i = 0; i < 5; i++) {
    _loaf(a, a.p(0.2 + i * 0.03, 0.585), a.size.height * 0.018, fresh: true);
  }
  // The notice, fresh.
  a.label('PISTORES', a.p(0.11, 0.37), a.size.height * 0.024, _red79);
  a.label('ROG · AED', a.p(0.11, 0.41), a.size.height * 0.02, _red79);
  a
    ..fill(a.r(0, 0.8, 0.46, 0.04), const Color(0xFF8E857A))
    ..hairline(a.p(0, 0.84), a.p(0.46, 0.84), Art.outline, 0.5);
  _ruts(a);
  _steppingStones(a, const Color(0xFF6E6862));
  // Where the hut will stand: a neighbour's snack bar with jars in its counter.
  _footOf(a, 0.6, 1, 0.8);
  _streetReturn(a, 0.64, 0.24, 0.8, const Color(0xFFA88E66), t: 0.3);
  a
    ..box(a.r(0.64, 0.24, 0.36, 0.56), const Color(0xFFD4B98C))
    ..fill(a.r(0.64, 0.64, 0.36, 0.16), _red79)
    ..box(a.r(0.62, 0.2, 0.4, 0.05), _tile, line: 0.5)
    ..fill(a.r(0.72, 0.42, 0.1, 0.32), const Color(0xFF30241A))
    ..box(a.r(0.84, 0.56, 0.14, 0.08), const Color(0xFFE2DACB), line: 0.5);
  for (var i = 0; i < 3; i++) {
    a.oval(a.r(0.855 + i * 0.04, 0.55, 0.03, 0.02), _black79, line: 0.3);
  }
  _falling(a, count: 50, seed: 12);
}

/// A round loaf scored into eight, centred at [c].
void _loaf(Art a, Offset c, double r, {required bool fresh}) {
  a.circle(
    c,
    r,
    fresh ? const Color(0xFFB9803F) : const Color(0xFF1C1814),
    line: 0.35,
  );
  final score = fresh ? const Color(0xFF7A4E22) : const Color(0xFF3A332C);
  for (var k = 0; k < 4; k++) {
    final angle = k * math.pi / 4;
    final d = Offset(math.cos(angle), math.sin(angle)) * r * 0.85;
    a.hairline(c - d, c + d, score, 0.25);
  }
}

// ---------------------------------------------------------------------------
// The diggers' hut

/// The diggers' hut's camera.
const _hutEye = Offset(0.5, 0.36);

/// Paints [paint], drawn for the picture's rect [from], moved and scaled
/// into [to] (both fractions of the picture).
void _moved(Art a, Rect from, Rect to, void Function() paint) {
  final sx = to.width / from.width;
  final sy = to.height / from.height;
  a.canvas
    ..save()
    ..translate(
      (to.left - from.left * sx) * a.size.width,
      (to.top - from.top * sy) * a.size.height,
    )
    ..scale(sx, sy);
  paint();
  a.canvas.restore();
}

void _hut(Art a) {
  final room = Room(a, vp: a.p(_hutEye.dx, _hutEye.dy), depth: 0.6);
  final back = room.back;
  const plankDark = Color(0xFF5E4630);
  const seam = Color(0x66281C12);
  a
    ..path(room.ceiling, const Color(0xFF3A2C20), line: 0)
    ..path(room.leftWall, plankDark, line: 0)
    ..path(room.rightWall, plankDark, line: 0)
    ..wood(back, base: _plank, vertical: true, grain: 16)
    ..fill(back, const Color(0x22000000));
  // The side walls' boards and the rafters, running back.
  for (var k = 1; k < 10; k++) {
    for (final x in [0.0, 1.0]) {
      a.hairline(room.at(x, 0, k / 10), room.at(x, 1, k / 10), seam, 0.5);
    }
  }
  for (var k = 1; k < 5; k++) {
    a.line(
      room.at(0, 1, k / 5),
      room.at(1, 1, k / 5),
      const Color(0xFF2A2018),
      width: 1.2,
    );
  }
  // The floorboards.
  a.path(room.floor, const Color(0xFF5A4430), line: 0);
  room.floorGrid(const Color(0x88281C12), rows: 0, columns: 12, width: 0.5);
  // A window of daylight, deep in the planks.
  final window = a.r(0.44, 0.234, 0.12, 0.15);
  room.recess(window, _plank);
  final glass = Room.recessInner(window);
  a
    ..box(glass, const Color(0xFFC9D6DC), line: 0.5)
    ..line(
      Offset(glass.center.dx, glass.top),
      Offset(glass.center.dx, glass.bottom),
      _plank,
      width: 0.6,
    )
    ..glow(
      glass.center,
      a.size.width * 0.22,
      const Color(0xFFF2E8D0),
      strength: 0.25,
    );
  // The door in the right wall, open on the bright street, its light
  // lying across the boards.
  final door = [
    room.at(1, 0.75, 0.15),
    room.at(1, 0.75, 0.45),
    room.at(1, 0, 0.45),
    room.at(1, 0, 0.15),
  ];
  a.path(a.poly(door), const Color(0xFFE6DCC4), line: 0.6);
  room.beam(
    [door[3], door[2]],
    [room.floorAt(0.62, 0.42), room.floorAt(0.7, 0.1)],
    const Color(0xFFF6EEDA),
    strength: 0.22,
  );
  a.glow(
    Offset.lerp(door[0], door[2], 0.5)!,
    a.size.width * 0.16,
    const Color(0xFFF6EEDA),
    strength: 0.35,
  );
  room
    ..shadeCorners(strength: 0.4)
    ..edges(const Color(0x88201810));
  // The town plan pinned to the wall.
  _moved(
    a,
    const Rect.fromLTWH(0.05, 0.12, 0.24, 0.32),
    const Rect.fromLTWH(0.23, 0.204, 0.198, 0.27),
    () {
      // The town plan pinned to the wall.
      a.box(a.r(0.05, 0.12, 0.24, 0.32), _paper, line: 0.5);
      final walls = Path()
        ..moveTo(a.p(0.08, 0.26).dx, a.p(0.08, 0.26).dy)
        ..quadraticBezierTo(
          a.p(0.1, 0.15).dx,
          a.p(0.1, 0.15).dy,
          a.p(0.18, 0.16).dx,
          a.p(0.18, 0.16).dy,
        )
        ..quadraticBezierTo(
          a.p(0.27, 0.16).dx,
          a.p(0.27, 0.16).dy,
          a.p(0.26, 0.28).dx,
          a.p(0.26, 0.28).dy,
        )
        ..quadraticBezierTo(
          a.p(0.25, 0.4).dx,
          a.p(0.25, 0.4).dy,
          a.p(0.16, 0.4).dx,
          a.p(0.16, 0.4).dy,
        )
        ..quadraticBezierTo(
          a.p(0.08, 0.39).dx,
          a.p(0.08, 0.39).dy,
          a.p(0.08, 0.26).dx,
          a.p(0.08, 0.26).dy,
        );
      a.strokePath(walls, StillroomPalette.inkOnPaper, width: 0.5);
      for (var i = 1; i < 5; i++) {
        a
          ..hairline(
            a.p(0.09, 0.16 + i * 0.05),
            a.p(0.25, 0.17 + i * 0.05),
            StillroomPalette.inkOnPaper.withValues(alpha: 0.4),
            0.2,
          )
          ..hairline(
            a.p(0.09 + i * 0.035, 0.17),
            a.p(0.1 + i * 0.035, 0.39),
            StillroomPalette.inkOnPaper.withValues(alpha: 0.4),
            0.2,
          );
      }
      // The gates: red ticks on the walls.
      for (final (x, y) in [
        (0.18, 0.16),
        (0.08, 0.3),
        (0.26, 0.24),
        (0.24, 0.36),
        (0.14, 0.4),
        (0.1, 0.19),
      ]) {
        a.circle(a.p(x, y), a.u * 0.7, _red79, line: 0);
      }
    },
  );
  // Shelf with books.
  room.box(
    a.r(0.575, 0.372, 0.195, 0.015),
    const Color(0xFF5A4030),
    depth: 0.04,
    line: 0.4,
  );
  _moved(
    a,
    const Rect.fromLTWH(0.7, 0.21, 0.26, 0.11),
    const Rect.fromLTWH(0.575, 0.2895, 0.195, 0.0825),
    () {
      for (final (x, w, h, c) in [
        (0.73, 0.02, 0.1, const Color(0xFF4A3A2E)),
        (0.752, 0.025, 0.11, const Color(0xFF6B4A2E)),
        (0.78, 0.02, 0.09, const Color(0xFF3E4A3A)),
        (0.84, 0.03, 0.1, const Color(0xFF8E2E24)),
        (0.875, 0.02, 0.08, const Color(0xFF6E5A3C)),
      ]) {
        a.box(a.r(x, 0.32 - h, w, h), c, line: 0.3);
      }
    },
  );
  // The drafting table, its board propped up at the back, the sheet pinned
  // to it.
  room
    ..table(
      0.28,
      0.68,
      0.25,
      0.5,
      0.36,
      const Color(0xFF8A6A48),
      legColor: const Color(0xFF4A3828),
      leg: 0.02,
    )
    ..block(0.31, 0.33, 0.36, 0.5, 0.45, 0.48, const Color(0xFF4A3828))
    ..block(0.63, 0.65, 0.36, 0.5, 0.45, 0.48, const Color(0xFF4A3828));
  Offset board(double u, double v) =>
      room.at(0.3 + 0.36 * u, 0.37 + 0.13 * v, 0.27 + 0.21 * v);
  a
    ..path(
      a.poly([board(0, 0), board(1, 0), board(1, 1), board(0, 1)]),
      const Color(0xFF9A7A56),
      line: 0.5,
    )
    ..path(
      a.poly([
        board(0.17, 0.12),
        board(0.83, 0.12),
        board(0.83, 0.92),
        board(0.17, 0.92),
      ]),
      _paper,
      line: 0.4,
    );
  for (var i = 1; i < 6; i++) {
    final t = i / 6;
    a
      ..hairline(
        board(0.17 + 0.66 * t, 0.12),
        board(0.17 + 0.66 * t, 0.92),
        const Color(0x3326384A),
        0.2,
      )
      ..hairline(
        board(0.17, 0.12 + 0.8 * t),
        board(0.83, 0.12 + 0.8 * t),
        const Color(0x3326384A),
        0.2,
      );
  }
  // The day-book on a small table, and a clay oil lamp, lit.
  room.table(
    0.72,
    0.94,
    0.42,
    0.6,
    0.34,
    const Color(0xFF5A4030),
    legColor: const Color(0xFF4A3828),
    leg: 0.016,
  );
  a
    ..paper(a.r(0.69, 0.535, 0.045, 0.05), lines: 4, angle: -0.05)
    ..paper(a.r(0.735, 0.535, 0.045, 0.05), lines: 4, angle: 0.05)
    ..oval(a.r(0.785, 0.565, 0.04, 0.025), const Color(0xFFA0643E))
    ..flame(a.p(0.818, 0.57), a.size.height * 0.045);
  // A crate of finds in straw.
  room
    ..shadow(0.74, 0.96, 0.08, 0.26)
    ..block(
      0.74,
      0.96,
      0,
      0.2,
      0.08,
      0.26,
      const Color(0xFF8A6A40),
      top: const Color(0xFFC9B46A),
    );
  for (final y in [0.07, 0.135]) {
    a.hairline(
      room.at(0.74, y, 0.08),
      room.at(0.96, y, 0.08),
      const Color(0xFF5A4428),
      0.4,
    );
  }
}

void _lens(Art a) {
  final c = a.p(0.42, 0.42);
  final r = a.size.shortestSide * 0.3;
  a
    ..line(a.p(0.62, 0.62), a.p(0.9, 0.9), const Color(0xFF5A3A26), width: 7)
    ..circle(c, r, const Color(0xFFBFD3DA), line: 0)
    ..glow(c, r, const Color(0xFFFFF6DC), strength: 0.4);
  a.canvas.drawCircle(
    c,
    r,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.22
      ..color = StillroomPalette.brass,
  );
  a.canvas.drawCircle(
    c,
    r * 1.11,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = a.u * 0.6
      ..color = Art.outline,
  );
  a.canvas.drawArc(
    Rect.fromCircle(center: c, radius: r * 0.65),
    -math.pi * 0.85,
    0.9,
    false,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.12
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xAAFFFFFF),
  );
}

/// The shovel leaning upright against the wall, its shadow at its foot.
void _shovel(Art a) {
  Room.spriteShadow(a, 0.15, 0.85);
  a
    ..line(a.p(0.5, 0.02), a.p(0.5, 0.72), const Color(0xFF7A5634), width: 2.4)
    ..box(a.r(0.3, 0.0, 0.4, 0.05), const Color(0xFF7A5634), line: 0.4)
    ..path(
      a.poly([
        a.p(0.2, 0.7),
        a.p(0.8, 0.7),
        a.p(0.76, 0.94),
        a.p(0.5, 1),
        a.p(0.24, 0.94),
      ]),
      const Color(0xFF6E7274),
    )
    ..hairline(a.p(0.26, 0.93), a.p(0.74, 0.93), const Color(0xFFC9CED0), 0.5);
}

/// The shovel lying across its slot in the inventory.
void _shovelIcon(Art a) {
  a.canvas
    ..save()
    ..translate(a.size.width / 2, a.size.height / 2)
    ..rotate(math.pi / 4)
    ..translate(-a.size.width * 0.18, -a.size.height / 2);
  _shovel(Art(a.canvas, Size(a.size.width * 0.36, a.size.height)));
  a.canvas.restore();
}

// ---------------------------------------------------------------------------
// The bakery

/// An hourglass mill of lava stone in [rect].
void _mill(Art a, Rect rect, {Color color = _lavaStone}) {
  final w = rect.width;
  final h = rect.height;
  final l = rect.left;
  final t = rect.top;
  Offset p(double x, double y) => Offset(l + w * x, t + h * y);
  // Its shadow on the paving, and the base it turns on.
  a.canvas.drawOval(
    Rect.fromPoints(p(-0.05, 0.95), p(1.1, 1.04)),
    Paint()
      ..color = const Color(0x66000000)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, a.u * 1.2),
  );
  final base = Rect.fromPoints(p(0.05, 0.82), p(0.95, 1));
  final stone = a.poly([
    p(0.15, 0),
    p(0.85, 0),
    p(0.6, 0.42),
    p(0.85, 0.84),
    p(0.15, 0.84),
    p(0.4, 0.42),
  ]);
  a
    ..box(base, color)
    ..path(stone, color);
  // The stones are round: dark down the far side, lit along the near.
  final shade = Paint()
    ..shader = Gradient.linear(p(0.3, 0), p(0.95, 0), [
      const Color(0x00000000),
      const Color(0x55000000),
    ]);
  a.canvas
    ..save()
    ..clipPath(stone)
    ..drawRect(Rect.fromPoints(p(0, 0), p(1, 0.84)), shade)
    ..restore()
    ..save()
    ..clipRect(base)
    ..drawRect(base, shade)
    ..restore();
  a
    ..oval(
      Rect.fromPoints(p(0.05, 0.79), p(0.95, 0.85)),
      Color.lerp(color, const Color(0xFFFFFFFF), 0.12)!,
      line: 0.3,
    )
    ..oval(
      Rect.fromPoints(p(0.15, -0.03), p(0.85, 0.03)),
      Color.lerp(color, Art.outline, 0.3)!,
      line: 0.3,
    )
    // The sockets for the turning beam.
    ..box(
      Rect.fromLTWH(l + w * 0.18, t + h * 0.36, w * 0.12, h * 0.08),
      _black79,
      line: 0.3,
    )
    ..box(
      Rect.fromLTWH(l + w * 0.7, t + h * 0.36, w * 0.12, h * 0.08),
      _black79,
      line: 0.3,
    );
}

/// The bakery's camera, shared by both its years: the wall's foot at
/// 0.72, the mills and the oven standing out on the paving before it.
const _bakeryEye = Offset(0.5, 0.45);

Room _bakeryRoom(Art a) => wallCamera(a, _bakeryEye, 0.72);

/// The oven: a masonry block with its low dome on top and a flue, the
/// mouth an arch of brick, soot above it, shut with an iron door.
void _oven(Art a, {required Color brick, required bool glow}) {
  final dark = Color.lerp(brick, Art.outline, 0.4)!;
  // The dome behind the front wall, and its flue.
  a
    ..box(a.r(0.715, 0.1, 0.04, 0.16), Color.lerp(brick, Art.outline, 0.3)!)
    ..path(
      Path()..addArc(a.r(0.55, 0.2, 0.24, 0.3), math.pi, math.pi),
      Color.lerp(brick, Art.outline, 0.15)!,
    );
  // The front: rough stones set in mortar, the block standing out from
  // the wall.
  final front = a.r(0.52, 0.34, 0.3, 0.46);
  final room = _bakeryRoom(a)..stand(front, dark, deep: 0.2);
  a.box(front, brick);
  final random = math.Random(5);
  for (var row = 0; row < 8; row++) {
    var x = front.left + random.nextDouble() * a.size.width * 0.02;
    final y = front.top + front.height * row / 8;
    while (x < front.right) {
      final w = a.size.width * (0.03 + random.nextDouble() * 0.03);
      a.canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            x,
            y + a.u * 0.4,
            math.min(w, front.right - x) - a.u * 0.5,
            front.height / 8 - a.u * 0.8,
          ),
          Radius.circular(a.u * 0.8),
        ),
        Paint()..color = Color.lerp(brick, dark, random.nextDouble() * 0.5)!,
      );
      x += w;
    }
  }
  a.ink(front);
  // Soot licked up the wall over the mouth.
  a.canvas.drawOval(
    a.r(0.585, 0.34, 0.17, 0.2),
    Paint()
      ..color = const Color(0x88151210)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, a.u * 2),
  );
  // The mouth: an arch of brick voussoirs round the door.
  final mouth = Path()
    ..moveTo(a.p(0.59, 0.66).dx, a.p(0, 0.66).dy)
    ..lineTo(a.p(0.59, 0.5).dx, a.p(0, 0.5).dy)
    ..arcTo(a.r(0.59, 0.43, 0.16, 0.14), math.pi, math.pi, false)
    ..lineTo(a.p(0.75, 0.66).dx, a.p(0, 0.66).dy)
    ..close();
  a.path(mouth, const Color(0xFF9C5E40), line: 0.5);
  for (var i = 1; i < 8; i++) {
    final angle = math.pi + math.pi * i / 8;
    final c = a.p(0.67, 0.5);
    a.canvas.drawLine(
      c +
          Offset(
            math.cos(angle) * a.size.width * 0.062,
            math.sin(angle) * a.size.height * 0.055,
          ),
      c +
          Offset(
            math.cos(angle) * a.size.width * 0.08,
            math.sin(angle) * a.size.height * 0.07,
          ),
      Paint()
        ..strokeWidth = a.u * 0.3
        ..color = Art.outline,
    );
  }
  // The iron door.
  a
    ..box(a.r(0.605, 0.49, 0.13, 0.15), const Color(0xFF2B2A28), line: 0.5)
    ..hairline(
      a.p(0.605, 0.515),
      a.p(0.735, 0.515),
      const Color(0xFF55524E),
      0.4,
    )
    ..hairline(
      a.p(0.605, 0.615),
      a.p(0.735, 0.615),
      const Color(0xFF55524E),
      0.4,
    )
    ..circle(a.p(0.715, 0.565), a.u * 0.9, const Color(0xFF6E6A66), line: 0.3);
  // The ledge in front of the mouth, where the loaves were slid in.
  room.box(
    a.r(0.56, 0.66, 0.22, 0.03),
    Color.lerp(brick, _plaster, 0.4)!,
    depth: 0.04,
    line: 0.4,
  );
  if (glow) {
    a
      ..hairline(
        a.p(0.605, 0.49),
        a.p(0.735, 0.49),
        const Color(0xFFF2A447),
        0.7,
      )
      ..hairline(
        a.p(0.605, 0.64),
        a.p(0.735, 0.64),
        const Color(0xFFF2A447),
        0.7,
      )
      ..glow(
        a.p(0.67, 0.57),
        a.size.width * 0.12,
        const Color(0xFFF2A447),
        strength: 0.25,
      );
  }
}

/// A doorway into the house: lintel, jambs, a worn threshold, and the room
/// beyond in dim light.
void _doorway(Art a, Rect door, {required Color room, required Color panel}) {
  a
    ..fill(door, room)
    ..fade(
      Rect.fromLTWH(door.left, door.top, door.width, door.height * 0.5),
      const Color(0x66000000),
      const Color(0x00000000),
    )
    ..fill(
      Rect.fromLTWH(
        door.left + door.width * 0.25,
        door.top + door.height * 0.3,
        door.width * 0.5,
        door.height * 0.3,
      ),
      panel,
    )
    ..fill(
      Rect.fromLTWH(door.left, door.top, door.width * 0.14, door.height),
      const Color(0x55000000),
    )
    ..ink(door)
    ..box(
      Rect.fromLTWH(
        door.left - door.width * 0.12,
        door.top - door.height * 0.05,
        door.width * 1.24,
        door.height * 0.05,
      ),
      const Color(0xFF6E5038),
      line: 0.4,
    )
    ..box(
      Rect.fromLTWH(
        door.left - door.width * 0.06,
        door.bottom - door.height * 0.03,
        door.width * 1.12,
        door.height * 0.03,
      ),
      const Color(0xFFB8AE9E),
      line: 0.4,
    );
}

/// A pomegranate, burnt black or fresh, with its little crown.
void _pomegranateFruit(Art a, Offset c, double r, {required bool charred}) {
  final skin = charred ? const Color(0xFF1E1A16) : _pomegranate;
  a
    ..path(
      a.poly([
        c.translate(-r * 0.35, -r * 0.8),
        c.translate(-r * 0.2, -r * 1.25),
        c.translate(0, -r * 0.95),
        c.translate(r * 0.2, -r * 1.25),
        c.translate(r * 0.35, -r * 0.8),
      ]),
      skin,
      line: 0.25,
    )
    ..circle(c, r, skin, line: 0.3)
    ..canvas.drawCircle(
      c.translate(-r * 0.35, -r * 0.35),
      r * 0.25,
      Paint()
        ..color = charred ? const Color(0x33FFFFFF) : const Color(0x55FFFFFF),
    );
}

/// A chestnut: a rounded drop with a pale base.
void _chestnut(Art a, Offset c, double r, {required bool charred}) {
  final skin = charred ? const Color(0xFF231C16) : const Color(0xFF6A3E22);
  a.path(
    Path()
      ..moveTo(c.dx, c.dy - r * 1.2)
      ..quadraticBezierTo(c.dx + r * 1.3, c.dy, c.dx, c.dy + r)
      ..quadraticBezierTo(c.dx - r * 1.3, c.dy, c.dx, c.dy - r * 1.2),
    skin,
    line: 0.2,
  );
}

void _bakery(Art a) {
  _sky1863(a, horizon: 0.3);
  final room = _bakeryRoom(a);
  _ruinWall(a, a.r(0, 0.14, 1, 0.6), seed: 6, jag: 0.07);
  _flaking(a, a.r(0, 0.2, 1, 0.45), seed: 13, count: 30);
  a.fill(a.r(0, 0.6, 1, 0.12), _fadedRed.withValues(alpha: 0.7));
  _paving(a, 0.72, color: const Color(0xFF6C665F), vp: _bakeryEye);
  room.wallFoot();
  // The ring a donkey's hooves wore round the mills.
  a.canvas.drawOval(
    a.r(0.02, 0.8, 0.32, 0.08),
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = a.u * 0.6
      ..color = const Color(0x55000000),
  );
  _mill(a, a.r(0.06, 0.36, 0.12, 0.46));
  _mill(a, a.r(0.2, 0.42, 0.1, 0.4));
  // The doorway into the house.
  _doorway(
    a,
    a.r(0.36, 0.3, 0.1, 0.42),
    room: const Color(0xFF7A6A58),
    panel: _fadedRed.withValues(alpha: 0.6),
  );
  _oven(a, brick: const Color(0xFF8C6450), glow: false);
  // The store corner: jars sunk in the floor, a shelf of charred fruit.
  room.box(
    a.r(0.85, 0.5, 0.14, 0.02),
    const Color(0xFF5A4636),
    depth: 0.04,
    line: 0.4,
  );
  for (var i = 0; i < 3; i++) {
    _pomegranateFruit(
      a,
      a.p(0.868 + i * 0.03, 0.482),
      a.size.height * 0.016,
      charred: true,
    );
  }
  for (var i = 0; i < 3; i++) {
    _chestnut(
      a,
      a.p(0.958 + i * 0.01, 0.488),
      a.size.height * 0.009,
      charred: true,
    );
  }
  // Jars sunk in the floor to their shoulders.
  for (var i = 0; i < 2; i++) {
    final x = 0.855 + i * 0.07;
    a.canvas
      ..save()
      ..clipRect(a.r(x - 0.01, 0.6, 0.085, 0.2));
    a.oval(a.r(x, 0.66, 0.065, 0.26), const Color(0xFFA0643E));
    a.canvas.restore();
    a
      ..oval(a.r(x - 0.004, 0.79, 0.073, 0.02), const Color(0xFF3A3632))
      ..oval(a.r(x + 0.015, 0.65, 0.035, 0.03), _ashDark, line: 0.3);
  }
  _weeds(a, a.r(0.48, 0.78, 0.14, 0.03), seed: 8);
}

void _ovenOpen(Art a) {
  a
    ..box(Offset.zero & a.size, const Color(0xFF3A342F), line: 0.6)
    ..fill(a.r(0.08, 0.1, 0.84, 0.82), const Color(0xFF151210));
  final r = a.size.shortestSide * 0.14;
  for (final (x, y) in [
    (0.24, 0.72),
    (0.5, 0.74),
    (0.76, 0.72),
    (0.36, 0.46),
    (0.64, 0.46),
  ]) {
    _loaf(a, a.p(x, y), r, fresh: false);
  }
  // The door, swung aside.
  a.box(a.r(0.9, 0.08, 0.1, 0.84), const Color(0xFF2B2A28), line: 0.4);
}

void _bakery79(Art a) {
  // Roof beams in shadow.
  a
    ..fill(a.r(0, 0, 1, 0.16), const Color(0xFF2A2019))
    ..hairline(a.p(0, 0.08), a.p(1, 0.08), const Color(0xFF3E2F24), 1.2)
    ..hairline(a.p(0, 0.15), a.p(1, 0.15), Art.outline, 0.6);
  final room = _bakeryRoom(a);
  _panels(
    a,
    a.r(0, 0.16, 1, 0.56),
    field: const Color(0xFFD7B06A),
    frame: _red79,
    dado: _red79,
    count: 5,
  );
  _paving(a, 0.72, color: const Color(0xFF5E5852), vp: _bakeryEye);
  room.wallFoot();
  _mill(a, a.r(0.06, 0.36, 0.12, 0.46), color: const Color(0xFF4A4540));
  _mill(a, a.r(0.2, 0.42, 0.1, 0.4), color: const Color(0xFF4A4540));
  _donkey(a, a.r(0.0, 0.55, 0.16, 0.28));
  _doorway(
    a,
    a.r(0.36, 0.3, 0.1, 0.42),
    room: const Color(0xFF5A2A20),
    panel: _yellow79.withValues(alpha: 0.5),
  );
  _oven(a, brick: const Color(0xFF9A6A52), glow: true);
  // The baker's peel, leaning where it was dropped.
  a
    ..line(a.p(0.5, 0.36), a.p(0.56, 0.8), const Color(0xFF8A6A48), width: 0.9)
    ..oval(a.r(0.535, 0.74, 0.05, 0.07), const Color(0xFF8A6A48), line: 0.4);
  // Jars in the corner and a table with a basket, fruit, and wine.
  room.box(
    a.r(0.86, 0.56, 0.13, 0.015),
    const Color(0xFF5A4636),
    depth: 0.04,
    line: 0.4,
  );
  for (var i = 0; i < 2; i++) {
    a.oval(a.r(0.87 + i * 0.06, 0.4, 0.06, 0.16), const Color(0xFFB0704A));
  }
  room.standTable(
    a.r(0.83, 0.6, 0.16, 0.24),
    const Color(0xFF6E5038),
    deep: 0.1,
    legColor: const Color(0xFF4A3828),
  );
  a.oval(a.r(0.84, 0.54, 0.09, 0.07), const Color(0xFF9A7A4A));
  for (var i = 0; i < 3; i++) {
    _loaf(a, a.p(0.86 + i * 0.023, 0.55), a.size.height * 0.016, fresh: true);
  }
  for (var i = 0; i < 3; i++) {
    _pomegranateFruit(
      a,
      a.p(0.94 + (i % 2) * 0.018, 0.585 - (i ~/ 2) * 0.022),
      a.size.height * 0.012,
      charred: false,
    );
  }
  a.box(a.r(0.965, 0.53, 0.02, 0.07), const Color(0xFF8E5A36), line: 0.3);
  for (var i = 0; i < 4; i++) {
    a.circle(
      a.p(0.845 + i * 0.012, 0.595),
      a.size.height * 0.006,
      const Color(0xFF5A3A22),
      line: 0.2,
    );
  }
}

/// A donkey at the mill, blindfolded, standing still.
void _donkey(Art a, Rect rect) {
  Offset p(double x, double y) =>
      Offset(rect.left + rect.width * x, rect.top + rect.height * y);
  const coat = Color(0xFF7A6E62);
  for (final x in [0.3, 0.42, 0.7, 0.82]) {
    a.line(p(x, 0.55), p(x, 0.98), coat, width: 1.2);
  }
  a
    ..oval(Rect.fromPoints(p(0.2, 0.25), p(0.9, 0.65)), coat)
    ..path(
      a.poly([p(0.8, 0.35), p(0.95, 0.05), p(1.05, 0.1), p(0.9, 0.45)]),
      coat,
    )
    ..oval(Rect.fromPoints(p(0.92, 0.0), p(1.08, 0.22)), coat)
    ..line(p(0.96, 0.02), p(0.93, -0.12), coat, width: 1)
    ..line(p(1.0, 0.02), p(1.0, -0.12), coat, width: 1)
    ..line(p(0.93, 0.08), p(1.07, 0.1), _black79, width: 1.2);
}

// ---------------------------------------------------------------------------
// The atrium

/// The atrium's camera, shared by its hours and its sprites: one wide
/// wall, its foot at [_atriumFoot], the floor running back to it.
const _atriumEye = Offset(0.5, 0.42);
const _atriumFoot = 0.66;
const _atriumDepth = (_atriumFoot - 0.42) / (1 - 0.42);

Room _atriumRoom(Art a) => wallCamera(a, _atriumEye, _atriumFoot);

/// The stone stair up to the floor above, each step's tread showing.
void _atriumSteps(Art a, Room room, Color stone) {
  for (var i = 5; i >= 0; i--) {
    room.box(
      a.r(0.8 + i * 0.03, 0.72 - i * 0.06, 0.2 - i * 0.03, 0.06),
      stone,
      depth: 0.05,
      line: 0.4,
    );
  }
}

void _atrium(Art a) {
  final room = _atriumRoom(a);
  _sky1863(a, horizon: 0.18);
  _ruinWall(a, a.r(0, 0.12, 1, 0.7), color: _plasterDark, seed: 15, jag: 0.05);
  // Faded panels on the walls.
  for (final (x, w) in [(0.02, 0.2), (0.24, 0.16), (0.58, 0.14)]) {
    a
      ..fill(a.r(x, 0.24, w, 0.34), _fadedRed.withValues(alpha: 0.55))
      ..canvas.drawRect(
        a.r(x + 0.01, 0.26, w - 0.02, 0.3),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = a.u * 0.3
          ..color = const Color(0x88B89A5A),
      );
  }
  _flaking(a, a.r(0, 0.2, 1, 0.55), seed: 17, count: 34);
  // The opening onto the garden.
  _gardenGlimpse(a, a.r(0.44, 0.28, 0.12, 0.38));
  // The shrine: a niche and its altar, empty; the painted panel at its
  // back has fallen, leaving bare rubble.
  room.box(a.r(0.07, 0.28, 0.12, 0.2), const Color(0xFFB08E6E), depth: 0.03);
  a
    ..path(
      a.poly([a.p(0.06, 0.28), a.p(0.13, 0.22), a.p(0.2, 0.28)]),
      const Color(0xFFB08E6E),
    )
    ..box(a.r(0.085, 0.3, 0.09, 0.1), const Color(0xFF6A5A4C), line: 0.4);
  _flaking(a, a.r(0.085, 0.3, 0.09, 0.1), seed: 21, count: 8);
  room.box(a.r(0.09, 0.48, 0.08, 0.1), const Color(0xFF9E8A74), depth: 0.05);
  // Remnants of the child's drawing, low on the wall.
  _drawingRemnant(a, a.r(0.235, 0.35, 0.14, 0.2));
  // A grown-up's graffito, scratched in.
  a.scrawl(
    a.r(0.6, 0.31, 0.1, 0.12),
    const Color(0x99402A20),
    lines: 3,
    seed: 5,
    width: 0.25,
  );
  // The earthquake crack, patched.
  _crack(a);
  // The floor, its old paving still showing through the dust.
  a
    ..fill(a.r(0, 0.66, 1, 0.34), const Color(0xFF8C7462))
    ..hairline(a.p(0, 0.66), a.p(1, 0.66), Art.outline, 0.5);
  room
    ..floorGrid(const Color(0x33402C20), rows: 4, columns: 18, x0: -1, x1: 2)
    ..wallFoot(strength: 0.25);
  for (var i = 0; i < 60; i++) {
    final random = math.Random(i);
    a.canvas.drawCircle(
      a.p(random.nextDouble(), 0.66 + random.nextDouble() * 0.34),
      a.u * 0.25,
      Paint()..color = const Color(0x66E8DCC8),
    );
  }
  // Stone steps up to a floor that is gone, and the niche beneath.
  _atriumSteps(a, room, const Color(0xFF9A9186));
  _stairNiche(a, a.r(0.82, 0.7, 0.1, 0.12));
  // The rainwater basin in the floor, full of pumice.
  _basin(a, room, a.r(0.36, 0.7, 0.28, 0.12), full: true);
}

/// The garden seen through a doorway: the jambs' depth, sky, the far wall,
/// column stumps and weeds.
void _gardenGlimpse(Art a, Rect door) {
  final w = door.width;
  final h = door.height;
  Rect at(double x, double y, double dw, double dh) =>
      Rect.fromLTWH(door.left + w * x, door.top + h * y, w * dw, h * dh);
  a
    ..fade(at(0, 0, 1, 0.45), _skyTop, _skyLow)
    ..fill(at(0, 0.3, 1, 0.3), _plasterDark)
    ..fill(at(0, 0.6, 1, 0.4), const Color(0xFF8A8C72));
  for (final (x, top) in [(0.2, 0.36), (0.62, 0.44)]) {
    a.box(at(x, top, 0.12, 0.6 - top), const Color(0xFFD2C6B0), line: 0.3);
  }
  _weeds(a, at(0.05, 0.56, 0.9, 0.08), seed: 12);
  // The thickness of the wall on either side.
  a
    ..fill(at(0, 0, 0.08, 1), Color.lerp(_plasterDark, Art.outline, 0.3)!)
    ..fill(at(0.92, 0, 0.08, 1), Color.lerp(_plasterDark, Art.outline, 0.15)!)
    ..ink(door);
}

/// What is left of the child's charcoal drawing: a few islands of plaster
/// still holding lines (a sail, a figure, a letter), the rest flaked back
/// to the rubble.
void _drawingRemnant(Art a, Rect rect) {
  // Where the plaster has gone: rough rubble.
  a.canvas.drawRRect(
    RRect.fromRectAndRadius(rect, Radius.circular(a.u)),
    Paint()..color = _plasterDark.withValues(alpha: 0.7),
  );
  final random = math.Random(8);
  for (var i = 0; i < 26; i++) {
    a.canvas.drawCircle(
      Offset(
        rect.left + random.nextDouble() * rect.width,
        rect.top + random.nextDouble() * rect.height,
      ),
      a.u * (0.3 + random.nextDouble() * 0.5),
      Paint()..color = const Color(0x66564A3E),
    );
  }
  // The islands that held, with the drawing still on them.
  final islands = Path();
  for (final (x, y, w, h) in [
    (0.62, 0.36, 0.3, 0.4),
    (0.1, 0.4, 0.3, 0.36),
    (0.34, 0.1, 0.22, 0.2),
  ]) {
    final c = Offset(
      rect.left + rect.width * (x + w / 2),
      rect.top + rect.height * (y + h / 2),
    );
    final points = <Offset>[];
    for (var i = 0; i < 11; i++) {
      final angle = i / 11 * 2 * math.pi;
      final k = 0.7 + random.nextDouble() * 0.45;
      points.add(
        c +
            Offset(
              math.cos(angle) * rect.width * w / 2 * k,
              math.sin(angle) * rect.height * h / 2 * k,
            ),
      );
    }
    islands.addPolygon(points, true);
  }
  a.canvas
    ..save()
    ..clipPath(islands)
    ..drawRect(rect, Paint()..color = _plaster)
    ..translate(rect.left, rect.top)
    ..saveLayer(
      Offset.zero & rect.size,
      Paint()..color = const Color(0x99000000),
    );
  final local = Art(a.canvas, rect.size);
  _boat(local);
  _people(local);
  _words(local);
  a.canvas
    ..restore()
    ..restore();
  a.canvas.drawPath(
    islands,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = a.u * 0.2
      ..color = const Color(0x88564A3E),
  );
}

/// The crack from the earthquake of 62: a ragged split running down the
/// wall with branches, a smear of newer, paler plaster over its middle.
void _crack(Art a) {
  final random = math.Random(62);
  final points = <Offset>[];
  var x = 0.752;
  for (var i = 0; i <= 18; i++) {
    x += (random.nextDouble() - 0.5) * 0.012;
    points.add(a.p(x, 0.17 + i * 0.018));
  }
  // The patch of newer plaster, trowelled over the middle.
  final patch = a.poly([
    a.p(0.738, 0.29),
    a.p(0.764, 0.285),
    a.p(0.772, 0.33),
    a.p(0.768, 0.39),
    a.p(0.77, 0.415),
    a.p(0.742, 0.41),
    a.p(0.733, 0.36),
  ]);
  a.canvas
    ..drawPath(patch, Paint()..color = const Color(0xCCD8CCB2))
    ..drawPath(
      patch,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = a.u * 0.25
        ..color = const Color(0x55564A3E),
    );
  final crack = Path()..addPolygon(points, false);
  a.canvas
    ..drawPath(
      crack,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = a.u * 0.9
        ..strokeJoin = StrokeJoin.round
        ..color = const Color(0xFF2A221C),
    )
    ..drawPath(
      crack.shift(Offset(a.u * 0.4, 0)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = a.u * 0.25
        ..color = const Color(0x55FFF4E0),
    );
  // Hairline branches off the main split.
  for (final (i, dx, dy) in [
    (3, 0.018, 0.03),
    (13, -0.02, 0.035),
    (16, 0.015, 0.03),
  ]) {
    final from = points[i];
    a.canvas.drawLine(
      from,
      from + Offset(a.size.width * dx, a.size.height * dy),
      Paint()
        ..strokeWidth = a.u * 0.3
        ..color = const Color(0xCC2A221C),
    );
  }
  // Where the patch has cracked again, faintly.
  a.hairline(points[7], points[11], const Color(0x662A221C), 0.3);
}

/// The little arched niche under the stair, packed with ash.
void _stairNiche(
  Art a,
  Rect rect, {
  bool ash = true,
  Color stone = const Color(0xFF9A9186),
}) {
  Path arch(Rect r) => Path()
    ..moveTo(r.left, r.bottom)
    ..lineTo(r.left, r.top + r.height * 0.4)
    ..quadraticBezierTo(
      r.center.dx,
      r.top - r.height * 0.2,
      r.right,
      r.top + r.height * 0.4,
    )
    ..lineTo(r.right, r.bottom)
    ..close();
  a.path(arch(rect), stone, line: 0.5);
  final inner = arch(
    Rect.fromLTRB(
      rect.left + rect.width * 0.12,
      rect.top + rect.height * 0.18,
      rect.right - rect.width * 0.12,
      rect.bottom,
    ),
  );
  a.path(inner, const Color(0xFF2E2A26), line: 0.35);
  if (!ash) return;
  // Ash packed into it, heaped.
  a.canvas
    ..save()
    ..clipPath(inner);
  a.path(
    a.poly([
      Offset(rect.left, rect.bottom),
      Offset(rect.left, rect.top + rect.height * 0.62),
      Offset(rect.center.dx, rect.top + rect.height * 0.5),
      Offset(rect.right, rect.top + rect.height * 0.66),
      Offset(rect.right, rect.bottom),
    ]),
    const Color(0xFFA6A098),
    line: 0,
  );
  final random = math.Random(4);
  for (var i = 0; i < 14; i++) {
    a.canvas.drawCircle(
      Offset(
        rect.left + rect.width * (0.15 + random.nextDouble() * 0.7),
        rect.top + rect.height * (0.6 + random.nextDouble() * 0.35),
      ),
      a.u * 0.35,
      Paint()..color = _ashDark,
    );
  }
  a.canvas.restore();
}

/// The rainwater basin sunk in the floor, seen from above at a slant: a
/// marble rim, and inside it either water or heaped pumice.
void _basin(
  Art a,
  Room room,
  Rect rect, {
  required bool full,
  Color water = const Color(0xFF3E5566),
}) {
  // Its corners on the floor, the far edge drawn in towards the eye.
  final z0 = room.floorDepthAt(rect.bottom);
  final z1 = room.floorDepthAt(rect.top);
  final x0 = room.xAt(rect.left, z0);
  final x1 = room.xAt(rect.right, z0);
  Path quad(double inset, double y, {double far = 0}) {
    final dx = (x1 - x0) * inset;
    final dz = (z1 - z0) * inset * 1.6;
    return a.poly([
      room.at(x0 + dx, y, z1 - dz - far),
      room.at(x1 - dx, y, z1 - dz - far),
      room.at(x1 - dx, y, z0 + dz),
      room.at(x0 + dx, y, z0 + dz),
    ]);
  }

  room.shadow(x0, x1, z0, z1, strength: 0.2, spread: 0.04);
  a.path(quad(0, 0.012), const Color(0xFFD9D2C4), line: 0.5);
  // The sunk pool: its inner walls, then what lies in it, lower down.
  final opening = quad(0.07, 0.012);
  a.path(opening, const Color(0xFF7E776C), line: 0.4);
  final pool = quad(0.07, -0.03);
  a.canvas
    ..save()
    ..clipPath(opening);
  if (!full) {
    a.path(pool, water, line: 0.3);
    a.canvas.restore();
    return;
  }
  a.path(pool, const Color(0xFF8D8574), line: 0.3);
  a.canvas.clipPath(pool);
  final bounds = pool.getBounds();
  final random = math.Random(31);
  for (var i = 0; i < 110; i++) {
    final c = Offset(
      bounds.left + random.nextDouble() * bounds.width,
      bounds.top + random.nextDouble() * bounds.height,
    );
    final r = a.u * (0.6 + random.nextDouble() * 0.7);
    a.canvas
      ..drawOval(
        Rect.fromCenter(
          center: c.translate(0, r * 0.3),
          width: r * 2.2,
          height: r * 1.6,
        ),
        Paint()..color = const Color(0xFF9E9582),
      )
      ..drawOval(
        Rect.fromCenter(center: c, width: r * 2, height: r * 1.4),
        Paint()..color = i.isEven ? _pumice : const Color(0xFFC4BAA4),
      )
      ..drawCircle(
        c.translate(-r * 0.3, -r * 0.25),
        r * 0.3,
        Paint()..color = const Color(0x88FFFFFF),
      );
  }
  a.canvas.restore();
}

/// The hours the lens can look at in the atrium.
enum _Hour { morning, noon, afternoon }

void _atrium79(Art a, _Hour hour) {
  final afternoon = hour == _Hour.afternoon;
  final room = _atriumRoom(a);
  // The roof seen from below, its beams running back to the wall, and the
  // opening in it over the basin.
  final ceiling = room.yAt(a.p(0, 0.2).dy, 1);
  final opening = a.poly([
    room.at(0.3, ceiling, 0.2),
    room.at(0.7, ceiling, 0.2),
    room.at(0.7, ceiling, 0.9),
    room.at(0.3, ceiling, 0.9),
  ]);
  a.fill(a.r(0, 0, 1, 0.2), const Color(0xFF241A14));
  for (var k = 1; k < 8; k++) {
    final z = 1 - (k / 8) * (k / 8);
    a.line(
      room.at(-1, ceiling, z),
      room.at(2, ceiling, z),
      const Color(0xFF3E2F24),
      width: 1.4,
    );
  }
  a.path(opening, switch (hour) {
    _Hour.morning => const Color(0xFF9FB8CC),
    _Hour.noon => const Color(0xFF6A5A4E),
    _Hour.afternoon => _sky79Top,
  }, line: 0);
  if (hour == _Hour.noon) {
    // The cloud's trunk, seen straight up through the opening.
    a.canvas.save();
    a.canvas.clipPath(opening);
    _pineCloud(a, 0.5, 0.2, -0.02, 0.2);
    a.canvas.restore();
  }
  a.path(opening, const Color(0x00000000), line: 0.6);
  _panels(
    a,
    a.r(0, 0.2, 1, 0.46),
    field: _red79,
    frame: _yellow79,
    dado: _black79,
    count: 5,
  );
  a
    ..box(a.r(0.44, 0.28, 0.12, 0.38), const Color(0xFF5E6A4A))
    ..fill(a.r(0.44, 0.54, 0.12, 0.12), const Color(0xFF3E4A30));
  // The shrine, its painted panel whole.
  room.box(a.r(0.07, 0.28, 0.12, 0.2), const Color(0xFFE6D2A6), depth: 0.03);
  a.path(a.poly([a.p(0.06, 0.28), a.p(0.13, 0.22), a.p(0.2, 0.28)]), _yellow79);
  final panel = a.r(0.085, 0.3, 0.09, 0.1);
  a.canvas
    ..save()
    ..translate(panel.left, panel.top);
  _fresco(Art(a.canvas, panel.size));
  a.canvas.restore();
  a.ink(panel, width: 0.4);
  room.box(a.r(0.09, 0.48, 0.08, 0.1), const Color(0xFFD8C8B0), depth: 0.05);
  if (afternoon) {
    // The little gods, wrapped in a cloth to go.
    a.oval(a.r(0.1, 0.44, 0.06, 0.04), const Color(0xFFE8E0D0), line: 0.3);
  } else {
    for (final x in [0.1, 0.155]) {
      a.box(a.r(x, 0.43, 0.012, 0.05), StillroomPalette.brass, line: 0.2);
    }
  }
  if (afternoon) {
    // The child's drawing, fresh, half hidden behind the family.
    a
      ..line(a.p(0.25, 0.52), a.p(0.37, 0.52), _charcoal, width: 0.4)
      ..line(a.p(0.33, 0.4), a.p(0.33, 0.5), _charcoal, width: 0.4);
  }
  // The strongbox against the wall.
  final box = a.r(0.6, 0.5, 0.14, 0.16);
  a.canvas
    ..save()
    ..translate(box.left, box.top);
  _arca(Art(a.canvas, box.size), open: false);
  a.canvas.restore();
  // The floor: red mortar set with chips of white stone.
  a
    ..fill(a.r(0, 0.66, 1, 0.34), const Color(0xFF7E5A46))
    ..hairline(a.p(0, 0.66), a.p(1, 0.66), Art.outline, 0.5);
  room
    ..floorGrid(const Color(0x44301E14), rows: 4, columns: 18, x0: -1, x1: 2)
    ..wallFoot(strength: 0.3);
  // Stairs and the niche beneath them.
  _atriumSteps(a, room, const Color(0xFF7A5A40));
  _stairNiche(
    a,
    a.r(0.82, 0.7, 0.1, 0.12),
    ash: false,
    stone: const Color(0xFF7A5A40),
  );
  if (afternoon) {
    final horse = a.r(0.835, 0.72, 0.07, 0.08);
    a.canvas
      ..save()
      ..translate(horse.left, horse.top);
    _horse(Art(a.canvas, horse.size));
    a.canvas.restore();
  } else if (hour == _Hour.morning) {
    // At play by the basin.
    final horse = a.r(0.67, 0.64, 0.05, 0.06);
    a.canvas
      ..save()
      ..translate(horse.left, horse.top);
    _horse(Art(a.canvas, horse.size));
    a.canvas.restore();
  }
  // The basin.
  _basin(a, room, a.r(0.36, 0.7, 0.28, 0.12), full: false);
  switch (hour) {
    case _Hour.morning:
      a
        ..glow(
          a.p(0.5, 0.74),
          a.size.width * 0.1,
          const Color(0xFFBFD7E6),
          strength: 0.3,
        )
        ..oval(a.r(0.46, 0.745, 0.03, 0.015), _leaf, line: 0.2);
    case _Hour.noon:
      break;
    case _Hour.afternoon:
      _falling(a, count: 70, seed: 3, inside: a.r(0.38, 0.0, 0.24, 0.8));
      final random = math.Random(8);
      for (var i = 0; i < 14; i++) {
        a.oval(
          a.r(
            0.38 + random.nextDouble() * 0.23,
            0.72 + random.nextDouble() * 0.08,
            0.012,
            0.008,
          ),
          _pumice,
          line: 0.2,
        );
      }
  }
}

// ---------------------------------------------------------------------------
// The shrine's painted panel

/// A household shrine painting, as at many houses in Pompeii: the spirit of
/// the house (the Genius) pouring an offering at an altar, a dancing god of
/// the household (a Lar) on each side with a drinking horn, and a serpent
/// coming to the altar below. Painted figures, no faces.
void _fresco(Art a) {
  a
    ..fill(Offset.zero & a.size, _red79)
    ..fill(a.r(0, 0.8, 1, 0.2), _black79)
    ..canvas.drawRect(
      a.r(0.03, 0.02, 0.94, 0.96),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = a.size.width * 0.02
        ..color = _yellow79,
    );
  // Garlands across the top.
  for (final x in [0.1, 0.4, 0.7]) {
    a.strokePath(
      Path()
        ..moveTo(a.p(x, 0.08).dx, a.p(x, 0.08).dy)
        ..quadraticBezierTo(
          a.p(x + 0.1, 0.18).dx,
          a.p(x + 0.1, 0.18).dy,
          a.p(x + 0.2, 0.08).dx,
          a.p(x + 0.2, 0.08).dy,
        ),
      _green79,
      width: 1.2,
    );
  }
  // The altar.
  a.box(a.r(0.42, 0.58, 0.16, 0.2), const Color(0xFFB8AE9C), line: 0.4);
  a.glow(
    a.p(0.5, 0.56),
    a.size.width * 0.06,
    StillroomPalette.gaslight,
    strength: 0.6,
  );
  // The Genius, veiled, pouring from a dish.
  const toga = Color(0xFFEDE3CF);
  a
    ..path(
      a.poly([
        a.p(0.44, 0.24),
        a.p(0.56, 0.24),
        a.p(0.6, 0.56),
        a.p(0.4, 0.56),
      ]),
      toga,
      line: 0.3,
    )
    ..oval(a.r(0.455, 0.12, 0.09, 0.12), const Color(0xFFD9B48A), line: 0.3)
    ..path(
      a.poly([
        a.p(0.44, 0.14),
        a.p(0.5, 0.1),
        a.p(0.56, 0.14),
        a.p(0.57, 0.26),
        a.p(0.43, 0.26),
      ]),
      toga,
      line: 0.3,
    )
    ..line(a.p(0.55, 0.32), a.p(0.52, 0.5), toga, width: 1.4)
    ..oval(a.r(0.48, 0.5, 0.08, 0.025), StillroomPalette.brass, line: 0.2);
  // A Lar on each side, dancing, a horn raised high.
  const tunic = Color(0xFF6E8E5A);
  for (final (x, flip) in [(0.18, 1.0), (0.82, -1.0)]) {
    a
      ..oval(a.r(x - 0.04, 0.2, 0.08, 0.1), const Color(0xFFD9B48A), line: 0.3)
      ..path(
        a.poly([
          a.p(x - 0.06, 0.3),
          a.p(x + 0.06, 0.3),
          a.p(x + 0.1, 0.56),
          a.p(x - 0.1, 0.56),
        ]),
        tunic,
        line: 0.3,
      )
      ..line(
        a.p(x - 0.04, 0.56),
        a.p(x - 0.08 * flip, 0.76),
        const Color(0xFFD9B48A),
        width: 1.2,
      )
      ..line(
        a.p(x + 0.03, 0.56),
        a.p(x + 0.05 * flip, 0.76),
        const Color(0xFFD9B48A),
        width: 1.2,
      )
      ..line(
        a.p(x + 0.05 * flip, 0.34),
        a.p(x + 0.1 * flip, 0.16),
        const Color(0xFFD9B48A),
        width: 1.1,
      )
      ..path(
        a.poly([
          a.p(x + 0.1 * flip, 0.16),
          a.p(x + 0.16 * flip, 0.1),
          a.p(x + 0.12 * flip, 0.2),
        ]),
        StillroomPalette.brass,
        line: 0.2,
      );
  }
  // The serpent along the bottom, towards the altar.
  final serpent = Path()..moveTo(a.p(0.06, 0.9).dx, a.p(0.06, 0.9).dy);
  for (var i = 1; i <= 8; i++) {
    serpent.quadraticBezierTo(
      a.p(0.06 + i * 0.045 - 0.022, i.isOdd ? 0.83 : 0.95).dx,
      a.p(0, i.isOdd ? 0.83 : 0.95).dy,
      a.p(0.06 + i * 0.045, 0.89).dx,
      a.p(0, 0.89).dy,
    );
  }
  a
    ..strokePath(serpent, const Color(0xFF8FA34A), width: 1.6)
    ..oval(a.r(0.41, 0.86, 0.04, 0.05), const Color(0xFF8FA34A), line: 0.2);
}

/// One of the six pieces the panel broke into: two columns, three rows.
void _frescoPiece(Art a, int index) {
  final col = index % 2;
  final row = index ~/ 2;
  final w = a.size.width;
  final h = a.size.height;
  a.canvas
    ..save()
    ..clipRect(Offset.zero & a.size)
    ..translate(-col * w, -row * h);
  _fresco(Art(a.canvas, Size(w * 2, h * 3)));
  a.canvas.restore();
  // Broken edges and the plaster behind.
  final random = math.Random(index + 7);
  final edge = Path()..moveTo(0, 0);
  for (var i = 1; i <= 8; i++) {
    edge.lineTo(w * i / 8, random.nextDouble() * h * 0.02);
  }
  for (var i = 1; i <= 8; i++) {
    edge.lineTo(w - random.nextDouble() * w * 0.02, h * i / 8);
  }
  for (var i = 7; i >= 0; i--) {
    edge.lineTo(w * i / 8, h - random.nextDouble() * h * 0.02);
  }
  for (var i = 7; i >= 1; i--) {
    edge.lineTo(random.nextDouble() * w * 0.02, h * i / 8);
  }
  edge.close();
  a.canvas.drawPath(
    edge,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = a.u * 1.2
      ..color = const Color(0xFFD9CDB6),
  );
  a.strokePath(edge, Art.outline, width: 0.3);
}

/// The panel's pieces where they fell, in the ash below the shrine.
void _frescoFallen(Art a) {
  final random = math.Random(12);
  for (var i = 0; i < 7; i++) {
    final x = 0.05 + i * 0.13 + random.nextDouble() * 0.04;
    final y = 0.2 + random.nextDouble() * 0.5;
    final color = [_red79, _black79, _yellow79][i % 3];
    a.path(
      a.poly([
        a.p(x, y),
        a.p(x + 0.1, y - 0.1 - random.nextDouble() * 0.1),
        a.p(x + 0.12, y + 0.2),
        a.p(x + 0.02, y + 0.26),
      ]),
      color,
      line: 0.3,
    );
  }
}

/// The shrine wall close up: where the panel was, the painter's red
/// underdrawing still shows faintly, a guide for the pieces.
void _frescoBoard(Art a) {
  a
    ..fill(Offset.zero & a.size, const Color(0xFFBFAE90))
    ..box(a.r(0.33, 0.06, 0.34, 0.86), const Color(0xFFB08E6E), line: 0.6);
  final panel = a.r(0.36, 0.1, 0.28, 0.78);
  a.canvas
    ..save()
    ..translate(panel.left, panel.top)
    ..saveLayer(
      Offset.zero & panel.size,
      Paint()..color = const Color(0x2E000000),
    );
  _fresco(Art(a.canvas, panel.size));
  a.canvas
    ..restore()
    ..restore();
  a.ink(panel, width: 0.5);
  _flaking(a, a.r(0, 0, 1, 1), seed: 44, count: 30);
}

// ---------------------------------------------------------------------------
// The strongbox and the wax tablets

/// The strongbox against the atrium wall (its layer
/// [0.6, 0.5, 0.14, 0.16]): iron-bound, standing on the floor, its top and
/// the side towards the room showing; open, its lid thrown back.
void _arca(Art a, {required bool open}) {
  const wood = Color(0xFF5A3E28);
  const iron = Color(0xFF2E2C2A);
  final room = Room.sprite(
    a,
    eye: _atriumEye,
    layer: (0.6, 0.5, 0.14, 0.16),
    depth: _atriumDepth,
  );
  Room.spriteShadow(a, 0.12, 1);
  final h = open ? 0.56 : 0.72;
  if (open) {
    room.block(0.2, 1, h, h + 0.38, 0.22, 0.25, wood);
  }
  final front = room.block(
    0.2,
    1,
    0,
    h,
    0,
    0.22,
    wood,
    top: open ? const Color(0xFF140E0A) : null,
  );
  paintOnFace(a, front, (f) {
    for (final x in [0.04, 0.47, 0.9]) {
      f.fill(f.r(x, 0, 0.06, 1), iron);
    }
    if (!open) {
      f
        ..fill(f.r(0, 0, 1, 0.08), iron)
        ..box(f.r(0.41, 0.3, 0.18, 0.26), StillroomPalette.brass, line: 0.3)
        ..fill(f.r(0.49, 0.37, 0.02, 0.12), Art.outline);
    }
  });
}

void _key(Art a) {
  const bronze = Color(0xFF8A6A3A);
  a
    ..circle(a.p(0.3, 0.3), a.size.width * 0.14, bronze)
    ..circle(a.p(0.3, 0.3), a.size.width * 0.07, const Color(0x00000000))
    ..line(a.p(0.38, 0.38), a.p(0.78, 0.78), bronze, width: 3)
    ..box(a.r(0.66, 0.74, 0.08, 0.12), bronze, line: 0.3)
    ..box(a.r(0.76, 0.66, 0.08, 0.1), bronze, line: 0.3)
    ..glow(
      a.p(0.3, 0.3),
      a.size.width * 0.2,
      const Color(0xFF6FA88A),
      strength: 0.15,
    );
}

/// Two wooden leaves side by side, their wax gone dark.
void _tabletSurface(Art a) {
  const wood = Color(0xFF8A6A48);
  const wax = Color(0xFF2E2418);
  for (final x in [0.04, 0.52]) {
    a
      ..wood(a.r(x, 0.12, 0.44, 0.76), base: wood, grain: 3)
      ..box(a.r(x + 0.04, 0.2, 0.36, 0.6), wax, line: 0.3);
  }
  for (final y in [0.35, 0.65]) {
    a.line(a.p(0.48, y), a.p(0.52, y), const Color(0xFFB09A6A), width: 1);
  }
}

/// What was scratched into the wax: lines of cursive, the first a name.
void _tabletMarks(Art a) {
  a
    ..script(
      'FELIX RVFO S',
      a.p(0.24, 0.27),
      a.size.height * 0.045,
      Art.outline,
    )
    ..scrawl(
      a.r(0.1, 0.34, 0.32, 0.42),
      Art.outline,
      lines: 4,
      seed: 79,
      width: 0.5,
    )
    ..scrawl(
      a.r(0.58, 0.24, 0.32, 0.52),
      Art.outline,
      lines: 5,
      seed: 80,
      width: 0.5,
    );
}

void _tabletBoard(Art a) =>
    a.wood(Offset.zero & a.size, base: const Color(0xFF2A1E15), grain: 12);

/// A clay horse on wheels.
void _horse(Art a) {
  const clay = Color(0xFFB0704A);
  a
    ..oval(a.r(0.15, 0.3, 0.6, 0.32), clay)
    ..path(
      a.poly([
        a.p(0.6, 0.35),
        a.p(0.78, 0.02),
        a.p(0.92, 0.1),
        a.p(0.74, 0.42),
      ]),
      clay,
    )
    ..line(a.p(0.25, 0.58), a.p(0.25, 0.75), clay, width: 1.2)
    ..line(a.p(0.62, 0.58), a.p(0.62, 0.75), clay, width: 1.2)
    ..box(a.r(0.1, 0.74, 0.7, 0.06), const Color(0xFF7A5436), line: 0.3)
    ..circle(a.p(0.2, 0.86), a.size.width * 0.1, const Color(0xFF5A3E28))
    ..circle(a.p(0.7, 0.86), a.size.width * 0.1, const Color(0xFF5A3E28));
}

/// The draughtsman's tin tube, dropped by the wall, its cap off and the
/// rolled tracing sheets sliding out.
void _tube(Art a) {
  const tin = Color(0xFF9AA2A6);
  final body = a.r(0.04, 0.3, 0.7, 0.4);
  a
    ..box(body, tin, line: 0.5)
    ..fade(
      Rect.fromLTWH(body.left, body.top, body.width, body.height * 0.45),
      const Color(0x88FFFFFF),
      const Color(0x00FFFFFF),
    )
    ..fill(
      Rect.fromLTWH(
        body.left,
        body.bottom - body.height * 0.25,
        body.width,
        body.height * 0.25,
      ),
      const Color(0x33000000),
    )
    ..ink(body, width: 0.5)
    // Seams round the tube.
    ..hairline(a.p(0.16, 0.3), a.p(0.16, 0.7), const Color(0xFF5E6468), 0.5)
    ..hairline(a.p(0.62, 0.3), a.p(0.62, 0.7), const Color(0xFF5E6468), 0.5)
    // The closed end.
    ..oval(a.r(0.0, 0.3, 0.08, 0.4), const Color(0xFF7E868A), line: 0.5);
  // The open end, and the roll of sheets coming out of it.
  a
    ..oval(a.r(0.7, 0.3, 0.08, 0.4), const Color(0xFF2E3234), line: 0.5)
    ..box(a.r(0.74, 0.34, 0.2, 0.32), _paper, line: 0.4)
    ..oval(a.r(0.9, 0.34, 0.08, 0.32), const Color(0xFFD8CDB2), line: 0.4);
  // The curl of the roll, and faint lines drawn on the outer sheet.
  a.canvas.drawArc(
    a.r(0.915, 0.4, 0.05, 0.2),
    -math.pi / 2,
    math.pi * 1.5,
    false,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = a.u * 0.4
      ..color = const Color(0xFF8A7E66),
  );
  for (final y in [0.42, 0.5, 0.58]) {
    a.hairline(a.p(0.77, y), a.p(0.89, y + 0.01), const Color(0x882A2420), 0.4);
  }
}

/// The jar's blank label, propped at the shrine.
void _labelTag(Art a) => a
  ..box(a.r(0.05, 0.1, 0.9, 0.8), _paper, line: 0.5)
  ..hairline(a.p(0.2, 0.5), a.p(0.8, 0.5), const Color(0x552A2420), 0.3);

// ---------------------------------------------------------------------------
// The garden

/// A round column (or its stump) in [r]: shaded down its far side, its
/// top seen as an ellipse if it is below the eye, its shadow at its foot.
void _column(Art a, Rect r, Color color, {bool top = true}) {
  a.canvas.drawOval(
    Rect.fromLTRB(
      r.left - r.width * 0.3,
      r.bottom - a.u * 0.8,
      r.right + r.width * 0.9,
      r.bottom + a.u * 1.2,
    ),
    Paint()
      ..color = const Color(0x55000000)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, a.u * 0.8),
  );
  a.box(r, color);
  a.canvas.drawRect(
    r.deflate(a.u * 0.15),
    Paint()
      ..shader = Gradient.linear(
        r.centerLeft,
        r.centerRight,
        [
          const Color(0x22FFFFFF),
          const Color(0x00000000),
          const Color(0x55000000),
        ],
        [0, 0.4, 1],
      ),
  );
  if (top) {
    a.oval(
      Rect.fromCenter(
        center: r.topCenter,
        width: r.width,
        height: r.width * 0.35,
      ),
      Color.lerp(color, const Color(0xFFFFFFFF), 0.15)!,
      line: 0.4,
    );
  }
}

void _garden(Art a) {
  _sky1863(a, horizon: 0.36);
  _vesuvius(a, 0.51, 0.06, 0.34);
  _smoke(a, 0.52, 0.05);
  // The back wall and the stumps of the colonnade.
  _ruinWall(a, a.r(0, 0.26, 1, 0.36), color: _plasterDark, seed: 23);
  for (var i = 0; i < 5; i++) {
    final x = 0.05 + i * 0.1;
    _column(
      a,
      a.r(x, 0.48 - (i % 3) * 0.05, 0.03, 0.14 + (i % 3) * 0.05),
      const Color(0xFFD2C6B0),
    );
  }
  // The ground: ash, grown over with weeds, darker under the wall.
  a
    ..fill(a.r(0, 0.6, 1, 0.4), _ash)
    ..fade(
      a.r(0, 0.6, 1, 0.08),
      const Color(0x44000000),
      const Color(0x00000000),
    );
  _weeds(a, a.r(0.02, 0.58, 0.12, 0.04), seed: 3);
  // Far off, under the diggers' canvas, the pale casts, left in peace.
  a
    ..line(
      a.p(0.08, 0.44),
      a.p(0.08, 0.62),
      const Color(0xFF5A4636),
      width: 0.6,
    )
    ..line(
      a.p(0.24, 0.44),
      a.p(0.24, 0.62),
      const Color(0xFF5A4636),
      width: 0.6,
    )
    ..path(
      a.poly([a.p(0.05, 0.45), a.p(0.16, 0.4), a.p(0.27, 0.45)]),
      const Color(0xFFD8CFBE),
      line: 0.4,
    )
    ..fill(a.r(0.09, 0.58, 0.14, 0.02), const Color(0xFF6E5A46));
  for (final (x, w) in [(0.11, 0.05), (0.17, 0.04)]) {
    a.canvas.drawOval(
      a.r(x, 0.555, w, 0.028),
      Paint()
        ..color = const Color(0xCCE6E0D4)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, a.u * 0.4),
    );
  }
  _rootHollow(a, a.r(0.37, 0.64, 0.14, 0.1));
  _excavationCut(a);
}

/// Where a tree stood: a pit in the ash, a raised lip round it, and the
/// channels its roots left, running off under the surface.
void _rootHollow(Art a, Rect rect) {
  final c = rect.center;
  final dark = Color.lerp(_ash, Art.outline, 0.6)!;
  final random = math.Random(19);
  // Root channels, branching outwards.
  for (var i = 0; i < 5; i++) {
    final angle = math.pi * (0.95 + i / 4 * 1.1) + random.nextDouble() * 0.2;
    var from = c;
    var length = rect.width * (0.4 + random.nextDouble() * 0.2);
    var width = 1.1;
    for (var step = 0; step < 3; step++) {
      final bend = angle + (random.nextDouble() - 0.5) * 0.6;
      final to =
          from +
          Offset(math.cos(bend) * length * 0.5, math.sin(bend) * length * 0.18);
      a.canvas.drawLine(
        from,
        to,
        Paint()
          ..strokeWidth = a.u * width
          ..strokeCap = StrokeCap.round
          ..color = dark.withValues(alpha: 0.75),
      );
      from = to;
      length *= 0.7;
      width *= 0.6;
    }
  }
  // The lip of ash round the pit.
  a.canvas.drawOval(
    Rect.fromCenter(
      center: c,
      width: rect.width * 0.72,
      height: rect.height * 0.62,
    ),
    Paint()..color = Color.lerp(_ash, _pumice, 0.5)!,
  );
  final pit = Path();
  final points = <Offset>[];
  for (var i = 0; i < 12; i++) {
    final angle = i / 12 * 2 * math.pi;
    final k = 0.8 + random.nextDouble() * 0.3;
    points.add(
      c +
          Offset(
            math.cos(angle) * rect.width * 0.26 * k,
            math.sin(angle) * rect.height * 0.22 * k,
          ),
    );
  }
  pit.addPolygon(points, true);
  a.path(pit, const Color(0xFF1E1B18), line: 0.4);
  // The pit's far wall catches a little light.
  a.canvas
    ..save()
    ..clipPath(pit)
    ..drawOval(
      Rect.fromCenter(
        center: c.translate(0, -rect.height * 0.14),
        width: rect.width * 0.5,
        height: rect.height * 0.2,
      ),
      Paint()..color = const Color(0x66A09A90),
    )
    ..restore();
}

/// The diggers' cut: the unexcavated ground standing as a cliff over the
/// cleared garden, its layers showing like pages, grass on top, a striped
/// measuring pole against it, fallen pumice at its foot, a ladder up.
void _excavationCut(Art a) {
  const left = 0.64;
  const top = 0.32;
  const foot = 0.8;
  final random = math.Random(41);
  final cliff = <Offset>[a.p(0.6, foot), a.p(left, top + 0.03)];
  for (var i = 0; i <= 8; i++) {
    cliff.add(a.p(left + 0.02 + i * 0.045, top + random.nextDouble() * 0.02));
  }
  cliff.addAll([a.p(1, top), a.p(1, foot)]);
  final face = a.poly(cliff);
  a.path(face, _pumice, line: 0);
  a.canvas
    ..save()
    ..clipPath(face);
  // The layers, newest on top: turf, fine grey ash, pumice, garden soil.
  Path band(double from, double to, int seed) {
    final wave = math.Random(seed);
    final path = Path()..moveTo(0, a.p(0, from).dy);
    for (var i = 1; i <= 10; i++) {
      path.lineTo(
        a.p(i / 10, 0).dx,
        a.p(0, from + (wave.nextDouble() - 0.5) * 0.012).dy,
      );
    }
    path
      ..lineTo(a.size.width, a.p(0, to).dy)
      ..lineTo(0, a.p(0, to).dy)
      ..close();
    return path;
  }

  a.canvas
    ..drawPath(
      band(top - 0.02, 0.36, 1),
      Paint()..color = const Color(0xFF5E5A3C),
    )
    ..drawPath(band(0.36, 0.45, 2), Paint()..color = const Color(0xFF8A8580));
  for (var i = 1; i < 4; i++) {
    a.hairline(
      a.p(left, 0.36 + i * 0.022),
      a.p(1, 0.36 + i * 0.022),
      const Color(0x55403A34),
      0.25,
    );
  }
  for (var i = 0; i < 150; i++) {
    final p = a.p(
      left - 0.04 + random.nextDouble() * 0.4,
      0.46 + random.nextDouble() * 0.26,
    );
    final r = a.u * (0.3 + random.nextDouble() * 0.6);
    a.canvas
      ..drawCircle(
        p.translate(0, r * 0.3),
        r,
        Paint()..color = const Color(0xFF9E9582),
      )
      ..drawCircle(p, r * 0.85, Paint()..color = const Color(0xFFC8BEA8));
  }
  a.canvas.drawPath(band(0.72, foot, 3), Paint()..color = _soil);
  for (var i = 0; i < 6; i++) {
    final x = left + random.nextDouble() * 0.34;
    a.hairline(
      a.p(x, 0.73),
      a.p(x + (random.nextDouble() - 0.5) * 0.03, 0.79),
      const Color(0xFF2E2419),
      0.3,
    );
  }
  // Shade under the overhang of turf.
  a.fade(
    a.r(0, 0.35, 1, 0.05),
    const Color(0x55000000),
    const Color(0x00000000),
  );
  a.canvas.restore();
  a.path(face, const Color(0x00000000), line: 0.5);
  // Grass along the top edge.
  _weeds(a, a.r(left, top - 0.035, 0.36, 0.035), seed: 9);
  // Its shadow on the cleared ground.
  a.fade(
    a.r(0.6, foot, 0.4, 0.06),
    const Color(0x55000000),
    const Color(0x00000000),
  );
  // Fallen pumice heaped at the foot.
  a.path(
    a.poly([
      a.p(0.6, foot + 0.005),
      a.p(0.625, 0.765),
      a.p(0.66, 0.775),
      a.p(0.7, foot + 0.005),
    ]),
    Color.lerp(_pumice, _ash, 0.35)!,
    line: 0.35,
  );
  // A measuring pole, painted in bands, against the face.
  for (var i = 0; i < 9; i++) {
    a.fill(
      a.r(0.925, 0.36 + i * 0.049, 0.012, 0.049),
      i.isEven ? const Color(0xFFB0402E) : const Color(0xFFEDE4CE),
    );
  }
  a.ink(a.r(0.925, 0.36, 0.012, 0.44), width: 0.3);
  // A ladder against the cut.
  a
    ..line(a.p(0.6, 0.84), a.p(0.66, 0.34), const Color(0xFF6E5034), width: 0.8)
    ..line(
      a.p(0.63, 0.85),
      a.p(0.69, 0.35),
      const Color(0xFF6E5034),
      width: 0.8,
    );
  for (var i = 1; i < 8; i++) {
    final t = i / 8;
    a.line(
      a.p(0.6 + 0.06 * t, 0.84 - 0.5 * t),
      a.p(0.63 + 0.06 * t, 0.85 - 0.5 * t),
      const Color(0xFF6E5034),
      width: 0.5,
    );
  }
}

void _garden79(Art a) {
  _sky79(a, horizon: 0.36);
  _vesuvius(a, 0.51, 0.3, 0.36, color: const Color(0xFF4E4046));
  _pineCloud(a, 0.52, 0.3, 0.02, 0.44);
  // The garden wall, painted with a garden of its own.
  a.box(a.r(0, 0.26, 1, 0.36), _green79);
  final random = math.Random(51);
  for (var i = 0; i < 30; i++) {
    a.canvas.drawCircle(
      a.p(random.nextDouble(), 0.3 + random.nextDouble() * 0.28),
      a.u * (0.8 + random.nextDouble()),
      Paint()..color = _leaf,
    );
  }
  for (var i = 0; i < 4; i++) {
    a.circle(
      a.p(0.1 + i * 0.26, 0.36),
      a.u * 0.8,
      const Color(0xFFE8E0D0),
      line: 0.2,
    );
  }
  // Columns, red below and white above, and the vine on its pergola.
  for (var i = 0; i < 5; i++) {
    final x = 0.05 + i * 0.1;
    _column(a, a.r(x, 0.5, 0.03, 0.12), _red79, top: false);
    _column(a, a.r(x, 0.3, 0.03, 0.2), const Color(0xFFEDE6D8), top: false);
  }
  a.box(a.r(0, 0.28, 0.6, 0.02), const Color(0xFF6E5034), line: 0.4);
  // Green ground, and a path running back to the colonnade.
  a
    ..fill(a.r(0, 0.62, 1, 0.38), const Color(0xFF5E7440))
    ..fade(
      a.r(0, 0.62, 1, 0.08),
      const Color(0x44000000),
      const Color(0x00000000),
    )
    ..path(
      a.poly([a.p(0.17, 1), a.p(0.31, 1), a.p(0.28, 0.62), a.p(0.22, 0.62)]),
      const Color(0xFFB9A57E),
      line: 0,
    );
  // The fig tree, late fruit on it, its shadow at its foot.
  a.canvas.drawOval(
    a.r(0.39, 0.745, 0.12, 0.03),
    Paint()
      ..color = const Color(0x55000000)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, a.u * 1.2),
  );
  a
    ..path(
      a.poly([
        a.p(0.43, 0.76),
        a.p(0.42, 0.5),
        a.p(0.45, 0.5),
        a.p(0.46, 0.76),
      ]),
      const Color(0xFF5A4A3A),
    )
    ..oval(a.r(0.34, 0.3, 0.2, 0.26), _leaf);
  for (var i = 0; i < 9; i++) {
    a.circle(
      a.p(0.37 + (i % 3) * 0.06, 0.36 + (i ~/ 3) * 0.06),
      a.u * 0.7,
      const Color(0xFF5A3A5A),
      line: 0.2,
    );
  }
  _falling(a, count: 60, seed: 19);
}

// ---------------------------------------------------------------------------
// The tracing sheets

/// Where the sheets belong on the board, and where their crosses are.
const _target = Rect.fromLTWH(0.3, 0.1, 0.4, 0.8);
const _crossAt = [(0.06, 0.06), (0.94, 0.06), (0.06, 0.94), (0.94, 0.94)];

void _cross(Art a, Offset c, Color color) {
  final r = a.size.shortestSide * 0.025;
  a
    ..hairline(c.translate(-r, 0), c.translate(r, 0), color, 0.35)
    ..hairline(c.translate(0, -r), c.translate(0, r), color, 0.35)
    ..canvas.drawCircle(
      c,
      r * 0.55,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = a.u * 0.2
        ..color = color,
    );
}

void _tracingBoard(Art a) {
  a.wood(Offset.zero & a.size, base: const Color(0xFF7A5A3E), grain: 14);
  // The squared sheet pinned down, with its four crosses.
  a.box(a.r(0.26, 0.05, 0.48, 0.9), _paper, line: 0.4);
  for (var i = 1; i < 16; i++) {
    a.hairline(
      a.p(0.26 + i * 0.03, 0.05),
      a.p(0.26 + i * 0.03, 0.95),
      const Color(0x2226384A),
      0.2,
    );
  }
  for (var i = 1; i < 30; i++) {
    a.hairline(
      a.p(0.26, 0.05 + i * 0.03),
      a.p(0.74, 0.05 + i * 0.03),
      const Color(0x2226384A),
      0.2,
    );
  }
  for (final (x, y) in _crossAt) {
    _cross(
      a,
      a.p(_target.left + _target.width * x, _target.top + _target.height * y),
      const Color(0xFF8E2B1E),
    );
  }
  for (final (x, y) in [
    (0.27, 0.06),
    (0.73, 0.06),
    (0.27, 0.94),
    (0.73, 0.94),
  ]) {
    a.circle(a.p(x, y), a.u * 0.8, StillroomPalette.brass, line: 0.3);
  }
  // A pencil and dividers at the side.
  a
    ..line(a.p(0.08, 0.7), a.p(0.2, 0.62), const Color(0xFFC9A24A), width: 1.2)
    ..line(a.p(0.82, 0.3), a.p(0.9, 0.62), const Color(0xFF9AA2A6), width: 0.6)
    ..line(
      a.p(0.82, 0.3),
      a.p(0.94, 0.58),
      const Color(0xFF9AA2A6),
      width: 0.6,
    );
}

/// One sheet of tracing paper: see-through, crosses at its corners, and
/// [content] drawn in charcoal.
void _sheet(Art a, void Function(Art a) content) {
  a
    ..fill(Offset.zero & a.size, const Color(0x40F4ECD8))
    ..ink(Offset.zero & a.size, width: 0.25);
  for (final (x, y) in _crossAt) {
    _cross(a, a.p(x, y), _charcoal);
  }
  content(a);
}

void _boat(Art a) {
  for (var row = 0; row < 3; row++) {
    final path = Path()
      ..moveTo(a.p(0.12, 0.78 + row * 0.04).dx, a.p(0, 0.78 + row * 0.04).dy);
    for (var i = 0; i < 8; i++) {
      final x0 = 0.12 + i * 0.1;
      path.quadraticBezierTo(
        a.p(x0 + 0.05, 0).dx,
        a.p(0, 0.76 + row * 0.04).dy,
        a.p(x0 + 0.1, 0).dx,
        a.p(0, 0.78 + row * 0.04).dy,
      );
    }
    a.strokePath(path, _charcoal, width: 0.45);
  }
  final hull = Path()
    ..moveTo(a.p(0.55, 0.66).dx, a.p(0, 0.66).dy)
    ..lineTo(a.p(0.9, 0.66).dx, a.p(0, 0.66).dy)
    ..lineTo(a.p(0.84, 0.74).dx, a.p(0, 0.74).dy)
    ..lineTo(a.p(0.6, 0.74).dx, a.p(0, 0.74).dy)
    ..close();
  a
    ..strokePath(hull, _charcoal, width: 0.6)
    ..line(a.p(0.72, 0.66), a.p(0.72, 0.42), _charcoal, width: 0.5)
    ..strokePath(
      a.poly([a.p(0.73, 0.43), a.p(0.86, 0.6), a.p(0.73, 0.6)]),
      _charcoal,
      width: 0.5,
    );
}

void _people(Art a) {
  for (final (x, h) in [(0.2, 0.28), (0.32, 0.26), (0.43, 0.17)]) {
    const foot = 0.74;
    final head = foot - h;
    a
      ..canvas.drawCircle(
        a.p(x, head + 0.03),
        a.size.width * 0.03,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = a.u * 0.5
          ..color = _charcoal,
      )
      // The cushion tied on the head.
      ..strokePath(
        Path()..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: a.p(x, head - 0.005),
              width: a.size.width * 0.09,
              height: a.size.height * 0.025,
            ),
            Radius.circular(a.size.width * 0.02),
          ),
        ),
        _charcoal,
        width: 0.45,
      )
      ..line(
        a.p(x, head + 0.06),
        a.p(x, foot - h * 0.35),
        _charcoal,
        width: 0.5,
      )
      ..line(
        a.p(x, foot - h * 0.35),
        a.p(x - 0.03, foot),
        _charcoal,
        width: 0.5,
      )
      ..line(
        a.p(x, foot - h * 0.35),
        a.p(x + 0.03, foot),
        _charcoal,
        width: 0.5,
      )
      ..line(
        a.p(x - 0.035, head + 0.12),
        a.p(x + 0.04, head + 0.1),
        _charcoal,
        width: 0.5,
      );
  }
}

void _words(Art a) {
  a
    ..script(
      'AD MARE',
      a.p(0.5, 0.22),
      a.size.height * 0.1,
      _charcoal,
      angle: -0.04,
    )
    ..line(a.p(0.3, 0.34), a.p(0.66, 0.52), _charcoal, width: 0.5)
    ..line(a.p(0.66, 0.52), a.p(0.6, 0.52), _charcoal, width: 0.5)
    ..line(a.p(0.66, 0.52), a.p(0.63, 0.46), _charcoal, width: 0.5);
  // A child's sun in the corner.
  a.canvas.drawCircle(
    a.p(0.8, 0.14),
    a.size.width * 0.04,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = a.u * 0.45
      ..color = _charcoal,
  );
}

void _gate(Art a) {
  // A gate in the city wall, the sea beyond it, and dots walking through.
  final arch = Path()
    ..moveTo(a.p(0.14, 0.7).dx, a.p(0, 0.7).dy)
    ..lineTo(a.p(0.14, 0.44).dx, a.p(0, 0.44).dy)
    ..quadraticBezierTo(
      a.p(0.24, 0.3).dx,
      a.p(0, 0.3).dy,
      a.p(0.34, 0.44).dx,
      a.p(0, 0.44).dy,
    )
    ..lineTo(a.p(0.34, 0.7).dx, a.p(0, 0.7).dy);
  a
    ..strokePath(arch, _charcoal, width: 0.6)
    ..line(a.p(0.06, 0.4), a.p(0.42, 0.4), _charcoal, width: 0.5);
  for (var i = 0; i < 6; i++) {
    a.canvas.drawCircle(
      a.p(0.46 + i * 0.03, 0.71 - i * 0.005),
      a.u * 0.4,
      Paint()..color = _charcoal,
    );
  }
}

/// The four tracings laid together, small, on the drafting table.
void _drawingDone(Art a) {
  a
    ..box(Offset.zero & a.size, const Color(0xFFEDE4CE), line: 0.4)
    ..glow(
      a.p(0.5, 0.5),
      a.size.width * 0.5,
      StillroomPalette.gaslight,
      strength: 0.15,
    );
  _boat(a);
  _people(a);
  _words(a);
  _gate(a);
}

// ---------------------------------------------------------------------------
// The jar's label: the diggers' cut, a tag on every layer

/// The cut through the garden, newest on top: the diggers' surface of
/// 1863, the ash of the second morning, the pumice of the first afternoon
/// and night, the garden soil of the last ordinary day. The label's tags sit
/// on these bands (`puzzles/jar_label.json`); the words take the right side.
void _labelSection(Art a) {
  a.fill(Offset.zero & a.size, _dusk79);
  final cut = a.r(0.02, 0.03, 0.58, 0.94);
  final random = math.Random(63);
  // The surface of 1863: weeds and trodden earth.
  a
    ..fill(
      Rect.fromLTRB(cut.left, cut.top, cut.right, a.p(0, 0.195).dy),
      const Color(0xFF6F6A60),
    )
    // The ash of the surge, set hard.
    ..fill(
      Rect.fromLTRB(cut.left, a.p(0, 0.195).dy, cut.right, a.p(0, 0.36).dy),
      const Color(0xFF7C7771),
    )
    // The pumice.
    ..fill(
      Rect.fromLTRB(cut.left, a.p(0, 0.36).dy, cut.right, a.p(0, 0.725).dy),
      _pumice,
    )
    // The garden soil of 79.
    ..fill(
      Rect.fromLTRB(cut.left, a.p(0, 0.725).dy, cut.right, cut.bottom),
      _soil,
    );
  for (var i = 0; i < 160; i++) {
    a.canvas.drawCircle(
      Offset(
        cut.left + random.nextDouble() * cut.width,
        a.p(0, 0.37 + random.nextDouble() * 0.345).dy,
      ),
      a.u * (0.3 + random.nextDouble() * 0.6),
      Paint()..color = const Color(0xFFA89E8A),
    );
  }
  for (var i = 1; i < 5; i++) {
    a.hairline(
      Offset(cut.left, a.p(0, 0.195 + i * 0.03).dy),
      Offset(cut.right, a.p(0, 0.2 + i * 0.03).dy),
      const Color(0x44403A34),
      0.25,
    );
  }
  _weeds(
    a,
    Rect.fromLTWH(cut.left, cut.top, cut.width, a.size.height * 0.04),
    seed: 13,
  );
  a.ink(cut, width: 0.8);
  // The column for the words: dark wood.
  a.wood(a.r(0.63, 0, 0.37, 1), base: const Color(0xFF3A2C22), grain: 10);
}

// ---------------------------------------------------------------------------
// The jar

void _jar(Art a) {
  final w = a.size.width;
  final h = a.size.height;
  final body = RRect.fromLTRBAndCorners(
    w * 0.08,
    h * 0.16,
    w * 0.92,
    h * 0.98,
    topLeft: Radius.circular(w * 0.22),
    topRight: Radius.circular(w * 0.22),
    bottomLeft: Radius.circular(w * 0.12),
    bottomRight: Radius.circular(w * 0.12),
  );
  a.canvas
    ..save()
    ..clipRRect(body);
  // Inside: the mountain, its pine-shaped cloud, red roofs below.
  a.fade(a.r(0, 0.16, 1, 0.84), _sky79Top, _sky79Low);
  _vesuvius(a, 0.5, 0.56, 0.8, color: const Color(0xFF4E4046));
  _pineCloud(a, 0.5, 0.56, 0.22, 0.7);
  a.fill(a.r(0, 0.8, 1, 0.2), _yellow79);
  for (var i = 0; i < 5; i++) {
    a.box(a.r(i * 0.22, 0.78, 0.18, 0.05), _tile, line: 0.4);
  }
  _falling(a, count: 25, seed: 4, inside: a.r(0, 0.3, 1, 0.5));
  a.canvas.restore();
  a.canvas
    ..drawRRect(
      body,
      Paint()..color = StillroomPalette.fog.withValues(alpha: 0.12),
    )
    ..drawRRect(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = StillroomPalette.paperShade.withValues(alpha: 0.7),
    );
  a.box(a.r(0.3, 0.04, 0.4, 0.14), const Color(0xFF7A5A3A), line: 0.5);
}
