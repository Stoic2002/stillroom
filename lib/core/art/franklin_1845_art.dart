import 'dart:math' as math;
import 'dart:ui';

import '../theme/stillroom_palette.dart';
import 'art_kit.dart';
import 'depth_kit.dart';
import 'echo_art.dart';
import 'whitechapel_1888_art.dart' show jarLabelBoard;

/// Code-drawn art for "The Franklin expedition, 1845"
/// (docs/episodes/franklin_1845.md): September 2014 off the Adelaide
/// Peninsula. The survey ship's deck among the floes, its survey room,
/// the small island where the iron pintle lay, and the community hall in
/// Gjoa Haven. Each scene from one camera (`depth_kit.dart`). No man of
/// 1845 is drawn but as an echo; no Inuk is drawn.
const _s = 'images/scenes/franklin_1845';
const _o = 'images/objects/franklin_1845';

final Map<String, ArtPainter> franklin1845Art = {
  // Scenes and puzzle boards.
  '$_s/deck.png': (c, s) => _deck(Art(c, s)),
  '$_s/survey.png': (c, s) => _survey(Art(c, s)),
  '$_s/island.png': (c, s) => _island(Art(c, s)),
  '$_s/hall.png': (c, s) => _hall(Art(c, s)),
  '$_s/margins_board.png': (c, s) => _deskBoard(Art(c, s)),
  '$_s/sonar_board.png': (c, s) => _consoleBoard(Art(c, s)),
  '$_s/label_close.png': (c, s) => jarLabelBoard(Art(c, s), _steel),
  // Objects.
  '$_o/later_sprite.png': (c, s) => _papers(Art(c, s)),
  '$_o/form_sprite.png': (c, s) => _form(Art(c, s)),
  '$_o/echo_hauler.png': (c, s) => paintEcho(Art(c, s), EchoFigure.hauler),
  '$_o/echo_surveyor.png': (c, s) => paintEcho(Art(c, s), EchoFigure.surveyor),
  // The jar on the shelf.
  'images/ui/jar_franklin_1845.png': (c, s) => _jar(Art(c, s)),
};

// ---------------------------------------------------------------------------
// Palette

const _skyHigh = Color(0xFF8A9AAA);
const _skyLow = Color(0xFFDCE2E4);
const _sea = Color(0xFF3E5664);
const _seaFar = Color(0xFF7A8E98);
const _ice = Color(0xFFE8EEF0);
const _iceShade = Color(0xFFB8C6CE);
const _steel = Color(0xFF5A6A70);
const _deckPaint = Color(0xFF6A7A6A);
const _white = Color(0xFFE6E8E4);
const _red = Color(0xFFB0302A);
const _rock = Color(0xFF6E6C68);
const _rockDark = Color(0xFF4A4846);
const _shore = Color(0xFF7A6E5E);
const _wood = Color(0xFF8A6A48);
const _paper = Color(0xFFE6DCC0);
const _lamp = StillroomPalette.gaslight;

// ---------------------------------------------------------------------------
// Shared pieces

/// An overcast Arctic sky, pale at the horizon.
void _sky(Art a, double horizon) {
  a.fade(a.r(0, 0, 1, horizon), _skyHigh, _skyLow);
  final random = math.Random(1845);
  for (var i = 0; i < 6; i++) {
    a.canvas.drawOval(
      Rect.fromCenter(
        center: a.p(random.nextDouble(), 0.05 + random.nextDouble() * 0.2),
        width: a.u * 34,
        height: a.u * 4,
      ),
      Paint()
        ..color = const Color(0x40FFFFFF)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, a.u * 2),
    );
  }
}

/// The sea from [top] down, with broken floes lying on it at depth.
void _seaWithFloes(Room room, double top, double bottom, {int seed = 3}) {
  final a = room.a;
  a.fade(Rect.fromLTRB(0, top, a.size.width, bottom), _seaFar, _sea);
  final random = math.Random(seed);
  for (var i = 0; i < 26; i++) {
    final x = -2 + random.nextDouble() * 5;
    final z = 1.2 + random.nextDouble() * 6;
    final w = 0.15 + random.nextDouble() * 0.4;
    final d = 0.08 + random.nextDouble() * 0.2;
    final floe = a.poly([
      room.at(x, 0, z),
      room.at(x + w, 0, z + d * 0.2),
      room.at(x + w * 0.9, 0, z + d),
      room.at(x + w * 0.1, 0, z + d * 0.8),
    ]);
    if (floe.getBounds().top < top) continue;
    a
      ..path(floe, _ice, line: 0.2)
      ..line(
        room.at(x, 0, z),
        room.at(x + w, 0, z + d * 0.2),
        _iceShade,
        width: 0.5,
      );
  }
}

/// A sheet lying flat, ruled with writing.
void _flatSheet(
  Room room,
  double x0,
  double x1,
  double z0,
  double z1,
  double y, {
  Color color = _paper,
}) {
  final a = room.a;
  a.path(
    a.poly([
      room.at(x0, y, z0),
      room.at(x1, y, z0),
      room.at(x1, y, z1),
      room.at(x0, y, z1),
    ]),
    color,
    line: 0.3,
  );
  for (var k = 0; k < 4; k++) {
    final z = z0 + (z1 - z0) * (0.25 + k * 0.18);
    a.hairline(
      room.at(x0 + (x1 - x0) * 0.12, y, z),
      room.at(x1 - (x1 - x0) * 0.2, y, z),
      StillroomPalette.inkOnPaper.withValues(alpha: 0.4),
      0.3,
    );
  }
}

// ---------------------------------------------------------------------------
// Scenes

/// The deck of the survey ship: its superstructure on the left with the
/// bridge door and the ice chart, the deck running aft to the helicopter,
/// the launch on its davits on the right, the rail, and beyond it the
/// floes and the low shore of the peninsula.
void _deck(Art a) {
  final room = Room(a, vp: a.p(0.52, 0.38), depth: 0.4);
  final back = room.back;
  _sky(a, 0.4);
  // The low brown shore at the horizon on the right, the sea and ice.
  a.path(
    a.poly([
      a.p(0.55, 0.385),
      a.p(0.75, 0.37),
      a.p(1, 0.375),
      a.p(1, 0.4),
      a.p(0.55, 0.4),
    ]),
    const Color(0xFF7A6A5A),
    line: 0,
  );
  _seaWithFloes(room, a.size.height * 0.4, a.size.height, seed: 5);
  // The deck: grey-green steel, non-slip, the hatch lines.
  a.path(room.floor, _deckPaint, line: 0);
  room.floorGrid(const Color(0x33000000), rows: 6, columns: 6);
  // The superstructure along the left, white, the bridge door in it.
  a.path(room.leftWall, _white, line: 0);
  for (var k = 1; k < 6; k++) {
    a.hairline(
      room.at(0, k * 0.2, 0),
      room.at(0, k * 0.2, 1),
      const Color(0x22000000),
      0.3,
    );
  }
  final door = a.poly([
    room.at(0, 0, 0.42),
    room.at(0, 0.72, 0.42),
    room.at(0, 0.72, 0.6),
    room.at(0, 0, 0.6),
  ]);
  a.path(door, const Color(0xFFB8BEBA), line: 0.5);
  a.circle(room.at(0, 0.36, 0.57), a.u * 0.6, const Color(0xFF3A3A38), line: 0);
  // The ice chart pinned beside the door.
  a.path(
    a.poly([
      room.at(0, 0.62, 0.22),
      room.at(0, 0.62, 0.36),
      room.at(0, 0.36, 0.36),
      room.at(0, 0.36, 0.22),
    ]),
    const Color(0xFFF2F2EE),
    line: 0.4,
  );
  for (var k = 0; k < 4; k++) {
    final z = 0.24 + k * 0.03;
    a.path(
      a.poly([
        room.at(0, 0.58 - k * 0.04, z),
        room.at(0, 0.58 - k * 0.04, z + 0.03),
        room.at(0, 0.44, z + 0.03),
        room.at(0, 0.44, z),
      ]),
      [
        const Color(0xFFD04030),
        const Color(0xFFE8A040),
        const Color(0xFF6AA0D0),
        const Color(0xFFE8E0A0),
      ][k],
      line: 0,
    );
  }
  // The rail along the right side and across aft.
  for (var z = 0.0; z <= 1.0; z += 0.1) {
    a.line(room.at(1, 0, z), room.at(1, 0.22, z), _white, width: 0.6);
  }
  a
    ..line(room.at(1, 0.22, 0), room.at(1, 0.22, 1), _white, width: 1)
    ..line(room.at(1, 0.11, 0), room.at(1, 0.11, 1), _white, width: 0.6)
    ..line(
      back.bottomLeft.translate(0, -back.height * 0.22),
      back.bottomRight.translate(0, -back.height * 0.22),
      _white,
      width: 0.6,
    );
  // The helicopter on its deck aft.
  _helicopter(room, 0.45, 0.88, 0.22);
  // The launch on its davits on the right, ready to swing out.
  for (final z in [0.42, 0.72]) {
    final foot = room.at(0.94, 0, z);
    final top = room.at(0.94, 0.62, z);
    final tip = room.at(0.82, 0.6, z);
    a
      ..line(foot, top, _steel, width: 1.2)
      ..line(top, tip, _steel, width: 1)
      ..line(tip, room.at(0.82, 0.38, z), const Color(0xFF2A2A2A), width: 0.3);
  }
  room
    ..shadow(0.68, 0.94, 0.42, 0.74, strength: 0.25, spread: 0.02)
    ..block(0.7, 0.92, 0.2, 0.38, 0.4, 0.76, const Color(0xFFE07A30));
  a.path(
    a.poly([
      room.at(0.7, 0.38, 0.4),
      room.at(0.92, 0.38, 0.4),
      room.at(0.92, 0.38, 0.76),
      room.at(0.7, 0.38, 0.76),
    ]),
    _white,
    line: 0.3,
  );
  // Where the deck meets the superstructure.
  a.line(
    room.at(0, 0, 0),
    room.at(0, 0, 1),
    const Color(0x66303030),
    width: 0.5,
  );
}

/// A helicopter standing at [x], [z], [w] long: a rounded cabin, a tail
/// boom, skids, the rotor blades drooping.
void _helicopter(Room room, double x, double z, double w) {
  final a = room.a;
  room.shadow(
    x - w * 0.5,
    x + w * 0.5,
    z - w * 0.15,
    z + w * 0.2,
    strength: 0.4,
    spread: 0.1,
  );
  final skidL = room.at(x - w * 0.4, 0.01, z);
  final skidR = room.at(x + w * 0.2, 0.01, z);
  a.line(skidL, skidR, const Color(0xFF2A2A2A), width: 0.8);
  final cabin = Rect.fromPoints(
    room.at(x - w * 0.4, 0.3, z),
    room.at(x + w * 0.2, 0.04, z),
  );
  a
    ..rbox(cabin, cabin.height * 0.45, _red, line: 0.5)
    ..fill(
      Rect.fromLTWH(
        cabin.left + cabin.width * 0.05,
        cabin.top + cabin.height * 0.15,
        cabin.width * 0.35,
        cabin.height * 0.4,
      ),
      const Color(0xFF3A4A54),
    )
    ..path(
      a.poly([
        Offset(
          cabin.right - cabin.width * 0.05,
          cabin.top + cabin.height * 0.3,
        ),
        room.at(x + w * 0.62, 0.22, z),
        room.at(x + w * 0.62, 0.17, z),
        Offset(
          cabin.right - cabin.width * 0.05,
          cabin.bottom - cabin.height * 0.35,
        ),
      ]),
      _white,
      line: 0.4,
    )
    ..line(
      Offset(cabin.center.dx, cabin.top),
      Offset(cabin.center.dx, cabin.top - cabin.height * 0.15),
      const Color(0xFF2A2A2A),
      width: 0.6,
    )
    ..line(
      Offset(
        cabin.center.dx - cabin.width * 1.0,
        cabin.top - cabin.height * 0.1,
      ),
      Offset(
        cabin.center.dx + cabin.width * 1.0,
        cabin.top - cabin.height * 0.2,
      ),
      const Color(0xFF2A2A2A),
      width: 0.6,
    );
}

/// The survey room: the consoles under the sonar screens along the back
/// wall, a porthole in the right wall, the chart table with Hall's chart
/// and the note in its sleeve.
void _survey(Art a) {
  final room = Room(a, vp: a.p(0.5, 0.24), depth: 0.55);
  final back = room.back;
  a
    ..path(room.ceiling, const Color(0xFFBCC0BC), line: 0)
    ..path(room.leftWall, const Color(0xFFC8CCC8), line: 0)
    ..path(room.rightWall, const Color(0xFFCCD0CC), line: 0)
    ..fill(back, const Color(0xFFD4D8D4))
    ..path(room.floor, const Color(0xFF4A5A60), line: 0);
  room
    ..floorGrid(const Color(0x33101820), rows: 6, columns: 8)
    ..shadeCorners(strength: 0.3)
    ..edges(const Color(0x66303030), width: 0.4);
  a
    ..path(
      a.poly([
        room.at(0.38, 0.99, 0.3),
        room.at(0.62, 0.99, 0.3),
        room.at(0.62, 0.99, 0.42),
        room.at(0.38, 0.99, 0.42),
      ]),
      const Color(0xFFF4F4EC),
      line: 0.3,
    )
    ..glow(
      room.at(0.5, 0.99, 0.36),
      a.size.width * 0.4,
      const Color(0xFFF0F4F4),
      strength: 0.2,
    );
  // A porthole in the right wall: the grey sea.
  final port = room.at(1, 0.6, 0.5);
  final r = a.size.width * 0.04 * room.scaleAt(0.5);
  a
    ..oval(
      Rect.fromCenter(center: port, width: r * 1.4, height: r * 2.2),
      _steel,
      line: 0.5,
    )
    ..oval(
      Rect.fromCenter(center: port, width: r * 1.0, height: r * 1.7),
      _seaFar,
      line: 0.3,
    );
  // The consoles along the back wall, the screens above them.
  room
    ..shadow(0.08, 0.92, 0.84, 0.98, strength: 0.35, spread: 0.02)
    ..block(0.08, 0.92, 0, 0.3, 0.84, 0.98, const Color(0xFF6A7478));
  for (var k = 0; k < 3; k++) {
    final x = 0.12 + k * 0.27;
    final screen = Rect.fromPoints(
      room.at(x, 0.72, 1),
      room.at(x + 0.22, 0.42, 1),
    );
    a
      ..box(screen, const Color(0xFF1E2A30), line: 0.5)
      ..fill(
        screen.deflate(a.u * 0.6),
        k == 1 ? const Color(0xFF2A1E10) : const Color(0xFF14222A),
      );
    if (k == 1) {
      // The sonar: an amber strip with its dark track.
      final s = screen.deflate(a.u * 0.6);
      a
        ..fade(
          Rect.fromLTWH(
            s.left,
            s.center.dy - s.height * 0.2,
            s.width,
            s.height * 0.4,
          ),
          const Color(0xFF6A4A20),
          const Color(0xFFB08440),
        )
        ..line(
          Offset(s.left, s.center.dy),
          Offset(s.right, s.center.dy),
          const Color(0xFF2A1E10),
          width: 0.6,
        );
    } else {
      for (var j = 0; j < 4; j++) {
        final y = screen.top + screen.height * (0.25 + j * 0.17);
        a.hairline(
          Offset(screen.left + a.u, y),
          Offset(screen.right - a.u * 2 - j * a.u, y),
          const Color(0x8890C8E0),
          0.3,
        );
      }
    }
  }
  // The chart table, Hall's chart and the note in its sleeve.
  room.table(
    0.24,
    0.76,
    0.12,
    0.46,
    0.27,
    const Color(0xFF8A8A84),
    legColor: const Color(0xFF5A5A58),
    leg: 0.018,
  );
  const y = 0.2705;
  _flatSheet(room, 0.29, 0.5, 0.18, 0.42, y, color: const Color(0xFFE2D8BC));
  a.strokePath(
    a.poly([
      room.at(0.33, y, 0.36),
      room.at(0.38, y, 0.3),
      room.at(0.44, y, 0.33),
    ]),
    const Color(0xFF3A4A8A),
    width: 0.4,
  );
  a.path(
    a.poly([
      room.at(0.53, y, 0.2),
      room.at(0.67, y, 0.2),
      room.at(0.67, y, 0.38),
      room.at(0.53, y, 0.38),
    ]),
    const Color(0x88E8F0F4),
    line: 0.4,
  );
  _flatSheet(
    room,
    0.55,
    0.65,
    0.22,
    0.36,
    y + 0.001,
    color: const Color(0xFFD8C8A0),
  );
}

/// The island: grey rock and lichen in front, the shore where the iron
/// pintle lay by a large rock, the sea and floes beyond, the helicopter
/// set down on a flat shelf of rock.
void _island(Art a) {
  final room = Room(a, vp: a.p(0.5, 0.4), depth: 0.3);
  _sky(a, 0.4);
  _seaWithFloes(room, a.size.height * 0.4, a.size.height, seed: 8);
  // The island: a low tongue of rock and gravel out into the sea.
  final land = a.poly([
    room.at(-1.2, 0, 0),
    room.at(2.2, 0, 0),
    room.at(1.8, 0, 0.6),
    room.at(1.2, 0, 0.85),
    room.at(0.4, 0, 0.9),
    room.at(-0.4, 0, 0.7),
    room.at(-1.2, 0, 0.5),
  ]);
  a.path(land, _shore, line: 0.4);
  final random = math.Random(9);
  for (var i = 0; i < 140; i++) {
    final p = room.floorAt(
      -0.8 + random.nextDouble() * 2.6,
      random.nextDouble() * 0.8,
    );
    a.canvas.drawCircle(
      p,
      a.u * (0.2 + random.nextDouble() * 0.5) * room.scaleAt(0.3),
      Paint()
        ..color = random.nextBool()
            ? const Color(0x55E8E0D0)
            : const Color(0x44303030),
    );
  }
  // Lichen and saxifrage on the near rocks.
  for (final (x, z, w) in [
    (-0.3, 0.12, 0.2),
    (1.05, 0.18, 0.24),
    (0.15, 0.6, 0.1),
  ]) {
    room.shadow(x, x + w, z, z + w * 0.6, strength: 0.4, spread: 0.1);
    final rock = room.block(x, x + w, 0, w * 0.5, z, z + w * 0.6, _rock);
    for (var k = 0; k < 5; k++) {
      a.circle(
        Offset(
          rock.left + rock.width * (0.15 + k * 0.17),
          rock.top + rock.height * (0.2 + (k % 2) * 0.4),
        ),
        a.u * 0.8 * room.scaleAt(z),
        k.isEven ? const Color(0xFFC8A040) : const Color(0xFF9A5A9A),
        line: 0,
      );
    }
  }
  // The large rock by the water, the pintle beside it, the plug farther up.
  room
    ..shadow(0.42, 0.6, 0.42, 0.54, strength: 0.45, spread: 0.08)
    ..block(0.42, 0.6, 0, 0.12, 0.42, 0.54, _rockDark);
  final pin = room.at(0.62, 0.01, 0.46);
  a
    ..line(
      pin,
      pin.translate(a.u * 3, -a.u * 0.4),
      const Color(0xFF6A3A22),
      width: 1.2,
    )
    ..circle(
      pin.translate(a.u * 3.2, -a.u * 0.4),
      a.u * 0.9,
      const Color(0xFF6A3A22),
      line: 0.3,
    );
  room
    ..footShadow(0.66, 0.3, 0.03)
    ..block(0.64, 0.69, 0, 0.03, 0.28, 0.32, _wood, line: 0.3);
  // The helicopter on a shelf of rock to the right.
  _helicopter(room, 1.2, 0.5, 0.36);
}

/// The community hall in Gjoa Haven: a wooden floor, the wall map of
/// Inuit place names, a drum on the wall, a window on the snow, and on a
/// table the elders' recordings.
void _hall(Art a) {
  final room = Room(a, vp: a.p(0.5, 0.24), depth: 0.55);
  final back = room.back;
  a
    ..path(room.ceiling, const Color(0xFFD8D2C4), line: 0)
    ..path(room.leftWall, const Color(0xFFC8D0CC), line: 0)
    ..path(room.rightWall, const Color(0xFFCCD4D0), line: 0)
    ..fill(back, const Color(0xFFD4DAD4))
    ..path(room.floor, const Color(0xFF9A7A54), line: 0);
  room
    ..floorGrid(const Color(0x33402A10), rows: 0, columns: 14)
    ..shadeCorners(strength: 0.3)
    ..edges(const Color(0x66303030), width: 0.4);
  // A window in the right wall: snow, a low hill.
  final win = a.poly([
    room.at(1, 0.78, 0.3),
    room.at(1, 0.78, 0.6),
    room.at(1, 0.48, 0.6),
    room.at(1, 0.48, 0.3),
  ]);
  a.path(win, const Color(0xFFE8ECF0), line: 0.5);
  a.hairline(
    room.at(1, 0.63, 0.3),
    room.at(1, 0.63, 0.6),
    const Color(0xFF6A6A66),
    0.4,
  );
  room.beam(
    [room.at(1, 0.48, 0.3), room.at(1, 0.48, 0.6)],
    [
      room.floorAt(0.62, 0.62),
      room.floorAt(0.92, 0.62),
      room.floorAt(0.92, 0.3),
      room.floorAt(0.62, 0.3),
    ],
    const Color(0xFFF0F4F8),
    strength: 0.1,
  );
  // The wall map: land and sea, the names written on it.
  final map = Rect.fromPoints(room.at(0.06, 0.86, 1), room.at(0.56, 0.42, 1));
  room.box(map, const Color(0xFFE8E2CC), depth: 0.01);
  a.canvas
    ..save()
    ..clipRect(map.deflate(a.u * 0.6));
  a
    ..fill(map.deflate(a.u * 0.6), const Color(0xFF9AB4C0))
    ..path(
      a.poly([
        Offset(map.left + map.width * 0.55, map.top),
        Offset(map.right, map.top),
        Offset(map.right, map.bottom),
        Offset(map.left + map.width * 0.7, map.bottom),
        Offset(map.left + map.width * 0.62, map.top + map.height * 0.5),
      ]),
      const Color(0xFFD8CCA8),
      line: 0.3,
    )
    ..path(
      a.poly([
        Offset(map.left, map.top),
        Offset(map.left + map.width * 0.4, map.top),
        Offset(map.left + map.width * 0.3, map.top + map.height * 0.25),
        Offset(map.left, map.top + map.height * 0.3),
      ]),
      const Color(0xFFD8CCA8),
      line: 0.3,
    )
    ..oval(
      Rect.fromLTWH(
        map.left + map.width * 0.18,
        map.top + map.height * 0.7,
        map.width * 0.12,
        map.height * 0.1,
      ),
      const Color(0xFFD8CCA8),
      line: 0.3,
    );
  a.canvas.restore();
  final names = math.Random(4);
  for (var k = 0; k < 7; k++) {
    final p = Offset(
      map.left + map.width * (0.1 + names.nextDouble() * 0.75),
      map.top + map.height * (0.15 + names.nextDouble() * 0.7),
    );
    a
      ..circle(p, a.u * 0.4, _red, line: 0)
      ..hairline(
        p.translate(a.u, 0),
        p.translate(a.u * 5, 0),
        const Color(0xAA2A2A2A),
        0.35,
      );
  }
  // The drum on the back wall, right.
  final drum = room.at(0.78, 0.66, 1);
  final dr = a.size.width * 0.05 * room.depth;
  a
    ..circle(drum, dr * 1.1, const Color(0xFF8A6A48), line: 0.5)
    ..circle(drum, dr, const Color(0xFFE6D6B4), line: 0.3)
    ..line(
      drum.translate(0, dr * 1.1),
      drum.translate(dr * 0.2, dr * 2.4),
      const Color(0xFF6A4A2A),
      width: 0.8,
    );
  // Chairs along the left, the table with the recordings in front.
  for (final z in [0.5, 0.66]) {
    room
      ..shadow(0.06, 0.18, z, z + 0.1, strength: 0.3, spread: 0.06)
      ..table(
        0.06,
        0.18,
        z,
        z + 0.1,
        0.15,
        const Color(0xFF4A6A8A),
        thickness: 0.03,
        leg: 0.01,
        shadow: false,
      )
      ..block(
        0.06,
        0.18,
        0.15,
        0.3,
        z + 0.08,
        z + 0.1,
        const Color(0xFF4A6A8A),
        line: 0.3,
      );
  }
  room.table(0.34, 0.66, 0.16, 0.4, 0.26, _wood, leg: 0.016);
  // A small recorder and a stack of tapes.
  room
    ..block(
      0.42,
      0.52,
      0.26,
      0.3,
      0.24,
      0.32,
      const Color(0xFF3A3A3A),
      line: 0.3,
    )
    ..block(
      0.55,
      0.6,
      0.26,
      0.28,
      0.24,
      0.3,
      const Color(0xFF8A2A22),
      line: 0.3,
    )
    ..block(
      0.55,
      0.6,
      0.28,
      0.3,
      0.24,
      0.3,
      const Color(0xFF2A4A6A),
      line: 0.3,
    );
  a.glow(room.at(0.5, 0.3, 0.28), a.size.width * 0.2, _lamp, strength: 0.1);
}

// ---------------------------------------------------------------------------
// Puzzle boards

/// The chart table seen close, under the lamp.
void _deskBoard(Art a) {
  a
    ..fade(
      Offset.zero & a.size,
      const Color(0xFF3A4044),
      const Color(0xFF22282C),
    )
    ..glow(
      a.p(0.35, 0.1),
      a.size.width * 0.6,
      const Color(0xFFF0F4F4),
      strength: 0.14,
    );
}

/// The sonar console, dark, its screen's glow.
void _consoleBoard(Art a) {
  a
    ..fade(
      Offset.zero & a.size,
      const Color(0xFF141C22),
      const Color(0xFF0C1216),
    )
    ..glow(
      a.p(0.4, 0.5),
      a.size.width * 0.5,
      const Color(0xFFB08440),
      strength: 0.08,
    );
}

// ---------------------------------------------------------------------------
// Objects

/// Later papers pinned to the wall.
void _papers(Art a) {
  for (var i = 0; i < 3; i++) {
    a.paper(
      a.r(0.06 + i * 0.28, 0.1 + (i % 2) * 0.08, 0.3, 0.72),
      lines: 6,
      angle: -0.05 + i * 0.05,
      color: i == 1 ? const Color(0xFFF2F2EE) : _paper,
      ink: 0.5,
    );
  }
}

/// A fresh Admiralty form lying on the table, seen at a slant.
void _form(Art a) {
  final sheet = a.poly([
    a.p(0.1, 0.06),
    a.p(0.9, 0.06),
    a.p(0.97, 0.94),
    a.p(0.03, 0.94),
  ]);
  a.path(sheet, const Color(0xFFF0EAD4), line: 0.4);
  for (var k = 0; k < 3; k++) {
    a.hairline(
      a.p(0.2, 0.25 + k * 0.08),
      a.p(0.8, 0.25 + k * 0.08),
      const Color(0x663A3630),
      0.4,
    );
  }
  for (var k = 0; k < 3; k++) {
    a.hairline(
      a.p(0.15, 0.6 + k * 0.1),
      a.p(0.85, 0.6 + k * 0.1),
      const Color(0x333A3630),
      0.3,
    );
  }
}

/// The jar: the grey Arctic sea, floes, and under the water the long dark
/// shape of a ship on the seabed.
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
    ..fade(a.r(0, 0.16, 1, 0.3), _skyHigh, _skyLow)
    ..fade(a.r(0, 0.46, 1, 0.54), _seaFar, const Color(0xFF1E2E38))
    ..path(
      a.poly([
        a.p(0.1, 0.46),
        a.p(0.4, 0.45),
        a.p(0.42, 0.48),
        a.p(0.12, 0.49),
      ]),
      _ice,
      line: 0.3,
    )
    ..path(
      a.poly([a.p(0.6, 0.47), a.p(0.9, 0.46), a.p(0.88, 0.5), a.p(0.62, 0.5)]),
      _ice,
      line: 0.3,
    )
    ..fill(a.r(0, 0.9, 1, 0.1), const Color(0xFF3A4A44));
  // The ship on the seabed, its masts broken.
  a
    ..path(
      a.poly([
        a.p(0.18, 0.84),
        a.p(0.82, 0.82),
        a.p(0.76, 0.9),
        a.p(0.24, 0.91),
      ]),
      const Color(0xFF2A2420),
      line: 0.4,
    )
    ..line(a.p(0.42, 0.83), a.p(0.44, 0.7), const Color(0xFF2A2420), width: 1)
    ..line(a.p(0.6, 0.83), a.p(0.58, 0.74), const Color(0xFF2A2420), width: 1);
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
  // The lid: a ship's bell.
  final bell = Path()
    ..moveTo(w * 0.36, h * 0.16)
    ..quadraticBezierTo(w * 0.38, h * 0.04, w * 0.5, h * 0.04)
    ..quadraticBezierTo(w * 0.62, h * 0.04, w * 0.64, h * 0.16)
    ..close();
  a.path(bell, StillroomPalette.brass, line: 0.5);
}
