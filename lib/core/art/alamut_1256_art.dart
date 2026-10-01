import 'dart:math' as math;
import 'dart:ui';

import '../theme/stillroom_palette.dart';
import 'art_kit.dart';
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

  // The court: snow, trodden into a path to the gate.
  a
    ..fade(a.r(0, 0.74, 1, 0.26), _snowShade, _snow)
    ..path(
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
  // Plastered walls, a beamed ceiling, a floor of packed earth.
  a
    ..fill(Offset.zero & a.size, _plaster)
    ..fade(a.r(0, 0, 1, 0.3), const Color(0x55000000), const Color(0x00000000))
    ..fill(a.r(0, 0.64, 1, 0.36), const Color(0xFF8C7458))
    ..fade(
      a.r(0, 0.64, 1, 0.36),
      const Color(0x33000000),
      const Color(0x00000000),
    );
  // The ceiling: a dark beam along the wall, and the joists' ends.
  a.wood(a.r(0, 0, 1, 0.045), base: _woodDark, grain: 2, line: 0.4);
  for (var i = 0; i < 12; i++) {
    a.box(a.r(i / 12 + 0.02, 0.045, 0.028, 0.03), _wood, line: 0.3);
  }
  a.line(a.p(0, 0.64), a.p(1, 0.64), _plasterShade, width: 0.8);

  // The lamp niche, black with smoke.
  final niche = a.r(0.09, 0.22, 0.08, 0.18);
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
  // The door down, shut.
  final door = a.r(0.19, 0.26, 0.1, 0.38);
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
  final window = a.r(0.57, 0.15, 0.28, 0.42);
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
    ..fill(a.r(0.55, 0.57, 0.32, 0.025), _plasterShade);

  // The reed mat on the floor.
  final mat = a.r(0.11, 0.72, 0.28, 0.1);
  a.box(mat, const Color(0xFFB09A68), line: 0.4);
  for (var i = 1; i < 18; i++) {
    final x = mat.left + mat.width * i / 18;
    a.hairline(
      Offset(x, mat.top),
      Offset(x, mat.bottom),
      const Color(0xFF8A7448),
      0.25,
    );
  }

  // Polo's book on the floor: a European binding, red leather with clasps,
  // plainly from somewhere else.
  final book = a.r(0.45, 0.72, 0.1, 0.06);
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

  // Light from the window on the floor.
  a.glow(
    a.p(0.7, 0.8),
    a.size.width * 0.18,
    const Color(0xFFE6E8EA),
    strength: 0.12,
  );
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
  // The floor of cut stone.
  a.fill(a.r(0, 0.56, 1, 0.44), const Color(0xFF5A4A3A));
  for (var i = 1; i < 6; i++) {
    final y = 0.56 + i * 0.08;
    a.hairline(a.p(0, y), a.p(1, y), const Color(0x663A2E24), 0.3);
  }
  // The four tanks under their covers.
  for (var i = 0; i < 4; i++) {
    final mouth = a.r(0.12 + i * 0.155, 0.64, 0.13, 0.18);
    a
      ..oval(mouth, const Color(0xFF14100C), line: 0.5)
      ..oval(mouth.deflate(a.u * 0.8), const Color(0xFF0A0806), line: 0);
    // Each cover slid half aside, as the soldiers left them.
    final cover = Rect.fromLTWH(
      mouth.left + mouth.width * 0.3,
      mouth.top - mouth.height * 0.08,
      mouth.width * 0.84,
      mouth.height * 0.46,
    );
    a.wood(cover, base: _wood, grain: 3, line: 0.4);
  }
  // The long reed, laid by the tanks.
  a.line(a.p(0.14, 0.88), a.p(0.7, 0.86), const Color(0xFFB8A86C), width: 0.8);

  // Left: the great jars, sealed.
  for (var i = 0; i < 3; i++) {
    final jar = a.r(0.02 + i * 0.045, 0.3 + (i.isOdd ? 0.03 : 0), 0.05, 0.24);
    a
      ..oval(jar, const Color(0xFF9A6A44), line: 0.5)
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

  // Right: the wide, high tunnel climbing through the rock.
  final tunnel = a.r(0.81, 0.2, 0.14, 0.44);
  a
    ..path(_arch(tunnel.inflate(a.u)), const Color(0xFF3A2E24), line: 0.5)
    ..path(_arch(tunnel), const Color(0xFF0E0A08), line: 0)
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
  // Plastered hall, a patterned band, a carpet.
  a
    ..fill(Offset.zero & a.size, _plaster)
    ..fade(a.r(0, 0, 1, 0.4), const Color(0x66000000), const Color(0x00000000))
    ..fill(a.r(0, 0.66, 1, 0.34), const Color(0xFF7A6448));
  a.wood(a.r(0, 0, 1, 0.06), base: _woodDark, grain: 2, line: 0.4);
  a.fill(a.r(0, 0.08, 1, 0.02), _indigo);
  for (var i = 0; i < 40; i++) {
    a.canvas.drawCircle(
      a.p(i / 40 + 0.0125, 0.09),
      a.u * 0.35,
      Paint()..color = const Color(0xFFB08A3A),
    );
  }
  final carpet = a.r(0.18, 0.74, 0.64, 0.2);
  a
    ..box(carpet, _carpet, line: 0.4)
    ..box(carpet.deflate(a.u * 1.4), _carpetDark, line: 0)
    ..box(carpet.deflate(a.u * 2.4), _carpet, line: 0);
  for (var i = 0; i < 5; i++) {
    final c = Offset(
      carpet.left + carpet.width * (0.14 + i * 0.18),
      carpet.center.dy,
    );
    a.path(
      a.poly([
        c.translate(0, -a.u * 2.4),
        c.translate(a.u * 2.4, 0),
        c.translate(0, a.u * 2.4),
        c.translate(-a.u * 2.4, 0),
      ]),
      const Color(0xFFB08A3A),
      line: 0.2,
    );
  }

  // Left: tall niches of books, most already emptied.
  final random = math.Random(51);
  for (var col = 0; col < 3; col++) {
    for (var row = 0; row < 3; row++) {
      final niche = a.r(0.035 + col * 0.09, 0.14 + row * 0.18, 0.075, 0.16);
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
  a
    ..box(a.r(0.508, 0.36, 0.008, 0.28), const Color(0xFF8A6A2A), line: 0.3)
    ..box(a.r(0.485, 0.625, 0.054, 0.02), const Color(0xFF8A6A2A), line: 0.3)
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

  // Right: the scholar's corner: a low platform, a cushion, a writing box,
  // and a folding stand for a book.
  final platform = a.r(0.72, 0.6, 0.24, 0.08);
  a.wood(platform, base: _wood, grain: 2, line: 0.4);
  a
    ..rbox(a.r(0.74, 0.55, 0.09, 0.05), a.u, const Color(0xFF3A4A6A), line: 0.4)
    ..box(a.r(0.86, 0.555, 0.07, 0.045), const Color(0xFF4A2E1A), line: 0.4)
    ..line(
      a.p(0.87, 0.565),
      a.p(0.92, 0.565),
      const Color(0xFFB08A3A),
      width: 0.4,
    );
  // The folding book-stand (rahl), a crossed X, on a shelf above.
  a.box(a.r(0.76, 0.5, 0.14, 0.012), _woodDark, line: 0.3);
  a
    ..line(a.p(0.79, 0.5), a.p(0.85, 0.41), _wood, width: 1)
    ..line(a.p(0.85, 0.5), a.p(0.79, 0.41), _wood, width: 1);
  // A lamp on the platform's end, by the writing box.
  _oilLamp(a, a.p(0.955, 0.588), a.u * 1.1);

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
