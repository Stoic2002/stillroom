import 'dart:math' as math;
import 'dart:ui';

import '../theme/stillroom_palette.dart';
import 'art_kit.dart';
import 'depth_kit.dart';
import 'echo_art.dart';
import 'whitechapel_1888_art.dart' show jarLabelBoard;

/// Code-drawn art for "Alamut, 1256" (docs/episodes/alamut_1256.md): the
/// castle on its rock in the Alborz, in December 1256, given up and not
/// yet burned. A snowy court on the rock, the bare room at the top of the
/// tower, the storerooms cut into the rock, and the library.
const _s = 'images/scenes/alamut_1256';
const _o = 'images/objects/alamut_1256';

final Map<String, ArtPainter> alamut1256Art = {
  // Scenes and puzzle boards.
  '$_s/gate_court.png': (c, s) => _court(Art(c, s)),
  '$_s/tower.png': (c, s) => _tower(Art(c, s)),
  '$_s/storerooms.png': (c, s) => _storerooms(Art(c, s)),
  '$_s/library.png': (c, s) => _library(Art(c, s)),
  '$_s/quire_board.png': (c, s) => _quireBoard(Art(c, s)),
  '$_s/dip_board.png': (c, s) => _dipBoard(Art(c, s)),
  '$_s/label_close.png': (c, s) => jarLabelBoard(Art(c, s), _rockDark),
  // Objects.
  '$_o/keys_sprite.png': (c, s) => _keys(Art(c, s)),
  '$_o/tally_sprite.png': (c, s) => _tally(Art(c, s)),
  '$_o/later_sprite.png': (c, s) => _laterPaper(Art(c, s)),
  '$_o/echo_garrison.png': (c, s) => paintEcho(Art(c, s), EchoFigure.garrison),
  '$_o/echo_librarian.png': (c, s) =>
      paintEcho(Art(c, s), EchoFigure.librarian),
  // The jar on the shelf.
  'images/ui/jar_alamut_1256.png': (c, s) => _jar(Art(c, s)),
};

// ---------------------------------------------------------------------------
// Palette

const _skyHigh = Color(0xFF5E6A7C);
const _sky = Color(0xFFA8A6A6);
const _peaks = Color(0xFF7E8694);
const _peaksFar = Color(0xFF9CA2AC);
const _snow = Color(0xFFE6E7E8);
const _snowShade = Color(0xFFB8BCC2);
const _rock = Color(0xFF8A7460);
const _rockDark = Color(0xFF4E4034);
const _rockDeep = Color(0xFF2A221C);
const _plaster = Color(0xFFC8B492);
const _plasterShade = Color(0xFF9A8468);
const _brick = Color(0xFFA48666);
const _wood = Color(0xFF5A3E26);
const _woodDark = Color(0xFF3A2818);
const _field = Color(0xFF8C8672);
const _iron = Color(0xFF34302C);
const _paper = Color(0xFFE2D2AC);
const _ink = Color(0xFF3A2414);
const _carpet = Color(0xFF7A2A20);
const _carpetDark = Color(0xFF4A1812);
const _indigo = Color(0xFF2A3452);
const _lamp = StillroomPalette.gaslight;

// ---------------------------------------------------------------------------
// Shared pieces

/// A pointed arch filling [r]: straight sides up to [spring] of its height
/// from the bottom, then two arcs meeting in a point.
Path _arch(Rect r, {double spring = 0.55}) {
  final springY = r.bottom - r.height * spring;
  return Path()
    ..moveTo(r.left, r.bottom)
    ..lineTo(r.left, springY)
    ..quadraticBezierTo(r.left, r.top + r.height * 0.1, r.center.dx, r.top)
    ..quadraticBezierTo(r.right, r.top + r.height * 0.1, r.right, springY)
    ..lineTo(r.right, r.bottom)
    ..close();
}

/// Rough rock: a fill with cracks and ledges, seeded.
void _rockFace(Art a, Rect r, {Color color = _rock, int seed = 1}) {
  a.fill(r, color);
  final random = math.Random(seed);
  final dark = Color.lerp(color, Art.outline, 0.45)!;
  final light = Color.lerp(color, _snow, 0.25)!;
  for (var i = 0; i < 26; i++) {
    final start = Offset(
      r.left + random.nextDouble() * r.width,
      r.top + random.nextDouble() * r.height,
    );
    final len = r.shortestSide * (0.06 + random.nextDouble() * 0.16);
    final angle = random.nextDouble() * math.pi;
    final end = start + Offset(math.cos(angle), math.sin(angle)) * len;
    a.hairline(start, end, dark, 0.3 + random.nextDouble() * 0.3);
    if (random.nextBool()) {
      a.hairline(start.translate(0, -a.u * 0.4), end, light, 0.2);
    }
  }
}

/// Where the court's lines run to.
const _courtEye = Offset(0.5, 0.6);

/// A building's side wall turning back from its front's edge at [x]
/// ([top] to [bottom]) towards the court's vanishing point.
void _courtSide(
  Art a,
  double x,
  double top,
  double bottom,
  Color color, {
  double t = 0.2,
}) {
  final vp = a.p(_courtEye.dx, _courtEye.dy);
  final upper = a.p(x, top);
  final lower = a.p(x, bottom);
  a.path(
    a.poly([
      upper,
      Offset.lerp(upper, vp, t)!,
      Offset.lerp(lower, vp, t)!,
      lower,
    ]),
    Color.lerp(color, Art.outline, 0.32)!,
    line: 0.4,
  );
}

/// A soft shadow along a foot from [x0] to [x1] at [y].
void _footShadow(Art a, double x0, double x1, double y) => a.canvas.drawOval(
  Rect.fromLTRB(
    a.p(x0, 0).dx,
    a.p(0, y).dy - a.u * 1.2,
    a.p(x1, 0).dx,
    a.p(0, y).dy + a.u * 2.4,
  ),
  Paint()
    ..color = const Color(0x55302820)
    ..maskFilter = MaskFilter.blur(BlurStyle.normal, a.u * 1.4),
);

/// Snow falling over the picture, or [within] a window.
void _snowfall(Art a, {int count = 120, int seed = 7, Rect? within}) {
  final random = math.Random(seed);
  final area = within ?? Offset.zero & a.size;
  for (var i = 0; i < count; i++) {
    a.canvas.drawCircle(
      Offset(
        area.left + random.nextDouble() * area.width,
        area.top + random.nextDouble() * area.height,
      ),
      a.u * (0.12 + random.nextDouble() * 0.22),
      Paint()..color = _snow.withValues(alpha: 0.4 + random.nextDouble() * 0.5),
    );
  }
}

/// A range of snowy peaks along [base], rising to [top].
void _range(
  Art a,
  double base,
  double top, {
  Color color = _peaks,
  int seed = 3,
  int count = 7,
}) {
  final random = math.Random(seed);
  final w = a.size.width;
  final points = <Offset>[Offset(0, a.size.height * base)];
  for (var i = 0; i <= count; i++) {
    final x = w * i / count;
    final y =
        a.size.height *
        (top + (base - top) * (0.1 + random.nextDouble() * 0.6));
    points
      ..add(Offset(x - w / count * 0.5, y + a.size.height * 0.08))
      ..add(Offset(x, y));
  }
  points
    ..add(Offset(w, a.size.height * base))
    ..add(Offset(0, a.size.height * base));
  a.path(a.poly(points), color, line: 0);
  // Snow on every peak: a cap down each slope.
  for (var i = 2; i < points.length - 2; i += 2) {
    final peak = points[i];
    final left = points[i - 1];
    final right = points[i + 1];
    a.path(
      a.poly([
        peak,
        Offset.lerp(peak, left, 0.45)!,
        Offset.lerp(peak, Offset.lerp(left, right, 0.5)!, 0.3)!,
        Offset.lerp(peak, right, 0.4)!,
      ]),
      _snow,
      line: 0,
    );
  }
}

/// A small oil lamp of fired clay, lit, its spout at [spout].
void _oilLamp(Art a, Offset spout, double size) {
  a
    ..glow(spout, size * 5, _lamp, strength: 0.35)
    ..path(
      Path()
        ..moveTo(spout.dx - size * 1.6, spout.dy + size * 0.3)
        ..quadraticBezierTo(
          spout.dx - size * 1.2,
          spout.dy + size * 0.9,
          spout.dx - size * 0.2,
          spout.dy + size * 0.5,
        )
        ..lineTo(spout.dx + size * 0.2, spout.dy + size * 0.1)
        ..lineTo(spout.dx - size * 0.3, spout.dy)
        ..quadraticBezierTo(
          spout.dx - size * 1.4,
          spout.dy - size * 0.2,
          spout.dx - size * 1.6,
          spout.dy + size * 0.3,
        )
        ..close(),
      const Color(0xFF9A6A44),
      line: 0.3,
    )
    ..flame(spout, size * 1.3);
}

/// A book lying closed, its spine towards the viewer: [r] its outline.
void _book(Art a, Rect r, Color cover) {
  a
    ..box(r, cover, line: 0.4)
    ..fill(
      Rect.fromLTRB(
        r.left + r.width * 0.06,
        r.top,
        r.right,
        r.top + r.height * 0.3,
      ),
      _paper,
    )
    ..hairline(
      Offset(r.left + r.width * 0.06, r.top + r.height * 0.3),
      Offset(r.right, r.top + r.height * 0.3),
      Art.outline,
      0.3,
    );
}

// ---------------------------------------------------------------------------
// The court on the rock

void _court(Art a) {
  // Winter sky, the far Alborz, and the valley deep below.
  a.fade(a.r(0, 0, 1, 0.62), _skyHigh, _sky);
  _range(a, 0.46, 0.08, color: _peaksFar, seed: 11, count: 6);
  _range(a, 0.58, 0.24, seed: 12, count: 8);
  // The valley floor far down, hazed, and the army's fires on it.
  a.fade(
    a.r(0, 0.5, 1, 0.14),
    const Color(0xFF6A6E72),
    const Color(0xFF4A4C4E),
  );
  // The camp: rows of small tents, campfires among them, and smoke
  // rising thin and straight in the cold air.
  final fires = math.Random(19);
  for (var i = 0; i < 22; i++) {
    final row = fires.nextDouble();
    final p = a.p(0.39 + fires.nextDouble() * 0.21, 0.535 + row * 0.05);
    final size = a.u * (0.5 + row * 0.5);
    a.path(
      a.poly([
        p.translate(-size, 0),
        p.translate(0, -size * 1.1),
        p.translate(size, 0),
      ]),
      const Color(0xFFB8B4A8),
      line: 0.15,
    );
  }
  for (var i = 0; i < 16; i++) {
    final row = fires.nextDouble();
    final p = a.p(0.4 + fires.nextDouble() * 0.19, 0.54 + row * 0.05);
    a
      ..line(
        p.translate(0, -a.u * 0.6),
        p.translate(a.u * 0.4, -a.u * (3 + row * 2)),
        const Color(0x55C8C8C8),
        width: 0.5,
      )
      ..glow(p, a.u * (1.2 + row), const Color(0xFFE08A3A), strength: 0.6)
      ..canvas.drawCircle(
        p,
        a.u * (0.2 + row * 0.15),
        Paint()..color = const Color(0xFFFFC870),
      );
  }

  // The top of the rock behind the buildings, under snow.
  a.fade(a.r(0, 0.64, 1, 0.12), _snowShade, _snow);

  // The parapet along the edge of the rock, crenellated, snow on top.
  final parapet = a.r(0.16, 0.6, 0.5, 0.14);
  a.box(parapet, _brick, line: 0.5);
  for (var i = 0; i < 9; i++) {
    final x = parapet.left + parapet.width * (i / 9);
    a
      ..box(
        Rect.fromLTWH(x, parapet.top - a.u * 3, parapet.width / 18, a.u * 3),
        _brick,
        line: 0.4,
      )
      ..fill(
        Rect.fromLTWH(
          x,
          parapet.top - a.u * 3.4,
          parapet.width / 18,
          a.u * 0.8,
        ),
        _snow,
      );
  }
  a.line(parapet.topLeft, parapet.topRight, _snow, width: 1);

  // Left: the rock face, and the door cut into it down to the stores.
  final outcrop = Path()
    ..moveTo(0, a.size.height * 0.2)
    ..lineTo(a.size.width * 0.06, a.size.height * 0.16)
    ..lineTo(a.size.width * 0.13, a.size.height * 0.2)
    ..lineTo(a.size.width * 0.2, a.size.height * 0.3)
    ..lineTo(a.size.width * 0.2, a.size.height * 0.78)
    ..lineTo(0, a.size.height * 0.78)
    ..close();
  a.canvas
    ..save()
    ..clipPath(outcrop);
  _rockFace(a, a.r(0, 0.14, 0.2, 0.64), seed: 21);
  a.canvas.restore();
  a
    ..strokePath(outcrop, Art.outline, width: 0.5)
    // Snow lying on the ledges of the rock.
    ..path(
      a.poly([
        a.p(0, 0.2),
        a.p(0.06, 0.16),
        a.p(0.13, 0.2),
        a.p(0.17, 0.26),
        a.p(0.11, 0.235),
        a.p(0.05, 0.22),
        a.p(0, 0.235),
      ]),
      _snow,
      line: 0,
    );
  final store = a.r(0.035, 0.44, 0.12, 0.32);
  a
    ..path(_arch(store.inflate(a.u)), _rockDark, line: 0.5)
    ..path(_arch(store), _wood, line: 0.5);
  for (var i = 1; i < 4; i++) {
    final x = store.left + store.width * i / 4;
    a.hairline(
      Offset(x, store.top + store.height * 0.12),
      Offset(x, store.bottom),
      _woodDark,
      0.35,
    );
  }
  a
    ..box(
      Rect.fromCenter(center: store.center, width: a.u * 2, height: a.u * 3),
      _iron,
      line: 0.2,
    )
    // The commander's seal, red wax on a cord.
    ..line(
      store.center.translate(-store.width * 0.3, 0),
      store.center.translate(store.width * 0.3, 0),
      const Color(0xFF7A6A50),
      width: 0.4,
    )
    ..circle(
      store.center.translate(store.width * 0.3, 0),
      a.u * 1.1,
      const Color(0xFF8A2018),
      line: 0.2,
    );

  // The gate: a deep pointed arch in the wall, the order pinned to its leaf.
  final wall = a.r(0.18, 0.28, 0.2, 0.46);
  _courtSide(a, 0.38, 0.28, 0.74, _plaster);
  a.box(wall, _plaster, line: 0.5);
  a.fade(wall, const Color(0x00000000), const Color(0x33000000));
  final gate = a.r(0.215, 0.38, 0.13, 0.36);
  a
    ..path(_arch(gate.inflate(a.u * 1.2)), _plasterShade, line: 0.5)
    ..path(_arch(gate), _woodDark, line: 0.5);
  for (var i = 1; i < 5; i++) {
    final y = gate.top + gate.height * (0.3 + i * 0.14);
    a.hairline(Offset(gate.left, y), Offset(gate.right, y), _iron, 0.5);
  }
  for (var i = 0; i < 4; i++) {
    for (var k = 0; k < 3; k++) {
      a.canvas.drawCircle(
        Offset(
          gate.left + gate.width * (0.2 + k * 0.3),
          gate.top + gate.height * (0.4 + i * 0.14),
        ),
        a.u * 0.35,
        Paint()..color = const Color(0xFF8A8078),
      );
    }
  }
  a
    ..paper(
      a.r(0.262, 0.47, 0.066, 0.11),
      lines: 6,
      angle: -0.03,
      color: _paper,
    )
    ..fill(a.r(0.18, 0.26, 0.2, 0.025), _snow);

  // The tower: square, mud-brick on stone, a small door at its foot.
  final tower = a.r(0.6, 0.1, 0.17, 0.64);
  _courtSide(a, 0.6, 0.1, 0.74, _brick, t: 0.12);
  a
    ..box(tower, _brick, line: 0.5)
    ..fade(tower, const Color(0x00000000), const Color(0x44000000));
  for (var i = 1; i < 14; i++) {
    final y = tower.top + tower.height * i / 14;
    a.hairline(
      Offset(tower.left, y),
      Offset(tower.right, y),
      const Color(0x553A2818),
      0.25,
    );
  }
  for (var i = 0; i < 5; i++) {
    final x = tower.left + tower.width * (i / 5);
    a
      ..box(
        Rect.fromLTWH(x, tower.top - a.u * 3.5, tower.width / 10, a.u * 3.5),
        _brick,
        line: 0.4,
      )
      ..fill(
        Rect.fromLTWH(x, tower.top - a.u * 3.9, tower.width / 10, a.u * 0.8),
        _snow,
      );
  }
  // The window of the room at the top, lamplit.
  final high = a.r(0.66, 0.18, 0.05, 0.1);
  a
    ..glow(high.center, a.u * 6, _lamp, strength: 0.25)
    ..path(_arch(high), const Color(0xFF3A2A1A), line: 0.4);
  final towerDoor = a.r(0.655, 0.47, 0.07, 0.25);
  a
    ..path(_arch(towerDoor), _rockDeep, line: 0.5)
    ..glow(towerDoor.center, a.u * 4, _lamp, strength: 0.12);

  // The library: a long hall on the right, its door barred.
  final hall = a.r(0.8, 0.28, 0.2, 0.48);
  _courtSide(a, 0.8, 0.28, 0.76, _plaster);
  a
    ..box(hall, _plaster, line: 0.5)
    ..fade(hall, const Color(0x00000000), const Color(0x33000000))
    ..fill(a.r(0.8, 0.26, 0.2, 0.025), _snow);
  final hallDoor = a.r(0.84, 0.48, 0.08, 0.26);
  a.path(_arch(hallDoor), _wood, line: 0.5);
  a.box(
    Rect.fromLTWH(
      hallDoor.left - a.u,
      hallDoor.top + hallDoor.height * 0.55,
      hallDoor.width + a.u * 2,
      a.u * 1.4,
    ),
    _woodDark,
    line: 0.3,
  );
  for (final x in [0.83, 0.94]) {
    a.path(
      _arch(a.r(x, 0.33, 0.035, 0.08)),
      const Color(0xFF3A2A1A),
      line: 0.3,
    );
  }

  // The court: snow, trodden into a path to the gate; the buildings'
  // shadows along their feet.
  a.fade(a.r(0, 0.74, 1, 0.26), _snowShade, _snow);
  for (final (x0, x1, y) in [
    (0.0, 0.42, 0.75),
    (0.58, 0.78, 0.745),
    (0.76, 1.0, 0.765),
  ]) {
    _footShadow(a, x0, x1, y);
  }
  a.path(
    a.poly([a.p(0.25, 0.74), a.p(0.33, 0.74), a.p(0.44, 1), a.p(0.2, 1)]),
    const Color(0xFFA6A8AA),
    line: 0,
  );
  for (var i = 0; i < 9; i++) {
    final t = i / 9;
    a.canvas.drawOval(
      Rect.fromCenter(
        center: a.p(
          0.3 + t * 0.06 + (i.isEven ? -0.01 : 0.01),
          0.76 + t * 0.22,
        ),
        width: a.u * 1.2,
        height: a.u * 0.7,
      ),
      Paint()..color = const Color(0x55606468),
    );
  }
  _snowfall(a, seed: 5);
}

// ---------------------------------------------------------------------------
// The room at the top of the tower

void _tower(Art a) {
  // Plastered walls, a beamed ceiling, a floor of packed earth, all in
  // one perspective.
  final room = Room(a, vp: a.p(0.5, 0.3), depth: 0.62);
  final back = room.back;
  a
    ..path(room.ceiling, const Color(0xFF4A3622), line: 0)
    ..path(room.leftWall, _plasterShade, line: 0)
    ..path(room.rightWall, Color.lerp(_plaster, _plasterShade, 0.6)!, line: 0)
    ..fill(back, _plaster)
    ..fade(
      Rect.fromLTRB(
        back.left,
        back.top,
        back.right,
        back.top + back.height * 0.3,
      ),
      const Color(0x55000000),
      const Color(0x00000000),
    )
    ..path(room.floor, const Color(0xFF8C7458), line: 0);
  // The joists across the ceiling, running back.
  for (var k = 1; k < 8; k++) {
    a.line(room.at(0, 1, k / 8), room.at(1, 1, k / 8), _woodDark, width: 1.4);
  }
  room
    ..shadeCorners(strength: 0.35)
    ..edges(_plasterShade);
  a.ink(back, width: 0.4);

  // The lamp niche, black with smoke.
  final niche = a.r(0.39, 0.22, 0.08, 0.18);
  a
    ..path(_arch(niche), const Color(0xFF6A5A48), line: 0.4)
    ..glow(
      niche.topCenter.translate(0, niche.height * 0.2),
      a.u * 4,
      const Color(0xFF1A120C),
      strength: 0.6,
    );

  // The hook by the door, where the commander's keys hang (a sprite).
  a
    ..line(a.p(0.335, 0.3), a.p(0.335, 0.33), _iron, width: 0.6)
    ..circle(a.p(0.335, 0.3), a.u * 0.5, _iron, line: 0);
  // The door down, shut, at the foot of the wall.
  final door = Rect.fromLTRB(
    a.p(0.21, 0).dx,
    a.p(0, 0.32).dy,
    a.p(0.31, 0).dx,
    back.bottom,
  );
  a.path(_arch(door), _wood, line: 0.5);
  for (var i = 1; i < 4; i++) {
    final x = door.left + door.width * i / 4;
    a.hairline(
      Offset(x, door.top + door.height * 0.15),
      Offset(x, door.bottom),
      _woodDark,
      0.3,
    );
  }

  // The window: the valley of Alamut below, terraced fields under snow.
  final window = a.r(0.5, 0.15, 0.28, 0.42);
  final frame = _arch(window, spring: 0.62);
  a.canvas
    ..save()
    ..clipPath(frame);
  a.fade(window, _skyHigh, _sky);
  final wl = window.left;
  final ww = window.width;
  double wx(double t) => wl + ww * t;
  double y(double t) => a.size.height * t;
  // The far side of the valley: a ridge with snow on its crest.
  final ridge = Path()
    ..moveTo(wx(0), y(0.3))
    ..lineTo(wx(0.18), y(0.24))
    ..lineTo(wx(0.34), y(0.28))
    ..lineTo(wx(0.52), y(0.2))
    ..lineTo(wx(0.72), y(0.27))
    ..lineTo(wx(0.88), y(0.23))
    ..lineTo(wx(1), y(0.27))
    ..lineTo(wx(1), y(0.4))
    ..lineTo(wx(0), y(0.4))
    ..close();
  a
    ..path(ridge, _peaksFar, line: 0)
    ..strokePath(
      Path()
        ..moveTo(wx(0), y(0.3))
        ..lineTo(wx(0.18), y(0.24))
        ..lineTo(wx(0.34), y(0.28))
        ..lineTo(wx(0.52), y(0.2))
        ..lineTo(wx(0.72), y(0.27))
        ..lineTo(wx(0.88), y(0.23))
        ..lineTo(wx(1), y(0.27)),
      _snow,
      width: 1.2,
    )
    // The valley floor falling away below, under snow.
    ..fade(a.r(0.5, 0.33, 0.4, 0.3), const Color(0xFFC4C6C8), _snow);
  // Terraces stepping down the near slope, curved round it, closer
  // together far off: a line of dark earth under each lip of snow.
  for (var i = 0; i < 8; i++) {
    final t = i / 7;
    final top = 0.36 + t * t * 0.18;
    final bow = 0.012 + t * 0.02;
    final terrace = Path()
      ..moveTo(wx(0), y(top + bow))
      ..quadraticBezierTo(wx(0.5), y(top - bow), wx(1), y(top + bow * 0.6));
    a
      ..strokePath(terrace, _field, width: 0.4 + t * 0.5)
      ..strokePath(terrace.shift(Offset(0, -a.u * 0.5)), _snow, width: 0.3);
  }
  // A water channel winding down across the terraces.
  final channel = Path()..moveTo(wx(0.62), y(0.35));
  for (var i = 1; i <= 8; i++) {
    final t = i / 8;
    channel.lineTo(
      wx(0.62 + math.sin(i * 1.3) * 0.05 - t * 0.12),
      y(0.35 + t * t * 0.22),
    );
  }
  a.strokePath(channel, const Color(0xFF4E5E6C), width: 0.45);
  _snowfall(a, within: window, count: 40, seed: 3);
  a.canvas.restore();
  a
    ..strokePath(frame, _plasterShade, width: 2.4)
    ..strokePath(frame, Art.outline, width: 0.5)
    ..strokePath(frame, Art.outline, width: 0.5);
  room
    ..box(a.r(0.48, 0.57, 0.32, 0.025), _plasterShade, depth: 0.04)
    // Light from the window on the floor.
    ..beam(
      [a.p(0.52, 0.57), a.p(0.76, 0.57)],
      [
        room.floorAt(0.5, 0.75),
        room.floorAt(0.78, 0.75),
        room.floorAt(0.86, 0.3),
        room.floorAt(0.52, 0.3),
      ],
      const Color(0xFFE6E8EA),
      strength: 0.12,
    );

  // The reed mat on the floor, lying flat.
  final mz0 = room.floorDepthAt(a.p(0, 0.82).dy);
  final mz1 = room.floorDepthAt(a.p(0, 0.72).dy);
  final mx0 = room.xAt(a.p(0.11, 0).dx, mz0);
  final mx1 = room.xAt(a.p(0.39, 0).dx, mz0);
  a.path(
    a.poly([
      room.floorAt(mx0, mz1),
      room.floorAt(mx1, mz1),
      room.floorAt(mx1, mz0),
      room.floorAt(mx0, mz0),
    ]),
    const Color(0xFFB09A68),
    line: 0.4,
  );
  for (var i = 1; i < 18; i++) {
    final x = mx0 + (mx1 - mx0) * i / 18;
    a.hairline(
      room.floorAt(x, mz1),
      room.floorAt(x, mz0),
      const Color(0xFF8A7448),
      0.25,
    );
  }

  // Polo's book on the floor: a European binding, red leather with clasps,
  // plainly from somewhere else.
  final book = a.r(0.45, 0.72, 0.1, 0.06);
  room.contactShadow(book.inflate(a.u * 0.6).translate(0, a.u * 1.4));
  a
    ..box(book, const Color(0xFF7A2418), line: 0.5)
    ..fill(
      Rect.fromLTWH(
        book.left,
        book.bottom - book.height * 0.25,
        book.width,
        book.height * 0.25,
      ),
      _paper,
    )
    ..box(
      Rect.fromLTWH(
        book.right - book.width * 0.1,
        book.top + book.height * 0.2,
        book.width * 0.12,
        book.height * 0.2,
      ),
      const Color(0xFFB08A3A),
      line: 0.2,
    )
    ..glow(book.center, a.u * 5, _lamp, strength: 0.15);
}

// ---------------------------------------------------------------------------
// The storerooms under the rock

void _storerooms(Art a) {
  // Rock all round, a low vault, lamps along the back wall.
  _rockFace(a, Offset.zero & a.size, color: const Color(0xFF6E5C4A), seed: 41);
  a
    ..fade(a.r(0, 0, 1, 0.3), const Color(0xCC000000), const Color(0x00000000))
    ..fade(
      a.r(0, 0.56, 1, 0.44),
      const Color(0x00000000),
      const Color(0x66000000),
    );
  // Arches of the gallery along the back.
  for (var i = 0; i < 4; i++) {
    final r = a.r(0.2 + i * 0.14, 0.1, 0.11, 0.44);
    a.path(_arch(r), const Color(0xFF3A2E24), line: 0.4);
    final niche = Rect.fromLTWH(
      r.left + r.width * 0.3,
      a.size.height * 0.2,
      r.width * 0.4,
      a.size.height * 0.1,
    );
    a.path(_arch(niche), const Color(0xFF1E1812), line: 0.3);
    _oilLamp(a, niche.center.translate(a.u * 0.6, a.u * 1.4), a.u * 1.4);
  }
  // The floor of cut stone, its joints running back to the rock.
  final room = wallCamera(a, const Offset(0.5, 0.34), 0.56);
  a.fill(a.r(0, 0.56, 1, 0.44), const Color(0xFF5A4A3A));
  room
    ..floorGrid(const Color(0x663A2E24), rows: 5, columns: 16, x0: -1, x1: 2)
    ..wallFoot(strength: 0.4);
  // The four tanks cut down into the floor, under their covers: a rim of
  // cut stone round each mouth, its far inner wall catching the lamps.
  for (var i = 0; i < 4; i++) {
    final mouth = a.r(0.12 + i * 0.155, 0.64, 0.13, 0.18);
    a
      ..oval(mouth.inflate(a.u * 0.8), const Color(0xFF6E5C4A), line: 0.5)
      ..oval(mouth, const Color(0xFF14100C), line: 0.5);
    a.canvas
      ..save()
      ..clipPath(Path()..addOval(mouth))
      ..drawOval(
        Rect.fromLTWH(
          mouth.left,
          mouth.top - mouth.height * 0.55,
          mouth.width,
          mouth.height,
        ),
        Paint()..color = const Color(0xFF3A2E24),
      )
      ..restore();
    // Each cover slid half aside, as the soldiers left them: planks with
    // their edge showing.
    final cover = Rect.fromLTWH(
      mouth.left + mouth.width * 0.3,
      mouth.top - mouth.height * 0.08,
      mouth.width * 0.84,
      mouth.height * 0.46,
    );
    a
      ..fill(
        Rect.fromLTWH(cover.left, cover.bottom, cover.width, a.u * 0.9),
        _woodDark,
      )
      ..wood(cover, base: _wood, grain: 3, line: 0.4);
  }
  // The long reed, laid by the tanks.
  a.line(a.p(0.14, 0.88), a.p(0.7, 0.86), const Color(0xFFB8A86C), width: 0.8);

  // Left: the great jars, sealed, standing on the floor.
  for (var i = 0; i < 3; i++) {
    final jar = a.r(0.02 + i * 0.045, 0.34 + (i.isOdd ? 0.03 : 0), 0.05, 0.24);
    room.contactShadow(
      Rect.fromCenter(
        center: jar.bottomCenter.translate(a.u * 0.6, -a.u * 0.4),
        width: jar.width * 1.3,
        height: a.u * 2.4,
      ),
      strength: 0.55,
    );
    a
      ..oval(jar, const Color(0xFF9A6A44), line: 0.5)
      ..canvas.drawOval(
        jar.deflate(a.u * 0.3),
        Paint()
          ..shader = Gradient.linear(
            jar.centerLeft,
            jar.centerRight,
            [
              const Color(0x22FFFFFF),
              const Color(0x00000000),
              const Color(0x66000000),
            ],
            [0, 0.4, 1],
          ),
      )
      ..box(
        Rect.fromLTWH(
          jar.left + jar.width * 0.3,
          jar.top - a.u,
          jar.width * 0.4,
          a.u * 2,
        ),
        const Color(0xFF6A4A2E),
        line: 0.3,
      );
  }

  // Right: the wide, high tunnel climbing through the rock, its mouth
  // deep, its steps going up into the dark.
  final tunnel = a.r(0.81, 0.2, 0.14, 0.44);
  final vp = a.p(0.88, 0.3);
  Path deeper(double t) => _arch(
    Rect.fromPoints(
      Offset.lerp(tunnel.topLeft, vp, t)!,
      Offset.lerp(tunnel.bottomRight, vp, t)!,
    ),
  );
  a
    ..path(_arch(tunnel.inflate(a.u)), const Color(0xFF3A2E24), line: 0.5)
    ..path(_arch(tunnel), const Color(0xFF1E1812), line: 0)
    ..path(deeper(0.35), const Color(0xFF0E0A08), line: 0)
    ..glow(
      tunnel.topCenter.translate(0, tunnel.height * 0.2),
      a.u * 6,
      _lamp,
      strength: 0.08,
    );
  for (var i = 0; i < 6; i++) {
    final y = tunnel.bottom - tunnel.height * (0.08 + i * 0.07);
    a.hairline(
      Offset(tunnel.left + tunnel.width * (0.18 + i * 0.04), y),
      Offset(tunnel.right - tunnel.width * (0.18 + i * 0.04), y),
      const Color(0xFF3A2E24),
      0.5,
    );
  }
}

// ---------------------------------------------------------------------------
// The library

void _library(Art a) {
  // Plastered hall, a patterned band round it, a carpet on the floor; one
  // perspective for all of it.
  final room = Room(a, vp: a.p(0.5, 0.3), depth: 0.66);
  final back = room.back;
  a
    ..path(room.ceiling, _woodDark, line: 0)
    ..path(room.leftWall, _plasterShade, line: 0)
    ..path(room.rightWall, Color.lerp(_plaster, _plasterShade, 0.6)!, line: 0)
    ..fill(back, _plaster)
    ..fade(
      Rect.fromLTRB(
        back.left,
        back.top,
        back.right,
        back.top + back.height * 0.45,
      ),
      const Color(0x66000000),
      const Color(0x00000000),
    )
    ..path(room.floor, const Color(0xFF7A6448), line: 0);
  for (var k = 1; k < 8; k++) {
    a.line(room.at(0, 1, k / 8), room.at(1, 1, k / 8), _wood, width: 1.2);
  }
  // The indigo band with its gilt dots, round all three walls.
  final band = [
    room.at(0, 0.93, 0),
    room.at(0, 0.93, 1),
    room.at(1, 0.93, 1),
    room.at(1, 0.93, 0),
  ];
  a.strokePath(Path()..addPolygon(band, false), _indigo, width: 2.2);
  for (var i = 0; i < 24; i++) {
    a.canvas.drawCircle(
      Offset.lerp(band[1], band[2], (i + 0.5) / 24)!,
      a.u * 0.3,
      Paint()..color = const Color(0xFFB08A3A),
    );
  }
  room
    ..shadeCorners(strength: 0.35)
    ..edges(_plasterShade);
  a.ink(back, width: 0.4);
  // The carpet, lying flat, its border and its row of lozenges.
  Offset rug(double u, double v) =>
      room.floorAt(0.12 + 0.56 * u, 0.12 + 0.5 * v);
  Path rugQuad(double inset) => a.poly([
    rug(inset, inset),
    rug(1 - inset, inset),
    rug(1 - inset, 1 - inset),
    rug(inset, 1 - inset),
  ]);
  a
    ..path(rugQuad(0), _carpet, line: 0.4)
    ..path(rugQuad(0.05), _carpetDark, line: 0)
    ..path(rugQuad(0.09), _carpet, line: 0);
  for (var i = 0; i < 5; i++) {
    final u = 0.14 + i * 0.18;
    a.path(
      a.poly([
        rug(u, 0.38),
        rug(u + 0.05, 0.5),
        rug(u, 0.62),
        rug(u - 0.05, 0.5),
      ]),
      const Color(0xFFB08A3A),
      line: 0.2,
    );
  }

  // Left: tall niches of books, most already emptied.
  final random = math.Random(51);
  for (var col = 0; col < 3; col++) {
    for (var row = 0; row < 3; row++) {
      final niche = a.r(0.18 + col * 0.088, 0.14 + row * 0.18, 0.075, 0.16);
      a.path(_arch(niche, spring: 0.7), const Color(0xFF3A2E22), line: 0.4);
      final shelf = Rect.fromLTRB(
        niche.left + a.u * 0.5,
        niche.bottom - niche.height * 0.3,
        niche.right - a.u * 0.5,
        niche.bottom - a.u * 0.5,
      );
      if (random.nextDouble() < 0.4) {
        // A few books left, lying on their sides.
        for (var k = 0; k < 1 + random.nextInt(3); k++) {
          final h = shelf.height * 0.25;
          _book(
            a,
            Rect.fromLTWH(
              shelf.left + a.u * 0.4,
              shelf.bottom - h * (k + 1),
              shelf.width * (0.6 + random.nextDouble() * 0.3),
              h,
            ),
            [const Color(0xFF6A3A22), _indigo, const Color(0xFF4A5A3A)][random
                .nextInt(3)],
          );
        }
      }
    }
  }

  // A high window, snow-light.
  final window = a.r(0.44, 0.12, 0.12, 0.14);
  a
    ..path(_arch(window), const Color(0xFFBFC4CA), line: 0.5)
    ..glow(window.center, a.u * 10, const Color(0xFFE6E8EA), strength: 0.2);
  _snowfall(a, within: window.deflate(a.u), count: 10, seed: 13);

  // The astrolabe's stand, empty: a brass post and arm, the throne (kursi)
  // hanging from its shackle, and below it only the pale ring in the dust
  // of the wall where the plate once hung.
  const brass = Color(0xFFB08A3A);
  room
    ..contactShadow(a.r(0.48, 0.775, 0.065, 0.018))
    ..box(a.r(0.485, 0.765, 0.054, 0.02), const Color(0xFF8A6A2A), depth: 0.04);
  a
    ..box(a.r(0.508, 0.36, 0.008, 0.405), const Color(0xFF8A6A2A), line: 0.3)
    ..box(a.r(0.49, 0.355, 0.04, 0.008), const Color(0xFF8A6A2A), line: 0.3)
    ..line(a.p(0.498, 0.363), a.p(0.498, 0.38), _iron, width: 0.4);
  final top = a.p(0.498, 0.38);
  final kursi = Path()
    ..moveTo(top.dx - a.u * 2.2, top.dy + a.u * 4.2)
    ..quadraticBezierTo(
      top.dx - a.u * 3.2,
      top.dy + a.u * 1.4,
      top.dx - a.u * 1.2,
      top.dy + a.u * 1.6,
    )
    ..quadraticBezierTo(top.dx - a.u * 1.2, top.dy - a.u * 0.4, top.dx, top.dy)
    ..quadraticBezierTo(
      top.dx + a.u * 1.2,
      top.dy - a.u * 0.4,
      top.dx + a.u * 1.2,
      top.dy + a.u * 1.6,
    )
    ..quadraticBezierTo(
      top.dx + a.u * 3.2,
      top.dy + a.u * 1.4,
      top.dx + a.u * 2.2,
      top.dy + a.u * 4.2,
    )
    ..close();
  a
    ..path(kursi, brass, line: 0.35)
    ..circle(
      top.translate(0, a.u * 2.2),
      a.u * 0.6,
      const Color(0xFF6A4A1A),
      line: 0.15,
    );
  final ghost = top.translate(0, a.u * 4.2 + a.u * 5.4);
  a.canvas
    ..drawCircle(ghost, a.u * 5.4, Paint()..color = const Color(0x22000000))
    ..drawCircle(
      ghost,
      a.u * 5.4,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = a.u * 0.3
        ..color = const Color(0x66B08A3A),
    );

  // Right: the scholar's corner: a low platform on the floor, a cushion,
  // a writing box and a lamp on it; on the wall above, a shelf with the
  // folding book-stand (rahl), a crossed X.
  room.box(a.r(0.66, 0.5, 0.14, 0.012), _woodDark, depth: 0.04, line: 0.3);
  a
    ..line(a.p(0.69, 0.5), a.p(0.75, 0.41), _wood, width: 1)
    ..line(a.p(0.75, 0.5), a.p(0.69, 0.41), _wood, width: 1);
  room
    ..shadow(0.68, 0.98, 0.25, 0.5)
    ..block(0.68, 0.98, 0, 0.07, 0.25, 0.5, _wood);
  a
    ..rbox(a.r(0.69, 0.79, 0.09, 0.05), a.u, const Color(0xFF3A4A6A), line: 0.4)
    ..box(a.r(0.81, 0.795, 0.07, 0.045), const Color(0xFF4A2E1A), line: 0.4)
    ..line(
      a.p(0.82, 0.805),
      a.p(0.87, 0.805),
      const Color(0xFFB08A3A),
      width: 0.4,
    );
  _oilLamp(a, a.p(0.905, 0.83), a.u * 1.1);

  // The loose sheets on the floor, folded in pairs.
  for (final (x, y, angle) in [
    (0.38, 0.76, -0.2),
    (0.45, 0.8, 0.15),
    (0.52, 0.75, -0.05),
    (0.58, 0.8, 0.25),
  ]) {
    a.paper(
      a.r(x, y, 0.06, 0.05),
      lines: 3,
      angle: angle,
      color: _paper,
      ink: 0.5,
    );
  }
}

// ---------------------------------------------------------------------------
// Puzzle boards

/// The reading desk: dark walnut under the lamp.
void _quireBoard(Art a) {
  a
    ..wood(
      Offset.zero & a.size,
      base: const Color(0xFF3A2818),
      grain: 9,
      line: 0,
    )
    ..glow(a.p(0.5, 0.35), a.size.width * 0.55, _lamp, strength: 0.18)
    ..fade(
      Offset.zero & a.size,
      const Color(0x00000000),
      const Color(0x66000000),
    );
}

/// The gallery floor over the tanks, dim, a lamp above.
void _dipBoard(Art a) {
  _rockFace(a, Offset.zero & a.size, color: const Color(0xFF4A3C30), seed: 61);
  a
    ..glow(a.p(0.5, 0), a.size.width * 0.5, _lamp, strength: 0.16)
    ..fade(
      Offset.zero & a.size,
      const Color(0x22000000),
      const Color(0x88000000),
    );
}

// ---------------------------------------------------------------------------
// Objects

/// The commander's keys on an iron ring, hung from a hook.
void _keys(Art a) {
  final ring = Offset(a.size.width * 0.5, a.size.height * 0.2);
  a.canvas.drawCircle(
    ring,
    a.size.width * 0.18,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = a.u * 4
      ..color = _iron,
  );
  for (final (angle, length) in [(-0.35, 0.62), (0.0, 0.7), (0.4, 0.58)]) {
    final top =
        ring + Offset(math.sin(angle), math.cos(angle)) * a.size.width * 0.18;
    final bottom =
        top + Offset(math.sin(angle) * 0.2, 1) * a.size.height * length * 0.9;
    a
      ..line(top, bottom, _iron, width: 6)
      ..box(
        Rect.fromCenter(
          center: bottom.translate(a.u * 5, -a.u * 5),
          width: a.u * 12,
          height: a.u * 7,
        ),
        _iron,
        line: 0,
      );
  }
}

/// A tally board hung across the tunnel on two ropes, notched in rows.
void _tally(Art a) {
  const rope = Color(0xFF9A8458);
  final board = a.r(0.08, 0.4, 0.84, 0.16);
  a
    ..line(
      a.p(0.14, 0),
      board.topLeft.translate(board.width * 0.06, 0),
      rope,
      width: 1.4,
    )
    ..line(
      a.p(0.86, 0),
      board.topRight.translate(-board.width * 0.06, 0),
      rope,
      width: 1.4,
    )
    ..wood(board, base: const Color(0xFF8A6A44), grain: 2, line: 0.6);
  for (var row = 0; row < 2; row++) {
    for (var k = 0; k < 14; k++) {
      final x = board.left + board.width * (0.08 + k * 0.06);
      final y = board.top + board.height * (0.25 + row * 0.45);
      a.line(
        Offset(x, y),
        Offset(x, y + board.height * 0.25),
        _woodDark,
        width: 0.8,
      );
    }
  }
}

/// A paper from long after: a printed page, folded once.
void _laterPaper(Art a) {
  a
    ..paper(
      a.r(0.1, 0.12, 0.8, 0.76),
      lines: 7,
      angle: -0.08,
      color: const Color(0xFFEDE8DC),
      ink: 0.55,
    )
    ..glow(a.p(0.5, 0.5), a.size.width * 0.6, _lamp, strength: 0.18);
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
  a.fade(a.r(0, 0.16, 1, 0.6), _skyHigh, _sky);
  _range(a, 0.62, 0.3, color: _peaksFar, seed: 71, count: 4);
  // The valley floor under snow, and the rock rising out of it, the
  // castle along its top.
  a.fade(a.r(0, 0.74, 1, 0.26), _snowShade, _snow);
  final rock = a.poly([
    a.p(0.24, 1),
    a.p(0.3, 0.84),
    a.p(0.27, 0.72),
    a.p(0.34, 0.62),
    a.p(0.4, 0.56),
    a.p(0.66, 0.55),
    a.p(0.72, 0.63),
    a.p(0.68, 0.74),
    a.p(0.75, 0.86),
    a.p(0.8, 1),
  ]);
  a.canvas
    ..save()
    ..clipPath(rock);
  _rockFace(a, a.r(0.2, 0.5, 0.64, 0.5), seed: 73);
  a.canvas.restore();
  a
    ..strokePath(rock, Art.outline, width: 0.4)
    ..box(a.r(0.39, 0.47, 0.28, 0.08), _brick, line: 0.4)
    ..box(a.r(0.57, 0.33, 0.08, 0.22), _brick, line: 0.4);
  for (var i = 0; i < 5; i++) {
    a.box(a.r(0.39 + i * 0.06, 0.445, 0.03, 0.025), _brick, line: 0.3);
  }
  a
    ..fill(a.r(0.39, 0.465, 0.28, 0.012), _snow)
    ..fill(a.r(0.57, 0.325, 0.08, 0.012), _snow)
    ..path(
      _arch(a.r(0.595, 0.37, 0.03, 0.05)),
      const Color(0xFF3A2A1A),
      line: 0.2,
    )
    ..glow(a.p(0.61, 0.4), w * 0.08, _lamp, strength: 0.5);
  _snowfall(a, count: 30, seed: 9);
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
  // The lid: a scrap of burnished paper, its edge scorched.
  a
    ..box(a.r(0.3, 0.04, 0.4, 0.14), _paper, line: 0.5)
    ..fill(a.r(0.62, 0.04, 0.08, 0.14), const Color(0xAA3A2010));
  a.hairline(a.p(0.36, 0.1), a.p(0.58, 0.1), _ink, 0.6);
}
