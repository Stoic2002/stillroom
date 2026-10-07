import 'dart:math' as math;
import 'dart:ui';

import '../theme/stillroom_palette.dart';
import 'art_kit.dart';
import 'depth_kit.dart';
import 'echo_art.dart';
import 'whitechapel_1888_art.dart' show jarLabelBoard;

/// Code-drawn art for "Borobudur, 1814" (docs/episodes/borobudur_1814.md):
/// the monument in 1890–91, cleared but not yet restored, a stretch of the
/// casing at its foot taken down for the hidden reliefs to be
/// photographed. The foot, a gallery of the first terrace, the round
/// terraces with their latticed stupas, and the rest house below. Each
/// scene from one camera (`depth_kit.dart`).
const _s = 'images/scenes/borobudur_1814';
const _o = 'images/objects/borobudur_1814';

final Map<String, ArtPainter> borobudur1814Art = {
  // Scenes and puzzle boards.
  '$_s/foot.png': (c, s) => _foot(Art(c, s)),
  '$_s/gallery.png': (c, s) => _gallery(Art(c, s)),
  '$_s/stupas.png': (c, s) => _stupas(Art(c, s)),
  '$_s/house.png': (c, s) => _house(Art(c, s)),
  '$_s/mudra_board.png': (c, s) => _stoneBoard(Art(c, s)),
  '$_s/casing_board.png': (c, s) => _stoneBoard(Art(c, s)),
  '$_s/label_close.png': (c, s) => jarLabelBoard(Art(c, s), _stone),
  // Objects.
  '$_o/papers_sprite.png': (c, s) => _flatPapers(Art(c, s)),
  '$_o/later_sprite.png': (c, s) => _papers(Art(c, s), 3),
  '$_o/echo_pilgrim.png': (c, s) => paintEcho(Art(c, s), EchoFigure.pilgrim),
  '$_o/echo_carrier.png': (c, s) => paintEcho(Art(c, s), EchoFigure.carrier),
  // The jar on the shelf.
  'images/ui/jar_borobudur_1814.png': (c, s) => _jar(Art(c, s)),
};

// ---------------------------------------------------------------------------
// Palette

const _skyHigh = Color(0xFF7A9AB4);
const _skyLow = Color(0xFFF0DCC0);
const _stone = Color(0xFF7A7670);
const _stoneDark = Color(0xFF5A5650);
const _stoneLight = Color(0xFF9A968E);
const _moss = Color(0xFF5A6A3E);
const _grass = Color(0xFF6E8A48);
const _hills = Color(0xFF5A7A6A);
const _plaster = Color(0xFFE8E2D4);
const _teak = Color(0xFF7A5232);
const _paper = Color(0xFFE6DCC0);
const _lamp = StillroomPalette.gaslight;

// ---------------------------------------------------------------------------
// Shared pieces

/// A morning sky over Java, the volcanoes on the horizon, Merapi smoking.
void _javaSky(Art a, double horizon) {
  a
    ..fade(a.r(0, 0, 1, horizon), _skyHigh, _skyLow)
    ..glow(
      a.p(0.85, horizon * 0.8),
      a.size.width * 0.3,
      const Color(0xFFFFE6B0),
      strength: 0.35,
    );
  final volcano = Path()
    ..moveTo(a.size.width * 0.55, a.size.height * horizon)
    ..lineTo(a.size.width * 0.72, a.size.height * (horizon - 0.13))
    ..lineTo(a.size.width * 0.76, a.size.height * (horizon - 0.13))
    ..lineTo(a.size.width * 0.95, a.size.height * horizon)
    ..close();
  a.path(volcano, const Color(0xFF7A8A9A), line: 0);
  for (var i = 0; i < 3; i++) {
    a.canvas.drawCircle(
      a.p(0.74 + i * 0.02, horizon - 0.16 - i * 0.04),
      a.u * (3 + i * 1.5),
      Paint()
        ..color = const Color(0x44E8E8E4)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, a.u * 1.5),
    );
  }
  a.path(
    a.poly([
      a.p(0, horizon),
      a.p(0.2, horizon - 0.05),
      a.p(0.42, horizon - 0.02),
      a.p(0.55, horizon),
    ]),
    const Color(0xFF8A9AA4),
    line: 0,
  );
}

/// A band of relief panels on a front face [face]: frames, and low
/// figures in each, worn.
void _reliefBand(Art a, Rect face, {int panels = 8, int seed = 1}) {
  final random = math.Random(seed);
  final w = face.width / panels;
  for (var k = 0; k < panels; k++) {
    final p = Rect.fromLTWH(
      face.left + k * w + 1,
      face.top + 1,
      w - 2,
      face.height - 2,
    );
    a
      ..fill(p, _stoneDark)
      ..ink(p, width: 0.25);
    for (var f = 0; f < 3; f++) {
      final x = p.left + p.width * (0.2 + f * 0.3);
      final h = p.height * (0.5 + random.nextDouble() * 0.2);
      a
        ..fill(
          Rect.fromLTWH(
            x - p.width * 0.05,
            p.bottom - h,
            p.width * 0.1,
            h * 0.8,
          ),
          _stoneLight,
        )
        ..canvas.drawCircle(
          Offset(x, p.bottom - h - p.width * 0.04),
          p.width * 0.05,
          Paint()..color = _stoneLight,
        );
    }
  }
}

/// A bell-shaped stupa with a latticed body, standing at [x], [z], [w]
/// across, on its square base, its spire on top.
void _bellStupa(
  Room room,
  double x,
  double z,
  double w, {
  bool latticed = true,
}) {
  final a = room.a;
  room.shadow(
    x - w * 0.55,
    x + w * 0.55,
    z - w * 0.4,
    z + w * 0.4,
    strength: 0.35,
    spread: 0.1,
  );
  room.block(
    x - w * 0.55,
    x + w * 0.55,
    0,
    w * 0.12,
    z - w * 0.45,
    z + w * 0.45,
    _stone,
    line: 0.3,
  );
  final foot = room.at(x, w * 0.12, z);
  final half = (room.at(x + w / 2, 0, z).dx - room.at(x, 0, z).dx).abs();
  final h = half * 2.2;
  final bell = Path()
    ..moveTo(foot.dx - half, foot.dy)
    ..cubicTo(
      foot.dx - half,
      foot.dy - h * 0.9,
      foot.dx - half * 0.3,
      foot.dy - h,
      foot.dx,
      foot.dy - h,
    )
    ..cubicTo(
      foot.dx + half * 0.3,
      foot.dy - h,
      foot.dx + half,
      foot.dy - h * 0.9,
      foot.dx + half,
      foot.dy,
    )
    ..close();
  final bounds = bell.getBounds();
  a.canvas.drawPath(
    bell,
    Paint()
      ..shader = Gradient.linear(
        bounds.centerLeft,
        bounds.centerRight,
        [_stoneDark, _stoneLight, _stone, _stoneDark],
        [0, 0.35, 0.6, 1],
      ),
  );
  a.strokePath(bell, Art.outline, width: 0.4);
  if (latticed) {
    a.canvas
      ..save()
      ..clipPath(bell);
    final d = half * 0.28;
    for (var row = 0; row < 4; row++) {
      final y = foot.dy - h * (0.15 + row * 0.17);
      for (var col = -3; col <= 3; col++) {
        final c = Offset(
          foot.dx + col * d * 1.2 + (row.isOdd ? d * 0.6 : 0),
          y,
        );
        a.path(
          a.poly([
            c.translate(0, -d * 0.45),
            c.translate(d * 0.32, 0),
            c.translate(0, d * 0.45),
            c.translate(-d * 0.32, 0),
          ]),
          const Color(0xFF2A2824),
          line: 0,
        );
      }
    }
    a.canvas.restore();
  }
  // The spire.
  final top = foot.translate(0, -h);
  a
    ..box(
      Rect.fromCenter(
        center: top.translate(0, -half * 0.12),
        width: half * 0.4,
        height: half * 0.24,
      ),
      _stone,
      line: 0.3,
    )
    ..path(
      a.poly([
        top.translate(-half * 0.12, -half * 0.24),
        top.translate(half * 0.12, -half * 0.24),
        top.translate(0, -half * 0.75),
      ]),
      _stone,
      line: 0.3,
    );
}

/// A seated Buddha in a niche or on the floor at a point, [h] tall: a
/// grey silhouette, hands in the lap.
void _seatedBuddha(Art a, Offset base, double h, {Color color = _stoneLight}) {
  final w = h * 0.8;
  a
    ..oval(
      Rect.fromCenter(
        center: base.translate(0, -h * 0.12),
        width: w,
        height: h * 0.24,
      ),
      color,
      line: 0.3,
    )
    ..path(
      a.poly([
        base.translate(-w * 0.25, -h * 0.2),
        base.translate(-w * 0.18, -h * 0.66),
        base.translate(w * 0.18, -h * 0.66),
        base.translate(w * 0.25, -h * 0.2),
      ]),
      color,
      line: 0.3,
    )
    ..circle(base.translate(0, -h * 0.78), h * 0.12, color, line: 0.3)
    ..circle(base.translate(0, -h * 0.93), h * 0.05, color, line: 0.2);
}

// ---------------------------------------------------------------------------
// Scenes

/// The foot of the monument: its terraces rising in front, the east
/// stairway up the middle under a kala gate; to the right a stretch of
/// the casing taken down, the carved base behind it showing, the casing
/// stones numbered in rows on the grass; Cephas's camera on its tripod.
void _foot(Art a) {
  final room = Room(a, vp: a.p(0.5, 0.36), depth: 0.3);
  _javaSky(a, 0.38);
  // The grass round the foot.
  a.fill(
    Rect.fromLTRB(0, room.at(0, 0, 1.6).dy, a.size.width, a.size.height),
    _grass,
  );
  // The terraces, from the top down, each set back further.
  for (var k = 5; k >= 0; k--) {
    final inset = k * 0.16;
    final z0 = 0.62 + k * 0.12;
    final y0 = k * 0.17;
    room.block(
      -1.2 + inset,
      2.2 - inset,
      y0,
      y0 + 0.17,
      z0,
      z0 + 0.4,
      k.isEven ? _stone : const Color(0xFF726E68),
      line: 0.4,
    );
    final face = Rect.fromPoints(
      room.at(-1.2 + inset, y0 + 0.15, z0),
      room.at(2.2 - inset, y0 + 0.03, z0),
    );
    _reliefBand(a, face, panels: 18 - k * 2, seed: k);
  }
  // The round terraces and the great stupa just showing above.
  for (var k = 0; k < 7; k++) {
    final top = room.at(-0.15 + k * 0.22, 1.02, 1.6);
    a.path(
      Path()
        ..moveTo(top.dx - a.u * 2.2, top.dy + a.u * 2)
        ..quadraticBezierTo(
          top.dx,
          top.dy - a.u * 3,
          top.dx + a.u * 2.2,
          top.dy + a.u * 2,
        )
        ..close(),
      _stone,
      line: 0.3,
    );
  }
  final great = room.at(0.5, 1.08, 1.7);
  a.path(
    Path()
      ..moveTo(great.dx - a.u * 6, great.dy + a.u * 3)
      ..quadraticBezierTo(
        great.dx,
        great.dy - a.u * 8,
        great.dx + a.u * 6,
        great.dy + a.u * 3,
      )
      ..close(),
    _stoneLight,
    line: 0.4,
  );
  // The east stairway up the middle, its kala gate.
  for (var k = 0; k < 6; k++) {
    room.block(
      0.4,
      0.6,
      k * 0.17,
      k * 0.17 + 0.17,
      0.5 + k * 0.12,
      0.62 + k * 0.12,
      const Color(0xFF8A867E),
      line: 0.3,
    );
    for (var s = 1; s < 4; s++) {
      a.hairline(
        room.at(0.4, k * 0.17 + s * 0.043, 0.5 + k * 0.12),
        room.at(0.6, k * 0.17 + s * 0.043, 0.5 + k * 0.12),
        const Color(0x55000000),
        0.3,
      );
    }
  }
  final gate = Rect.fromPoints(
    room.at(0.42, 0.3, 0.5),
    room.at(0.58, 0.17, 0.5),
  );
  a
    ..box(
      Rect.fromLTRB(
        gate.left - a.u,
        gate.top - a.u * 2.5,
        gate.right + a.u,
        gate.top,
      ),
      _stoneDark,
      line: 0.4,
    )
    ..circle(
      Offset(gate.center.dx, gate.top - a.u * 1.2),
      a.u * 1.2,
      _stoneLight,
      line: 0.3,
    );
  // To the right, the casing taken down: the older base carved behind.
  final opened = Rect.fromPoints(
    room.at(0.95, 0.15, 0.62),
    room.at(1.7, 0.0, 0.62),
  );
  a.fill(opened, const Color(0xFF4A4640));
  _reliefBand(a, opened.deflate(a.u * 0.3), panels: 5, seed: 9);
  // The casing stones in numbered rows on the grass.
  for (var row = 0; row < 3; row++) {
    for (var k = 0; k < 6; k++) {
      final x = 0.85 + k * 0.12;
      final z = 0.3 + row * 0.08;
      room.shadow(x, x + 0.08, z, z + 0.05, strength: 0.35, spread: 0.1);
      final f = room.block(
        x,
        x + 0.08,
        0,
        0.04,
        z,
        z + 0.05,
        const Color(0xFF6A6660),
        line: 0.3,
      );
      a.hairline(
        f.center.translate(-a.u * 0.4, 0),
        f.center.translate(a.u * 0.4, 0),
        const Color(0xCCE8E4DA),
        0.4,
      );
    }
  }
  // Cephas's camera on its tripod under a black cloth.
  final foot = room.floorAt(0.7, 0.18);
  final top = room.at(0.7, 0.32, 0.18);
  for (final dx in [-1.0, 0.0, 1.0]) {
    a.line(
      top,
      foot.translate(dx * a.u * 4, dx == 0 ? -a.u : 0),
      const Color(0xFF3A2A1A),
      width: 0.6,
    );
  }
  room.footShadow(0.7, 0.18, 0.06);
  a
    ..box(
      Rect.fromCenter(
        center: top.translate(0, -a.u * 2),
        width: a.u * 5,
        height: a.u * 4,
      ),
      const Color(0xFF5A3E26),
      line: 0.4,
    )
    ..circle(
      top.translate(a.u * 2.8, -a.u * 2),
      a.u * 1,
      const Color(0xFF2A2A2A),
      line: 0.3,
    )
    ..path(
      a.poly([
        top.translate(-a.u * 2.5, -a.u * 4),
        top.translate(a.u * 1, -a.u * 4.4),
        top.translate(a.u * 0.4, a.u * 2.4),
        top.translate(-a.u * 3.2, a.u * 2.2),
      ]),
      const Color(0xFF1E1E22),
      line: 0.3,
    );
  // The path down to the rest house, bottom left.
  a.path(
    a.poly([
      room.floorAt(-0.3, 0),
      room.floorAt(0.05, 0),
      room.floorAt(0.0, 0.45),
      room.floorAt(-0.12, 0.45),
    ]),
    const Color(0xFFB8A27A),
    line: 0,
  );
}

/// A gallery of the first terrace: the relief wall on the left, the
/// balustrade on the right with niches and their Buddhas along its top,
/// the stone floor, fallen Buddhas on it; at the far end the stairs up.
void _gallery(Art a) {
  final room = Room(a, vp: a.p(0.5, 0.36), depth: 0.4);
  final back = room.back;
  _javaSky(a, 0.45);
  // The relief wall, the left wall of the corridor, full height.
  a.path(room.leftWall, _stone, line: 0);
  for (var row = 0; row < 3; row++) {
    final y0 = 0.15 + row * 0.27;
    for (var k = 0; k < 8; k++) {
      final z0 = k / 8;
      final panel = a.poly([
        room.at(0, y0 + 0.22, z0 + 0.01),
        room.at(0, y0 + 0.22, z0 + 0.115),
        room.at(0, y0, z0 + 0.115),
        room.at(0, y0, z0 + 0.01),
      ]);
      a.path(panel, _stoneDark, line: 0.3);
      final c = room.at(0, y0 + 0.1, z0 + 0.06);
      final s = a.u * 3 * room.scaleAt(z0);
      a
        ..circle(c.translate(0, -s * 0.6), s * 0.25, _stoneLight, line: 0)
        ..fill(
          Rect.fromCenter(
            center: c.translate(0, s * 0.2),
            width: s * 0.4,
            height: s,
          ),
          _stoneLight,
        );
    }
  }
  // The floor, its paving.
  a.path(room.floor, const Color(0xFF6A665E), line: 0);
  room.floorGrid(const Color(0x44000000), rows: 8, columns: 4);
  // The balustrade on the right: lower, with niches along its top.
  a.path(
    a.poly([
      room.at(1, 0, 0),
      room.at(1, 0.5, 0),
      room.at(1, 0.5, 1),
      room.at(1, 0, 1),
    ]),
    const Color(0xFF7E7A72),
    line: 0.3,
  );
  for (var k = 0; k < 5; k++) {
    final z0 = 0.05 + k * 0.19;
    final niche = a.poly([
      room.at(1, 0.78, z0),
      room.at(1, 0.78, z0 + 0.12),
      room.at(1, 0.5, z0 + 0.12),
      room.at(1, 0.5, z0),
    ]);
    a.path(niche, const Color(0xFF3A3632), line: 0.3);
    _seatedBuddha(
      a,
      room.at(0.97, 0.5, z0 + 0.06),
      a.size.height * 0.26 * room.scaleAt(z0 + 0.06),
    );
    a.path(
      a.poly([
        room.at(1, 0.78, z0 - 0.01),
        room.at(1, 0.78, z0 + 0.13),
        room.at(1, 0.9, z0 + 0.06),
      ]),
      _stone,
      line: 0.3,
    );
  }
  // The far end: the corner, the stairs going up.
  a.fill(
    Rect.fromLTRB(
      back.left,
      back.top + back.height * 0.5,
      back.right,
      back.bottom,
    ),
    _stone,
  );
  for (var s = 0; s < 6; s++) {
    room.block(
      0.36,
      0.64,
      s * 0.05,
      s * 0.05 + 0.05,
      0.86 + s * 0.02,
      0.88 + s * 0.02,
      const Color(0xFF8A867E),
      line: 0.25,
    );
  }
  a
    ..line(
      room.at(0, 0, 0),
      room.at(0, 0, 1),
      const Color(0x66302C28),
      width: 0.4,
    )
    ..line(
      room.at(1, 0, 0),
      room.at(1, 0, 1),
      const Color(0x66302C28),
      width: 0.4,
    );
  // Fallen Buddhas on the floor, one on its side, one without its head.
  for (final (x, z, lie) in [
    (0.28, 0.3, false),
    (0.52, 0.42, true),
    (0.7, 0.24, false),
    (0.4, 0.58, false),
  ]) {
    room.shadow(
      x - 0.06,
      x + 0.06,
      z - 0.04,
      z + 0.04,
      strength: 0.4,
      spread: 0.1,
    );
    final base = room.floorAt(x, z);
    final h = a.size.height * 0.24 * room.scaleAt(z);
    if (lie) {
      a.canvas
        ..save()
        ..translate(base.dx, base.dy)
        ..rotate(-math.pi / 2)
        ..translate(-base.dx, -base.dy);
      _seatedBuddha(a, base.translate(0, h * 0.4), h);
      a.canvas.restore();
    } else {
      _seatedBuddha(a, base, h);
    }
  }
  // A guide's note on a stand by the corridor's mouth.
  room
    ..footShadow(0.12, 0.1, 0.02)
    ..block(0.1, 0.13, 0, 0.32, 0.09, 0.11, _teak, line: 0.3);
  a.paper(
    Rect.fromPoints(room.at(0.06, 0.48, 0.09), room.at(0.18, 0.32, 0.09)),
    lines: 4,
    color: _paper,
  );
  // Moss in the joints.
  final random = math.Random(4);
  for (var i = 0; i < 30; i++) {
    a.circle(
      room.floorAt(random.nextDouble(), random.nextDouble() * 0.9),
      a.u * 0.4,
      _moss,
      line: 0,
    );
  }
}

/// The round terraces: rings of latticed stupas curving away, the great
/// stupa above, the Kedu plain and Merapi beyond.
void _stupas(Art a) {
  final room = Room(a, vp: a.p(0.5, 0.42), depth: 0.3);
  _javaSky(a, 0.46);
  a
    ..fade(a.r(0, 0.42, 1, 0.2), _hills, const Color(0xFF6A8A5A))
    ..fill(
      Rect.fromLTRB(0, room.at(0, 0, 1.2).dy, a.size.width, a.size.height),
      _stone,
    );
  room.floorGrid(
    const Color(0x33000000),
    rows: 7,
    columns: 12,
    x0: -1.5,
    x1: 2.5,
    z1: 1.2,
  );
  // The great stupa behind and above.
  final g = room.at(0.5, 0.25, 1.5);
  final gw = a.size.width * 0.16;
  a.path(
    Path()
      ..moveTo(g.dx - gw, g.dy)
      ..cubicTo(
        g.dx - gw,
        g.dy - gw * 0.9,
        g.dx - gw * 0.3,
        g.dy - gw * 1.05,
        g.dx,
        g.dy - gw * 1.05,
      )
      ..cubicTo(
        g.dx + gw * 0.3,
        g.dy - gw * 1.05,
        g.dx + gw,
        g.dy - gw * 0.9,
        g.dx + gw,
        g.dy,
      )
      ..close(),
    _stoneLight,
    line: 0.5,
  );
  a.path(
    a.poly([
      g.translate(-gw * 0.1, -gw * 1.05),
      g.translate(gw * 0.1, -gw * 1.05),
      g.translate(0, -gw * 1.5),
    ]),
    _stone,
    line: 0.4,
  );
  // Rings of stupas, far ring first.
  for (final (z, count, w) in [
    (1.0, 9, 0.16),
    (0.72, 7, 0.2),
    (0.42, 5, 0.26),
  ]) {
    for (var k = 0; k < count; k++) {
      final t = k / (count - 1);
      final x = -0.9 + t * 2.8;
      final dz = 0.12 * math.pow(2 * t - 1, 2);
      _bellStupa(room, x, z + dz - 0.06, w);
    }
  }
}

/// The rest house below the hill: white walls, a teak floor, a window on
/// the monument, a table with the papers and a lamp, a shelf of boxed
/// glass plates, a bundle of palm leaves.
void _house(Art a) {
  final room = Room(a, vp: a.p(0.5, 0.24), depth: 0.55);
  final back = room.back;
  a
    ..path(room.ceiling, const Color(0xFFD8D0C0), line: 0)
    ..path(room.leftWall, _plaster, line: 0)
    ..path(room.rightWall, const Color(0xFFE2DCCC), line: 0)
    ..fill(back, const Color(0xFFEAE4D6))
    ..path(room.floor, _teak, line: 0);
  room
    ..floorGrid(const Color(0x33201008), rows: 0, columns: 12)
    ..shadeCorners(strength: 0.3)
    ..edges(const Color(0x66302C28), width: 0.4);
  // A wainscot along the walls.
  for (final x in [0.0, 1.0]) {
    a.line(
      room.at(x, 0.3, 0),
      room.at(x, 0.3, 1),
      const Color(0x55302010),
      width: 0.4,
    );
  }
  a.line(
    room.at(0, 0.3, 1),
    room.at(1, 0.3, 1),
    const Color(0x55302010),
    width: 0.4,
  );
  // The window on the back wall: the monument on its hill.
  final win = Rect.fromPoints(room.at(0.34, 0.85, 1), room.at(0.66, 0.42, 1));
  room.recess(win, const Color(0xFFEAE4D6), thickness: 0.04);
  final glass = Room.recessInner(win, thickness: 0.04);
  a.fade(glass, _skyHigh, _skyLow);
  final hill = glass.bottomCenter;
  a.path(
    a.poly([
      Offset(glass.left, glass.bottom),
      hill.translate(-glass.width * 0.32, -glass.height * 0.2),
      hill.translate(-glass.width * 0.2, -glass.height * 0.32),
      hill.translate(-glass.width * 0.08, -glass.height * 0.42),
      hill.translate(0, -glass.height * 0.5),
      hill.translate(glass.width * 0.08, -glass.height * 0.42),
      hill.translate(glass.width * 0.2, -glass.height * 0.32),
      hill.translate(glass.width * 0.32, -glass.height * 0.2),
      Offset(glass.right, glass.bottom),
    ]),
    const Color(0xFF6A665E),
    line: 0.3,
  );
  a
    ..ink(glass, width: 0.4)
    ..hairline(
      glass.topCenter,
      glass.bottomCenter,
      const Color(0xFF5A3E26),
      0.6,
    );
  room.beam(
    [glass.bottomLeft, glass.bottomRight],
    [
      room.floorAt(0.3, 0.6),
      room.floorAt(0.7, 0.6),
      room.floorAt(0.74, 0.32),
      room.floorAt(0.26, 0.32),
    ],
    const Color(0xFFFFF0D0),
    strength: 0.1,
  );
  // The shelf of boxed glass plates on the right wall.
  room
    ..shadow(0.84, 0.98, 0.5, 0.74, strength: 0.35, spread: 0.06)
    ..block(0.84, 0.98, 0, 0.5, 0.5, 0.74, _teak);
  for (var s = 0; s < 3; s++) {
    for (var k = 0; k < 4; k++) {
      room.block(
        0.86,
        0.96,
        0.08 + s * 0.14,
        0.17 + s * 0.14,
        0.51 + k * 0.055,
        0.555 + k * 0.055,
        const Color(0xFF8A6A48),
        line: 0.25,
      );
    }
  }
  // The table, the lamp, the papers and the palm leaves.
  room.table(0.22, 0.74, 0.14, 0.46, 0.27, _teak, leg: 0.02);
  const y = 0.2705;
  a.path(
    a.poly([
      room.at(0.26, y, 0.2),
      room.at(0.4, y, 0.2),
      room.at(0.4, y, 0.38),
      room.at(0.26, y, 0.38),
    ]),
    const Color(0xFFE2D6B8),
    line: 0.3,
  );
  a.path(
    a.poly([
      room.at(0.44, y, 0.22),
      room.at(0.56, y, 0.22),
      room.at(0.56, y, 0.36),
      room.at(0.44, y, 0.36),
    ]),
    const Color(0xFFEDE4C8),
    line: 0.3,
  );
  for (var k = 0; k < 4; k++) {
    room.block(
      0.6,
      0.72,
      y + k * 0.006,
      y + k * 0.006 + 0.006,
      0.22 + k * 0.005,
      0.26 + k * 0.005,
      const Color(0xFFD8BE84),
      line: 0.2,
    );
  }
  final lamp = room.at(0.33, 0.36, 0.4);
  a
    ..box(
      Rect.fromCenter(center: lamp, width: a.u * 2, height: a.u * 4),
      const Color(0xFFE8E0C8),
      line: 0.3,
    )
    ..flame(lamp.translate(0, -a.u * 0.4), a.u * 1.4)
    ..glow(lamp, a.size.width * 0.25, _lamp, strength: 0.16);
}

// ---------------------------------------------------------------------------
// Puzzle boards

/// Worn grey stone, close.
void _stoneBoard(Art a) {
  a.fade(
    Offset.zero & a.size,
    const Color(0xFF3E3C38),
    const Color(0xFF26241F),
  );
  final random = math.Random(814);
  for (var i = 0; i < 120; i++) {
    a.canvas.drawCircle(
      a.p(random.nextDouble(), random.nextDouble()),
      a.u * (0.1 + random.nextDouble() * 0.4),
      Paint()..color = const Color(0x22E8E0D0),
    );
  }
}

// ---------------------------------------------------------------------------
// Objects

/// Sheets lying flat on the table, seen at a slant.
void _flatPapers(Art a) {
  for (var i = 0; i < 2; i++) {
    final x = 0.04 + i * 0.5;
    a.path(
      a.poly([
        a.p(x + 0.04, 0.08),
        a.p(x + 0.42, 0.08),
        a.p(x + 0.46, 0.92),
        a.p(x, 0.92),
      ]),
      i.isOdd ? const Color(0xFFF2F2EE) : _paper,
      line: 0.3,
    );
    for (var k = 0; k < 4; k++) {
      a.hairline(
        a.p(x + 0.08, 0.25 + k * 0.17),
        a.p(x + 0.36, 0.25 + k * 0.17),
        StillroomPalette.inkOnPaper.withValues(alpha: 0.45),
        0.3,
      );
    }
  }
}

/// Papers laid on the table, [count] sheets.
void _papers(Art a, int count) {
  for (var i = 0; i < count; i++) {
    a.paper(
      a.r(
        0.06 + i * (0.84 / count),
        0.1 + (i % 2) * 0.08,
        0.84 / count + 0.06,
        0.72,
      ),
      lines: 6,
      angle: -0.05 + i * 0.05,
      color: i.isOdd ? const Color(0xFFF2F2EE) : _paper,
      ink: 0.5,
    );
  }
}

/// The jar: the monument's silhouette on its hill at dawn, stupas on top.
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
    ..fade(a.r(0, 0.16, 1, 0.5), _skyHigh, _skyLow)
    ..glow(a.p(0.75, 0.55), w * 0.5, const Color(0xFFFFD8A0), strength: 0.45)
    ..fill(a.r(0, 0.78, 1, 0.22), _grass);
  for (var k = 0; k < 6; k++) {
    a.fill(
      a.r(0.1 + k * 0.05, 0.78 - k * 0.04, 0.8 - k * 0.1, 0.04),
      k.isEven ? _stone : _stoneDark,
    );
  }
  for (var k = 0; k < 5; k++) {
    final c = a.p(0.3 + k * 0.1, 0.54);
    a.path(
      Path()
        ..moveTo(c.dx - w * 0.04, c.dy)
        ..quadraticBezierTo(c.dx, c.dy - w * 0.08, c.dx + w * 0.04, c.dy)
        ..close(),
      _stoneLight,
      line: 0.3,
    );
  }
  a.path(
    Path()
      ..moveTo(w * 0.42, h * 0.52)
      ..quadraticBezierTo(w * 0.5, h * 0.38, w * 0.58, h * 0.52)
      ..close(),
    _stoneLight,
    line: 0.4,
  );
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
  // The lid: a bundle of palm leaves.
  for (var k = 0; k < 3; k++) {
    a.rbox(
      a.r(0.24, 0.05 + k * 0.035, 0.52, 0.03),
      a.u * 1.5,
      const Color(0xFFD8BE84),
      line: 0.3,
    );
  }
}
