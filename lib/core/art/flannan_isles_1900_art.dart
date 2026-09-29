import 'dart:math' as math;
import 'dart:ui';

import '../theme/stillroom_palette.dart';
import 'art_kit.dart';
import 'echo_art.dart';
import 'whitechapel_1888_art.dart' show jarLabelBoard;

/// Code-drawn art for "Flannan Isles, 1900" (docs/episodes/
/// flannan_isles_1900.md): a lighthouse on a bare island at dusk, the sea
/// everywhere, whitewash gone blue in the failing light.
const _s = 'images/scenes/flannan_isles_1900';
const _o = 'images/objects/flannan_isles_1900';
const _i = 'images/items/flannan_isles_1900';

final Map<String, ArtPainter> flannanArt = {
  // Scenes and puzzle boards.
  '$_s/east_landing.png': (c, s) => _eastLanding(Art(c, s)),
  '$_s/yard.png': (c, s) => _yard(Art(c, s)),
  '$_s/kitchen.png': (c, s) => _kitchen(Art(c, s)),
  '$_s/oil_store.png': (c, s) => _oilStore(Art(c, s)),
  '$_s/stair.png': (c, s) => _stair(Art(c, s)),
  '$_s/lamp_room.png': (c, s) => _lampRoom(Art(c, s)),
  '$_s/west_landing.png': (c, s) => _westLanding(Art(c, s)),
  '$_s/clockwork_close.png': (c, s) => _clockworkBoard(Art(c, s)),
  '$_s/label_close.png': (c, s) => jarLabelBoard(Art(c, s), _night),
  // Objects.
  '$_o/gate_closed_sprite.png': (c, s) => _gate(Art(c, s), open: false),
  '$_o/gate_open_sprite.png': (c, s) => _gate(Art(c, s), open: true),
  '$_o/beam_sprite.png': (c, s) => _beam(Art(c, s)),
  '$_o/matches_sprite.png': (c, s) => _matches(Art(c, s)),
  '$_o/lantern_sprite.png': (c, s) => _lantern(Art(c, s), lit: false),
  '$_o/paraffin_sprite.png': (c, s) => _paraffin(Art(c, s)),
  '$_o/handle_sprite.png': (c, s) => _handle(Art(c, s)),
  '$_o/key_sprite.png': (c, s) => _key(Art(c, s)),
  '$_o/lens_dark_sprite.png': (c, s) => _lens(Art(c, s), lit: false),
  '$_o/lens_lit_sprite.png': (c, s) => _lens(Art(c, s), lit: true),
  '$_o/echo_keeper.png': (c, s) => paintEcho(Art(c, s), EchoFigure.keeper),
  '$_o/rope_plate_clean_sprite.png': (c, s) => _ropePlateSmall(Art(c, s)),
  '$_o/door_open_sprite.png': (c, s) => _stairDoorOpen(Art(c, s)),
  '$_o/clockwork_wound_sprite.png': (c, s) => _clockworkWound(Art(c, s)),
  // Items.
  '$_i/matches.png': (c, s) => _matches(Art(c, s)),
  '$_i/hand_lantern.png': (c, s) => _lantern(Art(c, s), lit: false),
  '$_i/lit_lantern.png': (c, s) => _lantern(Art(c, s), lit: true),
  '$_i/paraffin.png': (c, s) => _paraffin(Art(c, s)),
  '$_i/crank_handle.png': (c, s) => _handle(Art(c, s)),
  '$_i/lamp_key.png': (c, s) => _key(Art(c, s)),
  // The jar on the shelf.
  'images/ui/jar_flannan_isles_1900.png': (c, s) => _jar(Art(c, s)),
};

// ---------------------------------------------------------------------------
// Palette

const _night = Color(0xFF1B2330);
const _dusk = Color(0xFF3A4658);
const _sea = Color(0xFF1C2A33);
const _foam = Color(0xFFB9C4C6);
const _grass = Color(0xFF26302A);
const _rock = Color(0xFF2E3131);
const _stone = Color(0xFF4A4F52);
const _whitewash = Color(0xFF8E9AA4);
const _whitewashDark = Color(0xFF65717C);
const _iron = Color(0xFF22272B);
const _oilskin = Color(0xFFB08A2E);
const _lamp = Color(0xFFF1C66A);

// ---------------------------------------------------------------------------
// Shared pieces

void _sky(Art a, {double horizon = 0.62}) {
  a
    ..fade(a.r(0, 0, 1, horizon), _night, _dusk)
    ..fade(a.r(0, horizon, 1, 1 - horizon), _sea, const Color(0xFF0E151A));
  final random = math.Random(3);
  for (var i = 0; i < 14; i++) {
    final y = horizon + random.nextDouble() * (1 - horizon);
    final x = random.nextDouble();
    a.hairline(
      a.p(x, y),
      a.p(x + 0.05 + random.nextDouble() * 0.1, y),
      _foam.withValues(alpha: 0.25),
      0.4,
    );
  }
}

void _fog(Art a, {double strength = 0.18}) {
  for (final (x, y, r) in [
    (0.1, 0.7, 0.35),
    (0.5, 0.55, 0.4),
    (0.9, 0.65, 0.3),
  ]) {
    a.glow(a.p(x, y), a.size.width * r, _foam, strength: strength);
  }
}

/// A whitewashed interior wall, cold in the dusk.
void _whiteRoom(Art a, {double floor = 0.78}) {
  a
    ..fade(a.r(0, 0, 1, floor), _whitewash, _whitewashDark)
    ..fade(
      a.r(0, floor, 1, 1 - floor),
      const Color(0xFF3B3430),
      const Color(0xFF221D1A),
    )
    ..hairline(a.p(0, floor), a.p(1, floor), Art.outline, 0.8);
}

// ---------------------------------------------------------------------------
// Scenes

void _eastLanding(Art a) {
  _sky(a, horizon: 0.58);
  // The cliff and the island top.
  a
    ..path(
      a.poly([
        a.p(0.22, 1),
        a.p(0.3, 0.72),
        a.p(0.36, 0.7),
        a.p(0.4, 0.62),
        a.p(1, 0.6),
        a.p(1, 1),
      ]),
      _rock,
      line: 0.5,
    )
    ..fill(a.r(0.36, 0.6, 0.64, 0.12), _grass);
  // Steps cut into the cliff.
  for (var i = 0; i < 7; i++) {
    final y = 0.72 + i * 0.04;
    a.hairline(a.p(0.3 - i * 0.01, y), a.p(0.38 - i * 0.012, y), _stone, 1);
  }
  // The walls either side of the gate.
  a
    ..box(a.r(0.3, 0.44, 0.14, 0.28), _stone, line: 0.4)
    ..box(a.r(0.58, 0.44, 0.3, 0.28), _stone, line: 0.4)
    ..box(a.r(0.6, 0.36, 0.08, 0.1), StillroomPalette.brass, line: 0.4)
    ..label(
      '7 · XII · 1899',
      a.p(0.64, 0.41),
      a.size.height * 0.022,
      Art.outline,
    )
    // Flagpole, bare.
    ..line(
      a.p(0.265, 0.56),
      a.p(0.265, 0.07),
      const Color(0xFF9AA0A2),
      width: 0.7,
    )
    ..circle(a.p(0.265, 0.07), a.u * 0.6, StillroomPalette.brass, line: 0.2);
  // The relief boat below, in the fog.
  a
    ..path(
      a.poly([
        a.p(0.03, 0.74),
        a.p(0.19, 0.74),
        a.p(0.17, 0.78),
        a.p(0.05, 0.78),
      ]),
      const Color(0xFF14191C),
      line: 0.3,
    )
    ..line(a.p(0.1, 0.74), a.p(0.1, 0.64), const Color(0xFF14191C), width: 0.6)
    ..glow(a.p(0.06, 0.73), a.u * 5, _lamp, strength: 0.5)
    ..glow(a.p(0.16, 0.72), a.u * 5, _lamp, strength: 0.5);
  _fog(a);
}

void _gate(Art a, {required bool open}) {
  if (open) {
    a
      ..fill(a.r(0, 0, 1, 1), const Color(0x33121518))
      ..box(a.r(0.02, 0.06, 0.12, 0.94), _iron, line: 0.4);
    for (var i = 0; i < 3; i++) {
      a.line(
        a.p(0.04 + i * 0.04, 0.08),
        a.p(0.04 + i * 0.04, 0.98),
        _iron,
        width: 0.8,
      );
    }
    return;
  }
  a
    ..line(a.p(0.03, 0.08), a.p(0.97, 0.08), _iron, width: 1.2)
    ..line(a.p(0.03, 0.55), a.p(0.97, 0.55), _iron, width: 1);
  for (var i = 0; i <= 8; i++) {
    final x = 0.03 + i * 0.1175;
    a
      ..line(a.p(x, 0.04), a.p(x, 1), _iron, width: 0.9)
      ..path(
        a.poly([a.p(x - 0.02, 0.05), a.p(x, 0.0), a.p(x + 0.02, 0.05)]),
        _iron,
        line: 0,
      );
  }
  a
    ..box(a.r(0.42, 0.44, 0.16, 0.14), StillroomPalette.brass, line: 0.4)
    ..circle(a.p(0.5, 0.51), a.u * 1.2, Art.outline, line: 0);
}

void _yard(Art a) {
  _sky(a, horizon: 0.68);
  a.fill(a.r(0, 0.64, 1, 0.36), _grass);
  // The tower: white stone, dark lantern.
  final tower = a.poly([
    a.p(0.535, 0.7),
    a.p(0.555, 0.12),
    a.p(0.625, 0.12),
    a.p(0.645, 0.7),
  ]);
  a
    ..path(tower, _whitewash, line: 0.5)
    ..box(a.r(0.54, 0.08, 0.1, 0.05), _iron, line: 0.3)
    ..box(a.r(0.55, 0.02, 0.08, 0.07), const Color(0xFF2B3440), line: 0.4)
    ..path(
      a.poly([a.p(0.545, 0.02), a.p(0.59, -0.02), a.p(0.635, 0.02)]),
      _iron,
      line: 0.3,
    )
    ..box(a.r(0.565, 0.38, 0.05, 0.28), const Color(0xFF1C1612), line: 0.4);
  // Living quarters on the left, a low flat-roofed range.
  a
    ..box(a.r(0.0, 0.3, 0.3, 0.42), _whitewash, line: 0.5)
    ..box(a.r(0.08, 0.36, 0.14, 0.36), const Color(0xFF2A211A), line: 0.4)
    ..box(a.r(0.02, 0.36, 0.04, 0.1), const Color(0xFF151A20), line: 0.3)
    // The oil store, a small hut.
    ..box(a.r(0.29, 0.44, 0.13, 0.3), _whitewashDark, line: 0.4)
    ..box(a.r(0.31, 0.48, 0.08, 0.26), const Color(0xFF1C1612), line: 0.3);
  // The path west, and the rail across it.
  a
    ..path(
      a.poly([a.p(0.72, 1), a.p(0.8, 0.66), a.p(0.98, 0.62), a.p(1, 1)]),
      const Color(0xFF3A3A36),
      line: 0,
    )
    ..line(a.p(0.78, 0.74), a.p(0.98, 0.7), const Color(0xFF5B5550), width: 1.2)
    ..line(a.p(0.8, 0.84), a.p(0.99, 0.8), const Color(0xFF5B5550), width: 1.2)
    ..line(
      a.p(0.79, 0.64),
      a.p(0.95, 0.78),
      const Color(0xFF6E6862),
      width: 1.4,
    );
}

void _beam(Art a, {Offset? from}) {
  final origin = from ?? a.p(0.39, 0.12);
  for (final (end, spread) in [(a.p(1.0, 0.0), 0.05), (a.p(0.0, 0.3), 0.03)]) {
    final dir = end - origin;
    final normal = Offset(-dir.dy, dir.dx) / dir.distance;
    final width = a.size.height * spread * 4;
    final beam = Path()
      ..moveTo(origin.dx, origin.dy)
      ..lineTo(end.dx + normal.dx * width, end.dy + normal.dy * width)
      ..lineTo(end.dx - normal.dx * width, end.dy - normal.dy * width)
      ..close();
    a.canvas.drawPath(
      beam,
      Paint()
        ..shader = Gradient.linear(origin, end, [
          _lamp.withValues(alpha: 0.5),
          _lamp.withValues(alpha: 0),
        ]),
    );
  }
  a.glow(origin, a.size.width * 0.08, _lamp, strength: 0.8);
}

void _kitchen(Art a) {
  _whiteRoom(a);
  // Shelf with the magazine.
  a
    ..wood(a.r(0.22, 0.2, 0.16, 0.02), grain: 0)
    ..paper(
      a.r(0.25, 0.11, 0.1, 0.09),
      lines: 3,
      angle: -0.08,
      color: const Color(0xFFD6C89E),
    );
  // The stopped clock.
  final clock = a.p(0.49, 0.17);
  a
    ..circle(clock, a.u * 7, const Color(0xFFE2DAC4), line: 0.6)
    ..line(clock, clock + Offset(0, -a.u * 5), Art.outline, width: 0.5)
    ..line(clock, clock + Offset(a.u * 3, a.u * 1), Art.outline, width: 0.7);
  // The black range, cold.
  a
    ..box(a.r(0.04, 0.4, 0.2, 0.38), const Color(0xFF17191B), line: 0.6)
    ..box(a.r(0.06, 0.46, 0.07, 0.1), const Color(0xFF0C0D0E), line: 0.3)
    ..box(a.r(0.15, 0.46, 0.07, 0.1), const Color(0xFF0C0D0E), line: 0.3)
    ..line(a.p(0.04, 0.4), a.p(0.24, 0.4), const Color(0xFF6C6F72), width: 0.8)
    ..fill(a.r(0.12, 0.0, 0.05, 0.4), const Color(0xFF1B1D1F));
  // The scrubbed table and the log book.
  a
    ..wood(a.r(0.34, 0.58, 0.3, 0.04), base: const Color(0xFF7A6A52), grain: 1)
    ..wood(a.r(0.36, 0.62, 0.02, 0.16), vertical: true, grain: 0)
    ..wood(a.r(0.6, 0.62, 0.02, 0.16), vertical: true, grain: 0)
    ..box(a.r(0.39, 0.52, 0.08, 0.06), const Color(0xFF3E2A1C), line: 0.4)
    ..paper(
      a.r(0.395, 0.525, 0.07, 0.04),
      lines: 2,
      color: const Color(0xFFD9CCAE),
    );
  // The slate by the door.
  a
    ..box(a.r(0.58, 0.18, 0.1, 0.14), const Color(0xFF2A2E31), line: 0.6)
    ..scrawl(
      a.r(0.59, 0.2, 0.08, 0.1),
      const Color(0xCCE0E2E0),
      lines: 4,
      seed: 4,
      width: 0.3,
    );
  // Three hooks with tags; only the third keeps its oilskin.
  for (var i = 0; i < 3; i++) {
    final x = 0.77 + i * 0.05;
    a
      ..circle(a.p(x, 0.18), a.u * 0.8, StillroomPalette.brass, line: 0.2)
      ..box(
        a.r(x - 0.012, 0.2, 0.024, 0.02),
        const Color(0xFFD9CCAE),
        line: 0.2,
      );
  }
  a
    ..path(
      a.poly([
        a.p(0.87, 0.19),
        a.p(0.9, 0.26),
        a.p(0.91, 0.56),
        a.p(0.83, 0.56),
        a.p(0.84, 0.26),
      ]),
      _oilskin,
      line: 0.5,
    )
    ..line(a.p(0.87, 0.27), a.p(0.87, 0.55), Art.outline, width: 0.3);
}

void _matches(Art a) {
  a
    ..box(a.r(0.15, 0.35, 0.7, 0.4), const Color(0xFFB53A2A), line: 0.6)
    ..box(a.r(0.25, 0.43, 0.5, 0.24), const Color(0xFFE6D7B0), line: 0.3)
    ..line(a.p(0.3, 0.55), a.p(0.7, 0.55), const Color(0xFF2B2B2B), width: 0.6);
}

void _lantern(Art a, {required bool lit}) {
  final body = a.r(0.3, 0.3, 0.4, 0.5);
  if (lit) {
    a.glow(
      body.center,
      a.size.shortestSide * 0.8,
      StillroomPalette.gaslight,
      strength: 0.55,
    );
  }
  a
    ..strokePath(
      Path()..addArc(a.r(0.36, 0.06, 0.28, 0.26), math.pi, math.pi),
      _iron,
      width: 1.2,
    )
    ..box(a.r(0.28, 0.22, 0.44, 0.08), _iron, line: 0.5)
    ..box(
      body,
      lit ? const Color(0xAAF1D68A) : const Color(0x557F8E8A),
      line: 0.6,
    )
    ..box(a.r(0.26, 0.8, 0.48, 0.1), _iron, line: 0.5);
  for (final x in [0.4, 0.5, 0.6]) {
    a.line(a.p(x, 0.3), a.p(x, 0.8), _iron, width: 0.5);
  }
  if (lit) a.flame(a.p(0.5, 0.68), a.size.height * 0.22);
}

void _oilStore(Art a) {
  _whiteRoom(a, floor: 0.8);
  a.fill(Offset.zero & a.size, const Color(0x55000000));
  // Shelves of cans.
  for (var row = 0; row < 3; row++) {
    final y = 0.42 + row * 0.13;
    a.wood(a.r(0.05, y + 0.1, 0.33, 0.02), grain: 0);
    for (var i = 0; i < 5; i++) {
      a.box(
        a.r(0.07 + i * 0.06, y, 0.05, 0.1),
        const Color(0xFF6B2A22),
        line: 0.3,
      );
    }
  }
  // The bench where the handle lies.
  a
    ..wood(a.r(0.62, 0.64, 0.3, 0.04), grain: 1)
    ..wood(a.r(0.64, 0.68, 0.02, 0.12), vertical: true, grain: 0)
    ..wood(a.r(0.88, 0.68, 0.02, 0.12), vertical: true, grain: 0);
}

void _paraffin(Art a) {
  a
    ..box(a.r(0.2, 0.2, 0.6, 0.72), const Color(0xFF6B2A22), line: 0.6)
    ..box(a.r(0.42, 0.08, 0.16, 0.12), const Color(0xFF4A4F52), line: 0.4)
    ..box(a.r(0.28, 0.4, 0.44, 0.24), const Color(0xFFD9CCAE), line: 0.3)
    ..label('PARAFFIN', a.p(0.5, 0.52), a.size.height * 0.07, Art.outline);
}

void _handle(Art a) {
  a
    ..line(a.p(0.15, 0.6), a.p(0.7, 0.6), const Color(0xFF3C4045), width: 3)
    ..line(a.p(0.7, 0.6), a.p(0.7, 0.3), const Color(0xFF3C4045), width: 3)
    ..box(a.r(0.64, 0.12, 0.12, 0.2), const Color(0xFF5A3A26), line: 0.5)
    ..box(a.r(0.08, 0.54, 0.1, 0.12), const Color(0xFF3C4045), line: 0.5);
}

void _key(Art a) {
  a
    ..circle(
      a.p(0.3, 0.5),
      a.size.shortestSide * 0.2,
      StillroomPalette.brass,
      line: 0.6,
    )
    ..circle(
      a.p(0.3, 0.5),
      a.size.shortestSide * 0.09,
      const Color(0xFF15191C),
      line: 0.3,
    )
    ..box(a.r(0.46, 0.46, 0.44, 0.08), StillroomPalette.brass, line: 0.4)
    ..box(a.r(0.8, 0.54, 0.05, 0.12), StillroomPalette.brass, line: 0.3)
    ..box(a.r(0.7, 0.54, 0.05, 0.08), StillroomPalette.brass, line: 0.3);
}

void _stair(Art a) {
  // The curved inside of the tower, and the stair winding up.
  a.fade(Offset.zero & a.size, _whitewashDark, const Color(0xFF2E353C));
  for (var i = 0; i < 12; i++) {
    final t = i / 12;
    final y = 1 - t * 0.66;
    final x0 = 0.1 + 0.3 * math.sin(t * math.pi);
    a
      ..box(a.r(x0, y - 0.05, 0.5 - 0.2 * t, 0.05), _stone, line: 0.4)
      ..hairline(
        a.p(x0, y - 0.05),
        a.p(x0 + 0.5 - 0.2 * t, y - 0.05),
        const Color(0xFF6E767C),
        0.4,
      );
  }
  // Iron handrail.
  a.strokePath(
    Path()
      ..moveTo(a.size.width * 0.9, a.size.height * 0.95)
      ..quadraticBezierTo(
        a.size.width * 0.95,
        a.size.height * 0.5,
        a.size.width * 0.62,
        a.size.height * 0.3,
      ),
    _iron,
    width: 0.8,
  );
  // The lamp-room door at the top.
  a
    ..box(a.r(0.42, 0.06, 0.16, 0.3), const Color(0xFF2A211A), line: 0.6)
    ..circle(a.p(0.55, 0.22), a.u * 0.8, StillroomPalette.brass, line: 0.2)
    // A nail for the key.
    ..circle(a.p(0.745, 0.37), a.u * 0.5, _iron, line: 0)
    // The fourth hook, with an empty tag.
    ..circle(a.p(0.19, 0.47), a.u * 0.8, StillroomPalette.brass, line: 0.2)
    ..box(a.r(0.175, 0.49, 0.03, 0.025), const Color(0xFFD9CCAE), line: 0.2);
}

void _lampRoom(Art a) {
  // Glazing all round: dusk and sea through the diamond panes.
  _sky(a, horizon: 0.55);
  for (var i = 0; i <= 8; i++) {
    a.line(a.p(i / 8, 0), a.p(i / 8, 0.78), _iron, width: 1);
  }
  for (var i = 0; i < 16; i++) {
    final x = i / 8 - 1;
    a
      ..hairline(
        a.p(x, 0),
        a.p(x + 0.8, 0.78),
        _iron.withValues(alpha: 0.6),
        0.4,
      )
      ..hairline(
        a.p(x + 0.8, 0),
        a.p(x, 0.78),
        _iron.withValues(alpha: 0.6),
        0.4,
      );
  }
  a
    ..fill(a.r(0, 0.78, 1, 0.22), const Color(0xFF3A3F43))
    ..hairline(a.p(0, 0.78), a.p(1, 0.78), Art.outline, 1);
  // The clockwork cabinet.
  a
    ..box(a.r(0.05, 0.52, 0.2, 0.3), const Color(0xFF3A2C22), line: 0.6)
    ..circle(a.p(0.15, 0.64), a.u * 5, StillroomPalette.brass, line: 0.5)
    ..circle(a.p(0.15, 0.64), a.u * 1, Art.outline, line: 0);
  // Pages pinned by the lens.
  a
    ..paper(a.r(0.77, 0.55, 0.05, 0.1), lines: 5, angle: 0.06)
    ..paper(a.r(0.81, 0.56, 0.05, 0.1), lines: 5, angle: -0.05);
  // The pedestal.
  a.box(a.r(0.42, 0.64, 0.16, 0.16), _iron, line: 0.5);
}

void _lens(Art a, {required bool lit}) {
  final body = a.r(0.1, 0.02, 0.8, 0.96);
  if (lit) {
    a.glow(body.center, a.size.width * 1.1, _lamp, strength: 0.6);
  }
  a.canvas.drawOval(
    body,
    Paint()..color = lit ? const Color(0xCCF6DFA0) : const Color(0x9960707C),
  );
  // Rings of prisms.
  for (var i = 1; i <= 6; i++) {
    final inset = i * 0.06;
    a.canvas.drawOval(
      a.r(0.1 + inset * 0.5, 0.02 + inset, 0.8 - inset, 0.96 - inset * 2),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = a.u * 0.5
        ..color = lit ? const Color(0xFFB88A2A) : const Color(0xFF3B4650),
    );
  }
  a.line(a.p(0.5, 0.02), a.p(0.5, 0.98), Art.outline, width: 0.4);
  if (lit) a.flame(a.p(0.5, 0.58), a.size.height * 0.16);
}

void _westLanding(Art a) {
  _sky(a, horizon: 0.5);
  // Rock falling to the sea, the landing cut into it.
  a
    ..path(
      a.poly([
        a.p(0, 0.3),
        a.p(0.35, 0.34),
        a.p(0.7, 0.18),
        a.p(1, 0.14),
        a.p(1, 1),
        a.p(0, 1),
      ]),
      _rock,
      line: 0.6,
    )
    ..fill(a.r(0.66, 0.0, 0.34, 0.14), _grass);
  // Torn turf at the top.
  for (var i = 0; i < 6; i++) {
    final x = 0.68 + i * 0.05;
    a.box(
      a.r(x, 0.08 + (i % 2) * 0.02, 0.03, 0.03),
      const Color(0xFF3B2E22),
      line: 0.2,
    );
  }
  // Twisted railings.
  for (var i = 0; i < 6; i++) {
    final x = 0.06 + i * 0.06;
    a.strokePath(
      Path()
        ..moveTo(a.size.width * x, a.size.height * 0.74)
        ..quadraticBezierTo(
          a.size.width * (x + 0.04),
          a.size.height * (0.6 - (i % 3) * 0.03),
          a.size.width * (x - 0.02 + (i % 2) * 0.06),
          a.size.height * 0.48,
        ),
      const Color(0xFF6A6560),
      width: 0.8,
    );
  }
  // The brackets where the rope box stood, and its plate.
  a
    ..box(a.r(0.47, 0.34, 0.16, 0.02), _iron, line: 0.3)
    ..box(a.r(0.5, 0.2, 0.1, 0.12), const Color(0xFF8C8E86), line: 0.4)
    // The crane, still standing.
    ..line(a.p(0.86, 0.66), a.p(0.86, 0.26), _iron, width: 1.6)
    ..line(a.p(0.86, 0.28), a.p(0.8, 0.4), _iron, width: 1)
    ..line(a.p(0.8, 0.4), a.p(0.8, 0.5), const Color(0xFF5B5550), width: 0.4);
  // Surf.
  for (var i = 0; i < 5; i++) {
    a.glow(
      a.p(0.1 + i * 0.2, 0.96),
      a.size.width * 0.08,
      _foam,
      strength: 0.25,
    );
  }
}

// ---------------------------------------------------------------------------
// Puzzle boards and reveal art

void _clockworkBoard(Art a) {
  a.fill(Offset.zero & a.size, const Color(0xFF1C1814));
  final random = math.Random(8);
  for (var i = 0; i < 7; i++) {
    final c = a.p(
      0.1 + random.nextDouble() * 0.8,
      0.1 + random.nextDouble() * 0.8,
    );
    final r = a.size.height * (0.06 + random.nextDouble() * 0.1);
    a.canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = a.u * 1.4
        ..color = StillroomPalette.brass.withValues(alpha: 0.35),
    );
    for (var k = 0; k < 12; k++) {
      final angle = k * math.pi / 6;
      a.hairline(
        c + Offset(math.cos(angle), math.sin(angle)) * r,
        c + Offset(math.cos(angle), math.sin(angle)) * (r + a.u * 1.2),
        StillroomPalette.brass.withValues(alpha: 0.35),
        0.8,
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
  // Inside: a dark sea, a white tower, its beam.
  a
    ..fade(a.r(0, 0.16, 1, 0.84), _night, _sea)
    ..fill(a.r(0, 0.78, 1, 0.22), _rock)
    ..path(
      a.poly([
        a.p(0.44, 0.8),
        a.p(0.46, 0.44),
        a.p(0.54, 0.44),
        a.p(0.56, 0.8),
      ]),
      _whitewash,
      line: 0.5,
    )
    ..box(a.r(0.45, 0.38, 0.1, 0.06), _lamp, line: 0.4);
  _beam(a, from: a.p(0.5, 0.41));
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
  // Cork.
  a.box(a.r(0.3, 0.04, 0.4, 0.14), const Color(0xFF7A5A3A), line: 0.5);
}

// ---------------------------------------------------------------------------
// After-states

/// The rope-box plate on the rock, wiped clean.
void _ropePlateSmall(Art a) => a
  ..box(Offset.zero & a.size, const Color(0xFFB09A5E), line: 0.5)
  ..label('ROPES', a.p(0.5, 0.4), a.size.height * 0.22, const Color(0xFF2A241A))
  ..label(
    '& TACKLE',
    a.p(0.5, 0.7),
    a.size.height * 0.16,
    const Color(0xFF2A241A),
  );

/// The lamp-room door, open on the grey of the last evening light.
void _stairDoorOpen(Art a) {
  a
    ..fill(a.r(0.1, 0.06, 0.8, 0.94), const Color(0xFF8E98A2))
    ..glow(
      a.p(0.5, 0.4),
      a.size.width * 0.8,
      const Color(0xFFB8C2CC),
      strength: 0.3,
    )
    ..box(a.r(0.1, 0.06, 0.12, 0.94), const Color(0xFF2A211A), line: 0.5);
}

/// The clockwork cabinet, wound: the weights hang high and the dial glows.
void _clockworkWound(Art a) {
  a
    ..box(Offset.zero & a.size, const Color(0xFF3A2C22), line: 0.6)
    ..glow(a.p(0.5, 0.38), a.size.width * 0.5, _lamp, strength: 0.35)
    ..circle(
      a.p(0.5, 0.38),
      a.size.width * 0.23,
      StillroomPalette.brass,
      line: 0.5,
    )
    ..circle(a.p(0.5, 0.38), a.size.width * 0.05, Art.outline, line: 0)
    ..line(a.p(0.25, 0.1), a.p(0.25, 0.3), const Color(0xFF9AA0A2), width: 0.4)
    ..box(a.r(0.2, 0.3, 0.1, 0.12), _iron, line: 0.3)
    ..line(a.p(0.75, 0.1), a.p(0.75, 0.26), const Color(0xFF9AA0A2), width: 0.4)
    ..box(a.r(0.7, 0.26, 0.1, 0.12), _iron, line: 0.3);
}
