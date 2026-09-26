import 'dart:math' as math;
import 'dart:ui';

import '../theme/stillroom_palette.dart';
import 'art_kit.dart';

/// Code-drawn stand-in art for "Whitechapel, 1888", keyed by the image paths
/// used in the episode's JSON. A real file at the same path always wins.
///
/// Object painters draw inside their own layer `rect`; where two layers must
/// line up (cold and lit candles), the mapping is noted.
const _s = 'images/scenes/whitechapel_1888';
const _o = 'images/objects/whitechapel_1888';
const _i = 'images/items/whitechapel_1888';

final Map<String, ArtPainter> whitechapelArt = {
  // Scenes and puzzle boards.
  '$_s/room_north.png': (c, s) => _room(Art(c, s), _north),
  '$_s/room_east.png': (c, s) => _room(Art(c, s), _east),
  '$_s/room_south.png': (c, s) => _room(Art(c, s), _south),
  '$_s/room_west.png': (c, s) => _room(Art(c, s), _west, ghostFrames: true),
  '$_s/desk.png': (c, s) => _deskScene(Art(c, s)),
  '$_s/window.png': (c, s) => _windowScene(Art(c, s)),
  '$_s/drawer_lock_close.png': (c, s) => _drawerBoard(Art(c, s)),
  '$_s/candles_close.png': (c, s) => _candleBoard(Art(c, s)),
  '$_s/street_map_close.png': (c, s) => _mapBoard(Art(c, s)),
  '$_s/frames_close.png': (c, s) => _framesBoard(Art(c, s)),
  '$_s/label_close.png': (c, s) => jarLabelBoard(Art(c, s), _north.base),
  // Reveal puzzles: what shows through, and the ash on top.
  '$_o/fog_writing.png': (c, s) => _fogWritingBoard(Art(c, s)),
  '$_o/fog_writing_sprite.png': (c, s) => _fogWriting(Art(c, s)),
  '$_o/hearth_note.png': (c, s) => _hearthNote(Art(c, s)),
  '$_o/hearth_ash.png': (c, s) => _ash(Art(c, s)),
  // Objects.
  '$_o/window_sprite.png': (c, s) => _window(Art(c, s)),
  '$_o/desk_sprite.png': (c, s) => _desk(Art(c, s)),
  '$_o/bed_sprite.png': (c, s) => _bed(Art(c, s)),
  '$_o/fireplace_sprite.png': (c, s) => _fireplace(Art(c, s)),
  '$_o/mantel_sprite.png': (c, s) => Art(c, s).wood(Offset.zero & s, grain: 1),
  '$_o/clock_sprite.png': (c, s) => _clock(Art(c, s)),
  '$_o/candles_cold_sprite.png': (c, s) => _candles(Art(c, s), lit: false),
  '$_o/candles_lit_sprite.png': (c, s) => _candles(Art(c, s), lit: true),
  '$_o/door_closed_sprite.png': (c, s) => _door(Art(c, s), open: false),
  '$_o/door_open_sprite.png': (c, s) => _door(Art(c, s), open: true),
  '$_o/coat_rack_sprite.png': (c, s) => _coatRack(Art(c, s)),
  '$_o/frames_empty_sprite.png': (c, s) => _frameRow(Art(c, s), filled: false),
  '$_o/frames_restored_sprite.png': (c, s) =>
      _frameRow(Art(c, s), filled: true),
  '$_o/brass_frame.png': (c, s) => _floorRing(Art(c, s)),
  '$_o/clippings_sprite.png': (c, s) => _clippings(Art(c, s)),
  '$_o/faded_paper_sprite.png': (c, s) => _fadedPaper(Art(c, s)),
  '$_o/drawer_closed_sprite.png': (c, s) => _drawer(Art(c, s), open: false),
  '$_o/drawer_open_sprite.png': (c, s) => _drawer(Art(c, s), open: true),
  '$_o/street_map_sprite.png': (c, s) => _streetMap(Art(c, s)),
  '$_o/street_map_solved_sprite.png': (c, s) => _streetMapSolved(Art(c, s)),
  '$_o/hearth_note_sprite.png': (c, s) => _hearthScrap(Art(c, s)),
  '$_o/gaslamp_sprite.png': (c, s) => _gaslamp(Art(c, s)),
  '$_o/candle.png': (c, s) {
    final a = Art(c, s);
    a.candle(a.p(0.5, 0.98), s.height * 0.66);
  },
  '$_o/candle_lit.png': (c, s) {
    final a = Art(c, s);
    a.candle(a.p(0.5, 0.98), s.height * 0.66, lit: true);
  },
  '$_o/compass_outer.png': (c, s) =>
      _ring(Art(c, s), inner: 0.72, steps: 8, tone: StillroomPalette.paper),
  '$_o/compass_middle.png': (c, s) => _ring(
    Art(c, s),
    inner: 0.615,
    steps: 8,
    tone: StillroomPalette.paperShade,
  ),
  '$_o/compass_inner.png': (c, s) =>
      _ring(Art(c, s), inner: 0.375, steps: 4, tone: StillroomPalette.paper),
  '$_o/letter_street_names.png': (c, s) => _letterMap(Art(c, s)),
  // Items.
  '$_i/matches.png': (c, s) => _matches(Art(c, s)),
  '$_i/letter.png': (c, s) => _letterIcon(Art(c, s)),
  '$_i/letter_examine.png': (c, s) => _letterSheet(Art(c, s)),
  '$_i/lens.png': (c, s) => _lens(Art(c, s)),
  '$_i/brass_frame.png': (c, s) =>
      _magnifier(Art(c, s), glass: false, handle: false),
  '$_i/magnifier.png': (c, s) =>
      _magnifier(Art(c, s), glass: true, handle: true),
  '$_i/name_card.png': (c, s) => _nameCard(Art(c, s)),
  // The jar on the shelf.
  'images/ui/jar_whitechapel_1888.png': (c, s) => _jar(Art(c, s)),
};

// ---------------------------------------------------------------------------
// Rooms

typedef _Wall = ({Color base, Color stripe});

const _Wall _north = (base: Color(0xFF25211B), stripe: Color(0xFF2D2921));
const _Wall _east = (base: Color(0xFF2A1F1A), stripe: Color(0xFF33261F));
const _Wall _south = (base: Color(0xFF1E2320), stripe: Color(0xFF262C28));
const _Wall _west = (base: Color(0xFF241E1B), stripe: Color(0xFF2C2420));

void _room(Art a, _Wall wall, {bool ghostFrames = false}) {
  a.wallpaper(a.r(0, 0, 1, 0.84), wall.base, wall.stripe);
  if (ghostFrames) {
    // Paler rectangles where pictures once hung.
    for (final x in [0.03, 0.9]) {
      a.fill(a.r(x, 0.2, 0.07, 0.2), wall.stripe.withValues(alpha: 0.6));
    }
  }
  a
    ..stain(a.p(0.08, 0.3), a.size.width * 0.05)
    ..stain(a.p(0.93, 0.55), a.size.width * 0.04)
    ..fade(a.r(0, 0, 1, 0.3), const Color(0xCC000000), const Color(0x00000000))
    ..wood(a.r(0, 0.06, 1, 0.014), grain: 0)
    ..wood(a.r(0, 0.8, 1, 0.045), grain: 1)
    ..floorboards(a.r(0, 0.845, 1, 0.155))
    ..fade(
      a.r(0, 0.845, 1, 0.155),
      const Color(0x66000000),
      const Color(0x00000000),
    );
}

void _deskScene(Art a) {
  a
    ..wallpaper(a.r(0, 0, 1, 0.6), _north.base, _north.stripe, every: 0.08)
    ..fade(
      a.r(0, 0, 1, 0.35),
      const Color(0xAA000000),
      const Color(0x00000000),
    );
  // The desk top, seen from above at an angle.
  final top = a.poly([
    a.p(-0.05, 0.6),
    a.p(1.05, 0.6),
    a.p(1.1, 1),
    a.p(-0.1, 1),
  ]);
  a
    ..path(top, StillroomPalette.walnut)
    ..line(
      a.p(-0.05, 0.64),
      a.p(1.05, 0.64),
      const Color(0xFF1E150F),
      width: 0.4,
    )
    ..line(
      a.p(-0.05, 0.62),
      a.p(1.05, 0.62),
      StillroomPalette.walnutLight,
      width: 0.3,
    )
    // Inkwell and pen.
    ..oval(a.r(0.86, 0.5, 0.06, 0.1), const Color(0xFF14110F))
    ..line(
      a.p(0.88, 0.52),
      a.p(0.95, 0.36),
      StillroomPalette.paperShade,
      width: 0.5,
    )
    ..glow(
      a.p(0.95, 0.45),
      a.size.width * 0.12,
      StillroomPalette.gaslight,
      strength: 0.15,
    );
}

void _windowScene(Art a) {
  // Wall around the window.
  a.wallpaper(Offset.zero & a.size, _north.base, _north.stripe, every: 0.08);
  // Outside: fog over rooftops.
  final glass = a.r(0.05, 0.07, 0.52, 0.78);
  a
    ..fade(glass, const Color(0xFF3B443F), const Color(0xFF5E6862))
    ..path(
      a.poly([
        a.p(0.05, 0.62),
        a.p(0.14, 0.55),
        a.p(0.2, 0.58),
        a.p(0.24, 0.48),
        a.p(0.27, 0.48),
        a.p(0.28, 0.56),
        a.p(0.4, 0.5),
        a.p(0.48, 0.57),
        a.p(0.57, 0.53),
        a.p(0.57, 0.85),
        a.p(0.05, 0.85),
      ]),
      const Color(0xFF232826),
      line: 0,
    )
    ..fill(a.r(0.05, 0.4, 0.52, 0.45), const Color(0x445E6862))
    // Frame and mullions.
    ..ink(glass, width: 1.5)
    ..wood(a.r(0.03, 0.05, 0.56, 0.025), grain: 0)
    ..wood(a.r(0.03, 0.85, 0.56, 0.05), grain: 1)
    ..wood(a.r(0.03, 0.05, 0.02, 0.83), grain: 0)
    ..wood(a.r(0.57, 0.05, 0.02, 0.83), grain: 0)
    ..wood(a.r(0.3, 0.07, 0.012, 0.78), grain: 0)
    ..wood(a.r(0.05, 0.44, 0.52, 0.012), grain: 0)
    ..fade(
      a.r(0, 0, 1, 0.25),
      const Color(0xAA000000),
      const Color(0x00000000),
    );
}

// ---------------------------------------------------------------------------
// Puzzle boards (16:9)

void _drawerBoard(Art a) {
  a
    ..wood(Offset.zero & a.size, grain: 9)
    ..wood(
      a.r(0.06, 0.1, 0.88, 0.8),
      base: StillroomPalette.walnutLight,
      grain: 6,
    )
    ..rbox(a.r(0.24, 0.2, 0.52, 0.6), a.u * 2, const Color(0xFF6E5A30))
    ..rbox(
      a.r(0.26, 0.23, 0.48, 0.54),
      a.u * 1.5,
      StillroomPalette.brass,
      line: 0.4,
    )
    ..circle(a.p(0.5, 0.86), a.u * 2.4, const Color(0xFF6E5A30))
    ..fill(a.r(0.497, 0.86, 0.006, 0.05), Art.outline);
}

void _candleBoard(Art a) {
  a
    ..wallpaper(a.r(0, 0, 1, 0.7), _east.base, _east.stripe, every: 0.07)
    ..fade(a.r(0, 0, 1, 0.3), const Color(0xAA000000), const Color(0x00000000))
    ..wood(a.r(0.02, 0.68, 0.96, 0.06), grain: 2)
    ..fill(a.r(0.06, 0.74, 0.88, 0.26), const Color(0xFF1B1714))
    ..fill(a.r(0.2, 0.78, 0.6, 0.22), const Color(0xFF080605));
}

void _mapBoard(Art a) {
  a.fill(Offset.zero & a.size, const Color(0xFF1B1714));
  final sheet = a.r(0.18, 0.03, 0.64, 0.94);
  a.box(sheet, const Color(0xFFCDBD98));
  final random = math.Random(1888);
  for (var i = 0; i < 14; i++) {
    final y = sheet.top + sheet.height * random.nextDouble();
    a.line(
      Offset(sheet.left, y),
      Offset(sheet.right, y + (random.nextDouble() - 0.5) * sheet.height * 0.3),
      StillroomPalette.inkOnPaper.withValues(alpha: 0.25),
      width: 0.5,
    );
  }
  for (final (x, y) in [(0.2, 0.05), (0.8, 0.05), (0.2, 0.95), (0.8, 0.95)]) {
    a.circle(a.p(x, y), a.u * 1.2, StillroomPalette.oxblood, line: 0.3);
  }
}

void _framesBoard(Art a) {
  a
    ..wallpaper(Offset.zero & a.size, _west.base, _west.stripe, every: 0.07)
    ..fade(a.r(0, 0, 1, 0.3), const Color(0xAA000000), const Color(0x00000000));
  // Frames around the puzzle's slot rects (x, 0.16, 0.12, 0.36).
  for (final x in [0.10, 0.27, 0.44, 0.61, 0.78]) {
    _frame(
      a,
      a.r(x - 0.02, 0.16 - 0.04, 0.16, 0.44),
      inside: a.r(x, 0.16, 0.12, 0.36),
    );
  }
}

void _frame(Art a, Rect outer, {required Rect inside}) {
  a
    ..box(outer, const Color(0xFF6E5A30), line: 0.6)
    ..box(outer.deflate(a.u * 0.8), StillroomPalette.brass, line: 0.3)
    ..box(inside, const Color(0xFF15110E), line: 0.5);
}

// ---------------------------------------------------------------------------
// Objects (each drawn inside its layer rect)

void _window(Art a) {
  final glass = a.r(0.12, 0.06, 0.76, 0.78);
  a
    ..fade(glass, const Color(0xFF39413D), const Color(0xFF55605A))
    ..glow(
      a.p(0.3, 0.7),
      a.size.width * 0.3,
      StillroomPalette.gaslight,
      strength: 0.12,
    )
    ..ink(glass, width: 1)
    ..wood(a.r(0.1, 0.02, 0.8, 0.05), grain: 0)
    ..wood(a.r(0.49, 0.06, 0.03, 0.78), grain: 0)
    ..wood(a.r(0.12, 0.43, 0.76, 0.03), grain: 0)
    ..wood(a.r(0.06, 0.84, 0.88, 0.08), grain: 1);
  // Curtains.
  for (final left in [true, false]) {
    final x0 = left ? 0.0 : 0.86;
    final curtain = a.poly([
      a.p(x0, 0),
      a.p(x0 + 0.14, 0),
      a.p(x0 + (left ? 0.1 : 0.08), 0.6),
      a.p(x0 + (left ? 0.16 : 0.02), 1),
      a.p(x0 + (left ? 0.0 : 0.14), 1),
    ]);
    a.path(curtain, const Color(0xFF3E1715));
  }
}

void _desk(Art a) {
  a
    ..wood(
      a.r(0.04, 0.12, 0.92, 0.1),
      base: StillroomPalette.walnutLight,
      grain: 1,
    )
    ..wood(a.r(0.08, 0.22, 0.84, 0.42), grain: 3)
    ..wood(
      a.r(0.32, 0.3, 0.36, 0.26),
      base: StillroomPalette.walnutLight,
      grain: 1,
    )
    ..circle(a.p(0.5, 0.43), a.u * 2.2, StillroomPalette.brass, line: 0.4)
    ..wood(a.r(0.1, 0.64, 0.05, 0.36), grain: 0)
    ..wood(a.r(0.85, 0.64, 0.05, 0.36), grain: 0)
    // A stack of paper and a candle stub on top.
    ..paper(a.r(0.12, 0.02, 0.22, 0.1), lines: 2, angle: -0.04)
    ..candle(a.p(0.78, 0.12), a.size.height * 0.16);
}

void _bed(Art a) {
  const iron = Color(0xFF15120F);
  for (var i = 0; i < 5; i++) {
    a.line(
      a.p(0.03 + i * 0.035, 0.05),
      a.p(0.03 + i * 0.035, 0.95),
      iron,
      width: 0.8,
    );
  }
  a
    ..line(a.p(0.02, 0.05), a.p(0.19, 0.05), iron, width: 1.2)
    ..line(a.p(0.02, 0.4), a.p(0.19, 0.4), iron, width: 0.8)
    ..box(a.r(0.1, 0.48, 0.88, 0.3), const Color(0xFF3A3530))
    ..rbox(a.r(0.13, 0.38, 0.22, 0.16), a.u * 3, const Color(0xFFB8AC92))
    ..box(a.r(0.36, 0.44, 0.62, 0.36), const Color(0xFF2E3530))
    ..line(
      a.p(0.36, 0.52),
      a.p(0.98, 0.52),
      const Color(0xFF3F4841),
      width: 0.5,
    )
    ..line(a.p(0.96, 0.78), a.p(0.96, 1), iron, width: 1)
    ..line(a.p(0.12, 0.78), a.p(0.12, 1), iron, width: 1);
}

void _fireplace(Art a) {
  const stone = Color(0xFF1F1B18);
  final opening = Path()
    ..moveTo(a.size.width * 0.22, a.size.height)
    ..lineTo(a.size.width * 0.22, a.size.height * 0.34)
    ..quadraticBezierTo(
      a.size.width * 0.5,
      a.size.height * 0.1,
      a.size.width * 0.78,
      a.size.height * 0.34,
    )
    ..lineTo(a.size.width * 0.78, a.size.height)
    ..close();
  a
    ..box(a.r(0.04, 0.04, 0.92, 0.96), stone)
    ..box(a.r(0, 0, 1, 0.08), const Color(0xFF2A2521))
    ..path(opening, const Color(0xFF060504))
    ..oval(a.r(0.3, 0.84, 0.4, 0.12), const Color(0xFF3A3632), line: 0.3);
  for (var i = 0; i < 6; i++) {
    final x = 0.3 + i * 0.08;
    a.line(a.p(x, 0.66), a.p(x, 0.86), const Color(0xFF2B2826), width: 0.9);
  }
  a.line(a.p(0.28, 0.66), a.p(0.72, 0.66), const Color(0xFF2B2826), width: 1);
}

void _clock(Art a) {
  final center = a.p(0.5, 0.5);
  final radius = a.size.shortestSide * 0.4;
  a
    ..rbox(a.r(0.08, 0.02, 0.84, 0.96), a.u * 12, StillroomPalette.walnut)
    ..circle(center, radius, const Color(0xFFD9CCAE), line: 0.8);
  for (var h = 0; h < 12; h++) {
    final angle = h * math.pi / 6;
    final dir = Offset(math.sin(angle), -math.cos(angle));
    a.line(
      center + dir * radius * 0.78,
      center + dir * radius * 0.92,
      Art.outline,
      width: h % 3 == 0 ? 1.4 : 0.6,
    );
  }
  // Stopped at 3:40.
  Offset hand(double turns, double length) {
    final angle = turns * 2 * math.pi;
    return center + Offset(math.sin(angle), -math.cos(angle)) * radius * length;
  }

  a
    ..line(center, hand(40 / 60, 0.75), Art.outline, width: 1.1)
    ..line(center, hand((3 + 40 / 60) / 12, 0.5), Art.outline, width: 1.8)
    ..circle(center, a.u * 2, StillroomPalette.brass, line: 0.3);
}

/// Five candles on the mantel. The cold layer is [0.28, 0.34, 0.44, 0.16]
/// and the lit layer [0.26, 0.24, 0.48, 0.26] in the scene; both put the
/// candles at the same scene positions.
void _candles(Art a, {required bool lit}) {
  const scene = (x: 0.26, y: 0.24, w: 0.48, h: 0.26);
  const cold = (x: 0.28, y: 0.34, w: 0.44, h: 0.16);
  final layer = lit ? scene : cold;
  for (var i = 0; i < 5; i++) {
    final sceneX = cold.x + cold.w * (0.1 + 0.2 * i);
    final localX = (sceneX - layer.x) / layer.w;
    final height = a.size.height * (0.144 / layer.h);
    a.candle(a.p(localX, 1), height, lit: lit);
  }
}

void _door(Art a, {required bool open}) {
  a.wood(Offset.zero & a.size, grain: 0, vertical: true);
  final opening = a.r(0.07, 0.03, 0.86, 0.97);
  if (!open) {
    a.wood(opening, base: const Color(0xFF30231A), vertical: true, grain: 3);
    for (final (y, h) in [(0.08, 0.3), (0.44, 0.24), (0.74, 0.2)]) {
      a
        ..box(a.r(0.16, y, 0.3, h), const Color(0xFF281D15), line: 0.5)
        ..box(a.r(0.54, y, 0.3, h), const Color(0xFF281D15), line: 0.5);
    }
    a
      ..rbox(
        a.r(0.76, 0.5, 0.08, 0.12),
        a.u * 1.5,
        const Color(0xFF6E5A30),
        line: 0.4,
      )
      ..circle(a.p(0.8, 0.53), a.u * 3, StillroomPalette.brass, line: 0.4)
      ..fill(a.r(0.795, 0.57, 0.01, 0.03), Art.outline)
      ..fill(
        a.r(0.07, 0.985, 0.86, 0.015),
        StillroomPalette.fog.withValues(alpha: 0.6),
      );
  } else {
    // Beyond the door: the soft grey of the jar.
    a
      ..fade(opening, const Color(0xFF7A7F77), const Color(0xFF4E5A52))
      ..glow(
        a.p(0.5, 0.55),
        a.size.height * 0.4,
        StillroomPalette.paper,
        strength: 0.25,
      )
      ..path(
        a.poly([a.p(0.07, 0.03), a.p(0.3, 0.1), a.p(0.3, 0.93), a.p(0.07, 1)]),
        const Color(0xFF30231A),
      );
  }
}

void _coatRack(Art a) {
  const pole = Color(0xFF1E150F);
  a
    ..line(a.p(0.5, 0.05), a.p(0.5, 0.95), pole, width: 2)
    ..line(a.p(0.5, 0.95), a.p(0.2, 1), pole, width: 1.5)
    ..line(a.p(0.5, 0.95), a.p(0.8, 1), pole, width: 1.5)
    ..line(a.p(0.3, 0.1), a.p(0.7, 0.1), pole, width: 1.2);
  // Coat.
  final coat = a.poly([
    a.p(0.42, 0.12),
    a.p(0.58, 0.12),
    a.p(0.78, 0.2),
    a.p(0.82, 0.72),
    a.p(0.62, 0.76),
    a.p(0.5, 0.3),
    a.p(0.38, 0.76),
    a.p(0.18, 0.72),
    a.p(0.22, 0.2),
  ]);
  a
    ..path(coat, const Color(0xFF1C1F1D))
    ..line(a.p(0.5, 0.14), a.p(0.5, 0.3), const Color(0xFF2A302C), width: 0.6)
    // Bowler hat on the top hook.
    ..oval(a.r(0.24, 0.07, 0.52, 0.03), const Color(0xFF121110))
    ..path(
      Path()..addArc(a.r(0.34, 0.01, 0.32, 0.1), math.pi, math.pi),
      const Color(0xFF121110),
    );
}

void _frameRow(Art a, {required bool filled}) {
  for (var i = 0; i < 5; i++) {
    final outer = a.r(0.02 + i * 0.2, 0.08, 0.16, 0.84);
    final inside = a.r(0.04 + i * 0.2, 0.14, 0.12, 0.72);
    _frame(a, outer, inside: inside);
    if (filled) {
      a
        ..glow(
          inside.center,
          inside.width,
          StillroomPalette.gaslight,
          strength: 0.15,
        )
        ..paper(inside.deflate(a.u * 6), lines: 2, angle: (i - 2) * 0.03)
        ..fill(
          Rect.fromLTWH(
            inside.right - a.u * 8,
            inside.top + a.u * 4,
            a.u * 3,
            a.u * 10,
          ),
          StillroomPalette.oxblood,
        );
    }
  }
}

void _floorRing(Art a) {
  a
    ..oval(a.r(0.1, 0.55, 0.8, 0.35), const Color(0x55000000), line: 0)
    ..canvas.drawOval(
      a.r(0.15, 0.3, 0.5, 0.45),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = a.u * 5
        ..color = StillroomPalette.brass,
    )
    ..line(a.p(0.63, 0.55), a.p(0.92, 0.7), StillroomPalette.brass, width: 5);
}

void _clippings(Art a) {
  a.box(Offset.zero & a.size, const Color(0xFF3A2C20));
  final spots = [
    (0.05, 0.08, 0.4, 0.38, -0.05),
    (0.52, 0.06, 0.42, 0.3, 0.04),
    (0.1, 0.52, 0.34, 0.4, 0.03),
    (0.5, 0.42, 0.24, 0.5, -0.03),
    (0.76, 0.44, 0.2, 0.46, 0.06),
  ];
  for (final (x, y, w, h, angle) in spots) {
    final rect = a.r(x, y, w, h);
    a
      ..paper(rect, lines: 4, angle: angle, color: const Color(0xFFCFC2A2))
      ..circle(
        rect.topCenter.translate(0, a.u * 2),
        a.u * 1.4,
        StillroomPalette.oxblood,
        line: 0.3,
      );
  }
}

void _fadedPaper(Art a) => a
  ..paper(
    a.r(0.04, 0.06, 0.92, 0.88),
    lines: 7,
    color: const Color(0xFFBDB194),
    ink: 0.08,
  )
  ..path(
    a.poly([a.p(0.8, 0.94), a.p(0.96, 0.94), a.p(0.96, 0.7)]),
    const Color(0xFF15110E),
    line: 0,
  );

void _drawer(Art a, {required bool open}) {
  if (!open) {
    a
      ..wood(Offset.zero & a.size, base: StillroomPalette.walnutLight, grain: 2)
      ..box(a.r(0.06, 0.12, 0.88, 0.76), StillroomPalette.walnut, line: 0.5)
      ..rbox(
        a.r(0.36, 0.26, 0.28, 0.48),
        a.u * 2,
        StillroomPalette.brass,
        line: 0.5,
      );
    for (var i = 0; i < 4; i++) {
      a.box(
        a.r(0.39 + i * 0.058, 0.36, 0.045, 0.22),
        const Color(0xFF1B1511),
        line: 0.3,
      );
    }
    return;
  }
  // Pulled out: dark interior above, front panel below.
  a
    ..path(
      a.poly([a.p(0.1, 0.08), a.p(0.9, 0.08), a.p(1, 0.55), a.p(0, 0.55)]),
      const Color(0xFF120D0A),
    )
    ..wood(a.r(0, 0.55, 1, 0.45), base: StillroomPalette.walnutLight, grain: 2)
    ..circle(a.p(0.5, 0.78), a.u * 3, StillroomPalette.brass, line: 0.4);
}

void _streetMap(Art a) {
  final sheet = a.r(0.04, 0.04, 0.92, 0.92);
  a.box(sheet, const Color(0xFFCDBD98));
  final random = math.Random(9);
  for (var i = 0; i < 9; i++) {
    final y = sheet.top + sheet.height * random.nextDouble();
    a.line(
      Offset(sheet.left, y),
      Offset(sheet.right, y + (random.nextDouble() - 0.5) * sheet.height * 0.4),
      StillroomPalette.inkOnPaper.withValues(alpha: 0.3),
      width: 0.8,
    );
  }
  // Compass rose.
  final c = a.p(0.72, 0.72);
  final r = a.size.shortestSide * 0.14;
  a
    ..circle(c, r, const Color(0x00000000), line: 0.5)
    ..path(
      a.poly([
        c.translate(0, -r * 1.2),
        c.translate(r * 0.2, 0),
        c.translate(-r * 0.2, 0),
      ]),
      StillroomPalette.oxblood,
      line: 0.3,
    );
  for (final (x, y) in [
    (0.06, 0.06),
    (0.94, 0.06),
    (0.06, 0.94),
    (0.94, 0.94),
  ]) {
    a.circle(a.p(x, y), a.u * 2, StillroomPalette.oxblood, line: 0.3);
  }
}

void _gaslamp(Art a) {
  a
    ..glow(
      a.p(0.5, 0.16),
      a.size.width * 2.4,
      StillroomPalette.gaslight,
      strength: 0.35,
    )
    ..line(a.p(0.5, 0.3), a.p(0.5, 1), const Color(0xFF101211), width: 5)
    ..path(
      a.poly([
        a.p(0.2, 0.06),
        a.p(0.8, 0.06),
        a.p(0.68, 0.28),
        a.p(0.32, 0.28),
      ]),
      StillroomPalette.gaslight,
      line: 1,
    )
    ..path(
      a.poly([a.p(0.1, 0.06), a.p(0.9, 0.06), a.p(0.5, 0)]),
      const Color(0xFF101211),
      line: 0.6,
    );
}

/// One compass ring as a full-circle picture: an annulus from the edge to
/// [inner] × radius, with step ticks and an arrow at step 0 (the top).
void _ring(
  Art a, {
  required double inner,
  required int steps,
  required Color tone,
}) {
  final c = a.p(0.5, 0.5);
  final outer = a.size.shortestSide / 2;
  final width = outer * (1 - inner);
  final mid = outer - width / 2;
  a.canvas
    ..drawCircle(
      c,
      mid,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width * 0.94
        ..color = tone,
    )
    ..drawCircle(
      c,
      outer * 0.995,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = a.u * 0.6
        ..color = Art.outline,
    )
    ..drawCircle(
      c,
      outer * inner,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = a.u * 0.6
        ..color = Art.outline,
    );
  for (var s = 0; s < steps; s++) {
    final angle = 2 * math.pi * s / steps;
    final dir = Offset(math.sin(angle), -math.cos(angle));
    a.line(
      c + dir * (outer - width * 0.15),
      c + dir * (outer - width * 0.35),
      StillroomPalette.inkOnPaper.withValues(alpha: 0.6),
      width: 0.5,
    );
  }
  a.path(
    a.poly([
      c.translate(0, -outer + width * 0.08),
      c.translate(-width * 0.22, -outer + width * 0.62),
      c.translate(width * 0.22, -outer + width * 0.62),
    ]),
    StillroomPalette.oxblood,
    line: 0.3,
  );
}

void _letterMap(Art a) {
  a.box(Offset.zero & a.size, const Color(0xFFCFC2A2), line: 0.4);
  const brown = Color(0xFF5A3A22);
  for (var i = 0; i < 5; i++) {
    final x = 0.12 + i * 0.19;
    final base = a.p(x, 0.85);
    final tip = a.p(x + (i.isEven ? 0.02 : -0.02), 0.2);
    a
      ..line(base, tip, brown, width: 0.9)
      ..path(
        a.poly([
          tip.translate(0, -a.u * 4),
          tip.translate(-a.u * 2.5, a.u * 2),
          tip.translate(a.u * 2.5, a.u * 2),
        ]),
        brown,
        line: 0,
      );
  }
  a.label('N', a.p(0.5, 0.12), a.size.height * 0.16, brown);
}

// ---------------------------------------------------------------------------
// Items

void _matches(Art a) {
  a
    ..canvas.save()
    ..canvas.translate(a.size.width / 2, a.size.height / 2)
    ..canvas.rotate(-0.2)
    ..canvas.translate(-a.size.width / 2, -a.size.height / 2);
  for (var i = 0; i < 3; i++) {
    final x = 0.36 + i * 0.1;
    a
      ..line(a.p(x, 0.18), a.p(x, 0.5), const Color(0xFFC9A873), width: 2.4)
      ..circle(
        a.p(x, 0.18),
        a.u * 3.2,
        StillroomPalette.oxbloodBright,
        line: 0.4,
      );
  }
  a
    ..box(a.r(0.2, 0.42, 0.6, 0.36), const Color(0xFF3B2A1C))
    ..box(a.r(0.28, 0.5, 0.44, 0.2), StillroomPalette.paperShade, line: 0.3)
    ..canvas.restore();
}

void _letterIcon(Art a) {
  final sheet = a.r(0.14, 0.24, 0.72, 0.52);
  a
    ..box(sheet, StillroomPalette.paper)
    ..line(sheet.topLeft, sheet.center, Art.outline, width: 0.8)
    ..line(sheet.topRight, sheet.center, Art.outline, width: 0.8)
    ..circle(
      sheet.center.translate(0, a.u * 4),
      a.u * 7,
      StillroomPalette.oxblood,
      line: 0.5,
    );
}

/// The letter's close-up (square). Its lower band [0.62–0.90] is the folded
/// part that the `letter_street_names` layer reveals.
void _letterSheet(Art a) {
  a
    ..fill(Offset.zero & a.size, const Color(0xFF15110E))
    ..paper(
      a.r(0.08, 0.06, 0.84, 0.86),
      lines: 9,
      color: const Color(0xFFCFC2A2),
      ink: 0.45,
    )
    ..box(a.r(0.1, 0.62, 0.8, 0.28), const Color(0xFFB3A585), line: 0.5)
    ..fade(
      a.r(0.1, 0.62, 0.8, 0.05),
      const Color(0x55000000),
      const Color(0x00000000),
    );
}

void _lens(Art a) {
  final c = a.p(0.5, 0.5);
  final r = a.size.shortestSide * 0.32;
  a
    ..circle(c, r, StillroomPalette.fog.withValues(alpha: 0.7), line: 0.8)
    ..canvas.drawArc(
      Rect.fromCircle(center: c, radius: r * 0.7),
      -2.6,
      1.2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = a.u * 3
        ..strokeCap = StrokeCap.round
        ..color = StillroomPalette.paper.withValues(alpha: 0.7),
    );
}

void _magnifier(Art a, {required bool glass, required bool handle}) {
  final c = a.p(0.42, 0.42);
  final r = a.size.shortestSide * 0.26;
  if (handle) {
    a.line(
      c + Offset(r * 0.8, r * 0.8),
      a.p(0.88, 0.88),
      StillroomPalette.walnutLight,
      width: 9,
    );
  } else {
    a.line(
      c + Offset(r * 0.8, r * 0.8),
      a.p(0.7, 0.7),
      StillroomPalette.brass,
      width: 5,
    );
  }
  if (glass) {
    a.circle(c, r, StillroomPalette.fog.withValues(alpha: 0.6), line: 0);
  }
  a.canvas.drawCircle(
    c,
    r,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = a.u * 6
      ..color = StillroomPalette.brass,
  );
}

void _nameCard(Art a) => a
  ..paper(a.r(0.12, 0.26, 0.76, 0.48), lines: 2, angle: -0.06)
  ..fill(a.r(0.66, 0.2, 0.08, 0.3), StillroomPalette.oxblood);

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
  // Fog inside, a gas lamp glowing through it.
  a
    ..fade(
      a.r(0, 0.2, 1, 0.8),
      const Color(0xFF3B443F),
      const Color(0xFF6B746D),
    )
    ..glow(a.p(0.66, 0.5), w * 0.35, StillroomPalette.gaslight, strength: 0.6)
    ..line(
      a.p(0.66, 0.54),
      a.p(0.66, 0.95),
      const Color(0xFF101211),
      width: 1.6,
    )
    ..fill(a.r(0.61, 0.46, 0.1, 0.08), StillroomPalette.gaslight)
    ..path(
      a.poly([
        a.p(0, 0.9),
        a.p(0.2, 0.8),
        a.p(0.35, 0.84),
        a.p(0.45, 0.74),
        a.p(0.52, 0.8),
        a.p(0.52, 1),
        a.p(0, 1),
      ]),
      const Color(0xFF1B201D),
      line: 0,
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
  a
    ..fill(a.r(0.28, 0.08, 0.44, 0.09), StillroomPalette.walnutLight)
    ..rbox(a.r(0.3, 0, 0.4, 0.1), 3, const Color(0xFF7A5A3A), line: 0);
}

// ---------------------------------------------------------------------------
// Reveal puzzles and the label

/// The night street through the window, and what was written on the glass.
void _fogWritingBoard(Art a) {
  a
    ..fade(
      Offset.zero & a.size,
      const Color(0xFF1B2226),
      const Color(0xFF2E3833),
    )
    ..path(
      a.poly([
        a.p(0, 0.72),
        a.p(0.12, 0.6),
        a.p(0.2, 0.64),
        a.p(0.26, 0.5),
        a.p(0.31, 0.5),
        a.p(0.33, 0.6),
        a.p(0.5, 0.55),
        a.p(0.62, 0.62),
        a.p(0.74, 0.52),
        a.p(0.8, 0.58),
        a.p(1, 0.54),
        a.p(1, 1),
        a.p(0, 1),
      ]),
      const Color(0xFF111513),
      line: 0,
    )
    ..glow(
      a.p(0.14, 0.62),
      a.size.width * 0.18,
      StillroomPalette.gaslight,
      strength: 0.4,
    )
    ..circle(a.p(0.14, 0.62), a.u * 1.2, StillroomPalette.gaslight, line: 0)
    // Mullions.
    ..wood(a.r(0.49, 0, 0.02, 1), grain: 0)
    ..wood(a.r(0, 0.86, 1, 0.03), grain: 0);
  // Words traced in the condensation from the inside, a little uneven.
  const trace = Color(0xCCD7DED9);
  a
    ..script(
      'Berner St.',
      a.p(0.4, 0.4),
      a.size.height * 0.12,
      trace,
      angle: -0.05,
    )
    ..script(
      'Mitre Sq.',
      a.p(0.6, 0.58),
      a.size.height * 0.12,
      trace,
      angle: 0.03,
    )
    ..line(a.p(0.44, 0.49), a.p(0.52, 0.5), trace, width: 0.8);
  for (final (x, y) in [(0.33, 0.47), (0.58, 0.66), (0.7, 0.64)]) {
    a.line(a.p(x, y), a.p(x, y + 0.12), const Color(0x66D7DED9), width: 0.4);
  }
}

/// On the window scene once wiped: a clear patch and the traced words.
void _fogWriting(Art a) {
  a
    ..canvas.drawOval(
      a.r(0.08, 0.3, 0.84, 0.42),
      Paint()
        ..color = const Color(0x88141A18)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, a.u * 3),
    )
    ..script(
      'Berner St.',
      a.p(0.42, 0.44),
      a.size.height * 0.08,
      const Color(0xBBD7DED9),
      angle: -0.05,
    )
    ..script(
      'Mitre Sq.',
      a.p(0.6, 0.57),
      a.size.height * 0.08,
      const Color(0xBBD7DED9),
      angle: 0.03,
    );
}

/// Soot-black hearth floor with a scrap the fire would not take.
void _hearthNote(Art a) {
  a.fade(
    Offset.zero & a.size,
    const Color(0xFF15110F),
    const Color(0xFF221B17),
  );
  for (var i = 0; i < 7; i++) {
    a.hairline(
      a.p(0, i / 7 + 0.07),
      a.p(1, i / 7 + 0.07),
      const Color(0xFF2B231E),
      0.6,
    );
  }
  final scrap = a.poly([
    a.p(0.33, 0.33),
    a.p(0.45, 0.3),
    a.p(0.58, 0.34),
    a.p(0.67, 0.31),
    a.p(0.69, 0.5),
    a.p(0.65, 0.66),
    a.p(0.52, 0.69),
    a.p(0.4, 0.66),
    a.p(0.31, 0.6),
  ]);
  a
    ..path(scrap, const Color(0xFFCDBB94), line: 0)
    ..canvas.drawPath(
      scrap,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = a.u * 2.2
        ..color = const Color(0xFF3B2414)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, a.u * 0.8),
    )
    ..scrawl(
      a.r(0.37, 0.37, 0.28, 0.26),
      StillroomPalette.inkOnPaper,
      lines: 5,
      seed: 18,
    );
}

/// Grey ash, heaped unevenly, a few embers still in it.
void _ash(Art a) {
  a.fill(Offset.zero & a.size, const Color(0xFF4A4541));
  final random = math.Random(5);
  for (var i = 0; i < 60; i++) {
    a.canvas.drawCircle(
      a.p(random.nextDouble(), random.nextDouble()),
      a.u * (1 + random.nextDouble() * 5),
      Paint()
        ..color = Color.lerp(
          const Color(0xFF34302D),
          const Color(0xFF79726B),
          random.nextDouble(),
        )!.withValues(alpha: 0.6)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, a.u),
    );
  }
  for (var i = 0; i < 8; i++) {
    final p = a.p(random.nextDouble(), random.nextDouble());
    a
      ..glow(p, a.u * 3, StillroomPalette.oxbloodBright, strength: 0.5)
      ..circle(p, a.u * 0.4, StillroomPalette.gaslight, line: 0);
  }
}

/// Behind the deduction screen: the jar's glass, close.
void jarLabelBoard(Art a, Color wall) {
  a
    ..fill(Offset.zero & a.size, Color.lerp(wall, Art.outline, 0.5)!)
    ..glow(
      a.p(0.5, 0.5),
      a.size.width * 0.6,
      const Color(0xFF55605A),
      strength: 0.25,
    )
    ..canvas.drawArc(
      a.r(-0.2, -0.3, 1.4, 1.6),
      3.5,
      2.4,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = a.u * 1.2
        ..color = const Color(0x22FFFFFF),
    )
    ..hairline(a.p(0.08, 0.1), a.p(0.06, 0.9), const Color(0x18FFFFFF), 2);
}

/// Over the street map once solved: five streets, five arrows, all north.
void _streetMapSolved(Art a) {
  a.glow(
    a.p(0.72, 0.72),
    a.size.shortestSide * 0.4,
    StillroomPalette.gaslight,
    strength: 0.3,
  );
  for (var i = 0; i < 5; i++) {
    final x = 0.14 + i * 0.12;
    final y = 0.26 + (i % 2) * 0.16;
    a
      ..line(a.p(x, y + 0.14), a.p(x, y), StillroomPalette.oxblood, width: 1)
      ..path(
        a.poly([
          a.p(x - 0.03, y + 0.03),
          a.p(x, y - 0.02),
          a.p(x + 0.03, y + 0.03),
        ]),
        StillroomPalette.oxblood,
        line: 0,
      );
  }
}

/// The scrap that would not burn, now lying clear of the ash.
void _hearthScrap(Art a) {
  final scrap = a.poly([
    a.p(0.08, 0.3),
    a.p(0.5, 0.12),
    a.p(0.92, 0.28),
    a.p(0.86, 0.82),
    a.p(0.14, 0.9),
  ]);
  a
    ..glow(
      a.p(0.5, 0.5),
      a.size.width * 0.6,
      StillroomPalette.gaslight,
      strength: 0.25,
    )
    ..path(scrap, const Color(0xFFCDBB94), line: 0.4)
    ..scrawl(
      a.r(0.2, 0.3, 0.6, 0.45),
      StillroomPalette.inkOnPaper,
      lines: 3,
      seed: 18,
      width: 0.2,
    );
}
