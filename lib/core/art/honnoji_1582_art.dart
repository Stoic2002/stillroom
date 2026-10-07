import 'dart:math' as math;
import 'dart:ui';

import '../theme/stillroom_palette.dart';
import 'art_kit.dart';
import 'depth_kit.dart';
import 'echo_art.dart';
import 'whitechapel_1888_art.dart' show jarLabelBoard;

/// Code-drawn art for "Honnō-ji, 1582" (docs/episodes/honnoji_1582.md):
/// Kyoto in the summer of 2007. The dig in the block where the old temple
/// stood, behind a site fence; the site office and the finds room; and,
/// across the city, today's Honnō-ji at Teramachi. Drawn in depth
/// (`depth_kit.dart`). No one of 1582 is drawn; the fire is a black layer
/// in the earth.
const _s = 'images/scenes/honnoji_1582';
const _o = 'images/objects/honnoji_1582';

final Map<String, ArtPainter> honnoji1582Art = {
  // Scenes and puzzle boards.
  '$_s/dig.png': (c, s) => _dig(Art(c, s)),
  '$_s/office.png': (c, s) => _office(Art(c, s)),
  '$_s/finds.png': (c, s) => _finds(Art(c, s)),
  '$_s/teramachi.png': (c, s) => _teramachi(Art(c, s)),
  '$_s/strata_board.png': (c, s) => _strataBoard(Art(c, s)),
  '$_s/streets_board.png': (c, s) => _streetsBoard(Art(c, s)),
  '$_s/label_close.png': (c, s) => jarLabelBoard(Art(c, s), _granite),
  // Objects.
  '$_o/tile_sprite.png': (c, s) => _roundTile(Art(c, s)),
  '$_o/frois_sprite.png': (c, s) => _letter(Art(c, s)),
  '$_o/later_sprite.png': (c, s) => _papers(Art(c, s)),
  '$_o/echo_excavator.png': (c, s) =>
      paintEcho(Art(c, s), EchoFigure.excavator),
  '$_o/echo_monk.png': (c, s) => paintEcho(Art(c, s), EchoFigure.sweeper),
  // The jar on the shelf.
  'images/ui/jar_honnoji_1582.png': (c, s) => _jar(Art(c, s)),
};

// ---------------------------------------------------------------------------
// Palette

const _skyHigh = Color(0xFFB8C4C4);
const _skyLow = Color(0xFFE8E2CE);
const _haze = Color(0xFFC8C8BC);
const _clay = Color(0xFF9A7E5A);
const _clayDark = Color(0xFF6E5638);
const _fence = Color(0xFFD4D4CC);
const _fenceBand = Color(0xFF3E6A5A);
const _tarp = Color(0xFF3A6A9A);
const _cabin = Color(0xFFCAC6B6);
const _granite = Color(0xFF8E9094);
const _ash = Color(0xFF221D1A);
const _tile = Color(0xFF4A4A4E);
const _tileBurnt = Color(0xFF5A3A2E);
const _cedar = Color(0xFF5A3A26);
const _gravel = Color(0xFFBEB6A4);
const _paper = Color(0xFFE6E0D0);
const _lamp = StillroomPalette.gaslight;

// ---------------------------------------------------------------------------
// Shared pieces

/// A summer sky over Kyoto: haze low down, thin cloud.
void _summerSky(Art a, double bottom) {
  a.fade(a.r(0, 0, 1, bottom), _skyHigh, _skyLow);
  final random = math.Random(1582);
  for (var i = 0; i < 6; i++) {
    final c = a.p(random.nextDouble(), 0.04 + random.nextDouble() * 0.12);
    a.canvas.drawOval(
      Rect.fromCenter(center: c, width: a.u * 26, height: a.u * 3),
      Paint()
        ..color = const Color(0x33FFFFFF)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, a.u * 1.5),
    );
  }
}

/// The city beyond: low flat blocks in the haze, a few taller, power
/// poles and their wires.
void _city(Art a, double base, {int seed = 7}) {
  final random = math.Random(seed);
  var x = 0.0;
  while (x < 1) {
    final w = 0.04 + random.nextDouble() * 0.08;
    final h =
        0.04 + random.nextDouble() * (random.nextInt(5) == 0 ? 0.16 : 0.07);
    final shade = Color.lerp(
      _haze,
      const Color(0xFF7A7E80),
      random.nextDouble() * 0.5,
    )!;
    a.fill(a.r(x, base - h, w + 0.002, h), shade);
    // Rows of windows, faint.
    for (var k = 1; k < h / 0.025; k++) {
      a.hairline(
        a.p(x + 0.006, base - h + k * 0.025),
        a.p(x + w - 0.006, base - h + k * 0.025),
        const Color(0x22000000),
        0.3,
      );
    }
    x += w;
  }
  for (final px in [0.08, 0.36, 0.64, 0.92]) {
    a.line(
      a.p(px, base + 0.02),
      a.p(px, base - 0.2),
      const Color(0xFF5A5A58),
      width: 0.5,
    );
    a.line(
      a.p(px - 0.015, base - 0.18),
      a.p(px + 0.015, base - 0.18),
      const Color(0xFF5A5A58),
      width: 0.4,
    );
  }
  for (var k = 0; k < 2; k++) {
    final wire = Path()
      ..moveTo(a.p(0, 0).dx, a.p(0, base - 0.17 + k * 0.01).dy);
    for (final (from, to) in [(0.08, 0.36), (0.36, 0.64), (0.64, 0.92)]) {
      final y = base - 0.18 + k * 0.01;
      wire
        ..moveTo(a.p(from, y).dx, a.p(from, y).dy)
        ..quadraticBezierTo(
          a.p((from + to) / 2, 0).dx,
          a.p(0, y + 0.03).dy,
          a.p(to, y).dx,
          a.p(to, y).dy,
        );
    }
    a.strokePath(wire, const Color(0x885A5A58), width: 0.2);
  }
}

/// A temple roof: a heavy tiled hip-and-gable, its eaves curving up at the
/// ends; [r] spans the eaves.
void _roof(Art a, Rect r, {Color color = _tile}) {
  final w = r.width;
  final h = r.height;
  final roof = Path()
    ..moveTo(r.left, r.bottom - h * 0.12)
    ..quadraticBezierTo(r.left + w * 0.12, r.bottom, r.left + w * 0.3, r.bottom)
    ..lineTo(r.right - w * 0.3, r.bottom)
    ..quadraticBezierTo(
      r.right - w * 0.12,
      r.bottom,
      r.right,
      r.bottom - h * 0.12,
    )
    ..quadraticBezierTo(
      r.right - w * 0.2,
      r.bottom - h * 0.3,
      r.right - w * 0.28,
      r.top + h * 0.12,
    )
    ..lineTo(r.left + w * 0.28, r.top + h * 0.12)
    ..quadraticBezierTo(
      r.left + w * 0.2,
      r.bottom - h * 0.3,
      r.left,
      r.bottom - h * 0.12,
    )
    ..close();
  a.path(roof, color, line: 0.5);
  // The ridge, its end tiles.
  a
    ..box(
      Rect.fromLTRB(
        r.left + w * 0.26,
        r.top,
        r.right - w * 0.26,
        r.top + h * 0.14,
      ),
      Color.lerp(color, Art.outline, 0.3)!,
      line: 0.4,
    )
    ..path(
      a.poly([
        Offset(r.left + w * 0.26, r.top + h * 0.14),
        Offset(r.left + w * 0.23, r.top - h * 0.1),
        Offset(r.left + w * 0.3, r.top),
      ]),
      Color.lerp(color, Art.outline, 0.3)!,
      line: 0.3,
    )
    ..path(
      a.poly([
        Offset(r.right - w * 0.26, r.top + h * 0.14),
        Offset(r.right - w * 0.23, r.top - h * 0.1),
        Offset(r.right - w * 0.3, r.top),
      ]),
      Color.lerp(color, Art.outline, 0.3)!,
      line: 0.3,
    );
  // Tile rows running down the slope.
  final rows = (w / (a.u * 1.6)).floor();
  for (var k = 1; k < rows; k++) {
    final t = k / rows;
    final top = Offset(r.left + w * (0.28 + 0.44 * t), r.top + h * 0.14);
    final bottom = Offset(r.left + w * (0.06 + 0.88 * t), r.bottom - h * 0.03);
    a.hairline(top, bottom, Color.lerp(color, Art.outline, 0.45)!, 0.25);
  }
}

/// A round eave tile seen face on: a disc with a raised rim, the old
/// form of a character in relief, blistered by fire.
void _tileFace(Art a, Offset c, double r, {bool burnt = true}) {
  final base = burnt ? _tileBurnt : _tile;
  a
    ..circle(c, r, base, line: 0.5)
    ..circle(
      c,
      r * 0.78,
      Color.lerp(base, const Color(0xFFFFFFFF), 0.08)!,
      line: 0.3,
    );
  // The character, a few raised strokes.
  final s = r * 0.42;
  final ink = Color.lerp(base, const Color(0xFF0A0806), 0.45)!;
  a
    ..line(
      c.translate(-s, -s * 0.6),
      c.translate(-s * 0.1, -s * 0.6),
      ink,
      width: 0.6,
    )
    ..line(
      c.translate(-s * 0.55, -s * 0.9),
      c.translate(-s * 0.55, s * 0.9),
      ink,
      width: 0.6,
    )
    ..line(
      c.translate(-s, s * 0.1),
      c.translate(-s * 0.1, s * 0.1),
      ink,
      width: 0.5,
    )
    ..line(
      c.translate(s * 0.2, -s * 0.8),
      c.translate(s * 0.9, -s * 0.4),
      ink,
      width: 0.5,
    )
    ..line(
      c.translate(s * 0.2, 0),
      c.translate(s * 0.9, s * 0.3),
      ink,
      width: 0.5,
    )
    ..line(
      c.translate(s * 0.3, -s * 0.9),
      c.translate(s * 0.3, s * 0.9),
      ink,
      width: 0.5,
    );
  if (burnt) {
    final random = math.Random(c.dx.round());
    for (var i = 0; i < 9; i++) {
      final angle = random.nextDouble() * math.pi * 2;
      final d = random.nextDouble() * r * 0.9;
      a.canvas.drawCircle(
        c + Offset(math.cos(angle) * d, math.sin(angle) * d),
        r * (0.04 + random.nextDouble() * 0.08),
        Paint()..color = const Color(0x99140E0A),
      );
    }
  }
}

/// A flat quad lying at height [y], [x0]–[x1] by [z0]–[z1]: paper on a
/// table, a tarp on the ground.
Path _flat(Room room, double x0, double x1, double z0, double z1, double y) =>
    room.a.poly([
      room.at(x0, y, z0),
      room.at(x1, y, z0),
      room.at(x1, y, z1),
      room.at(x0, y, z1),
    ]);

/// A sheet of paper lying flat, ruled with writing.
void _flatPaper(
  Room room,
  double x0,
  double x1,
  double z0,
  double z1,
  double y, {
  Color color = _paper,
  int lines = 5,
}) {
  final a = room.a;
  a.path(_flat(room, x0, x1, z0, z1, y), color, line: 0.3);
  final ink = StillroomPalette.inkOnPaper.withValues(alpha: 0.45);
  for (var k = 0; k < lines; k++) {
    final z = z0 + (z1 - z0) * (0.2 + 0.65 * k / math.max(1, lines - 1));
    a.hairline(
      room.at(x0 + (x1 - x0) * 0.12, y, z),
      room.at(x1 - (x1 - x0) * (k.isOdd ? 0.3 : 0.14), y, z),
      ink,
      0.3,
    );
  }
}

/// A stone site marker: a square granite post standing in the ground, the
/// face with cut strokes.
Rect _markerPost(Room room, double x0, double x1, double z0, double z1) {
  final a = room.a;
  room.shadow(x0, x1, z0, z1, strength: 0.5, spread: 0.3);
  final r = room.block(x0, x1, 0, 0.32, z0, z1, _granite);
  a.fade(r, const Color(0x22FFFFFF), const Color(0x22000000));
  // Cut characters running down the face: a few strokes each.
  final random = math.Random(41);
  final x = r.center.dx;
  for (var k = 0; k < 5; k++) {
    final y = r.top + r.height * (0.08 + k * 0.17);
    final s = r.width * 0.26;
    for (var j = 0; j < 3; j++) {
      final dx = (random.nextDouble() - 0.5) * s;
      final dy = random.nextDouble() * s;
      a.line(
        Offset(x + dx - s * 0.4, y + dy),
        Offset(
          x + dx + s * 0.4,
          y + dy + (random.nextDouble() - 0.5) * s * 0.6,
        ),
        const Color(0xCC2A2C30),
        width: 0.35,
      );
    }
    a.line(
      Offset(x, y),
      Offset(x, y + s),
      const Color(0xCC2A2C30),
      width: 0.35,
    );
  }
  return r;
}

/// A prefab site cabin standing on the ground: a door and a window in its
/// front, a roof edge. Returns its front.
Rect _prefab(
  Room room,
  double x0,
  double x1,
  double z0,
  double z1, {
  double height = 0.8,
}) {
  final a = room.a;
  room.shadow(x0, x1, z0, z1, strength: 0.4, spread: 0.06);
  final front = room.block(x0, x1, 0, height, z0, z1, _cabin);
  // The roof's edge, a little proud of the walls.
  room.block(
    x0 - 0.01,
    x1 + 0.01,
    height,
    height + 0.03,
    z0 - 0.01,
    z1,
    const Color(0xFF8A8A84),
    line: 0.3,
  );
  // Ribbed panels.
  for (var k = 1; k < 8; k++) {
    final x = front.left + front.width * k / 8;
    a.hairline(
      Offset(x, front.top),
      Offset(x, front.bottom),
      const Color(0x33000000),
      0.2,
    );
  }
  final d = Rect.fromLTWH(
    front.left + front.width * 0.12,
    front.top + front.height * 0.22,
    front.width * 0.24,
    front.height * 0.78,
  );
  a
    ..box(d, const Color(0xFF8C8A80), line: 0.4)
    ..fill(
      Rect.fromLTWH(
        d.left + a.u * 0.6,
        d.top + a.u * 0.6,
        d.width - a.u * 1.2,
        d.height * 0.32,
      ),
      const Color(0xFF5A6670),
    )
    ..circle(
      Offset(d.right - a.u, d.center.dy),
      a.u * 0.4,
      const Color(0xFF3A3A38),
      line: 0,
    );
  // A step before the door.
  final step = (x0 + (x1 - x0) * 0.1, x0 + (x1 - x0) * 0.4);
  room.block(step.$1, step.$2, 0, 0.03, z0 - 0.04, z0, const Color(0xFF9A9A92));
  final w = Rect.fromLTWH(
    front.left + front.width * 0.5,
    front.top + front.height * 0.24,
    front.width * 0.38,
    front.height * 0.3,
  );
  a
    ..box(w, const Color(0xFF6A7A84), line: 0.4)
    ..hairline(w.topCenter, w.bottomCenter, const Color(0xFF3A3A38), 0.4)
    ..fade(
      w.deflate(a.u * 0.3),
      const Color(0x44FFFFFF),
      const Color(0x00FFFFFF),
    );
  return front;
}

/// A plastic bucket on the ground, grey sludge in it: a round body
/// centred on [x], [z], of radius [r] and height [h].
void _bucket(Room room, double x, double z, double r, double h) {
  final a = room.a;
  room.shadow(x - r, x + r, z - r, z + r, strength: 0.5, spread: 0.2);
  Rect rim(double y) {
    final c = room.at(x, y, z);
    final w = (room.at(x + r, y, z).dx - room.at(x - r, y, z).dx).abs();
    final d = (room.at(x, y, z - r).dy - room.at(x, y, z + r).dy).abs();
    return Rect.fromCenter(center: c, width: w, height: d);
  }

  final top = rim(h);
  final foot = rim(0);
  final body = Path()
    ..moveTo(top.left, top.center.dy)
    ..lineTo(foot.left + foot.width * 0.06, foot.center.dy)
    ..arcTo(
      Rect.fromLTRB(
        foot.left + foot.width * 0.06,
        foot.top,
        foot.right - foot.width * 0.06,
        foot.bottom,
      ),
      3.1416,
      -3.1416,
      false,
    )
    ..lineTo(top.right, top.center.dy)
    ..close();
  a
    ..path(body, const Color(0xFF3A5A8A), line: 0.4)
    ..oval(top, const Color(0xFF2E4A72), line: 0.4)
    ..oval(top.deflate(top.height * 0.12), const Color(0xFF6A6A66), line: 0);
}

/// A memorial tower of stone on the ground: a base, a plinth, a body, a
/// stepped roof with upturned corners, a ringed finial. Centred on [x],
/// [z], [w] wide.
void _tower(Room room, double x, double z, double w) {
  final a = room.a;
  final h = w / 2;
  room
    ..shadow(x - h, x + h, z - h, z + h, strength: 0.5, spread: 0.15)
    ..block(x - h, x + h, 0, 0.08, z - h, z + h, _granite);
  room.block(
    x - h * 0.78,
    x + h * 0.78,
    0.08,
    0.24,
    z - h * 0.78,
    z + h * 0.78,
    const Color(0xFF9A9C9E),
  );
  final body = room.block(
    x - h * 0.6,
    x + h * 0.6,
    0.24,
    0.48,
    z - h * 0.6,
    z + h * 0.6,
    const Color(0xFF8A8C90),
  );
  a.ink(body.deflate(body.width * 0.18), width: 0.3);
  // The stepped roof with its horns, over the body.
  final roofBase = body.top;
  final rw = body.width * 1.7;
  final rh = body.height * 0.6;
  final cx = body.center.dx;
  room.block(
    x - h * 0.85,
    x + h * 0.85,
    0.48,
    0.53,
    z - h * 0.85,
    z + h * 0.85,
    const Color(0xFF7E8084),
  );
  a.path(
    a.poly([
      Offset(cx - rw * 0.5, roofBase - rh * 0.25),
      Offset(cx - rw * 0.56, roofBase - rh * 0.62),
      Offset(cx - rw * 0.4, roofBase - rh * 0.4),
      Offset(cx - rw * 0.2, roofBase - rh * 0.75),
      Offset(cx + rw * 0.2, roofBase - rh * 0.75),
      Offset(cx + rw * 0.4, roofBase - rh * 0.4),
      Offset(cx + rw * 0.56, roofBase - rh * 0.62),
      Offset(cx + rw * 0.5, roofBase - rh * 0.25),
    ]),
    const Color(0xFF7E8084),
    line: 0.4,
  );
  // The finial: rings to a point.
  final top = roofBase - rh * 0.75;
  for (var k = 0; k < 6; k++) {
    a.oval(
      Rect.fromCenter(
        center: Offset(cx, top - rh * (0.15 + k * 0.28)),
        width: body.width * (0.5 - k * 0.05),
        height: rh * 0.24,
      ),
      const Color(0xFF8A8C90),
      line: 0.3,
    );
  }
  a.circle(
    Offset(cx, top - rh * 1.95),
    body.width * 0.14,
    const Color(0xFF8A8C90),
    line: 0.3,
  );
}

/// A stone lantern on the ground: a foot, a post, the fire box, a cap.
void _stoneLantern(Room room, double x, double z) {
  final a = room.a;
  room
    ..shadow(x - 0.05, x + 0.05, z - 0.04, z + 0.04, strength: 0.45)
    ..block(x - 0.05, x + 0.05, 0, 0.04, z - 0.04, z + 0.04, _granite)
    ..block(x - 0.015, x + 0.015, 0.04, 0.2, z - 0.012, z + 0.012, _granite)
    ..block(
      x - 0.04,
      x + 0.04,
      0.2,
      0.23,
      z - 0.035,
      z + 0.035,
      const Color(0xFF9A9C9E),
    );
  final box = room.block(
    x - 0.03,
    x + 0.03,
    0.23,
    0.3,
    z - 0.025,
    z + 0.025,
    const Color(0xFF9A9C9E),
  );
  a.fill(box.deflate(box.width * 0.25), const Color(0xFF3A3630));
  final cap = room.block(
    x - 0.055,
    x + 0.055,
    0.3,
    0.32,
    z - 0.05,
    z + 0.05,
    const Color(0xFF7E8084),
  );
  a.path(
    a.poly([
      cap.topLeft,
      Offset(cap.center.dx, cap.top - cap.width * 0.3),
      cap.topRight,
    ]),
    const Color(0xFF7E8084),
    line: 0.3,
  );
}

// ---------------------------------------------------------------------------
// Scenes

/// The dig, a summer afternoon, seen from one camera: the ground runs back
/// to the site fence and on to the horizon, a city beyond. The trench in
/// front, the moat's section in its far wall; the stone marker at the
/// corner; the finds room's cabin and the site office; the gate out to
/// the street. Everything stands on the ground with its shadow under it.
void _dig(Art a) {
  final room = Room(a, vp: a.p(0.5, 0.3), depth: 0.3);
  final fenceFoot = room.at(0, 0, 1).dy;
  _summerSky(a, 0.36);
  _city(a, 0.35);
  a.fill(Rect.fromLTRB(0, fenceFoot - 1, a.size.width, a.size.height), _clay);

  // The site fence across the far side of the block: white panels, a
  // green band, an open gate onto the street.
  a.path(
    a.poly([
      room.at(-2, 0.6, 1),
      room.at(3, 0.6, 1),
      room.at(3, 0, 1),
      room.at(-2, 0, 1),
    ]),
    _fence,
    line: 0.4,
  );
  a.path(
    a.poly([
      room.at(-2, 0.48, 1),
      room.at(3, 0.48, 1),
      room.at(3, 0.42, 1),
      room.at(-2, 0.42, 1),
    ]),
    _fenceBand,
    line: 0,
  );
  for (var k = -20; k <= 30; k++) {
    final x = k / 10;
    a.hairline(
      room.at(x, 0.6, 1),
      room.at(x, 0, 1),
      const Color(0x44000000),
      0.2,
    );
  }
  final gate = Rect.fromPoints(room.at(0.38, 0.55, 1), room.at(0.62, 0, 1));
  a
    ..fade(gate, _skyLow, _haze)
    ..fill(
      Rect.fromLTRB(
        gate.left,
        gate.top + gate.height * 0.66,
        gate.right,
        gate.bottom,
      ),
      const Color(0xFF8A8A84),
    );
  _roof(
    a,
    Rect.fromLTWH(
      gate.left + gate.width * 0.18,
      gate.top + gate.height * 0.3,
      gate.width * 0.64,
      gate.height * 0.22,
    ),
    color: const Color(0xFF5A5C60),
  );
  a
    ..fill(
      Rect.fromLTWH(
        gate.left + gate.width * 0.3,
        gate.top + gate.height * 0.52,
        gate.width * 0.4,
        gate.height * 0.14,
      ),
      const Color(0xFF5A4636),
    )
    ..ink(gate, width: 0.5);
  for (final x in [0.36, 0.62]) {
    room.block(
      x,
      x + 0.02,
      0,
      0.62,
      0.98,
      1,
      const Color(0xFF9A9A92),
      line: 0.3,
    );
  }

  // The ground: clay, a surveyor's grid of string over it, grit.
  room.floorGrid(
    const Color(0x40F0E8D0),
    rows: 6,
    columns: 16,
    width: 0.2,
    x0: -1.5,
    x1: 2.5,
  );
  final random = math.Random(9);
  for (var i = 0; i < 200; i++) {
    final p = room.floorAt(
      -1 + random.nextDouble() * 3,
      random.nextDouble() * 0.98,
    );
    a.canvas.drawCircle(
      p,
      a.u * (0.15 + random.nextDouble() * 0.3),
      Paint()..color = const Color(0x334A3820),
    );
  }

  // The finds room and the site office: cabins against the fence.
  _prefab(room, -0.5, 0.05, 0.72, 0.92);
  _prefab(room, 0.95, 1.5, 0.7, 0.92);

  // A spoil heap on the left, weeds on it.
  room.shadow(-0.4, 0.12, 0.45, 0.68, strength: 0.3, spread: 0.05);
  final heapL = room.floorAt(-0.4, 0.5);
  final heapR = room.floorAt(0.12, 0.5);
  final peak = room.at(-0.12, 0.2, 0.58);
  final control = peak * 2 - Offset.lerp(heapL, heapR, 0.5)!;
  final heap = Path()
    ..moveTo(heapL.dx, heapL.dy)
    ..quadraticBezierTo(control.dx, control.dy, heapR.dx, heapR.dy)
    ..close();
  a.path(heap, _clayDark, line: 0.4);
  for (var i = 0; i < 9; i++) {
    final t = 0.15 + i * 0.08;
    final base = Offset(
      heapL.dx + (heapR.dx - heapL.dx) * t,
      heapL.dy - (heapL.dy - peak.dy) * (1 - (2 * t - 1) * (2 * t - 1)) * 0.92,
    );
    a.line(
      base,
      base.translate(a.u * (i.isEven ? 0.6 : -0.5), -a.u * 1.8),
      const Color(0xFF5A7040),
      width: 0.4,
    );
  }

  // A blue tarp folded back on the ground, right of the trench.
  a
    ..path(_flat(room, 0.82, 1.08, 0.62, 0.78, 0.005), _tarp, line: 0.4)
    ..line(
      room.at(0.82, 0.005, 0.7),
      room.at(1.08, 0.005, 0.7),
      const Color(0x66000000),
      width: 0.3,
    );

  // The trench: an opening in the ground; inside it, the sides in shade,
  // a wet floor, and the far wall: the moat's section, layer under layer.
  const tx0 = 0.18;
  const tx1 = 0.82;
  const tz0 = 0.22;
  const tz1 = 0.6;
  const deep = -0.45;
  final opening = _flat(room, tx0, tx1, tz0, tz1, 0);
  room.shadow(tx0, tx1, tz0, tz1, strength: 0.2, spread: 0.04);
  a.canvas
    ..save()
    ..clipPath(opening);
  a
    ..path(
      _flat(room, tx0, tx1, tz0, tz1, deep),
      const Color(0xFF3A3630),
      line: 0,
    )
    ..path(
      a.poly([
        room.at(tx0, 0, tz0),
        room.at(tx0, 0, tz1),
        room.at(tx0, deep, tz1),
        room.at(tx0, deep, tz0),
      ]),
      const Color(0xFF4A3A28),
      line: 0.3,
    )
    ..path(
      a.poly([
        room.at(tx1, 0, tz0),
        room.at(tx1, 0, tz1),
        room.at(tx1, deep, tz1),
        room.at(tx1, deep, tz0),
      ]),
      const Color(0xFF5A4630),
      line: 0.3,
    );
  const bands = [
    (0.0, 0.16, Color(0xFF8A7458)),
    (0.16, 0.36, Color(0xFF7A5A3A)),
    (0.36, 0.48, Color(0xFF2A2420)),
    (0.48, 0.64, Color(0xFF8C8A80)),
    (0.64, 0.8, _ash),
    (0.8, 1.0, Color(0xFF4A4A40)),
  ];
  for (final (from, to, color) in bands) {
    a.path(
      a.poly([
        room.at(tx0, deep * from, tz1),
        room.at(tx1, deep * from, tz1),
        room.at(tx1, deep * to, tz1),
        room.at(tx0, deep * to, tz1),
      ]),
      color,
      line: 0,
    );
  }
  // Tile fragments in the black layer of the fire; white tags at the lines.
  for (var i = 0; i < 16; i++) {
    final p = room.at(
      tx0 + random.nextDouble() * (tx1 - tx0),
      deep * (0.66 + random.nextDouble() * 0.12),
      tz1,
    );
    a.canvas.drawRect(
      Rect.fromCenter(center: p, width: a.u * 1.1, height: a.u * 0.45),
      Paint()..color = const Color(0xFF7A4A34),
    );
  }
  for (var k = 1; k < 6; k++) {
    a.fill(
      Rect.fromCenter(
        center: room.at(tx1 - 0.05, deep * bands[k].$1, tz1),
        width: a.u * 1.1,
        height: a.u * 0.7,
      ),
      const Color(0xFFF2F0E8),
    );
  }
  // A ladder down the far wall.
  for (final x in [0.27, 0.33]) {
    a.line(
      room.at(x, 0.12, tz1 - 0.02),
      room.at(x, deep, tz1 - 0.06),
      const Color(0xFF8A6A44),
      width: 0.6,
    );
  }
  for (var k = 0; k < 5; k++) {
    final y = 0.08 - k * 0.11;
    a.line(
      room.at(0.27, y, tz1 - 0.03),
      room.at(0.33, y, tz1 - 0.03),
      const Color(0xFF8A6A44),
      width: 0.4,
    );
  }
  a.canvas.restore();
  a.strokePath(opening, const Color(0xFF2A2018), width: 0.5);

  // The pump behind the trench, its hose over the lip and down.
  room
    ..shadow(0.1, 0.17, 0.64, 0.72, strength: 0.45)
    ..block(0.1, 0.17, 0, 0.1, 0.64, 0.72, const Color(0xFFC08A2A));
  final hoseFrom = room.at(0.17, 0.05, 0.68);
  final lip = room.at(0.4, 0, tz1);
  final hose = Path()
    ..moveTo(hoseFrom.dx, hoseFrom.dy)
    ..quadraticBezierTo(
      room.at(0.3, 0, 0.66).dx,
      room.at(0.3, 0, 0.66).dy,
      lip.dx,
      lip.dy,
    )
    ..lineTo(
      room.at(0.44, deep * 0.3, tz1 - 0.04).dx,
      room.at(0.44, deep * 0.3, tz1 - 0.04).dy,
    );
  a.strokePath(hose, const Color(0xFF2A2A2A), width: 0.7);

  // Sieves on trestles at the right, buckets of sludge before them.
  final sieve = room.table(
    0.98,
    1.22,
    0.32,
    0.44,
    0.26,
    const Color(0xFF7A6448),
    thickness: 0.04,
    leg: 0.012,
  );
  a.path(
    _flat(room, 1.0, 1.2, 0.335, 0.425, 0.262),
    const Color(0xFF7A7A72),
    line: 0.2,
  );
  a.ink(sieve, width: 0.2);
  _bucket(room, 1.02, 0.23, 0.032, 0.09);
  _bucket(room, 1.12, 0.21, 0.032, 0.09);

  // The stone marker at the corner, front left.
  _markerPost(room, -0.02, 0.04, 0.13, 0.18);
  // Afternoon heat.
  a.glow(
    a.p(0.7, 0.0),
    a.size.width * 0.5,
    const Color(0xFFFFF0C0),
    strength: 0.18,
  );
}

/// The site office, seen from its door: a prefab room, a window onto the
/// dig, the permit board, hard hats on a peg rail, a filing cabinet, and
/// the city map on the table.
void _office(Art a) {
  final room = Room(a, vp: a.p(0.5, 0.2), depth: 0.55);
  final back = room.back;
  a
    ..path(room.ceiling, const Color(0xFFC4C0B4), line: 0)
    ..path(room.leftWall, const Color(0xFFB8B4A6), line: 0)
    ..path(room.rightWall, const Color(0xFFC0BCAE), line: 0)
    ..fill(back, const Color(0xFFCCC8BA))
    ..path(room.floor, const Color(0xFF6A7068), line: 0);
  room
    ..floorGrid(const Color(0x44202420), rows: 6, columns: 8)
    ..shadeCorners(strength: 0.3)
    ..edges(const Color(0x66302C28), width: 0.4);
  // Ribbed panels on the back wall.
  for (var k = 1; k < 12; k++) {
    a.hairline(
      room.at(k / 12, 0, 1),
      room.at(k / 12, 1, 1),
      const Color(0x22000000),
      0.25,
    );
  }
  // The fluorescent tube on the ceiling.
  a
    ..path(
      _flat(room, 0.38, 0.62, 0.3, 0.42, 0.99),
      const Color(0xFFF4F4EC),
      line: 0.3,
    )
    ..glow(
      room.at(0.5, 0.99, 0.36),
      a.size.width * 0.4,
      const Color(0xFFF0F4EC),
      strength: 0.2,
    );
  // The window onto the dig: the fence, a crane's arm.
  final win = Rect.fromPoints(room.at(0.06, 0.82, 1), room.at(0.44, 0.48, 1));
  room.recess(win, const Color(0xFFCCC8BA), thickness: 0.03);
  final glass = Room.recessInner(win, thickness: 0.03);
  a
    ..fade(glass, _skyHigh, _skyLow)
    ..fill(
      Rect.fromLTRB(
        glass.left,
        glass.bottom - glass.height * 0.3,
        glass.right,
        glass.bottom,
      ),
      _fence,
    )
    ..fill(
      Rect.fromLTRB(
        glass.left,
        glass.bottom - glass.height * 0.26,
        glass.right,
        glass.bottom - glass.height * 0.22,
      ),
      _fenceBand,
    )
    ..line(
      Offset(glass.left + glass.width * 0.7, glass.bottom - glass.height * 0.3),
      Offset(glass.left + glass.width * 0.72, glass.top + glass.height * 0.1),
      const Color(0xFFC08A2A),
      width: 0.6,
    )
    ..line(
      Offset(glass.left + glass.width * 0.72, glass.top + glass.height * 0.1),
      Offset(glass.left + glass.width * 0.2, glass.top + glass.height * 0.2),
      const Color(0xFFC08A2A),
      width: 0.5,
    )
    ..ink(glass, width: 0.4)
    ..hairline(
      glass.topCenter,
      glass.bottomCenter,
      const Color(0xFF6A6A66),
      0.5,
    );
  room.beam(
    [glass.bottomLeft, glass.bottomRight],
    [
      room.floorAt(0.1, 0.62),
      room.floorAt(0.42, 0.62),
      room.floorAt(0.46, 0.36),
      room.floorAt(0.02, 0.36),
    ],
    const Color(0xFFFFF4D0),
    strength: 0.1,
  );
  // The permit board on the back wall, a sketch pinned below.
  final board = Rect.fromPoints(room.at(0.56, 0.86, 1), room.at(0.92, 0.42, 1));
  room.box(board, const Color(0xFFF2F0E8), depth: 0.01);
  a.fill(
    Rect.fromLTWH(board.left, board.top, board.width, board.height * 0.14),
    const Color(0xFF2A4A7A),
  );
  for (var k = 0; k < 5; k++) {
    final y = board.top + board.height * (0.24 + k * 0.08);
    a.hairline(
      Offset(board.left + board.width * 0.08, y),
      Offset(board.right - board.width * (k.isOdd ? 0.3 : 0.1), y),
      const Color(0x88202020),
      0.3,
    );
  }
  final sketch = Rect.fromLTWH(
    board.left + board.width * 0.2,
    board.top + board.height * 0.66,
    board.width * 0.6,
    board.height * 0.28,
  );
  a
    ..box(sketch, _paper, line: 0.3)
    ..strokePath(
      Path()..addRect(sketch.deflate(a.u * 0.8)),
      const Color(0xFF3A5A8A),
      width: 0.4,
    )
    ..strokePath(
      Path()..addRect(sketch.deflate(a.u * 1.6)),
      const Color(0xFF6A5A4A),
      width: 0.3,
    );

  // A peg rail on the left wall, hard hats hanging from it.
  a.path(
    a.poly([
      room.at(0, 0.66, 0.18),
      room.at(0, 0.66, 0.62),
      room.at(0, 0.62, 0.62),
      room.at(0, 0.62, 0.18),
    ]),
    const Color(0xFF8A6A44),
    line: 0.3,
  );
  for (final (k, z) in [0.26, 0.4, 0.54].indexed) {
    final peg = room.at(0.015, 0.64, z);
    final w = a.size.width * 0.07 * room.scaleAt(z);
    final rim = peg.translate(w * 0.15, w * 0.62);
    // Its shadow on the wall, then the hat.
    a.canvas.drawOval(
      Rect.fromCenter(
        center: rim.translate(-w * 0.12, -w * 0.1),
        width: w * 1.05,
        height: w * 0.6,
      ),
      Paint()
        ..color = const Color(0x33000000)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, a.u * 0.6),
    );
    a
      ..line(
        peg,
        peg.translate(w * 0.15, w * 0.1),
        const Color(0xFF3A3A38),
        width: 0.4,
      )
      ..path(
        Path()
          ..moveTo(rim.dx - w / 2, rim.dy)
          ..quadraticBezierTo(rim.dx, rim.dy - w * 0.95, rim.dx + w / 2, rim.dy)
          ..close(),
        k == 1 ? const Color(0xFFF0F0EA) : const Color(0xFFE8C030),
        line: 0.4,
      )
      ..line(
        Offset(rim.dx - w * 0.62, rim.dy),
        Offset(rim.dx + w * 0.62, rim.dy),
        const Color(0xFF6A5A30),
        width: 0.5,
      );
  }

  // A filing cabinet against the right wall.
  room.shadow(0.84, 0.98, 0.42, 0.62, strength: 0.4, spread: 0.08);
  final cabinet = room.block(
    0.84,
    0.98,
    0,
    0.45,
    0.42,
    0.62,
    const Color(0xFF8A9090),
  );
  for (var k = 1; k < 4; k++) {
    final y = cabinet.top + cabinet.height * k / 4;
    a
      ..hairline(
        Offset(cabinet.left, y),
        Offset(cabinet.right, y),
        const Color(0x66000000),
        0.4,
      )
      ..fill(
        Rect.fromCenter(
          center: Offset(cabinet.center.dx, y - cabinet.height / 8),
          width: cabinet.width * 0.3,
          height: a.u * 0.6,
        ),
        const Color(0xFF4A4E50),
      );
  }

  // The table, the map of the city on it, a phone at its corner.
  room.table(
    0.2,
    0.8,
    0.1,
    0.5,
    0.27,
    const Color(0xFF9A8460),
    legColor: const Color(0xFF6A6460),
    leg: 0.018,
  );
  const y = 0.2705;
  a.path(
    _flat(room, 0.25, 0.75, 0.14, 0.46, y),
    const Color(0xFFE8E0CA),
    line: 0.4,
  );
  for (var k = 1; k < 8; k++) {
    final x = 0.25 + 0.5 * k / 8;
    a.hairline(
      room.at(x, y, 0.14),
      room.at(x, y, 0.46),
      const Color(0x664A4030),
      0.3,
    );
  }
  for (var k = 1; k < 6; k++) {
    final z = 0.14 + 0.32 * k / 6;
    a.hairline(
      room.at(0.25, y, z),
      room.at(0.75, y, z),
      const Color(0x664A4030),
      0.3,
    );
  }
  room.block(
    0.69,
    0.75,
    0.27,
    0.29,
    0.38,
    0.47,
    const Color(0xFF3A3A3A),
    line: 0.3,
  );
}

/// The finds room: racks of trays along the left wall, shelves of bagged
/// finds, the long table with its papers and a cloth for the tile, a
/// pinboard on the back wall.
void _finds(Art a) {
  final room = Room(a, vp: a.p(0.5, 0.2), depth: 0.55);
  final back = room.back;
  a
    ..path(room.ceiling, const Color(0xFFBCB8AC), line: 0)
    ..path(room.leftWall, const Color(0xFFB0AC9E), line: 0)
    ..path(room.rightWall, const Color(0xFFB8B4A6), line: 0)
    ..fill(back, const Color(0xFFC4C0B2))
    ..path(room.floor, const Color(0xFF5E625A), line: 0);
  room
    ..floorGrid(const Color(0x44202420), rows: 6, columns: 8)
    ..shadeCorners(strength: 0.35)
    ..edges(const Color(0x66302C28), width: 0.4);
  a
    ..path(
      _flat(room, 0.38, 0.62, 0.3, 0.42, 0.99),
      const Color(0xFFF4F4EC),
      line: 0.3,
    )
    ..glow(
      room.at(0.5, 0.99, 0.36),
      a.size.width * 0.4,
      const Color(0xFFF0F4EC),
      strength: 0.22,
    );

  // Shelves of bagged finds along the back wall.
  for (var k = 0; k < 3; k++) {
    final y = 0.42 + k * 0.17;
    room.box(
      Rect.fromPoints(room.at(0.2, y, 0.97), room.at(0.6, y - 0.015, 0.97)),
      const Color(0xFF8A7A5A),
      depth: 0.03,
      line: 0.3,
    );
    for (var j = 0; j < 7; j++) {
      final x = 0.215 + j * 0.055;
      a.box(
        Rect.fromPoints(
          room.at(x, y + 0.09, 0.98),
          room.at(x + 0.042, y, 0.98),
        ),
        Color.lerp(
          const Color(0xFFE6E2D6),
          const Color(0xFFA0907A),
          (j * 37 % 10) / 14,
        )!,
        line: 0.2,
      );
    }
  }

  // The pinboard on the right of the back wall, empty pins for now.
  final pin = Rect.fromPoints(room.at(0.64, 0.82, 1), room.at(0.95, 0.42, 1));
  room.box(pin, const Color(0xFFA08A64), depth: 0.01);
  for (var k = 0; k < 4; k++) {
    a.circle(
      Offset(
        pin.left + pin.width * (0.2 + k * 0.2),
        pin.top + pin.height * 0.15,
      ),
      a.u * 0.4,
      const Color(0xFFB0302A),
      line: 0,
    );
  }

  // The racks of trays along the left wall: their faces turned to the
  // room, receding.
  room.shadow(0, 0.16, 0.1, 0.62, strength: 0.4, spread: 0.06);
  room.block(0, 0.16, 0, 0.78, 0.1, 0.62, const Color(0xFF7A7E80));
  final random = math.Random(3);
  for (var k = 0; k < 5; k++) {
    final y0 = 0.04 + k * 0.15;
    final y1 = y0 + 0.11;
    a.path(
      a.poly([
        room.at(0.16, y1, 0.13),
        room.at(0.16, y1, 0.59),
        room.at(0.16, y0, 0.59),
        room.at(0.16, y0, 0.13),
      ]),
      const Color(0xFFD8D2C2),
      line: 0.3,
    );
    for (var j = 0; j < 9; j++) {
      final p = room.at(
        0.16,
        y0 + 0.03 + random.nextDouble() * 0.05,
        0.15 + j * 0.05,
      );
      final s = a.u * 1.4 * room.scaleAt(0.15 + j * 0.05) / room.scaleAt(0.3);
      a.path(
        a.poly([
          p,
          p.translate(s, -s * 0.3),
          p.translate(s * 1.1, s * 0.5),
          p.translate(s * 0.1, s * 0.6),
        ]),
        j.isEven ? _tileBurnt : const Color(0xFF5A5A5E),
        line: 0.2,
      );
    }
  }

  // The long table under the lamp. On it the chronicle, a cloth laid
  // ready for the tile, and a cleared space where the letter will lie.
  room.table(
    0.22,
    0.84,
    0.12,
    0.5,
    0.27,
    const Color(0xFFD8D4C8),
    legColor: const Color(0xFF6A6A66),
    leg: 0.018,
  );
  const y = 0.2705;
  _flatPaper(room, 0.27, 0.42, 0.24, 0.4, y, color: const Color(0xFFE2DCC8));
  _flatPaper(
    room,
    0.285,
    0.43,
    0.22,
    0.38,
    y + 0.001,
    color: const Color(0xFFEDE4C8),
  );
  a.path(
    _flat(room, 0.46, 0.6, 0.22, 0.42, y),
    const Color(0xFFEAE6DA),
    line: 0.3,
  );
  a.glow(room.at(0.55, y, 0.3), a.size.width * 0.3, _lamp, strength: 0.14);
}

/// Today's Honnō-ji at Teramachi, from one camera: the court of raked
/// gravel and the paved path to the main hall; the memorial tower on the
/// left, a stone lantern either side of the path, a leaflet rack, and a
/// guide's flag across the court.
void _teramachi(Art a) {
  final room = Room(a, vp: a.p(0.5, 0.36), depth: 0.25);
  _summerSky(a, 0.6);
  // Trees of the precinct, above the far wall.
  final random = math.Random(5);
  for (var i = 0; i < 14; i++) {
    a.canvas.drawCircle(
      a.p(0.04 + i * 0.07, 0.22 + random.nextDouble() * 0.08),
      a.u * (6 + random.nextDouble() * 5),
      Paint()
        ..color = Color.lerp(
          const Color(0xFF3E5A3A),
          const Color(0xFF5A7048),
          random.nextDouble(),
        )!,
    );
  }
  // The far wall, white plaster under a tiled coping.
  room.block(
    -3,
    4,
    0,
    0.3,
    1.6,
    1.65,
    const Color(0xFFE6E2D6),
    top: _tile,
    line: 0.3,
  );
  // The court: gravel to the wall, raked in lines.
  a.fill(
    Rect.fromLTRB(0, room.at(0, 0, 1.6).dy, a.size.width, a.size.height),
    _gravel,
  );
  for (var k = 1; k < 30; k++) {
    final z = 1.6 * k / 30;
    a.hairline(
      room.floorAt(-3, z),
      room.floorAt(4, z),
      const Color(0x22000000),
      0.3,
    );
  }

  // The main hall: a stone platform, cedar posts, paper doors lit from
  // within, and the great roof.
  room.shadow(-0.3, 1.3, 1.0, 1.35, strength: 0.35, spread: 0.03);
  room.block(-0.3, 1.3, 0, 0.06, 1.0, 1.35, const Color(0xFF9A968A));
  final hall = room.block(
    -0.2,
    1.2,
    0.06,
    0.62,
    1.04,
    1.32,
    const Color(0xFF3A2A1E),
  );
  for (var k = 0; k <= 6; k++) {
    final x = hall.left + hall.width * k / 6;
    a.box(
      Rect.fromLTWH(x - a.u * 0.5, hall.top, a.u, hall.height),
      _cedar,
      line: 0.3,
    );
  }
  for (var k = 1; k < 5; k++) {
    final d = Rect.fromLTWH(
      hall.left + hall.width * k / 6 + a.u * 0.6,
      hall.top + hall.height * 0.25,
      hall.width / 6 - a.u * 1.2,
      hall.height * 0.6,
    );
    a.fill(d, const Color(0xFFE8D8B0));
    for (var j = 1; j < 4; j++) {
      a.hairline(
        Offset(d.left, d.top + d.height * j / 4),
        Offset(d.right, d.top + d.height * j / 4),
        const Color(0x664A3A2A),
        0.25,
      );
    }
  }
  a.glow(hall.center, hall.width * 0.6, _lamp, strength: 0.12);
  final eaves = Rect.fromPoints(
    room.at(-0.45, 1.25, 1.0),
    room.at(1.45, 0.58, 1.0),
  );
  _roof(a, eaves);
  // Steps up to the platform.
  for (var k = 0; k < 3; k++) {
    room.block(
      0.38 - k * 0.02,
      0.62 + k * 0.02,
      0,
      0.06 - k * 0.02,
      0.94 - k * 0.03,
      1.0 - k * 0.03,
      const Color(0xFFA8A496),
      line: 0.25,
    );
  }

  // The paved path from the gate to the steps.
  a.path(
    _flat(room, 0.42, 0.58, 0, 0.9, 0.002),
    const Color(0xFFA8A496),
    line: 0.3,
  );
  for (var k = 1; k < 14; k++) {
    final z = 0.9 * k / 14;
    a.hairline(
      room.at(0.42, 0.002, z),
      room.at(0.58, 0.002, z),
      const Color(0x44000000),
      0.3,
    );
  }

  // A stone lantern either side of the path.
  _stoneLantern(room, 0.25, 0.62);
  _stoneLantern(room, 0.75, 0.62);

  // A guide's flag on its pole across the court, no one holding it.
  final foot = room.floorAt(1.32, 0.85);
  final tip = room.at(1.32, 0.78, 0.85);
  room.footShadow(1.32, 0.85, 0.03);
  a
    ..line(foot, tip, const Color(0xFF4A4A48), width: 0.5)
    ..path(
      a.poly([
        tip,
        tip.translate(a.u * 5, a.u * 1.2),
        tip.translate(0, a.u * 2.6),
      ]),
      const Color(0xFFD0A030),
      line: 0.3,
    );

  // The memorial tower, an offering box and flowers before it.
  _tower(room, -0.22, 0.42, 0.2);
  room
    ..shadow(-0.28, -0.16, 0.25, 0.3, strength: 0.45)
    ..block(-0.28, -0.16, 0, 0.08, 0.25, 0.3, const Color(0xFF6A5A48));
  for (final x in [-0.26, -0.18]) {
    final base = room.at(x, 0.08, 0.29);
    final top = room.at(x, 0.16, 0.29);
    a
      ..line(base, top, const Color(0xFF3A5A30), width: 0.4)
      ..circle(top, a.u * 0.9, const Color(0xFFE8E0D0), line: 0.2);
  }

  // The leaflet rack at the right front, leaflets standing in it.
  final rack = room.table(
    1.0,
    1.2,
    0.24,
    0.31,
    0.34,
    const Color(0xFF6A4E36),
    thickness: 0.06,
    leg: 0.014,
  );
  for (var k = 0; k < 3; k++) {
    a.paper(
      Rect.fromLTWH(
        rack.left + rack.width * (0.08 + k * 0.3),
        rack.top - rack.height * 1.6,
        rack.width * 0.26,
        rack.height * 1.8,
      ),
      lines: 3,
      color: const Color(0xFFF2EEE2),
    );
  }
  a.glow(
    a.p(0.8, 0.0),
    a.size.width * 0.5,
    const Color(0xFFFFF0C0),
    strength: 0.16,
  );
}

// ---------------------------------------------------------------------------
// Puzzle boards

/// Behind the section: the trench's wall, dim, a lamp on the lip.
void _strataBoard(Art a) {
  a
    ..fade(
      Offset.zero & a.size,
      const Color(0xFF3A3024),
      const Color(0xFF1E1812),
    )
    ..glow(a.p(0.35, 0.0), a.size.width * 0.55, _lamp, strength: 0.18);
  final random = math.Random(2007);
  for (var i = 0; i < 200; i++) {
    a.canvas.drawCircle(
      a.p(random.nextDouble(), random.nextDouble()),
      a.u * (0.1 + random.nextDouble() * 0.3),
      Paint()..color = const Color(0x22E8D8B8),
    );
  }
}

/// The site table under the map: a dark board.
void _streetsBoard(Art a) {
  a
    ..fade(
      Offset.zero & a.size,
      const Color(0xFF2A3036),
      const Color(0xFF181C20),
    )
    ..glow(
      a.p(0.35, 0.5),
      a.size.width * 0.5,
      const Color(0xFFF0F4EC),
      strength: 0.08,
    );
}

// ---------------------------------------------------------------------------
// Objects

/// The round eave tile on its cloth, burnt.
void _roundTile(Art a) {
  a.glow(a.p(0.5, 0.55), a.size.width * 0.5, _lamp, strength: 0.15);
  final c = a.p(0.5, 0.5);
  final r = a.size.shortestSide * 0.38;
  a.canvas.drawOval(
    Rect.fromCenter(
      center: c.translate(r * 0.1, r * 0.2),
      width: r * 2.3,
      height: r * 1.6,
    ),
    Paint()
      ..color = const Color(0x66000000)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, a.u * 2),
  );
  // Lying on its back on the cloth: the disc seen at a slant.
  a.canvas
    ..save()
    ..translate(c.dx, c.dy)
    ..scale(1, 0.55)
    ..translate(-c.dx, -c.dy);
  _tileFace(a, c, r);
  a.canvas.restore();
}

/// Fróis's letter, folded, a line of Portuguese hand.
void _letter(Art a) {
  // Lying flat on the table: the far edge a little narrower.
  final sheet = a.poly([
    a.p(0.07, 0.06),
    a.p(0.93, 0.06),
    a.p(0.98, 0.94),
    a.p(0.02, 0.94),
  ]);
  a.path(sheet, const Color(0xFFE8DCBA), line: 0.3);
  for (var k = 0; k < 6; k++) {
    final y = 0.2 + k * 0.12;
    a.hairline(
      a.p(0.14, y),
      a.p(k.isOdd ? 0.7 : 0.84, y),
      StillroomPalette.inkOnPaper.withValues(alpha: 0.55),
      0.3,
    );
  }
  a
    ..hairline(a.p(0.5, 0.06), a.p(0.5, 0.94), const Color(0x44000000), 0.3)
    ..glow(a.p(0.5, 0.5), a.size.width * 0.5, _lamp, strength: 0.12);
}

/// Later papers pinned to the board.
void _papers(Art a) {
  for (var i = 0; i < 3; i++) {
    a.paper(
      a.r(0.06 + i * 0.28, 0.1 + (i % 2) * 0.08, 0.3, 0.72),
      lines: 6,
      angle: -0.05 + i * 0.05,
      color: i == 1 ? const Color(0xFFF2F2EE) : _paper,
      ink: 0.5,
    );
    a.circle(
      a.p(0.21 + i * 0.28, 0.14 + (i % 2) * 0.08),
      a.u * 1.4,
      const Color(0xFFB0302A),
      line: 0.2,
    );
  }
}

/// The jar: dusk over Kyoto, a temple roof black against it, smoke rising,
/// and below, the black layer in the earth.
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
  a
    ..fade(
      a.r(0, 0.16, 1, 0.5),
      const Color(0xFF4A3A44),
      const Color(0xFFC0703A),
    )
    ..glow(a.p(0.5, 0.62), w * 0.6, const Color(0xFFE08A3A), strength: 0.4);
  for (var k = 0; k < 4; k++) {
    a.canvas.drawCircle(
      a.p(0.46 + k * 0.05, 0.42 - k * 0.07),
      w * (0.1 + k * 0.03),
      Paint()
        ..color = const Color(0x553A3034)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.04),
    );
  }
  _roof(a, a.r(0.14, 0.5, 0.72, 0.16), color: const Color(0xFF1A1414));
  a
    ..fill(a.r(0, 0.66, 1, 0.1), const Color(0xFF1A1414))
    ..fill(a.r(0, 0.76, 1, 0.08), _clay)
    ..fill(a.r(0, 0.84, 1, 0.06), _ash)
    ..fill(a.r(0, 0.9, 1, 0.1), const Color(0xFF4A4A40));
  for (var k = 0; k < 6; k++) {
    a.fill(a.r(0.1 + k * 0.14, 0.86, 0.06, 0.015), const Color(0xFF7A4A34));
  }
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
  // The lid: a round eave tile.
  _tileFace(a, a.p(0.5, 0.1), a.size.width * 0.16, burnt: false);
}
