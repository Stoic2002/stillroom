import 'dart:math' as math;
import 'dart:ui';

import '../theme/stillroom_palette.dart';
import 'art_kit.dart';
import 'depth_kit.dart';
import 'echo_art.dart';
import 'whitechapel_1888_art.dart' show jarLabelBoard;

/// Code-drawn art for "Dyatlov Pass, 1959" (docs/episodes/dyatlov_1959.md):
/// the eastern slope of Kholat Syakhl during the search, late February
/// 1959. The tent half buried on its cut platform, the raised footprints
/// going down, the cedar at the forest edge, the search camp's tent, and
/// the investigators' darkroom in Ivdel. None of the nine is drawn; the
/// figures in their last frames are small and faceless.
const _s = 'images/scenes/dyatlov_1959';
const _o = 'images/objects/dyatlov_1959';

final Map<String, ArtPainter> dyatlov1959Art = {
  // Scenes and puzzle boards.
  '$_s/slope.png': (c, s) => _slope(Art(c, s)),
  '$_s/cedar.png': (c, s) => _cedar(Art(c, s)),
  '$_s/camp.png': (c, s) => _camp(Art(c, s)),
  '$_s/darkroom.png': (c, s) => _darkroom(Art(c, s)),
  '$_s/pit_board.png': (c, s) => _pitBoard(Art(c, s)),
  '$_s/darkroom_board.png': (c, s) => _darkroomBoard(Art(c, s)),
  '$_s/label_close.png': (c, s) => jarLabelBoard(Art(c, s), _canvasDark),
  // Objects.
  '$_o/kit_sprite.png': (c, s) => _kit(Art(c, s)),
  '$_o/later_sprite.png': (c, s) => _papers(Art(c, s)),
  '$_o/prints_sprite.png': (c, s) => _prints(Art(c, s)),
  for (var i = 1; i <= 4; i++)
    '$_o/frame_$i.png': (c, s) => _frame(Art(c, s), i),
  '$_o/echo_searcher.png': (c, s) => paintEcho(Art(c, s), EchoFigure.searcher),
  '$_o/echo_investigator.png': (c, s) =>
      paintEcho(Art(c, s), EchoFigure.investigator),
  // The jar on the shelf.
  'images/ui/jar_dyatlov_1959.png': (c, s) => _jar(Art(c, s)),
};

// ---------------------------------------------------------------------------
// Palette

const _skyHigh = Color(0xFF6E7884);
const _sky = Color(0xFFB4BAC0);
const _snow = Color(0xFFEDF0F3);
const _snowShade = Color(0xFFC6CED8);
const _snowDeep = Color(0xFF9EA8B6);
const _rock = Color(0xFF5A5C60);
const _forest = Color(0xFF26302C);
const _bark = Color(0xFF4A3A30);
const _needles = Color(0xFF2E3E34);
const _canvas = Color(0xFFB6AE96);
const _canvasDark = Color(0xFF6E6656);
const _wood = Color(0xFF6A4E36);
const _paper = Color(0xFFE6E0D0);
const _red = Color(0xFFB0302A);
const _lamp = StillroomPalette.gaslight;

// ---------------------------------------------------------------------------
// Shared pieces

/// Snow blowing across: thin streaks low over the surface.
void _drift(Art a, {int seed = 3, int count = 40, double top = 0.3}) {
  final random = math.Random(seed);
  for (var i = 0; i < count; i++) {
    final y = a.size.height * (top + random.nextDouble() * (1 - top));
    final x = random.nextDouble() * a.size.width;
    a.hairline(
      Offset(x, y),
      Offset(x + a.u * (4 + random.nextDouble() * 10), y - a.u * 0.4),
      const Color(0x88FFFFFF),
      0.25,
    );
  }
}

/// A spruce or larch under snow: a dark spire with white on its tiers.
void _spruce(Art a, Offset base, double height, {Color color = _forest}) {
  final w = height * 0.32;
  for (var i = 0; i < 4; i++) {
    final bottom = base.dy - height * (0.05 + i * 0.22);
    final top = bottom - height * 0.34;
    final half = w * (0.5 - i * 0.1);
    a
      ..path(
        a.poly([
          Offset(base.dx - half, bottom),
          Offset(base.dx, top),
          Offset(base.dx + half, bottom),
        ]),
        color,
        line: 0,
      )
      ..line(
        Offset(base.dx - half * 0.6, bottom - height * 0.06),
        Offset(base.dx, top + height * 0.03),
        _snow.withValues(alpha: 0.8),
        width: 0.4,
      );
  }
}

/// A small faceless figure, [h] tall, at [foot]: a hooded body and legs.
void _figure(Art a, Offset foot, double h, {double lean = 0, Color? color}) {
  final c = color ?? const Color(0xFF2A2C30);
  a.canvas
    ..save()
    ..translate(foot.dx, foot.dy)
    ..rotate(lean);
  a
    ..path(
      a.poly([
        Offset(-h * 0.14, -h * 0.75),
        Offset(h * 0.14, -h * 0.75),
        Offset(h * 0.18, -h * 0.35),
        Offset(-h * 0.18, -h * 0.35),
      ]),
      c,
      line: 0,
    )
    ..circle(Offset(0, -h * 0.85), h * 0.1, c, line: 0)
    ..line(Offset(-h * 0.08, -h * 0.36), Offset(-h * 0.1, 0), c, width: 0.7)
    ..line(Offset(h * 0.08, -h * 0.36), Offset(h * 0.1, 0), c, width: 0.7);
  a.canvas.restore();
}

/// The Soviet ridge tent, long and low, seen across the slope: [r] its
/// outline; slit along its side when [slit].
void _tent(Art a, Rect r, {bool buried = true, bool slit = true}) {
  final ridgeL = Offset(r.left + r.width * 0.06, r.top);
  final ridgeR = Offset(r.right - r.width * 0.06, r.top + r.height * 0.08);
  a
    ..path(
      a.poly([ridgeL, ridgeR, r.bottomRight, r.bottomLeft]),
      _canvas,
      line: 0.5,
    )
    ..line(ridgeL, ridgeR, _canvasDark, width: 0.6);
  // The canvas sagging between the poles.
  for (var k = 1; k < 4; k++) {
    final t = k / 4;
    a.hairline(
      Offset.lerp(ridgeL, ridgeR, t)!,
      Offset(r.left + r.width * t, r.bottom),
      const Color(0x55403A2E),
      0.3,
    );
  }
  if (slit) {
    for (final (x, len) in [(0.32, 0.5), (0.46, 0.62), (0.58, 0.4)]) {
      final top = Offset(r.left + r.width * x, r.top + r.height * 0.25);
      a.line(
        top,
        top.translate(r.width * 0.02, r.height * len),
        const Color(0xFF1E1C18),
        width: 0.9,
      );
    }
  }
  if (buried) {
    a.path(
      Path()
        ..moveTo(r.left - r.width * 0.05, r.bottom)
        ..quadraticBezierTo(
          r.left + r.width * 0.3,
          r.top + r.height * 0.15,
          r.left + r.width * 0.62,
          r.top + r.height * 0.55,
        )
        ..quadraticBezierTo(
          r.right,
          r.bottom - r.height * 0.1,
          r.right + r.width * 0.05,
          r.bottom,
        )
        ..close(),
      _snow,
      line: 0,
    );
  }
}

// ---------------------------------------------------------------------------
// The slope

void _slope(Art a) {
  a.fade(a.r(0, 0, 1, 0.4), _skyHigh, _sky);
  // The ridge above, rocks breaking the snow.
  a.path(
    a.poly([
      a.p(0, 0.3),
      a.p(0.2, 0.14),
      a.p(0.42, 0.12),
      a.p(0.64, 0.2),
      a.p(1, 0.26),
      a.p(1, 1),
      a.p(0, 1),
    ]),
    _snowShade,
    line: 0,
  );
  for (final (x, y, w) in [
    (0.26, 0.13, 0.05),
    (0.5, 0.15, 0.04),
    (0.8, 0.23, 0.03),
  ]) {
    a.path(
      a.poly([a.p(x, y + 0.03), a.p(x + w * 0.3, y), a.p(x + w, y + 0.035)]),
      _rock,
      line: 0,
    );
  }
  // The slope falling away to the right, lighter where the wind scoured it.
  a
    ..fade(a.r(0, 0.3, 1, 0.7), _snowShade, _snow)
    // The forest edge far down to the right.
    ..path(
      a.poly([a.p(0.74, 0.66), a.p(1, 0.6), a.p(1, 0.76), a.p(0.76, 0.74)]),
      const Color(0xFF8A929A),
      line: 0,
    );
  for (var i = 0; i < 12; i++) {
    _spruce(
      a,
      a.p(0.77 + i * 0.02, 0.72 - i * 0.008),
      a.size.height * 0.07,
      color: const Color(0xFF4A5450),
    );
  }
  // The shoulder above the tent: a mound of wind-packed snow, its lip
  // casting a faint shadow.
  final shoulder = Path()
    ..moveTo(a.size.width * 0.14, a.size.height * 0.47)
    ..quadraticBezierTo(
      a.size.width * 0.4,
      a.size.height * 0.24,
      a.size.width * 0.68,
      a.size.height * 0.46,
    )
    ..quadraticBezierTo(
      a.size.width * 0.4,
      a.size.height * 0.52,
      a.size.width * 0.14,
      a.size.height * 0.47,
    )
    ..close();
  a
    ..path(shoulder, const Color(0xFFE6EAF0), line: 0)
    ..strokePath(
      Path()
        ..moveTo(a.size.width * 0.2, a.size.height * 0.48)
        ..quadraticBezierTo(
          a.size.width * 0.42,
          a.size.height * 0.53,
          a.size.width * 0.66,
          a.size.height * 0.47,
        ),
      const Color(0x669AA6B6),
      width: 1.2,
    );
  // The cut: a shaded back wall where the slope was dug level for the tent.
  a.path(
    Path()
      ..moveTo(a.size.width * 0.32, a.size.height * 0.56)
      ..quadraticBezierTo(
        a.size.width * 0.47,
        a.size.height * 0.5,
        a.size.width * 0.62,
        a.size.height * 0.55,
      )
      ..lineTo(a.size.width * 0.62, a.size.height * 0.58)
      ..lineTo(a.size.width * 0.32, a.size.height * 0.59)
      ..close(),
    const Color(0xFFB4BECA),
    line: 0,
  );
  a.canvas.drawOval(
    a.r(0.33, 0.655, 0.28, 0.03),
    Paint()
      ..color = const Color(0x445A6474)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, a.u * 1.4),
  );
  _tent(a, a.r(0.35, 0.55, 0.24, 0.12));

  // The footprints: raised columns of pressed snow, going down in a line
  // from the tent to the forest.
  final random = math.Random(5);
  for (var trail = 0; trail < 3; trail++) {
    for (var k = 0; k < 15; k++) {
      final t = k / 15;
      final x = 0.5 + t * 0.32 + trail * 0.014 + (k.isEven ? 0.005 : -0.005);
      final y = 0.69 + t * 0.2 + trail * 0.01;
      final p = a.p(x, y);
      final s = a.u * (1.0 + t * 0.7);
      a
        // The shadow the column casts, and the column itself.
        ..fill(
          Rect.fromLTWH(p.dx - s * 0.2, p.dy, s * 1.6, s * 0.5),
          const Color(0x559AA4B2),
        )
        ..rbox(
          Rect.fromCenter(
            center: p.translate(0, -s * 0.25),
            width: s * 1.1,
            height: s,
          ),
          s * 0.3,
          Color.lerp(_snow, _snowShade, random.nextDouble() * 0.4)!,
          line: 0.15,
        );
    }
  }

  // The search camp's tents far off on the left, a thread of smoke.
  for (final (x, y) in [(0.03, 0.58), (0.08, 0.6)]) {
    a.path(
      a.poly([a.p(x, y), a.p(x + 0.025, y - 0.04), a.p(x + 0.05, y)]),
      const Color(0xFF7A7464),
      line: 0.2,
    );
  }
  a.strokePath(
    Path()
      ..moveTo(a.size.width * 0.06, a.size.height * 0.56)
      ..quadraticBezierTo(
        a.size.width * 0.04,
        a.size.height * 0.48,
        a.size.width * 0.08,
        a.size.height * 0.4,
      ),
    const Color(0x66E0E4E8),
    width: 0.8,
  );
  _drift(a);
}

// ---------------------------------------------------------------------------
// The cedar at the forest edge

void _cedar(Art a) {
  a
    ..fade(a.r(0, 0, 1, 0.6), _skyHigh, _sky)
    // The forest behind.
    ..fill(a.r(0, 0.36, 1, 0.3), const Color(0xFF3A4440));
  for (var i = 0; i < 26; i++) {
    _spruce(a, a.p(i / 24, 0.66), a.size.height * (0.34 + (i % 3) * 0.06));
  }
  a.fade(a.r(0, 0.62, 1, 0.38), _snowShade, _snow);
  // A tree on the left, where the raven sits.
  a
    ..line(a.p(0.2, 0.9), a.p(0.22, 0.12), _bark, width: 1.6)
    ..line(a.p(0.215, 0.32), a.p(0.28, 0.3), _bark, width: 0.7);

  // The great cedar: a thick trunk, its lower branches broken off.
  final trunk = a.r(0.44, 0.06, 0.07, 0.74);
  // Roots spreading into the snow.
  for (final dx in [-0.03, -0.01, 0.02, 0.04]) {
    a.line(a.p(0.475, 0.78), a.p(0.475 + dx, 0.82), _bark, width: 1);
  }
  a.box(trunk, _bark, line: 0.5);
  for (var i = 0; i < 9; i++) {
    final y = 0.36 + i * 0.05;
    final left = i.isEven;
    a.line(
      a.p(left ? 0.44 : 0.51, y),
      a.p(left ? 0.42 : 0.53, y - 0.01),
      const Color(0xFF6A5444),
      width: 1.1,
    );
  }
  // Its crown, high and dark, snow on its boughs.
  final random = math.Random(9);
  for (var i = 0; i < 18; i++) {
    final c = a.p(
      0.36 + random.nextDouble() * 0.24,
      0.04 + random.nextDouble() * 0.24,
    );
    a
      ..oval(
        Rect.fromCenter(
          center: c,
          width: a.size.width * 0.08,
          height: a.size.height * 0.05,
        ),
        _needles,
        line: 0,
      )
      ..line(
        c.translate(-a.size.width * 0.03, -a.size.height * 0.012),
        c.translate(a.size.width * 0.03, -a.size.height * 0.016),
        _snow,
        width: 0.5,
      );
  }
  // The broken low branch on the right.
  a
    ..line(a.p(0.51, 0.46), a.p(0.64, 0.44), _bark, width: 1.4)
    ..line(
      a.p(0.64, 0.44),
      a.p(0.66, 0.46),
      const Color(0xFF8A7058),
      width: 1.2,
    );

  // The black ring of the small fire in the snow.
  final fire = a.r(0.55, 0.8, 0.14, 0.05);
  a
    ..oval(fire, const Color(0xFF2A2624), line: 0)
    ..oval(fire.deflate(a.u * 0.8), const Color(0xFF4A4440), line: 0);
  for (var i = 0; i < 7; i++) {
    final x = fire.left + fire.width * (0.2 + i * 0.1);
    a.line(
      Offset(x, fire.center.dy),
      Offset(x + a.u * 2, fire.center.dy - a.u),
      const Color(0xFF1A1816),
      width: 0.5,
    );
  }
  _drift(a, seed: 7, top: 0.6);
}

// ---------------------------------------------------------------------------
// The search camp's tent

void _camp(Art a) {
  // Inside the search party's tent: canvas walls and roof running back, a
  // floor of boards over the snow, seen from a little above.
  final room = Room(a, vp: a.p(0.5, 0.18), depth: 0.6);
  final back = room.back;
  a
    ..path(room.ceiling, const Color(0xFF8E866E), line: 0)
    ..path(room.leftWall, const Color(0xFFA49C84), line: 0)
    ..path(room.rightWall, const Color(0xFFA49C84), line: 0)
    ..fill(back, _canvas)
    ..path(room.floor, const Color(0xFF7A6E5A), line: 0);
  // The canvas seams and the ridge pole, running back.
  for (var k = 1; k < 6; k++) {
    for (final x in [0.0, 1.0]) {
      a.hairline(room.at(x, 0, k / 6), room.at(x, 1, k / 6), _canvasDark, 0.3);
    }
  }
  a.line(room.at(0.5, 1, 0), room.at(0.5, 1, 1), _wood, width: 1.2);
  room
    ..floorGrid(const Color(0x553A3022), rows: 0, columns: 10, width: 0.4)
    ..shadeCorners(strength: 0.35)
    ..edges(_canvasDark);
  a
    ..ink(back, width: 0.4)
    ..glow(a.p(0.5, 0.2), a.size.width * 0.4, _lamp, strength: 0.22);
  // The flap open in the right wall: snow light outside.
  final flap = [
    room.at(1, 0.75, 0.1),
    room.at(1, 0.75, 0.45),
    room.at(1, 0, 0.45),
    room.at(1, 0, 0.1),
  ];
  a
    ..path(a.poly(flap), const Color(0xFFDDE3EA), line: 0.4)
    ..path(
      a.poly([flap[0], Offset.lerp(flap[3], flap[2], 0.4)!, flap[3]]),
      _canvasDark,
      line: 0.3,
    );
  room.beam(
    [flap[3], flap[2]],
    [room.floorAt(0.7, 0.4), room.floorAt(0.78, 0.08)],
    const Color(0xFFDDE3EA),
    strength: 0.2,
  );
  // Notes pinned to the back wall.
  for (final (x, y, ang) in [
    (0.21, 0.18, -0.05),
    (0.27, 0.24, 0.06),
    (0.22, 0.32, 0.02),
  ]) {
    a.paper(
      a.r(x, y, 0.07, 0.08),
      lines: 4,
      angle: ang,
      color: _paper,
      ink: 0.5,
    );
  }
  // Crates for a table, seen from above, and what lies on them.
  room
    ..shadow(0.1, 0.9, 0.15, 0.6)
    ..block(0.1, 0.9, 0, 0.3, 0.15, 0.6, _wood, top: const Color(0xFF7E6044));
  for (var k = 1; k < 4; k++) {
    a.hairline(
      room.at(0.1 + 0.8 * k / 4, 0.3, 0.15),
      room.at(0.1 + 0.8 * k / 4, 0.3, 0.6),
      const Color(0xFF4A3424),
      0.4,
    );
  }
  a
    // The case file: a cardboard folder tied with tape.
    ..box(a.r(0.2, 0.565, 0.14, 0.08), const Color(0xFFC0A878), line: 0.4)
    ..line(
      a.p(0.2, 0.605),
      a.p(0.34, 0.605),
      const Color(0xFF8A6A44),
      width: 0.5,
    )
    // The route book, small and buff.
    ..box(a.r(0.36, 0.6, 0.09, 0.05), const Color(0xFFB8AC8A), line: 0.3)
    ..line(
      a.p(0.405, 0.6),
      a.p(0.405, 0.65),
      const Color(0xFF6A5E44),
      width: 0.3,
    )
    // The cameras.
    ..rbox(
      a.r(0.47, 0.57, 0.055, 0.06),
      a.u * 0.6,
      const Color(0xFF2A2A2C),
      line: 0.3,
    )
    ..circle(a.p(0.4975, 0.6), a.u * 1.1, const Color(0xFF4A4A50), line: 0.2)
    ..rbox(
      a.r(0.535, 0.58, 0.05, 0.055),
      a.u * 0.6,
      const Color(0xFF36302C),
      line: 0.3,
    )
    ..circle(a.p(0.56, 0.6075), a.u * 1, const Color(0xFF4A4A50), line: 0.2);
  // The radio on its box at the far end, its aerial up.
  a
    ..box(a.r(0.7, 0.45, 0.12, 0.13), const Color(0xFF4A5040), line: 0.4)
    ..circle(a.p(0.735, 0.51), a.u * 1.4, const Color(0xFF2A2C26), line: 0.2)
    ..circle(a.p(0.78, 0.51), a.u * 1.4, const Color(0xFF2A2C26), line: 0.2)
    ..line(
      a.p(0.81, 0.45),
      a.p(0.83, 0.31),
      const Color(0xFF2A2C26),
      width: 0.4,
    )
    ..box(a.r(0.71, 0.58, 0.11, 0.03), _wood, line: 0.3)
    ..line(a.p(0.5, 0), a.p(0.5, 0.1), const Color(0xFF2A2420), width: 0.3)
    ..box(a.r(0.49, 0.1, 0.02, 0.04), const Color(0xFF3A3A34), line: 0.2)
    ..glow(a.p(0.5, 0.12), a.u * 6, _lamp, strength: 0.4);
}

// ---------------------------------------------------------------------------
// The darkroom in Ivdel

void _darkroom(Art a) {
  a
    ..fill(Offset.zero & a.size, const Color(0xFF1E0E0C))
    ..glow(a.p(0.5, 0.12), a.size.width * 0.5, _red, strength: 0.45);
  // The red safelight.
  a
    ..box(a.r(0.47, 0.06, 0.06, 0.08), const Color(0xFF3A1E1A), line: 0.4)
    ..fill(a.r(0.48, 0.08, 0.04, 0.05), const Color(0xFFE0402E))
    ..glow(a.p(0.5, 0.1), a.u * 8, const Color(0xFFFF4A30), strength: 0.5);
  // A string across the left wall, for prints to dry.
  a.line(a.p(0.04, 0.17), a.p(0.28, 0.17), const Color(0xFF6A4038), width: 0.4);
  // The bench on its legs: three trays and the enlarger.
  Room(a, vp: a.p(0.5, 0.25), depth: 0.6).standTable(
    a.r(0.2, 0.64, 0.62, 0.28),
    const Color(0xFF3A2018),
    deep: 0.2,
    thickness: 0.04,
    leg: 0.02,
    legColor: const Color(0xFF2A1612),
  );
  for (var i = 0; i < 3; i++) {
    final tray = a.r(0.3 + i * 0.11, 0.6, 0.09, 0.04);
    a
      ..box(tray, const Color(0xFF2A1612), line: 0.4)
      ..fill(tray.deflate(a.u * 0.5), const Color(0xFF4A2420));
  }
  // The enlarger: a column, a lamp house, a lens, a baseboard.
  a
    ..box(a.r(0.66, 0.2, 0.02, 0.42), const Color(0xFF2A2420), line: 0.3)
    ..box(a.r(0.6, 0.3, 0.1, 0.08), const Color(0xFF3A3230), line: 0.4)
    ..box(a.r(0.63, 0.38, 0.04, 0.05), const Color(0xFF2A2420), line: 0.3)
    ..box(a.r(0.58, 0.58, 0.14, 0.03), const Color(0xFF4A3A34), line: 0.3)
    ..glow(a.p(0.65, 0.58), a.u * 4, const Color(0xFFFFE0C0), strength: 0.1);
  // Film strips hanging to dry.
  for (var i = 0; i < 2; i++) {
    a.box(
      a.r(0.24 + i * 0.03, 0.22, 0.015, 0.3),
      const Color(0xFF2A1A16),
      line: 0.2,
    );
  }
}

// ---------------------------------------------------------------------------
// Puzzle boards

/// The pit's surroundings: snow walls, a grey sky above.
void _pitBoard(Art a) {
  a
    ..fade(a.r(0, 0, 1, 0.12), _skyHigh, _sky)
    ..fade(
      a.r(0, 0.1, 1, 0.9),
      const Color(0xFFD4DCE6),
      const Color(0xFF9EAABA),
    )
    ..fade(
      Offset.zero & a.size,
      const Color(0x22000000),
      const Color(0x66000000),
    );
}

/// The darkroom bench under the safelight.
void _darkroomBoard(Art a) {
  a
    ..fill(Offset.zero & a.size, const Color(0xFF180A08))
    ..glow(a.p(0.5, 0), a.size.width * 0.6, _red, strength: 0.35);
}

// ---------------------------------------------------------------------------
// Objects

/// The snow kit by the pit: a shovel stuck upright, a saw, the pit's dark
/// mouth.
void _kit(Art a) {
  a
    ..oval(a.r(0.1, 0.55, 0.8, 0.35), const Color(0xFF8A96A8), line: 0.4)
    ..oval(a.r(0.18, 0.6, 0.64, 0.22), const Color(0xFF6A7688), line: 0)
    ..line(
      a.p(0.75, 0.08),
      a.p(0.72, 0.62),
      const Color(0xFF5A4A3A),
      width: 1.4,
    )
    ..path(
      a.poly([
        a.p(0.64, 0.58),
        a.p(0.8, 0.58),
        a.p(0.78, 0.74),
        a.p(0.66, 0.74),
      ]),
      const Color(0xFF6A7078),
      line: 0.4,
    )
    ..line(a.p(0.18, 0.5), a.p(0.42, 0.42), const Color(0xFF9A9CA0), width: 1);
}

/// Papers from the future, laid on the crate.
void _papers(Art a) {
  for (var i = 0; i < 3; i++) {
    a.paper(
      a.r(0.1 + i * 0.05, 0.14 + i * 0.04, 0.72, 0.68),
      lines: 6,
      angle: -0.06 + i * 0.05,
      color: i == 2 ? const Color(0xFFF2F2EE) : _paper,
      ink: 0.5,
    );
  }
  a.glow(a.p(0.5, 0.5), a.size.width * 0.6, _lamp, strength: 0.15);
}

/// Four prints pinned up to dry.
void _prints(Art a) {
  for (var i = 0; i < 4; i++) {
    final r = a.r(0.03 + i * 0.245, 0.08, 0.21, 0.5);
    a
      ..box(r, const Color(0xFFD8D0C8), line: 0.3)
      ..fill(
        r.deflate(a.u * 1.2),
        Color.lerp(
          const Color(0xFF8A8A8A),
          const Color(0xFFD0D0D0),
          (i % 2) * 0.4,
        )!,
      )
      ..line(
        r.topCenter.translate(0, -a.u),
        r.topCenter.translate(0, a.u),
        const Color(0xFF6A4038),
        width: 0.6,
      );
  }
}

/// The frames on their roll, drawn in plain tones (the view greys them).
void _frame(Art a, int i) {
  a.fade(a.r(0, 0, 1, 0.45), const Color(0xFF8A929C), const Color(0xFFB8BEC6));
  switch (i) {
    case 1:
      // The frozen river between snowy banks, skiers on it.
      a
        ..fill(a.r(0, 0.4, 1, 0.6), _snow)
        ..path(
          a.poly([a.p(0, 0.62), a.p(1, 0.52), a.p(1, 0.66), a.p(0, 0.78)]),
          const Color(0xFFDDE2E8),
          line: 0,
        );
      for (var k = 0; k < 8; k++) {
        _spruce(a, a.p(k / 7, 0.44), a.size.height * 0.28);
      }
      for (var k = 0; k < 3; k++) {
        _figure(a, a.p(0.3 + k * 0.14, 0.7 - k * 0.025), a.size.height * 0.16);
      }
      a.line(
        a.p(0.05, 0.76),
        a.p(0.6, 0.66),
        const Color(0xFF9AA4B0),
        width: 0.4,
      );
    case 2:
      // The cache in the upper valley: a platform on posts, covered.
      a.fill(a.r(0, 0.42, 1, 0.58), _snow);
      for (var k = 0; k < 7; k++) {
        _spruce(a, a.p(0.05 + k * 0.15, 0.48), a.size.height * 0.32);
      }
      a
        ..line(a.p(0.38, 0.8), a.p(0.38, 0.58), _wood, width: 1)
        ..line(a.p(0.62, 0.8), a.p(0.62, 0.58), _wood, width: 1)
        ..box(a.r(0.34, 0.5, 0.32, 0.09), _canvasDark, line: 0.4);
      _figure(a, a.p(0.74, 0.82), a.size.height * 0.2);
    case 3:
      // Out of the trees onto the open slope, figures in a line.
      a.path(
        a.poly([a.p(0, 0.9), a.p(1, 0.32), a.p(1, 1), a.p(0, 1)]),
        _snow,
        line: 0,
      );
      for (var k = 0; k < 4; k++) {
        _spruce(a, a.p(0.04 + k * 0.06, 0.95), a.size.height * 0.3);
      }
      for (var k = 0; k < 5; k++) {
        _figure(
          a,
          a.p(0.32 + k * 0.1, 0.78 - k * 0.07),
          a.size.height * 0.14,
          lean: -0.15,
        );
      }
    case 4:
      // Before sunset: digging a step into the slope below the shoulder.
      a
        ..fade(
          a.r(0, 0, 1, 0.45),
          const Color(0xFF7A808A),
          const Color(0xFFC8C2BA),
        )
        ..path(
          Path()
            ..moveTo(0, a.size.height * 0.5)
            ..quadraticBezierTo(
              a.size.width * 0.5,
              a.size.height * 0.26,
              a.size.width,
              a.size.height * 0.42,
            )
            ..lineTo(a.size.width, a.size.height)
            ..lineTo(0, a.size.height)
            ..close(),
          _snow,
          line: 0,
        )
        // The cut: a level step with a shaded back wall.
        ..path(
          a.poly([
            a.p(0.2, 0.62),
            a.p(0.72, 0.58),
            a.p(0.72, 0.66),
            a.p(0.2, 0.7),
          ]),
          _snowDeep,
          line: 0,
        )
        ..fill(a.r(0.2, 0.7, 0.52, 0.06), const Color(0xFFDDE2E8))
        // The rolled tent beside it.
        ..rbox(a.r(0.76, 0.66, 0.14, 0.05), a.u * 1.5, _canvasDark, line: 0.3);
      for (final (x, lean) in [(0.3, 0.3), (0.45, -0.2), (0.6, 0.25)]) {
        final foot = a.p(x, 0.72);
        _figure(a, foot, a.size.height * 0.2, lean: lean);
        a.line(
          foot.translate(0, -a.size.height * 0.1),
          foot.translate(a.size.width * 0.05 * lean.sign, a.size.height * 0.02),
          _wood,
          width: 0.6,
        );
      }
  }
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
  a.fade(a.r(0, 0.16, 1, 0.4), _skyHigh, _sky);
  a.path(
    Path()
      ..moveTo(0, h * 0.5)
      ..quadraticBezierTo(w * 0.5, h * 0.34, w, h * 0.44)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close(),
    _snow,
    line: 0,
  );
  _tent(a, a.r(0.3, 0.52, 0.42, 0.12));
  for (var k = 0; k < 7; k++) {
    a.oval(
      Rect.fromCenter(
        center: a.p(0.52 + k * 0.05, 0.7 + k * 0.035),
        width: a.u * 2.2,
        height: a.u * 1.4,
      ),
      _snowShade,
      line: 0.15,
    );
  }
  _drift(a, seed: 11, count: 14, top: 0.4);
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
  // The lid: the buff cover of a route book.
  a
    ..box(a.r(0.3, 0.04, 0.4, 0.14), const Color(0xFFB8AC8A), line: 0.5)
    ..circle(a.p(0.5, 0.11), a.u * 3, const Color(0x00000000), line: 0.4);
}
