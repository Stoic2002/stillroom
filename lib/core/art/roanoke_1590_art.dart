import 'dart:math' as math;
import 'dart:ui';

import '../theme/stillroom_palette.dart';
import 'art_kit.dart';
import 'depth_kit.dart';
import 'echo_art.dart';
import 'whitechapel_1888_art.dart' show jarLabelBoard;

/// Code-drawn art for "Roanoke, 1590" (docs/episodes/roanoke_1590.md):
/// the north end of Roanoke Island at dawn on 18 August 1590, when John
/// White's men came ashore. The shore with the boat and the smouldering
/// grass, the hill with CRO on a tree, the empty fort and its carved post,
/// the dug-up chests, and the cabin of the ship. Each scene from one
/// camera (`depth_kit.dart`). No colonist, no White, no Croatoan person is
/// drawn.
const _s = 'images/scenes/roanoke_1590';
const _o = 'images/objects/roanoke_1590';

final Map<String, ArtPainter> roanoke1590Art = {
  // Scenes and puzzle boards.
  '$_s/shore.png': (c, s) => _shore(Art(c, s)),
  '$_s/hill.png': (c, s) => _hill(Art(c, s)),
  '$_s/fort.png': (c, s) => _fort(Art(c, s)),
  '$_s/chests.png': (c, s) => _chests(Art(c, s)),
  '$_s/ship.png': (c, s) => _ship(Art(c, s)),
  '$_s/rings_board.png': (c, s) => _tableBoard(Art(c, s), lamp: 0.16),
  '$_s/dividers_board.png': (c, s) => _tableBoard(Art(c, s), lamp: 0.22),
  '$_s/label_close.png': (c, s) => jarLabelBoard(Art(c, s), _palisade),
  // Objects.
  '$_o/chart_sprite.png': (c, s) => _chartOnTable(Art(c, s)),
  '$_o/core_sprite.png': (c, s) => _coreOnTable(Art(c, s)),
  '$_o/hatteras_sprite.png': (c, s) => _papers(Art(c, s), 2),
  '$_o/later_sprite.png': (c, s) => _papers(Art(c, s), 3),
  '$_o/echo_trumpeter.png': (c, s) =>
      paintEcho(Art(c, s), EchoFigure.trumpeter),
  '$_o/echo_shoveller.png': (c, s) =>
      paintEcho(Art(c, s), EchoFigure.shoveller),
  // The jar on the shelf.
  'images/ui/jar_roanoke_1590.png': (c, s) => _jar(Art(c, s)),
};

// ---------------------------------------------------------------------------
// Palette

const _skyHigh = Color(0xFF7E8EA6);
const _skyLow = Color(0xFFF0C8A0);
const _sun = Color(0xFFFFD8A0);
const _water = Color(0xFF6A808E);
const _waterFar = Color(0xFF9AA8B0);
const _sand = Color(0xFFD6C49C);
const _sandWet = Color(0xFFB4A27E);
const _grass = Color(0xFF7A8450);
const _bark = Color(0xFF4A3E32);
const _leaves = Color(0xFF3E5236);
const _leavesLight = Color(0xFF5A6E44);
const _palisade = Color(0xFF6A5640);
const _stripped = Color(0xFFD8C49A);
const _iron = Color(0xFF4A4440);
const _rust = Color(0xFF8A4A2A);
const _lead = Color(0xFF8A8C90);
const _oak = Color(0xFF7A5A3A);
const _cabin = Color(0xFF6A4E34);
const _paper = Color(0xFFE6DCC0);
const _lamp = StillroomPalette.gaslight;

// ---------------------------------------------------------------------------
// Shared pieces

/// Dawn over the water: blue above, warm at the horizon, the sun's glow
/// low on the right.
void _dawnSky(Art a, double horizon) {
  a
    ..fade(a.r(0, 0, 1, horizon), _skyHigh, _skyLow)
    ..glow(a.p(0.82, horizon), a.size.width * 0.35, _sun, strength: 0.45);
  final random = math.Random(1590);
  for (var i = 0; i < 5; i++) {
    a.canvas.drawOval(
      Rect.fromCenter(
        center: a.p(random.nextDouble(), 0.06 + random.nextDouble() * 0.16),
        width: a.u * 30,
        height: a.u * 2.4,
      ),
      Paint()
        ..color = const Color(0x40FFE8D0)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, a.u * 1.4),
    );
  }
}

/// The ground from [z0] to the bottom of the picture, filled flat; then
/// sand grains scattered on it.
void _ground(Room room, double fromY, Color color, {int seed = 1}) {
  final a = room.a;
  a.fill(Rect.fromLTRB(0, fromY, a.size.width, a.size.height), color);
  final random = math.Random(seed);
  for (var i = 0; i < 160; i++) {
    final p = room.floorAt(-1 + random.nextDouble() * 3, random.nextDouble());
    if (p.dy < fromY) continue;
    a.canvas.drawCircle(
      p,
      a.u * (0.12 + random.nextDouble() * 0.25),
      Paint()..color = const Color(0x22000000),
    );
  }
}

/// A live oak standing on the ground at [x], [z]: a trunk of width [w]
/// rising out of the picture or to a crown, its crown a cluster of dark
/// leaves with lighter edges, wild vines hanging.
void _liveOak(Room room, double x, double z, double w, {double h = 0.9}) {
  final a = room.a;
  _trunk(room, x, z, w, h);
  final crown = room.at(x, h, z);
  final r = a.size.width * 0.12 * room.scaleAt(z);
  final random = math.Random((x * 100).round() + (z * 10).round());
  for (var i = 0; i < 7; i++) {
    final c =
        crown +
        Offset(
          (random.nextDouble() - 0.5) * r * 2.4,
          (random.nextDouble() - 0.7) * r,
        );
    a.canvas
      ..drawCircle(
        c,
        r * (0.6 + random.nextDouble() * 0.4),
        Paint()..color = _leaves,
      )
      ..drawCircle(
        c.translate(-r * 0.15, -r * 0.2),
        r * 0.35,
        Paint()..color = _leavesLight.withValues(alpha: 0.5),
      );
  }
  // Vines hanging from the crown.
  for (var i = 0; i < 3; i++) {
    final from = crown + Offset((i - 1) * r * 0.7, r * 0.2);
    a.line(
      from,
      from.translate(r * 0.05, r * (0.6 + i * 0.2)),
      const Color(0xFF4A5A30),
      width: 0.4,
    );
  }
}

/// A round trunk standing on the ground at [x], [z], [w] across and [h]
/// tall: darker at its edges, a flare of roots at its foot, furrowed
/// bark, its shadow under it. Returns its outline on screen.
Rect _trunk(Room room, double x, double z, double w, double h) {
  final a = room.a;
  final foot = room.at(x, 0, z);
  final top = room.at(x, h, z);
  final half = (room.at(x + w / 2, 0, z).dx - foot.dx).abs();
  final flare = half * 1.5;
  // A round pool of shade at its foot, falling a little to the left,
  // away from the low sun.
  a.canvas
    ..drawOval(
      Rect.fromCenter(
        center: foot.translate(-flare * 0.5, 0),
        width: flare * 4,
        height: flare * 0.8,
      ),
      Paint()
        ..color = const Color(0x55000000)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, a.u * 1.2),
    )
    ..drawOval(
      Rect.fromCenter(center: foot, width: flare * 2.2, height: flare * 0.35),
      Paint()
        ..color = const Color(0x77000000)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, a.u * 0.4),
    );
  final outline = Path()
    ..moveTo(top.dx - half * 0.85, top.dy)
    ..lineTo(top.dx + half * 0.85, top.dy)
    ..lineTo(foot.dx + half, foot.dy - half * 1.2)
    ..quadraticBezierTo(foot.dx + half, foot.dy, foot.dx + flare, foot.dy)
    ..lineTo(foot.dx - flare, foot.dy)
    ..quadraticBezierTo(
      foot.dx - half,
      foot.dy,
      foot.dx - half,
      foot.dy - half * 1.2,
    )
    ..close();
  final bounds = outline.getBounds();
  a.canvas.drawPath(
    outline,
    Paint()
      ..shader = Gradient.linear(
        bounds.centerLeft,
        bounds.centerRight,
        [
          const Color(0xFF2A221A),
          const Color(0xFF5A4A3A),
          const Color(0xFF4A3E32),
          const Color(0xFF221C16),
        ],
        [0, 0.4, 0.6, 1],
      ),
  );
  a.strokePath(outline, Art.outline, width: 0.5);
  final random = math.Random((x * 97).round() + (z * 31).round());
  for (var i = 0; i < (bounds.height / (a.u * 2)).round(); i++) {
    final px = bounds.left + bounds.width * (0.15 + random.nextDouble() * 0.7);
    final py = bounds.top + random.nextDouble() * bounds.height * 0.9;
    a.line(
      Offset(px, py),
      Offset(px + a.u * 0.2, py + a.u * 2.5),
      const Color(0x99201812),
      width: 0.35,
    );
  }
  return bounds;
}

/// A belt of woods: trunks and crowns across [x0]–[x1] at depth [z].
void _woods(Room room, double x0, double x1, double z, {int seed = 3}) {
  final a = room.a;
  final random = math.Random(seed);
  final top = room.at(0, 1.1, z).dy;
  final foot = room.at(0, 0, z).dy;
  final left = room.at(x0, 0, z).dx;
  final right = room.at(x1, 0, z).dx;
  a.fill(
    Rect.fromLTRB(left, top + (foot - top) * 0.25, right, foot),
    const Color(0xFF2E3E2A),
  );
  for (var x = x0; x < x1; x += 0.05 + random.nextDouble() * 0.08) {
    final p = room.at(x, 0, z);
    final t = room.at(x, 0.6 + random.nextDouble() * 0.3, z);
    a.line(p, t, const Color(0xFF3A3028), width: 0.8);
    a.canvas.drawCircle(
      t,
      (foot - top) * (0.2 + random.nextDouble() * 0.15),
      Paint()
        ..color = Color.lerp(
          _leaves,
          const Color(0xFF26321F),
          random.nextDouble(),
        )!,
    );
  }
}

/// Smoke rising in thin wisps from a point.
void _smoke(Art a, Offset from, double height, {int seed = 2}) {
  final random = math.Random(seed);
  for (var i = 0; i < 4; i++) {
    final start = from.translate((random.nextDouble() - 0.5) * a.u * 8, 0);
    final wisp = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(
        start.dx + a.u * 3,
        start.dy - height * 0.3,
        start.dx - a.u * 4,
        start.dy - height * 0.6,
        start.dx + a.u * 2,
        start.dy - height,
      );
    a.canvas.drawPath(
      wisp,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = a.u * 1.6
        ..color = const Color(0x44D8D4CC)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, a.u * 0.8),
    );
  }
}

/// A row of palisade posts along [z], from [x0] to [x1], [h] tall, with a
/// gap left between [gap0] and [gap1].
void _palisadeRow(
  Room room,
  double x0,
  double x1,
  double z,
  double h, {
  double gap0 = 99,
  double gap1 = 99,
  double post = 0.06,
}) {
  final random = math.Random((z * 100).round());
  for (var x = x0; x < x1; x += post) {
    if (x + post > gap0 && x < gap1) continue;
    final top = h * (0.92 + random.nextDouble() * 0.1);
    room.block(
      x,
      x + post * 0.96,
      0,
      top,
      z,
      z + post,
      Color.lerp(_palisade, _bark, random.nextDouble() * 0.5)!,
      line: 0.3,
    );
  }
}

/// A ship's chest on the ground, its lid thrown back, its contents spilled.
Rect _chest(
  Room room,
  double x0,
  double x1,
  double z0,
  double z1, {
  double h = 0.12,
}) {
  room.shadow(x0, x1, z0, z1, strength: 0.45, spread: 0.12);
  final front = room.block(x0, x1, 0, h, z0, z1, _oak);
  // The lid, thrown back against the far edge.
  room.a.path(
    room.a.poly([
      room.at(x0, h, z1),
      room.at(x1, h, z1),
      room.at(x1, h + (x1 - x0) * 0.5, z1 + 0.03),
      room.at(x0, h + (x1 - x0) * 0.5, z1 + 0.03),
    ]),
    Color.lerp(_oak, Art.outline, 0.2)!,
    line: 0.4,
  );
  // Iron bands.
  for (final t in [0.2, 0.8]) {
    final x = front.left + front.width * t;
    room.a.line(
      Offset(x, front.top),
      Offset(x, front.bottom),
      _iron,
      width: 0.6,
    );
  }
  return front;
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
  double turn = 0,
}) {
  final a = room.a;
  a.path(
    a.poly([
      room.at(x0 + turn, y, z0),
      room.at(x1 + turn, y, z0),
      room.at(x1 - turn, y, z1),
      room.at(x0 - turn, y, z1),
    ]),
    color,
    line: 0.3,
  );
  for (var k = 0; k < 4; k++) {
    final z = z0 + (z1 - z0) * (0.25 + k * 0.18);
    a.hairline(
      room.at(x0 + (x1 - x0) * 0.15, y, z),
      room.at(x1 - (x1 - x0) * 0.2, y, z),
      StillroomPalette.inkOnPaper.withValues(alpha: 0.4),
      0.3,
    );
  }
}

// ---------------------------------------------------------------------------
// Scenes

/// The shore at dawn: the sound out to the far banks, the ship at anchor
/// beyond; woods along the left with a path up the rise and the track to
/// the fort; grass still smoking at the woods' edge; footprints in the
/// sand; the boat drawn up, a trumpet on its thwart.
void _shore(Art a) {
  final room = Room(a, vp: a.p(0.5, 0.4), depth: 0.3);
  final waterline = room.at(0, 0, 0.9).dy;
  _dawnSky(a, 0.4);
  // The water, the far banks a low line at the horizon, the ship.
  a
    ..fade(
      Rect.fromLTRB(0, a.size.height * 0.4, a.size.width, waterline),
      _waterFar,
      _water,
    )
    ..fill(a.r(0, 0.398, 1, 0.008), const Color(0xFF5A6A5E));
  for (var k = 0; k < 14; k++) {
    final z = 0.95 + k * 0.6;
    a.hairline(
      room.at(-3, 0, z),
      room.at(4, 0, z),
      const Color(0x22FFFFFF),
      0.25,
    );
  }
  _ship3d(room, 2.3, 6.5);
  _ground(room, waterline, _sand, seed: 4);
  a.path(
    a.poly([
      room.at(-3, 0, 0.9),
      room.at(4, 0, 0.9),
      room.at(4, 0, 0.8),
      room.at(-3, 0, 0.8),
    ]),
    _sandWet,
    line: 0,
  );
  // Woods along the left, back to the water.
  _woods(room, -2.5, 0.6, 0.86, seed: 5);
  _woods(room, -2.5, -0.15, 0.6, seed: 6);
  const path = Color(0xFFB4A078);
  // The track to the fort into the trees, posts glimpsed at its end.
  a.path(
    a.poly([
      room.at(0.08, 0.001, 0.5),
      room.at(0.22, 0.001, 0.5),
      room.at(0.15, 0.001, 0.86),
      room.at(0.08, 0.001, 0.86),
    ]),
    path,
    line: 0,
  );
  for (var k = 0; k < 6; k++) {
    final x = 0.0 + k * 0.035;
    room.block(x, x + 0.03, 0, 0.5, 0.86, 0.89, _palisade, line: 0.25);
  }
  // The path up the rise, into the near woods on the left.
  a.path(
    a.poly([
      room.at(-0.16, 0.001, 0.12),
      room.at(0.0, 0.001, 0.12),
      room.at(-0.17, 0.04, 0.6),
      room.at(-0.24, 0.04, 0.6),
    ]),
    path,
    line: 0,
  );
  // Grass still smoking at the far woods' edge.
  a.path(
    a.poly([
      room.at(0.24, 0.002, 0.62),
      room.at(0.5, 0.002, 0.6),
      room.at(0.56, 0.002, 0.8),
      room.at(0.26, 0.002, 0.84),
    ]),
    const Color(0xFF2A2420),
    line: 0,
  );
  final burn = math.Random(8);
  for (var i = 0; i < 30; i++) {
    final p = room.at(
      0.27 + burn.nextDouble() * 0.26,
      0.002,
      0.63 + burn.nextDouble() * 0.18,
    );
    a.canvas.drawCircle(
      p,
      a.u * 0.25,
      Paint()..color = const Color(0xAAE07A30),
    );
  }
  _smoke(a, room.at(0.4, 0, 0.72), a.size.height * 0.24);
  // A live oak close on the left, framing the shore.
  _liveOak(room, -0.2, 0.24, 0.07, h: 1.2);
  // Footprints in the sand, two or three kinds, wandering.
  for (var i = 0; i < 12; i++) {
    final x = 0.28 + i * 0.022 + (i.isEven ? 0.015 : 0);
    final z = 0.1 + i * 0.026;
    final c = room.floorAt(x, z);
    final s = a.u * 2.2 * room.scaleAt(z) / room.scaleAt(0.2);
    a.oval(
      Rect.fromCenter(center: c, width: s, height: s * 0.5),
      const Color(0x88806A48),
      line: 0,
    );
  }
  // The boat drawn up on the sand, the trumpet on its thwart.
  _boat(room, 0.62, 0.98, 0.24, 0.42);
  final thwart = room.at(0.8, 0.13, 0.33);
  a
    ..line(
      thwart.translate(-a.u * 3, 0),
      thwart.translate(a.u * 3, -a.u * 0.4),
      const Color(0xFFC8A040),
      width: 0.7,
    )
    ..oval(
      Rect.fromCenter(
        center: thwart.translate(a.u * 3.4, -a.u * 0.5),
        width: a.u * 1.8,
        height: a.u * 1.4,
      ),
      const Color(0xFFC8A040),
      line: 0.3,
    );
}

/// A ship at anchor far out, at [x], [z]: hull, three masts, sails furled.
void _ship3d(Room room, double x, double z) {
  final a = room.a;
  final hull0 = room.at(x - 0.35, 0.06, z);
  final hull1 = room.at(x + 0.35, 0.06, z);
  final keel = room.at(x, -0.02, z);
  a.path(
    a.poly([
      hull0,
      hull1,
      Offset(hull1.dx - (hull1.dx - hull0.dx) * 0.15, keel.dy),
      Offset(hull0.dx + (hull1.dx - hull0.dx) * 0.1, keel.dy),
    ]),
    const Color(0xFF3A2A20),
    line: 0.3,
  );
  for (final (dx, h) in [(-0.18, 0.9), (0.02, 1.1), (0.2, 0.8)]) {
    final foot = room.at(x + dx, 0.06, z);
    final top = room.at(x + dx, h, z);
    a.line(foot, top, const Color(0xFF3A2A20), width: 0.4);
    for (final t in [0.35, 0.65]) {
      final y = Offset.lerp(foot, top, t)!;
      a.line(
        y.translate(-a.u * 1.2, 0),
        y.translate(a.u * 1.2, 0),
        const Color(0xFF3A2A20),
        width: 0.3,
      );
    }
  }
}

/// A ship's boat drawn up on the sand: its hull in perspective, thwarts.
void _boat(Room room, double x0, double x1, double z0, double z1) {
  final a = room.a;
  room.shadow(x0, x1, z0, z1, strength: 0.4, spread: 0.05);
  const h = 0.14;
  final mid = (z0 + z1) / 2;
  // Gunwale: pointed at the bow (left), square at the stern.
  final gunwale = [
    room.at(x0, h, mid),
    room.at(x0 + (x1 - x0) * 0.25, h, z0),
    room.at(x1, h, z0 + 0.02),
    room.at(x1, h, z1 - 0.02),
    room.at(x0 + (x1 - x0) * 0.25, h, z1),
  ];
  final keel = [
    room.at(x0 + 0.02, 0.02, mid),
    room.at(x0 + (x1 - x0) * 0.25, 0, z0 + 0.03),
    room.at(x1, 0, z0 + 0.04),
  ];
  // The near side of the hull.
  a.path(
    a.poly([gunwale[0], gunwale[1], gunwale[2], keel[2], keel[1], keel[0]]),
    const Color(0xFF6A4E34),
    line: 0.5,
  );
  // Inside the hull, seen over the near gunwale.
  a.path(a.poly(gunwale), const Color(0xFF4A3828), line: 0.5);
  a.path(
    a.poly([
      gunwale[0],
      gunwale[1],
      gunwale[2],
      room.at(x1, h * 0.4, z0 + 0.04),
      room.at(x0 + (x1 - x0) * 0.25, h * 0.4, z0 + 0.03),
    ]),
    const Color(0xFF7A5A3E),
    line: 0.3,
  );
  // Thwarts across.
  for (final t in [0.45, 0.72]) {
    final x = x0 + (x1 - x0) * t;
    a.line(
      room.at(x, h * 0.95, z0 + 0.01),
      room.at(x, h * 0.95, z1 - 0.01),
      const Color(0xFF8A6A48),
      width: 1,
    );
  }
  // The stern, square.
  a.path(
    a.poly([gunwale[2], gunwale[3], room.at(x1, 0.01, z1 - 0.03), keel[2]]),
    const Color(0xFF5A4230),
    line: 0.4,
  );
}

/// The hill: a sandy rise among live oaks. One oak in front with its bark
/// cut away and CRO carved there; across to the right, the sound and the
/// long banks running south toward Croatoan.
void _hill(Art a) {
  final room = Room(a, vp: a.p(0.5, 0.42), depth: 0.3);
  _dawnSky(a, 0.42);
  // The view south: the sound, the banks, the sea beyond.
  a
    ..fade(a.r(0, 0.42, 1, 0.08), _waterFar, _water)
    ..fill(a.r(0.35, 0.445, 0.65, 0.012), const Color(0xFFD8C8A0))
    ..fill(a.r(0, 0.42, 1, 0.006), const Color(0xFF5A6A5E))
    // The slope falling away below the crest, dune grass on it.
    ..fade(
      a.r(0, 0.5, 1, 0.1),
      const Color(0xFFB8A878),
      const Color(0xFFC8B48A),
    );
  // The crest of the rise: grass and sand falling away at its far edge.
  final crest = room.at(0, 0, 1).dy;
  _ground(room, crest, _sand, seed: 7);
  final random = math.Random(9);
  for (var i = 0; i < 120; i++) {
    final x = -1.5 + random.nextDouble() * 4;
    final z = random.nextDouble();
    final p = room.floorAt(x, z);
    final s = a.u * 1.6 * room.scaleAt(z);
    a.line(p, p.translate(s * 0.3, -s * 1.6), _grass, width: 0.35);
  }
  _woods(room, -2.5, 0.3, 1.0, seed: 10);
  _liveOak(room, 0.9, 0.85, 0.05);
  _liveOak(room, -0.35, 0.7, 0.07);
  // The oak with CRO: a broad trunk in front on the left, the bark cut
  // away in a pale patch, three letters cut in it.
  const x0 = 0.06;
  const x1 = 0.28;
  final trunk = _trunk(room, (x0 + x1) / 2, 0.3, x1 - x0, 1.6);
  final patch = Rect.fromPoints(
    room.at(x0 + 0.04, 0.5, 0.26),
    room.at(x1 - 0.04, 0.34, 0.26),
  );
  a
    ..rbox(patch, a.u * 0.8, _stripped, line: 0.4)
    ..label('CRO', patch.center, patch.height * 0.55, const Color(0xFF3A2A1A));
  // Its crown overhead, leaves hanging into the top of the picture, and a
  // wild vine down the trunk.
  final leaves = math.Random(12);
  for (var i = 0; i < 9; i++) {
    final c = Offset(
      trunk.center.dx + (leaves.nextDouble() - 0.3) * a.size.width * 0.4,
      -a.size.height * 0.04 + leaves.nextDouble() * a.size.height * 0.12,
    );
    a.canvas.drawCircle(
      c,
      a.u * (7 + leaves.nextDouble() * 6),
      Paint()..color = _leaves,
    );
  }
}

/// The fort: a high palisade of great trees across the clearing, an
/// entrance, the chief post on its right stripped and carved; through
/// the gap the bare places where the houses stood. In the grass in front,
/// iron bars, pigs of lead and fowlers, overgrown. To the right the
/// palisade bends back where an old trench runs.
void _fort(Art a) {
  final room = Room(a, vp: a.p(0.5, 0.38), depth: 0.3);
  _dawnSky(a, 0.4);
  _woods(room, -3, 4, 1.6, seed: 12);
  _ground(room, room.at(0, 0, 1.6).dy, _grass, seed: 13);
  // Inside, seen through the gap: the far palisade, the bare house sites.
  _palisadeRow(room, -1, 2, 1.2, 0.8, post: 0.07);
  for (final (x, z) in [(0.3, 0.6), (0.6, 0.78)]) {
    a.path(
      a.poly([
        room.floorAt(x, z),
        room.floorAt(x + 0.16, z),
        room.floorAt(x + 0.16, z + 0.12),
        room.floorAt(x, z + 0.12),
      ]),
      const Color(0xFF6A6040),
      line: 0.3,
    );
  }
  // The near palisade, with the entrance.
  _palisadeRow(room, -1.6, 2.6, 0.35, 0.85, gap0: 0.42, gap1: 0.58, post: 0.07);
  // The left entrance post, and the chief post on the right: thicker, its
  // bark stripped in a band, CROATOAN cut in it.
  room
    ..shadow(0.32, 0.42, 0.33, 0.41, strength: 0.35)
    ..block(0.32, 0.42, 0, 0.98, 0.33, 0.41, _bark)
    ..shadow(0.58, 0.7, 0.33, 0.42, strength: 0.35);
  final post = room.block(0.58, 0.7, 0, 0.98, 0.33, 0.42, _bark);
  final band = Rect.fromLTRB(
    post.left + post.width * 0.08,
    room.at(0.58, 0.66, 0.33).dy,
    post.right - post.width * 0.08,
    room.at(0.58, 0.3, 0.33).dy,
  );
  a.rbox(band, a.u * 0.4, _stripped, line: 0.3);
  // The letters run down the post, one under another.
  const word = 'CROATOAN';
  for (var i = 0; i < word.length; i++) {
    a.label(
      word[i],
      Offset(band.center.dx, band.top + band.height * (i + 0.5) / word.length),
      band.height / word.length * 0.85,
      const Color(0xFF3A2A1A),
    );
  }
  // The flanker jutting forward on the left.
  _palisadeRow(room, -0.66, -0.4, 0.18, 0.85, post: 0.07);
  for (var z = 0.18; z < 0.35; z += 0.07) {
    room.block(-0.7, -0.63, 0, 0.88, z, z + 0.07, _palisade, line: 0.3);
  }
  // The old trench on the right: a low bank of earth with a dark cut.
  room.shadow(1.0, 1.45, 0.16, 0.3, strength: 0.25, spread: 0.02);
  a
    ..path(
      a.poly([
        room.at(1.0, 0.0, 0.18),
        room.at(1.45, 0.0, 0.18),
        room.at(1.45, 0.06, 0.28),
        room.at(1.0, 0.06, 0.28),
      ]),
      const Color(0xFF6A5638),
      line: 0.3,
    )
    ..path(
      a.poly([
        room.at(1.04, 0.0, 0.2),
        room.at(1.41, 0.0, 0.2),
        room.at(1.41, 0.0, 0.25),
        room.at(1.04, 0.0, 0.25),
      ]),
      const Color(0xFF2A2018),
      line: 0,
    );
  // In the grass before the gate: iron bars, two pigs of lead, four
  // fowlers, shot, all overgrown.
  room.shadow(0.0, 0.34, 0.06, 0.26, strength: 0.25, spread: 0.02);
  for (var k = 0; k < 4; k++) {
    final z = 0.08 + k * 0.03;
    room.block(
      0.02 + k * 0.01,
      0.17 + k * 0.01,
      0,
      0.012,
      z,
      z + 0.012,
      _iron,
      line: 0.25,
    );
  }
  room
    ..block(0.2, 0.27, 0, 0.03, 0.08, 0.12, _lead, line: 0.3)
    ..block(0.22, 0.29, 0, 0.03, 0.15, 0.19, _lead, line: 0.3);
  for (var k = 0; k < 4; k++) {
    final x = 0.04 + k * 0.07;
    final z = 0.22 + (k % 2) * 0.02;
    a.line(
      room.at(x, 0.02, z),
      room.at(x + 0.05, 0.02, z - 0.01),
      _rust,
      width: 1.4,
    );
  }
  for (var k = 0; k < 5; k++) {
    a.circle(
      room.at(0.3 + k * 0.012, 0.012, 0.24),
      a.u * 0.5,
      _iron,
      line: 0.2,
    );
  }
  final weeds = math.Random(14);
  for (var i = 0; i < 90; i++) {
    final x = -0.3 + weeds.nextDouble() * 0.75;
    final z = 0.03 + weeds.nextDouble() * 0.28;
    final p = room.floorAt(x, z);
    final s = a.u * 2.2 * room.scaleAt(z);
    a.line(
      p,
      p.translate(s * (weeds.nextDouble() - 0.5), -s * 1.4),
      _grass,
      width: 0.4,
    );
  }
}

/// The chests: by the end of the old trench, a pit dug open, five chests
/// broken and spilled, White's pictures and maps spoiled, his armour rusted.
/// The palisade stands beyond.
void _chests(Art a) {
  final room = Room(a, vp: a.p(0.5, 0.34), depth: 0.3);
  _dawnSky(a, 0.36);
  _woods(room, -3, 4, 2.2, seed: 15);
  _ground(room, room.at(0, 0, 2.2).dy, _grass, seed: 16);
  _palisadeRow(room, -2, 3, 1.4, 0.85, post: 0.07);
  // The pit: dug earth heaped round a dark hole.
  room.shadow(0.2, 0.8, 0.45, 0.75, strength: 0.25, spread: 0.05);
  a
    ..path(
      a.poly([
        room.floorAt(0.18, 0.45),
        room.floorAt(0.82, 0.45),
        room.floorAt(0.86, 0.78),
        room.floorAt(0.14, 0.78),
      ]),
      const Color(0xFF7A6040),
      line: 0.3,
    )
    ..path(
      a.poly([
        room.floorAt(0.28, 0.5),
        room.floorAt(0.72, 0.5),
        room.floorAt(0.74, 0.7),
        room.floorAt(0.26, 0.7),
      ]),
      const Color(0xFF2E2418),
      line: 0.3,
    );
  // Spade marks, heaps.
  for (final (x, z) in [(0.12, 0.6), (0.88, 0.55), (0.5, 0.82)]) {
    final c = room.floorAt(x, z);
    final w = a.size.width * 0.08 * room.scaleAt(z);
    a.path(
      Path()
        ..moveTo(c.dx - w, c.dy)
        ..quadraticBezierTo(c.dx, c.dy - w * 0.5, c.dx + w, c.dy)
        ..close(),
      const Color(0xFF6A5236),
      line: 0.3,
    );
  }
  // Five chests, dug up and broken open.
  _chest(room, 0.02, 0.18, 0.3, 0.4);
  _chest(room, 0.84, 1.02, 0.34, 0.44);
  _chest(room, 0.3, 0.46, 0.84, 0.92);
  _chest(room, 0.6, 0.76, 0.86, 0.94);
  final chartChest = _chest(room, 0.6, 0.8, 0.16, 0.28, h: 0.13);
  // In the near chest, a roll of oiled cloth.
  a
    ..oval(
      Rect.fromCenter(
        center: chartChest.topCenter.translate(0, -a.u * 0.6),
        width: chartChest.width * 0.7,
        height: a.u * 2.6,
      ),
      const Color(0xFF8A7A4A),
      line: 0.4,
    )
    ..line(
      chartChest.topCenter.translate(-chartChest.width * 0.3, -a.u * 0.6),
      chartChest.topCenter.translate(chartChest.width * 0.3, -a.u * 0.6),
      const Color(0xFF5A4A2A),
      width: 0.3,
    );
  // Spoiled papers and broken frames, the armour rusting.
  _flatSheet(
    room,
    0.2,
    0.32,
    0.2,
    0.3,
    0.002,
    color: const Color(0xFFBCAE8A),
    turn: 0.02,
  );
  _flatSheet(
    room,
    0.36,
    0.5,
    0.24,
    0.34,
    0.002,
    color: const Color(0xFFC8B890),
    turn: -0.02,
  );
  room.block(
    0.08,
    0.2,
    0,
    0.012,
    0.16,
    0.22,
    const Color(0xFF7A5A3A),
    line: 0.3,
  );
  final breast = room.at(0.94, 0.03, 0.22);
  final w = a.size.width * 0.07;
  a
    ..path(
      Path()
        ..moveTo(breast.dx - w / 2, breast.dy)
        ..quadraticBezierTo(
          breast.dx,
          breast.dy - w * 0.9,
          breast.dx + w / 2,
          breast.dy,
        )
        ..close(),
      _rust,
      line: 0.5,
    )
    ..stain(breast.translate(0, -w * 0.25), w * 0.2);
}

/// The ship's cabin: plank walls, the stern windows on the dawn sea, a
/// hanging lantern; White's bunk on the left with his journal, the table
/// in the middle, a sea chest on the right.
void _ship(Art a) {
  final room = Room(a, vp: a.p(0.5, 0.24), depth: 0.55);
  final back = room.back;
  a
    ..path(room.ceiling, const Color(0xFF4A3424), line: 0)
    ..path(room.leftWall, const Color(0xFF5E4430), line: 0)
    ..path(room.rightWall, const Color(0xFF654a34), line: 0)
    ..fill(back, const Color(0xFF6A4E36))
    ..path(room.floor, const Color(0xFF5A4028), line: 0);
  // Planks: along the floor, up the walls, across the ceiling beams.
  room.floorGrid(const Color(0x55201408), rows: 0, columns: 12);
  for (var k = 1; k < 10; k++) {
    final y = k / 10;
    a
      ..hairline(
        room.at(0, y, 0),
        room.at(0, y, 1),
        const Color(0x44201408),
        0.3,
      )
      ..hairline(
        room.at(1, y, 0),
        room.at(1, y, 1),
        const Color(0x44201408),
        0.3,
      )
      ..hairline(
        room.at(0, y, 1),
        room.at(1, y, 1),
        const Color(0x44201408),
        0.3,
      );
  }
  for (var k = 1; k < 5; k++) {
    final z = k / 5;
    room.a.path(
      a.poly([
        room.at(0, 1, z),
        room.at(1, 1, z),
        room.at(1, 0.96, z + 0.04),
        room.at(0, 0.96, z + 0.04),
      ]),
      const Color(0xFF3A2818),
      line: 0.3,
    );
  }
  room
    ..shadeCorners(strength: 0.45)
    ..edges(const Color(0x88201408), width: 0.4);
  // The stern windows: three lights on the dawn sea.
  for (var k = 0; k < 3; k++) {
    final x = 0.2 + k * 0.22;
    final win = Rect.fromPoints(
      room.at(x, 0.85, 1),
      room.at(x + 0.16, 0.55, 1),
    );
    room.recess(win, const Color(0xFF6A4E36), thickness: 0.04);
    final glass = Room.recessInner(win, thickness: 0.04);
    a
      ..fade(glass, _skyLow, _water)
      ..fill(
        Rect.fromLTRB(
          glass.left,
          glass.center.dy + glass.height * 0.1,
          glass.right,
          glass.bottom,
        ),
        _water,
      )
      ..ink(glass, width: 0.4)
      ..hairline(
        glass.topCenter,
        glass.bottomCenter,
        const Color(0xFF3A2818),
        0.5,
      )
      ..hairline(
        glass.centerLeft,
        glass.centerRight,
        const Color(0xFF3A2818),
        0.5,
      );
    room.beam(
      [glass.bottomLeft, glass.bottomRight],
      [
        room.floorAt(x - 0.02, 0.62),
        room.floorAt(x + 0.18, 0.62),
        room.floorAt(x + 0.2, 0.4),
        room.floorAt(x - 0.04, 0.4),
      ],
      _sun,
      strength: 0.06,
    );
  }
  // The lantern hanging from a beam.
  final hook = room.at(0.5, 1, 0.45);
  final lantern = room.at(0.5, 0.78, 0.45);
  a
    ..line(hook, lantern, const Color(0xFF2A1E14), width: 0.4)
    ..box(
      Rect.fromCenter(
        center: lantern.translate(0, a.u * 2),
        width: a.u * 3,
        height: a.u * 4,
      ),
      const Color(0xFF4A3A2A),
      line: 0.4,
    )
    ..flame(lantern.translate(0, a.u * 3.2), a.u * 2)
    ..glow(lantern, a.size.width * 0.3, _lamp, strength: 0.18);
  // White's bunk along the left wall, his journal open on it.
  room
    ..shadow(0, 0.22, 0.2, 0.7, strength: 0.4, spread: 0.04)
    ..block(0, 0.22, 0, 0.2, 0.2, 0.7, _oak)
    ..block(0.01, 0.21, 0.2, 0.23, 0.22, 0.68, const Color(0xFF8A7A5A));
  _flatSheet(
    room,
    0.06,
    0.17,
    0.28,
    0.38,
    0.232,
    color: const Color(0xFFE8DCBA),
  );
  _flatSheet(
    room,
    0.06,
    0.17,
    0.38,
    0.48,
    0.232,
    color: const Color(0xFFE2D6B2),
  );
  // The sea chest on the right.
  room
    ..shadow(0.78, 0.98, 0.3, 0.48, strength: 0.4, spread: 0.06)
    ..block(0.78, 0.98, 0, 0.18, 0.3, 0.48, _oak);
  // The table, its top bare: the chart and the papers come later.
  room.table(0.28, 0.72, 0.14, 0.44, 0.27, _cabin, leg: 0.02);
}

// ---------------------------------------------------------------------------
// Puzzle boards

/// The cabin table under the lantern.
void _tableBoard(Art a, {required double lamp}) {
  a
    ..fade(
      Offset.zero & a.size,
      const Color(0xFF3A2818),
      const Color(0xFF1E140C),
    )
    ..glow(a.p(0.4, 0.0), a.size.width * 0.6, _lamp, strength: lamp);
  for (var k = 1; k < 8; k++) {
    a.hairline(a.p(0, k / 8), a.p(1, k / 8), const Color(0x22000000), 0.4);
  }
}

// ---------------------------------------------------------------------------
// Objects

/// White's chart lying on the table: a sheet seen at a slant, the coast
/// drawn on it, a pair of dividers across it.
void _chartOnTable(Art a) {
  final sheet = a.poly([
    a.p(0.08, 0.06),
    a.p(0.92, 0.06),
    a.p(0.98, 0.94),
    a.p(0.02, 0.94),
  ]);
  a.path(sheet, const Color(0xFFE6D8B4), line: 0.4);
  a.canvas
    ..save()
    ..clipPath(sheet);
  a
    ..fill(a.r(0, 0.78, 1, 0.22), const Color(0xFF9AB0A8))
    ..fill(a.r(0, 0.6, 1, 0.16), const Color(0xFFB4C4B6));
  a.canvas.restore();
  a
    ..line(a.p(0.3, 0.3), a.p(0.42, 0.7), const Color(0xFF6A6A70), width: 0.6)
    ..line(a.p(0.42, 0.7), a.p(0.56, 0.32), const Color(0xFF6A6A70), width: 0.6)
    ..circle(a.p(0.65, 0.68), a.u * 1.2, const Color(0xFFB0302A), line: 0.2);
}

/// The cypress core on the table, in its paper sleeve.
void _coreOnTable(Art a) {
  a
    ..paper(
      a.r(0.05, 0.2, 0.9, 0.6),
      lines: 3,
      color: const Color(0xFFF0EEE6),
      ink: 0.4,
    )
    ..rbox(
      a.r(0.1, 0.44, 0.8, 0.14),
      a.u * 2,
      const Color(0xFFC8A070),
      line: 0.4,
    );
  for (var k = 1; k < 14; k++) {
    final x = 0.1 + 0.8 * k / 14;
    a.hairline(
      a.p(x, 0.44),
      a.p(x, 0.58),
      const Color(0xFF6A4424),
      k == 9 || k == 10 ? 0.6 : 0.3,
    );
  }
}

/// Papers that should not be here yet, [count] sheets.
void _papers(Art a, int count) {
  for (var i = 0; i < count; i++) {
    a.paper(
      a.r(
        0.06 + i * (0.84 / count),
        0.1 + (i % 2) * 0.08,
        0.84 / count + 0.06,
        0.72,
      ),
      lines: 6,
      angle: -0.05 + i * 0.05,
      color: i.isOdd ? const Color(0xFFF2F2EE) : _paper,
      ink: 0.5,
    );
  }
  a.glow(a.p(0.5, 0.5), a.size.width * 0.6, _lamp, strength: 0.12);
}

/// The jar: dawn over the water, and before it the stripped post with the
/// letters begun.
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
    ..fade(a.r(0, 0.16, 1, 0.44), _skyHigh, _skyLow)
    ..glow(a.p(0.7, 0.6), w * 0.5, _sun, strength: 0.5)
    ..fill(a.r(0, 0.6, 1, 0.14), _water)
    ..fill(a.r(0, 0.74, 1, 0.26), _sand);
  // The post, bark at its edges, the stripped band and the letters.
  final post = a.r(0.36, 0.28, 0.28, 0.72);
  a
    ..box(post, _bark, line: 0.5)
    ..rbox(a.r(0.4, 0.42, 0.2, 0.3), a.u * 1, _stripped, line: 0.4);
  const letters = 'CRO';
  for (var i = 0; i < letters.length; i++) {
    a.label(
      letters[i],
      a.p(0.5, 0.47 + i * 0.09),
      h * 0.07,
      const Color(0xFF3A2A1A),
    );
  }
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
  // The lid: a coil of old rope.
  a
    ..oval(a.r(0.28, 0.06, 0.44, 0.12), const Color(0xFFA08A5A), line: 0.5)
    ..oval(a.r(0.36, 0.09, 0.28, 0.06), const Color(0xFF8A744A), line: 0.4);
}
