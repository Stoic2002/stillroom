import 'dart:math' as math;
import 'dart:ui';

import '../theme/stillroom_palette.dart';
import 'art_kit.dart';
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

// ---------------------------------------------------------------------------
// Scenes

void _station(Art a) {
  // Green distemper above, brown dado below, a board floor.
  a
    ..fade(a.r(0, 0, 1, 0.58), _wallLow, _wall)
    ..wood(a.r(0, 0.58, 1, 0.2), base: _dado, vertical: true, grain: 16)
    ..floorboards(a.r(0, 0.78, 1, 0.22));
  // The file room door, left, with its plate.
  final door = a.r(0.03, 0.28, 0.11, 0.5);
  a
    ..box(door.inflate(a.u), const Color(0xFF2A1E14), line: 0.5)
    ..wood(door, base: const Color(0xFF3E2C1E), vertical: true, grain: 3)
    ..box(a.r(0.05, 0.36, 0.07, 0.035), StillroomPalette.brass, line: 0.3)
    ..label(
      'RECORDS',
      a.p(0.085, 0.3775),
      a.size.height * 0.018,
      const Color(0xFF2A1E14),
    )
    ..circle(a.p(0.125, 0.55), a.u * 0.9, StillroomPalette.brass, line: 0.3);
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
  // The counter, and the occurrence book open on a sloped desk.
  a
    ..wood(a.r(0.22, 0.64, 0.6, 0.06), base: const Color(0xFF4A3524), grain: 2)
    ..wood(
      a.r(0.24, 0.7, 0.56, 0.1),
      base: const Color(0xFF3A2A1E),
      vertical: true,
      grain: 8,
    );
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
  // The street door, right, a lit fanlight over it.
  final street = a.r(0.85, 0.3, 0.12, 0.5);
  a
    ..box(street.inflate(a.u), const Color(0xFF2A1E14), line: 0.5)
    ..wood(street, base: const Color(0xFF3E2C1E), vertical: true, grain: 3)
    ..box(a.r(0.855, 0.24, 0.11, 0.05), const Color(0xFF2A3440), line: 0.5)
    ..glow(a.p(0.91, 0.265), a.size.width * 0.04, _gas, strength: 0.25)
    ..circle(a.p(0.865, 0.56), a.u * 0.9, StillroomPalette.brass, line: 0.3);
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
  a
    ..glow(
      a.p(0.5, 0.66),
      a.size.width * 0.12,
      const Color(0xFF3A4450),
      strength: 0.3,
    )
    ..fill(a.r(0.46, 0.5, 0.08, 0.26), const Color(0xFF0E1014));
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
  // A hansom cab waiting, right.
  a
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
  a
    ..wallpaper(
      a.r(0, 0, 1, 0.66),
      const Color(0xFF3A2E30),
      const Color(0xFF443638),
    )
    ..wood(a.r(0, 0.66, 1, 0.12), base: _dado, vertical: true, grain: 14)
    ..floorboards(a.r(0, 0.78, 1, 0.22))
    ..fade(a.r(0, 0, 1, 1), const Color(0x33000000), const Color(0x66000000));
  // Hats on stands and boxes on a shelf, left.
  a.wood(a.r(0.07, 0.34, 0.24, 0.02), base: _dado, grain: 1);
  for (final (x, color) in [
    (0.09, const Color(0xFFC8A868)),
    (0.16, const Color(0xFF3A3A40)),
    (0.23, const Color(0xFF5A3A40)),
  ]) {
    a
      ..box(a.r(x + 0.025, 0.26, 0.006, 0.08), _dado, line: 0.2)
      ..oval(a.r(x, 0.24, 0.06, 0.03), color, line: 0.4)
      ..rbox(a.r(x + 0.012, 0.2, 0.036, 0.05), a.u, color, line: 0.4);
  }
  for (final (x, y) in [(0.08, 0.4), (0.16, 0.42), (0.23, 0.39)]) {
    a
      ..box(a.r(x, y, 0.07, 0.1), const Color(0xFFB8A888), line: 0.4)
      ..fill(a.r(x, y, 0.07, 0.02), const Color(0xFF8A6A4A));
  }
  // The counter, the order book open on it, a roll of crêpe at the end.
  a
    ..wood(a.r(0.34, 0.64, 0.5, 0.05), base: const Color(0xFF5A4030), grain: 2)
    ..wood(
      a.r(0.35, 0.69, 0.48, 0.12),
      base: const Color(0xFF4A3424),
      vertical: true,
      grain: 6,
    );
  final book = a.r(0.41, 0.56, 0.18, 0.08);
  a
    ..paper(
      Rect.fromLTRB(book.left, book.top, book.center.dx, book.bottom),
      lines: 4,
    )
    ..paper(
      Rect.fromLTRB(book.center.dx, book.top, book.right, book.bottom),
      lines: 3,
    )
    ..rbox(a.r(0.645, 0.6, 0.12, 0.04), a.u * 2, _crepe, line: 0.5)
    ..oval(a.r(0.755, 0.6, 0.015, 0.04), const Color(0xFF2A2428), line: 0.3);
  // The window, shuttered.
  final win = a.r(0.71, 0.15, 0.2, 0.38);
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
    ..box(a.r(0.705, 0.33, 0.21, 0.02), const Color(0xFF2A2A2C), line: 0.4)
    ..glow(a.p(0.5, 0.3), a.size.width * 0.3, _gas, strength: 0.12);
  _gasLamp(a, a.p(0.5, 0.12), a.size.height * 0.022);
}

void _press(Art a) {
  a
    ..fade(a.r(0, 0, 1, 0.8), const Color(0xFF1E1C1A), const Color(0xFF2E2A24))
    ..floorboards(a.r(0, 0.8, 1, 0.2));
  // The type case cabinet, left: a sloped case on a frame.
  a
    ..wood(
      a.r(0.06, 0.62, 0.22, 0.2),
      base: const Color(0xFF4A3524),
      vertical: true,
      grain: 4,
    )
    ..path(
      a.poly([
        a.p(0.05, 0.62),
        a.p(0.29, 0.62),
        a.p(0.27, 0.5),
        a.p(0.07, 0.5),
      ]),
      const Color(0xFF5A4232),
    );
  for (var r = 0; r < 4; r++) {
    for (var c = 0; c < 8; c++) {
      a.ink(
        Rect.fromLTWH(
          a.size.width * (0.075 + c * 0.024 + r * 0.002),
          a.size.height * (0.51 + r * 0.027),
          a.size.width * 0.022,
          a.size.height * 0.025,
        ),
        width: 0.25,
      );
    }
  }
  // The imposing stone and the forme on it: a chase of type, the headline
  // backwards.
  a
    ..box(a.r(0.32, 0.64, 0.34, 0.04), const Color(0xFF5A5A5E), line: 0.5)
    ..box(a.r(0.34, 0.68, 0.3, 0.14), const Color(0xFF3A2A1E), line: 0.5);
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
  // The spike of papers.
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
  a
    ..box(a.r(0.8, 0.62, 0.14, 0.24), const Color(0xFF26282C), line: 0.6)
    ..box(a.r(0.78, 0.6, 0.18, 0.03), const Color(0xFF34363A), line: 0.5)
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
  a
    ..fade(a.r(0, 0, 1, 0.7), _wallLow, _wall)
    ..floorboards(a.r(0, 0.7, 1, 0.3));
  // The shelves of the file, packed with bundles.
  final shelf = a.r(0.18, 0.14, 0.64, 0.5);
  a.box(shelf.inflate(a.u), const Color(0xFF2A1E14), line: 0.6);
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
  a
    ..wood(a.r(0.3, 0.8, 0.6, 0.04), base: const Color(0xFF4A3524), grain: 1)
    ..box(a.r(0.32, 0.84, 0.02, 0.14), _dado, line: 0.4)
    ..box(a.r(0.86, 0.84, 0.02, 0.14), _dado, line: 0.4)
    ..paper(
      a.r(0.41, 0.72, 0.18, 0.09),
      lines: 3,
      angle: 0.02,
      color: const Color(0xFFD9C9A0),
    )
    ..label(
      'WHITECHAPEL MURDERS',
      a.p(0.5, 0.745),
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
