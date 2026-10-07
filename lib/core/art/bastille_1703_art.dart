import 'dart:math' as math;
import 'dart:ui';

import '../theme/stillroom_palette.dart';
import 'art_kit.dart';
import 'depth_kit.dart';
import 'echo_art.dart';
import 'whitechapel_1888_art.dart' show jarLabelBoard;

/// Code-drawn art for "Bastille, 1703" (docs/episodes/bastille_1703.md): a
/// fortress of grey limestone at dawn, 19–20 November 1703. Cold stone and
/// iron outside, candlelight and walnut in the officers' rooms.
const _s = 'images/scenes/bastille_1703';
const _o = 'images/objects/bastille_1703';
const _i = 'images/items/bastille_1703';

final Map<String, ArtPainter> bastilleArt = {
  // Scenes and puzzle boards.
  '$_s/courtyard.png': (c, s) => _courtyard(Art(c, s)),
  '$_s/junca_room.png': (c, s) => _juncaRoom(Art(c, s)),
  '$_s/governor_office.png': (c, s) => _governorOffice(Art(c, s)),
  '$_s/tower_stair.png': (c, s) => _towerStair(Art(c, s)),
  '$_s/cell.png': (c, s) => _cell(Art(c, s)),
  '$_s/saint_paul.png': (c, s) => _saintPaul(Art(c, s)),
  '$_s/lock_board.png': (c, s) => _lockBoard(Art(c, s)),
  '$_s/desk_board.png': (c, s) => _deskBoard(Art(c, s)),
  '$_s/label_close.png': (c, s) => jarLabelBoard(Art(c, s), _stoneDark),
  // Objects.
  '$_o/key_ring_sprite.png': (c, s) => _keyRingOnNail(Art(c, s)),
  '$_o/worksheet_sprite.png': (c, s) => _worksheet(Art(c, s)),
  '$_o/door_open_sprite.png': (c, s) => _doorOpen(Art(c, s)),
  '$_o/gate_open_sprite.png': (c, s) => _gateOpen(Art(c, s)),
  '$_o/echo_turnkey.png': (c, s) => paintEcho(Art(c, s), EchoFigure.turnkey),
  '$_o/echo_prisoner.png': (c, s) => paintEcho(Art(c, s), EchoFigure.prisoner),
  // Items.
  '$_i/key_ring.png': (c, s) => _keyRing(Art(c, s)),
  '$_i/worksheet.png': (c, s) => _worksheet(Art(c, s)),
  // The jar on the shelf.
  'images/ui/jar_bastille_1703.png': (c, s) => _jar(Art(c, s)),
};

// ---------------------------------------------------------------------------
// Palette

const _dawn = Color(0xFF6F7C8C);
const _dawnLow = Color(0xFFB8A490);
const _stone = Color(0xFF7A7468);
const _stoneLight = Color(0xFF928B7D);
const _stoneDark = Color(0xFF3E3A34);
const _cobble = Color(0xFF4B463F);
const _iron = Color(0xFF26282A);
const _ironLight = Color(0xFF55585A);
const _oak = Color(0xFF4A3524);
const _plaster = Color(0xFF8C7F6A);
const _velvet = Color(0xFF141114);
const _pencil = Color(0xFF5A5A62);

// ---------------------------------------------------------------------------
// Shared pieces

/// Coursed limestone blocks filling [rect].
void _masonry(Art a, Rect rect, {Color base = _stone, double rows = 9}) {
  a.fill(rect, base);
  final dark = Color.lerp(base, Art.outline, 0.35)!;
  final rowH = rect.height / rows;
  final random = math.Random(rect.left.round() + rect.top.round() * 7);
  for (var i = 0; i < rows; i++) {
    final y = rect.top + rowH * i;
    a.hairline(Offset(rect.left, y), Offset(rect.right, y), dark, 0.3);
    final blockW = rowH * 2.2;
    var x = rect.left + (i.isOdd ? blockW / 2 : 0);
    while (x < rect.right) {
      a.hairline(Offset(x, y), Offset(x, y + rowH), dark, 0.3);
      if (random.nextDouble() < 0.18) {
        a.fill(
          Rect.fromLTWH(x + 2, y + 2, blockW - 4, rowH - 4),
          Color.lerp(base, Art.outline, 0.08)!,
        );
      }
      x += blockW;
    }
  }
}

/// A round-headed doorway in a wall: stone frame and a plank door.
void _archDoor(
  Art a,
  Rect rect, {
  Color door = _oak,
  bool studs = false,
  bool shut = true,
}) {
  final w = rect.width;
  Path arch(Rect r) => Path()
    ..moveTo(r.left, r.bottom)
    ..lineTo(r.left, r.top + r.width / 2)
    ..arcToPoint(
      Offset(r.right, r.top + r.width / 2),
      radius: Radius.circular(r.width / 2),
    )
    ..lineTo(r.right, r.bottom)
    ..close();
  a.path(arch(rect), _stoneLight, line: 0.6);
  final inner = rect.deflate(w * 0.1);
  final leaf = Rect.fromLTRB(inner.left, inner.top, inner.right, rect.bottom);
  a.path(arch(leaf), shut ? door : StillroomPalette.ink, line: 0.5);
  if (!shut) return;
  a.canvas
    ..save()
    ..clipPath(arch(leaf));
  final dark = Color.lerp(door, Art.outline, 0.4)!;
  for (var i = 1; i < 4; i++) {
    final x = leaf.left + leaf.width * i / 4;
    a.hairline(Offset(x, leaf.top), Offset(x, leaf.bottom), dark, 0.3);
  }
  for (final t in [0.3, 0.75]) {
    final y = leaf.top + leaf.height * t;
    a.fill(Rect.fromLTWH(leaf.left, y, leaf.width, leaf.height * 0.035), _iron);
    if (studs) {
      for (var i = 0; i < 5; i++) {
        a.circle(
          Offset(
            leaf.left + leaf.width * (0.1 + i * 0.2),
            y + leaf.height * 0.017,
          ),
          w * 0.025,
          _ironLight,
          line: 0.2,
        );
      }
    }
  }
  a.canvas.restore();
  // Ring handle and keyhole.
  a
    ..circle(
      Offset(leaf.right - leaf.width * 0.2, leaf.top + leaf.height * 0.55),
      w * 0.05,
      _ironLight,
      line: 0.4,
    )
    ..fill(
      Rect.fromCenter(
        center: Offset(
          leaf.right - leaf.width * 0.2,
          leaf.top + leaf.height * 0.45,
        ),
        width: w * 0.03,
        height: w * 0.07,
      ),
      Art.outline,
    );
}

/// The rooms' camera: the eye a little above the middle, as in the cell.
const _roomEye = Offset(0.5, 0.26);

/// An interior in one-point perspective: plastered walls, a flagged floor
/// running back, a dark ceiling; [dado] panels the walls to waist height.
/// Returns its camera, for what stands in it.
Room _room(Art a, {Color wall = _plaster, Color? dado}) {
  final room = Room(a, vp: a.p(_roomEye.dx, _roomEye.dy), depth: 0.7);
  final back = room.back;
  a
    ..path(room.ceiling, const Color(0xFF26221C), line: 0)
    ..path(room.leftWall, Color.lerp(wall, Art.outline, 0.25)!, line: 0)
    ..path(room.rightWall, Color.lerp(wall, Art.outline, 0.15)!, line: 0)
    ..fade(back, Color.lerp(wall, Art.outline, 0.3)!, wall)
    ..path(room.floor, _stoneDark, line: 0);
  if (dado != null) {
    a.wood(
      Rect.fromPoints(room.at(0, 0.36, 1), room.at(1, 0, 1)),
      base: dado,
      vertical: true,
      grain: 12,
    );
    for (final x in [0.0, 1.0]) {
      a.path(
        a.poly([
          room.at(x, 0, 0),
          room.at(x, 0.36, 0),
          room.at(x, 0.36, 1),
          room.at(x, 0, 1),
        ]),
        Color.lerp(dado, Art.outline, 0.25)!,
        line: 0,
      );
      for (var k = 1; k < 8; k++) {
        a.hairline(
          room.at(x, 0, k / 8),
          room.at(x, 0.36, k / 8),
          const Color(0x55000000),
          0.4,
        );
      }
    }
  }
  room
    ..floorGrid(const Color(0x66141210), rows: 5, columns: 7, width: 0.35)
    ..shadeCorners(strength: 0.45)
    ..edges(const Color(0xAA1A1714));
  a.ink(back, width: 0.5);
  return room;
}

/// A small-paned window; [view] paints what is seen through it.
void _window(Art a, Rect rect, void Function(Rect glass) view, {Room? room}) {
  late final Rect glass;
  if (room == null) {
    a.box(rect, _stoneLight, line: 0.6);
    glass = rect.deflate(rect.width * 0.1);
  } else {
    // Deep in the wall: its reveal, lit on the side towards the light.
    room.recess(rect, _stoneLight);
    glass = Room.recessInner(rect);
  }
  view(glass);
  final bar = Color.lerp(_oak, Art.outline, 0.3)!;
  for (var i = 1; i < 3; i++) {
    final x = glass.left + glass.width * i / 3;
    a.hairline(Offset(x, glass.top), Offset(x, glass.bottom), bar, 0.5);
  }
  for (var i = 1; i < 4; i++) {
    final y = glass.top + glass.height * i / 4;
    a.hairline(Offset(glass.left, y), Offset(glass.right, y), bar, 0.5);
  }
  a.ink(glass, width: 0.5);
  final sill = Rect.fromLTWH(
    rect.left - rect.width * 0.06,
    rect.bottom,
    rect.width * 1.12,
    rect.height * 0.05,
  );
  if (room == null) {
    a.box(sill, _stoneLight, line: 0.5);
  } else {
    room.box(sill, _stoneLight, depth: 0.03, line: 0.5);
  }
}

/// Dawn over rooftops, seen through [glass].
void _dawnView(Art a, Rect glass) {
  a.canvas
    ..save()
    ..clipRect(glass);
  a.canvas.drawRect(
    glass,
    Paint()
      ..shader = Gradient.linear(glass.topCenter, glass.bottomCenter, [
        _dawn,
        _dawnLow,
      ]),
  );
  final roofs = Path()..moveTo(glass.left, glass.bottom);
  final random = math.Random(5);
  var x = glass.left;
  while (x < glass.right) {
    final w = glass.width * (0.15 + random.nextDouble() * 0.15);
    final h = glass.height * (0.2 + random.nextDouble() * 0.25);
    roofs
      ..lineTo(x, glass.bottom - h * 0.6)
      ..lineTo(x + w / 2, glass.bottom - h)
      ..lineTo(x + w, glass.bottom - h * 0.6);
    x += w;
  }
  roofs
    ..lineTo(glass.right, glass.bottom)
    ..close();
  a.canvas
    ..drawPath(roofs, Paint()..color = const Color(0xFF3A3C44))
    ..restore();
}

/// A closed book lying flat, spine towards the viewer.
void _book(Art a, Rect rect, Color cover, {String title = ''}) {
  a
    ..box(
      Rect.fromLTWH(
        rect.left,
        rect.top + rect.height * 0.55,
        rect.width,
        rect.height * 0.25,
      ),
      StillroomPalette.paper,
      line: 0.4,
    )
    ..rbox(
      Rect.fromLTWH(rect.left, rect.top, rect.width, rect.height * 0.6),
      rect.height * 0.08,
      cover,
      line: 0.5,
    )
    ..box(
      Rect.fromLTWH(
        rect.left,
        rect.top + rect.height * 0.75,
        rect.width,
        rect.height * 0.2,
      ),
      Color.lerp(cover, Art.outline, 0.3)!,
      line: 0.4,
    );
  if (title.isNotEmpty) {
    a.label(
      title,
      Offset(rect.center.dx, rect.top + rect.height * 0.3),
      rect.height * 0.28,
      StillroomPalette.brass,
    );
  }
}

/// An open bound book, pages covered in cursive.
void _openBook(Art a, Rect rect, {int seed = 1}) {
  final mid = rect.center.dx;
  a
    ..rbox(
      rect.inflate(rect.height * 0.05),
      rect.height * 0.06,
      const Color(0xFF3A2418),
      line: 0.5,
    )
    ..path(
      a.poly([
        rect.topLeft,
        Offset(mid, rect.top + rect.height * 0.06),
        Offset(mid, rect.bottom),
        rect.bottomLeft,
      ]),
      StillroomPalette.paper,
      line: 0.4,
    )
    ..path(
      a.poly([
        Offset(mid, rect.top + rect.height * 0.06),
        rect.topRight,
        rect.bottomRight,
        Offset(mid, rect.bottom),
      ]),
      StillroomPalette.paper,
      line: 0.4,
    )
    ..scrawl(
      Rect.fromLTRB(
        rect.left + rect.width * 0.05,
        rect.top + rect.height * 0.15,
        mid - rect.width * 0.04,
        rect.bottom - rect.height * 0.1,
      ),
      StillroomPalette.inkOnPaper.withValues(alpha: 0.7),
      lines: 5,
      seed: seed,
      width: 0.25,
    )
    ..scrawl(
      Rect.fromLTRB(
        mid + rect.width * 0.04,
        rect.top + rect.height * 0.15,
        rect.right - rect.width * 0.05,
        rect.bottom - rect.height * 0.35,
      ),
      StillroomPalette.inkOnPaper.withValues(alpha: 0.7),
      lines: 3,
      seed: seed + 1,
      width: 0.25,
    );
}

/// The prisoner's mask: black velvet, two eyeholes, ties at the sides.
void _mask(Art a, Rect rect) {
  final c = rect.center;
  final w = rect.width;
  final h = rect.height;
  final shape = Path()
    ..moveTo(c.dx - w * 0.36, c.dy - h * 0.3)
    ..quadraticBezierTo(c.dx, c.dy - h * 0.55, c.dx + w * 0.36, c.dy - h * 0.3)
    ..quadraticBezierTo(
      c.dx + w * 0.42,
      c.dy + h * 0.2,
      c.dx + w * 0.2,
      c.dy + h * 0.45,
    )
    ..quadraticBezierTo(c.dx, c.dy + h * 0.55, c.dx - w * 0.2, c.dy + h * 0.45)
    ..quadraticBezierTo(
      c.dx - w * 0.42,
      c.dy + h * 0.2,
      c.dx - w * 0.36,
      c.dy - h * 0.3,
    )
    ..close();
  // Ties.
  a
    ..strokePath(
      Path()
        ..moveTo(c.dx - w * 0.38, c.dy - h * 0.1)
        ..quadraticBezierTo(
          c.dx - w * 0.46,
          c.dy + h * 0.2,
          c.dx - w * 0.5,
          c.dy + h * 0.4,
        ),
      const Color(0xFF3A3530),
      width: 0.4,
    )
    ..strokePath(
      Path()
        ..moveTo(c.dx + w * 0.38, c.dy - h * 0.1)
        ..quadraticBezierTo(
          c.dx + w * 0.46,
          c.dy + h * 0.25,
          c.dx + w * 0.5,
          c.dy + h * 0.35,
        ),
      const Color(0xFF3A3530),
      width: 0.4,
    )
    ..path(shape, _velvet, line: 0.5);
  // A soft sheen on the velvet, so it reads as cloth, not a hole.
  a.canvas
    ..save()
    ..clipPath(shape);
  a
    ..glow(
      Offset(c.dx - w * 0.12, c.dy - h * 0.25),
      w * 0.35,
      const Color(0xFF5A5060),
      strength: 0.45,
    )
    ..hairline(
      Offset(c.dx, c.dy - h * 0.4),
      Offset(c.dx, c.dy + h * 0.5),
      const Color(0xFF2E2830),
      0.3,
    );
  a.canvas.restore();
  for (final dx in [-0.16, 0.16]) {
    a.oval(
      Rect.fromCenter(
        center: Offset(c.dx + w * dx, c.dy - h * 0.08),
        width: w * 0.16,
        height: h * 0.16,
      ),
      _oak,
      line: 0.4,
    );
  }
}

/// A folded letter with a red wax seal.
void _letter(Art a, Rect rect, {double angle = 0, bool numbers = false}) {
  a.paper(rect, lines: numbers ? 0 : 5, angle: angle);
  if (numbers) {
    a.canvas
      ..save()
      ..translate(rect.center.dx, rect.center.dy)
      ..rotate(angle);
    final random = math.Random(9);
    for (var row = 0; row < 4; row++) {
      final y = -rect.height * 0.3 + row * rect.height * 0.2;
      var x = -rect.width * 0.4;
      while (x < rect.width * 0.32) {
        final n = 10 + random.nextInt(500);
        a.script(
          '$n',
          Offset(x + rect.width * 0.06, y),
          rect.height * 0.14,
          StillroomPalette.inkOnPaper,
        );
        x += rect.width * (0.16 + random.nextDouble() * 0.04);
      }
    }
    a.canvas.restore();
  }
  a.circle(
    Offset(rect.left + rect.width * 0.82, rect.bottom - rect.height * 0.18),
    rect.height * 0.12,
    StillroomPalette.oxbloodBright,
    line: 0.3,
  );
}

// ---------------------------------------------------------------------------
// Scenes

void _courtyard(Art a) {
  final court = wallCamera(a, const Offset(0.5, 0.42), 0.8);
  // Dawn sky over the walls.
  a.fade(a.r(0, 0, 1, 0.45), _dawn, _dawnLow);
  // The towers along the far side of the court.
  for (final (x, w, top) in [
    (0.14, 0.12, 0.02),
    (0.33, 0.11, 0.05),
    (0.56, 0.11, 0.04),
    (0.8, 0.12, 0.01),
  ]) {
    final body = a.r(x, top + 0.04, w, 0.5);
    _masonry(a, body, base: _stoneLight, rows: 12);
    a
      ..fade(body, const Color(0x00000000), const Color(0x55000000))
      ..ink(body);
    // Crenellations.
    for (var i = 0; i < 4; i++) {
      a.box(
        a.r(x + w * (0.04 + i * 0.26), top, w * 0.16, 0.045),
        _stoneLight,
        line: 0.5,
      );
    }
    // Slit windows.
    for (final ty in [0.14, 0.28]) {
      a.fill(a.r(x + w * 0.46, top + ty, w * 0.08, 0.06), Art.outline);
    }
  }
  // The wall of the court behind the doors.
  final wall = a.r(0, 0.36, 1, 0.44);
  _masonry(a, wall, rows: 10);
  a.fade(wall, const Color(0x33000000), const Color(0x11000000));
  // Left: the base of the Bertaudière, round, with its door.
  final tower = a.r(0, 0.22, 0.22, 0.58);
  _masonry(a, tower, base: _stone, rows: 14);
  a
    ..fade(
      a.r(0, 0.22, 0.06, 0.58),
      const Color(0x66000000),
      const Color(0x44000000),
    )
    ..fade(
      a.r(0.17, 0.22, 0.05, 0.58),
      const Color(0x00000000),
      const Color(0x66000000),
    )
    ..ink(tower);
  _archDoor(a, a.r(0.08, 0.42, 0.12, 0.36), studs: true);
  // The nail by the tower door.
  a.circle(a.p(0.245, 0.47), a.u * 0.5, _iron, line: 0);
  // The King's lieutenant's lodging: a low door, a lit window above.
  _archDoor(a, a.r(0.38, 0.46, 0.09, 0.3), door: const Color(0xFF5A4030));
  _window(a, a.r(0.385, 0.38, 0.08, 0.07), (g) {
    a
      ..fill(g, const Color(0xFF3A2A1A))
      ..glow(g.center, g.width, StillroomPalette.gaslight, strength: 0.6);
  });
  // The governor's house: steps and a pediment.
  final gov = a.r(0.6, 0.44, 0.1, 0.32);
  a.path(
    a.poly([a.p(0.585, 0.44), a.p(0.65, 0.39), a.p(0.715, 0.44)]),
    _stoneLight,
  );
  _archDoor(a, gov, door: const Color(0xFF3A2A20), studs: true);
  for (var i = 0; i < 2; i++) {
    court.box(
      a.r(0.59 - i * 0.01, 0.76 + i * 0.02, 0.12 + i * 0.02, 0.02),
      _stoneLight,
      depth: 0.04,
      line: 0.4,
    );
  }
  // The gate to the street, barred.
  final gate = a.r(0.84, 0.36, 0.14, 0.46);
  _archDoor(a, gate, door: const Color(0xFF3E2C1E), studs: true);
  a.box(a.r(0.845, 0.58, 0.13, 0.03), _iron, line: 0.5);
  // The court: cobbles.
  final ground = a.r(0, 0.78, 1, 0.22);
  a.fade(ground, _cobble, const Color(0xFF2A2724));
  final random = math.Random(11);
  for (var i = 0; i < 80; i++) {
    final x = random.nextDouble();
    final y = 0.8 + random.nextDouble() * 0.19;
    a.canvas.drawOval(
      Rect.fromCenter(
        center: a.p(x, y),
        width: a.size.width * 0.025 * (0.6 + y),
        height: a.size.height * 0.012 * (0.6 + y),
      ),
      Paint()..color = const Color(0x33000000),
    );
  }
  court.wallFoot(strength: 0.35);
  // The cart and its box.
  _cart(a, court);
  // Morning mist in the court.
  a
    ..glow(a.p(0.5, 0.8), a.size.width * 0.4, _dawnLow, strength: 0.12)
    ..fade(a.r(0, 0, 1, 1), const Color(0x00000000), const Color(0x22000000));
}

void _cart(Art a, Room court) {
  court
    ..contactShadow(a.r(0.27, 0.835, 0.22, 0.03), strength: 0.5)
    // Box: plain boards, its lid seen from above.
    ..box(a.r(0.31, 0.7, 0.12, 0.06), const Color(0xFF7A6448), depth: 0.06);
  a.wood(a.r(0.31, 0.7, 0.12, 0.06), base: const Color(0xFF7A6448), grain: 2);
  court.box(a.r(0.28, 0.76, 0.18, 0.035), _oak, depth: 0.08);
  a.wood(a.r(0.28, 0.76, 0.18, 0.035), base: _oak, grain: 1);
  // Wheel.
  final hub = a.p(0.33, 0.81);
  final r = a.size.height * 0.05;
  a.circle(hub, r, const Color(0x00000000), line: 1.2);
  for (var i = 0; i < 8; i++) {
    final t = i * math.pi / 4;
    a.line(
      hub,
      hub + Offset(math.cos(t) * r, math.sin(t) * r),
      Art.outline,
      width: 0.5,
    );
  }
  a
    ..circle(hub, r * 0.2, _oak, line: 0.4)
    // Shafts, resting on the ground.
    ..line(a.p(0.44, 0.78), a.p(0.47, 0.85), Art.outline, width: 1.2);
}

void _juncaRoom(Art a) {
  final room = _room(a, wall: const Color(0xFF8A7A62));
  // Window on the court, deep in the wall, its light across the floor.
  final win = a.r(0.17, 0.16, 0.15, 0.3);
  _window(a, win, (g) => _dawnView(a, g), room: room);
  room.beam(
    [win.bottomLeft, win.bottomRight],
    [
      room.floorAt(0.18, 0.55),
      room.floorAt(0.4, 0.55),
      room.floorAt(0.36, 0.15),
      room.floorAt(0.08, 0.15),
    ],
    _dawnLow,
    strength: 0.12,
  );
  // Shelf on the back wall, with ledgers; the worksheet lies at its end.
  room
    ..box(a.r(0.6, 0.44, 0.24, 0.02), _oak, depth: 0.05, line: 0.4)
    ..box(a.r(0.62, 0.46, 0.012, 0.035), _oak, depth: 0.03, line: 0.3)
    ..box(a.r(0.81, 0.46, 0.012, 0.035), _oak, depth: 0.03, line: 0.3);
  for (final (x, h, color) in [
    (0.61, 0.12, const Color(0xFF4A2A1E)),
    (0.63, 0.13, const Color(0xFF2E3A2A)),
    (0.65, 0.11, const Color(0xFF5A3A22)),
  ]) {
    a.box(a.r(x, 0.44 - h, 0.018, h), color, line: 0.4);
  }
  a
    ..box(a.r(0.8, 0.32, 0.018, 0.12), const Color(0xFF3A2A1E), line: 0.4)
    ..box(a.r(0.822, 0.34, 0.018, 0.10), const Color(0xFF4A3A2A), line: 0.4);
  // Desk, the journal open on it, the candle burned down.
  room.standTable(
    a.r(0.26, 0.64, 0.46, 0.26),
    _oak,
    deep: 0.3,
    thickness: 0.03,
    leg: 0.02,
    legColor: Color.lerp(_oak, Art.outline, 0.3),
  );
  _openBook(a, a.r(0.35, 0.54, 0.2, 0.09), seed: 17);
  // Quill and inkwell.
  a
    ..box(a.r(0.57, 0.6, 0.02, 0.03), _iron, line: 0.4)
    ..path(
      a.poly([a.p(0.578, 0.6), a.p(0.598, 0.53), a.p(0.604, 0.535)]),
      const Color(0xFFE0D8C8),
      line: 0.3,
    );
  // The candle, burned down to a stub on a tall brass stick.
  a
    ..oval(a.r(0.6, 0.615, 0.05, 0.02), StillroomPalette.brass, line: 0.4)
    ..box(a.r(0.621, 0.51, 0.008, 0.11), StillroomPalette.brass, line: 0.4)
    ..oval(a.r(0.607, 0.5, 0.036, 0.015), StillroomPalette.brass, line: 0.4)
    ..box(a.r(0.617, 0.48, 0.016, 0.022), const Color(0xFFE6DCC4), line: 0.4)
    ..fill(a.r(0.614, 0.495, 0.022, 0.008), const Color(0xFFD4C8AC))
    ..line(a.p(0.625, 0.48), a.p(0.626, 0.47), Art.outline, width: 0.4)
    // A thread of smoke.
    ..strokePath(
      Path()
        ..moveTo(a.p(0.626, 0.47).dx, a.p(0.626, 0.47).dy)
        ..cubicTo(
          a.p(0.61, 0.45).dx,
          a.p(0.61, 0.45).dy,
          a.p(0.64, 0.43).dx,
          a.p(0.64, 0.43).dy,
          a.p(0.625, 0.39).dx,
          a.p(0.625, 0.39).dy,
        ),
      const Color(0x66D5DEE2),
      width: 0.4,
    );
}

void _governorOffice(Art a) {
  final room = _room(
    a,
    wall: const Color(0xFF6E5A48),
    dado: const Color(0xFF3A2A1E),
  );
  // The fireplace, cold, its breast standing out from the wall.
  room
    ..box(a.r(0.17, 0.42, 0.14, 0.36), _stoneLight, depth: 0.05, line: 0.6)
    ..box(a.r(0.155, 0.39, 0.17, 0.035), _stoneLight, depth: 0.07, line: 0.6);
  a.box(a.r(0.19, 0.49, 0.1, 0.29), const Color(0xFF15120F), line: 0.5);
  // Grey ashes and a charred log.
  a
    ..oval(a.r(0.197, 0.745, 0.085, 0.03), const Color(0xFF6A6560), line: 0.3)
    ..rbox(
      a.r(0.205, 0.728, 0.07, 0.022),
      a.u,
      const Color(0xFF221C18),
      line: 0.3,
    );
  // Window with dawn.
  _window(a, a.r(0.68, 0.12, 0.13, 0.3), (g) => _dawnView(a, g), room: room);
  // A map of the kingdom on the wall.
  final map = a.r(0.36, 0.14, 0.24, 0.2);
  a
    ..box(map.inflate(a.u * 0.8), StillroomPalette.brass, line: 0.5)
    ..box(map, const Color(0xFFCDBB94), line: 0.4)
    ..strokePath(
      Path()..addPolygon([
        a.p(0.42, 0.17),
        a.p(0.5, 0.16),
        a.p(0.55, 0.2),
        a.p(0.54, 0.29),
        a.p(0.47, 0.31),
        a.p(0.4, 0.28),
        a.p(0.39, 0.21),
      ], true),
      const Color(0xFF6A5A3A),
      width: 0.5,
    )
    ..circle(a.p(0.48, 0.2), a.u * 0.6, StillroomPalette.oxblood, line: 0);
  // The desk.
  room.standTable(
    a.r(0.24, 0.62, 0.56, 0.28),
    const Color(0xFF3A2418),
    deep: 0.3,
    thickness: 0.035,
    leg: 0.022,
    legColor: const Color(0xFF2A1A10),
  );
  // Green leather inlay suggested by a band along the front.
  a.fill(a.r(0.25, 0.625, 0.54, 0.012), const Color(0xFF2E3A2A));
  // The letter of 1669, sealed.
  _letter(a, a.r(0.29, 0.535, 0.12, 0.08), angle: -0.04);
  // The letter of 1691, all numbers.
  _letter(a, a.r(0.47, 0.535, 0.11, 0.08), angle: 0.03, numbers: true);
  // The prisoner's file: a folder tied with ribbon.
  final file = a.r(0.63, 0.53, 0.12, 0.08);
  a
    ..paper(file.shift(Offset(a.u * 0.6, -a.u * 0.6)), lines: 0)
    ..box(file, const Color(0xFF9A8058), line: 0.5)
    ..box(
      Rect.fromLTWH(
        file.center.dx - a.u * 0.4,
        file.top,
        a.u * 0.8,
        file.height,
      ),
      StillroomPalette.oxblood,
      line: 0,
    )
    ..label(
      'B',
      file.center.translate(file.width * 0.25, 0),
      file.height * 0.4,
      StillroomPalette.inkOnPaper,
    );
  // Candlestick, out.
  a.candle(a.p(0.77, 0.6), a.size.height * 0.12);
}

void _towerStair(Art a) {
  // Curving stone walls inside the round tower.
  _masonry(a, a.r(0, 0, 1, 1), base: _stoneDark, rows: 18);
  a
    ..fade(a.r(0, 0, 0.3, 1), const Color(0x88000000), const Color(0x44000000))
    ..fade(
      a.r(0.7, 0, 0.3, 1),
      const Color(0x22000000),
      const Color(0x88000000),
    );
  // The newel: the stair's stone core, and the steps winding up to the
  // right, each tread showing, the far ones first.
  final eye = Room(a, vp: a.p(0.45, 0.36), depth: 0.5);
  a.box(a.r(0.34, 0, 0.04, 1), const Color(0xFF4A453E), line: 0.6);
  for (var i = 11; i >= 0; i--) {
    final t = i / 11;
    final y = 0.92 - t * 0.48;
    final x0 = 0.38 + t * 0.2;
    final w = 0.3 - t * 0.08;
    final step = a.r(x0, y, w, 0.035);
    eye.box(step, Color.lerp(_stone, _stoneDark, t)!, depth: 0.06, line: 0.5);
    // The hollow worn in the middle of each step.
    a.oval(
      Rect.fromCenter(
        center: step.center.translate(-step.width * 0.1, -step.height * 0.2),
        width: step.width * 0.35,
        height: step.height * 0.5,
      ),
      const Color(0x33000000),
      line: 0,
    );
  }
  // The landing below the lower door.
  eye.box(a.r(0, 0.78, 0.36, 0.22), _stone, depth: 0.1, line: 0.6);
  // The lower door, heavy and iron-bound.
  _archDoor(
    a,
    a.r(0.18, 0.3, 0.15, 0.46),
    studs: true,
    door: const Color(0xFF3E2C1E),
  );
  // The upper door, up the stair.
  eye.box(a.r(0.58, 0.4, 0.22, 0.04), _stone, depth: 0.08, line: 0.5);
  _archDoor(
    a,
    a.r(0.62, 0.06, 0.13, 0.36),
    studs: true,
    door: const Color(0xFF34261A),
  );
  // A lantern bracket on the wall.
  a
    ..line(a.p(0.47, 0.18), a.p(0.5, 0.18), _iron, width: 0.8)
    ..box(a.r(0.49, 0.18, 0.025, 0.05), _iron, line: 0.4)
    ..glow(
      a.p(0.502, 0.205),
      a.size.width * 0.12,
      StillroomPalette.gaslight,
      strength: 0.4,
    )
    ..box(a.r(0.494, 0.19, 0.015, 0.03), const Color(0xFFF1C66A), line: 0);
  // An arrow slit with a thread of dawn.
  a
    ..fill(a.r(0.88, 0.22, 0.02, 0.14), const Color(0xFF8A96A4))
    ..ink(a.r(0.88, 0.22, 0.02, 0.14));
}

void _cell(Art a) {
  // A stone cell seen from its door, from a little above: the back wall
  // with the high window, side walls and a flagged floor running back to
  // it, and what stands in it standing on that floor.
  final room = Room(a, vp: a.p(0.5, 0.26), depth: 0.55);
  final back = room.back;
  a
    ..path(room.ceiling, const Color(0xFF3A3630), line: 0)
    ..path(room.leftWall, const Color(0xFF5E5A50), line: 0)
    ..path(room.rightWall, const Color(0xFF686458), line: 0)
    ..path(room.floor, const Color(0xFF3E3A34), line: 0);
  // The side walls' courses, running back to the vanishing point.
  for (var k = 1; k < 12; k++) {
    final y = k / 12;
    a
      ..hairline(
        room.at(0, y, 0),
        room.at(0, y, 1),
        const Color(0x55241F1A),
        0.3,
      )
      ..hairline(
        room.at(1, y, 0),
        room.at(1, y, 1),
        const Color(0x55241F1A),
        0.3,
      );
  }
  _masonry(a, back, base: const Color(0xFF6E6A60), rows: 10);
  room
    ..floorGrid(const Color(0x66141210), rows: 6, columns: 7, width: 0.35)
    ..shadeCorners(strength: 0.5)
    ..edges(const Color(0xAA1A1714));
  a.ink(back, width: 0.5);
  // A scraped patch on the right wall, in the wall's own slant.
  a.path(
    a.poly([
      room.at(1, 0.68, 0.25),
      room.at(1, 0.68, 0.5),
      room.at(1, 0.42, 0.5),
      room.at(1, 0.42, 0.25),
    ]),
    const Color(0x22D8D0C0),
    line: 0,
  );

  // The high window, deep in the wall, barred, dawn behind; its light
  // falling across the floor to the table.
  final win = Rect.fromPoints(room.at(0.42, 0.9, 1), room.at(0.58, 0.55, 1));
  final glass = Room.recessInner(win, thickness: 0.05);
  room.recess(win, const Color(0xFF6E6A60), thickness: 0.05);
  _dawnView(a, glass);
  a.ink(glass, width: 0.4);
  for (var i = 1; i < 4; i++) {
    final x = glass.left + glass.width * i / 4;
    a.line(Offset(x, glass.top), Offset(x, glass.bottom), _iron, width: 1);
  }
  a.line(
    Offset(glass.left, glass.center.dy),
    Offset(glass.right, glass.center.dy),
    _iron,
    width: 1,
  );
  room.beam(
    [glass.bottomLeft, glass.bottomRight],
    [
      room.floorAt(0.36, 0.5),
      room.floorAt(0.64, 0.5),
      room.floorAt(0.7, 0.2),
      room.floorAt(0.3, 0.2),
    ],
    _dawnLow,
    strength: 0.14,
  );
  a.glow(glass.center, a.size.width * 0.14, _dawnLow, strength: 0.16);

  // A deep embrasure on the right of the back wall, its sill wide enough
  // for a book.
  final niche = Rect.fromPoints(room.at(0.78, 0.58, 1), room.at(0.94, 0.4, 1));
  room.recess(niche, const Color(0xFF6E6A60), thickness: 0.06);
  a.fill(Room.recessInner(niche, thickness: 0.06), const Color(0xFF2A2622));
  room.block(0.77, 0.95, 0.37, 0.4, 0.94, 1, _stoneLight);
  final sill = room.at(0.86, 0.4, 0.97);
  _book(
    a,
    Rect.fromCenter(
      center: sill.translate(0, -a.u * 1.1),
      width: a.size.width * 0.06,
      height: a.u * 2.6,
    ),
    const Color(0xFF6A2A20),
  );

  // The table under the window, and on it the mask.
  final top = room.table(0.38, 0.62, 0.55, 0.8, 0.27, _oak, leg: 0.016);
  _mask(
    a,
    Rect.fromCenter(
      center: room.at(0.5, 0.27, 0.66).translate(0, -a.u * 1.6),
      width: top.width * 0.5,
      height: a.u * 6,
    ),
  );

  // The stripped bed on the left, against the wall: planks on trestles, a
  // bare straw pallet.
  room
    ..table(0.02, 0.32, 0.15, 0.6, 0.15, _oak, thickness: 0.03, leg: 0.022)
    ..block(0.035, 0.305, 0.15, 0.18, 0.17, 0.58, const Color(0xFFA08A5A));
  final random = math.Random(4);
  for (var i = 0; i < 18; i++) {
    final p = room.at(
      0.05 + random.nextDouble() * 0.24,
      0.18,
      0.2 + random.nextDouble() * 0.36,
    );
    a.hairline(
      p,
      p.translate(a.u * 1.4, a.u * 0.3),
      const Color(0xFF6A5A38),
      0.3,
    );
  }

  // A stool, nearer, on the right.
  room.table(0.64, 0.73, 0.2, 0.3, 0.16, _oak, thickness: 0.025, leg: 0.014);

  // Where a bucket stood, a ring on the floor.
  final ring = room.floorAt(0.88, 0.22);
  a.oval(
    Rect.fromCenter(
      center: ring,
      width: a.size.width * 0.07,
      height: a.size.height * 0.025,
    ),
    const Color(0x33000000),
    line: 0,
  );
}

void _saintPaul(Art a) {
  final room = _room(a, wall: const Color(0xFF7E7666));
  // A pointed window on the churchyard: a fresh grave in grey light.
  final win = a.r(0.17, 0.12, 0.15, 0.38);
  room.box(
    Rect.fromLTWH(
      win.left - win.width * 0.06,
      win.bottom,
      win.width * 1.12,
      win.height * 0.04,
    ),
    _stoneLight,
    depth: 0.03,
    line: 0.5,
  );
  final arch = Path()
    ..moveTo(win.left, win.bottom)
    ..lineTo(win.left, win.top + win.height * 0.3)
    ..quadraticBezierTo(win.left, win.top, win.center.dx, win.top)
    ..quadraticBezierTo(
      win.right,
      win.top,
      win.right,
      win.top + win.height * 0.3,
    )
    ..lineTo(win.right, win.bottom)
    ..close();
  a.path(arch, _stoneLight, line: 0.6);
  final glass = win.deflate(win.width * 0.1);
  a.canvas
    ..save()
    ..clipPath(
      Path()
        ..moveTo(glass.left, glass.bottom)
        ..lineTo(glass.left, glass.top + glass.height * 0.3)
        ..quadraticBezierTo(glass.left, glass.top, glass.center.dx, glass.top)
        ..quadraticBezierTo(
          glass.right,
          glass.top,
          glass.right,
          glass.top + glass.height * 0.3,
        )
        ..lineTo(glass.right, glass.bottom)
        ..close(),
    );
  a
    ..fade(glass, _dawn, _dawnLow)
    ..fill(
      Rect.fromLTRB(
        glass.left,
        glass.top + glass.height * 0.62,
        glass.right,
        glass.bottom,
      ),
      const Color(0xFF3E4238),
    )
    // Old headstones, and a mound of fresh earth.
    ..rbox(
      Rect.fromLTWH(
        glass.left + glass.width * 0.1,
        glass.top + glass.height * 0.5,
        glass.width * 0.14,
        glass.height * 0.14,
      ),
      a.u,
      const Color(0xFF8A887E),
      line: 0.3,
    )
    ..rbox(
      Rect.fromLTWH(
        glass.left + glass.width * 0.72,
        glass.top + glass.height * 0.52,
        glass.width * 0.12,
        glass.height * 0.12,
      ),
      a.u,
      const Color(0xFF8A887E),
      line: 0.3,
    )
    ..oval(
      Rect.fromLTWH(
        glass.left + glass.width * 0.3,
        glass.top + glass.height * 0.72,
        glass.width * 0.4,
        glass.height * 0.1,
      ),
      const Color(0xFF5A4432),
      line: 0.3,
    )
    ..fill(
      Rect.fromLTWH(
        glass.left + glass.width * 0.34,
        glass.top + glass.height * 0.8,
        glass.width * 0.32,
        glass.height * 0.06,
      ),
      Art.outline,
    );
  a.canvas.restore();
  for (var i = 1; i < 3; i++) {
    final x = glass.left + glass.width * i / 3;
    a.hairline(Offset(x, glass.top), Offset(x, glass.bottom), _iron, 0.5);
  }
  // A vestment press standing against the back wall.
  final press = room.stand(
    a.r(0.34, 0.2, 0.2, 0.6),
    const Color(0xFF3A2A1E),
    deep: 0.12,
  );
  a
    ..wood(press, base: const Color(0xFF3A2A1E), vertical: true, grain: 3)
    ..hairline(press.topCenter, press.bottomCenter, Art.outline, 0.6);
  // The clerk's lectern, the register open on it: a foot, a post, and the
  // sloping desk.
  room
    ..stand(a.r(0.42, 0.865, 0.14, 0.02), _oak, deep: 0.1)
    ..stand(a.r(0.465, 0.66, 0.05, 0.205), _oak, deep: 0.04, shadow: false);
  a
    ..path(
      a.poly([
        a.p(0.36, 0.66),
        a.p(0.62, 0.66),
        a.p(0.6, 0.62),
        a.p(0.38, 0.62),
      ]),
      _oak,
    )
    ..box(
      a.r(0.36, 0.66, 0.26, 0.012),
      Color.lerp(_oak, Art.outline, 0.3)!,
      line: 0.4,
    );
  _openBook(a, a.r(0.39, 0.53, 0.2, 0.1), seed: 23);
  // Quill in its pot.
  a
    ..box(a.r(0.58, 0.6, 0.02, 0.025), _iron, line: 0.3)
    ..line(
      a.p(0.59, 0.6),
      a.p(0.61, 0.52),
      const Color(0xFFE0D8C8),
      width: 0.6,
    );
  // A stand of candles for the dead.
  room
    ..stand(a.r(0.65, 0.8, 0.06, 0.014), _iron, deep: 0.04)
    ..stand(a.r(0.675, 0.46, 0.01, 0.34), _iron, deep: 0.01, shadow: false);
  a.box(a.r(0.64, 0.45, 0.08, 0.012), _iron, line: 0.4);
  for (final x in [0.65, 0.67, 0.69, 0.71]) {
    a.candle(a.p(x, 0.452), a.size.height * 0.1, lit: true);
  }
  // A pew on the right, nearer: its back, the seat, the end board, a book
  // left on it.
  room
    ..shadow(0.64, 0.99, 0.28, 0.43)
    ..block(0.64, 0.97, 0.17, 0.34, 0.4, 0.425, _oak)
    ..table(
      0.64,
      0.97,
      0.28,
      0.4,
      0.17,
      _oak,
      thickness: 0.03,
      leg: 0.02,
      shadow: false,
    )
    ..block(0.97, 0.99, 0, 0.36, 0.27, 0.43, _oak);
  _book(
    a,
    Rect.fromCenter(
      center: room.at(0.8, 0.17, 0.33).translate(0, -a.u * 1.6),
      width: a.size.width * 0.07,
      height: a.size.height * 0.045,
    ),
    const Color(0xFF2A3A5A),
  );
}

void _lockBoard(Art a) {
  // Close on the door: iron-bound oak, lit by a lantern.
  a.wood(
    Offset.zero & a.size,
    base: const Color(0xFF2E2016),
    vertical: true,
    grain: 9,
    line: 0,
  );
  for (final y in [0.12, 0.86]) {
    a.fill(a.r(0, y, 1, 0.06), _iron);
    for (var i = 0; i < 12; i++) {
      a.circle(
        a.p(0.04 + i * 0.085, y + 0.03),
        a.u * 0.9,
        _ironLight,
        line: 0.2,
      );
    }
  }
  a
    ..glow(
      a.p(0.3, 0.4),
      a.size.width * 0.5,
      StillroomPalette.gaslight,
      strength: 0.15,
    )
    ..fade(a.r(0, 0, 1, 1), const Color(0x22000000), const Color(0x88000000));
}

void _deskBoard(Art a) {
  // The governor's desk from above: walnut, a green leather inlay.
  a
    ..wood(
      Offset.zero & a.size,
      base: const Color(0xFF3A2418),
      grain: 7,
      line: 0,
    )
    ..rbox(
      a.r(0.04, 0.06, 0.92, 0.88),
      a.u,
      const Color(0xFF26302A),
      line: 0.6,
    );
  a.canvas.drawRRect(
    RRect.fromRectAndRadius(a.r(0.055, 0.08, 0.89, 0.84), Radius.circular(a.u)),
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = a.u * 0.3
      ..color = StillroomPalette.brass.withValues(alpha: 0.5),
  );
  a
    ..glow(
      a.p(0.5, 0.4),
      a.size.width * 0.6,
      StillroomPalette.gaslight,
      strength: 0.1,
    )
    ..fade(a.r(0, 0, 1, 1), const Color(0x00000000), const Color(0x66000000));
}

// ---------------------------------------------------------------------------
// Objects and items

/// A key with a round bow, a plain shaft and a toothed bit.
void _oneKey(Art a, Offset bow, double angle, double len, Color color) {
  a.canvas
    ..save()
    ..translate(bow.dx, bow.dy)
    ..rotate(angle);
  final r = len * 0.14;
  a
    ..circle(Offset.zero, r, color, line: 0.5)
    ..circle(Offset.zero, r * 0.45, const Color(0xFF1A1612), line: 0.3)
    ..box(
      Rect.fromLTWH(-len * 0.025, r, len * 0.05, len * 0.72),
      color,
      line: 0.4,
    )
    ..path(
      a.poly([
        Offset(len * 0.025, len * 0.72),
        Offset(len * 0.16, len * 0.72),
        Offset(len * 0.16, len * 0.78),
        Offset(len * 0.1, len * 0.78),
        Offset(len * 0.1, len * 0.83),
        Offset(len * 0.18, len * 0.83),
        Offset(len * 0.18, len * 0.9),
        Offset(len * 0.025, len * 0.9),
      ]),
      color,
      line: 0.4,
    );
  a.canvas.restore();
}

/// The ring of keys, loose (the item).
void _keyRing(Art a) {
  final c = a.p(0.5, 0.3);
  final r = a.size.shortestSide * 0.18;
  a.canvas.drawCircle(
    c,
    r,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = a.u * 3.2
      ..color = Art.outline,
  );
  a.canvas.drawCircle(
    c,
    r,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = a.u * 2
      ..color = _ironLight,
  );
  final len = a.size.shortestSide * 0.6;
  for (final (t, color) in [
    (-0.5, const Color(0xFF6A6C6E)),
    (-0.15, const Color(0xFF8A7A5A)),
    (0.2, const Color(0xFF5E6062)),
    (0.55, const Color(0xFF7A6A4A)),
  ]) {
    final at = c + Offset(math.sin(t) * r, math.cos(t) * r);
    _oneKey(a, at, -t * 0.6, len, color);
  }
}

/// The ring hanging on its nail (the sprite in the court).
void _keyRingOnNail(Art a) {
  final top = a.p(0.5, 0.06);
  final r = a.size.width * 0.22;
  final c = top + Offset(0, r);
  a
    ..circle(top, a.size.width * 0.06, _iron, line: 0.3)
    ..canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = a.size.width * 0.08
        ..color = _ironLight,
    );
  final len = a.size.height * 0.6;
  for (final (t, color) in [
    (-0.4, const Color(0xFF6A6C6E)),
    (0.0, const Color(0xFF8A7A5A)),
    (0.4, const Color(0xFF5E6062)),
  ]) {
    final at = c + Offset(math.sin(t) * r, math.cos(t) * r);
    _oneKey(a, at, -t * 0.4, len, color);
  }
}

/// Bazeries's worksheet: pencilled columns of numbers and syllables.
void _worksheet(Art a) {
  final sheet = a.r(0.08, 0.06, 0.84, 0.88);
  a.box(sheet, const Color(0xFFE8E4D8), line: 0.5);
  final random = math.Random(3);
  for (var col = 0; col < 2; col++) {
    for (var row = 0; row < 5; row++) {
      final y = sheet.top + sheet.height * (0.14 + row * 0.17);
      final x = sheet.left + sheet.width * (0.1 + col * 0.46);
      a
        ..hairline(
          Offset(x, y),
          Offset(x + sheet.width * 0.14, y),
          _pencil,
          0.6,
        )
        ..hairline(
          Offset(x + sheet.width * 0.2, y),
          Offset(x + sheet.width * (0.28 + random.nextDouble() * 0.06), y),
          StillroomPalette.oxblood,
          0.6,
        );
    }
  }
  a.hairline(
    Offset(sheet.center.dx, sheet.top + sheet.height * 0.06),
    Offset(sheet.center.dx, sheet.bottom - sheet.height * 0.06),
    _pencil,
    0.3,
  );
}

/// A doorway standing open: darkness beyond, the leaf swung in.
void _doorOpen(Art a) {
  final w = a.size.width;
  final h = a.size.height;
  final frame = Offset.zero & a.size;
  final inner = frame.deflate(w * 0.1);
  final hole = Path()
    ..moveTo(inner.left, h)
    ..lineTo(inner.left, inner.top + inner.width / 2)
    ..arcToPoint(
      Offset(inner.right, inner.top + inner.width / 2),
      radius: Radius.circular(inner.width / 2),
    )
    ..lineTo(inner.right, h)
    ..close();
  a.path(hole, const Color(0xFF0C0A08), line: 0.5);
  a.canvas
    ..save()
    ..clipPath(hole);
  a
    ..glow(Offset(inner.center.dx, h * 0.7), w * 0.5, _dawnLow, strength: 0.18)
    // The leaf, swung inward and seen edge-on.
    ..box(
      Rect.fromLTWH(
        inner.left,
        inner.top + inner.width * 0.3,
        inner.width * 0.18,
        h,
      ),
      const Color(0xFF3E2C1E),
      line: 0.5,
    );
  a.canvas.restore();
}

/// The street gate open: the leaves back, the parish beyond.
void _gateOpen(Art a) {
  final w = a.size.width;
  final h = a.size.height;
  final inner = (Offset.zero & a.size).deflate(w * 0.1);
  final hole = Path()
    ..moveTo(inner.left, h)
    ..lineTo(inner.left, inner.top + inner.width / 2)
    ..arcToPoint(
      Offset(inner.right, inner.top + inner.width / 2),
      radius: Radius.circular(inner.width / 2),
    )
    ..lineTo(inner.right, h)
    ..close();
  a.canvas
    ..save()
    ..clipPath(hole);
  _dawnView(a, inner);
  a
    ..fill(Rect.fromLTRB(inner.left, h * 0.8, inner.right, h), _cobble)
    // The church of Saint-Paul: a spire over the roofs.
    ..path(
      a.poly([a.p(0.55, 0.36), a.p(0.6, 0.18), a.p(0.65, 0.36)]),
      const Color(0xFF3A3C44),
      line: 0.3,
    )
    ..box(a.r(0.53, 0.36, 0.14, 0.26), const Color(0xFF3A3C44), line: 0.3);
  a.canvas.restore();
  // The leaves, folded back against the jambs.
  a
    ..box(
      Rect.fromLTWH(inner.left, inner.top + inner.width * 0.4, w * 0.08, h),
      const Color(0xFF3E2C1E),
      line: 0.5,
    )
    ..box(
      Rect.fromLTWH(
        inner.right - w * 0.08,
        inner.top + inner.width * 0.4,
        w * 0.08,
        h,
      ),
      const Color(0xFF3E2C1E),
      line: 0.5,
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
  // Inside: a barred window at dawn, and the velvet mask before it.
  a
    ..fade(a.r(0, 0.16, 1, 0.84), _stoneDark, const Color(0xFF1C1A17))
    ..fill(a.r(0.34, 0.26, 0.32, 0.3), _dawnLow);
  for (var i = 1; i < 4; i++) {
    a.line(
      a.p(0.34 + 0.08 * i, 0.26),
      a.p(0.34 + 0.08 * i, 0.56),
      _iron,
      width: 1.4,
    );
  }
  _mask(a, a.r(0.26, 0.56, 0.48, 0.3));
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
  // Cork, sealed in red wax.
  a
    ..box(a.r(0.3, 0.04, 0.4, 0.14), const Color(0xFF7A5A3A), line: 0.5)
    ..circle(
      a.p(0.5, 0.11),
      w * 0.06,
      StillroomPalette.oxbloodBright,
      line: 0.3,
    );
}
