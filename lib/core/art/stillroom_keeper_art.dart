import 'dart:math' as math;
import 'dart:ui';

import '../theme/stillroom_palette.dart';
import 'art_kit.dart';
import 'depth_kit.dart';
import 'figure_kit.dart';
import 'keeper_art.dart';
import 'vector_art.dart' show vectorArtFor;
import 'whitechapel_1888_art.dart' show jarLabelBoard;

/// Code-drawn art for the keeper's own tale (docs/episodes/
/// stillroom_keeper.md): behind the shelves of the Stillroom, the keeper's
/// stillroom and her study, and a window that looks out on every tale.
const _s = 'images/scenes/stillroom_keeper';
const _o = 'images/objects/stillroom_keeper';
const _i = 'images/items/stillroom_keeper';

/// The places the window turns through, in shelf order: a scene of each
/// tale, then her own house.
const keeperViews = [
  'images/scenes/whitechapel_1888/window.png',
  'images/scenes/lawang_sewu_1945/window_1945.png',
  'images/scenes/flannan_isles_1900/east_landing.png',
  'images/scenes/pompeii_79/street.png',
  'images/scenes/bastille_1703/courtyard.png',
  'images/scenes/gyeongju_771/yard.png',
  'images/scenes/whitechapel_1891/swallow_gardens.png',
  'images/scenes/chongling_1908/stele_court.png',
  'images/scenes/alamut_1256/gate_court.png',
  'images/scenes/great_zimbabwe_1871/valley.png',
  'images/scenes/dyatlov_1959/slope.png',
  'images/scenes/honnoji_1582/teramachi.png',
  'images/scenes/roanoke_1590/shore.png',
  'images/scenes/franklin_1845/island.png',
  'images/scenes/borobudur_1814/foot.png',
];

final Map<String, ArtPainter> stillroomKeeperArt = {
  '$_s/behind.png': (c, s) => _behind(Art(c, s)),
  '$_s/stillroom.png': (c, s) => _stillroom(Art(c, s)),
  '$_s/study.png': (c, s) => _study(Art(c, s)),
  '$_s/window.png': (c, s) => _window(Art(c, s)),
  '$_s/board.png': (c, s) => _board(Art(c, s)),
  '$_s/label_close.png': (c, s) =>
      jarLabelBoard(Art(c, s), const Color(0xFF2A2018)),
  '$_o/door_open_sprite.png': (c, s) => _doorOpen(Art(c, s)),
  '$_o/fire_sprite.png': (c, s) => _fire(Art(c, s)),
  '$_o/portrait_grimed.png': (c, s) =>
      paintKeeperPortrait(Art(c, s), look: PortraitLook.grimed),
  '$_o/portrait_scraped.png': (c, s) =>
      paintKeeperPortrait(Art(c, s), look: PortraitLook.scraped),
  '$_o/portrait_whole.png': (c, s) =>
      paintKeeperPortrait(Art(c, s), look: PortraitLook.whole),
  '$_o/hester.png': (c, s) => _hester(Art(c, s)),
  '$_o/letters_sprite.png': (c, s) => _letters(Art(c, s)),
  for (final (k, scene) in keeperViews.indexed)
    '$_o/view_$k.png': (c, s) => _view(Art(c, s), scene),
  '$_o/view_${keeperViews.length}.png': (c, s) =>
      _view(Art(c, s), null, house: true),
  '$_o/house_her_sprite.png': (c, s) => _houseHer(Art(c, s)),
  '$_i/tinder.png': (c, s) => _tinder(Art(c, s)),
  '$_i/spirit.png': (c, s) => _spirit(Art(c, s)),
  'images/ui/jar_stillroom_keeper.png': (c, s) => _jar(Art(c, s)),
};

// ---------------------------------------------------------------------------
// Palette

const _walnut = Color(0xFF4A3424);
const _walnutDark = Color(0xFF2A1E14);
const _plaster = Color(0xFF8A7A62);
const _boards = Color(0xFF5A4030);
const _amber = Color(0xFFE8A84A);
const _copper = Color(0xFFB0683A);
const _copperDark = Color(0xFF6A3A1E);
const _brick = Color(0xFF7A4434);

/// The keeper's rooms share one camera: the eye a little high, as in the
/// Bastille's cell.
const _eye = Offset(0.5, 0.26);

/// A room of the keeper's: plaster walls, a beamed ceiling, boards running
/// back, a dado of walnut. Returns its camera.
Room _room(
  Art a, {
  double depth = 0.6,
  Color wall = _plaster,
  Color dado = _walnut,
}) {
  final room = Room(a, vp: a.p(_eye.dx, _eye.dy), depth: depth);
  final back = room.back;
  a
    ..path(room.ceiling, const Color(0xFF221812), line: 0)
    ..path(room.leftWall, Color.lerp(wall, Art.outline, 0.3)!, line: 0)
    ..path(room.rightWall, Color.lerp(wall, Art.outline, 0.2)!, line: 0)
    ..fade(back, Color.lerp(wall, Art.outline, 0.25)!, wall)
    ..path(room.floor, _boards, line: 0);
  // The ceiling's beams, running across.
  for (var k = 1; k < 6; k++) {
    a.line(room.at(0, 1, k / 6), room.at(1, 1, k / 6), _walnutDark, width: 1.6);
  }
  // Walnut to waist height round the three walls.
  a.wood(
    Rect.fromPoints(room.at(0, 0.3, 1), room.at(1, 0, 1)),
    base: dado,
    vertical: true,
    grain: 12,
  );
  for (final x in [0.0, 1.0]) {
    a.path(
      a.poly([
        room.at(x, 0, 0),
        room.at(x, 0.3, 0),
        room.at(x, 0.3, 1),
        room.at(x, 0, 1),
      ]),
      Color.lerp(dado, Art.outline, 0.3)!,
      line: 0,
    );
  }
  room
    ..floorGrid(
      Color.lerp(_boards, Art.outline, 0.5)!,
      rows: 0,
      columns: 12,
      width: 0.45,
    )
    ..shadeCorners(strength: 0.45)
    ..edges(const Color(0xAA140E08));
  a.ink(back, width: 0.5);
  return room;
}

/// A soft warm glow: a candle's light on what is round it.
void _candle(Art a, Offset base, double height) {
  a
    ..glow(
      base.translate(0, -height),
      height * 6,
      StillroomPalette.gaslight,
      strength: 0.35,
    )
    ..box(
      Rect.fromCenter(
        center: base.translate(0, -height * 0.5),
        width: height * 0.35,
        height: height,
      ),
      const Color(0xFFE8DCC0),
      line: 0.3,
    )
    ..flame(base.translate(0, -height), height * 0.7);
}

// ---------------------------------------------------------------------------
// Behind the shelves (start)

/// The study door in the right wall, from depth 0.25 to 0.6.
List<Offset> _studyDoor(Room room) => [
  room.at(1, 0.72, 0.25),
  room.at(1, 0.72, 0.6),
  room.at(1, 0, 0.6),
  room.at(1, 0, 0.25),
];

void _behind(Art a) {
  final room = _room(a, depth: 0.58, wall: const Color(0xFF6E6250));
  final back = room.back;
  // The backs of the shelves: a walnut frame across the back wall, five
  // shelves, the jars on them seen from behind, lit through from the room
  // beyond.
  final frame = Rect.fromLTRB(
    back.left + back.width * 0.04,
    back.top + back.height * 0.05,
    back.right - back.width * 0.04,
    back.bottom,
  );
  a.fill(frame, const Color(0xFF1A120C));
  // Light from the room on the other side, between the jars.
  a.canvas.drawRect(
    frame,
    Paint()
      ..shader = Gradient.radial(frame.center, frame.width * 0.6, [
        const Color(0x55E8A84A),
        const Color(0x00000000),
      ]),
  );
  const counts = [1, 5, 4, 4, 2];
  const shelves = 5;
  for (var row = 0; row < shelves; row++) {
    final y = frame.top + frame.height * (row + 1) / shelves;
    room.box(
      Rect.fromLTRB(frame.left, y - a.u * 1.2, frame.right, y),
      _walnut,
      depth: 0.03,
      line: 0.3,
    );
    final n = counts[row];
    for (var k = 0; k < n; k++) {
      final cx = frame.left + frame.width * (k + 0.5) / n;
      final jh = frame.height / shelves * 0.66;
      final jar = Rect.fromCenter(
        center: Offset(cx, y - a.u * 1.2 - jh / 2),
        width: jh * 0.62,
        height: jh,
      );
      // The top shelf: one jar gone, its place a ring in the dust.
      final gone = row == 0;
      if (gone) {
        a.canvas.drawOval(
          Rect.fromCenter(
            center: Offset(cx, y - a.u * 1.4),
            width: jar.width,
            height: a.u * 1.4,
          ),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = a.u * 0.4
            ..color = const Color(0x88B8A888),
        );
        continue;
      }
      a.canvas
        ..drawRRect(
          RRect.fromRectAndRadius(jar, Radius.circular(jar.width * 0.25)),
          Paint()
            ..shader = Gradient.linear(jar.topCenter, jar.bottomCenter, [
              _amber.withValues(alpha: 0.85),
              const Color(0xCC8A4A1A),
            ]),
        )
        ..drawRRect(
          RRect.fromRectAndRadius(jar, Radius.circular(jar.width * 0.25)),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = a.u * 0.3
            ..color = Art.outline,
        )
        // The red wax seal on its lid.
        ..drawCircle(
          jar.topCenter.translate(0, a.u * 0.5),
          jar.width * 0.22,
          Paint()..color = const Color(0xFF9A2A1E),
        );
      a.glow(jar.center, jar.width, _amber, strength: 0.25);
    }
  }
  a.ink(frame, width: 0.6);

  // The arch in the left wall into the stillroom, warm light inside.
  Offset left(double y, double z) => room.at(0, y, z);
  final arch = Path()..moveTo(left(0, 0.2).dx, left(0, 0.2).dy);
  for (var k = 0; k <= 12; k++) {
    final t = k / 12;
    final z = 0.2 + 0.36 * t;
    final y = 0.56 + 0.16 * math.sin(math.pi * t);
    final q = left(y, z);
    arch.lineTo(q.dx, q.dy);
  }
  arch
    ..lineTo(left(0, 0.56).dx, left(0, 0.56).dy)
    ..close();
  a
    ..path(arch, const Color(0xFF8A5A30), line: 0.6)
    ..glow(left(0.3, 0.38), a.size.width * 0.1, _amber, strength: 0.4);

  // The study door in the right wall, shut, the lock of seals on it.
  final door = _studyDoor(room);
  a.path(a.poly(door), _walnut, line: 0.6);
  for (var k = 1; k < 4; k++) {
    final z = 0.25 + 0.35 * k / 4;
    a.hairline(room.at(1, 0.72, z), room.at(1, 0, z), _walnutDark, 0.4);
  }
  final lock = room.at(1, 0.38, 0.42);
  final r = a.size.height * 0.05;
  a.circle(lock, r, const Color(0xFF3A3A3A), line: 0.4);
  for (var k = 0; k < 15; k++) {
    final t = k / 15 * math.pi * 2;
    a.canvas.drawCircle(
      lock + Offset(math.cos(t) * r * 0.72, math.sin(t) * r * 0.72),
      r * 0.12,
      Paint()..color = const Color(0xFFB0302A),
    );
  }
  a.circle(lock, r * 0.25, StillroomPalette.brass, line: 0.2);

  // A stool, nearer, a chapbook left on it.
  final top = room.table(
    0.12,
    0.3,
    0.12,
    0.28,
    0.2,
    _walnut,
    thickness: 0.03,
    leg: 0.018,
  );
  a.paper(
    Rect.fromCenter(
      center: top.topCenter.translate(0, -a.u * 1.6),
      width: top.width * 0.55,
      height: a.u * 3,
    ),
    lines: 2,
    angle: -0.06,
    color: const Color(0xFFD8C8A0),
  );
  _candle(a, room.at(0.06, 0.62, 0.66), a.size.height * 0.04);
}

/// The study door, open: the room beyond in candle light (over
/// [_studyDoor]; the layer [0.84, 0.25, 0.14, 0.72]).
void _doorOpen(Art a) {
  final room = Room.sprite(
    a,
    eye: _eye,
    layer: (0.84, 0.25, 0.14, 0.72),
    depth: 0.58,
  );
  final door = _studyDoor(room);
  a.path(a.poly(door), const Color(0xFF3A2414), line: 0.6);
  a.glow(
    Offset.lerp(door[0], door[2], 0.5)!,
    a.size.width * 0.8,
    _amber,
    strength: 0.5,
  );
  // The door itself swung back into the room.
  a.path(
    a.poly([door[0], door[3], door[3].translate(-a.size.width * 0.5, 0)]),
    _walnut,
    line: 0.5,
  );
}

// ---------------------------------------------------------------------------
// The stillroom

void _stillroom(Art a) {
  final room = _room(a, wall: const Color(0xFFA8987A));
  final back = room.back;
  // Shelves of stoppered bottles on the back wall, right.
  for (final y in [0.3, 0.42]) {
    final shelf = Rect.fromLTRB(
      back.left + back.width * 0.55,
      a.p(0, y).dy,
      back.right - back.width * 0.04,
      a.p(0, y).dy + a.u * 1.2,
    );
    room.box(shelf, _walnut, depth: 0.04, line: 0.3);
    final random = math.Random((y * 100).round());
    for (var x = shelf.left + a.u; x < shelf.right - a.u * 3;) {
      final bw = a.u * (2.4 + random.nextDouble() * 1.6);
      final bh = a.size.height * (0.05 + random.nextDouble() * 0.03);
      final colour = [
        const Color(0xCC6A8A5A),
        const Color(0xCC8A5A2A),
        const Color(0xCCB8C8D0),
        const Color(0xCC5A3A2A),
      ][random.nextInt(4)];
      a
        ..rbox(
          Rect.fromLTWH(x, shelf.top - bh, bw, bh),
          bw * 0.3,
          colour,
          line: 0.25,
        )
        ..box(
          Rect.fromLTWH(x + bw * 0.3, shelf.top - bh - a.u, bw * 0.4, a.u),
          const Color(0xFF8A6A4A),
          line: 0.2,
        );
      x += bw + a.u * 0.8;
    }
  }
  // Herbs drying from a rail under the ceiling.
  final rail = room.at(0.1, 0.92, 0.9);
  final railEnd = room.at(0.9, 0.92, 0.9);
  a.line(rail, railEnd, _walnutDark, width: 1.2);
  final random = math.Random(7);
  for (var k = 0; k < 9; k++) {
    final at = Offset.lerp(rail, railEnd, (k + 0.5) / 9)!;
    final len = a.size.height * (0.07 + random.nextDouble() * 0.04);
    a.line(at, at.translate(0, len * 0.3), const Color(0xFF6A5A3A), width: 0.4);
    a.path(
      a.poly([
        at.translate(-a.u * 1.2, len * 0.3),
        at.translate(a.u * 1.2, len * 0.3),
        at.translate(a.u * 0.4, len),
        at.translate(-a.u * 0.4, len),
      ]),
      [
        const Color(0xFF6A7A4A),
        const Color(0xFF8A6A8A),
        const Color(0xFF9A8A4A),
      ][k % 3],
      line: 0.3,
    );
  }
  // The furnace of brick, the copper pot on it, its head, the arm.
  room.shadow(0.06, 0.34, 0.36, 0.6);
  final furnace = room.block(0.06, 0.34, 0, 0.32, 0.36, 0.6, _brick);
  paintOnFace(a, furnace, (f) {
    for (var y = 0.12; y < 1; y += 0.14) {
      f.hairline(f.p(0, y), f.p(1, y), const Color(0x553A2018), 0.6);
    }
    f.box(f.r(0.36, 0.5, 0.28, 0.32), const Color(0xFF140C08), line: 0.5);
  });
  final potBase = room.at(0.2, 0.32, 0.48);
  final pw = (room.at(0.32, 0.32, 0.48).dx - room.at(0.08, 0.32, 0.48).dx);
  final pot = Rect.fromCenter(
    center: potBase.translate(0, -pw * 0.28),
    width: pw,
    height: pw * 0.62,
  );
  a
    ..oval(pot, _copper, line: 0.6)
    ..oval(
      pot.deflate(pw * 0.12).shift(Offset(-pw * 0.08, -pw * 0.06)),
      const Color(0x33FFFFFF),
      line: 0,
    );
  final head = Path()
    ..moveTo(pot.center.dx - pw * 0.16, pot.top + pw * 0.04)
    ..quadraticBezierTo(
      pot.center.dx,
      pot.top - pw * 0.5,
      pot.center.dx + pw * 0.16,
      pot.top + pw * 0.04,
    )
    ..close();
  a.path(head, _copper, line: 0.5);
  final armStart = Offset(pot.center.dx + pw * 0.05, pot.top - pw * 0.3);
  // The worm tub: a cask of water, iron hoops.
  room.shadow(0.42, 0.58, 0.48, 0.66);
  final tub = room.block(
    0.42,
    0.58,
    0,
    0.36,
    0.48,
    0.66,
    const Color(0xFF6A4A30),
  );
  for (final t in [0.2, 0.75]) {
    a.line(
      Offset(tub.left, tub.top + tub.height * t),
      Offset(tub.right, tub.top + tub.height * t),
      const Color(0xFF2A2A2A),
      width: 1.2,
    );
  }
  a
    ..line(
      armStart,
      Offset(tub.left + tub.width * 0.3, tub.top),
      _copperDark,
      width: 1.6,
    )
    // The spout from the tub's foot, a small glass under it on a stool.
    ..line(
      Offset(tub.right, tub.top + tub.height * 0.7),
      Offset(tub.right + tub.width * 0.25, tub.top + tub.height * 0.78),
      _copperDark,
      width: 1.2,
    );
  // The bench on the right, the receipt book open on it, a candle.
  final bench = room.table(
    0.62,
    0.96,
    0.28,
    0.52,
    0.34,
    _walnut,
    thickness: 0.03,
    leg: 0.02,
  );
  Offset onBench(double u, double v) =>
      room.at(0.66 + 0.2 * u, 0.34, 0.31 + 0.16 * v);
  a
    ..path(
      a.poly([onBench(0, 0), onBench(1, 0), onBench(1, 1), onBench(0, 1)]),
      const Color(0xFF3A2414),
      line: 0.4,
    )
    ..path(
      a.poly([
        onBench(0.04, 0.08),
        onBench(0.49, 0.08),
        onBench(0.49, 0.92),
        onBench(0.04, 0.92),
      ]),
      const Color(0xFFE8DCC0),
      line: 0.3,
    )
    ..path(
      a.poly([
        onBench(0.51, 0.08),
        onBench(0.96, 0.08),
        onBench(0.96, 0.92),
        onBench(0.51, 0.92),
      ]),
      const Color(0xFFE2D4B4),
      line: 0.3,
    );
  for (var k = 1; k < 5; k++) {
    final v = 0.08 + 0.84 * k / 5;
    a
      ..hairline(
        onBench(0.08, v),
        onBench(0.45, v),
        const Color(0x663A2614),
        0.3,
      )
      ..hairline(
        onBench(0.55, v),
        onBench(0.92, v),
        const Color(0x663A2614),
        0.3,
      );
  }
  _candle(a, room.at(0.92, 0.34, 0.45), a.size.height * 0.05);
  a.hairline(bench.topLeft, bench.topLeft, Art.outline, 0.1);
}

/// The furnace lit: fire behind its door, its glow on the floor (the layer
/// [0.08, 0.5, 0.26, 0.34]).
void _fire(Art a) {
  a
    ..glow(
      a.p(0.5, 0.62),
      a.size.width * 0.7,
      const Color(0xFFF2A040),
      strength: 0.55,
    )
    ..fill(a.r(0.38, 0.52, 0.24, 0.26), const Color(0xFFE08A3A));
  for (var k = 0; k < 4; k++) {
    a.flame(a.p(0.42 + k * 0.05, 0.78), a.size.height * 0.16);
  }
}

// ---------------------------------------------------------------------------
// The study

/// The window in the left wall, from depth 0.18 to 0.5.
List<Offset> _studyWindow(Room room) => [
  room.at(0, 0.86, 0.18),
  room.at(0, 0.86, 0.5),
  room.at(0, 0.36, 0.5),
  room.at(0, 0.36, 0.18),
];

void _study(Art a) {
  final room = _room(a, depth: 0.62, wall: const Color(0xFF5E6458));
  final back = room.back;
  // The window in the left wall, the last light in it.
  final win = _studyWindow(room);
  a.path(a.poly(win), const Color(0xFF7A8AA0), line: 0.6);
  for (var k = 1; k < 3; k++) {
    final z = 0.18 + 0.32 * k / 3;
    a.line(room.at(0, 0.86, z), room.at(0, 0.36, z), _walnutDark, width: 0.8);
  }
  a.line(
    room.at(0, 0.61, 0.18),
    room.at(0, 0.61, 0.5),
    _walnutDark,
    width: 0.8,
  );
  room.beam(
    [win[3], win[2]],
    [
      room.floorAt(0.08, 0.5),
      room.floorAt(0.36, 0.5),
      room.floorAt(0.3, 0.12),
      room.floorAt(0.02, 0.12),
    ],
    const Color(0xFFB8C8E0),
    strength: 0.12,
  );
  // The coat rack on the back wall, right: four pegs, a coat on the last.
  final rack = Rect.fromLTRB(
    back.left + back.width * 0.68,
    a.p(0, 0.2).dy,
    back.right - back.width * 0.03,
    a.p(0, 0.2).dy + a.u * 1.6,
  );
  room.box(rack, _walnut, depth: 0.03, line: 0.4);
  for (var k = 0; k < 4; k++) {
    final peg = Offset(
      rack.left + rack.width * (k + 0.5) / 4,
      rack.bottom + a.u * 0.6,
    );
    a.circle(peg, a.u * 0.7, StillroomPalette.brass, line: 0.2);
  }
  final peg = Offset(rack.left + rack.width * 3.5 / 4, rack.bottom);
  final coat = Path()
    ..moveTo(peg.dx, peg.dy)
    ..lineTo(peg.dx + a.u * 3, peg.dy + a.size.height * 0.05)
    ..lineTo(peg.dx + a.u * 4, peg.dy + a.size.height * 0.38)
    ..lineTo(peg.dx - a.u * 4.4, peg.dy + a.size.height * 0.38)
    ..lineTo(peg.dx - a.u * 3, peg.dy + a.size.height * 0.05)
    ..close();
  a
    ..path(
      coat.shift(Offset(a.u * 1.2, a.u * 0.8)),
      const Color(0x44000000),
      line: 0,
    )
    ..path(coat, const Color(0xFF4A4A40), line: 0.5)
    ..line(
      Offset(peg.dx, peg.dy + a.size.height * 0.05),
      Offset(peg.dx, peg.dy + a.size.height * 0.37),
      const Color(0xFF2A2A24),
      width: 0.4,
    );
  // The portrait's place on the back wall: a nail, the frame's shadow.
  a.canvas.drawOval(
    a.r(0.425, 0.15, 0.16, 0.38),
    Paint()
      ..color = const Color(0x66000000)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, a.u * 2),
  );
  // The desk, left, the drafts on it, a candle.
  final desk = room.table(
    0.06,
    0.4,
    0.24,
    0.48,
    0.32,
    _walnut,
    thickness: 0.03,
    leg: 0.02,
  );
  final random = math.Random(5);
  for (var k = 0; k < 6; k++) {
    final at = room.at(
      0.1 + random.nextDouble() * 0.2,
      0.32,
      0.3 + random.nextDouble() * 0.14,
    );
    a.paper(
      Rect.fromCenter(
        center: at,
        width: a.size.width * 0.05,
        height: a.u * 2.4,
      ),
      lines: 2,
      angle: random.nextDouble() * 0.6 - 0.3,
      color: const Color(0xFFE2D6BA),
    );
  }
  _candle(a, room.at(0.36, 0.32, 0.42), a.size.height * 0.05);
  a.hairline(desk.topLeft, desk.topLeft, Art.outline, 0.1);
}

/// Her: Hester Croft, as she was, standing by the coat rack: not an echo,
/// in her own colours, a face.
void _hester(Art a) {
  a.glow(
    a.p(0.5, 0.5),
    a.size.width * 1.4,
    StillroomPalette.gaslight,
    strength: 0.18,
  );
  paintFigure(
    a,
    const Figure(
      top: Color(0xFF4A3E3A),
      hem: 0.92,
      inner: Color(0xFFEDE6D8),
      apron: Color(0xFFE6DCC8),
      hat: Hat.mobCap,
      hatColor: Color(0xFFEDE6D8),
      hair: Color(0xFF5A3A26),
      skin: Color(0xFFE6C2A2),
      shoes: Color(0xFF2A2220),
      left: Pose.chest,
    ),
    echo: false,
  );
}

/// A bundle of letters tied with tape: one more each time the keeper's
/// stars have grown on the shelves.
void _letters(Art a) {
  for (var k = 0; k < 3; k++) {
    a.paper(
      a.r(0.1 + k * 0.04, 0.4 - k * 0.12, 0.8, 0.5),
      lines: 2,
      angle: (k - 1) * 0.08,
      color: const Color(0xFFE2D6BA),
    );
  }
  a.fill(a.r(0.46, 0.1, 0.08, 0.86), const Color(0xFF8A2A22));
}

// ---------------------------------------------------------------------------
// The window

/// The glass of the window, on the window scene.
const keeperGlass = (0.24, 0.1, 0.52, 0.66);

void _window(Art a) {
  a.fill(Offset.zero & a.size, const Color(0xFF3A2E24));
  final wall = Paint()
    ..shader = Gradient.radial(a.p(0.5, 0.45), a.size.width * 0.7, [
      const Color(0xFF6E6250),
      const Color(0xFF2A2018),
    ]);
  a.canvas.drawRect(Offset.zero & a.size, wall);
  final (gx, gy, gw, gh) = keeperGlass;
  final glass = a.r(gx, gy, gw, gh);
  // The deep reveal round the window, the sill below.
  a
    ..path(
      a.poly([
        glass.topLeft.translate(-a.u * 6, -a.u * 4),
        glass.topRight.translate(a.u * 6, -a.u * 4),
        glass.topRight,
        glass.topLeft,
      ]),
      const Color(0xFF4A3E30),
      line: 0.4,
    )
    ..path(
      a.poly([
        glass.topLeft.translate(-a.u * 6, -a.u * 4),
        glass.topLeft,
        glass.bottomLeft,
        glass.bottomLeft.translate(-a.u * 6, a.u * 4),
      ]),
      const Color(0xFF5A4E3E),
      line: 0.4,
    )
    ..path(
      a.poly([
        glass.topRight.translate(a.u * 6, -a.u * 4),
        glass.topRight,
        glass.bottomRight,
        glass.bottomRight.translate(a.u * 6, a.u * 4),
      ]),
      const Color(0xFF3A2E22),
      line: 0.4,
    )
    ..fill(glass, const Color(0xFF1A2230))
    ..wood(a.r(gx - 0.06, gy + gh, gw + 0.12, 0.05), base: _walnut, grain: 2);
  // The brass ring that turns the window.
  a
    ..circle(
      a.p(gx + gw + 0.06, gy + gh * 0.55),
      a.u * 3.2,
      Color.lerp(StillroomPalette.brass, Art.outline, 0.2)!,
      line: 0.5,
    )
    ..circle(
      a.p(gx + gw + 0.06, gy + gh * 0.55),
      a.u * 1.8,
      const Color(0xFF3A2E24),
      line: 0.3,
    );
  // A pot of rosemary on the sill.
  a.path(
    a.poly([
      a.p(0.3, gy + gh + 0.0),
      a.p(0.36, gy + gh + 0.0),
      a.p(0.35, gy + gh - 0.06),
      a.p(0.31, gy + gh - 0.06),
    ]),
    const Color(0xFF9A5A3A),
    line: 0.4,
  );
  for (var k = 0; k < 7; k++) {
    a.line(
      a.p(0.33, gy + gh - 0.06),
      a.p(0.29 + k * 0.013, gy + gh - 0.16 - (k % 3) * 0.02),
      const Color(0xFF4A6A3A),
      width: 0.8,
    );
  }
}

/// One view through the window: a tale's place (its scene art) or her
/// house, under the leads of the panes and a sheen on the old glass.
void _view(Art a, String? scene, {bool house = false}) {
  a.canvas
    ..save()
    ..clipRect(Offset.zero & a.size);
  final paint = scene == null ? null : vectorArtFor(scene);
  if (house || paint == null) {
    _house(a);
  } else {
    // The scene, scaled to the glass, cropped to its height.
    final scale = a.size.height / (a.size.width * 9 / 16);
    final size = Size(a.size.width * scale, a.size.height);
    a.canvas
      ..save()
      ..translate((a.size.width - size.width) / 2, 0);
    paint(a.canvas, size);
    a.canvas.restore();
  }
  // Old glass: a little uneven, a cool sheen across it.
  a.canvas.drawRect(
    Offset.zero & a.size,
    Paint()
      ..shader = Gradient.linear(
        Offset.zero,
        Offset(a.size.width, a.size.height),
        [
          const Color(0x22FFFFFF),
          const Color(0x00FFFFFF),
          const Color(0x18B8C8D8),
        ],
        [0, 0.5, 1],
      ),
  );
  // The leads: diamond panes.
  final lead = Paint()
    ..strokeWidth = a.u * 0.5
    ..color = const Color(0xCC2A2A2A);
  for (var k = -6; k <= 12; k++) {
    final x = a.size.width * k / 6;
    a.canvas
      ..drawLine(
        Offset(x, 0),
        Offset(x + a.size.height * 0.8, a.size.height),
        lead,
      )
      ..drawLine(
        Offset(x, 0),
        Offset(x - a.size.height * 0.8, a.size.height),
        lead,
      );
  }
  a.canvas.restore();
  a.ink(Offset.zero & a.size, width: 0.8);
}

/// Her house: a brick house among trees at dusk, a garden of herbs in
/// front, one window lit low down: the stillroom's.
void _house(Art a) {
  a
    ..fade(a.r(0, 0, 1, 0.62), const Color(0xFF3A4660), const Color(0xFFC8906A))
    ..fill(a.r(0, 0.62, 1, 0.38), const Color(0xFF3A4A2E));
  for (final (x, r) in [(0.08, 0.14), (0.9, 0.16), (0.98, 0.1)]) {
    a.circle(a.p(x, 0.5), a.size.width * r, const Color(0xFF26301E), line: 0);
  }
  final house = a.r(0.24, 0.3, 0.52, 0.34);
  a
    ..box(house, const Color(0xFF8A5A44), line: 0.5)
    ..path(
      a.poly([a.p(0.2, 0.31), a.p(0.5, 0.14), a.p(0.8, 0.31)]),
      const Color(0xFF4A3A34),
      line: 0.5,
    )
    ..box(a.r(0.62, 0.1, 0.05, 0.12), const Color(0xFF7A4A3A), line: 0.4);
  for (var row = 0; row < 2; row++) {
    for (var k = 0; k < 4; k++) {
      final lit = row == 1 && k == 0;
      a.box(
        a.r(0.28 + k * 0.12, 0.36 + row * 0.14, 0.06, 0.08),
        lit ? const Color(0xFFF2C66A) : const Color(0xFF2A3040),
        line: 0.3,
      );
      if (lit) {
        a.glow(
          a.p(0.31, 0.54),
          a.size.width * 0.12,
          StillroomPalette.gaslight,
          strength: 0.5,
        );
      }
    }
  }
  // The herb beds before the door.
  for (var k = 0; k < 5; k++) {
    a.oval(
      a.r(0.12 + k * 0.16, 0.74 + (k % 2) * 0.06, 0.12, 0.05),
      const Color(0xFF5A6A3A),
      line: 0.3,
    );
  }
}

/// Her, small, at the lit window of the house (over view 15).
void _houseHer(Art a) {
  a.glow(
    a.p(0.5, 0.5),
    a.size.width * 0.9,
    StillroomPalette.gaslight,
    strength: 0.6,
  );
  paintFigure(
    a,
    const Figure(
      top: Color(0xFF4A3E3A),
      hem: 0.92,
      apron: Color(0xFFE6DCC8),
      hat: Hat.mobCap,
      hatColor: Color(0xFFEDE6D8),
      skin: Color(0xFFE6C2A2),
    ),
    echo: false,
  );
}

// ---------------------------------------------------------------------------
// Boards, items, jar

/// A dark ground for the puzzle screens: walnut and candle light.
void _board(Art a) {
  a
    ..fade(
      Offset.zero & a.size,
      const Color(0xFF2A1E16),
      const Color(0xFF140E0A),
    )
    ..glow(
      a.p(0.3, 0.3),
      a.size.width * 0.5,
      StillroomPalette.gaslight,
      strength: 0.12,
    );
}

/// A tinder box: a tin with a striker and a flint on its lid.
void _tinder(Art a) {
  a
    ..rbox(a.r(0.14, 0.34, 0.72, 0.42), a.u * 6, const Color(0xFF5A5E62))
    ..oval(a.r(0.16, 0.28, 0.68, 0.16), const Color(0xFF7A7E82), line: 0.5)
    ..box(a.r(0.3, 0.3, 0.4, 0.06), const Color(0xFF3A3A3A), line: 0.3)
    ..path(
      a.poly([
        a.p(0.6, 0.22),
        a.p(0.72, 0.18),
        a.p(0.76, 0.26),
        a.p(0.64, 0.3),
      ]),
      const Color(0xFFC8C0A8),
      line: 0.3,
    );
}

/// The heart of the run: a small stoppered bottle, clear spirit in it.
void _spirit(Art a) {
  a
    ..rbox(a.r(0.3, 0.32, 0.4, 0.58), a.u * 10, const Color(0xAAD8E8F0))
    ..fill(a.r(0.33, 0.5, 0.34, 0.37), const Color(0x88E8F4FF))
    ..box(a.r(0.42, 0.14, 0.16, 0.2), const Color(0xAAD8E8F0), line: 0.4)
    ..box(a.r(0.4, 0.08, 0.2, 0.08), const Color(0xFF8A6A4A), line: 0.4)
    ..line(a.p(0.38, 0.4), a.p(0.38, 0.8), const Color(0x99FFFFFF), width: 1.2);
}

/// The last jar: inside it, the keeper's own room, a candle in it.
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
    ..fade(
      a.r(0, 0.16, 1, 0.84),
      const Color(0xFF3A2A1E),
      const Color(0xFF1A120C),
    )
    ..glow(a.p(0.5, 0.56), w * 0.6, StillroomPalette.gaslight, strength: 0.5);
  // A small portrait in its oval, a candle under it.
  a.canvas
    ..save()
    ..translate(w * 0.32, h * 0.3);
  paintKeeperPortrait(Art(a.canvas, Size(w * 0.36, h * 0.36)));
  a.canvas.restore();
  a.flame(a.p(0.5, 0.86), h * 0.07);
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
  // The lid: linen tied over the mouth with a cord.
  a
    ..rbox(
      a.r(0.2, 0.06, 0.6, 0.12),
      a.u * 2,
      const Color(0xFFE6DCC8),
      line: 0.4,
    )
    ..line(a.p(0.2, 0.14), a.p(0.8, 0.14), const Color(0xFF8A2A22), width: 1);
}
