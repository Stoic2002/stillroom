import 'dart:math' as math;
import 'dart:ui';

import '../theme/stillroom_palette.dart';
import 'art_kit.dart';
import 'echo_art.dart';
import 'whitechapel_1888_art.dart' show jarLabelBoard;

/// Code-drawn art for "Gyeongju, 771" (docs/episodes/gyeongju_771.md):
/// Bongdeoksa temple on a snowy winter night in Silla. Blue snow light,
/// red pillars and green eaves, the glow of the founders' furnaces, and the
/// great bronze bell, green-grey.
const _s = 'images/scenes/gyeongju_771';
const _o = 'images/objects/gyeongju_771';
const _i = 'images/items/gyeongju_771';

final Map<String, ArtPainter> gyeongjuArt = {
  // Scenes and puzzle boards.
  '$_s/yard.png': (c, s) => _yard(Art(c, s)),
  '$_s/founders_shed.png': (c, s) => _shed(Art(c, s)),
  '$_s/casting_pit.png': (c, s) => _pit(Art(c, s)),
  '$_s/monks_hall.png': (c, s) => _hall(Art(c, s)),
  '$_s/pavilion.png': (c, s) => _pavilion(Art(c, s)),
  '$_s/pit_board.png': (c, s) => _pitBoard(Art(c, s)),
  '$_s/pavilion_board.png': (c, s) => _pavilionBoard(Art(c, s)),
  '$_s/rim_board.png': (c, s) => _rimBoard(Art(c, s)),
  '$_s/label_close.png': (c, s) => jarLabelBoard(Art(c, s), _night),
  // Objects.
  '$_o/bell_far_sprite.png': (c, s) => _bellFar(Art(c, s)),
  '$_o/rope_sprite.png': (c, s) => _ropeOnPeg(Art(c, s)),
  '$_o/mould_open_sprite.png': (c, s) => _mouldOpen(Art(c, s)),
  '$_o/rope_tied_sprite.png': (c, s) => _ropeTied(Art(c, s)),
  '$_o/report_sprite.png': (c, s) => _report(Art(c, s)),
  '$_o/echo_founder.png': (c, s) => paintEcho(Art(c, s), EchoFigure.founder),
  '$_o/echo_monk.png': (c, s) => paintEcho(Art(c, s), EchoFigure.monk),
  // Items.
  '$_i/striker_rope.png': (c, s) => _ropeCoil(Art(c, s)),
  // The jar on the shelf.
  'images/ui/jar_gyeongju_771.png': (c, s) => _jar(Art(c, s)),
};

// ---------------------------------------------------------------------------
// Palette

const _night = Color(0xFF151C2A);
const _nightLow = Color(0xFF2A3446);
const _snow = Color(0xFFC9D2DC);
const _snowShade = Color(0xFF8E9AAA);
const _pillar = Color(0xFF7A2A20);
const _eave = Color(0xFF3E6A58);
const _roofTile = Color(0xFF2E3238);
const _wood = Color(0xFF4A3524);
const _plank = Color(0xFF5A4232);
const _bronze = Color(0xFF5E6A56);
const _bronzeLight = Color(0xFF7E8A72);
const _bronzeDark = Color(0xFF3E483A);
const _clay = Color(0xFF8A6A4A);
const _ember = Color(0xFFE08A3A);
const _hanji = Color(0xFFE6DDC8);

// ---------------------------------------------------------------------------
// Shared pieces

/// Falling snow over the whole picture.
void _snowfall(Art a, {int seed = 7, int count = 90}) {
  final random = math.Random(seed);
  final flake = Paint()..color = const Color(0xAAE8EEF4);
  for (var i = 0; i < count; i++) {
    a.canvas.drawCircle(
      a.p(random.nextDouble(), random.nextDouble()),
      a.u * (0.2 + random.nextDouble() * 0.35),
      flake,
    );
  }
}

/// A tiled Korean roof over [rect]: a heavy dark mass whose eaves sweep up
/// at both ends, green rafter ends under it, snow on top.
void _roof(Art a, Rect rect) {
  final w = rect.width;
  final h = rect.height;
  final roof = Path()
    ..moveTo(rect.left - w * 0.04, rect.bottom - h * 0.35)
    ..quadraticBezierTo(
      rect.left + w * 0.12,
      rect.bottom,
      rect.left + w * 0.3,
      rect.bottom - h * 0.02,
    )
    ..lineTo(rect.right - w * 0.3, rect.bottom - h * 0.02)
    ..quadraticBezierTo(
      rect.right - w * 0.12,
      rect.bottom,
      rect.right + w * 0.04,
      rect.bottom - h * 0.35,
    )
    ..lineTo(rect.right - w * 0.18, rect.top + h * 0.2)
    ..lineTo(rect.left + w * 0.18, rect.top + h * 0.2)
    ..close();
  a.path(roof, _roofTile, line: 0.6);
  // Ridge.
  a.box(
    Rect.fromLTWH(rect.left + w * 0.16, rect.top, w * 0.68, h * 0.22),
    const Color(0xFF24272C),
    line: 0.5,
  );
  // Tile rows.
  for (var i = 1; i < 10; i++) {
    final x = rect.left + w * (0.14 + 0.72 * i / 10);
    a.hairline(
      Offset(x, rect.top + h * 0.24),
      Offset(x + (x - rect.center.dx) * 0.12, rect.bottom - h * 0.05),
      const Color(0xFF15171A),
      0.35,
    );
  }
  // Snow along the ridge and the upper slope.
  a.canvas.drawPath(
    Path()
      ..moveTo(rect.left + w * 0.16, rect.top + h * 0.02)
      ..lineTo(rect.right - w * 0.16, rect.top + h * 0.02)
      ..lineTo(rect.right - w * 0.2, rect.top + h * 0.3)
      ..quadraticBezierTo(
        rect.center.dx,
        rect.top + h * 0.42,
        rect.left + w * 0.2,
        rect.top + h * 0.3,
      )
      ..close(),
    Paint()..color = _snow.withValues(alpha: 0.85),
  );
  // Green rafter ends under the eaves.
  a.fill(
    Rect.fromLTWH(
      rect.left + w * 0.18,
      rect.bottom - h * 0.02,
      w * 0.64,
      h * 0.08,
    ),
    _eave,
  );
}

/// A red wooden pillar.
void _post(Art a, Rect rect) => a
  ..box(rect, _pillar, line: 0.5)
  ..fill(
    Rect.fromLTWH(rect.left, rect.top, rect.width * 0.3, rect.height),
    const Color(0x22FFFFFF),
  );

/// Snowy ground from [top] down.
void _ground(Art a, double top) {
  a.fade(a.r(0, top, 1, 1 - top), _snowShade, const Color(0xFF5A6474));
  final random = math.Random(3);
  for (var i = 0; i < 40; i++) {
    final x = random.nextDouble();
    final y = top + random.nextDouble() * (1 - top);
    a.canvas.drawOval(
      Rect.fromCenter(
        center: a.p(x, y),
        width: a.size.width * 0.05,
        height: a.size.height * 0.008,
      ),
      Paint()..color = const Color(0x22FFFFFF),
    );
  }
}

/// The great bell, front on, filling [rect]: dragon hook and sound tube on
/// the crown, bands, lotus-boss frames, the lotus striking seat, a pair of
/// kneeling celestials. [detail] adds the smaller relief.
void _bell(Art a, Rect rect, {bool detail = true}) {
  final w = rect.width;
  final h = rect.height;
  final crown = rect.top + h * 0.14;
  final mouth = rect.bottom;
  final body = Path()
    ..moveTo(rect.left + w * 0.16, crown)
    ..quadraticBezierTo(
      rect.center.dx,
      crown - h * 0.05,
      rect.right - w * 0.16,
      crown,
    )
    ..cubicTo(
      rect.right - w * 0.04,
      crown + h * 0.3,
      rect.right - w * 0.08,
      mouth - h * 0.18,
      rect.right,
      mouth,
    )
    ..lineTo(rect.left, mouth)
    ..cubicTo(
      rect.left + w * 0.08,
      mouth - h * 0.18,
      rect.left + w * 0.04,
      crown + h * 0.3,
      rect.left + w * 0.16,
      crown,
    )
    ..close();
  // The dragon hook: an arched neck and head over the crown.
  final hook = Path()
    ..moveTo(rect.center.dx - w * 0.14, crown)
    ..quadraticBezierTo(
      rect.center.dx - w * 0.16,
      rect.top,
      rect.center.dx,
      rect.top + h * 0.02,
    )
    ..quadraticBezierTo(
      rect.center.dx + w * 0.12,
      rect.top + h * 0.03,
      rect.center.dx + w * 0.08,
      crown,
    );
  a.canvas.drawPath(
    hook,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.07
      ..strokeCap = StrokeCap.round
      ..color = Art.outline,
  );
  a.canvas.drawPath(
    hook,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.05
      ..strokeCap = StrokeCap.round
      ..color = _bronzeLight,
  );
  // The sound tube beside the hook.
  a.box(
    Rect.fromLTWH(
      rect.center.dx + w * 0.1,
      rect.top + h * 0.03,
      w * 0.06,
      crown - rect.top - h * 0.02,
    ),
    _bronze,
    line: 0.5,
  );
  a.path(body, _bronze, line: 0.7);
  a.canvas
    ..save()
    ..clipPath(body);
  // Light from the left, shade to the right.
  a
    ..fade(
      Rect.fromLTWH(rect.left, rect.top, w * 0.3, h),
      const Color(0x33FFFFFF),
      const Color(0x11FFFFFF),
    )
    ..fill(
      Rect.fromLTWH(rect.right - w * 0.25, rect.top, w * 0.25, h),
      const Color(0x33000000),
    );
  // Upper and lower bands of scroll.
  final top = crown + h * 0.05;
  final low = mouth - h * 0.11;
  for (final y in [top, low]) {
    a
      ..fill(Rect.fromLTWH(rect.left, y, w, h * 0.06), _bronzeDark)
      ..hairline(Offset(rect.left, y), Offset(rect.right, y), _bronzeLight, 0.5)
      ..hairline(
        Offset(rect.left, y + h * 0.06),
        Offset(rect.right, y + h * 0.06),
        _bronzeLight,
        0.5,
      );
    for (var x = rect.left + w * 0.04; x < rect.right; x += w * 0.08) {
      a.canvas.drawArc(
        Rect.fromLTWH(x, y + h * 0.012, w * 0.06, h * 0.036),
        math.pi,
        math.pi * 1.5,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = a.u * 0.3
          ..color = _bronzeLight,
      );
    }
  }
  // Two frames of nine lotus bosses, under the upper band.
  for (final fx in [0.2, 0.62]) {
    final frame = Rect.fromLTWH(
      rect.left + w * fx,
      top + h * 0.07,
      w * 0.18,
      h * 0.17,
    );
    a
      ..box(frame, _bronzeDark, line: 0.4)
      ..ink(frame.deflate(w * 0.012), width: 0.3);
    for (var r = 0; r < 3; r++) {
      for (var c = 0; c < 3; c++) {
        a.circle(
          Offset(
            frame.left + frame.width * (0.2 + 0.3 * c),
            frame.top + frame.height * (0.2 + 0.3 * r),
          ),
          w * 0.018,
          _bronzeLight,
          line: 0.25,
        );
      }
    }
  }
  // The lotus striking seat.
  final seat = Offset(rect.left + w * 0.3, low - h * 0.14);
  a.circle(seat, w * 0.07, _bronzeDark, line: 0.4);
  for (var i = 0; i < 8; i++) {
    final t = i * math.pi / 4;
    a.oval(
      Rect.fromCenter(
        center: seat + Offset(math.cos(t), math.sin(t)) * w * 0.045,
        width: w * 0.035,
        height: w * 0.035,
      ),
      _bronzeLight,
      line: 0.2,
    );
  }
  a.circle(seat, w * 0.022, _bronzeLight, line: 0.25);
  if (detail) {
    // A kneeling celestial on a cloud, a censer held up, facing the seat.
    final k = Offset(rect.left + w * 0.66, low - h * 0.2);
    final cel = Paint()..color = _bronzeLight;
    a.canvas
      ..drawOval(
        Rect.fromCenter(
          center: k + Offset(0, h * 0.07),
          width: w * 0.2,
          height: h * 0.04,
        ),
        cel,
      )
      ..drawPath(
        Path()
          ..moveTo(k.dx - w * 0.04, k.dy + h * 0.06)
          ..lineTo(k.dx + w * 0.02, k.dy - h * 0.02)
          ..lineTo(k.dx + w * 0.06, k.dy + h * 0.06)
          ..close(),
        cel,
      )
      ..drawCircle(k + Offset(w * 0.015, -h * 0.035), w * 0.022, cel)
      ..drawCircle(k + Offset(-w * 0.05, -h * 0.02), w * 0.018, cel);
    // Streamers floating up behind.
    a.strokePath(
      Path()
        ..moveTo(k.dx + w * 0.04, k.dy)
        ..quadraticBezierTo(
          k.dx + w * 0.14,
          k.dy - h * 0.08,
          k.dx + w * 0.1,
          k.dy - h * 0.14,
        ),
      _bronzeLight,
      width: 0.5,
    );
  }
  a.canvas.restore();
  a.canvas.drawPath(
    body,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = a.u * 0.7
      ..color = Art.outline,
  );
}

// ---------------------------------------------------------------------------
// Scenes

void _yard(Art a) {
  a.fade(a.r(0, 0, 1, 0.62), _night, _nightLow);
  // Far hills, dark, with snow.
  a.path(
    a.poly([
      a.p(0, 0.44),
      a.p(0.2, 0.34),
      a.p(0.42, 0.4),
      a.p(0.66, 0.32),
      a.p(0.88, 0.38),
      a.p(1, 0.34),
      a.p(1, 0.6),
      a.p(0, 0.6),
    ]),
    const Color(0xFF1E2636),
    line: 0,
  );
  // The pavilion, far back in the middle, open on all sides.
  _roof(a, a.r(0.39, 0.16, 0.22, 0.1));
  for (final x in [0.43, 0.56]) {
    _post(a, a.r(x, 0.26, 0.012, 0.28));
  }
  a.box(a.r(0.43, 0.25, 0.142, 0.018), _wood, line: 0.4);
  a.box(a.r(0.41, 0.54, 0.18, 0.025), const Color(0xFF6A6A70), line: 0.4);
  // The founders' shed, left.
  _roof(a, a.r(0.0, 0.3, 0.22, 0.12));
  a
    ..wood(a.r(0.02, 0.42, 0.18, 0.36), base: _plank, vertical: true, grain: 6)
    ..box(a.r(0.07, 0.5, 0.08, 0.28), const Color(0xFF1A120C), line: 0.5)
    ..glow(a.p(0.11, 0.66), a.size.width * 0.06, _ember, strength: 0.35);
  // The monks' hall, right: red posts, paper doors lit from inside.
  _roof(a, a.r(0.72, 0.22, 0.26, 0.16));
  a.box(a.r(0.76, 0.38, 0.2, 0.38), const Color(0xFF3A2A22), line: 0.5);
  for (final x in [0.76, 0.85, 0.94]) {
    _post(a, a.r(x, 0.38, 0.016, 0.38));
  }
  for (final x in [0.778, 0.868]) {
    final door = a.r(x, 0.44, 0.07, 0.3);
    a
      ..box(door, const Color(0xFFD8C08A), line: 0.4)
      ..glow(
        door.center,
        a.size.width * 0.06,
        StillroomPalette.gaslight,
        strength: 0.25,
      );
    for (var i = 1; i < 4; i++) {
      a.hairline(
        Offset(door.left + door.width * i / 4, door.top),
        Offset(door.left + door.width * i / 4, door.bottom),
        _wood,
        0.4,
      );
    }
    for (var i = 1; i < 6; i++) {
      a.hairline(
        Offset(door.left, door.top + door.height * i / 6),
        Offset(door.right, door.top + door.height * i / 6),
        _wood,
        0.4,
      );
    }
  }
  // Snowy ground.
  _ground(a, 0.62);
  // The casting pit, front middle, steam rising.
  final pit = a.r(0.39, 0.76, 0.24, 0.1);
  a
    ..oval(pit, const Color(0xFF3A2A20), line: 0.6)
    ..oval(pit.deflate(a.u * 1.5), const Color(0xFF1A120C), line: 0)
    ..glow(pit.center, a.size.width * 0.1, _ember, strength: 0.3);
  for (var i = 0; i < 3; i++) {
    a.strokePath(
      Path()
        ..moveTo(a.p(0.45 + i * 0.06, 0.78).dx, a.p(0.45 + i * 0.06, 0.78).dy)
        ..cubicTo(
          a.p(0.43 + i * 0.06, 0.72).dx,
          a.p(0.43 + i * 0.06, 0.72).dy,
          a.p(0.48 + i * 0.06, 0.68).dx,
          a.p(0.48 + i * 0.06, 0.68).dy,
          a.p(0.46 + i * 0.06, 0.6).dx,
          a.p(0.46 + i * 0.06, 0.6).dy,
        ),
      const Color(0x55D5DEE2),
      width: 1.2,
    );
  }
  // The founders' board on two posts.
  final board = a.r(0.245, 0.47, 0.09, 0.12);
  a
    ..box(a.r(0.25, 0.47, 0.008, 0.18), _wood, line: 0.4)
    ..box(a.r(0.326, 0.47, 0.008, 0.18), _wood, line: 0.4)
    ..box(board, const Color(0xFFB8A078), line: 0.5);
  for (var i = 0; i < 4; i++) {
    // Four columns of brush strokes: four names.
    final x = board.right - board.width * (0.18 + i * 0.21);
    for (var j = 0; j < 4; j++) {
      a.fill(
        Rect.fromLTWH(
          x - a.u * 0.4,
          board.top + board.height * (0.12 + j * 0.2),
          a.u * 0.8,
          board.height * 0.12,
        ),
        const Color(0xFF2A1F17),
      );
    }
  }
  a.fill(a.r(0.24, 0.462, 0.1, 0.012), _snow);
  // Paper lanterns on a line.
  a.line(a.p(0.58, 0.3), a.p(0.74, 0.32), _wood, width: 0.4);
  for (final (x, y) in [(0.62, 0.31), (0.67, 0.315)]) {
    a
      ..glow(
        a.p(x, y + 0.05),
        a.size.width * 0.04,
        StillroomPalette.gaslight,
        strength: 0.5,
      )
      ..line(a.p(x, y), a.p(x, y + 0.02), _wood, width: 0.3)
      ..oval(
        a.r(x - 0.015, y + 0.02, 0.03, 0.06),
        const Color(0xFFE8B868),
        line: 0.4,
      )
      ..fill(a.r(x - 0.012, y + 0.075, 0.024, 0.005), _pillar);
  }
  _snowfall(a);
}

void _shed(Art a) {
  // Plank walls, a beaten earth floor, the brazier's warmth.
  a
    ..wood(a.r(0, 0, 1, 0.76), base: _plank, vertical: true, grain: 14, line: 0)
    ..fade(a.r(0, 0, 1, 0.2), const Color(0xAA000000), const Color(0x00000000))
    ..fade(
      a.r(0, 0.76, 1, 0.24),
      const Color(0xFF3A2E22),
      const Color(0xFF221A12),
    )
    ..hairline(a.p(0, 0.76), a.p(1, 0.76), Art.outline, 0.8);
  // A shelf of clay and wax, left.
  a
    ..wood(a.r(0.04, 0.48, 0.16, 0.025), base: _wood, grain: 1)
    ..oval(a.r(0.06, 0.4, 0.06, 0.08), _clay, line: 0.5)
    ..oval(a.r(0.12, 0.43, 0.05, 0.05), const Color(0xFFD8C890), line: 0.5)
    ..rbox(a.r(0.07, 0.31, 0.08, 0.07), a.u, _clay, line: 0.5);
  // The plan of the channels, scratched on a board.
  final plan = a.r(0.37, 0.21, 0.2, 0.22);
  a
    ..box(plan.inflate(a.u * 0.8), _wood, line: 0.5)
    ..box(plan, const Color(0xFF9A7A58), line: 0.4);
  final scratch = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = a.u * 0.4
    ..color = const Color(0xFF3A2A1A);
  for (final fx in [0.15, 0.5, 0.85]) {
    // Furnaces along the top.
    a.canvas.drawCircle(
      Offset(plan.left + plan.width * fx, plan.top + plan.height * 0.14),
      plan.width * 0.05,
      scratch,
    );
  }
  a.canvas
    ..drawPath(
      Path()
        ..moveTo(plan.left + plan.width * 0.15, plan.top + plan.height * 0.2)
        ..lineTo(plan.left + plan.width * 0.15, plan.top + plan.height * 0.5)
        ..lineTo(plan.left + plan.width * 0.32, plan.top + plan.height * 0.5)
        ..lineTo(plan.left + plan.width * 0.32, plan.top + plan.height * 0.8)
        ..moveTo(plan.left + plan.width * 0.5, plan.top + plan.height * 0.2)
        ..lineTo(plan.left + plan.width * 0.5, plan.top + plan.height * 0.8)
        ..moveTo(plan.left + plan.width * 0.85, plan.top + plan.height * 0.2)
        ..lineTo(plan.left + plan.width * 0.85, plan.top + plan.height * 0.5)
        ..lineTo(plan.left + plan.width * 0.68, plan.top + plan.height * 0.5)
        ..lineTo(plan.left + plan.width * 0.68, plan.top + plan.height * 0.8),
      scratch,
    )
    ..drawOval(
      Rect.fromLTWH(
        plan.left + plan.width * 0.22,
        plan.top + plan.height * 0.8,
        plan.width * 0.56,
        plan.height * 0.14,
      ),
      scratch,
    );
  // A peg for the rope, right.
  a.box(a.r(0.745, 0.55, 0.012, 0.02), _wood, line: 0.3);
  // The workbench, and the newspaper on it.
  a
    ..wood(a.r(0.08, 0.7, 0.3, 0.035), base: _wood, grain: 1)
    ..box(a.r(0.1, 0.735, 0.015, 0.2), _wood, line: 0.4)
    ..box(a.r(0.34, 0.735, 0.015, 0.2), _wood, line: 0.4);
  a.paper(
    a.r(0.15, 0.63, 0.12, 0.07),
    lines: 0,
    angle: 0.05,
    color: const Color(0xFFD8D0B8),
  );
  a.canvas
    ..save()
    ..translate(a.p(0.21, 0.665).dx, a.p(0.21, 0.665).dy)
    ..rotate(0.05);
  for (var i = 0; i < 6; i++) {
    a.hairline(
      Offset(a.size.width * (0.045 - i * 0.015), -a.size.height * 0.025),
      Offset(a.size.width * (0.045 - i * 0.015), a.size.height * 0.025),
      const Color(0xFF3A3A3A),
      0.4,
    );
  }
  a.fill(
    Rect.fromLTWH(
      -a.size.width * 0.055,
      -a.size.height * 0.03,
      a.size.width * 0.03,
      a.size.height * 0.012,
    ),
    const Color(0xFF2A2A2A),
  );
  a.canvas.restore();
  // Tools: long-handled ladles and tongs leaning on the wall.
  for (final (x, t) in [(0.48, -0.12), (0.52, -0.05), (0.56, 0.08)]) {
    a.canvas
      ..save()
      ..translate(a.p(x, 0.74).dx, a.p(x, 0.74).dy)
      ..rotate(t);
    a
      ..box(
        Rect.fromLTWH(
          -a.u * 0.4,
          -a.size.height * 0.22,
          a.u * 0.8,
          a.size.height * 0.2,
        ),
        _wood,
        line: 0.3,
      )
      ..oval(
        Rect.fromCenter(
          center: Offset(0, -a.size.height * 0.23),
          width: a.u * 3.6,
          height: a.u * 2.4,
        ),
        const Color(0xFF3A3C3E),
        line: 0.4,
      );
    a.canvas.restore();
  }
  // A brazier and its glow.
  a
    ..oval(a.r(0.82, 0.8, 0.12, 0.06), const Color(0xFF3A3530), line: 0.5)
    ..oval(a.r(0.84, 0.8, 0.08, 0.03), _ember, line: 0)
    ..glow(a.p(0.88, 0.78), a.size.width * 0.25, _ember, strength: 0.3);
}

void _pit(Art a) {
  a.fade(a.r(0, 0, 1, 0.5), _night, _nightLow);
  _ground(a, 0.46);
  // The furnaces, left: three squat clay kilns, glowing.
  for (final (x, y) in [(0.05, 0.3), (0.12, 0.34), (0.18, 0.3)]) {
    final kiln = Path()
      ..moveTo(a.p(x, y + 0.3).dx, a.p(x, y + 0.3).dy)
      ..lineTo(a.p(x + 0.01, y + 0.04).dx, a.p(x + 0.01, y + 0.04).dy)
      ..quadraticBezierTo(
        a.p(x + 0.035, y - 0.02).dx,
        a.p(x + 0.035, y - 0.02).dy,
        a.p(x + 0.06, y + 0.04).dx,
        a.p(x + 0.06, y + 0.04).dy,
      )
      ..lineTo(a.p(x + 0.07, y + 0.3).dx, a.p(x + 0.07, y + 0.3).dy)
      ..close();
    a
      ..glow(
        a.p(x + 0.035, y + 0.2),
        a.size.width * 0.07,
        _ember,
        strength: 0.4,
      )
      ..path(kiln, const Color(0xFF6A4E36), line: 0.6)
      ..oval(a.r(x + 0.02, y + 0.18, 0.03, 0.05), _ember, line: 0.3);
  }
  // Clay channels from the kilns to the mould.
  final channel = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = a.u * 1.6
    ..color = _clay;
  a.canvas.drawPath(
    Path()
      ..moveTo(a.p(0.12, 0.62).dx, a.p(0.12, 0.62).dy)
      ..quadraticBezierTo(
        a.p(0.28, 0.5).dx,
        a.p(0.28, 0.5).dy,
        a.p(0.44, 0.4).dx,
        a.p(0.44, 0.4).dy,
      ),
    channel,
  );
  // The pit, and the mould in it: a dome of clay bound with rope.
  a
    ..oval(a.r(0.3, 0.64, 0.4, 0.16), const Color(0xFF2A1E14), line: 0.6)
    ..glow(a.p(0.5, 0.6), a.size.width * 0.18, _ember, strength: 0.15);
  final mould = Path()
    ..moveTo(a.p(0.36, 0.74).dx, a.p(0.36, 0.74).dy)
    ..cubicTo(
      a.p(0.37, 0.5).dx,
      a.p(0.37, 0.5).dy,
      a.p(0.42, 0.38).dx,
      a.p(0.42, 0.38).dy,
      a.p(0.5, 0.38).dx,
      a.p(0.5, 0.38).dy,
    )
    ..cubicTo(
      a.p(0.58, 0.38).dx,
      a.p(0.58, 0.38).dy,
      a.p(0.63, 0.5).dx,
      a.p(0.63, 0.5).dy,
      a.p(0.64, 0.74).dx,
      a.p(0.64, 0.74).dy,
    )
    ..close();
  a.path(mould, _clay, line: 0.7);
  for (final y in [0.48, 0.58, 0.68]) {
    a.line(a.p(0.37, y), a.p(0.63, y), const Color(0xFFB89A68), width: 0.8);
  }
  // Pouring cups on the top.
  for (final x in [0.45, 0.5, 0.55]) {
    a.oval(
      a.r(x - 0.015, 0.37, 0.03, 0.025),
      const Color(0xFF5A4432),
      line: 0.4,
    );
  }
  // Channel pieces stacked on the right.
  for (var i = 0; i < 4; i++) {
    a.rbox(
      a.r(0.74 + (i % 2) * 0.07, 0.36 + (i ~/ 2) * 0.1, 0.06, 0.06),
      a.u,
      _clay,
      line: 0.5,
    );
    a.line(
      a.p(0.77 + (i % 2) * 0.07, 0.365 + (i ~/ 2) * 0.1),
      a.p(0.77 + (i % 2) * 0.07, 0.415 + (i ~/ 2) * 0.1),
      const Color(0xFF3E2C1E),
      width: 1.2,
    );
  }
  _snowfall(a, seed: 11, count: 60);
}

void _hall(Art a) {
  // Wooden walls, papered doors, a heated floor of oiled paper.
  a
    ..wood(
      a.r(0, 0, 1, 0.74),
      base: const Color(0xFF4A3526),
      vertical: true,
      grain: 8,
      line: 0,
    )
    ..fade(a.r(0, 0, 1, 0.2), const Color(0xAA000000), const Color(0x00000000))
    ..fade(
      a.r(0, 0.74, 1, 0.26),
      const Color(0xFFB08A58),
      const Color(0xFF7A5A38),
    )
    ..hairline(a.p(0, 0.74), a.p(1, 0.74), Art.outline, 0.8);
  for (var i = 1; i < 5; i++) {
    a.hairline(
      a.p(0, 0.74 + i * 0.05),
      a.p(1, 0.74 + i * 0.05),
      const Color(0x33000000),
      0.4,
    );
  }
  for (final x in [0.28, 0.7]) {
    _post(a, a.r(x, 0, 0.022, 0.74));
  }
  // The lattice window, snow blue beyond.
  final win = a.r(0.06, 0.16, 0.16, 0.34);
  a.box(win, const Color(0xFF9AA6B8), line: 0.6);
  for (var i = 1; i < 4; i++) {
    a.hairline(
      Offset(win.left + win.width * i / 4, win.top),
      Offset(win.left + win.width * i / 4, win.bottom),
      _wood,
      0.6,
    );
  }
  for (var i = 1; i < 6; i++) {
    a.hairline(
      Offset(win.left, win.top + win.height * i / 6),
      Offset(win.right, win.top + win.height * i / 6),
      _wood,
      0.6,
    );
  }
  // A low desk, the draft on it in columns of brush strokes.
  a
    ..wood(a.r(0.34, 0.63, 0.3, 0.035), base: const Color(0xFF3A2418), grain: 1)
    ..box(a.r(0.36, 0.665, 0.02, 0.08), const Color(0xFF3A2418), line: 0.4)
    ..box(a.r(0.6, 0.665, 0.02, 0.08), const Color(0xFF3A2418), line: 0.4);
  final draft = a.r(0.38, 0.52, 0.2, 0.11);
  a.box(draft, _hanji, line: 0.4);
  final random = math.Random(771);
  for (var col = 0; col < 12; col++) {
    final x = draft.right - draft.width * (0.07 + col * 0.075);
    var y = draft.top + draft.height * 0.1;
    while (y < draft.bottom - draft.height * 0.15) {
      final len = draft.height * (0.04 + random.nextDouble() * 0.06);
      a.fill(Rect.fromLTWH(x, y, a.u * 0.5, len), const Color(0xFF1A1410));
      y += len + draft.height * 0.03;
    }
  }
  // Brush and inkstone.
  a
    ..rbox(
      a.r(0.595, 0.585, 0.035, 0.04),
      a.u * 0.5,
      const Color(0xFF26262A),
      line: 0.4,
    )
    ..line(a.p(0.35, 0.6), a.p(0.37, 0.53), _wood, width: 0.6);
  // The oil lamp on a stand.
  a
    ..box(a.r(0.645, 0.43, 0.006, 0.31), _wood, line: 0.3)
    ..oval(a.r(0.63, 0.42, 0.036, 0.015), const Color(0xFF8A7A5A), line: 0.3)
    ..flame(a.p(0.648, 0.42), a.size.height * 0.04);
  // A Western book, lying where it should not be.
  final book = a.r(0.73, 0.62, 0.1, 0.05);
  a
    ..rbox(book, a.u * 0.4, const Color(0xFF2A3A5A), line: 0.5)
    ..fill(
      Rect.fromLTWH(
        book.left,
        book.bottom - book.height * 0.3,
        book.width,
        book.height * 0.25,
      ),
      _hanji,
    )
    ..label(
      '1906',
      Offset(book.center.dx, book.top + book.height * 0.35),
      book.height * 0.4,
      StillroomPalette.brass,
    );
}

void _pavilion(Art a) {
  a.fade(a.r(0, 0, 1, 0.8), _night, _nightLow);
  // The underside of the pavilion roof, and its great beam.
  a
    ..fill(a.r(0, 0, 1, 0.08), const Color(0xFF24272C))
    ..fill(a.r(0, 0.08, 1, 0.025), _eave)
    ..wood(a.r(0.02, 0.1, 0.96, 0.04), base: _wood, grain: 1);
  // Pillars at the sides.
  for (final x in [0.02, 0.94]) {
    _post(a, a.r(x, 0.1, 0.04, 0.72));
  }
  // Stone floor with snow blown in, the hollow under the bell's mouth.
  a
    ..fade(
      a.r(0, 0.8, 1, 0.2),
      const Color(0xFF6A6E78),
      const Color(0xFF3E424A),
    )
    ..hairline(a.p(0, 0.8), a.p(1, 0.8), Art.outline, 0.8);
  final hollow = a.r(0.4, 0.8, 0.24, 0.08);
  a
    ..oval(hollow, const Color(0xFF0E0C0A), line: 0.6)
    ..fill(a.r(0.04, 0.8, 0.14, 0.04), const Color(0x55C9D2DC));
  // The bell.
  _bell(a, a.r(0.38, 0.14, 0.28, 0.6));
  // Chain from the beam to the hook.
  a.box(a.r(0.515, 0.14, 0.01, 0.03), const Color(0xFF3A3A3A), line: 0.3);
  // The log striker, level, hanging by its left rope; the right end rests
  // on a trestle.
  a
    ..line(
      a.p(0.12, 0.14),
      a.p(0.12, 0.37),
      const Color(0xFFB8A070),
      width: 0.8,
    )
    ..rbox(
      a.r(0.08, 0.37, 0.24, 0.06),
      a.u * 2.4,
      StillroomPalette.walnutLight,
      line: 0.6,
    )
    ..oval(a.r(0.3, 0.372, 0.02, 0.056), const Color(0xFF6A5236), line: 0.3);
  // The trestle.
  a
    ..line(a.p(0.26, 0.43), a.p(0.23, 0.8), _wood, width: 1.2)
    ..line(a.p(0.26, 0.43), a.p(0.29, 0.8), _wood, width: 1.2)
    ..box(a.r(0.24, 0.425, 0.04, 0.012), _wood, line: 0.3);
  // A low bench, right, for later papers.
  a
    ..wood(a.r(0.72, 0.76, 0.16, 0.025), base: _wood, grain: 1)
    ..box(a.r(0.73, 0.785, 0.01, 0.05), _wood, line: 0.3)
    ..box(a.r(0.86, 0.785, 0.01, 0.05), _wood, line: 0.3);
  // Snow beyond the pillars.
  _snowfall(a, seed: 5, count: 40);
}

void _pitBoard(Art a) {
  // Close on the channels: packed sand in the furnaces' glow.
  a
    ..fade(
      Offset.zero & a.size,
      const Color(0xFF4A3A2A),
      const Color(0xFF2A1E14),
    )
    ..glow(a.p(0.5, 0.1), a.size.width * 0.5, _ember, strength: 0.2);
  final random = math.Random(9);
  for (var i = 0; i < 160; i++) {
    a.canvas.drawCircle(
      a.p(random.nextDouble(), random.nextDouble()),
      a.u * 0.2,
      Paint()..color = const Color(0x22000000),
    );
  }
}

void _pavilionBoard(Art a) {
  a
    ..fade(Offset.zero & a.size, _night, _nightLow)
    ..fill(a.r(0, 0, 1, 0.06), const Color(0xFF24272C))
    ..fill(a.r(0, 0.06, 1, 0.02), _eave);
  _snowfall(a, seed: 13, count: 50);
}

void _rimBoard(Art a) {
  // Looking up into the bell: dark bronze all round.
  a
    ..fill(Offset.zero & a.size, const Color(0xFF12140F))
    ..glow(a.p(0.28, 0.46), a.size.width * 0.35, _bronze, strength: 0.25)
    ..fade(
      Offset.zero & a.size,
      const Color(0x00000000),
      const Color(0x66000000),
    );
}

// ---------------------------------------------------------------------------
// Objects and items

/// The bell hanging far off in the pavilion (over the yard's pavilion).
void _bellFar(Art a) => _bell(a, a.r(0.22, 0.28, 0.56, 0.58), detail: false);

/// A coil of hemp rope.
void _ropeCoil(Art a) {
  final c = a.p(0.5, 0.52);
  final r = a.size.shortestSide * 0.32;
  for (var i = 0; i < 4; i++) {
    a.canvas.drawOval(
      Rect.fromCenter(
        center: c.translate(0, i * r * 0.1 - r * 0.15),
        width: r * 2 - i * r * 0.12,
        height: r * 1.1,
      ),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = a.u * 3.6
        ..color = Art.outline,
    );
    a.canvas.drawOval(
      Rect.fromCenter(
        center: c.translate(0, i * r * 0.1 - r * 0.15),
        width: r * 2 - i * r * 0.12,
        height: r * 1.1,
      ),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = a.u * 2.4
        ..color = const Color(0xFFB8A070),
    );
  }
  a.strokePath(
    Path()
      ..moveTo(c.dx + r * 0.9, c.dy)
      ..quadraticBezierTo(
        c.dx + r * 1.2,
        c.dy + r * 0.6,
        c.dx + r * 0.7,
        c.dy + r * 0.9,
      ),
    const Color(0xFFB8A070),
    width: 2.4,
  );
}

/// The rope hanging on its peg in the shed.
void _ropeOnPeg(Art a) {
  a.box(a.r(0.4, 0.0, 0.2, 0.08), _wood, line: 0.3);
  for (var i = 0; i < 3; i++) {
    a.canvas.drawOval(
      a.r(0.12 + i * 0.04, 0.04 + i * 0.02, 0.76 - i * 0.08, 0.86 - i * 0.04),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = a.size.width * 0.1
        ..color = Art.outline,
    );
    a.canvas.drawOval(
      a.r(0.12 + i * 0.04, 0.04 + i * 0.02, 0.76 - i * 0.08, 0.86 - i * 0.04),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = a.size.width * 0.07
        ..color = const Color(0xFFB8A070),
    );
  }
}

/// The second rope, tied: from the beam to the log's right end.
void _ropeTied(Art a) {
  // The rope comes down from the beam (above this sprite) to the log.
  a.line(a.p(0.83, 0), a.p(0.83, 0.3), const Color(0xFFB8A070), width: 1.2);
  a.oval(a.r(0.79, 0.24, 0.08, 0.14), const Color(0xFFB8A070), line: 0.4);
}

/// The mould broken away: shards round an empty pit.
void _mouldOpen(Art a) {
  a.oval(a.r(0.02, 0.7, 0.96, 0.26), const Color(0xFF1A120C), line: 0.6);
  final random = math.Random(21);
  for (var i = 0; i < 9; i++) {
    final x = 0.05 + random.nextDouble() * 0.85;
    final y = 0.72 + random.nextDouble() * 0.2;
    a.path(
      a.poly([
        a.p(x, y),
        a.p(x + 0.08, y - 0.04),
        a.p(x + 0.14, y + 0.02),
        a.p(x + 0.05, y + 0.05),
      ]),
      _clay,
      line: 0.4,
    );
  }
  a.glow(a.p(0.5, 0.82), a.size.width * 0.4, _ember, strength: 0.15);
}

/// The 1998 report, a modern sheet on the bench.
void _report(Art a) {
  a.paper(a.r(0.1, 0.1, 0.8, 0.8), lines: 4, color: const Color(0xFFF2F2EE));
  a.fill(a.r(0.16, 0.18, 0.3, 0.1), const Color(0xFF3A5A8A));
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
    ..fade(a.r(0, 0.16, 1, 0.84), _night, _nightLow)
    ..fill(a.r(0, 0.84, 1, 0.16), _snow);
  _bell(a, a.r(0.24, 0.3, 0.52, 0.56), detail: false);
  _snowfall(a, seed: 2, count: 16);
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
  a.box(a.r(0.3, 0.04, 0.4, 0.14), const Color(0xFF7A5A3A), line: 0.5);
}
