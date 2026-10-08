import 'dart:math' as math;
import 'dart:ui';

import '../theme/stillroom_palette.dart';
import 'art_kit.dart';
import 'depth_kit.dart';
import 'echo_art.dart';
import 'whitechapel_1888_art.dart' show jarLabelBoard;

/// Code-drawn art for "Great Zimbabwe, 1871"
/// (docs/episodes/great_zimbabwe_1871.md): the ruins in September 1871,
/// at the end of the dry season. The great enclosure's outer wall with its
/// chevron band, Mauch's camp under the msasa trees, the conical tower
/// inside, and the hill where the soapstone birds stand on their pillars.
const _s = 'images/scenes/great_zimbabwe_1871';
const _o = 'images/objects/great_zimbabwe_1871';

final Map<String, ArtPainter> greatZimbabwe1871Art = {
  // Scenes and puzzle boards.
  '$_s/valley.png': (c, s) => _valley(Art(c, s)),
  '$_s/camp.png': (c, s) => _camp(Art(c, s)),
  '$_s/enclosure.png': (c, s) => _enclosure(Art(c, s)),
  '$_s/hill.png': (c, s) => _hill(Art(c, s)),
  '$_s/courses_board.png': (c, s) => _coursesBoard(Art(c, s)),
  '$_s/identify_board.png': (c, s) => _identifyBoard(Art(c, s)),
  '$_s/label_close.png': (c, s) => jarLabelBoard(Art(c, s), _graniteDark),
  // Objects.
  '$_o/rubble_sprite.png': (c, s) => _rubble(Art(c, s)),
  '$_o/mended_sprite.png': (c, s) => _mended(Art(c, s)),
  '$_o/report_sprite.png': (c, s) => _papers(Art(c, s), seed: 3),
  '$_o/later_sprite.png': (c, s) => _papers(Art(c, s), seed: 7),
  '$_o/echo_builder.png': (c, s) => paintEcho(Art(c, s), EchoFigure.builder),
  '$_o/echo_hunter.png': (c, s) => paintEcho(Art(c, s), EchoFigure.hunter),
  // The jar on the shelf.
  'images/ui/jar_great_zimbabwe_1871.png': (c, s) => _jar(Art(c, s)),
};

// ---------------------------------------------------------------------------
// Palette

const _skyHigh = Color(0xFF8AA2B8);
const _sky = Color(0xFFD8D2C0);
const _hills = Color(0xFF9A9078);
const _granite = Color(0xFFA9A190);
const _graniteDark = Color(0xFF5E584C);
const _graniteShade = Color(0xFF7E7666);
const _grass = Color(0xFFC2A86A);
const _grassDark = Color(0xFF9A8248);
const _earth = Color(0xFF8A6A48);
const _msasa = Color(0xFFB0402A);
const _msasaDark = Color(0xFF7A2A1E);
const _leaf = Color(0xFF5E6A3A);
const _bark = Color(0xFF4A3A2C);
const _canvas = Color(0xFFD8CCAE);
const _wood = Color(0xFF6A4A2E);
const _tambootie = Color(0xFF5A3020);
const _paper = Color(0xFFE6DAB8);
const _soapstone = Color(0xFF8C8A6E);
const _lamp = StillroomPalette.gaslight;

// ---------------------------------------------------------------------------
// Shared pieces

/// Courses of granite blocks filling [r]: level rows, joints staggered, a
/// little uneven, as the builders laid them.
void _coursed(Art a, Rect r, {int seed = 1, double row = 2.2}) {
  a.fill(r, _granite);
  final random = math.Random(seed);
  final h = a.u * row;
  for (var y = r.top, k = 0; y < r.bottom; y += h, k++) {
    a.hairline(
      Offset(r.left, y),
      Offset(r.right, y),
      const Color(0x99403A30),
      0.25,
    );
    var x = r.left - random.nextDouble() * h * 2;
    while (x < r.right) {
      final w = h * (1.4 + random.nextDouble() * 1.4);
      final block = Rect.fromLTWH(x, y, w, h);
      if (random.nextDouble() < 0.4) {
        a.canvas.drawRect(
          block.intersect(r),
          Paint()
            ..color =
                (random.nextBool() ? _graniteShade : const Color(0xFFBCB4A2))
                    .withValues(alpha: 0.35),
        );
      }
      x += w;
      if (x < r.right) {
        a.hairline(
          Offset(x, y),
          Offset(x, math.min(y + h, r.bottom)),
          const Color(0x99403A30),
          0.25,
        );
      }
    }
  }
}

/// The chevron band along a wall's top: slabs set slanting, in turn.
void _chevrons(Art a, Rect r, {int count = 18}) {
  a.fill(r, _graniteShade);
  final w = r.width / count;
  for (var k = 0; k < count; k++) {
    final lean = k.isEven ? 1.0 : -1.0;
    final cx = r.left + w * (k + 0.5);
    a.path(
      a.poly([
        Offset(cx + lean * w * 0.3 - w * 0.12, r.top),
        Offset(cx + lean * w * 0.3 + w * 0.12, r.top),
        Offset(cx - lean * w * 0.3 + w * 0.12, r.bottom),
        Offset(cx - lean * w * 0.3 - w * 0.12, r.bottom),
      ]),
      const Color(0xFFC0B8A6),
      line: 0.2,
    );
  }
}

/// A msasa tree: a dark trunk and a spreading crown, red with new leaves.
void _msasaTree(Art a, Offset base, double height, {int seed = 1}) {
  final random = math.Random(seed);
  a
    ..line(
      base,
      base.translate(height * 0.04, -height * 0.55),
      _bark,
      width: 1.4,
    )
    ..line(
      base.translate(height * 0.02, -height * 0.35),
      base.translate(-height * 0.18, -height * 0.62),
      _bark,
      width: 0.8,
    );
  for (var i = 0; i < 26; i++) {
    final c = base.translate(
      (random.nextDouble() - 0.5) * height * 0.8,
      -height * (0.55 + random.nextDouble() * 0.38),
    );
    a.oval(
      Rect.fromCenter(
        center: c,
        width: height * (0.14 + random.nextDouble() * 0.12),
        height: height * (0.08 + random.nextDouble() * 0.06),
      ),
      [_msasa, _msasaDark, const Color(0xFFC86A3A), _leaf][random.nextInt(4)],
      line: 0,
    );
  }
}

/// Dry grass along [y], tufts across the whole width.
void _dryGrass(Art a, double y, {int seed = 5, int count = 90}) {
  final random = math.Random(seed);
  for (var i = 0; i < count; i++) {
    final x = random.nextDouble() * a.size.width;
    final base = a.size.height * (y + random.nextDouble() * (1 - y));
    for (var k = -1; k <= 1; k++) {
      a.line(
        Offset(x, base),
        Offset(x + k * a.u * 0.8, base - a.u * (1.5 + random.nextDouble() * 2)),
        random.nextBool() ? _grass : _grassDark,
        width: 0.3,
      );
    }
  }
}

/// A soft shadow on the ground along a foot from [x0] to [x1] at [y].
void _groundShadow(
  Art a,
  double x0,
  double x1,
  double y, {
  double strength = 0.35,
}) => a.canvas.drawOval(
  Rect.fromLTRB(
    a.p(x0, 0).dx,
    a.p(0, y).dy - a.u * 1.4,
    a.p(x1, 0).dx,
    a.p(0, y).dy + a.u * 2.6,
  ),
  Paint()
    ..color = Color.fromRGBO(40, 30, 20, strength)
    ..maskFilter = MaskFilter.blur(BlurStyle.normal, a.u * 1.6),
);

/// A round granite boulder, its skin splitting off in sheets.
void _boulder(Art a, Rect r) {
  a
    ..oval(r, _granite, line: 0.5)
    ..canvas.drawArc(
      r.deflate(r.width * 0.1),
      3.6,
      1.6,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = a.u * 0.3
        ..color = _graniteDark,
    )
    ..glow(
      r.topCenter.translate(0, r.height * 0.25),
      r.width * 0.4,
      const Color(0xFFEDE6D4),
      strength: 0.25,
    );
}

// ---------------------------------------------------------------------------
// The valley: the great enclosure's outer wall

void _valley(Art a) {
  a
    ..fade(a.r(0, 0, 1, 0.62), _skyHigh, _sky)
    // The hill and its boulders, far off on the left.
    ..path(
      a.poly([
        a.p(0, 0.4),
        a.p(0.05, 0.24),
        a.p(0.14, 0.2),
        a.p(0.24, 0.3),
        a.p(0.34, 0.6),
        a.p(0, 0.6),
      ]),
      _hills,
      line: 0,
    );
  for (final (x, y, w) in [
    (0.03, 0.2, 0.05),
    (0.09, 0.16, 0.06),
    (0.16, 0.22, 0.04),
  ]) {
    _boulder(a, a.r(x, y, w, w * 1.2));
  }
  _msasaTree(a, a.p(0.9, 0.42), a.size.height * 0.32, seed: 3);
  a.fade(a.r(0, 0.6, 1, 0.4), _grass, const Color(0xFFAA9258));

  // The outer wall, curving away: its top an arc, its foot a gentler one,
  // its shadow along the grass.
  _groundShadow(a, 0.06, 0.82, 0.79, strength: 0.4);
  const top = 0.18;
  final wall = Path()
    ..moveTo(a.size.width * 0.08, a.size.height * 0.34)
    ..quadraticBezierTo(
      a.size.width * 0.44,
      a.size.height * (top - 0.04),
      a.size.width * 0.8,
      a.size.height * 0.3,
    )
    ..lineTo(a.size.width * 0.8, a.size.height * 0.78)
    ..quadraticBezierTo(
      a.size.width * 0.44,
      a.size.height * 0.82,
      a.size.width * 0.08,
      a.size.height * 0.76,
    )
    ..close();
  a.canvas
    ..save()
    ..clipPath(wall);
  _coursed(a, a.r(0.06, 0.1, 0.76, 0.74), seed: 11);
  // The chevron band along the top, following the curve.
  // Points along the wall's top: the same curve as its outline.
  Offset along(double t) => Offset(
    (1 - t) * (1 - t) * 0.08 + 2 * t * (1 - t) * 0.44 + t * t * 0.8,
    (1 - t) * (1 - t) * 0.34 + 2 * t * (1 - t) * (top - 0.04) + t * t * 0.3,
  );
  for (var i = 0; i < 44; i++) {
    final p = along((i + 0.5) / 44);
    final lean = i.isEven ? 1.0 : -1.0;
    final c = a.p(p.dx, p.dy + 0.03);
    final half = a.size.width * 0.004;
    final reach = a.size.height * 0.018;
    a.path(
      a.poly([
        c.translate(lean * half * 2 - half, -reach),
        c.translate(lean * half * 2 + half, -reach),
        c.translate(-lean * half * 2 + half, reach),
        c.translate(-lean * half * 2 - half, reach),
      ]),
      const Color(0xFFC0B8A6),
      line: 0.15,
    );
  }
  a
    ..fade(
      a.r(0.06, 0.1, 0.12, 0.74),
      const Color(0x44000000),
      const Color(0x44000000),
    )
    ..canvas.restore();
  a.strokePath(wall, Art.outline, width: 0.5);

  // The breach: the wall slumped from the top down, course by course,
  // its blocks fallen; the gap shows the wall's inner fill behind.
  final b = a.r(0.27, 0.2, 0.16, 0.44);
  final step = b.height / 7;
  final notch = Path()..moveTo(b.left, b.top);
  for (var k = 1; k <= 6; k++) {
    notch
      ..lineTo(b.left + b.width * 0.035 * k, b.top + step * (k - 1))
      ..lineTo(b.left + b.width * 0.035 * k, b.top + step * k);
  }
  notch.lineTo(b.center.dx, b.bottom);
  for (var k = 6; k >= 1; k--) {
    notch
      ..lineTo(b.right - b.width * 0.04 * k, b.top + step * k)
      ..lineTo(b.right - b.width * 0.04 * k, b.top + step * (k - 1));
  }
  notch
    ..lineTo(b.right, b.top)
    ..close();
  a.canvas
    ..save()
    ..clipPath(wall);
  a
    ..path(notch, const Color(0xFF6A6252), line: 0.5)
    ..fade(b, const Color(0x00000000), const Color(0x66000000));
  a.canvas.restore();

  // The narrow entrance at the wall's foot.
  final entrance = a.r(0.52, 0.5, 0.06, 0.28);
  a.box(entrance, const Color(0xFF2A241C), line: 0.5);
  a.glow(entrance.center, a.u * 3, const Color(0xFF000000), strength: 0.4);

  // A wild fig rooted in the top of the wall, its roots down the stones.
  final fig = a.p(0.7, 0.24);
  for (var i = 0; i < 6; i++) {
    a.strokePath(
      Path()
        ..moveTo(fig.dx, fig.dy)
        ..quadraticBezierTo(
          fig.dx + (i - 2.5) * a.u * 2,
          fig.dy + a.u * 8,
          fig.dx + (i - 2.5) * a.u * 3.4,
          fig.dy + a.u * (14 + i * 2),
        ),
      const Color(0xFF8A7A62),
      width: 0.7,
    );
  }
  a
    ..line(fig, fig.translate(-a.u * 2, -a.u * 10), _bark, width: 1.2)
    ..line(
      fig.translate(-a.u, -a.u * 6),
      fig.translate(a.u * 6, -a.u * 14),
      _bark,
      width: 0.8,
    );
  final random = math.Random(9);
  for (var i = 0; i < 22; i++) {
    a.oval(
      Rect.fromCenter(
        center: fig.translate(
          (random.nextDouble() - 0.4) * a.u * 16,
          -a.u * (8 + random.nextDouble() * 12),
        ),
        width: a.u * 4,
        height: a.u * 2.6,
      ),
      random.nextBool() ? _leaf : const Color(0xFF4A5A2E),
      line: 0,
    );
  }

  // Mauch's tent on the right.
  _groundShadow(a, 0.8, 1.0, 0.8);
  final tent = Path()
    ..moveTo(a.size.width * 0.82, a.size.height * 0.8)
    ..lineTo(a.size.width * 0.9, a.size.height * 0.44)
    ..lineTo(a.size.width * 0.98, a.size.height * 0.8)
    ..close();
  a
    ..path(tent, _canvas, line: 0.5)
    ..path(
      a.poly([a.p(0.88, 0.8), a.p(0.9, 0.54), a.p(0.92, 0.8)]),
      const Color(0xFF6A5E48),
      line: 0.3,
    );

  // The path up the hill on the left.
  a.path(
    a.poly([a.p(0, 0.62), a.p(0.06, 0.58), a.p(0.12, 0.9), a.p(0, 0.95)]),
    const Color(0xFFB09A6E),
    line: 0,
  );
  _dryGrass(a, 0.78);
}

// ---------------------------------------------------------------------------
// Mauch's camp

void _camp(Art a) {
  a
    ..fade(a.r(0, 0, 1, 0.55), _skyHigh, _sky)
    ..path(
      a.poly([
        a.p(0, 0.5),
        a.p(0.3, 0.42),
        a.p(0.6, 0.48),
        a.p(1, 0.4),
        a.p(1, 0.56),
        a.p(0, 0.56),
      ]),
      _hills,
      line: 0,
    )
    ..fade(a.r(0, 0.54, 1, 0.46), _grass, _earth);
  _msasaTree(a, a.p(0.12, 0.5), a.size.height * 0.5, seed: 21);
  _msasaTree(a, a.p(0.66, 0.48), a.size.height * 0.36, seed: 22);

  // The tent behind, its flap open, its far slope in shade.
  _groundShadow(a, 0.48, 1.0, 0.62);
  final tent = Path()
    ..moveTo(a.size.width * 0.5, a.size.height * 0.62)
    ..lineTo(a.size.width * 0.74, a.size.height * 0.16)
    ..lineTo(a.size.width * 0.98, a.size.height * 0.62)
    ..close();
  a
    ..path(tent, _canvas, line: 0.5)
    ..path(
      a.poly([a.p(0.66, 0.62), a.p(0.74, 0.3), a.p(0.82, 0.62)]),
      const Color(0xFF4A3E2E),
      line: 0.3,
    )
    ..path(
      a.poly([a.p(0.74, 0.16), a.p(0.98, 0.62), a.p(0.9, 0.62)]),
      const Color(0x22000000),
      line: 0,
    )
    // The tent pole, and the rifle leaning on it.
    ..line(a.p(0.84, 0.66), a.p(0.84, 0.22), _wood, width: 0.9);
  _groundShadow(a, 0.8, 0.86, 0.665, strength: 0.5);
  // The rifle: a long dark barrel resting on the pole, the wooden stock
  // on the ground, its butt widening to the foot.
  a
    ..line(
      a.p(0.838, 0.27),
      a.p(0.818, 0.56),
      const Color(0xFF2A2420),
      width: 0.7,
    )
    ..line(
      a.p(0.836, 0.3),
      a.p(0.82, 0.54),
      const Color(0xFF6A5A48),
      width: 0.25,
    )
    ..path(
      a.poly([
        a.p(0.815, 0.54),
        a.p(0.824, 0.54),
        a.p(0.83, 0.63),
        a.p(0.822, 0.665),
        a.p(0.806, 0.665),
        a.p(0.81, 0.6),
      ]),
      const Color(0xFF6A4226),
      line: 0.35,
    )
    ..line(
      a.p(0.822, 0.575),
      a.p(0.828, 0.585),
      const Color(0xFF8A8A84),
      width: 0.35,
    );

  // The folding table: its top seen from a little above, its crossed legs
  // and their shadow on the grass.
  _groundShadow(a, 0.25, 0.75, 0.865, strength: 0.4);
  final top = a.r(0.26, 0.5, 0.48, 0.05);
  Room(a, vp: a.p(0.5, 0.36), depth: 0.3).box(top, _wood, depth: 0.08);
  a
    ..wood(top, base: _wood, grain: 2, line: 0.5)
    ..line(a.p(0.29, 0.55), a.p(0.33, 0.86), _wood, width: 1)
    ..line(a.p(0.33, 0.55), a.p(0.29, 0.86), _wood, width: 1)
    ..line(a.p(0.67, 0.55), a.p(0.71, 0.86), _wood, width: 1)
    ..line(a.p(0.71, 0.55), a.p(0.67, 0.86), _wood, width: 1);
  // On it: the notebook open, the pencil, the splinter in its paper, the
  // hand lens, a lantern.
  a
    ..paper(
      a.r(0.31, 0.47, 0.07, 0.07),
      lines: 5,
      angle: -0.04,
      color: _paper,
      ink: 0.5,
    )
    ..paper(
      a.r(0.38, 0.47, 0.07, 0.07),
      lines: 5,
      angle: 0.04,
      color: _paper,
      ink: 0.5,
    )
    ..line(a.p(0.48, 0.52), a.p(0.55, 0.5), const Color(0xFFB0603A), width: 0.8)
    ..line(
      a.p(0.548, 0.502),
      a.p(0.555, 0.5),
      const Color(0xFF2A2420),
      width: 0.8,
    )
    ..box(a.r(0.6, 0.485, 0.07, 0.03), _paper, line: 0.3)
    ..line(a.p(0.61, 0.5), a.p(0.66, 0.494), _tambootie, width: 1.1)
    ..circle(a.p(0.7, 0.49), a.u * 1.6, const Color(0x88C8D8DA), line: 0.4)
    ..line(a.p(0.715, 0.5), a.p(0.73, 0.52), _wood, width: 0.8);
  // A hurricane lantern standing on the table's end: a wire handle, a
  // glass with the flame low, a tin base.
  final glass = a.r(0.272, 0.452, 0.022, 0.032);
  a
    ..glow(glass.center, a.u * 5, _lamp, strength: 0.25)
    ..strokePath(
      Path()..addArc(
        Rect.fromCenter(
          center: glass.topCenter.translate(0, -a.u * 0.2),
          width: glass.width * 0.9,
          height: a.u * 2.4,
        ),
        math.pi,
        math.pi,
      ),
      const Color(0xFF3A3A34),
      width: 0.3,
    )
    ..box(
      Rect.fromLTWH(
        glass.left - a.u * 0.2,
        glass.top - a.u * 0.7,
        glass.width + a.u * 0.4,
        a.u * 0.7,
      ),
      const Color(0xFF4A4A42),
      line: 0.25,
    )
    ..oval(glass, const Color(0xCCF2DCA0), line: 0.25)
    ..flame(glass.center.translate(0, glass.height * 0.2), glass.height * 0.4)
    ..box(
      Rect.fromLTWH(
        glass.left - a.u * 0.3,
        glass.bottom,
        glass.width + a.u * 0.6,
        0.5 * a.size.height - glass.bottom,
      ),
      const Color(0xFF4A4A42),
      line: 0.25,
    );
  _dryGrass(a, 0.84, seed: 23, count: 60);
}

// ---------------------------------------------------------------------------
// Inside the great enclosure

void _enclosure(Art a) {
  a.fade(a.r(0, 0, 1, 0.5), _skyHigh, _sky);
  // The inner face of the outer wall, curving round behind.
  _coursed(a, a.r(0, 0.18, 1, 0.42), seed: 31);
  _chevrons(a, a.r(0.24, 0.15, 0.76, 0.04), count: 36);
  a
    ..fade(
      a.r(0, 0.18, 1, 0.42),
      const Color(0x22000000),
      const Color(0x44000000),
    )
    ..fade(a.r(0, 0.58, 1, 0.42), _grass, _earth);

  // Left: the narrow passage between two high walls, running away.
  a.path(
    a.poly([a.p(0, 0.04), a.p(0.24, 0.16), a.p(0.24, 0.66), a.p(0, 0.86)]),
    _graniteShade,
    line: 0.5,
  );
  a.canvas
    ..save()
    ..clipPath(
      a.poly([a.p(0, 0.04), a.p(0.24, 0.16), a.p(0.24, 0.66), a.p(0, 0.86)]),
    );
  _coursed(a, a.r(0, 0.04, 0.24, 0.82), seed: 32, row: 3);
  a.canvas.restore();
  a
    ..path(
      a.poly([
        a.p(0.13, 0.12),
        a.p(0.24, 0.16),
        a.p(0.24, 0.66),
        a.p(0.13, 0.74),
      ]),
      const Color(0xFF3A342A),
      line: 0.3,
    )
    ..line(a.p(0.24, 0.16), a.p(0.24, 0.66), Art.outline, width: 0.5);

  // The conical tower, its shadow at its foot.
  _groundShadow(a, 0.53, 0.72, 0.72, strength: 0.45);
  final tower = Path()
    ..moveTo(a.size.width * 0.55, a.size.height * 0.72)
    ..lineTo(a.size.width * 0.58, a.size.height * 0.14)
    ..quadraticBezierTo(
      a.size.width * 0.62,
      a.size.height * 0.11,
      a.size.width * 0.66,
      a.size.height * 0.14,
    )
    ..lineTo(a.size.width * 0.69, a.size.height * 0.72)
    ..close();
  a.canvas
    ..save()
    ..clipPath(tower);
  _coursed(a, a.r(0.54, 0.1, 0.16, 0.64), seed: 33, row: 1.8);
  a
    ..fade(
      a.r(0.54, 0.1, 0.05, 0.64),
      const Color(0x33000000),
      const Color(0x33000000),
    )
    ..fade(
      a.r(0.65, 0.1, 0.05, 0.64),
      const Color(0x44000000),
      const Color(0x44000000),
    );
  a.canvas.restore();
  a.strokePath(tower, Art.outline, width: 0.5);

  // A tree grown up inside the walls.
  _msasaTree(a, a.p(0.86, 0.62), a.size.height * 0.44, seed: 34);

  // The fallen doorway: its blocks, and the dark lintel among them.
  final random = math.Random(35);
  final eye = Room(a, vp: a.p(0.5, 0.5), depth: 0.3);
  _groundShadow(a, 0.3, 0.52, 0.785);
  for (var i = 0; i < 9; i++) {
    eye.box(
      a.r(
        0.31 + random.nextDouble() * 0.17,
        0.7 + random.nextDouble() * 0.07,
        0.04,
        0.03,
      ),
      _granite,
      depth: 0.06,
      line: 0.4,
    );
  }
  a
    ..path(
      a.poly([
        a.p(0.31, 0.74),
        a.p(0.48, 0.71),
        a.p(0.485, 0.735),
        a.p(0.315, 0.765),
      ]),
      _tambootie,
      line: 0.4,
    )
    ..circle(a.p(0.47, 0.725), a.u * 0.8, const Color(0xFFC08A5A), line: 0);
  _dryGrass(a, 0.82, seed: 36, count: 50);
}

// ---------------------------------------------------------------------------
// The hill

void _hill(Art a) {
  a.fade(a.r(0, 0, 1, 0.5), _skyHigh, _sky);
  // Far hills, and the valley spread out below to the right.
  a
    ..path(
      a.poly([
        a.p(0, 0.44),
        a.p(0.3, 0.38),
        a.p(0.55, 0.42),
        a.p(0.8, 0.36),
        a.p(1, 0.4),
        a.p(1, 0.5),
        a.p(0, 0.5),
      ]),
      _hills,
      line: 0,
    )
    ..fade(
      a.r(0, 0.48, 1, 0.34),
      const Color(0xFFB8A878),
      const Color(0xFFA08C5E),
    );
  // The great enclosure far below: a thick oval of grey stone with its
  // outer face showing, the grass inside, the tower's cone, and a hint of
  // the chevrons along the far rim.
  final oval = a.r(0.7, 0.58, 0.2, 0.1);
  final face = oval.translate(0, a.size.height * 0.014);
  final inside = Rect.fromLTRB(
    oval.left + oval.width * 0.06,
    oval.top + oval.height * 0.14,
    oval.right - oval.width * 0.06,
    oval.bottom - oval.height * 0.12,
  );
  a
    ..oval(face.inflate(a.u * 0.6), const Color(0x33000000), line: 0)
    ..oval(face, _graniteShade, line: 0.4)
    ..oval(oval, const Color(0xFFA8A090), line: 0.4)
    ..oval(inside, const Color(0xFFB4A474), line: 0.3);
  for (var i = 0; i < 9; i++) {
    final t = math.pi * (1.15 + 0.7 * i / 8);
    final c = Offset(
      oval.center.dx + math.cos(t) * oval.width * 0.47,
      oval.center.dy + math.sin(t) * oval.height * 0.44,
    );
    a.line(
      c.translate(-a.u * 0.25, -a.u * 0.2),
      c.translate(a.u * 0.25, a.u * 0.2),
      const Color(0xFFD8D0C0),
      width: 0.18,
    );
  }
  a.path(
    a.poly([a.p(0.812, 0.645), a.p(0.82, 0.595), a.p(0.828, 0.645)]),
    const Color(0xFF8A8474),
    line: 0.25,
  );
  _msasaTree(a, a.p(0.64, 0.6), a.size.height * 0.12, seed: 41);
  _msasaTree(a, a.p(0.96, 0.58), a.size.height * 0.12, seed: 42);

  // The hilltop: its edge dropping away to the right, great boulders, and
  // a wall laid between them.
  a.path(
    a.poly([
      a.p(0, 0.42),
      a.p(0.5, 0.44),
      a.p(0.62, 0.56),
      a.p(0.66, 0.78),
      a.p(1, 0.8),
      a.p(1, 1),
      a.p(0, 1),
    ]),
    const Color(0xFF9A8A66),
    line: 0.4,
  );
  a.fade(a.r(0, 0.6, 1, 0.4), const Color(0x00000000), const Color(0x44000000));
  for (final (x, y, w, h) in [
    (0.0, 0.06, 0.16, 0.38),
    (0.12, 0.2, 0.12, 0.26),
    (0.54, 0.22, 0.1, 0.26),
  ]) {
    _groundShadow(a, x, x + w * 1.1, y + h * 0.96, strength: 0.4);
    _boulder(a, a.r(x, y, w, h));
  }
  // The wall between them, its top seen from above.
  _groundShadow(a, 0.19, 0.58, 0.58, strength: 0.4);
  Room(
    a,
    vp: a.p(0.4, 0.3),
    depth: 0.3,
  ).box(a.r(0.2, 0.46, 0.36, 0.12), _graniteShade, depth: 0.06);
  _coursed(a, a.r(0.2, 0.46, 0.36, 0.12), seed: 43, row: 1.8);
  a.ink(a.r(0.2, 0.46, 0.36, 0.12), width: 0.4);

  // The birds on their pillars, standing above the wall: upright birds of
  // prey, wings folded, hooked beaks, gripping the pillar's top.
  for (final (i, x) in [0.31, 0.4, 0.49].indexed) {
    final pillar = a.r(x, 0.28 + i * 0.015, 0.024, 0.22);
    a.box(pillar, _granite, line: 0.4);
    // A band of chevrons cut into the pillar.
    for (var k = 0; k < 3; k++) {
      final y = pillar.top + pillar.height * (0.35 + k * 0.07);
      a.strokePath(
        Path()
          ..moveTo(pillar.left, y)
          ..lineTo(pillar.center.dx, y + a.u * 0.8)
          ..lineTo(pillar.right, y),
        _graniteDark,
        width: 0.25,
      );
    }
    final foot = pillar.topCenter;
    final face = i.isOdd ? -1.0 : 1.0;
    final body = Rect.fromCenter(
      center: foot.translate(0, -a.u * 4.2),
      width: a.u * 3.4,
      height: a.u * 7.6,
    );
    a
      // The tail, down the back of the pillar.
      ..path(
        a.poly([
          body.bottomCenter.translate(-face * a.u * 1.2, -a.u * 1.4),
          body.bottomCenter.translate(-face * a.u * 2.0, a.u * 2.4),
          body.bottomCenter.translate(-face * a.u * 0.4, a.u * 0.4),
        ]),
        _soapstone,
        line: 0.3,
      )
      ..oval(body, _soapstone, line: 0.4)
      // The folded wing.
      ..oval(
        Rect.fromCenter(
          center: body.center.translate(-face * a.u * 0.5, a.u * 0.6),
          width: a.u * 2.2,
          height: a.u * 5.4,
        ),
        const Color(0xFF76745A),
        line: 0.25,
      );
    final head = body.topCenter.translate(face * a.u * 0.6, -a.u * 0.4);
    a
      ..circle(head, a.u * 1.4, _soapstone, line: 0.4)
      ..path(
        Path()
          ..moveTo(head.dx + face * a.u * 1.1, head.dy - a.u * 0.6)
          ..lineTo(head.dx + face * a.u * 2.8, head.dy + a.u * 0.1)
          ..lineTo(head.dx + face * a.u * 2.0, head.dy + a.u * 1.0)
          ..lineTo(head.dx + face * a.u * 1.2, head.dy + a.u * 0.4)
          ..close(),
        _soapstone,
        line: 0.3,
      )
      ..circle(
        head.translate(face * a.u * 0.5, -a.u * 0.3),
        a.u * 0.25,
        Art.outline,
        line: 0,
      )
      // The feet gripping the pillar's top.
      ..line(
        body.bottomCenter.translate(-a.u * 0.6, -a.u * 0.4),
        foot.translate(-a.u * 0.6, 0),
        _graniteDark,
        width: 0.5,
      )
      ..line(
        body.bottomCenter.translate(a.u * 0.6, -a.u * 0.4),
        foot.translate(a.u * 0.6, 0),
        _graniteDark,
        width: 0.5,
      );
  }
  _dryGrass(a, 0.82, seed: 44, count: 60);
}

// ---------------------------------------------------------------------------
// Puzzle boards

/// The breach close up: the wall's face on either side, dry grass below.
void _coursesBoard(Art a) {
  a
    ..fade(a.r(0, 0, 1, 0.3), _skyHigh, _sky)
    ..fill(a.r(0, 0.86, 1, 0.14), _grassDark);
  _coursed(a, a.r(0, 0.1, 1, 0.76), seed: 51, row: 6);
  a.fade(
    Offset.zero & a.size,
    const Color(0x55000000),
    const Color(0x88000000),
  );
}

/// The splinter under the lens: a cross-section of dark reddish wood with
/// fine pores scattered through it and faint rays; the rest dim.
void _identifyBoard(Art a) {
  a
    ..fill(Offset.zero & a.size, const Color(0xFF231C16))
    ..glow(a.p(0.25, 0.5), a.size.width * 0.32, _lamp, strength: 0.16);
  final c = a.p(0.24, 0.5);
  final r = a.size.height * 0.36;
  a.canvas
    ..save()
    ..clipPath(Path()..addOval(Rect.fromCircle(center: c, radius: r)));
  a.fill(Rect.fromCircle(center: c, radius: r), _tambootie);
  final random = math.Random(61);
  // Faint growth lines and rays.
  for (var i = 0; i < 9; i++) {
    a.canvas.drawCircle(
      c.translate(-r * 1.6, r * 0.2),
      r * (1.1 + i * 0.18),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0x33200C06),
    );
  }
  for (var i = 0; i < 40; i++) {
    final x = c.dx - r + random.nextDouble() * r * 2;
    a.hairline(
      Offset(x, c.dy - r),
      Offset(x + r * 0.06, c.dy + r),
      const Color(0x22E0A070),
      0.2,
    );
  }
  // The pores: fine, scattered, single and in short radial files.
  for (var i = 0; i < 160; i++) {
    final p =
        c +
        Offset(
          (random.nextDouble() - 0.5) * r * 2,
          (random.nextDouble() - 0.5) * r * 2,
        );
    final files = random.nextDouble() < 0.3 ? 2 : 1;
    for (var k = 0; k < files; k++) {
      a.canvas.drawOval(
        Rect.fromCenter(
          center: p.translate(0, k * a.u * 1.1),
          width: a.u * 0.7,
          height: a.u * 0.9,
        ),
        Paint()..color = const Color(0xFF120806),
      );
    }
  }
  a.canvas.restore();
  // The lens rim and handle.
  a.canvas
    ..drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = a.u * 2.4
        ..color = const Color(0xFF8A6A3A),
    )
    ..drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = a.u * 0.5
        ..color = const Color(0xFFD8B87A),
    );
  a.line(
    c.translate(r * 0.72, r * 0.72),
    c.translate(r * 1.1, r * 1.1),
    _wood,
    width: 3,
  );
}

// ---------------------------------------------------------------------------
// Objects

/// Fallen blocks heaped in the entrance.
void _rubble(Art a) {
  final random = math.Random(71);
  for (var i = 0; i < 14; i++) {
    final w = a.size.width * (0.3 + random.nextDouble() * 0.3);
    final h = w * 0.45;
    final x = random.nextDouble() * (a.size.width - w);
    final y = a.size.height * (0.4 + random.nextDouble() * 0.5);
    a.canvas
      ..save()
      ..translate(x + w / 2, y)
      ..rotate((random.nextDouble() - 0.5) * 0.6);
    a.box(
      Rect.fromCenter(center: Offset.zero, width: w, height: h),
      i.isEven ? _granite : const Color(0xFF948C7A),
      line: 0.4,
    );
    a.canvas.restore();
  }
}

/// The breach laid back: courses filling it, and the chevrons on top.
void _mended(Art a) {
  // The sprite stands at [0.26, 0.22, 0.18, 0.42] in the valley: its top
  // follows the wall's own curve there (t from 0.25 to 0.5 along it).
  Offset curve(double t, {double drop = 0}) {
    final x = (1 - t) * (1 - t) * 0.08 + 2 * t * (1 - t) * 0.44 + t * t * 0.8;
    final y =
        (1 - t) * (1 - t) * 0.34 + 2 * t * (1 - t) * 0.14 + t * t * 0.3 + drop;
    return a.p((x - 0.26) / 0.18, (y - 0.22) / 0.42);
  }

  final shape = Path()..moveTo(curve(0.25).dx, curve(0.25).dy);
  for (var i = 1; i <= 8; i++) {
    final p = curve(0.25 + 0.25 * i / 8);
    shape.lineTo(p.dx, p.dy);
  }
  shape
    ..lineTo(a.size.width, a.size.height)
    ..lineTo(0, a.size.height)
    ..close();
  a.canvas
    ..save()
    ..clipPath(shape);
  // Courses as tall as the wall's round it (this sprite is a narrow slice
  // of the scene, so its own unit is smaller).
  _coursed(a, a.r(0, 0, 1, 1), seed: 72, row: 6.6);
  // The chevron band, as on the rest of the wall: 44 along the whole top,
  // so 11 in this quarter.
  for (var k = 0; k < 11; k++) {
    final c = curve(0.25 + 0.25 * (k + 0.5) / 11, drop: 0.03);
    final lean = (k + 11).isEven ? 1.0 : -1.0;
    final half = a.size.width * 0.004 / 0.18;
    final reach = a.size.height * 0.018 / 0.42;
    a.path(
      a.poly([
        c.translate(lean * half * 2 - half, -reach),
        c.translate(lean * half * 2 + half, -reach),
        c.translate(-lean * half * 2 + half, reach),
        c.translate(-lean * half * 2 - half, reach),
      ]),
      const Color(0xFFC0B8A6),
      line: 0.15,
    );
  }
  a.canvas.restore();
  a.strokePath(
    Path()..addPolygon([
      for (var i = 0; i <= 8; i++) curve(0.25 + 0.25 * i / 8),
    ], false),
    Art.outline,
    width: 0.5,
  );
}

/// Papers laid on a stone, weighted with a pebble.
void _papers(Art a, {required int seed}) {
  final random = math.Random(seed);
  for (var i = 0; i < 3; i++) {
    a.paper(
      a.r(0.1 + i * 0.06, 0.12 + i * 0.04, 0.72, 0.7),
      lines: 6,
      angle: (random.nextDouble() - 0.5) * 0.3,
      color: i == 2 ? const Color(0xFFEDE8DC) : _paper,
      ink: 0.5,
    );
  }
  a
    ..oval(a.r(0.62, 0.62, 0.22, 0.18), _granite, line: 0.4)
    ..glow(a.p(0.5, 0.5), a.size.width * 0.6, _lamp, strength: 0.15);
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
  a
    ..fade(a.r(0, 0.16, 1, 0.5), _skyHigh, _sky)
    ..fade(a.r(0, 0.62, 1, 0.38), _grass, _earth);
  // The curve of the great wall, its chevrons, and the tower behind.
  final wall = Path()
    ..moveTo(0, h * 0.62)
    ..quadraticBezierTo(w * 0.5, h * 0.4, w, h * 0.6)
    ..lineTo(w, h * 0.86)
    ..quadraticBezierTo(w * 0.5, h * 0.8, 0, h * 0.88)
    ..close();
  a.path(
    a.poly([a.p(0.6, 0.5), a.p(0.62, 0.3), a.p(0.68, 0.3), a.p(0.7, 0.5)]),
    _graniteShade,
    line: 0.3,
  );
  a.canvas
    ..save()
    ..clipPath(wall);
  _coursed(a, a.r(0, 0.4, 1, 0.5), seed: 81, row: 3);
  a.canvas.restore();
  a.strokePath(wall, Art.outline, width: 0.4);
  for (var i = 0; i < 10; i++) {
    final t = i / 10;
    final x = w * (0.05 + t * 0.9);
    final y = h * (0.6 - math.sin(t * math.pi) * 0.12);
    a.line(
      Offset(x, y),
      Offset(x + w * 0.03, y + h * 0.03),
      const Color(0xFFC0B8A6),
      width: 0.6,
    );
  }
  _msasaTree(a, a.p(0.2, 0.6), h * 0.3, seed: 82);
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
  // The lid: a carved soapstone bird's head.
  a
    ..box(a.r(0.3, 0.04, 0.4, 0.14), _soapstone, line: 0.5)
    ..path(
      a.poly([a.p(0.44, 0.08), a.p(0.56, 0.06), a.p(0.6, 0.1), a.p(0.5, 0.12)]),
      const Color(0xFF6E6C54),
      line: 0.3,
    );
}
