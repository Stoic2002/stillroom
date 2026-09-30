import 'dart:math' as math;
import 'dart:ui';

import '../theme/stillroom_palette.dart';
import 'art_kit.dart';
import 'echo_art.dart';
import 'whitechapel_1888_art.dart' show jarLabelBoard;

/// Code-drawn art for "Beijing, 1908" (docs/episodes/chongling_1908.md):
/// Chongling, the Guangxu Emperor's tomb in the Western Qing Tombs, in the
/// winter of the tests (2003–2008). Red walls and yellow tiles under snow,
/// the marble crypt under a work lamp, an archive room, and a heated
/// work-room where the hair and robes are measured.
const _s = 'images/scenes/chongling_1908';
const _o = 'images/objects/chongling_1908';

final Map<String, ArtPainter> chongling1908Art = {
  // Scenes and puzzle boards.
  '$_s/stele_court.png': (c, s) => _court(Art(c, s)),
  '$_s/crypt.png': (c, s) => _crypt(Art(c, s)),
  '$_s/archive.png': (c, s) => _archive(Art(c, s)),
  '$_s/site_lab.png': (c, s) => _lab(Art(c, s)),
  '$_s/bench_board.png': (c, s) => _benchBoard(Art(c, s)),
  '$_s/robe_board.png': (c, s) => _benchBoard(Art(c, s), robe: true),
  '$_s/label_close.png': (c, s) => jarLabelBoard(Art(c, s), _redDark),
  // Objects.
  '$_o/rumour_sprite.png': (c, s) => _cuttings(Art(c, s)),
  '$_o/report_sprite.png': (c, s) => _report(Art(c, s)),
  '$_o/echo_keeper.png': (c, s) => paintEcho(Art(c, s), EchoFigure.tombKeeper),
  '$_o/echo_scientist.png': (c, s) =>
      paintEcho(Art(c, s), EchoFigure.scientist),
  // The jar on the shelf.
  'images/ui/jar_chongling_1908.png': (c, s) => _jar(Art(c, s)),
};

// ---------------------------------------------------------------------------
// Palette

const _sky = Color(0xFFA4ACB4);
const _skyHigh = Color(0xFF6A7480);
const _hills = Color(0xFF7E8690);
const _snow = Color(0xFFE6E8EA);
const _snowShade = Color(0xFFB4BAC2);
const _red = Color(0xFF8E3226);
const _redDark = Color(0xFF5A1E18);
const _tile = Color(0xFFC89A2E);
const _tileDark = Color(0xFF8A6A1E);
const _greyTile = Color(0xFF4A4E54);
const _stone = Color(0xFF8C8A84);
const _stoneDark = Color(0xFF5E5C58);
const _marble = Color(0xFFC8C4B8);
const _pine = Color(0xFF26382E);
const _panel = Color(0xFFB8C4CC);
const _tube = Color(0xFFEAF4F2);
const _imperial = Color(0xFFE9C766);
const _vermilion = Color(0xFFB02A1A);
const _robe = Color(0xFF1E2438);
const _gold = Color(0xFFB08A3A);
const _lamp = StillroomPalette.gaslight;

// ---------------------------------------------------------------------------
// Shared pieces

/// A hipped roof of glazed tiles: a trapezoid with upturned eaves and a
/// line of snow along its top edge.
void _roof(Art a, Rect r, Color tile, {double inset = 0.14}) {
  final dx = r.width * inset;
  final roof = a.poly([
    r.bottomLeft,
    Offset(r.left + dx, r.top),
    Offset(r.right - dx, r.top),
    r.bottomRight,
  ]);
  a.path(roof, tile, line: 0.5);
  final dark = Color.lerp(tile, Art.outline, 0.35)!;
  // Rows of tiles running down the slope.
  for (var i = 1; i < 14; i++) {
    final t = i / 14;
    a.hairline(
      Offset(r.left + dx + (r.width - dx * 2) * t, r.top),
      Offset(r.left + r.width * t, r.bottom),
      dark,
      0.2,
    );
  }
  // The eaves turn up at the corners.
  for (final (corner, sx) in [(r.bottomLeft, -1.0), (r.bottomRight, 1.0)]) {
    a.path(
      a.poly([
        corner,
        corner.translate(sx * r.height * 0.5, -r.height * 0.35),
        corner.translate(-sx * r.height * 0.3, -r.height * 0.05),
      ]),
      tile,
      line: 0.4,
    );
  }
  // Snow on the ridge and along the eaves.
  a
    ..line(
      Offset(r.left + dx, r.top),
      Offset(r.right - dx, r.top),
      _snow,
      width: 1.1,
    )
    ..line(
      r.bottomLeft.translate(r.width * 0.02, -a.u * 0.3),
      r.bottomRight.translate(-r.width * 0.02, -a.u * 0.3),
      _snow.withValues(alpha: 0.8),
      width: 0.6,
    );
}

/// A pine, dark tiers with snow on their upper edges.
void _pineTree(Art a, Offset base, double height) {
  final w = height * 0.42;
  a.box(
    Rect.fromCenter(
      center: base.translate(0, -height * 0.06),
      width: w * 0.12,
      height: height * 0.12,
    ),
    const Color(0xFF3A2A20),
    line: 0.3,
  );
  for (var i = 0; i < 4; i++) {
    final bottom = base.dy - height * (0.1 + i * 0.2);
    final top = bottom - height * 0.34;
    final half = w * (0.5 - i * 0.1);
    final tier = a.poly([
      Offset(base.dx - half, bottom),
      Offset(base.dx, top),
      Offset(base.dx + half, bottom),
    ]);
    a
      ..path(tier, _pine, line: 0.4)
      ..line(
        Offset(base.dx - half * 0.6, bottom - height * 0.12),
        Offset(base.dx, top + height * 0.02),
        _snow.withValues(alpha: 0.85),
        width: 0.5,
      );
  }
}

/// Snow falling: flakes scattered over the picture, or [within] a window.
void _snowfall(Art a, {int count = 140, int seed = 7, Rect? within}) {
  final area = within ?? Offset.zero & a.size;
  final random = math.Random(seed);
  final flake = Paint()..color = _snow.withValues(alpha: 0.75);
  for (var i = 0; i < count; i++) {
    a.canvas.drawCircle(
      Offset(
        area.left + area.width * random.nextDouble(),
        area.top + area.height * random.nextDouble(),
      ),
      a.u * (0.12 + random.nextDouble() * 0.22),
      flake,
    );
  }
}

/// Vertical columns of brush writing on [rect], right to left.
void _columns(Art a, Rect rect, Color ink, {int columns = 6}) {
  for (var i = 0; i < columns; i++) {
    final x = rect.right - rect.width * (i + 0.5) / columns;
    var y = rect.top + rect.height * 0.08;
    final random = math.Random(i * 13 + rect.left.round());
    final end = rect.bottom - rect.height * (0.08 + random.nextDouble() * 0.3);
    while (y < end) {
      final h = rect.height * (0.04 + random.nextDouble() * 0.04);
      a.hairline(Offset(x, y), Offset(x, y + h), ink, 0.35);
      y += h + rect.height * 0.03;
    }
  }
}

// ---------------------------------------------------------------------------
// Scenes

void _court(Art a) {
  // Winter sky and the Yi mountains, faint.
  a
    ..fade(a.r(0, 0, 1, 0.7), _skyHigh, _sky)
    ..path(
      a.poly([
        a.p(0, 0.56),
        a.p(0.14, 0.44),
        a.p(0.3, 0.52),
        a.p(0.5, 0.4),
        a.p(0.7, 0.5),
        a.p(0.86, 0.42),
        a.p(1, 0.5),
        a.p(1, 0.7),
        a.p(0, 0.7),
      ]),
      _hills,
      line: 0,
    )
    // The snowy court.
    ..fade(a.r(0, 0.66, 1, 0.34), _snowShade, _snow)
    // The paved way to the tower, swept.
    ..path(
      a.poly([a.p(0.44, 0.76), a.p(0.56, 0.76), a.p(0.68, 1), a.p(0.32, 1)]),
      const Color(0xFF9EA2A6),
      line: 0,
    );
  for (var i = 1; i < 6; i++) {
    final y = 0.76 + i * 0.045;
    final spread = 0.06 + (y - 0.76) * 0.5;
    a.hairline(
      a.p(0.5 - spread, y),
      a.p(0.5 + spread, y),
      const Color(0xFF7A7E82),
      0.25,
    );
  }

  // Far left, a pine behind the side hall.
  _pineTree(a, a.p(0.25, 0.7), a.size.height * 0.46);

  // The side hall, where the archive is kept.
  a
    ..box(a.r(0, 0.3, 0.2, 0.44), _red, line: 0.5)
    ..fill(a.r(0, 0.7, 0.2, 0.04), _stoneDark);
  _roof(a, a.r(-0.03, 0.2, 0.26, 0.1), _greyTile, inset: 0.1);
  final door = a.r(0.035, 0.36, 0.13, 0.34);
  a.box(door, const Color(0xFF5A3A26), line: 0.5);
  for (var i = 1; i < 6; i++) {
    a.hairline(
      Offset(door.left + door.width * i / 6, door.top + door.height * 0.04),
      Offset(door.left + door.width * i / 6, door.top + door.height * 0.6),
      const Color(0xFF2A1A10),
      0.3,
    );
  }
  for (var i = 1; i < 6; i++) {
    a.hairline(
      Offset(door.left, door.top + door.height * 0.1 * i),
      Offset(door.right, door.top + door.height * 0.1 * i),
      const Color(0xFF2A1A10),
      0.3,
    );
  }
  a
    ..line(
      door.topCenter,
      door.bottomCenter,
      const Color(0xFF2A1A10),
      width: 0.4,
    )
    ..glow(door.center, door.width * 0.5, _lamp, strength: 0.18);

  // The square wall of the tower, and the tunnel down to the crypt.
  final base = a.r(0.3, 0.46, 0.4, 0.3);
  a.box(base, _stone, line: 0.6);
  for (var i = 1; i < 8; i++) {
    final y = base.top + base.height * i / 8;
    a.hairline(Offset(base.left, y), Offset(base.right, y), _stoneDark, 0.2);
  }
  a.line(base.topLeft, base.topRight, _snow, width: 1.2);
  final tunnel = Path()
    ..moveTo(a.p(0.44, 0.76).dx, a.p(0.44, 0.76).dy)
    ..lineTo(a.p(0.44, 0.63).dx, a.p(0.44, 0.63).dy)
    ..arcToPoint(a.p(0.56, 0.63), radius: Radius.circular(a.size.width * 0.06))
    ..lineTo(a.p(0.56, 0.76).dx, a.p(0.56, 0.76).dy)
    ..close();
  a.path(tunnel, const Color(0xFF14161A), line: 0.6);
  for (var i = 0; i < 4; i++) {
    final y = 0.7 + i * 0.018;
    a.hairline(
      a.p(0.455 + i * 0.008, y),
      a.p(0.545 - i * 0.008, y),
      const Color(0xFF3A3C40),
      0.35,
    );
  }
  a.glow(a.p(0.5, 0.68), a.size.width * 0.05, _lamp, strength: 0.25);

  // The stele tower: red walls, an arched opening, the stele inside.
  a.box(a.r(0.37, 0.2, 0.26, 0.27), _red, line: 0.6);
  final opening = Path()
    ..moveTo(a.p(0.445, 0.47).dx, a.p(0.445, 0.47).dy)
    ..lineTo(a.p(0.445, 0.29).dx, a.p(0.445, 0.29).dy)
    ..arcToPoint(
      a.p(0.555, 0.29),
      radius: Radius.circular(a.size.width * 0.055),
    )
    ..lineTo(a.p(0.555, 0.47).dx, a.p(0.555, 0.47).dy)
    ..close();
  a.path(opening, const Color(0xFF1E1614), line: 0.5);
  final stele = a.r(0.468, 0.27, 0.064, 0.2);
  a
    ..rbox(stele, a.u * 1.2, const Color(0xFFC4BEB0), line: 0.4)
    ..box(
      Rect.fromLTWH(stele.left, stele.top, stele.width, stele.height * 0.2),
      const Color(0xFFB0A898),
      line: 0.3,
    );
  _columns(
    a,
    Rect.fromLTWH(
      stele.left + stele.width * 0.2,
      stele.top + stele.height * 0.26,
      stele.width * 0.6,
      stele.height * 0.66,
    ),
    const Color(0xFF4A4238),
    columns: 3,
  );
  _roof(a, a.r(0.32, 0.14, 0.36, 0.07), _tile);
  _roof(a, a.r(0.39, 0.06, 0.22, 0.08), _tile, inset: 0.22);
  a.line(a.p(0.41, 0.2), a.p(0.59, 0.2), _tileDark, width: 0.8);

  // Pines beside the tower.
  _pineTree(a, a.p(0.73, 0.72), a.size.height * 0.62);
  _pineTree(a, a.p(0.66, 0.74), a.size.height * 0.4);

  // The work-room put up for the tests: panels, a lit window, a stovepipe.
  final hut = a.r(0.8, 0.32, 0.2, 0.42);
  a.box(hut, _panel, line: 0.6);
  for (var i = 1; i < 5; i++) {
    a.hairline(
      Offset(hut.left + hut.width * i / 5, hut.top),
      Offset(hut.left + hut.width * i / 5, hut.bottom),
      const Color(0xFF8A969E),
      0.25,
    );
  }
  a
    ..box(a.r(0.79, 0.3, 0.22, 0.025), const Color(0xFF4A5058), line: 0.4)
    ..line(a.p(0.79, 0.3), a.p(1, 0.3), _snow, width: 1)
    ..box(a.r(0.832, 0.4, 0.065, 0.32), const Color(0xFF8A9AA6), line: 0.5)
    ..circle(a.p(0.89, 0.56), a.u * 0.5, const Color(0xFF3A3A3E), line: 0)
    ..box(a.r(0.91, 0.4, 0.07, 0.1), const Color(0xFFF2D890), line: 0.5)
    ..glow(a.p(0.945, 0.45), a.size.width * 0.06, _lamp, strength: 0.4)
    ..line(a.p(0.945, 0.4), a.p(0.945, 0.5), const Color(0xFF6A6A6A))
    ..box(a.r(0.955, 0.2, 0.014, 0.1), const Color(0xFF5A5A5E), line: 0.3);
  for (var i = 0; i < 3; i++) {
    a.canvas.drawCircle(
      a.p(0.962 - i * 0.012, 0.18 - i * 0.035),
      a.u * (1 + i * 0.6),
      Paint()..color = _snow.withValues(alpha: 0.35 - i * 0.08),
    );
  }
  // Its power cable, across the snow to the tower.
  a.strokePath(
    Path()
      ..moveTo(a.p(0.8, 0.72).dx, a.p(0.8, 0.72).dy)
      ..quadraticBezierTo(
        a.p(0.7, 0.88).dx,
        a.p(0.7, 0.88).dy,
        a.p(0.57, 0.765).dx,
        a.p(0.57, 0.765).dy,
      ),
    const Color(0xFF1A1A1C),
    width: 0.4,
  );

  // The notice board on its posts.
  a
    ..box(a.r(0.212, 0.56, 0.008, 0.16), const Color(0xFF4A3524), line: 0.3)
    ..box(a.r(0.32, 0.56, 0.008, 0.16), const Color(0xFF4A3524), line: 0.3)
    ..wood(a.r(0.2, 0.5, 0.14, 0.1), base: const Color(0xFF5A4028), grain: 2)
    ..paper(
      a.r(0.214, 0.51, 0.11, 0.08),
      lines: 4,
      color: const Color(0xFFEDEBE4),
    )
    ..circle(a.p(0.31, 0.575), a.u * 0.9, _vermilion.withValues(alpha: 0.8))
    ..line(a.p(0.2, 0.5), a.p(0.34, 0.5), _snow, width: 1);

  // The stone altar of five offerings.
  a
    ..box(a.r(0.6, 0.7, 0.16, 0.03), _marble, line: 0.5)
    ..box(a.r(0.61, 0.73, 0.02, 0.04), _stone, line: 0.4)
    ..box(a.r(0.73, 0.73, 0.02, 0.04), _stone, line: 0.4)
    ..box(a.r(0.66, 0.655, 0.04, 0.045), _stone, line: 0.4)
    ..box(a.r(0.655, 0.645, 0.05, 0.012), _stone, line: 0.4)
    ..box(a.r(0.636, 0.64, 0.008, 0.06), _stone, line: 0.3)
    ..box(a.r(0.716, 0.64, 0.008, 0.06), _stone, line: 0.3)
    ..oval(a.r(0.608, 0.66, 0.018, 0.04), _stone, line: 0.3)
    ..oval(a.r(0.734, 0.66, 0.018, 0.04), _stone, line: 0.3)
    ..line(a.p(0.6, 0.7), a.p(0.76, 0.7), _snow, width: 0.8)
    ..fill(a.r(0.664, 0.648, 0.032, 0.006), _snow);

  // Dry grass through the snow.
  final random = math.Random(3);
  for (var i = 0; i < 40; i++) {
    final x = random.nextDouble();
    if (x > 0.3 && x < 0.7) continue;
    final y = 0.82 + random.nextDouble() * 0.16;
    a.hairline(
      a.p(x, y),
      a.p(x + (random.nextDouble() - 0.5) * 0.01, y - 0.03),
      const Color(0xFF8A7A58),
      0.25,
    );
  }
  _snowfall(a);
}

void _crypt(Art a) {
  a.fill(Offset.zero & a.size, const Color(0xFF26262A));
  // The barrel vault, marble blocks in the lamp's light.
  final vault = Path()
    ..moveTo(a.p(0.08, 0.8).dx, a.p(0.08, 0.8).dy)
    ..lineTo(a.p(0.08, 0.36).dx, a.p(0.08, 0.36).dy)
    ..arcToPoint(a.p(0.92, 0.36), radius: Radius.circular(a.size.width * 0.42))
    ..lineTo(a.p(0.92, 0.8).dx, a.p(0.92, 0.8).dy)
    ..close();
  a.path(vault, const Color(0xFF6E6C66), line: 0.6);
  a.canvas
    ..save()
    ..clipPath(vault);
  for (var i = 0; i < 16; i++) {
    final y = 0.02 + i * 0.05;
    a.hairline(a.p(0, y), a.p(1, y), const Color(0xFF4E4C48), 0.25);
    for (var k = 0; k < 8; k++) {
      final x = (k + (i.isEven ? 0 : 0.5)) / 8 + 0.02;
      a.hairline(a.p(x, y), a.p(x, y + 0.05), const Color(0xFF4E4C48), 0.2);
    }
  }
  a.canvas.restore();
  // The floor, stone slabs.
  a.fill(a.r(0, 0.8, 1, 0.2), const Color(0xFF4A4844));
  for (var i = 1; i < 4; i++) {
    a.hairline(
      a.p(0, 0.8 + i * 0.05),
      a.p(1, 0.8 + i * 0.05),
      const Color(0xFF35332F),
      0.3,
    );
  }
  // The work lamp on its cable.
  a
    ..line(a.p(0.5, 0), a.p(0.5, 0.12), const Color(0xFF1A1A1C))
    ..glow(
      a.p(0.5, 0.2),
      a.size.width * 0.42,
      const Color(0xFFF4E8C8),
      strength: 0.32,
    )
    ..path(
      a.poly([
        a.p(0.485, 0.12),
        a.p(0.515, 0.12),
        a.p(0.53, 0.16),
        a.p(0.47, 0.16),
      ]),
      const Color(0xFF3A3C40),
      line: 0.4,
    )
    ..oval(a.r(0.485, 0.155, 0.03, 0.015), const Color(0xFFFFF4D8), line: 0);

  // An open marble door, each leaf one slab, rows of carved studs.
  a.box(a.r(0.03, 0.18, 0.15, 0.62), const Color(0xFF121214), line: 0.5);
  final leaf = a.poly([
    a.p(0.04, 0.16),
    a.p(0.19, 0.22),
    a.p(0.19, 0.8),
    a.p(0.04, 0.84),
  ]);
  a.path(leaf, _marble, line: 0.6);
  for (var row = 0; row < 7; row++) {
    for (var col = 0; col < 4; col++) {
      final x = 0.06 + col * 0.034;
      final t = (x - 0.04) / 0.15;
      final top = 0.16 + 0.06 * t;
      final bottom = 0.84 - 0.04 * t;
      final y = top + (bottom - top) * (0.12 + row * 0.12);
      a.circle(a.p(x, y), a.u * 0.55, const Color(0xFFB0AA9C), line: 0.2);
    }
  }

  // The coffin bed of pale stone.
  a
    ..box(a.r(0.26, 0.72, 0.48, 0.1), _marble, line: 0.6)
    ..box(a.r(0.26, 0.72, 0.48, 0.02), const Color(0xFFD8D4C8), line: 0.3);
  for (var i = 0; i < 12; i++) {
    a.hairline(
      a.p(0.28 + i * 0.038, 0.76),
      a.p(0.3 + i * 0.038, 0.8),
      const Color(0xFF9A968A),
      0.25,
    );
  }
  // The empress's coffin, behind.
  _coffin(a, 0.6, 0.74, 0.55, const Color(0xFF3E1E16));
  // The emperor's coffin: dark lacquer, gold bands, the axe cuts mended.
  _coffin(a, 0.32, 0.67, 0.48, const Color(0xFF5A2A1E));
  for (final x in [0.38, 0.5, 0.62]) {
    a.line(a.p(x, 0.52 - (0.62 - x) * 0.1), a.p(x, 0.72), _gold, width: 0.6);
  }
  for (final (x, y) in [
    (0.43, 0.56),
    (0.46, 0.6),
    (0.55, 0.58),
    (0.57, 0.64),
  ]) {
    a
      ..line(
        a.p(x, y),
        a.p(x + 0.03, y + 0.02),
        const Color(0xFFA07A50),
        width: 0.5,
      )
      ..line(
        a.p(x + 0.004, y + 0.012),
        a.p(x + 0.012, y + 0.002),
        const Color(0xFF3A1A10),
        width: 0.3,
      );
  }

  // The clearance record on a stand.
  a
    ..line(a.p(0.82, 0.58), a.p(0.785, 0.8), const Color(0xFF2A2A2C))
    ..line(a.p(0.82, 0.58), a.p(0.855, 0.8), const Color(0xFF2A2A2C))
    ..line(a.p(0.82, 0.58), a.p(0.82, 0.8), const Color(0xFF2A2A2C))
    ..box(a.r(0.772, 0.46, 0.096, 0.13), const Color(0xFF7A5A3A), line: 0.5)
    ..paper(
      a.r(0.78, 0.475, 0.08, 0.105),
      lines: 5,
      color: const Color(0xFFEDEBE4),
    )
    ..box(a.r(0.805, 0.455, 0.03, 0.015), const Color(0xFF9A9CA0), line: 0.3);
}

/// A Chinese coffin seen from the side, from [left] to [right], its top
/// at [top] over the head end: the head end higher, the lid bulging and
/// overhanging both ends.
void _coffin(Art a, double left, double right, double top, Color lacquer) {
  const bottom = 0.72;
  final w = right - left;
  final foot = top + (bottom - top) * 0.28;
  a
    ..path(
      a.poly([
        a.p(left + w * 0.02, top + 0.02),
        a.p(right - w * 0.03, foot + 0.02),
        a.p(right - w * 0.05, bottom),
        a.p(left + w * 0.04, bottom),
      ]),
      lacquer,
      line: 0.6,
    )
    ..path(
      Path()
        ..moveTo(
          a.p(left - w * 0.03, top + 0.03).dx,
          a.p(left - w * 0.03, top + 0.03).dy,
        )
        ..quadraticBezierTo(
          a.p(left + w * 0.3, top - 0.05).dx,
          a.p(left + w * 0.3, top - 0.05).dy,
          a.p(right + w * 0.01, foot).dx,
          a.p(right + w * 0.01, foot).dy,
        )
        ..lineTo(
          a.p(right - w * 0.02, foot + 0.025).dx,
          a.p(right - w * 0.02, foot + 0.025).dy,
        )
        ..quadraticBezierTo(
          a.p(left + w * 0.3, top - 0.01).dx,
          a.p(left + w * 0.3, top - 0.01).dy,
          a.p(left - w * 0.01, top + 0.05).dx,
          a.p(left - w * 0.01, top + 0.05).dy,
        )
        ..close(),
      Color.lerp(lacquer, const Color(0xFFB0603A), 0.25)!,
      line: 0.5,
    );
}

void _archive(Art a) {
  a
    ..fade(a.r(0, 0, 1, 0.8), const Color(0xFF6E6A62), const Color(0xFF8A857A))
    ..fill(a.r(0, 0.8, 1, 0.2), const Color(0xFF55524C))
    ..hairline(a.p(0, 0.8), a.p(1, 0.8), const Color(0xFF3A3834), 0.4);

  // Steel shelves of archive boxes.
  final shelf = a.r(0.04, 0.06, 0.28, 0.46);
  a
    ..line(shelf.topLeft, shelf.bottomLeft, const Color(0xFF55595E), width: 0.8)
    ..line(
      shelf.topRight,
      shelf.bottomRight,
      const Color(0xFF55595E),
      width: 0.8,
    );
  final random = math.Random(11);
  for (var row = 0; row < 3; row++) {
    final bottom = shelf.top + shelf.height * (row + 1) / 3;
    a.box(
      Rect.fromLTWH(shelf.left, bottom - a.u * 0.8, shelf.width, a.u * 0.8),
      const Color(0xFF6A6E72),
      line: 0.3,
    );
    var x = shelf.left + a.u * 0.6;
    while (x < shelf.right - a.u * 5) {
      final w = a.size.width * (0.03 + random.nextDouble() * 0.012);
      final h = shelf.height / 3 * (0.6 + random.nextDouble() * 0.2);
      final box = Rect.fromLTWH(x, bottom - a.u * 0.8 - h, w, h);
      a
        ..box(
          box,
          Color.lerp(
            const Color(0xFF9A8C6E),
            const Color(0xFFB0A280),
            random.nextDouble(),
          )!,
          line: 0.35,
        )
        ..fill(
          Rect.fromLTWH(
            box.left + w * 0.2,
            box.top + h * 0.2,
            w * 0.6,
            h * 0.22,
          ),
          const Color(0xFFE8E4D8),
        )
        ..hairline(
          Offset(box.left, box.center.dy + h * 0.1),
          Offset(box.right, box.center.dy + h * 0.1),
          const Color(0xFFD8CFA8),
          0.3,
        );
      x += w + a.u * 0.4;
    }
  }

  // The window, snow outside, the stele tower across the court.
  final window = a.r(0.4, 0.08, 0.2, 0.3);
  a
    ..fade(window, const Color(0xFF9AA2AA), const Color(0xFFD4D8DC))
    ..box(a.r(0.47, 0.22, 0.06, 0.1), _red, line: 0.3);
  _roof(a, a.r(0.455, 0.19, 0.09, 0.035), _tile, inset: 0.18);
  a
    ..fill(a.r(0.4, 0.32, 0.2, 0.06), _snow)
    ..ink(window, width: 0.8)
    ..line(
      window.topCenter,
      window.bottomCenter,
      const Color(0xFF4A3A2A),
      width: 0.8,
    )
    ..line(
      window.centerLeft,
      window.centerRight,
      const Color(0xFF4A3A2A),
      width: 0.8,
    )
    ..box(a.r(0.39, 0.38, 0.22, 0.02), const Color(0xFFD8D8D8), line: 0.4);
  _snowfall(a, count: 30, seed: 5, within: window.deflate(a.u));

  // The pin board on the right wall (the cuttings arrive later).
  a
    ..box(a.r(0.72, 0.22, 0.18, 0.24), const Color(0xFFA07E56), line: 0.6)
    ..circle(a.p(0.76, 0.3), a.u * 0.5, _vermilion, line: 0.2)
    ..circle(a.p(0.86, 0.4), a.u * 0.5, const Color(0xFF3A5A8A), line: 0.2);

  // The long table.
  a
    ..wood(a.r(0.1, 0.7, 0.78, 0.04), base: const Color(0xFF5A4028), grain: 2)
    ..box(a.r(0.12, 0.74, 0.02, 0.12), const Color(0xFF3A2A1C), line: 0.4)
    ..box(a.r(0.84, 0.74, 0.02, 0.12), const Color(0xFF3A2A1C), line: 0.4);
  // The court's announcement: yellow paper, columns of brush writing.
  final decree = a.r(0.17, 0.585, 0.16, 0.11);
  a.box(decree, _imperial, line: 0.4);
  _columns(a, decree.deflate(a.u), const Color(0xFF2A2018), columns: 8);
  // The physicians' records: thread-bound books in blue covers.
  for (var i = 0; i < 3; i++) {
    final book = a.r(0.41 + i * 0.004, 0.66 - i * 0.03, 0.16, 0.03);
    a
      ..box(book, const Color(0xFF34466A), line: 0.4)
      ..fill(
        Rect.fromLTWH(
          book.left + book.width * 0.7,
          book.top + book.height * 0.2,
          book.width * 0.08,
          book.height * 0.6,
        ),
        const Color(0xFFE8E4D8),
      );
  }
  // The memoir, a printed book lying open.
  a
    ..paper(
      a.r(0.65, 0.61, 0.07, 0.085),
      lines: 6,
      color: const Color(0xFFE6E0D0),
    )
    ..paper(
      a.r(0.72, 0.61, 0.07, 0.085),
      lines: 6,
      color: const Color(0xFFE6E0D0),
    )
    ..line(a.p(0.72, 0.61), a.p(0.72, 0.695), const Color(0xFF6A6254));
  // A desk lamp.
  a
    ..line(a.p(0.84, 0.7), a.p(0.83, 0.6), const Color(0xFF2A2A2C), width: 0.6)
    ..path(
      a.poly([a.p(0.81, 0.6), a.p(0.85, 0.6), a.p(0.86, 0.63), a.p(0.8, 0.63)]),
      const Color(0xFF2E4A3A),
      line: 0.4,
    )
    ..glow(a.p(0.83, 0.66), a.size.width * 0.12, _lamp, strength: 0.3);
}

void _lab(Art a) {
  a
    ..fade(a.r(0, 0, 1, 0.82), const Color(0xFF9CA6AA), const Color(0xFFB8C0C2))
    ..fill(a.r(0, 0.82, 1, 0.18), const Color(0xFF6A6E70))
    ..hairline(a.p(0, 0.82), a.p(1, 0.82), const Color(0xFF4A4E50), 0.4);
  for (var i = 1; i < 8; i++) {
    a.hairline(a.p(i / 8, 0), a.p(i / 8, 0.82), const Color(0xFF8E989C), 0.2);
  }
  // The strip light.
  a
    ..box(a.r(0.3, 0.02, 0.4, 0.018), _tube, line: 0.4)
    ..glow(a.p(0.5, 0.05), a.size.width * 0.5, _tube, strength: 0.3);

  // The reactor's data sheets pinned up.
  for (var i = 0; i < 3; i++) {
    final sheet = a.r(
      0.125 + i * 0.07,
      0.13 + (i.isOdd ? 0.02 : 0),
      0.065,
      0.18,
    );
    a.box(sheet, const Color(0xFFF0EEE8), line: 0.4);
    final random = math.Random(i + 2);
    final points = [
      for (var k = 0; k < 9; k++)
        Offset(
          sheet.left + sheet.width * (0.1 + k * 0.1),
          sheet.bottom -
              sheet.height *
                  (0.15 + (k == 4 + i % 2 ? 0.55 : random.nextDouble() * 0.15)),
        ),
    ];
    a
      ..hairline(
        Offset(
          sheet.left + sheet.width * 0.1,
          sheet.bottom - sheet.height * 0.1,
        ),
        Offset(
          sheet.right - sheet.width * 0.05,
          sheet.bottom - sheet.height * 0.1,
        ),
        const Color(0xFF5A5A5A),
        0.25,
      )
      ..strokePath(
        Path()..addPolygon(points, false),
        const Color(0xFF2A3A6A),
        width: 0.3,
      )
      ..circle(
        Offset(sheet.center.dx, sheet.top + a.u * 0.6),
        a.u * 0.4,
        _vermilion,
        line: 0,
      );
  }

  // The window, snow outside.
  final window = a.r(0.46, 0.14, 0.14, 0.18);
  a
    ..fade(window, const Color(0xFF8E98A2), const Color(0xFFD8DCE0))
    ..fill(
      Rect.fromLTWH(
        window.left,
        window.bottom - window.height * 0.22,
        window.width,
        window.height * 0.22,
      ),
      _snow,
    )
    ..ink(window, width: 0.7)
    ..line(window.topCenter, window.bottomCenter, const Color(0xFF5A6066));
  _snowfall(a, count: 20, seed: 4, within: window.deflate(a.u));

  // The bench and the sample rack.
  a
    ..box(a.r(0.04, 0.62, 0.36, 0.035), const Color(0xFFD0D4D4), line: 0.5)
    ..box(a.r(0.05, 0.655, 0.34, 0.165), const Color(0xFF8A9296), line: 0.5)
    ..line(a.p(0.22, 0.655), a.p(0.22, 0.82), const Color(0xFF5A6064))
    ..box(a.r(0.12, 0.575, 0.22, 0.045), const Color(0xFFF2F2EE), line: 0.4);
  for (var i = 0; i < 8; i++) {
    final x = 0.132 + i * 0.026;
    final tube = a.r(x, 0.48, 0.014, 0.12);
    a.rbox(tube, a.u * 0.6, const Color(0xCCDCE8EC), line: 0.3);
    final curl = Path()..moveTo(tube.center.dx, tube.top + tube.height * 0.3);
    for (var k = 0; k < 4; k++) {
      curl.relativeQuadraticBezierTo(
        (k.isEven ? 1 : -1) * tube.width * 0.35,
        tube.height * 0.08,
        0,
        tube.height * 0.14,
      );
    }
    a
      ..strokePath(curl, const Color(0xFF15110D), width: 0.25)
      ..box(
        Rect.fromLTWH(
          tube.left - a.u * 0.1,
          tube.top - a.u * 0.6,
          tube.width + a.u * 0.2,
          a.u * 0.8,
        ),
        i < 4 ? const Color(0xFF3A6A9A) : const Color(0xFF9A3A3A),
        line: 0.2,
      );
  }

  // The steel table, the robe laid on it, the probe on its arm.
  a
    ..box(a.r(0.42, 0.66, 0.4, 0.03), const Color(0xFFA8B0B4), line: 0.5)
    ..box(a.r(0.44, 0.69, 0.012, 0.13), const Color(0xFF6A7276), line: 0.3)
    ..box(a.r(0.8, 0.69, 0.012, 0.13), const Color(0xFF6A7276), line: 0.3);
  final robe = a.poly([
    a.p(0.58, 0.52),
    a.p(0.66, 0.52),
    a.p(0.78, 0.56),
    a.p(0.78, 0.6),
    a.p(0.69, 0.585),
    a.p(0.7, 0.665),
    a.p(0.54, 0.665),
    a.p(0.55, 0.585),
    a.p(0.46, 0.6),
    a.p(0.46, 0.56),
  ]);
  a.path(robe, _robe, line: 0.5);
  for (final (x, y) in [
    (0.62, 0.56),
    (0.58, 0.62),
    (0.66, 0.62),
    (0.5, 0.575),
    (0.74, 0.575),
  ]) {
    a.circle(a.p(x, y), a.u * 0.9, _robe, line: 0);
    a.canvas.drawCircle(
      a.p(x, y),
      a.u * 0.9,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = a.u * 0.25
        ..color = _gold,
    );
  }
  a.line(a.p(0.62, 0.53), a.p(0.62, 0.665), _gold, width: 0.3);
  a
    ..box(a.r(0.795, 0.42, 0.014, 0.24), const Color(0xFF55595E), line: 0.4)
    ..line(a.p(0.8, 0.43), a.p(0.66, 0.45), const Color(0xFF55595E), width: 1.2)
    ..path(
      a.poly([
        a.p(0.65, 0.44),
        a.p(0.675, 0.44),
        a.p(0.668, 0.49),
        a.p(0.657, 0.49),
      ]),
      const Color(0xFF3A3C40),
      line: 0.4,
    )
    ..circle(a.p(0.6625, 0.495), a.u * 0.35, const Color(0xFFD8B25A), line: 0);

  // The oil heater, its light on.
  final heater = a.r(0.87, 0.66, 0.08, 0.16);
  a.rbox(heater, a.u, const Color(0xFFDCD8D0), line: 0.5);
  for (var i = 1; i < 6; i++) {
    a.hairline(
      Offset(heater.left + heater.width * i / 6, heater.top + a.u),
      Offset(heater.left + heater.width * i / 6, heater.bottom - a.u),
      const Color(0xFF9A968E),
      0.3,
    );
  }
  a
    ..circle(
      heater.topRight.translate(-a.u * 1.4, a.u * 1.4),
      a.u * 0.4,
      const Color(0xFFE88A2A),
      line: 0,
    )
    ..glow(
      heater.center,
      heater.height,
      const Color(0xFFE88A2A),
      strength: 0.12,
    );
}

void _benchBoard(Art a, {bool robe = false}) {
  a
    ..fill(
      Offset.zero & a.size,
      robe ? const Color(0xFF1C1F24) : const Color(0xFF22262A),
    )
    ..glow(a.p(0.5, 0), a.size.width * 0.6, _tube, strength: 0.12)
    ..fade(
      Offset.zero & a.size,
      const Color(0x00000000),
      const Color(0x55000000),
    );
}

// ---------------------------------------------------------------------------
// Objects

/// Newspaper cuttings of 2008, pinned to the board.
void _cuttings(Art a) {
  for (final (i, (x, y, w, h, angle)) in [
    (0.04, 0.06, 0.5, 0.6, -0.05),
    (0.44, 0.14, 0.5, 0.52, 0.04),
    (0.2, 0.44, 0.56, 0.5, -0.02),
  ].indexed) {
    final r = a.r(x, y, w, h);
    a.canvas
      ..save()
      ..translate(r.center.dx, r.center.dy)
      ..rotate(angle);
    final local = Rect.fromCenter(
      center: Offset.zero,
      width: r.width,
      height: r.height,
    );
    a
      ..box(local, const Color(0xFFDAD6CA), line: 0.4)
      ..fill(
        Rect.fromLTWH(
          local.left + local.width * 0.1,
          local.top + local.height * 0.1,
          local.width * 0.8,
          local.height * 0.14,
        ),
        const Color(0xFF3A3632),
      );
    for (var col = 0; col < 3; col++) {
      for (var k = 0; k < 5; k++) {
        final lx = local.left + local.width * (0.1 + col * 0.28);
        final ly = local.top + local.height * (0.36 + k * 0.12);
        a.hairline(
          Offset(lx, ly),
          Offset(lx + local.width * 0.22, ly),
          const Color(0xFF6A6660),
          0.3,
        );
      }
    }
    a.circle(
      Offset(0, local.top + a.u * 1.5),
      a.u * 1.2,
      i == 1 ? const Color(0xFF3A5A8A) : _vermilion,
      line: 0.2,
    );
    a.canvas.restore();
  }
}

/// The report of November 2008: a stapled paper, a blue heading band, and
/// an official red seal.
void _report(Art a) {
  final sheet = a.r(0.12, 0.06, 0.76, 0.9);
  a
    ..box(sheet, const Color(0xFFF2F0EA), line: 0.5)
    ..fill(
      Rect.fromLTWH(
        sheet.left,
        sheet.top + sheet.height * 0.08,
        sheet.width,
        sheet.height * 0.1,
      ),
      const Color(0xFF34466A),
    );
  for (var k = 0; k < 8; k++) {
    final y = sheet.top + sheet.height * (0.26 + k * 0.075);
    a.hairline(
      Offset(sheet.left + sheet.width * 0.1, y),
      Offset(sheet.right - sheet.width * (k.isOdd ? 0.2 : 0.1), y),
      const Color(0xFF6A6660),
      0.35,
    );
  }
  a
    ..circle(
      Offset(
        sheet.right - sheet.width * 0.25,
        sheet.bottom - sheet.height * 0.13,
      ),
      sheet.width * 0.13,
      _vermilion.withValues(alpha: 0.2),
      line: 0,
    )
    ..canvas.drawCircle(
      Offset(
        sheet.right - sheet.width * 0.25,
        sheet.bottom - sheet.height * 0.13,
      ),
      sheet.width * 0.13,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = a.u * 1.2
        ..color = _vermilion.withValues(alpha: 0.85),
    );
  a
    ..line(
      sheet.topLeft.translate(sheet.width * 0.08, sheet.height * 0.03),
      sheet.topLeft.translate(sheet.width * 0.18, sheet.height * 0.03),
      const Color(0xFF8A8C90),
      width: 0.6,
    )
    ..circle(a.p(0.5, 0.05), a.u * 2.2, const Color(0xFF3A5A8A), line: 0.3);
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
  a
    ..fade(a.r(0, 0.16, 1, 0.6), _skyHigh, _sky)
    ..fill(a.r(0, 0.76, 1, 0.24), _snow)
    ..box(a.r(0.2, 0.62, 0.6, 0.16), _stone, line: 0.5)
    ..box(a.r(0.3, 0.44, 0.4, 0.18), _red, line: 0.5)
    ..rbox(
      a.r(0.45, 0.48, 0.1, 0.14),
      w * 0.04,
      const Color(0xFF1E1614),
      line: 0.3,
    )
    ..box(a.r(0.475, 0.5, 0.05, 0.12), const Color(0xFFC4BEB0), line: 0.2);
  _roof(a, a.r(0.18, 0.36, 0.64, 0.08), _tile);
  _roof(a, a.r(0.3, 0.27, 0.4, 0.09), _tile, inset: 0.2);
  _pineTree(a, a.p(0.86, 0.8), h * 0.5);
  _snowfall(a, count: 40, seed: 9);
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
  a.box(a.r(0.3, 0.04, 0.4, 0.14), _vermilion, line: 0.5);
}
