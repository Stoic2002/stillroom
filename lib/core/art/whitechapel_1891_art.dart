import 'dart:math' as math;
import 'dart:ui';

import '../theme/stillroom_palette.dart';
import 'art_kit.dart';
import 'depth_kit.dart';
import 'echo_art.dart';
import 'whitechapel_1888_art.dart' show jarLabelBoard;

/// Code-drawn art for "Whitechapel, 1891" (docs/episodes/
/// whitechapel_1891.md): the small hours of 13 February 1891. Gaslight on
/// wet brick, a police station's green walls, a milliner's shuttered shop,
/// a composing room, and the file room.
const _s = 'images/scenes/whitechapel_1891';
const _o = 'images/objects/whitechapel_1891';

final Map<String, ArtPainter> whitechapel1891Art = {
  // Scenes and puzzle boards.
  '$_s/leman_street.png': (c, s) => _station(Art(c, s)),
  '$_s/swallow_gardens.png': (c, s) => _arch(Art(c, s)),
  '$_s/milliner.png': (c, s) => _milliner(Art(c, s)),
  '$_s/press_room.png': (c, s) => _press(Art(c, s)),
  '$_s/file_room.png': (c, s) => _fileRoom(Art(c, s)),
  '$_s/shelf_board.png': (c, s) => _shelfBoard(Art(c, s)),
  '$_s/case_board.png': (c, s) => _caseBoard(Art(c, s)),
  '$_s/label_close.png': (c, s) => jarLabelBoard(Art(c, s), _wall),
  // Objects.
  '$_o/charge_sheet_sprite.png': (c, s) => _sheet(Art(c, s), tint: _blueForm),
  '$_o/memo_sprite.png': (c, s) => _sheet(Art(c, s), tint: _paperWhite),
  '$_o/echo_constable.png': (c, s) =>
      paintEcho(Art(c, s), EchoFigure.constable),
  '$_o/echo_compositor.png': (c, s) =>
      paintEcho(Art(c, s), EchoFigure.compositor),
  // The jar on the shelf.
  'images/ui/jar_whitechapel_1891.png': (c, s) => _jar(Art(c, s)),
};

// ---------------------------------------------------------------------------
// Palette

const _wall = Color(0xFF26302A);
const _wallLow = Color(0xFF1A201C);
const _dado = Color(0xFF3A2A1E);
const _brick = Color(0xFF4A2E24);
const _brickDark = Color(0xFF2A1A14);
const _cobble = Color(0xFF2A2A2C);
const _night = Color(0xFF12161C);
const _gas = StillroomPalette.gaslight;
const _blueForm = Color(0xFFBCC8D4);
const _paperWhite = Color(0xFFE8E2D2);
const _crepe = Color(0xFF141214);

// ---------------------------------------------------------------------------
// Shared pieces

/// A gas bracket on a wall: pipe, mantle, glow.
void _gasLamp(Art a, Offset at, double size, {double glow = 0.35}) {
  a
    ..glow(at, size * 5, _gas, strength: glow)
    ..line(
      at.translate(-size, -size * 0.2),
      at,
      const Color(0xFF3A3A3A),
      width: 0.8,
    )
    ..oval(
      Rect.fromCenter(center: at, width: size * 0.9, height: size * 1.2),
      const Color(0xFFF6D890),
      line: 0.4,
    );
}

/// Brickwork filling [rect].
void _bricks(Art a, Rect rect, {Color base = _brick}) {
  a.fill(rect, base);
  final rowH = a.size.height * 0.03;
  final mortar = Color.lerp(base, Art.outline, 0.45)!;
  var row = 0;
  for (var y = rect.top; y < rect.bottom; y += rowH) {
    a.hairline(Offset(rect.left, y), Offset(rect.right, y), mortar, 0.3);
    final w = rowH * 2.4;
    for (var x = rect.left + (row.isOdd ? w / 2 : 0); x < rect.right; x += w) {
      a.hairline(
        Offset(x, y),
        Offset(x, math.min(y + rowH, rect.bottom)),
        mortar,
        0.3,
      );
    }
    row++;
  }
}

/// A plain sheet with faint lines, for papers that arrive later.
void _sheet(Art a, {required Color tint}) =>
    a.paper(a.r(0.06, 0.08, 0.88, 0.84), lines: 4, angle: -0.03, color: tint);

/// A black crêpe hat lying on its side: a low crown, a small brim, a bow.
void _hat(Art a, Rect rect) {
  final w = rect.width;
  final h = rect.height;
  a
    ..oval(
      Rect.fromLTWH(rect.left, rect.top + h * 0.55, w, h * 0.4),
      _crepe,
      line: 0.5,
    )
    ..rbox(
      Rect.fromLTWH(rect.left + w * 0.2, rect.top + h * 0.15, w * 0.6, h * 0.6),
      w * 0.12,
      const Color(0xFF1E1A1E),
      line: 0.5,
    )
    ..fill(
      Rect.fromLTWH(rect.left + w * 0.2, rect.top + h * 0.5, w * 0.6, h * 0.08),
      const Color(0xFF3A3238),
    );
  // The bow, and the milliner's ticket in the band.
  a
    ..oval(
      Rect.fromLTWH(
        rect.left + w * 0.62,
        rect.top + h * 0.38,
        w * 0.2,
        h * 0.22,
      ),
      const Color(0xFF2A2428),
      line: 0.3,
    )
    ..box(
      Rect.fromLTWH(
        rect.left + w * 0.3,
        rect.top + h * 0.4,
        w * 0.14,
        h * 0.16,
      ),
      _paperWhite,
      line: 0.3,
    );
}

/// Wet cobbles from [top] down, catching the gaslight.
void _wetCobbles(Art a, double top, {Offset? light}) {
  a.fade(a.r(0, top, 1, 1 - top), _cobble, const Color(0xFF151517));
  final random = math.Random(8);
  for (var i = 0; i < 90; i++) {
    final x = random.nextDouble();
    final y = top + random.nextDouble() * (1 - top);
    a.canvas.drawOval(
      Rect.fromCenter(
        center: a.p(x, y),
        width: a.size.width * 0.022 * (0.6 + y),
        height: a.size.height * 0.011 * (0.6 + y),
      ),
      Paint()..color = const Color(0x22000000),
    );
  }
  if (light != null) {
    a.glow(light, a.size.width * 0.12, _gas, strength: 0.18);
  }
}

/// An interior in one-point perspective: the eye at [eye], the back wall
/// [depth] of the picture, painted by [back] (default: [top] fading to
/// [low]); side walls darker; a dado of [dado] to [dadoTop] of the height
/// round all three walls; boards running back. Returns its camera.
Room _interior(
  Art a, {
  required Offset eye,
  required double depth,
  Color top = _wallLow,
  Color low = _wall,
  Color? dado,
  double dadoTop = 0.28,
  void Function(Rect back)? back,
}) {
  final room = Room(a, vp: a.p(eye.dx, eye.dy), depth: depth);
  final wall = room.back;
  a
    ..path(room.ceiling, const Color(0xFF121412), line: 0)
    ..path(room.leftWall, Color.lerp(low, Art.outline, 0.35)!, line: 0)
    ..path(room.rightWall, Color.lerp(low, Art.outline, 0.25)!, line: 0);
  if (back != null) {
    back(wall);
  } else {
    a.fade(wall, top, low);
  }
  if (dado != null) {
    a.wood(
      Rect.fromPoints(room.at(0, dadoTop, 1), room.at(1, 0, 1)),
      base: dado,
      vertical: true,
      grain: 14,
    );
    for (final x in [0.0, 1.0]) {
      a.path(
        a.poly([
          room.at(x, 0, 0),
          room.at(x, dadoTop, 0),
          room.at(x, dadoTop, 1),
          room.at(x, 0, 1),
        ]),
        Color.lerp(dado, Art.outline, 0.3)!,
        line: 0,
      );
      for (var k = 1; k < 8; k++) {
        a.hairline(
          room.at(x, 0, k / 8),
          room.at(x, dadoTop, k / 8),
          const Color(0x55000000),
          0.4,
        );
      }
    }
  }
  a.path(room.floor, StillroomPalette.walnut, line: 0);
  room
    ..floorGrid(
      Color.lerp(StillroomPalette.walnut, Art.outline, 0.5)!,
      rows: 0,
      columns: 12,
      width: 0.45,
    )
    ..shadeCorners(strength: 0.5)
    ..edges(const Color(0xAA0A0806));
  a
    ..ink(wall, width: 0.5)
    ..fade(
      Rect.fromLTRB(0, 0, a.size.width, wall.top + wall.height * 0.2),
      const Color(0x99000000),
      const Color(0x00000000),
    );
  return room;
}

/// A door in a side wall ([x] 0 or 1), from depth [z0] to [z1], [height]
/// tall: its leaf in perspective, with its frame. Returns the leaf's
/// corners (top near, top far, bottom far, bottom near).
List<Offset> _sideDoor(
  Art a,
  Room room,
  double x,
  double z0,
  double z1, {
  double height = 0.7,
  Color leaf = const Color(0xFF3E2C1E),
}) {
  Offset p(double y, double z) => room.at(x, y, z);
  final frame = [
    p(height + 0.03, z0 - 0.02),
    p(height + 0.03, z1 + 0.02),
    p(0, z1 + 0.02),
    p(0, z0 - 0.02),
  ];
  final door = [p(height, z0), p(height, z1), p(0, z1), p(0, z0)];
  a
    ..path(a.poly(frame), const Color(0xFF2A1E14), line: 0.5)
    ..path(a.poly(door), leaf, line: 0.5);
  for (var i = 1; i < 4; i++) {
    final z = z0 + (z1 - z0) * i / 4;
    a.hairline(p(height, z), p(0, z), Color.lerp(leaf, Art.outline, 0.4)!, 0.4);
  }
  return door;
}

// ---------------------------------------------------------------------------
// Scenes

void _station(Art a) {
  // Green distemper above, brown dado below, a board floor.
  final room = _interior(
    a,
    eye: const Offset(0.5, 0.34),
    depth: 0.66,
    dado: _dado,
    dadoTop: 0.3,
  );
  // The file room door in the left wall, with its plate.
  final door = _sideDoor(a, room, 0, 0.25, 0.6, height: 0.7);
  final plate = [
    for (final (y, z) in [(0.6, 0.33), (0.6, 0.5), (0.55, 0.5), (0.55, 0.33)])
      room.at(0, y, z),
  ];
  a
    ..path(a.poly(plate), StillroomPalette.brass, line: 0.3)
    ..circle(
      Offset.lerp(door[3], door[1], 0.55)!,
      a.u * 0.9,
      StillroomPalette.brass,
      line: 0.3,
    );
  // The street door in the right wall, a lit fanlight over it.
  _sideDoor(a, room, 1, 0.2, 0.55, height: 0.7);
  final fan = [
    for (final (y, z) in [(0.82, 0.2), (0.82, 0.55), (0.74, 0.55), (0.74, 0.2)])
      room.at(1, y, z),
  ];
  a
    ..path(a.poly(fan), const Color(0xFF2A3440), line: 0.5)
    ..glow(
      Offset.lerp(fan[0], fan[2], 0.5)!,
      a.size.width * 0.04,
      _gas,
      strength: 0.25,
    )
    ..circle(
      room.at(1, 0.36, 0.5),
      a.u * 0.9,
      StillroomPalette.brass,
      line: 0.3,
    );
  // The notice board, with yellowed bills.
  final board = a.r(0.2, 0.18, 0.16, 0.24);
  a
    ..box(board.inflate(a.u * 0.8), _dado, line: 0.5)
    ..box(board, const Color(0xFF4A4030), line: 0.3);
  for (final (x, y, w, h, t) in [
    (0.21, 0.19, 0.06, 0.1, -0.04),
    (0.28, 0.2, 0.07, 0.09, 0.03),
    (0.22, 0.3, 0.07, 0.1, 0.02),
    (0.3, 0.3, 0.05, 0.1, -0.05),
  ]) {
    a.paper(
      a.r(x, y, w, h),
      lines: 3,
      angle: t,
      color: const Color(0xFFC8B888),
    );
  }
  a.label(
    'MURDER',
    a.p(0.24, 0.215),
    a.size.height * 0.016,
    const Color(0xFF2A1F17),
  );
  // The gas bracket.
  _gasLamp(a, a.p(0.65, 0.22), a.size.height * 0.025);
  // The counter, standing out on the boards, and the occurrence book open
  // on a sloped desk.
  room.shadow(0.2, 0.8, 0.3, 0.45);
  final counter = room.block(
    0.2,
    0.8,
    0,
    0.3,
    0.3,
    0.45,
    const Color(0xFF3A2A1E),
    top: const Color(0xFF4A3524),
  );
  a.wood(counter, base: const Color(0xFF3A2A1E), vertical: true, grain: 8);
  final book = a.r(0.37, 0.52, 0.22, 0.12);
  a.path(
    a.poly([
      book.bottomLeft,
      book.bottomRight,
      a.p(0.58, 0.54),
      a.p(0.38, 0.54),
    ]),
    const Color(0xFF2A1E14),
  );
  a
    ..paper(
      Rect.fromLTRB(
        book.left + a.u,
        book.top + a.u * 2,
        book.center.dx,
        book.bottom - a.u,
      ),
      lines: 6,
    )
    ..paper(
      Rect.fromLTRB(
        book.center.dx,
        book.top + a.u * 2,
        book.right - a.u,
        book.bottom - a.u,
      ),
      lines: 5,
    )
    ..line(
      Offset(book.center.dx, book.top + a.u * 2),
      Offset(book.center.dx, book.bottom - a.u),
      Art.outline,
      width: 0.5,
    );
  // An inkwell and a pen.
  a
    ..box(a.r(0.6, 0.6, 0.02, 0.03), const Color(0xFF1A1A1C), line: 0.3)
    ..line(a.p(0.61, 0.6), a.p(0.63, 0.55), Art.outline, width: 0.4);
  // A helmet on a peg.
  a
    ..box(a.r(0.79, 0.34, 0.006, 0.03), _dado, line: 0.2)
    ..path(
      a.poly([
        a.p(0.772, 0.43),
        a.p(0.778, 0.37),
        a.p(0.795, 0.355),
        a.p(0.812, 0.37),
        a.p(0.818, 0.43),
      ]),
      const Color(0xFF15181E),
      line: 0.4,
    )
    ..circle(a.p(0.795, 0.4), a.u * 0.8, StillroomPalette.brass, line: 0.2);
}

void _arch(Art a) {
  a.fill(Offset.zero & a.size, _night);
  // The railway viaduct: brick piers and the girder of the bridge on top.
  _bricks(a, a.r(0, 0.1, 1, 0.66));
  a
    ..fill(a.r(0, 0.02, 1, 0.1), const Color(0xFF1E2024))
    ..ink(a.r(0, 0.02, 1, 0.1))
    ..fade(
      a.r(0, 0.1, 1, 0.66),
      const Color(0x55000000),
      const Color(0x22000000),
    );
  for (var x = 0.02; x < 1; x += 0.06) {
    a.box(a.r(x, 0.04, 0.012, 0.06), const Color(0xFF2E3036), line: 0.2);
  }
  // The arch itself: a deep dark tunnel.
  final arch = Path()
    ..moveTo(a.p(0.32, 0.76).dx, a.p(0.32, 0.76).dy)
    ..lineTo(a.p(0.32, 0.46).dx, a.p(0.32, 0.46).dy)
    ..arcToPoint(a.p(0.68, 0.46), radius: Radius.circular(a.size.width * 0.18))
    ..lineTo(a.p(0.68, 0.76).dx, a.p(0.68, 0.76).dy)
    ..close();
  a.path(arch, const Color(0xFF070608), line: 0.8);
  a.canvas
    ..save()
    ..clipPath(arch);
  // The tunnel running back under the line: its vault and walls drawn in
  // to the far mouth, where the street beyond shows grey.
  final vp = a.p(0.5, 0.62);
  Offset far(Offset p) => Offset.lerp(p, vp, 0.62)!;
  final mouth = Path()
    ..moveTo(far(a.p(0.32, 0.76)).dx, far(a.p(0.32, 0.76)).dy)
    ..lineTo(far(a.p(0.32, 0.46)).dx, far(a.p(0.32, 0.46)).dy)
    ..arcToPoint(
      far(a.p(0.68, 0.46)),
      radius: Radius.circular(a.size.width * 0.18 * 0.38),
    )
    ..lineTo(far(a.p(0.68, 0.76)).dx, far(a.p(0.68, 0.76)).dy)
    ..close();
  a
    ..path(mouth, const Color(0xFF1E242C), line: 0.4)
    ..glow(
      a.p(0.5, 0.66),
      a.size.width * 0.12,
      const Color(0xFF3A4450),
      strength: 0.3,
    );
  for (var i = 0; i <= 8; i++) {
    final t = math.pi + i * math.pi / 8;
    final c = a.p(0.5, 0.46);
    final r = a.size.width * 0.18;
    final p = c + Offset(math.cos(t) * r, math.sin(t) * r);
    a.hairline(p, far(p), const Color(0x552A1A14), 0.4);
  }
  for (final x in [0.32, 0.68]) {
    a.hairline(a.p(x, 0.76), far(a.p(x, 0.76)), const Color(0x552A1A14), 0.4);
  }
  a.fill(a.r(0.46, 0.5, 0.08, 0.26), const Color(0x880E1014));
  a.canvas.restore();
  // Voussoirs round the arch.
  for (var i = 0; i <= 12; i++) {
    final t = math.pi + i * math.pi / 12;
    final c = a.p(0.5, 0.46);
    final r = a.size.width * 0.18;
    a.line(
      c + Offset(math.cos(t) * r, math.sin(t) * r),
      c + Offset(math.cos(t) * r * 1.12, math.sin(t) * r * 1.12),
      _brickDark,
      width: 0.6,
    );
  }
  // The street corner, left, towards Nottingham Street.
  a
    ..fill(a.r(0, 0.3, 0.13, 0.46), const Color(0xFF1A1A1E))
    ..box(a.r(0.02, 0.4, 0.06, 0.08), const Color(0xFF3A3020), line: 0.4)
    ..glow(a.p(0.05, 0.44), a.size.width * 0.04, _gas, strength: 0.25);
  // The gas lamp on its post.
  a.canvas.drawOval(
    a.r(0.13, 0.755, 0.04, 0.012),
    Paint()
      ..color = const Color(0x88000000)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, a.u * 0.6),
  );
  a
    ..box(a.r(0.145, 0.3, 0.008, 0.46), const Color(0xFF1E1E22), line: 0.3)
    ..box(a.r(0.132, 0.18, 0.034, 0.12), const Color(0xFF2A2A2E), line: 0.4);
  _gasLamp(a, a.p(0.149, 0.25), a.size.height * 0.03, glow: 0.45);
  // Wet cobbles.
  _wetCobbles(a, 0.76, light: a.p(0.15, 0.82));
  // The chalk: a constable's mark on the stones.
  a.canvas.drawPath(
    Path()
      ..moveTo(a.p(0.3, 0.84).dx, a.p(0.3, 0.84).dy)
      ..lineTo(a.p(0.4, 0.83).dx, a.p(0.4, 0.83).dy)
      ..moveTo(a.p(0.33, 0.81).dx, a.p(0.33, 0.81).dy)
      ..lineTo(a.p(0.36, 0.86).dx, a.p(0.36, 0.86).dy),
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = a.u * 0.6
      ..color = const Color(0xCCE8E4DA),
  );
  // The hat, at the mouth of the arch.
  _hat(a, a.r(0.462, 0.705, 0.095, 0.085));
  // A hansom cab waiting, right, its side to us and its shadow on the
  // stones.
  a.canvas.drawOval(
    a.r(0.81, 0.75, 0.18, 0.03),
    Paint()
      ..color = const Color(0x88000000)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, a.u * 1.2),
  );
  a
    ..path(
      a.poly([
        a.p(0.84, 0.5),
        a.p(0.82, 0.48),
        a.p(0.82, 0.64),
        a.p(0.84, 0.66),
      ]),
      const Color(0xFF101012),
      line: 0.4,
    )
    ..box(a.r(0.84, 0.5, 0.1, 0.16), const Color(0xFF1A1A1C), line: 0.5)
    ..box(a.r(0.845, 0.52, 0.05, 0.06), const Color(0xFF3A3430), line: 0.3)
    ..circle(
      a.p(0.88, 0.7),
      a.size.height * 0.06,
      const Color(0x00000000),
      line: 1,
    )
    ..line(a.p(0.94, 0.62), a.p(0.99, 0.6), Art.outline, width: 1.2)
    ..box(a.r(0.83, 0.47, 0.12, 0.03), const Color(0xFF15151A), line: 0.4)
    ..glow(a.p(0.95, 0.52), a.size.width * 0.03, _gas, strength: 0.4);
  // Rain.
  final random = math.Random(4);
  for (var i = 0; i < 70; i++) {
    final x = random.nextDouble();
    final y = random.nextDouble();
    a.hairline(
      a.p(x, y),
      a.p(x - 0.004, y + 0.03),
      const Color(0x44B8C4D0),
      0.3,
    );
  }
}

void _milliner(Art a) {
  // A small shop: papered walls, a counter, the shutters up.
  final room = _interior(
    a,
    eye: const Offset(0.5, 0.32),
    depth: 0.68,
    low: const Color(0xFF3A2E30),
    dado: _dado,
    dadoTop: 0.18,
    back: (wall) =>
        a.wallpaper(wall, const Color(0xFF3A2E30), const Color(0xFF443638)),
  );
  // Hats on stands and boxes on two shelves, left.
  room
    ..box(a.r(0.17, 0.34, 0.24, 0.02), _dado, depth: 0.05, line: 0.4)
    ..box(a.r(0.17, 0.5, 0.24, 0.02), _dado, depth: 0.05, line: 0.4);
  for (final (x, color) in [
    (0.19, const Color(0xFFC8A868)),
    (0.26, const Color(0xFF3A3A40)),
    (0.33, const Color(0xFF5A3A40)),
  ]) {
    a
      ..box(a.r(x + 0.025, 0.26, 0.006, 0.08), _dado, line: 0.2)
      ..oval(a.r(x, 0.24, 0.06, 0.03), color, line: 0.4)
      ..rbox(a.r(x + 0.012, 0.2, 0.036, 0.05), a.u, color, line: 0.4);
  }
  for (final (x, y) in [(0.18, 0.4), (0.255, 0.42), (0.33, 0.39)]) {
    a
      ..box(a.r(x, y, 0.07, 0.5 - y), const Color(0xFFB8A888), line: 0.4)
      ..fill(a.r(x, y, 0.07, 0.02), const Color(0xFF8A6A4A));
  }
  // The counter, the order book open on it, a roll of crêpe at the end.
  room.shadow(0.22, 0.78, 0.25, 0.4);
  final counter = room.block(
    0.22,
    0.78,
    0,
    0.28,
    0.25,
    0.4,
    const Color(0xFF4A3424),
    top: const Color(0xFF5A4030),
  );
  a.wood(counter, base: const Color(0xFF4A3424), vertical: true, grain: 6);
  final book = a.r(0.41, 0.6, 0.18, 0.08);
  a
    ..paper(
      Rect.fromLTRB(book.left, book.top, book.center.dx, book.bottom),
      lines: 4,
    )
    ..paper(
      Rect.fromLTRB(book.center.dx, book.top, book.right, book.bottom),
      lines: 3,
    )
    ..rbox(a.r(0.6, 0.64, 0.12, 0.04), a.u * 2, _crepe, line: 0.5)
    ..oval(a.r(0.71, 0.64, 0.015, 0.04), const Color(0xFF2A2428), line: 0.3);
  // The window, deep in the wall, shuttered.
  final win = a.r(0.62, 0.15, 0.2, 0.38);
  room.recess(win.inflate(a.u * 2), const Color(0xFF3A2E30), thickness: 0.03);
  a.box(win.inflate(a.u), _dado, line: 0.5);
  for (var i = 0; i < 2; i++) {
    final leaf = Rect.fromLTWH(
      win.left + win.width * i / 2,
      win.top,
      win.width / 2,
      win.height,
    );
    a.wood(leaf, base: const Color(0xFF3A2E24), grain: 6);
  }
  a
    ..box(a.r(0.615, 0.33, 0.21, 0.02), const Color(0xFF2A2A2C), line: 0.4)
    ..glow(a.p(0.5, 0.3), a.size.width * 0.3, _gas, strength: 0.12);
  _gasLamp(a, a.p(0.5, 0.12), a.size.height * 0.022);
}

void _press(Art a) {
  final room = _interior(
    a,
    eye: const Offset(0.5, 0.3),
    depth: 0.7,
    top: const Color(0xFF1E1C1A),
    low: const Color(0xFF2E2A24),
  );
  // The type case cabinet, left: a frame, and the case sloping up on it,
  // its compartments in rows.
  const caseWood = Color(0xFF4A3524);
  room.shadow(0.02, 0.28, 0.3, 0.5);
  final frame = room.block(0.02, 0.28, 0, 0.3, 0.3, 0.5, caseWood);
  a.wood(frame, base: caseWood, vertical: true, grain: 4);
  Offset slope(double u, double v) =>
      room.at(0.01 + 0.28 * u, 0.3 + 0.1 * v, 0.29 + 0.22 * v);
  a.path(
    a.poly([slope(0, 0), slope(1, 0), slope(1, 1), slope(0, 1)]),
    const Color(0xFF5A4232),
    line: 0.6,
  );
  for (var r = 1; r < 4; r++) {
    a.hairline(slope(0.03, r / 4), slope(0.97, r / 4), Art.outline, 0.3);
  }
  for (var c = 1; c < 8; c++) {
    a.hairline(slope(c / 8, 0.03), slope(c / 8, 0.97), Art.outline, 0.3);
  }
  // The imposing stone on its frame, and the forme on it: a chase of type,
  // the headline backwards.
  final base = room.stand(
    a.r(0.34, 0.68, 0.3, 0.16),
    const Color(0xFF3A2A1E),
    deep: 0.18,
  );
  final z = room.floorDepthAt(base.bottom);
  final x0 = room.xAt(base.left, z);
  final x1 = room.xAt(base.right, z);
  final h = room.yAt(base.top, z);
  room.block(
    x0 - 0.02,
    x1 + 0.02,
    h,
    h + 0.035,
    z - 0.01,
    z + 0.19,
    const Color(0xFF5A5A5E),
  );
  final chase = a.r(0.35, 0.46, 0.28, 0.18);
  a
    ..box(chase, const Color(0xFF6E6E72), line: 0.6)
    ..box(chase.deflate(a.u * 1.2), const Color(0xFF2A2A2E), line: 0.3);
  a.canvas
    ..save()
    ..translate(chase.center.dx, 0)
    ..scale(-1, 1)
    ..translate(-chase.center.dx, 0);
  a.label(
    'JACK THE RIPPER AGAIN?',
    Offset(chase.center.dx, chase.top + chase.height * 0.22),
    chase.height * 0.13,
    const Color(0xFFB8B8BC),
  );
  a.canvas.restore();
  for (var i = 0; i < 6; i++) {
    final y = chase.top + chase.height * (0.42 + i * 0.09);
    a.hairline(
      Offset(chase.left + chase.width * 0.08, y),
      Offset(chase.right - chase.width * (i.isOdd ? 0.2 : 0.08), y),
      const Color(0xFF8A8A8E),
      0.8,
    );
  }
  // The spike of papers, on a bracket on the wall.
  room.box(a.r(0.71, 0.48, 0.1, 0.015), _dado, depth: 0.05, line: 0.4);
  a
    ..box(a.r(0.74, 0.46, 0.04, 0.02), const Color(0xFF2A2A2C), line: 0.3)
    ..line(
      a.p(0.76, 0.46),
      a.p(0.76, 0.26),
      const Color(0xFF6A6A6E),
      width: 0.6,
    );
  for (var i = 0; i < 4; i++) {
    a.paper(
      a.r(0.725, 0.3 + i * 0.035, 0.07, 0.05),
      lines: 2,
      angle: (i - 1.5) * 0.08,
    );
  }
  // The press, right: an iron hand press.
  room.stand(a.r(0.8, 0.62, 0.14, 0.24), const Color(0xFF26282C), deep: 0.16);
  room.box(a.r(0.78, 0.6, 0.18, 0.03), const Color(0xFF34363A), depth: 0.05);
  a
    ..box(a.r(0.84, 0.66, 0.06, 0.1), const Color(0xFF1A1C20), line: 0.4)
    ..line(
      a.p(0.94, 0.66),
      a.p(0.99, 0.58),
      const Color(0xFF34363A),
      width: 1.4,
    );
  // Gas over the stone.
  _gasLamp(a, a.p(0.5, 0.14), a.size.height * 0.025, glow: 0.4);
}

void _fileRoom(Art a) {
  final room = _interior(a, eye: const Offset(0.5, 0.3), depth: 0.68);
  // The shelves of the file, packed with bundles: a press standing
  // against the back wall, a cupboard below.
  final press = room.stand(
    a.r(0.18, 0.13, 0.64, 0.67),
    const Color(0xFF2A1E14),
    deep: 0.12,
  );
  final shelf = Rect.fromLTRB(
    press.left + a.u,
    press.top + a.u,
    press.right - a.u,
    a.p(0, 0.64).dy,
  );
  a
    ..fill(shelf, const Color(0xFF140E0A))
    ..wood(
      Rect.fromLTRB(press.left, shelf.bottom, press.right, press.bottom),
      base: _dado,
      vertical: true,
      grain: 6,
    );
  final random = math.Random(1891);
  for (var r = 0; r < 3; r++) {
    final top = shelf.top + shelf.height * r / 3;
    final bottom = top + shelf.height / 3;
    a.wood(
      Rect.fromLTRB(shelf.left, bottom - a.u * 1.2, shelf.right, bottom),
      base: _dado,
      grain: 1,
    );
    var x = shelf.left + a.u;
    while (x < shelf.right - a.u * 3) {
      final w = a.size.width * (0.018 + random.nextDouble() * 0.02);
      final h = (bottom - top) * (0.6 + random.nextDouble() * 0.3);
      a.box(
        Rect.fromLTWH(x, bottom - a.u * 1.2 - h, w, h),
        Color.lerp(
          const Color(0xFF6E5A40),
          const Color(0xFF8A7050),
          random.nextDouble(),
        )!,
        line: 0.4,
      );
      a.fill(
        Rect.fromLTWH(x, bottom - a.u * 1.2 - h * 0.7, w, a.u * 0.6),
        const Color(0xFF8A2A22),
      );
      x += w + a.u * 0.3;
    }
  }
  // The table, the cover sheet on it.
  room.standTable(
    a.r(0.3, 0.74, 0.6, 0.24),
    const Color(0xFF4A3524),
    deep: 0.25,
    thickness: 0.03,
    leg: 0.02,
    legColor: _dado,
  );
  a
    ..paper(
      a.r(0.41, 0.66, 0.18, 0.08),
      lines: 3,
      angle: 0.02,
      color: const Color(0xFFD9C9A0),
    )
    ..label(
      'WHITECHAPEL MURDERS',
      a.p(0.5, 0.685),
      a.size.height * 0.014,
      const Color(0xFF2A2420),
    );
  // The hanging gas lamp.
  a.line(a.p(0.89, 0), a.p(0.89, 0.14), const Color(0xFF3A3A3A), width: 0.6);
  _gasLamp(a, a.p(0.89, 0.18), a.size.height * 0.03, glow: 0.4);
}

void _shelfBoard(Art a) {
  a
    ..fade(Offset.zero & a.size, _wallLow, _wall)
    ..glow(a.p(0.9, 0.05), a.size.width * 0.5, _gas, strength: 0.12);
}

void _caseBoard(Art a) {
  a
    ..wood(
      Offset.zero & a.size,
      base: const Color(0xFF2E221A),
      grain: 8,
      line: 0,
    )
    ..glow(a.p(0.5, 0.1), a.size.width * 0.5, _gas, strength: 0.12)
    ..fade(
      Offset.zero & a.size,
      const Color(0x00000000),
      const Color(0x66000000),
    );
}

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
  _bricks(a, a.r(0, 0.16, 1, 0.84));
  final arch = Path()
    ..moveTo(a.p(0.26, 0.9).dx, a.p(0.26, 0.9).dy)
    ..lineTo(a.p(0.26, 0.56).dx, a.p(0.26, 0.56).dy)
    ..arcToPoint(a.p(0.74, 0.56), radius: Radius.circular(w * 0.24))
    ..lineTo(a.p(0.74, 0.9).dx, a.p(0.74, 0.9).dy)
    ..close();
  a
    ..path(arch, const Color(0xFF070608), line: 0.5)
    ..fill(a.r(0, 0.86, 1, 0.14), _cobble)
    ..glow(a.p(0.2, 0.5), w * 0.3, _gas, strength: 0.3);
  _hat(a, a.r(0.4, 0.8, 0.2, 0.1));
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
