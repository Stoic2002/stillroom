import 'dart:math' as math;
import 'dart:ui';

import '../theme/stillroom_palette.dart';
import 'art_kit.dart';
import 'echo_art.dart';
import 'whitechapel_1888_art.dart' show jarLabelBoard;

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
  '$_s/atrium_79.png': (c, s) => _atrium79(Art(c, s)),
  '$_s/garden.png': (c, s) => _garden(Art(c, s)),
  '$_s/garden_79.png': (c, s) => _garden79(Art(c, s)),
  // Puzzle boards.
  '$_s/tracing_board.png': (c, s) => _tracingBoard(Art(c, s)),
  '$_s/label_close.png': (c, s) => jarLabelBoard(Art(c, s), _dusk79),
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
    (EchoFigure.cushioned, 0.0, 0.0, 0.36, 1.0),
    (EchoFigure.cushioned, 0.34, 0.04, 0.34, 0.96),
    (EchoFigure.child, 0.66, 0.34, 0.3, 0.66),
  ]),
  // Items.
  '$_i/era_lens.png': (c, s) => _lens(Art(c, s)),
  '$_i/shovel.png': (c, s) => _shovelIcon(Art(c, s)),
  '$_i/tracings.png': (c, s) => _tube(Art(c, s)),
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

/// Vesuvius, its peak at ([x], [y]), filling down to [base].
void _vesuvius(Art a, double x, double y, double base, {Color? color}) {
  a.path(
    a.poly([
      a.p(x - 0.24, base),
      a.p(x - 0.12, base - (base - y) * 0.55),
      a.p(x - 0.04, y + 0.01),
      a.p(x + 0.03, y),
      a.p(x + 0.12, base - (base - y) * 0.5),
      a.p(x + 0.26, base),
    ]),
    color ?? _mountain,
    line: 0.4,
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
void _paving(Art a, double top, {Color color = _basalt}) {
  a.fill(a.r(0, top, 1, 1 - top), color);
  final dark = Color.lerp(color, Art.outline, 0.45)!;
  final random = math.Random(11);
  var y = top;
  var row = 0;
  while (y < 1) {
    final h = 0.03 + row * 0.012;
    a.hairline(a.p(0, y), a.p(1, y), dark, 0.25);
    var x = random.nextDouble() * 0.08;
    while (x < 1) {
      a.hairline(a.p(x, y), a.p(x, y + h), dark, 0.25);
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

void _street(Art a) {
  _sky1863(a, horizon: 0.52);
  _vesuvius(a, 0.18, 0.17, 0.46);
  _smoke(a, 0.19, 0.16);
  // Spoil heaps where the diggers have not cleared yet.
  a.fill(a.r(0, 0.5, 1, 0.3), _ash);
  // Ruins far down the street.
  _ruinWall(a, a.r(0.36, 0.34, 0.34, 0.2), color: _plasterDark, seed: 4);
  _farStreet(a, horizon: 0.54, ruin: true);
  _paving(a, 0.8);
  // Left: the baker's shopfront, roofless, to the shoulder.
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
  // Ruts and stepping stones.
  for (final x in [0.44, 0.6]) {
    a.line(a.p(x, 0.86), a.p(x + 0.04, 1), Art.outline, width: 0.8);
  }
  for (final x in [0.47, 0.53, 0.59]) {
    a.oval(a.r(x - 0.022, 0.78, 0.044, 0.035), const Color(0xFF6E6862));
  }
  // The diggers' hut on the right.
  a
    ..wood(a.r(0.66, 0.3, 0.28, 0.46), base: _plank, vertical: true, grain: 8)
    ..path(
      a.poly([a.p(0.64, 0.31), a.p(0.8, 0.22), a.p(0.96, 0.31)]),
      const Color(0xFF5A4636),
    )
    ..box(a.r(0.72, 0.42, 0.1, 0.32), const Color(0xFF221A14))
    ..box(a.r(0.84, 0.4, 0.07, 0.08), const Color(0xFFBFD0DA), line: 0.4);
  // Baskets and a barrow by the hut.
  a
    ..oval(a.r(0.86, 0.7, 0.06, 0.06), const Color(0xFF8C6B45))
    ..oval(a.r(0.9, 0.72, 0.06, 0.06), const Color(0xFF7A5C3A));
  // The diggers' board on its post.
  a
    ..line(a.p(0.57, 0.54), a.p(0.57, 0.8), const Color(0xFF4A3828), width: 0.9)
    ..box(a.r(0.52, 0.44, 0.1, 0.1), const Color(0xFFD9C9A2), line: 0.5)
    ..label('SCAVI', a.p(0.57, 0.475), a.size.height * 0.022, _charcoal)
    ..label('1748', a.p(0.57, 0.51), a.size.height * 0.02, _charcoal);
  _weeds(a, a.r(0, 0.76, 0.14, 0.04));
}

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
  a.path(a.poly(top), _ash, line: 0.5);
  for (var i = 0; i < 40; i++) {
    a.canvas.drawCircle(
      a.p(random.nextDouble(), 0.35 + random.nextDouble() * 0.6),
      a.u * (0.3 + random.nextDouble() * 0.8),
      Paint()..color = (i.isEven ? _ashDark : _pumice).withValues(alpha: 0.6),
    );
  }
  for (var i = 1; i < 4; i++) {
    a.hairline(
      a.p(0.05, 0.4 + i * 0.14),
      a.p(0.95, 0.42 + i * 0.14),
      _ashDark,
      0.3,
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
  _paving(a, 0.8);
  // The shopfront, whole: yellow above, red below, a tiled roof.
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
  for (final x in [0.47, 0.53, 0.59]) {
    a.oval(a.r(x - 0.022, 0.78, 0.044, 0.035), const Color(0xFF6E6862));
  }
  // Where the hut will stand: a neighbour's snack bar with jars in its counter.
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

void _hut(Art a) {
  a
    ..wood(a.r(0, 0, 1, 0.82), base: _plank, vertical: true, grain: 24)
    ..fill(a.r(0, 0, 1, 0.82), const Color(0x22000000));
  // A window of daylight.
  a
    ..box(a.r(0.42, 0.08, 0.16, 0.2), const Color(0xFFC9D6DC), line: 0.6)
    ..line(a.p(0.5, 0.08), a.p(0.5, 0.28), _plank, width: 0.6)
    ..glow(
      a.p(0.5, 0.2),
      a.size.width * 0.25,
      const Color(0xFFF2E8D0),
      strength: 0.25,
    );
  // The door on the right, open on the bright street.
  a
    ..box(a.r(0.86, 0.22, 0.13, 0.62), const Color(0xFFD9CDB2), line: 0.6)
    ..glow(
      a.p(0.92, 0.5),
      a.size.width * 0.2,
      const Color(0xFFF6EEDA),
      strength: 0.35,
    );
  // Floorboards.
  a.floorboards(a.r(0, 0.82, 1, 0.18));
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
  // Shelf with books.
  a.box(a.r(0.7, 0.32, 0.26, 0.02), const Color(0xFF5A4030), line: 0.4);
  for (final (x, w, h, c) in [
    (0.73, 0.02, 0.1, const Color(0xFF4A3A2E)),
    (0.752, 0.025, 0.11, const Color(0xFF6B4A2E)),
    (0.78, 0.02, 0.09, const Color(0xFF3E4A3A)),
    (0.84, 0.03, 0.1, const Color(0xFF8E2E24)),
    (0.875, 0.02, 0.08, const Color(0xFF6E5A3C)),
  ]) {
    a.box(a.r(x, 0.32 - h, w, h), c, line: 0.3);
  }
  // The drafting table with its pinned sheet.
  a
    ..path(
      a.poly([
        a.p(0.34, 0.52),
        a.p(0.68, 0.5),
        a.p(0.7, 0.66),
        a.p(0.33, 0.68),
      ]),
      const Color(0xFF8A6A48),
    )
    ..line(a.p(0.36, 0.68), a.p(0.36, 0.84), const Color(0xFF4A3828), width: 1)
    ..line(a.p(0.67, 0.66), a.p(0.67, 0.84), const Color(0xFF4A3828), width: 1)
    ..box(a.r(0.42, 0.51, 0.18, 0.13), _paper, line: 0.4);
  for (var i = 1; i < 6; i++) {
    a
      ..hairline(
        a.p(0.42 + i * 0.03, 0.51),
        a.p(0.42 + i * 0.03, 0.64),
        const Color(0x3326384A),
        0.2,
      )
      ..hairline(
        a.p(0.42, 0.51 + i * 0.022),
        a.p(0.6, 0.51 + i * 0.022),
        const Color(0x3326384A),
        0.2,
      );
  }
  // The day-book on a small table.
  a
    ..box(a.r(0.73, 0.58, 0.16, 0.025), const Color(0xFF5A4030), line: 0.4)
    ..line(a.p(0.75, 0.6), a.p(0.75, 0.84), const Color(0xFF4A3828), width: 0.8)
    ..line(a.p(0.87, 0.6), a.p(0.87, 0.84), const Color(0xFF4A3828), width: 0.8)
    ..paper(a.r(0.75, 0.52, 0.055, 0.06), lines: 4, angle: -0.05)
    ..paper(a.r(0.805, 0.52, 0.055, 0.06), lines: 4, angle: 0.05);
  // A crate of finds in straw.
  a
    ..wood(a.r(0.3, 0.78, 0.16, 0.14), base: const Color(0xFF8A6A40))
    ..fill(a.r(0.31, 0.77, 0.14, 0.02), const Color(0xFFC9B46A));
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

/// The shovel leaning upright by the door.
void _shovel(Art a) {
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
  // The base.
  a
    ..box(Rect.fromLTWH(l + w * 0.05, t + h * 0.82, w * 0.9, h * 0.18), color)
    ..path(
      a.poly([
        Offset(l + w * 0.15, t),
        Offset(l + w * 0.85, t),
        Offset(l + w * 0.6, t + h * 0.42),
        Offset(l + w * 0.85, t + h * 0.84),
        Offset(l + w * 0.15, t + h * 0.84),
        Offset(l + w * 0.4, t + h * 0.42),
      ]),
      color,
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

/// The oven: a brick block with an arched mouth; [mouth] is the door area.
void _oven(Art a, {required Color brick, required bool glow}) {
  a
    ..box(a.r(0.52, 0.3, 0.3, 0.5), brick)
    ..path(
      a.poly([a.p(0.52, 0.3), a.p(0.67, 0.2), a.p(0.82, 0.3)]),
      Color.lerp(brick, Art.outline, 0.2)!,
    )
    ..box(a.r(0.7, 0.08, 0.05, 0.14), Color.lerp(brick, Art.outline, 0.3)!);
  for (var i = 1; i < 10; i++) {
    a.hairline(
      a.p(0.52, 0.3 + i * 0.05),
      a.p(0.82, 0.3 + i * 0.05),
      Color.lerp(brick, Art.outline, 0.4)!,
      0.25,
    );
  }
  // The mouth, shut with an iron door.
  a
    ..box(a.r(0.6, 0.48, 0.14, 0.17), const Color(0xFF3A342F), line: 0.6)
    ..box(a.r(0.615, 0.5, 0.11, 0.14), const Color(0xFF2B2A28), line: 0.4)
    ..circle(a.p(0.71, 0.57), a.u * 0.8, const Color(0xFF6E6A66), line: 0.3);
  if (glow) {
    a
      ..hairline(a.p(0.615, 0.5), a.p(0.725, 0.5), const Color(0xFFF2A447), 0.6)
      ..hairline(
        a.p(0.615, 0.64),
        a.p(0.725, 0.64),
        const Color(0xFFF2A447),
        0.6,
      )
      ..glow(
        a.p(0.67, 0.57),
        a.size.width * 0.12,
        const Color(0xFFF2A447),
        strength: 0.25,
      );
  }
}

void _bakery(Art a) {
  _sky1863(a, horizon: 0.3);
  _ruinWall(a, a.r(0, 0.14, 1, 0.68), seed: 6, jag: 0.07);
  _flaking(a, a.r(0, 0.2, 1, 0.5), seed: 13, count: 30);
  a.fill(a.r(0, 0.66, 1, 0.14), _fadedRed.withValues(alpha: 0.7));
  _paving(a, 0.8, color: const Color(0xFF6C665F));
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
  a
    ..box(a.r(0.36, 0.3, 0.1, 0.5), const Color(0xFF2F2A25))
    ..glow(a.p(0.41, 0.5), a.size.width * 0.05, _skyLow, strength: 0.15);
  _oven(a, brick: const Color(0xFF8C6450), glow: false);
  // The store corner: jars sunk in the floor, a shelf of charred fruit.
  a.box(a.r(0.85, 0.5, 0.14, 0.02), const Color(0xFF5A4636), line: 0.4);
  for (var i = 0; i < 4; i++) {
    a.circle(
      a.p(0.87 + i * 0.03, 0.485),
      a.u * 1.4,
      const Color(0xFF1E1A16),
      line: 0.3,
    );
  }
  for (var i = 0; i < 2; i++) {
    a.oval(a.r(0.855 + i * 0.07, 0.66, 0.065, 0.26), const Color(0xFFA0643E));
    a.oval(a.r(0.87 + i * 0.07, 0.65, 0.035, 0.03), _ashDark, line: 0.3);
  }
  // Sunk in the floor to their shoulders.
  a
    ..fill(a.r(0.84, 0.8, 0.16, 0.2), const Color(0xFF6C665F))
    ..hairline(a.p(0.84, 0.8), a.p(1, 0.8), const Color(0xFF3E3A36), 0.3);
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
  _panels(
    a,
    a.r(0, 0.16, 1, 0.64),
    field: const Color(0xFFD7B06A),
    frame: _red79,
    dado: _red79,
    count: 5,
  );
  _paving(a, 0.8, color: const Color(0xFF5E5852));
  _mill(a, a.r(0.06, 0.36, 0.12, 0.46), color: const Color(0xFF4A4540));
  _mill(a, a.r(0.2, 0.42, 0.1, 0.4), color: const Color(0xFF4A4540));
  _donkey(a, a.r(0.0, 0.55, 0.16, 0.28));
  a.box(a.r(0.36, 0.3, 0.1, 0.5), const Color(0xFF3A2C22));
  _oven(a, brick: const Color(0xFF9A6A52), glow: true);
  // The baker's peel, leaning where it was dropped.
  a
    ..line(a.p(0.5, 0.36), a.p(0.56, 0.8), const Color(0xFF8A6A48), width: 0.9)
    ..oval(a.r(0.535, 0.74, 0.05, 0.07), const Color(0xFF8A6A48), line: 0.4);
  // Jars in the corner and a table with a basket, fruit, and wine.
  for (var i = 0; i < 2; i++) {
    a.oval(a.r(0.87 + i * 0.06, 0.4, 0.06, 0.16), const Color(0xFFB0704A));
  }
  a
    ..box(a.r(0.83, 0.6, 0.16, 0.03), const Color(0xFF6E5038), line: 0.4)
    ..line(a.p(0.85, 0.63), a.p(0.85, 0.8), const Color(0xFF4A3828), width: 0.8)
    ..line(a.p(0.97, 0.63), a.p(0.97, 0.8), const Color(0xFF4A3828), width: 0.8)
    ..oval(a.r(0.84, 0.54, 0.09, 0.07), const Color(0xFF9A7A4A));
  for (var i = 0; i < 3; i++) {
    _loaf(a, a.p(0.86 + i * 0.023, 0.55), a.size.height * 0.016, fresh: true);
  }
  for (var i = 0; i < 3; i++) {
    a.circle(
      a.p(0.94 + (i % 2) * 0.018, 0.585 - (i ~/ 2) * 0.02),
      a.size.height * 0.012,
      _pomegranate,
      line: 0.3,
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

void _atrium(Art a) {
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
  a
    ..box(a.r(0.44, 0.28, 0.12, 0.38), const Color(0xFFA9B8A2))
    ..fill(a.r(0.44, 0.54, 0.12, 0.12), const Color(0xFF7E8A6A));
  // The shrine: a niche with two serpents and an altar, empty.
  a
    ..box(a.r(0.07, 0.28, 0.12, 0.2), const Color(0xFFB08E6E))
    ..path(
      a.poly([a.p(0.06, 0.28), a.p(0.13, 0.22), a.p(0.2, 0.28)]),
      const Color(0xFFB08E6E),
    )
    ..box(a.r(0.09, 0.3, 0.08, 0.1), const Color(0xFF6A5040), line: 0.4);
  _serpents(a, faded: true);
  a.box(a.r(0.09, 0.48, 0.08, 0.1), const Color(0xFF9E8A74));
  // Remnants of the child's drawing, low on the wall.
  for (final (x1, y1, x2, y2) in [
    (0.25, 0.5, 0.28, 0.48),
    (0.3, 0.52, 0.31, 0.47),
    (0.34, 0.5, 0.36, 0.5),
  ]) {
    a.line(
      a.p(x1, y1),
      a.p(x2, y2),
      _charcoal.withValues(alpha: 0.5),
      width: 0.35,
    );
  }
  // A grown-up's graffito, scratched in.
  a.scrawl(
    a.r(0.6, 0.31, 0.1, 0.12),
    const Color(0x99402A20),
    lines: 3,
    seed: 5,
    width: 0.25,
  );
  // The earthquake crack, patched.
  final crack = Path()..moveTo(a.p(0.75, 0.16).dx, a.p(0.75, 0.16).dy);
  for (var i = 1; i <= 8; i++) {
    crack.lineTo(
      a.p(0.75 + (i.isOdd ? 0.015 : -0.01), 0.16 + i * 0.055).dx,
      a.p(0, 0.16 + i * 0.055).dy,
    );
  }
  a
    ..fill(a.r(0.735, 0.3, 0.035, 0.12), const Color(0xFFE0D6C2))
    ..strokePath(crack, Art.outline, width: 0.45);
  // The floor.
  a
    ..fill(a.r(0, 0.66, 1, 0.34), const Color(0xFF8C7462))
    ..hairline(a.p(0, 0.66), a.p(1, 0.66), Art.outline, 0.5);
  for (var i = 0; i < 60; i++) {
    final random = math.Random(i);
    a.canvas.drawCircle(
      a.p(random.nextDouble(), 0.66 + random.nextDouble() * 0.34),
      a.u * 0.25,
      Paint()..color = const Color(0x66E8DCC8),
    );
  }
  // Stone steps up to a floor that is gone, and the niche beneath.
  for (var i = 0; i < 6; i++) {
    a.box(
      a.r(0.8 + i * 0.03, 0.72 - i * 0.06, 0.2 - i * 0.03, 0.06),
      const Color(0xFF9A9186),
      line: 0.4,
    );
  }
  a.box(a.r(0.82, 0.7, 0.1, 0.12), const Color(0xFF3A3530));
  // The floor and the basin full of pumice.
  a.box(a.r(0.36, 0.7, 0.28, 0.12), const Color(0xFF6E6A62), line: 0.6);
  final random = math.Random(31);
  for (var i = 0; i < 80; i++) {
    a.canvas.drawCircle(
      a.p(0.37 + random.nextDouble() * 0.26, 0.71 + random.nextDouble() * 0.1),
      a.u * (0.4 + random.nextDouble() * 0.6),
      Paint()..color = i.isEven ? _pumice : const Color(0xFFBDB29C),
    );
  }
}

void _serpents(Art a, {required bool faded}) {
  final color = faded ? const Color(0x663A5A2E) : const Color(0xFF3A5A2E);
  for (final side in [-1.0, 1.0]) {
    final path = Path()
      ..moveTo(a.p(0.13 + side * 0.05, 0.47).dx, a.p(0, 0.47).dy);
    for (var i = 1; i <= 6; i++) {
      path.lineTo(
        a
            .p(0.13 + side * (0.05 - i * 0.006) + (i.isOdd ? 0.008 : -0.008), 0)
            .dx,
        a.p(0, 0.47 - i * 0.012).dy,
      );
    }
    a.strokePath(path, color, width: 0.6);
  }
}

void _atrium79(Art a) {
  // The roof, with its opening over the basin: dark sky and falling stones.
  a
    ..fill(a.r(0, 0, 1, 0.2), const Color(0xFF241A14))
    ..fill(a.r(0.38, 0, 0.24, 0.18), _sky79Top);
  for (var i = 0; i < 8; i++) {
    a.hairline(
      a.p(i * 0.14, 0),
      a.p(i * 0.14, 0.2),
      const Color(0xFF3E2F24),
      1,
    );
  }
  a.ink(a.r(0.38, 0, 0.24, 0.18));
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
  // The shrine, bright, its little gods being wrapped.
  a
    ..box(a.r(0.07, 0.28, 0.12, 0.2), const Color(0xFFE6D2A6))
    ..path(
      a.poly([a.p(0.06, 0.28), a.p(0.13, 0.22), a.p(0.2, 0.28)]),
      _yellow79,
    )
    ..box(a.r(0.09, 0.3, 0.08, 0.1), const Color(0xFFD9C08A), line: 0.4);
  _serpents(a, faded: false);
  a
    ..box(a.r(0.09, 0.48, 0.08, 0.1), const Color(0xFFD8C8B0))
    ..box(a.r(0.1, 0.36, 0.012, 0.04), StillroomPalette.brass, line: 0.2)
    ..oval(a.r(0.13, 0.37, 0.04, 0.03), const Color(0xFFE8E0D0), line: 0.3);
  // The child's drawing, fresh, half hidden behind the family.
  a
    ..line(a.p(0.25, 0.52), a.p(0.37, 0.52), _charcoal, width: 0.4)
    ..line(a.p(0.33, 0.4), a.p(0.33, 0.5), _charcoal, width: 0.4);
  // The floor.
  a
    ..fill(a.r(0, 0.66, 1, 0.34), const Color(0xFF7E5A46))
    ..hairline(a.p(0, 0.66), a.p(1, 0.66), Art.outline, 0.5);
  // Stairs and the niche, with the clay horse in it.
  for (var i = 0; i < 6; i++) {
    a.box(
      a.r(0.8 + i * 0.03, 0.72 - i * 0.06, 0.2 - i * 0.03, 0.06),
      const Color(0xFF7A5A40),
      line: 0.4,
    );
  }
  a.box(a.r(0.82, 0.7, 0.1, 0.12), const Color(0xFF2A211A));
  final horse = a.r(0.835, 0.72, 0.07, 0.08);
  a.canvas
    ..save()
    ..translate(horse.left, horse.top);
  _horse(Art(a.canvas, horse.size));
  a.canvas.restore();
  // The basin, stones falling into the water.
  a.box(a.r(0.36, 0.7, 0.28, 0.12), const Color(0xFF3E5462), line: 0.6);
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

/// The draughtsman's tin tube, dropped by the wall.
void _tube(Art a) {
  a
    ..rbox(
      a.r(0.08, 0.3, 0.8, 0.4),
      a.size.height * 0.15,
      const Color(0xFF9AA2A6),
    )
    ..hairline(a.p(0.2, 0.32), a.p(0.2, 0.68), const Color(0xFF6E7478), 0.4)
    ..hairline(a.p(0.76, 0.32), a.p(0.76, 0.68), const Color(0xFF6E7478), 0.4)
    ..path(
      a.poly([
        a.p(0.86, 0.36),
        a.p(0.98, 0.3),
        a.p(0.98, 0.7),
        a.p(0.86, 0.64),
      ]),
      _paper,
      line: 0.3,
    );
}

/// The jar's blank label, propped at the shrine.
void _labelTag(Art a) => a
  ..box(a.r(0.05, 0.1, 0.9, 0.8), _paper, line: 0.5)
  ..hairline(a.p(0.2, 0.5), a.p(0.8, 0.5), const Color(0x552A2420), 0.3);

// ---------------------------------------------------------------------------
// The garden

void _garden(Art a) {
  _sky1863(a, horizon: 0.36);
  _vesuvius(a, 0.51, 0.06, 0.34);
  _smoke(a, 0.52, 0.05);
  // The back wall and the stumps of the colonnade.
  _ruinWall(a, a.r(0, 0.26, 1, 0.36), color: _plasterDark, seed: 23);
  for (var i = 0; i < 5; i++) {
    final x = 0.05 + i * 0.1;
    a.box(
      a.r(x, 0.48 - (i % 3) * 0.05, 0.03, 0.14 + (i % 3) * 0.05),
      const Color(0xFFD2C6B0),
    );
  }
  // The ground: ash, grown over with weeds.
  a.fill(a.r(0, 0.6, 1, 0.4), _ash);
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
  // The hollow where a tree stood.
  a.oval(a.r(0.38, 0.66, 0.12, 0.08), const Color(0xFF3E3A36));
  // The diggers' cut through the layers.
  final cut = a.r(0.64, 0.32, 0.32, 0.48);
  a
    ..fill(
      Rect.fromLTWH(cut.left, cut.top, cut.width, cut.height * 0.2),
      const Color(0xFF7C7771),
    )
    ..fill(
      Rect.fromLTWH(
        cut.left,
        cut.top + cut.height * 0.2,
        cut.width,
        cut.height * 0.6,
      ),
      _pumice,
    )
    ..fill(
      Rect.fromLTWH(
        cut.left,
        cut.top + cut.height * 0.8,
        cut.width,
        cut.height * 0.2,
      ),
      _soil,
    )
    ..ink(cut);
  final random = math.Random(41);
  for (var i = 0; i < 120; i++) {
    a.canvas.drawCircle(
      Offset(
        cut.left + random.nextDouble() * cut.width,
        cut.top + cut.height * (0.22 + random.nextDouble() * 0.56),
      ),
      a.u * (0.3 + random.nextDouble() * 0.5),
      Paint()..color = const Color(0xFFA89E8A),
    );
  }
  for (var i = 1; i < 4; i++) {
    a.hairline(
      Offset(cut.left, cut.top + cut.height * 0.05 * i),
      Offset(cut.right, cut.top + cut.height * 0.05 * i),
      const Color(0x55403A34),
      0.25,
    );
  }
  _weeds(
    a,
    Rect.fromLTWH(
      cut.left,
      cut.top - a.size.height * 0.03,
      cut.width,
      a.size.height * 0.03,
    ),
    seed: 9,
  );
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
    a
      ..box(a.r(x, 0.3, 0.03, 0.2), const Color(0xFFEDE6D8))
      ..box(a.r(x, 0.5, 0.03, 0.12), _red79);
  }
  a.box(a.r(0, 0.28, 0.6, 0.02), const Color(0xFF6E5034), line: 0.4);
  // Green ground and a path.
  a
    ..fill(a.r(0, 0.62, 1, 0.38), const Color(0xFF5E7440))
    ..fill(a.r(0.2, 0.62, 0.1, 0.38), const Color(0xFFB9A57E));
  // The fig tree, late fruit on it.
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

/// The three tracings laid together, small, on the drafting table.
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
