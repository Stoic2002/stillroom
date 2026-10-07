import 'dart:math' as math;
import 'dart:ui';

import '../theme/stillroom_palette.dart';
import 'art_kit.dart';
import 'depth_kit.dart';
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
  '$_s/beam_board.png': (c, s) => _beamBoard(Art(c, s)),
  '$_s/swell_board.png': (c, s) => _swellBoard(Art(c, s)),
  '$_s/label_close.png': (c, s) => jarLabelBoard(Art(c, s), _night),
  // Objects.
  '$_o/gate_closed_sprite.png': (c, s) => _gate(Art(c, s), open: false),
  '$_o/gate_open_sprite.png': (c, s) => _gate(Art(c, s), open: true),
  '$_o/beam_sprite.png': (c, s) => _beam(Art(c, s)),
  '$_o/matches_sprite.png': (c, s) => _matches(Art(c, s)),
  '$_o/lantern_sprite.png': (c, s) => _lantern(Art(c, s), lit: false),
  '$_o/paraffin_sprite.png': (c, s) => _paraffinStanding(Art(c, s)),
  '$_o/handle_sprite.png': (c, s) => _handleLying(Art(c, s)),
  '$_o/key_sprite.png': (c, s) => _key(Art(c, s)),
  '$_o/lens_dark_sprite.png': (c, s) => _lens(Art(c, s), lit: false),
  '$_o/lens_lit_sprite.png': (c, s) => _lens(Art(c, s), lit: true),
  '$_o/echo_keeper.png': (c, s) => paintEcho(Art(c, s), EchoFigure.keeper),
  '$_o/rope_plate_clean_sprite.png': (c, s) => _ropePlateSmall(Art(c, s)),
  '$_o/door_open_sprite.png': (c, s) => _stairDoorOpen(Art(c, s)),
  '$_o/clockwork_wound_sprite.png': (c, s) => _clockworkWound(Art(c, s)),
  '$_o/rail_sprite.png': (c, s) => _railAcross(Art(c, s)),
  '$_o/rail_aside_sprite.png': (c, s) => _railAside(Art(c, s)),
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

/// A whitewashed room in one-point perspective, cold in the dusk: the
/// walls gone blue, a tarred dado round their foot, flagstones running
/// back. Returns its camera, for what stands in it.
Room _whiteRoom(Art a, {required Offset eye, required double depth}) {
  final room = Room(a, vp: a.p(eye.dx, eye.dy), depth: depth);
  final back = room.back;
  a
    ..path(room.ceiling, const Color(0xFF3A434C), line: 0)
    ..path(room.leftWall, _whitewashDark, line: 0)
    ..path(room.rightWall, _whitewashDark, line: 0)
    ..fade(back, _whitewash, _whitewashDark);
  // The dado: dark paint to waist height, on the back wall and both sides.
  const dado = Color(0xFF3E3A36);
  const rail = Color(0xFF2A2724);
  a.fill(Rect.fromPoints(room.at(0, 0.24, 1), room.at(1, 0, 1)), dado);
  for (final x in [0.0, 1.0]) {
    a.path(
      a.poly([
        room.at(x, 0, 0),
        room.at(x, 0.24, 0),
        room.at(x, 0.24, 1),
        room.at(x, 0, 1),
      ]),
      Color.lerp(dado, Art.outline, 0.2)!,
      line: 0,
    );
    a.line(room.at(x, 0.24, 0), room.at(x, 0.24, 1), rail, width: 0.6);
  }
  a
    ..line(room.at(0, 0.24, 1), room.at(1, 0.24, 1), rail, width: 0.6)
    ..path(room.floor, const Color(0xFF34302C), line: 0);
  room
    ..floorGrid(const Color(0x66151210), rows: 5, columns: 8, width: 0.4)
    ..shadeCorners(strength: 0.4)
    ..edges(const Color(0x88202428));
  return room;
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
  // The walls either side of the gate, thick enough to stand.
  Room(a, vp: a.p(0.5, 0.58), depth: 0.3)
    ..stand(a.r(0.3, 0.44, 0.14, 0.28), _stone, deep: 0.08, line: 0.4)
    ..stand(a.r(0.58, 0.44, 0.3, 0.28), _stone, deep: 0.08, line: 0.4);
  a
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
  // The relief boat below, in the fog: a small steamer, her lamps lit.
  const hull = Color(0xFF14191C);
  a
    ..path(
      a.poly([
        a.p(0.02, 0.73),
        a.p(0.2, 0.73),
        a.p(0.18, 0.775),
        a.p(0.045, 0.775),
      ]),
      hull,
      line: 0.3,
    )
    ..box(a.r(0.08, 0.7, 0.07, 0.03), const Color(0xFF2A3036), line: 0.3)
    ..box(a.r(0.11, 0.655, 0.018, 0.045), hull, line: 0.3)
    ..line(a.p(0.05, 0.73), a.p(0.05, 0.63), hull, width: 0.5)
    ..line(a.p(0.17, 0.73), a.p(0.17, 0.65), hull, width: 0.4)
    ..line(a.p(0.05, 0.64), a.p(0.17, 0.66), hull, width: 0.25);
  for (var i = 0; i < 4; i++) {
    a.glow(
      a.p(0.125 + i * 0.012, 0.64 - i * 0.02),
      a.u * (1.5 + i),
      const Color(0xFF8A9298),
      strength: 0.25,
    );
  }
  a
    ..circle(a.p(0.05, 0.645), a.u * 0.5, _lamp, line: 0)
    ..circle(a.p(0.16, 0.715), a.u * 0.45, _lamp, line: 0)
    ..glow(a.p(0.05, 0.645), a.u * 3, _lamp, strength: 0.45)
    ..glow(a.p(0.16, 0.715), a.u * 2.5, _lamp, strength: 0.4)
    ..hairline(
      a.p(0.0, 0.785),
      a.p(0.22, 0.78),
      _foam.withValues(alpha: 0.4),
      0.4,
    );
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
  // The tower is round: dark down its far side, its foot in shadow.
  a.path(
    a.poly([
      a.p(0.605, 0.12),
      a.p(0.625, 0.12),
      a.p(0.645, 0.7),
      a.p(0.615, 0.7),
    ]),
    const Color(0x44000000),
    line: 0,
  );
  final ground = Room(a, vp: a.p(0.5, 0.66), depth: 0.3)
    ..contactShadow(a.r(0.52, 0.685, 0.14, 0.03));
  // Living quarters on the left, a low flat-roofed range running back.
  final quarters = ground.stand(
    a.r(0.0, 0.3, 0.3, 0.42),
    _whitewash,
    deep: 0.5,
    side: _whitewashDark,
  );
  a
    ..box(a.r(0.08, 0.36, 0.14, 0.36), const Color(0xFF2A211A), line: 0.4)
    ..box(a.r(0.02, 0.36, 0.04, 0.1), const Color(0xFF151A20), line: 0.3)
    ..hairline(
      quarters.topLeft,
      quarters.topRight,
      const Color(0xFFB8C2CA),
      0.6,
    );
  // The oil store, a small hut in front of it.
  ground.stand(
    a.r(0.29, 0.44, 0.13, 0.3),
    _whitewashDark,
    deep: 0.3,
    side: const Color(0xFF4E5862),
  );
  a.box(a.r(0.31, 0.48, 0.08, 0.26), const Color(0xFF1C1612), line: 0.3);
  // The path west, and the rail across it.
  a.path(
    a.poly([a.p(0.72, 1), a.p(0.8, 0.66), a.p(0.98, 0.62), a.p(1, 1)]),
    const Color(0xFF3A3A36),
    line: 0,
  );
  // The tramway running west along it: sleepers and two rails.
  for (var i = 0; i < 7; i++) {
    final t = i / 6;
    final y = 0.98 - t * 0.32;
    final x = 0.76 + t * 0.07;
    a.box(
      a.r(x, y, 0.13 - t * 0.06, 0.012),
      const Color(0xFF4A3E32),
      line: 0.2,
    );
  }
  for (final dx in [0.0, 0.1]) {
    a.line(
      a.p(0.77 + dx, 0.99),
      a.p(0.83 + dx * 0.45, 0.66),
      const Color(0xFF8E887E),
      width: 0.8,
    );
  }
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

/// The kitchen's camera, shared by its sprites.
const _kitchenEye = Offset(0.5, 0.36);
const _kitchenDepth = 0.64;

void _kitchen(Art a) {
  final room = _whiteRoom(a, eye: _kitchenEye, depth: _kitchenDepth);
  // A small deep window in the left wall, the last of the dusk in it.
  final pane = [
    room.at(0, 0.44, 0.16),
    room.at(0, 0.82, 0.16),
    room.at(0, 0.82, 0.4),
    room.at(0, 0.44, 0.4),
  ];
  a.path(a.poly(pane), const Color(0xFF4A5A70), line: 0.6);
  final sill = [
    room.at(0, 0.44, 0.16),
    room.at(0.035, 0.44, 0.16),
    room.at(0.035, 0.44, 0.4),
    room.at(0, 0.44, 0.4),
  ];
  a
    ..path(a.poly(sill), _whitewash, line: 0.4)
    ..line(room.at(0, 0.63, 0.16), room.at(0, 0.63, 0.4), _iron, width: 0.6)
    ..line(room.at(0, 0.44, 0.28), room.at(0, 0.82, 0.28), _iron, width: 0.6);
  // Shelf with the magazine.
  room.box(
    a.r(0.33, 0.33, 0.13, 0.014),
    const Color(0xFF4A3828),
    depth: 0.04,
    line: 0.4,
  );
  a.paper(
    a.r(0.35, 0.245, 0.09, 0.085),
    lines: 3,
    angle: -0.08,
    color: const Color(0xFFD6C89E),
  );
  // The stopped clock.
  final clock = a.p(0.5, 0.22);
  a
    ..circle(clock, a.u * 6, const Color(0xFFE2DAC4), line: 0.6)
    ..line(clock, clock + Offset(0, -a.u * 4.2), Art.outline, width: 0.5)
    ..line(
      clock,
      clock + Offset(a.u * 2.6, a.u * 0.9),
      Art.outline,
      width: 0.7,
    );
  // The slate by the door.
  room.box(
    a.r(0.58, 0.22, 0.08, 0.12),
    const Color(0xFF2A2E31),
    depth: 0.02,
    line: 0.6,
  );
  a.scrawl(
    a.r(0.588, 0.235, 0.064, 0.09),
    const Color(0xCCE0E2E0),
    lines: 4,
    seed: 4,
    width: 0.3,
  );
  // Three hooks with tags; only the third keeps its oilskin.
  for (var i = 0; i < 3; i++) {
    final x = 0.69 + i * 0.04;
    a
      ..circle(a.p(x, 0.24), a.u * 0.7, StillroomPalette.brass, line: 0.2)
      ..box(
        a.r(x - 0.01, 0.255, 0.02, 0.018),
        const Color(0xFFD9CCAE),
        line: 0.2,
      );
  }
  final coat = [
    a.p(0.77, 0.25),
    a.p(0.797, 0.31),
    a.p(0.806, 0.6),
    a.p(0.734, 0.6),
    a.p(0.743, 0.31),
  ];
  a
    ..path(
      a.poly([for (final p in coat) p.translate(a.u * 1.2, a.u * 0.8)]),
      const Color(0x44000000),
      line: 0,
    )
    ..path(a.poly(coat), _oilskin, line: 0.5)
    ..line(a.p(0.77, 0.32), a.p(0.77, 0.59), Art.outline, width: 0.3);
  _range(a, room);
  // The scrubbed table and the log book on it.
  room.table(
    0.36,
    0.7,
    0.3,
    0.56,
    0.3,
    const Color(0xFF7A6A52),
    legColor: const Color(0xFF3A2C20),
    leg: 0.02,
  );
  _logBook(a, room.at(0.5, 0.3, 0.42), 0.85);
  // A crate by the right wall, where the lantern was left.
  room
    ..shadow(0.82, 0.96, 0.18, 0.34)
    ..block(
      0.82,
      0.96,
      0,
      0.16,
      0.18,
      0.34,
      const Color(0xFF5A4630),
      top: const Color(0xFF6E5A40),
    );
  for (final y in [0.055, 0.105]) {
    a.hairline(
      room.at(0.82, y, 0.18),
      room.at(0.96, y, 0.18),
      const Color(0xFF3A2C1E),
      0.4,
    );
  }
}

/// The keeper's log, open on the table: its spine standing on [base],
/// drawn at [k] of its size.
void _logBook(Art a, Offset base, double k) {
  Offset p(double x, double y) =>
      base +
      Offset((x - 0.435) * k * a.size.width, (y - 0.58) * k * a.size.height);
  a
    ..path(
      a.poly([p(0.385, 0.58), p(0.395, 0.52), p(0.475, 0.52), p(0.485, 0.58)]),
      const Color(0xFF3E2A1C),
      line: 0.4,
    )
    ..path(
      a.poly([
        p(0.392, 0.575),
        p(0.4, 0.525),
        p(0.435, 0.528),
        p(0.435, 0.578),
      ]),
      const Color(0xFFE2D6BA),
      line: 0.25,
    )
    ..path(
      a.poly([
        p(0.435, 0.578),
        p(0.435, 0.528),
        p(0.47, 0.525),
        p(0.478, 0.575),
      ]),
      const Color(0xFFD9CCAE),
      line: 0.25,
    );
  for (var i = 0; i < 4; i++) {
    final y = 0.537 + i * 0.01;
    a
      ..hairline(p(0.402, y), p(0.43, y), const Color(0x882A241A), 0.25)
      ..hairline(p(0.44, y), p(0.468, y), const Color(0x882A241A), 0.25);
  }
  a.hairline(p(0.435, 0.528), p(0.435, 0.578), Art.outline, 0.4);
}

/// The black kitchen range against the back wall, cold: hotplate with
/// round lids and a kettle, oven and firebox doors, a brass rail along
/// the front, the stovepipe up to the ceiling.
void _range(Art a, Room room) {
  const iron = Color(0xFF1C1E20);
  const rim = Color(0xFF55595C);
  room.shadow(0.03, 0.3, 0.6, 0.9);
  final front = room.block(0.03, 0.3, 0, 0.42, 0.6, 0.9, iron, top: rim);
  room.block(0.15, 0.19, 0.42, 1, 0.84, 0.88, const Color(0xFF1B1D1F));
  // The lids on the hotplate.
  for (final x in [0.1, 0.2]) {
    final c = room.at(x, 0.42, 0.8);
    final w = room.at(x + 0.04, 0.42, 0.8).dx - room.at(x - 0.04, 0.42, 0.8).dx;
    a.oval(
      Rect.fromCenter(center: c, width: w, height: w * 0.18),
      const Color(0xFF3A3E41),
      line: 0.3,
    );
  }
  // The kettle, left to go cold.
  final k = room.at(0.23, 0.42, 0.7);
  final kw = room.at(0.28, 0.42, 0.7).dx - room.at(0.18, 0.42, 0.7).dx;
  Offset kp(double x, double y) => k + Offset(x * kw, -y * kw);
  const kettle = Color(0xFF3E4448);
  a
    ..path(
      a.poly([kp(-0.5, 0), kp(-0.4, 0.42), kp(0.4, 0.42), kp(0.5, 0)]),
      kettle,
      line: 0.4,
    )
    ..line(kp(0.5, 0.2), kp(0.75, 0.42), kettle, width: 0.6)
    ..strokePath(
      Path()..addArc(
        Rect.fromCenter(center: kp(0, 0.42), width: kw * 0.6, height: kw * 0.5),
        math.pi,
        math.pi,
      ),
      kettle,
      width: 0.5,
    );
  paintOnFace(a, front, (f) {
    // Firebox door (grate slots) and oven door (handle).
    f
      ..box(f.r(0.1, 0.16, 0.35, 0.32), const Color(0xFF101112), line: 0.4)
      ..box(f.r(0.55, 0.16, 0.35, 0.42), const Color(0xFF101112), line: 0.4)
      ..line(f.p(0.75, 0.36), f.p(0.85, 0.36), rim, width: 0.8);
    for (var i = 0; i < 4; i++) {
      f.hairline(
        f.p(0.15 + i * 0.08, 0.24),
        f.p(0.15 + i * 0.08, 0.4),
        rim,
        0.4,
      );
    }
    f
      // The ash pit and the brass rail along the front.
      ..box(f.r(0.1, 0.66, 0.8, 0.16), const Color(0xFF101112), line: 0.3)
      ..line(f.p(0, 0.08), f.p(1, 0.08), StillroomPalette.brass, width: 0.6);
  });
}

/// A box of matches, its tray pushed half out: red heads in a row, the
/// brown striking strip down the side.
void _matches(Art a) {
  a
    // The tray, slid out to the right, full of matches.
    ..box(a.r(0.42, 0.34, 0.5, 0.36), const Color(0xFFD8C8A0), line: 0.5)
    ..fill(a.r(0.45, 0.38, 0.44, 0.28), const Color(0xFFC2A878));
  for (var i = 0; i < 7; i++) {
    final y = 0.4 + i * 0.037;
    a
      ..line(a.p(0.5, y), a.p(0.86, y), const Color(0xFFE8D9B0), width: 0.9)
      ..circle(a.p(0.86, y), a.u * 1.4, const Color(0xFFB83A26), line: 0.2);
  }
  // The sleeve, with its label and striker.
  a
    ..box(a.r(0.08, 0.3, 0.46, 0.44), const Color(0xFFB53A2A), line: 0.6)
    ..box(a.r(0.14, 0.38, 0.34, 0.28), const Color(0xFFE6D7B0), line: 0.3)
    ..label('SAFETY', a.p(0.31, 0.47), a.size.height * 0.07, Art.outline)
    ..label('MATCHES', a.p(0.31, 0.57), a.size.height * 0.06, Art.outline)
    ..fill(a.r(0.08, 0.7, 0.46, 0.05), const Color(0xFF5A3A2A))
    ..ink(a.r(0.08, 0.7, 0.46, 0.05), width: 0.3);
}

/// A keeper's hand lantern: a tin cap and ring handle, glass panes behind
/// wire guards, the oil fount at the bottom, a wick that may be burning.
void _lantern(Art a, {required bool lit}) {
  const tin = Color(0xFF5E666C);
  final body = a.r(0.3, 0.3, 0.4, 0.46);
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
      Path()..addArc(a.r(0.36, 0.04, 0.28, 0.26), math.pi, math.pi),
      tin,
      width: 1.4,
    )
    ..path(
      a.poly([a.p(0.3, 0.3), a.p(0.38, 0.18), a.p(0.62, 0.18), a.p(0.7, 0.3)]),
      tin,
      line: 0.5,
    )
    ..box(a.r(0.46, 0.13, 0.08, 0.05), tin, line: 0.4)
    ..box(
      body,
      lit ? const Color(0xCCF1D68A) : const Color(0x99A8B8BC),
      line: 0.6,
    );
  if (!lit) {
    // A glint on the cold glass, and the wick waiting.
    a
      ..line(a.p(0.35, 0.34), a.p(0.35, 0.7), const Color(0x66FFFFFF), width: 1)
      ..line(a.p(0.5, 0.64), a.p(0.5, 0.7), Art.outline, width: 0.8);
  }
  for (final x in [0.4, 0.5, 0.6]) {
    a.line(a.p(x, 0.3), a.p(x, 0.76), tin, width: 0.6);
  }
  a
    ..line(a.p(0.3, 0.53), a.p(0.7, 0.53), tin, width: 0.6)
    ..box(a.r(0.24, 0.76, 0.52, 0.16), tin, line: 0.5)
    ..hairline(a.p(0.24, 0.8), a.p(0.76, 0.8), const Color(0xFF3A4046), 0.5);
  if (lit) a.flame(a.p(0.5, 0.68), a.size.height * 0.22);
}

void _oilStore(Art a) {
  final room = _whiteRoom(a, eye: const Offset(0.5, 0.36), depth: 0.6);
  a.fill(Offset.zero & a.size, const Color(0x55000000));
  // The rack of cans against the back wall: two uprights, four boards.
  const board = Color(0xFF3A2A1C);
  room.shadow(0.02, 0.42, 0.7, 0.9);
  for (final x in [0.02, 0.4]) {
    room.block(x, x + 0.02, 0, 0.56, 0.7, 0.9, board, line: 0.4);
  }
  for (final (row, h) in [0.03, 0.2, 0.37, 0.54].indexed) {
    room.block(0.04, 0.4, h - 0.02, h, 0.7, 0.9, board, line: 0.4);
    if (row == 3) continue;
    for (var i = 0; i < 5; i++) {
      final x = 0.06 + i * 0.068;
      final can = Rect.fromPoints(
        room.at(x, h + 0.13, 0.76),
        room.at(x + 0.055, h, 0.76),
      );
      paintOnFace(a, can, (f) => _can(f, label: false));
    }
  }
  // The bench where the handle lies.
  room.table(
    0.62,
    0.95,
    0.3,
    0.55,
    0.28,
    const Color(0xFF4A3828),
    legColor: const Color(0xFF2E2218),
    leg: 0.018,
  );
}

/// The paraffin can standing on the floor, its shadow under it.
void _paraffinStanding(Art a) {
  Room.spriteShadow(a, 0.1, 0.9, y: 0.95);
  _can(a, label: true);
}

void _paraffin(Art a) => _can(a, label: true);

/// A tall paraffin can: red tin with a carrying handle and a screw spout,
/// a paper label round its middle.
void _can(Art a, {required bool label}) {
  const tin = Color(0xFF8A3226);
  a
    // The carrying handle over the top.
    ..strokePath(
      Path()..addArc(a.r(0.26, 0.02, 0.36, 0.26), math.pi, math.pi),
      _iron,
      width: 1.1,
    )
    ..box(a.r(0.66, 0.06, 0.12, 0.12), const Color(0xFF6E7478), line: 0.4)
    ..rbox(a.r(0.16, 0.14, 0.68, 0.82), a.size.width * 0.06, tin, line: 0.6)
    // Seams, a highlight down one side, the shadow down the other.
    ..hairline(a.p(0.16, 0.24), a.p(0.84, 0.24), const Color(0xFF5A1E16), 0.4)
    ..hairline(a.p(0.16, 0.88), a.p(0.84, 0.88), const Color(0xFF5A1E16), 0.4)
    ..fill(a.r(0.22, 0.26, 0.08, 0.6), const Color(0x33FFFFFF))
    ..fill(a.r(0.7, 0.26, 0.12, 0.6), const Color(0x33000000));
  if (!label) {
    a.box(a.r(0.16, 0.44, 0.68, 0.2), const Color(0xFFC9BC9C), line: 0.25);
    return;
  }
  a
    ..box(a.r(0.16, 0.38, 0.68, 0.3), const Color(0xFFD9CCAE), line: 0.3)
    ..label('PARAFFIN', a.p(0.5, 0.5), a.size.height * 0.075, Art.outline)
    ..hairline(a.p(0.24, 0.6), a.p(0.76, 0.6), const Color(0x882A241A), 0.4);
}

/// The winding handle lying flat on the bench, seen from the front: the
/// socket, the long arm, the grip standing up at the end.
void _handleLying(Art a) {
  final h = a.size.height;
  final iron = Paint()
    ..color = const Color(0xFF5A6066)
    ..strokeWidth = h * 0.16
    ..strokeCap = StrokeCap.round;
  a
    ..canvas.drawLine(a.p(0.14, 0.78), a.p(0.7, 0.78), iron)
    ..canvas.drawLine(a.p(0.7, 0.78), a.p(0.7, 0.5), iron)
    ..box(a.r(0.02, 0.6, 0.14, 0.36), const Color(0xFF5A6066), line: 0.5)
    ..box(a.r(0.06, 0.7, 0.06, 0.16), Art.outline, line: 0)
    ..rbox(a.r(0.64, 0.02, 0.13, 0.52), h * 0.08, const Color(0xFF7A5234))
    ..fill(a.r(0.66, 0.08, 0.03, 0.4), const Color(0x44FFFFFF))
    ..hairline(a.p(0.14, 0.72), a.p(0.68, 0.72), const Color(0x44FFFFFF), 0.4);
}

/// The winding handle: a square socket, an iron arm bent twice, and a
/// turned wooden grip.
void _handle(Art a) {
  const iron = Color(0xFF4A5056);
  a
    ..box(a.r(0.06, 0.52, 0.14, 0.18), iron, line: 0.5)
    ..box(a.r(0.1, 0.57, 0.06, 0.08), Art.outline, line: 0)
    ..line(a.p(0.2, 0.61), a.p(0.62, 0.61), iron, width: 5)
    ..line(a.p(0.62, 0.64), a.p(0.62, 0.3), iron, width: 5)
    ..line(a.p(0.61, 0.32), a.p(0.7, 0.32), iron, width: 3.5)
    ..circle(a.p(0.62, 0.61), a.u * 1.8, iron, line: 0.4)
    ..rbox(
      a.r(0.68, 0.14, 0.2, 0.34),
      a.size.height * 0.08,
      const Color(0xFF6E4A2E),
    )
    ..hairline(a.p(0.68, 0.24), a.p(0.88, 0.24), const Color(0xFF4A3020), 0.5)
    ..hairline(a.p(0.68, 0.38), a.p(0.88, 0.38), const Color(0xFF4A3020), 0.5)
    ..fill(a.r(0.71, 0.17, 0.04, 0.28), const Color(0x33FFFFFF));
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
  // The curved inside of the tower, dark where it turns away, and the
  // stair winding up it: each step's tread seen from below or above.
  a.fade(Offset.zero & a.size, _whitewashDark, const Color(0xFF2E353C));
  for (final (x0, x1) in [(0.0, 0.3), (1.0, 0.7)]) {
    a.canvas.drawRect(
      a.r(math.min(x0, x1), 0, 0.3, 1),
      Paint()
        ..shader = Gradient.linear(a.p(x0, 0), a.p(x1, 0), [
          const Color(0x99000000),
          const Color(0x00000000),
        ]),
    );
  }
  final room = Room(a, vp: a.p(0.5, 0.45), depth: 0.5);
  for (var i = 11; i >= 0; i--) {
    final t = i / 12;
    final y = 1 - t * 0.66;
    final x0 = 0.1 + 0.3 * math.sin(t * math.pi);
    final step = a.r(x0, y - 0.05, 0.5 - 0.2 * t, 0.05);
    room
      ..contactShadow(
        Rect.fromLTRB(
          step.left,
          step.bottom - a.u,
          step.right,
          step.bottom + a.u * 2,
        ),
        strength: 0.35,
      )
      ..box(step, _stone, depth: 0.1, line: 0.4);
    a.hairline(step.topLeft, step.topRight, const Color(0xFF6E767C), 0.4);
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
    // The fourth hook, with an empty tag and a note tucked behind it.
    ..box(a.r(0.17, 0.465, 0.04, 0.02), const Color(0xFF6E5038), line: 0.3)
    ..strokePath(
      Path()
        ..moveTo(a.p(0.19, 0.48).dx, a.p(0, 0.48).dy)
        ..lineTo(a.p(0.19, 0.505).dx, a.p(0, 0.505).dy)
        ..quadraticBezierTo(
          a.p(0.19, 0.52).dx,
          a.p(0, 0.52).dy,
          a.p(0.2, 0.51).dx,
          a.p(0, 0.51).dy,
        ),
      StillroomPalette.brass,
      width: 0.7,
    )
    ..paper(a.r(0.2, 0.45, 0.02, 0.05), lines: 2, angle: 0.18)
    ..line(
      a.p(0.19, 0.505),
      a.p(0.19, 0.525),
      const Color(0xFF9A8A6A),
      width: 0.2,
    )
    ..box(a.r(0.176, 0.525, 0.028, 0.02), const Color(0xFFD9CCAE), line: 0.25);
}

void _lampRoom(Art a) {
  // The round lantern room seen from inside: glazing all round above an
  // iron parapet, the floor's far edge curving away to either side.
  const rx = 0.9;
  double arc(double x) {
    final t = ((x - 0.5) / rx).clamp(-1.0, 1.0);
    return math.sqrt(1 - t * t);
  }

  double floorEdge(double x) => 1.06 - 0.28 * arc(x);
  double parapetTop(double x) => 0.88 - 0.22 * arc(x);
  final xs = [for (var i = 0; i <= 40; i++) i / 40];

  // Dusk and sea through the diamond panes.
  _sky(a, horizon: 0.55);
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
  // The mullions, crowding together where the glass turns away.
  for (var k = -4; k <= 4; k++) {
    final x = 0.5 + rx * math.sin(k * math.pi / 24);
    a.line(a.p(x, 0), a.p(x, parapetTop(x)), _iron, width: 1.2 - k.abs() * 0.1);
  }
  a
    // The parapet under the glass, and the floor inside it.
    ..path(
      a.poly([
        for (final x in xs) a.p(x, parapetTop(x)),
        for (final x in xs.reversed) a.p(x, floorEdge(x)),
      ]),
      const Color(0xFF2E3438),
      line: 0,
    )
    ..strokePath(
      a.poly([for (final x in xs) a.p(x, parapetTop(x))])..close(),
      const Color(0xFF55595C),
      width: 0.6,
    )
    ..path(
      a.poly([for (final x in xs) a.p(x, floorEdge(x)), a.p(1, 1), a.p(0, 1)]),
      const Color(0xFF3A3F43),
      line: 0,
    );
  // Plates of the floor, ringing the pedestal.
  for (final (cy, ry) in [(1.18, 0.3), (1.32, 0.36)]) {
    a.strokePath(
      Path()..addOval(
        Rect.fromCenter(
          center: a.p(0.5, cy),
          width: a.size.width * rx * 2 * (ry / 0.28),
          height: a.size.height * ry * 2,
        ),
      ),
      const Color(0x55181C20),
      width: 0.5,
    );
  }
  a.strokePath(
    a.poly([for (final x in xs) a.p(x, floorEdge(x))]),
    Art.outline,
    width: 0.8,
  );
  final room = Room(a, vp: a.p(0.5, 0.42), depth: 0.6);
  // The clockwork cabinet, run down.
  final cabinet = a.r(0.04, 0.52, 0.22, 0.32);
  room.stand(cabinet, const Color(0xFF3A2C22), deep: 0.1);
  paintOnFace(a, cabinet, (f) => _clockwork(f, wound: false));
  // The pedestal under the lens.
  room.stand(a.r(0.42, 0.64, 0.16, 0.16), _iron, deep: 0.14);
  // A little iron table, the legend's pages on it.
  room.standTable(
    a.r(0.74, 0.645, 0.15, 0.22),
    const Color(0xFF3A4046),
    deep: 0.12,
    legColor: _iron,
  );
  a
    ..paper(a.r(0.77, 0.56, 0.05, 0.085), lines: 5, angle: 0.06)
    ..paper(a.r(0.81, 0.565, 0.05, 0.08), lines: 5, angle: -0.05);
  // The little iron door out onto the gallery, set in the parapet.
  a
    ..box(a.r(0.895, 0.28, 0.1, 0.54), const Color(0xFF2A3036), line: 0.5)
    ..box(a.r(0.905, 0.3, 0.08, 0.52), _iron, line: 0.4)
    ..box(a.r(0.92, 0.34, 0.05, 0.1), const Color(0xFF3A4658), line: 0.3)
    ..hairline(a.p(0.945, 0.34), a.p(0.945, 0.44), _iron, 0.4)
    ..circle(a.p(0.915, 0.58), a.u * 0.8, StillroomPalette.brass, line: 0.2);
  for (final y in [0.36, 0.74]) {
    a.box(a.r(0.905, y, 0.025, 0.02), const Color(0xFF3E4448), line: 0.2);
  }
}

/// The great lens: a drum of glass in a brass frame, the bull's-eye panel
/// in the middle and rings of prisms stacked above and below it.
void _lens(Art a, {required bool lit}) {
  const brass = StillroomPalette.brass;
  final glass = lit ? const Color(0xE6F6DFA0) : const Color(0xB0708290);
  final prism = lit ? const Color(0xFFD9B060) : const Color(0xFF55636E);
  final edge = lit ? const Color(0xFFFFF4D0) : const Color(0xFF9AAAB4);
  if (lit) a.glow(a.p(0.5, 0.5), a.size.width * 1.2, _lamp, strength: 0.6);
  // Top cap and base ring.
  a
    ..path(
      a.poly([a.p(0.2, 0.1), a.p(0.35, 0.02), a.p(0.65, 0.02), a.p(0.8, 0.1)]),
      brass,
      line: 0.5,
    )
    ..box(a.r(0.14, 0.9, 0.72, 0.07), brass, line: 0.5);
  // The glass drum, bulging a little at its waist.
  final drum = Path()
    ..moveTo(a.p(0.2, 0.1).dx, a.p(0, 0.1).dy)
    ..quadraticBezierTo(
      a.p(0.08, 0.5).dx,
      a.p(0, 0.5).dy,
      a.p(0.16, 0.9).dx,
      a.p(0, 0.9).dy,
    )
    ..lineTo(a.p(0.84, 0.9).dx, a.p(0, 0.9).dy)
    ..quadraticBezierTo(
      a.p(0.92, 0.5).dx,
      a.p(0, 0.5).dy,
      a.p(0.8, 0.1).dx,
      a.p(0, 0.1).dy,
    )
    ..close();
  a.path(drum, glass, line: 0.6);
  a.canvas
    ..save()
    ..clipPath(drum);
  // Rings of prisms above and below the waist.
  for (var i = 0; i < 12; i++) {
    final y = i < 6 ? 0.12 + i * 0.045 : 0.62 + (i - 6) * 0.045;
    a
      ..fill(a.r(0, y, 1, 0.022), prism.withValues(alpha: 0.7))
      ..hairline(a.p(0, y), a.p(1, y), edge.withValues(alpha: 0.8), 0.3);
  }
  // The bull's-eye panel at the waist: concentric rings round a centre.
  final eye = a.p(0.5, 0.5);
  for (var i = 5; i >= 1; i--) {
    a.canvas.drawOval(
      Rect.fromCenter(
        center: eye,
        width: a.size.width * 0.09 * i,
        height: a.size.height * 0.036 * i,
      ),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = a.u * 0.45
        ..color = i.isEven ? edge : prism,
    );
  }
  // The brass uprights that hold the panels.
  for (final x in [0.3, 0.5, 0.7]) {
    a.line(a.p(x, 0.1), a.p(x, 0.9), brass.withValues(alpha: 0.85), width: 0.6);
  }
  // Glint down one side.
  a.fade(
    a.r(0.2, 0.1, 0.08, 0.8),
    const Color(0x55FFFFFF),
    const Color(0x11FFFFFF),
  );
  a.canvas.restore();
  if (lit) a.flame(a.p(0.5, 0.56), a.size.height * 0.12);
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
  _tornTurf(a);
  _landingSteps(a);
  _twistedRailings(a);
  // The brackets where the rope box stood, and its plate.
  a
    ..box(a.r(0.47, 0.34, 0.16, 0.02), _iron, line: 0.3)
    ..box(a.r(0.5, 0.2, 0.1, 0.12), const Color(0xFF8C8E86), line: 0.4);
  _crane(a);
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

/// Steps cut down the rock to the landing, the surf at their foot.
void _landingSteps(Art a) {
  const stone = Color(0xFF4F5456);
  const top = Color(0xFF6E7478);
  final camera = Room(a, vp: a.p(0.5, 0.5), depth: 0.3);
  for (var i = 0; i < 7; i++) {
    final x = 0.46 + i * 0.038;
    final y = 0.52 + i * 0.055;
    camera.box(a.r(x, y, 0.09, 0.055), stone, depth: 0.06, line: 0.35);
    a.fill(a.r(x, y, 0.09, 0.008), top);
  }
  a.glow(a.p(0.72, 0.92), a.size.width * 0.08, _foam, strength: 0.35);
}

/// The cliff top, sixty metres up, with the turf ripped off in sods: brown
/// earth showing, loose sods flung and upturned.
void _tornTurf(Art a) {
  const earth = Color(0xFF4A3526);
  const grass = Color(0xFF3E5236);
  final random = math.Random(6);
  // The bare, torn ground where the sods came away.
  final torn = <Offset>[a.p(0.68, 0.12)];
  for (var i = 0; i <= 12; i++) {
    torn.add(a.p(0.68 + i * 0.025, 0.07 + random.nextDouble() * 0.03));
  }
  torn.add(a.p(0.98, 0.12));
  a.path(a.poly(torn), earth, line: 0.3);
  for (var i = 0; i < 10; i++) {
    final x = 0.69 + random.nextDouble() * 0.28;
    a.hairline(
      a.p(x, 0.095),
      a.p(x + 0.01, 0.115),
      const Color(0xFF2E2016),
      0.3,
    );
  }
  for (var i = 0; i < 5; i++) {
    final x = 0.68 + random.nextDouble() * 0.28;
    final y = 0.02 + random.nextDouble() * 0.05;
    final flipped = i.isEven;
    a
      ..box(a.r(x, y, 0.035, 0.018), flipped ? earth : grass, line: 0.3)
      ..fill(
        a.r(x, flipped ? y + 0.013 : y, 0.035, 0.005),
        flipped ? grass : earth,
      );
  }
  _grassTufts(a, a.r(0.66, 0.12, 0.34, 0.02));
}

void _grassTufts(Art a, Rect rect) {
  final random = math.Random(2);
  for (var i = 0; i < 16; i++) {
    final x = rect.left + random.nextDouble() * rect.width;
    a.line(
      Offset(x, rect.bottom),
      Offset(x + (random.nextDouble() - 0.5) * rect.height, rect.top),
      const Color(0xFF55704A),
      width: 0.4,
    );
  }
}

/// Iron railings along the landing, bent and wrenched by the sea: posts
/// leaning, the rails between them looped like wire, one torn loose; the
/// tramway's rails ripped out of their concrete bed below.
void _twistedRailings(Art a) {
  const iron = Color(0xFF7A746C);
  // The concrete bed and the torn tramway rails.
  a.path(
    a.poly([a.p(0.04, 0.76), a.p(0.4, 0.74), a.p(0.42, 0.78), a.p(0.02, 0.8)]),
    const Color(0xFF55585A),
    line: 0.4,
  );
  for (final dy in [0.0, 0.02]) {
    a.strokePath(
      Path()
        ..moveTo(a.p(0.05, 0.765 + dy).dx, a.p(0, 0.765 + dy).dy)
        ..lineTo(a.p(0.2, 0.755 + dy).dx, a.p(0, 0.755 + dy).dy)
        ..quadraticBezierTo(
          a.p(0.28, 0.75).dx,
          a.p(0, 0.75).dy,
          a.p(0.3, 0.66 + dy).dx,
          a.p(0, 0.66 + dy).dy,
        ),
      const Color(0xFF8E887E),
      width: 0.9,
    );
  }
  // Posts, leaning every way.
  final posts = [
    (0.07, 0.0),
    (0.14, -0.02),
    (0.21, 0.05),
    (0.29, 0.1),
    (0.36, -0.06),
  ];
  final tops = <Offset>[];
  for (final (x, lean) in posts) {
    final foot = a.p(x, 0.75);
    final top = a.p(x + lean, 0.52);
    tops.add(top);
    a
      ..line(foot, top, iron, width: 1.1)
      ..circle(top, a.u * 0.7, iron, line: 0.2);
  }
  // Rails between them, pulled into loops and kinks.
  for (var i = 0; i < tops.length - 1; i++) {
    for (final level in [0.0, 0.35]) {
      final from = Offset.lerp(tops[i], a.p(posts[i].$1, 0.75), level)!;
      final to = Offset.lerp(tops[i + 1], a.p(posts[i + 1].$1, 0.75), level)!;
      if (i == 2 && level > 0) continue; // torn loose
      final mid =
          Offset.lerp(from, to, 0.5)! +
          Offset(0, a.size.height * (i.isEven ? 0.05 : -0.04));
      a.strokePath(
        Path()
          ..moveTo(from.dx, from.dy)
          ..quadraticBezierTo(mid.dx, mid.dy, to.dx, to.dy),
        iron,
        width: 0.8,
      );
    }
  }
  // The torn rail, hanging.
  a.strokePath(
    Path()
      ..moveTo(a.p(0.21, 0.6).dx, a.p(0, 0.6).dy)
      ..quadraticBezierTo(
        a.p(0.22, 0.7).dx,
        a.p(0, 0.7).dy,
        a.p(0.26, 0.72).dx,
        a.p(0, 0.72).dy,
      ),
    iron,
    width: 0.8,
  );
}

/// The landing crane: an iron post on a base plate, its jib braced out
/// over the water, a pulley at the end and the hook on its chain.
void _crane(Art a) {
  const iron = Color(0xFF55595C);
  Room(a, vp: a.p(0.5, 0.5), depth: 0.3)
    ..contactShadow(a.r(0.82, 0.655, 0.09, 0.025))
    ..box(a.r(0.83, 0.64, 0.07, 0.025), const Color(0xFF3E4245), depth: 0.08);
  a
    ..line(a.p(0.865, 0.645), a.p(0.865, 0.27), iron, width: 2.2)
    ..line(a.p(0.865, 0.29), a.p(0.81, 0.3), iron, width: 1.6)
    ..line(a.p(0.865, 0.42), a.p(0.815, 0.305), iron, width: 1)
    ..circle(a.p(0.81, 0.305), a.u * 1.1, const Color(0xFF7A7E80), line: 0.3);
  for (var y = 0.32; y < 0.48; y += 0.02) {
    a.canvas.drawOval(
      Rect.fromCenter(
        center: a.p(0.81, y),
        width: a.u * 0.8,
        height: a.size.height * 0.018,
      ),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = a.u * 0.3
        ..color = const Color(0xFF9AA0A2),
    );
  }
  a.strokePath(
    Path()
      ..moveTo(a.p(0.81, 0.48).dx, a.p(0, 0.48).dy)
      ..lineTo(a.p(0.81, 0.5).dx, a.p(0, 0.5).dy)
      ..quadraticBezierTo(
        a.p(0.81, 0.52).dx,
        a.p(0, 0.52).dy,
        a.p(0.822, 0.51).dx,
        a.p(0, 0.51).dy,
      ),
    const Color(0xFF9AA0A2),
    width: 0.8,
  );
}

/// The rail torn from the tramway, flung across the path west and bent at
/// one end (the yard's `rail_sprite`, [0.76, 0.6, 0.24, 0.24]).
void _railAcross(Art a) {
  final path = Path()
    ..moveTo(a.p(0.08, 0.83).dx, a.p(0, 0.83).dy)
    ..lineTo(a.p(0.79, 0.5).dx, a.p(0, 0.5).dy)
    ..quadraticBezierTo(
      a.p(0.92, 0.42).dx,
      a.p(0, 0.42).dy,
      a.p(0.96, 0.17).dx,
      a.p(0, 0.17).dy,
    );
  a.canvas
    ..drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = a.size.height * 0.09
        ..strokeCap = StrokeCap.round
        ..color = Art.outline,
    )
    ..drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = a.size.height * 0.06
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFA8A298),
    );
}

/// The same rail, dragged off the path onto the grass.
void _railAside(Art a) {
  a.canvas
    ..drawLine(
      a.p(0.05, 0.62),
      a.p(0.95, 0.42),
      Paint()
        ..strokeWidth = a.size.height * 0.24
        ..strokeCap = StrokeCap.round
        ..color = Art.outline,
    )
    ..drawLine(
      a.p(0.05, 0.62),
      a.p(0.95, 0.42),
      Paint()
        ..strokeWidth = a.size.height * 0.16
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFF8E887E),
    );
}

/// The island at night seen from the gallery, looking west: the lamp
/// behind you at the bottom, the path running away over the grass to the
/// west landing, the cliff top on the left, the sea all round. The beam
/// puzzle darkens it and lets the beam show it piece by piece.
void _beamBoard(Art a) {
  _sky(a, horizon: 0.16);
  // The island's back, a long rise of grass falling to cliffs.
  a.path(
    a.poly([
      a.p(0, 0.3),
      a.p(0.1, 0.26),
      a.p(0.3, 0.3),
      a.p(0.55, 0.26),
      a.p(0.78, 0.3),
      a.p(0.92, 0.24),
      a.p(1, 0.3),
      a.p(1, 1),
      a.p(0, 1),
    ]),
    _grass,
    line: 0.5,
  );
  _grassTufts(a, a.r(0, 0.5, 1, 0.03));
  // The path west, from the foot of the tower to the landing.
  a.path(
    a.poly([
      a.p(0.46, 0.86),
      a.p(0.56, 0.86),
      a.p(0.7, 0.56),
      a.p(0.84, 0.38),
      a.p(0.82, 0.37),
      a.p(0.64, 0.54),
    ]),
    const Color(0xFF3A3A36),
    line: 0,
  );
  for (var i = 0; i < 9; i++) {
    final t = i / 8;
    a.hairline(
      a.p(0.5 + t * 0.3, 0.84 - t * 0.44),
      a.p(0.54 + t * 0.29, 0.84 - t * 0.44),
      const Color(0xFF4A3E32),
      0.6,
    );
  }
  // The rail across it.
  a.canvas.drawLine(
    a.p(0.6, 0.57),
    a.p(0.71, 0.51),
    Paint()
      ..strokeWidth = a.u * 1.4
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFA8A298),
  );
  // The torn turf at the cliff top, bare earth showing.
  for (final (x, y) in [(0.15, 0.28), (0.19, 0.3), (0.23, 0.28)]) {
    a.oval(a.r(x, y, 0.035, 0.018), const Color(0xFF4A3526), line: 0.3);
  }
  // The crane at the landing, over the drop.
  a
    ..line(a.p(0.83, 0.37), a.p(0.83, 0.25), const Color(0xFF7A7E80), width: 1)
    ..line(
      a.p(0.83, 0.26),
      a.p(0.805, 0.27),
      const Color(0xFF7A7E80),
      width: 0.8,
    )
    ..line(
      a.p(0.805, 0.27),
      a.p(0.805, 0.31),
      const Color(0xFF9AA0A2),
      width: 0.3,
    );
  // The quarters' roof below, and the gallery rail in front.
  a
    ..box(a.r(0.1, 0.7, 0.24, 0.12), const Color(0xFF55606A), line: 0.4)
    ..box(a.r(0.28, 0.76, 0.08, 0.08), const Color(0xFF4A535C), line: 0.4)
    ..fill(a.r(0, 0.9, 1, 0.1), _iron)
    ..line(a.p(0, 0.91), a.p(1, 0.91), const Color(0xFF3E4448), width: 1.2);
  for (var i = 0; i < 12; i++) {
    a.line(
      a.p(i / 11, 0.91),
      a.p(i / 11, 1),
      const Color(0xFF3E4448),
      width: 0.6,
    );
  }
}

/// The west landing seen from the top of its steps: sky, the cliff, the
/// crane on its ledge. The swell puzzle draws the steps and the sea over
/// it.
void _swellBoard(Art a) {
  _sky(a, horizon: 0.62);
  a.path(
    a.poly([
      a.p(0, 0.22),
      a.p(0.3, 0.2),
      a.p(0.62, 0.34),
      a.p(0.95, 0.5),
      a.p(1, 0.5),
      a.p(1, 1),
      a.p(0, 1),
    ]),
    _rock,
    line: 0.5,
  );
  // The crevice where the rope box was kept, high on the rock.
  a
    ..box(a.r(0.36, 0.26, 0.06, 0.05), const Color(0xFF15191C), line: 0.3)
    ..box(a.r(0.37, 0.215, 0.04, 0.035), const Color(0xFF8C8E86), line: 0.3);
  // The crane on its ledge above the water.
  a
    ..box(a.r(0.84, 0.74, 0.14, 0.03), _stone, line: 0.4)
    ..line(a.p(0.93, 0.74), a.p(0.93, 0.4), const Color(0xFF55595C), width: 2)
    ..line(
      a.p(0.93, 0.42),
      a.p(0.86, 0.44),
      const Color(0xFF55595C),
      width: 1.4,
    )
    ..line(
      a.p(0.86, 0.44),
      a.p(0.86, 0.56),
      const Color(0xFF9AA0A2),
      width: 0.4,
    );
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
void _clockworkWound(Art a) => _clockwork(a, wound: true);

/// The clockwork that turns the lens: a wooden cabinet with a glass front,
/// brass gears inside, a square arbor for the winding handle, and the
/// weights on their chains, low when run down, high when wound.
void _clockwork(Art a, {required bool wound}) {
  const brass = StillroomPalette.brass;
  a
    ..box(Offset.zero & a.size, const Color(0xFF3A2C22), line: 0.6)
    ..box(a.r(0.08, 0.06, 0.84, 0.52), const Color(0xFF1A1512), line: 0.4);
  if (wound) a.glow(a.p(0.5, 0.32), a.size.width * 0.5, _lamp, strength: 0.3);
  // Gears behind the glass.
  for (final (x, y, r, teeth) in [
    (0.36, 0.3, 0.17, 14),
    (0.66, 0.24, 0.11, 10),
    (0.7, 0.46, 0.08, 8),
  ]) {
    _gear(a, a.p(x, y), a.size.width * r, teeth, brass);
  }
  // The winding arbor, square, where the handle goes.
  a
    ..circle(a.p(0.36, 0.3), a.u * 2.4, const Color(0xFF6E5A30), line: 0.3)
    ..box(
      Rect.fromCenter(
        center: a.p(0.36, 0.3),
        width: a.u * 2.2,
        height: a.u * 2.2,
      ),
      Art.outline,
      line: 0,
    )
    // A glint on the glass.
    ..line(
      a.p(0.14, 0.1),
      a.p(0.28, 0.54),
      const Color(0x33FFFFFF),
      width: 1.2,
    );
  // The weights on their chains below.
  for (final x in [0.25, 0.75]) {
    final top = wound ? 0.62 : 0.62;
    final weight = wound ? 0.66 : 0.84;
    for (var y = top; y < weight; y += 0.03) {
      a.canvas.drawOval(
        Rect.fromCenter(
          center: a.p(x, y + 0.015),
          width: a.u * 1.2,
          height: a.size.height * 0.026,
        ),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = a.u * 0.4
          ..color = const Color(0xFF9AA0A2),
      );
    }
    a.box(a.r(x - 0.06, weight, 0.12, 0.12), _iron, line: 0.3);
  }
}

/// A brass gear wheel with [teeth] teeth and a few spokes.
void _gear(Art a, Offset c, double r, int teeth, Color color) {
  final path = Path();
  for (var k = 0; k < teeth * 2; k++) {
    final angle = k * math.pi / teeth;
    final radius = k.isEven ? r : r * 0.84;
    final p = c + Offset(math.cos(angle), math.sin(angle)) * radius;
    k == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
  }
  path.close();
  a.path(path, color, line: 0.35);
  final dark = Color.lerp(color, Art.outline, 0.45)!;
  a.canvas.drawCircle(
    c,
    r * 0.62,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = a.u * 0.4
      ..color = dark,
  );
  for (var k = 0; k < 4; k++) {
    final angle = k * math.pi / 2 + 0.4;
    a.hairline(
      c,
      c + Offset(math.cos(angle), math.sin(angle)) * r * 0.62,
      dark,
      0.5,
    );
  }
}
