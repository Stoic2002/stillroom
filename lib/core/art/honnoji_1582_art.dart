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

/// A stone site marker: a square granite post, the face with cut strokes.
void _markerPost(Art a, Rect r, Room room) {
  room.box(r, _granite, depth: 0.03);
  a.fade(r, const Color(0x22FFFFFF), const Color(0x22000000));
  // Cut characters running down the face: a few strokes each.
  final random = math.Random(41);
  final x = r.center.dx;
  for (var k = 0; k < 5; k++) {
    final y = r.top + r.height * (0.1 + k * 0.13);
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
}

/// A Japanese site fence: white panels, a coloured band, posts.
void _fenceRun(Art a, List<Offset> top, List<Offset> bottom) {
  // [top] and [bottom] are the run's two ends, top and foot.
  a.path(a.poly([top[0], top[1], bottom[1], bottom[0]]), _fence, line: 0.4);
  final band0 = Offset.lerp(top[0], bottom[0], 0.18)!;
  final band1 = Offset.lerp(top[1], bottom[1], 0.18)!;
  final band2 = Offset.lerp(top[1], bottom[1], 0.28)!;
  final band3 = Offset.lerp(top[0], bottom[0], 0.28)!;
  a.path(a.poly([band0, band1, band2, band3]), _fenceBand, line: 0);
  for (var k = 1; k < 10; k++) {
    final t = k / 10;
    a.hairline(
      Offset.lerp(top[0], top[1], t)!,
      Offset.lerp(bottom[0], bottom[1], t)!,
      const Color(0x55000000),
      0.25,
    );
  }
}

/// A prefab site cabin: its front face [front], a door, a window.
void _prefab(Art a, Room room, Rect front, {bool door = true}) {
  room.box(front, _cabin, depth: 0.1);
  // Roof edge and a gutter.
  a.box(
    Rect.fromLTRB(
      front.left - a.u * 0.4,
      front.top - a.u * 0.8,
      front.right + a.u * 0.4,
      front.top,
    ),
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
  if (door) {
    final d = Rect.fromLTWH(
      front.left + front.width * 0.12,
      front.top + front.height * 0.22,
      front.width * 0.26,
      front.height * 0.78,
    );
    a
      ..box(d, const Color(0xFF8C8A80), line: 0.4)
      ..fill(
        d.deflate(a.u * 0.6).topLeft &
            Size(d.width - a.u * 1.2, d.height * 0.35),
        const Color(0xFF5A6670),
      )
      ..circle(
        Offset(d.right - a.u, d.center.dy),
        a.u * 0.4,
        const Color(0xFF3A3A38),
        line: 0,
      );
  }
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

/// A memorial tower of stone: a base, a body, a stepped roof with
/// upturned corners, a ringed finial.
void _tower(Art a, Room room, Rect r) {
  final w = r.width;
  final h = r.height;
  room.box(
    Rect.fromLTWH(r.left, r.bottom - h * 0.1, w, h * 0.1),
    _granite,
    depth: 0.05,
  );
  room.box(
    Rect.fromLTWH(r.left + w * 0.12, r.bottom - h * 0.26, w * 0.76, h * 0.16),
    const Color(0xFF9A9C9E),
    depth: 0.04,
    shadow: false,
  );
  room.box(
    Rect.fromLTWH(r.left + w * 0.2, r.bottom - h * 0.5, w * 0.6, h * 0.24),
    const Color(0xFF8A8C90),
    depth: 0.04,
    shadow: false,
  );
  // Carved panels on the body.
  a.ink(
    Rect.fromLTWH(r.left + w * 0.3, r.bottom - h * 0.46, w * 0.4, h * 0.16),
    width: 0.3,
  );
  // The stepped roof with its horns.
  final roofBase = r.bottom - h * 0.5;
  a.path(
    a.poly([
      Offset(r.left + w * 0.04, roofBase),
      Offset(r.left, roofBase - h * 0.1),
      Offset(r.left + w * 0.14, roofBase - h * 0.05),
      Offset(r.left + w * 0.3, roofBase - h * 0.14),
      Offset(r.right - w * 0.3, roofBase - h * 0.14),
      Offset(r.right - w * 0.14, roofBase - h * 0.05),
      Offset(r.right, roofBase - h * 0.1),
      Offset(r.right - w * 0.04, roofBase),
    ]),
    const Color(0xFF7E8084),
    line: 0.4,
  );
  // The finial: rings to a point.
  for (var k = 0; k < 6; k++) {
    final y = roofBase - h * (0.16 + k * 0.05);
    a.oval(
      Rect.fromCenter(
        center: Offset(r.center.dx, y),
        width: w * (0.24 - k * 0.02),
        height: h * 0.04,
      ),
      const Color(0xFF8A8C90),
      line: 0.3,
    );
  }
  a.circle(
    Offset(r.center.dx, r.top + h * 0.04),
    w * 0.08,
    const Color(0xFF8A8C90),
    line: 0.3,
  );
}

/// Papers laid down, from the past.
void _sheaf(Art a, Rect r, {int count = 2, double angle = 0}) {
  for (var i = 0; i < count; i++) {
    a.paper(
      Rect.fromLTWH(
        r.left + i * r.width * 0.04,
        r.top + i * r.height * 0.06,
        r.width * 0.92,
        r.height * 0.9,
      ),
      lines: 5,
      angle: angle + i * 0.04,
      color: i == count - 1 ? const Color(0xFFEDE4C8) : _paper,
      ink: 0.5,
    );
  }
}

/// A sieve on trestles: a wooden frame, a mesh, grey sludge in it.
void _sieve(Art a, Room room, Rect top) {
  for (final x in [top.left + top.width * 0.1, top.right - top.width * 0.14]) {
    a.line(
      Offset(x, top.bottom),
      Offset(x - a.u * 0.4, top.bottom + top.height * 1.6),
      const Color(0xFF5A4A36),
      width: 0.6,
    );
  }
  final frame = a.poly([
    top.bottomLeft,
    top.bottomRight,
    room.toward(top.bottomRight, 0.12),
    room.toward(top.bottomLeft, 0.12),
  ]);
  a.path(frame, const Color(0xFF7A6448), line: 0.4);
  final mesh = Rect.fromPoints(
    Offset.lerp(
      top.bottomLeft,
      room.toward(top.bottomLeft, 0.12),
      0.2,
    )!.translate(a.u * 0.6, 0),
    Offset.lerp(
      top.bottomRight,
      room.toward(top.bottomRight, 0.12),
      0.8,
    )!.translate(-a.u * 0.6, 0),
  );
  a.oval(mesh, const Color(0xFF7A7A72), line: 0.2);
}

// ---------------------------------------------------------------------------
// Scenes

/// The dig, a summer afternoon: the block behind its site fence, a city
/// beyond; the trench in front with the moat's section in its far wall,
/// the stone marker at the corner, the finds room's cabin and the site
/// office, the gate out to the street.
void _dig(Art a) {
  final room = Room(a, back: a.r(0.12, 0.0, 0.76, 0.47), vp: a.p(0.5, 0.32));
  final back = room.back;
  _summerSky(a, 0.47);
  _city(a, 0.3);
  a.fill(a.r(0, 0.46, 1, 0.54), _clay);
  // The far fence along the back of the block; the side fences running
  // forward to the edges of the picture.
  _fenceRun(
    a,
    [a.p(0.12, 0.3), a.p(0.88, 0.3)],
    [back.bottomLeft, back.bottomRight],
  );
  _fenceRun(a, [a.p(0, 0.12), a.p(0.12, 0.3)], [a.p(0, 0.72), back.bottomLeft]);
  _fenceRun(
    a,
    [a.p(0.88, 0.3), a.p(1, 0.12)],
    [back.bottomRight, a.p(1, 0.72)],
  );
  // The ground: clay, a surveyor's grid of string over it.
  room.floorGrid(const Color(0x40F0E8D0), rows: 5, columns: 8, width: 0.2);
  final random = math.Random(9);
  for (var i = 0; i < 160; i++) {
    final p = room.floorAt(random.nextDouble(), random.nextDouble());
    a.canvas.drawCircle(
      p,
      a.u * (0.15 + random.nextDouble() * 0.3),
      Paint()..color = const Color(0x334A3820),
    );
  }
  // The gate in the far fence, open onto the street: a temple's roof far
  // off across the city.
  final gate = a.r(0.44, 0.27, 0.12, 0.2);
  a
    ..fade(gate, _skyLow, _haze)
    ..fill(
      Rect.fromLTRB(
        gate.left,
        gate.top + gate.height * 0.62,
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
        gate.height * 0.12,
      ),
      const Color(0xFF5A4636),
    )
    ..ink(gate, width: 0.5)
    ..box(
      Rect.fromLTWH(
        gate.left - a.u * 0.6,
        gate.top - a.u * 0.6,
        a.u * 0.8,
        gate.height + a.u * 0.6,
      ),
      const Color(0xFF9A9A92),
      line: 0.3,
    )
    ..box(
      Rect.fromLTWH(
        gate.right - a.u * 0.2,
        gate.top - a.u * 0.6,
        a.u * 0.8,
        gate.height + a.u * 0.6,
      ),
      const Color(0xFF9A9A92),
      line: 0.3,
    );
  // The finds room: a prefab cabin against the left of the far fence.
  _prefab(a, room, a.r(0.17, 0.25, 0.15, 0.22));
  // The site office: a larger cabin on the right.
  _prefab(a, room, a.r(0.78, 0.24, 0.18, 0.3));
  // A spoil heap on the left, weeds on it.
  final heap = Path()
    ..moveTo(a.size.width * 0.14, a.size.height * 0.62)
    ..quadraticBezierTo(
      a.size.width * 0.22,
      a.size.height * 0.48,
      a.size.width * 0.3,
      a.size.height * 0.6,
    )
    ..close();
  a.path(heap, _clayDark, line: 0.4);
  for (var i = 0; i < 9; i++) {
    final base = a.p(0.17 + i * 0.013, 0.56 + (i - 4).abs() * 0.008);
    a.line(
      base,
      base.translate(a.u * (i.isEven ? 0.6 : -0.5), -a.u * 2),
      const Color(0xFF5A7040),
      width: 0.4,
    );
  }

  // The trench: an opening in the ground, its far wall the moat's
  // section, layer under layer; a pump hose over the lip.
  final nl = a.p(0.28, 0.8);
  final nr = a.p(0.74, 0.8);
  final fl = a.p(0.33, 0.57);
  final fr = a.p(0.69, 0.57);
  final bl = a.p(0.345, 0.75);
  final br = a.p(0.675, 0.75);
  room.contactShadow(
    Rect.fromPoints(a.p(0.26, 0.54), a.p(0.76, 0.84)),
    strength: 0.15,
  );
  // The sides, in shade, then the floor of the trench, wet.
  a
    ..path(a.poly([nl, fl, bl]), const Color(0xFF4A3A28), line: 0.3)
    ..path(a.poly([nr, fr, br]), const Color(0xFF5A4630), line: 0.3)
    ..path(a.poly([bl, br, nr, nl]), const Color(0xFF3A3630), line: 0.3);
  a.oval(
    Rect.fromPoints(a.p(0.42, 0.765), a.p(0.58, 0.79)),
    const Color(0xFF6A7478),
    line: 0,
  );
  // The section: bands from the top down, as the puzzle shows them.
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
        Offset.lerp(fl, bl, from)!,
        Offset.lerp(fr, br, from)!,
        Offset.lerp(fr, br, to)!,
        Offset.lerp(fl, bl, to)!,
      ]),
      color,
      line: 0,
    );
  }
  // Tile fragments in the black layer of the fire.
  for (var i = 0; i < 14; i++) {
    final t = 0.66 + random.nextDouble() * 0.12;
    final x = random.nextDouble();
    final p = Offset.lerp(Offset.lerp(fl, bl, t)!, Offset.lerp(fr, br, t)!, x)!;
    a.canvas.drawRect(
      Rect.fromCenter(center: p, width: a.u * 1.2, height: a.u * 0.5),
      Paint()..color = const Color(0xFF7A4A34),
    );
  }
  a.strokePath(a.poly([fl, fr, br, bl]), const Color(0x88140E0A), width: 0.4);
  // Survey tags pinned at the layer lines, white.
  for (var k = 1; k < 6; k++) {
    final p = Offset.lerp(
      Offset.lerp(fl, bl, bands[k].$1)!,
      Offset.lerp(fr, br, bands[k].$1)!,
      0.92,
    )!;
    a.fill(
      Rect.fromCenter(center: p, width: a.u * 1.2, height: a.u * 0.8),
      const Color(0xFFF2F0E8),
    );
  }
  // The lip of the trench, a blue tarp folded back beside it.
  a
    ..line(nl, nr, const Color(0xFF2A2018), width: 0.6)
    ..line(fl, fr, const Color(0xFF2A2018), width: 0.4);
  a.path(
    a.poly([a.p(0.64, 0.52), a.p(0.78, 0.52), a.p(0.8, 0.56), a.p(0.68, 0.56)]),
    _tarp,
    line: 0.4,
  );
  // The pump and its hose.
  room.box(
    a.r(0.24, 0.5, 0.05, 0.05),
    const Color(0xFFC08A2A),
    depth: 0.08,
    line: 0.3,
  );
  final hose = Path()
    ..moveTo(a.size.width * 0.265, a.size.height * 0.55)
    ..quadraticBezierTo(
      a.size.width * 0.3,
      a.size.height * 0.62,
      a.size.width * 0.35,
      a.size.height * 0.58,
    )
    ..quadraticBezierTo(
      a.size.width * 0.38,
      a.size.height * 0.68,
      a.size.width * 0.44,
      a.size.height * 0.77,
    );
  a.strokePath(hose, const Color(0xFF2A2A2A), width: 0.7);

  // Sieves on trestles at the right, buckets of sludge.
  _sieve(a, room, a.r(0.77, 0.6, 0.14, 0.05));
  for (final x in [0.79, 0.86]) {
    final b = a.r(x, 0.71, 0.04, 0.05);
    room.box(b, const Color(0xFF3A5A8A), depth: 0.05, line: 0.3);
    a.oval(
      Rect.fromLTWH(b.left, b.top - a.u * 0.4, b.width, a.u * 0.8),
      const Color(0xFF6A6A66),
      line: 0.2,
    );
  }
  // The stone marker at the corner, front left.
  _markerPost(a, a.r(0.06, 0.44, 0.07, 0.38), room);
  // Afternoon heat.
  a.glow(
    a.p(0.7, 0.0),
    a.size.width * 0.5,
    const Color(0xFFFFF0C0),
    strength: 0.18,
  );
}

/// The site office: a prefab room, a window onto the dig, the permit
/// board, hard hats on pegs, and the city map on the table.
void _office(Art a) {
  final room = Room(a, back: a.r(0.18, 0.06, 0.64, 0.5));
  final back = room.back;
  a
    ..path(room.ceiling, const Color(0xFFC4C0B4), line: 0)
    ..path(room.leftWall, const Color(0xFFB8B4A6), line: 0)
    ..path(room.rightWall, const Color(0xFFC0BCAE), line: 0)
    ..fill(back, const Color(0xFFCCC8BA))
    ..path(room.floor, const Color(0xFF6A7068), line: 0);
  room
    ..floorGrid(const Color(0x44202420), rows: 6, columns: 8)
    ..shadeCorners(strength: 0.3);
  // Ribbed panels on the back wall.
  for (var k = 1; k < 12; k++) {
    final x = back.left + back.width * k / 12;
    a.hairline(
      Offset(x, back.top),
      Offset(x, back.bottom),
      const Color(0x22000000),
      0.25,
    );
  }
  for (final (p, q) in [
    (back.topLeft, Offset.zero),
    (back.topRight, Offset(a.size.width, 0)),
    (back.bottomLeft, Offset(0, a.size.height)),
    (back.bottomRight, Offset(a.size.width, a.size.height)),
  ]) {
    a.line(p, q, const Color(0x66302C28), width: 0.4);
  }
  // The fluorescent tube.
  a
    ..path(
      a.poly([
        a.p(0.36, 0.03),
        a.p(0.64, 0.03),
        a.p(0.62, 0.05),
        a.p(0.38, 0.05),
      ]),
      const Color(0xFFF4F4EC),
      line: 0.3,
    )
    ..glow(
      a.p(0.5, 0.05),
      a.size.width * 0.4,
      const Color(0xFFF0F4EC),
      strength: 0.2,
    );
  // The window onto the dig: the fence, a crane's arm.
  final win = a.r(0.24, 0.14, 0.26, 0.2);
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
      room.floorAt(0.2, 0.55),
      room.floorAt(0.5, 0.55),
      room.floorAt(0.55, 0.3),
      room.floorAt(0.12, 0.3),
    ],
    const Color(0xFFFFF4D0),
    strength: 0.1,
  );
  // The permit board on the back wall, a sketch pinned below.
  final board = a.r(0.58, 0.12, 0.22, 0.26);
  a
    ..box(board, const Color(0xFFF2F0E8), line: 0.5)
    ..fill(
      Rect.fromLTWH(board.left, board.top, board.width, board.height * 0.14),
      const Color(0xFF2A4A7A),
    );
  for (var k = 0; k < 5; k++) {
    a.hairline(
      Offset(
        board.left + board.width * 0.08,
        board.top + board.height * (0.24 + k * 0.08),
      ),
      Offset(
        board.right - board.width * (k.isOdd ? 0.3 : 0.1),
        board.top + board.height * (0.24 + k * 0.08),
      ),
      const Color(0x88202020),
      0.3,
    );
  }
  // The sketch: a square of moat round a temple.
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
  // Hard hats on pegs along the left wall, in its slant.
  for (var k = 0; k < 3; k++) {
    final p = Offset.lerp(a.p(0.1, 0.36), a.p(0.2, 0.36), k / 2)!;
    final w = a.u * (6 - k * 1.2);
    a
      ..line(p, p.translate(0, -a.u * 0.8), const Color(0xFF3A3A38), width: 0.4)
      ..path(
        Path()
          ..moveTo(p.dx - w / 2, p.dy + w * 0.35)
          ..quadraticBezierTo(
            p.dx,
            p.dy - w * 0.45,
            p.dx + w / 2,
            p.dy + w * 0.35,
          )
          ..close(),
        k == 1 ? const Color(0xFFF0F0EA) : const Color(0xFFE8C030),
        line: 0.4,
      )
      ..line(
        Offset(p.dx - w * 0.6, p.dy + w * 0.35),
        Offset(p.dx + w * 0.6, p.dy + w * 0.35),
        const Color(0xFF6A5A30),
        width: 0.5,
      );
  }
  // A filing cabinet on the right.
  room.box(a.r(0.86, 0.36, 0.1, 0.36), const Color(0xFF8A9090), depth: 0.1);
  for (var k = 1; k < 4; k++) {
    a.hairline(
      a.p(0.86, 0.36 + k * 0.09),
      a.p(0.96, 0.36 + k * 0.09),
      const Color(0x66000000),
      0.4,
    );
  }
  // The table, the map of the city on it, a phone at its corner.
  room.box(a.r(0.24, 0.74, 0.52, 0.04), const Color(0xFF9A8460), depth: 0.38);
  for (final x in [0.25, 0.73]) {
    room.box(
      a.r(x, 0.78, 0.02, 0.18),
      const Color(0xFF6A6460),
      depth: 0.02,
      line: 0.3,
    );
  }
  final map = a.poly([
    a.p(0.3, 0.72),
    a.p(0.7, 0.72),
    a.p(0.66, 0.58),
    a.p(0.34, 0.58),
  ]);
  a.path(map, const Color(0xFFE8E0CA), line: 0.4);
  for (var k = 1; k < 8; k++) {
    final t = k / 8;
    a.hairline(
      Offset.lerp(a.p(0.3, 0.72), a.p(0.7, 0.72), t)!,
      Offset.lerp(a.p(0.34, 0.58), a.p(0.66, 0.58), t)!,
      const Color(0x664A4030),
      0.3,
    );
  }
  for (var k = 1; k < 6; k++) {
    final t = k / 6;
    final y = 0.58 + 0.14 * t;
    final inset = 0.04 * (1 - t);
    a.hairline(
      a.p(0.3 + inset, y),
      a.p(0.7 - inset, y),
      const Color(0x664A4030),
      0.3,
    );
  }
  a.path(
    a.poly([a.p(0.7, 0.62), a.p(0.76, 0.62), a.p(0.77, 0.66), a.p(0.69, 0.66)]),
    const Color(0xFF3A3A3A),
    line: 0.3,
  );
}

/// The finds room: racks of trays on the left, the long table with its
/// papers and a cloth for the tile, a pinboard on the right.
void _finds(Art a) {
  final room = Room(a, back: a.r(0.22, 0.06, 0.58, 0.5));
  final back = room.back;
  a
    ..path(room.ceiling, const Color(0xFFBCB8AC), line: 0)
    ..path(room.leftWall, const Color(0xFFB0AC9E), line: 0)
    ..path(room.rightWall, const Color(0xFFB8B4A6), line: 0)
    ..fill(back, const Color(0xFFC4C0B2))
    ..path(room.floor, const Color(0xFF5E625A), line: 0);
  room
    ..floorGrid(const Color(0x44202420), rows: 6, columns: 8)
    ..shadeCorners(strength: 0.35);
  for (final (p, q) in [
    (back.topLeft, Offset.zero),
    (back.topRight, Offset(a.size.width, 0)),
    (back.bottomLeft, Offset(0, a.size.height)),
    (back.bottomRight, Offset(a.size.width, a.size.height)),
  ]) {
    a.line(p, q, const Color(0x66302C28), width: 0.4);
  }
  a
    ..path(
      a.poly([
        a.p(0.38, 0.03),
        a.p(0.62, 0.03),
        a.p(0.6, 0.05),
        a.p(0.4, 0.05),
      ]),
      const Color(0xFFF4F4EC),
      line: 0.3,
    )
    ..glow(
      a.p(0.5, 0.06),
      a.size.width * 0.4,
      const Color(0xFFF0F4EC),
      strength: 0.22,
    );
  // Shelves of bagged finds along the back wall.
  for (var k = 0; k < 3; k++) {
    final y = back.top + back.height * (0.3 + k * 0.24);
    room.box(
      Rect.fromLTWH(
        back.left + back.width * 0.05,
        y,
        back.width * 0.5,
        a.u * 0.6,
      ),
      const Color(0xFF8A7A5A),
      depth: 0.04,
      shadow: false,
      line: 0.3,
    );
    for (var j = 0; j < 7; j++) {
      a.box(
        Rect.fromLTWH(
          back.left + back.width * (0.07 + j * 0.068),
          y - a.u * 3,
          back.width * 0.055,
          a.u * 3,
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
  // The racks of trays on the left, close.
  final rack = a.r(0.03, 0.2, 0.24, 0.5);
  room.box(rack, const Color(0xFF7A7E80), depth: 0.12);
  for (var k = 0; k < 5; k++) {
    final tray = Rect.fromLTWH(
      rack.left + a.u,
      rack.top + rack.height * (0.04 + k * 0.19),
      rack.width - a.u * 2,
      rack.height * 0.15,
    );
    a.box(tray, const Color(0xFFD8D2C2), line: 0.3);
    final random = math.Random(k);
    for (var j = 0; j < 7; j++) {
      final p = Offset(
        tray.left + tray.width * (0.08 + j * 0.13),
        tray.top + tray.height * (0.4 + random.nextDouble() * 0.3),
      );
      a.path(
        a.poly([
          p,
          p.translate(a.u * 1.6, -a.u * 0.4),
          p.translate(a.u * 1.8, a.u * 0.8),
          p.translate(a.u * 0.2, a.u * 0.9),
        ]),
        j.isEven ? _tileBurnt : const Color(0xFF5A5A5E),
        line: 0.2,
      );
    }
  }
  // The pinboard on the right of the back wall, empty pins for now.
  final pin = a.r(0.72, 0.2, 0.2, 0.22);
  room.box(pin, const Color(0xFFA08A64), depth: 0.02, shadow: false);
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
  // The long table, a lamp over it.
  room.box(a.r(0.26, 0.68, 0.58, 0.04), const Color(0xFFD8D4C8), depth: 0.42);
  for (final x in [0.27, 0.81]) {
    room.box(
      a.r(x, 0.72, 0.02, 0.22),
      const Color(0xFF6A6A66),
      depth: 0.02,
      line: 0.3,
    );
  }
  // The chronicle, a cloth laid ready for the tile, a cleared space by the
  // brush and tags where the letter will lie.
  _sheaf(a, a.r(0.33, 0.585, 0.13, 0.075), angle: -0.04);
  a.path(
    a.poly([a.p(0.5, 0.64), a.p(0.62, 0.64), a.p(0.61, 0.55), a.p(0.51, 0.55)]),
    const Color(0xFFEAE6DA),
    line: 0.3,
  );
  a.glow(a.p(0.55, 0.6), a.size.width * 0.3, _lamp, strength: 0.14);
}

/// Today's Honnō-ji at Teramachi: the court of grey gravel, the paved path
/// to the main hall, the memorial tower on the left, a leaflet rack, and a
/// guide's flag across the court.
void _teramachi(Art a) {
  final room = Room(a, back: a.r(0.08, 0.0, 0.84, 0.52), vp: a.p(0.5, 0.36));
  final back = room.back;
  _summerSky(a, 0.52);
  // Trees of the precinct behind the hall.
  final random = math.Random(5);
  for (var i = 0; i < 14; i++) {
    a.canvas.drawCircle(
      a.p(0.04 + i * 0.07, 0.2 + random.nextDouble() * 0.08),
      a.u * (6 + random.nextDouble() * 5),
      Paint()
        ..color = Color.lerp(
          const Color(0xFF3E5A3A),
          const Color(0xFF5A7048),
          random.nextDouble(),
        )!,
    );
  }
  // The court: gravel, raked in lines, a paved path to the hall.
  a.fill(a.r(0, 0.5, 1, 0.5), _gravel);
  for (var k = 1; k < 14; k++) {
    final z = k / 14;
    a.hairline(
      room.floorAt(0, z),
      room.floorAt(1, z),
      const Color(0x22000000),
      0.3,
    );
  }
  a.path(
    a.poly([
      room.floorAt(0.42, 0),
      room.floorAt(0.58, 0),
      room.floorAt(0.53, 1),
      room.floorAt(0.47, 1),
    ]),
    const Color(0xFFA8A496),
    line: 0.3,
  );
  for (var k = 1; k < 10; k++) {
    final z = k / 10;
    a.hairline(
      room.floorAt(0.42 + 0.05 * z, z),
      room.floorAt(0.58 - 0.05 * z, z),
      const Color(0x44000000),
      0.3,
    );
  }
  // A low wall along the back, white plaster over stone.
  a
    ..fill(
      Rect.fromLTRB(0, back.bottom - a.u * 5, a.size.width, back.bottom),
      const Color(0xFFE6E2D6),
    )
    ..fill(
      Rect.fromLTRB(
        0,
        back.bottom - a.u * 5,
        a.size.width,
        back.bottom - a.u * 4.2,
      ),
      _tile,
    )
    ..line(
      Offset(0, back.bottom),
      Offset(a.size.width, back.bottom),
      const Color(0x66000000),
      width: 0.4,
    );
  // The main hall: a raised floor, posts, the great roof.
  final hall = a.r(0.36, 0.3, 0.28, 0.22);
  room.box(
    Rect.fromLTWH(
      hall.left - a.u,
      hall.bottom - a.u * 2,
      hall.width + a.u * 2,
      a.u * 2,
    ),
    const Color(0xFF9A968A),
    depth: 0.06,
  );
  a.fill(
    Rect.fromLTRB(hall.left, hall.top, hall.right, hall.bottom - a.u * 2),
    const Color(0xFF3A2A1E),
  );
  for (var k = 0; k <= 6; k++) {
    final x = hall.left + hall.width * k / 6;
    a.box(
      Rect.fromLTWH(x - a.u * 0.5, hall.top, a.u, hall.height - a.u * 2),
      _cedar,
      line: 0.3,
    );
  }
  // Paper-screened doors, warm inside.
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
  _roof(a, a.r(0.3, 0.1, 0.4, 0.22));
  // Steps up to the hall.
  for (var k = 0; k < 3; k++) {
    room.box(
      a.r(0.44 - k * 0.01, 0.52 + k * 0.012, 0.12 + k * 0.02, 0.012),
      const Color(0xFFA8A496),
      depth: 0.04,
      shadow: false,
      line: 0.25,
    );
  }
  // A stone lantern on either side of the path.
  for (final x in [0.3, 0.66]) {
    final base = a.r(x, 0.56, 0.04, 0.12);
    room.box(
      Rect.fromLTWH(
        base.left + base.width * 0.35,
        base.top + base.height * 0.4,
        base.width * 0.3,
        base.height * 0.6,
      ),
      _granite,
      depth: 0.03,
    );
    room.box(
      Rect.fromLTWH(
        base.left + base.width * 0.15,
        base.top + base.height * 0.16,
        base.width * 0.7,
        base.height * 0.24,
      ),
      const Color(0xFF9A9C9E),
      depth: 0.03,
      shadow: false,
    );
    a.path(
      a.poly([
        Offset(base.left, base.top + base.height * 0.16),
        Offset(base.center.dx, base.top),
        Offset(base.right, base.top + base.height * 0.16),
      ]),
      const Color(0xFF7E8084),
      line: 0.3,
    );
  }
  // The memorial tower, an incense stand and flowers before it.
  _tower(a, room, a.r(0.1, 0.26, 0.14, 0.48));
  room.box(a.r(0.13, 0.76, 0.08, 0.04), const Color(0xFF6A5A48), depth: 0.06);
  for (final x in [0.135, 0.205]) {
    a
      ..line(a.p(x, 0.76), a.p(x, 0.71), const Color(0xFF3A5A30), width: 0.4)
      ..circle(a.p(x, 0.705), a.u * 0.9, const Color(0xFFE8E0D0), line: 0.2);
  }
  // The leaflet rack at the right front.
  final rack = a.r(0.73, 0.62, 0.1, 0.1);
  room.box(rack, const Color(0xFF6A4E36), depth: 0.08);
  for (var k = 0; k < 3; k++) {
    a.paper(
      Rect.fromLTWH(
        rack.left + rack.width * (0.08 + k * 0.3),
        rack.top - rack.height * 0.3,
        rack.width * 0.26,
        rack.height * 0.5,
      ),
      lines: 3,
      color: const Color(0xFFF2EEE2),
    );
  }
  room.box(
    a.r(0.735, 0.72, 0.012, 0.1),
    const Color(0xFF4A3A2A),
    depth: 0.02,
    line: 0.3,
  );
  room.box(
    a.r(0.808, 0.72, 0.012, 0.1),
    const Color(0xFF4A3A2A),
    depth: 0.02,
    line: 0.3,
  );
  // A guide's flag on its pole across the court, no one holding it.
  a
    ..line(
      a.p(0.88, 0.54),
      a.p(0.88, 0.34),
      const Color(0xFF4A4A48),
      width: 0.5,
    )
    ..path(
      a.poly([a.p(0.88, 0.35), a.p(0.94, 0.37), a.p(0.88, 0.4)]),
      const Color(0xFFD0A030),
      line: 0.3,
    );
  room.contactShadow(
    Rect.fromCenter(center: a.p(0.88, 0.54), width: a.u * 4, height: a.u),
  );
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
  _tileFace(a, c, r);
}

/// Fróis's letter, folded, a line of Portuguese hand.
void _letter(Art a) {
  a
    ..paper(
      a.r(0.08, 0.12, 0.84, 0.76),
      lines: 7,
      angle: 0.03,
      color: const Color(0xFFE8DCBA),
      ink: 0.6,
    )
    ..hairline(a.p(0.5, 0.12), a.p(0.52, 0.88), const Color(0x44000000), 0.3)
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
