import 'dart:math' as math;
import 'dart:ui';

import '../theme/stillroom_palette.dart';
import 'art_kit.dart';

/// Code-drawn stand-in art for "Semarang, 1945" (Lawang Sewu), keyed by the
/// image paths in the episode's JSON. A real file at the same path wins.
///
/// Colour notes (docs/episodes/lawang_sewu_1945.md): white colonial walls
/// gone grey-green in the dark, tall teak doors with fanlights, tiled floors;
/// the stained glass dull until solved; 1907 in warm sepia, 1942 in cold fog,
/// 1945 lit by distant orange.
const _s = 'images/scenes/lawang_sewu_1945';
const _o = 'images/objects/lawang_sewu_1945';
const _i = 'images/items/lawang_sewu_1945';

final Map<String, ArtPainter> lawangSewuArt = {
  // Scenes.
  '$_s/landing.png': (c, s) => _landing(Art(c, s)),
  '$_s/corridor_west.png': (c, s) => _corridor(Art(c, s)),
  '$_s/corridor_east.png': (c, s) => _corridor(Art(c, s)),
  '$_s/office_1907.png': (c, s) => _office(Art(c, s)),
  '$_s/window_1945.png': (c, s) => _window1945(Art(c, s)),
  '$_s/cellar_1942.png': (c, s) => _cellar(Art(c, s)),
  '$_s/lockers.png': (c, s) => _lockerRoom(Art(c, s)),
  // Puzzle boards.
  '$_s/timetable_close.png': (c, s) => _timetableBoard(Art(c, s)),
  '$_s/telegraph_close.png': (c, s) => _telegraphBoard(Art(c, s)),
  '$_s/clock_close.png': (c, s) => _clockBoard(Art(c, s)),
  '$_s/locker_door_close.png': (c, s) => _lockerDoorBoard(Art(c, s)),
  '$_s/lockers_close.png': (c, s) => _lockersBoard(Art(c, s)),
  '$_s/glass_close.png': (c, s) => _glassBoard(Art(c, s)),
  // Landing objects.
  '$_o/staircase_sprite.png': (c, s) => _staircase(Art(c, s)),
  '$_o/glass_dark_sprite.png': (c, s) => _stainedGlass(Art(c, s), lit: false),
  '$_o/glass_lit_sprite.png': (c, s) => _stainedGlass(Art(c, s), lit: true),
  '$_o/clock_stopped_sprite.png': (c, s) =>
      _stationClock(Art(c, s), running: false),
  '$_o/clock_running_sprite.png': (c, s) =>
      _stationClock(Art(c, s), running: true),
  '$_o/clock_niche_sprite.png': (c, s) => _niche(Art(c, s)),
  '$_o/lantern_sprite.png': (c, s) => _lantern(Art(c, s), lit: false),
  // Corridor doors.
  '$_o/door_1907_sprite.png': (c, s) => _door(Art(c, s), '1907'),
  '$_o/door_1942_sprite.png': (c, s) => _door(Art(c, s), '1942'),
  '$_o/door_1945_sprite.png': (c, s) => _door(Art(c, s), '1945'),
  '$_o/door_lockers_sprite.png': (c, s) => _door(Art(c, s), null, dial: true),
  // Office 1907.
  '$_o/office_desk_sprite.png': (c, s) => _officeDesk(Art(c, s)),
  '$_o/ledger_sprite.png': (c, s) => _openBook(Art(c, s), small: true),
  '$_o/timetable_board_sprite.png': (c, s) => _timetable(Art(c, s)),
  '$_o/telegraph_sprite.png': (c, s) => _telegraph(Art(c, s)),
  '$_o/telegram_form_sprite.png': (c, s) =>
      Art(c, s).paper(Offset.zero & s, lines: 5, angle: 0.04),
  '$_o/shelf_sprite.png': (c, s) => Art(c, s).wood(Offset.zero & s, grain: 1),
  '$_o/oil_can_sprite.png': (c, s) => _oilCan(Art(c, s)),
  // Window 1945.
  '$_o/calendar_sprite.png': (c, s) => _calendar(Art(c, s)),
  '$_o/cap_sprite.png': (c, s) => _cap(Art(c, s)),
  // Cellar 1942.
  '$_o/darkness_sprite.png': (c, s) => _darkness(Art(c, s)),
  '$_o/tally_sprite.png': (c, s) => _tally(Art(c, s)),
  '$_o/chair_sprite.png': (c, s) => _chair(Art(c, s)),
  '$_o/whistle_sprite.png': (c, s) => _whistle(Art(c, s), glint: true),
  // Lockers.
  '$_o/lockers_empty_sprite.png': (c, s) =>
      _lockerRow(Art(c, s), filled: false),
  '$_o/lockers_filled_sprite.png': (c, s) =>
      _lockerRow(Art(c, s), filled: true),
  // Puzzle pieces.
  '$_o/station_plate.png': (c, s) => _stationPlate(Art(c, s)),
  '$_o/key_dot.png': (c, s) => _morseKey(Art(c, s), dash: false),
  '$_o/key_dash.png': (c, s) => _morseKey(Art(c, s), dash: true),
  '$_o/glass_outer.png': (c, s) => _glassRing(Art(c, s), _Ring.flora),
  '$_o/glass_middle.png': (c, s) => _glassRing(Art(c, s), _Ring.cities),
  '$_o/glass_inner.png': (c, s) => _glassRing(Art(c, s), _Ring.wheel),
  // Items.
  '$_i/ledger.png': (c, s) => _closedBook(Art(c, s)),
  '$_i/ledger_examine.png': (c, s) => _openBook(Art(c, s), small: false),
  '$_i/ledger_page_0.png': (c, s) => _page(Art(c, s), 0),
  '$_i/ledger_page_1.png': (c, s) => _page(Art(c, s), 1),
  '$_i/ledger_page_2.png': (c, s) => _page(Art(c, s), 2),
  '$_i/ledger_page_3.png': (c, s) => _page(Art(c, s), 3),
  '$_i/lamp_oil.png': (c, s) => _oilCan(Art(c, s)),
  '$_i/lantern.png': (c, s) => _lantern(Art(c, s), lit: false),
  '$_i/lit_lantern.png': (c, s) => _lantern(Art(c, s), lit: true),
  '$_i/ticket_punch.png': (c, s) => _ticketPunch(Art(c, s)),
  '$_i/telegraph_key.png': (c, s) => _morseKey(Art(c, s), dash: false),
  '$_i/driver_cap.png': (c, s) => _cap(Art(c, s)),
  '$_i/whistle.png': (c, s) => _whistle(Art(c, s), glint: false),
  // The jar on the shelf.
  'images/ui/jar_lawang_sewu_1945.png': (c, s) => _jar(Art(c, s)),
};

// ---------------------------------------------------------------------------
// Palette

const _wall = Color(0xFF28302D);
const _wallPale = Color(0xFF34403B);
const _plaster = Color(0xFF5E6A63);
const _teak = Color(0xFF3B2618);
const _teakDark = Color(0xFF24160D);
const _tileA = Color(0xFF2C2824);
const _tileB = Color(0xFF1C1916);
const _iron = Color(0xFF2B3033);
const _enamel = Color(0xFFD7D1C1);
const _enamelBlue = Color(0xFF274A6B);
const _amber = Color(0xFFD9962B);
const _ruby = Color(0xFF9A2B25);
const _cobalt = Color(0xFF2B4F8C);
const _emerald = Color(0xFF2F6B45);
const _sepia = Color(0xFF4A3622);
const _sepiaLight = Color(0xFF6B4E30);
const _ember = Color(0xFFD8742C);

// ---------------------------------------------------------------------------
// Shared shapes

/// A round-topped arch filling [rect].
Path _archPath(Rect rect) => Path()
  ..moveTo(rect.left, rect.bottom)
  ..lineTo(rect.left, rect.top + rect.width / 2)
  ..arcToPoint(
    Offset(rect.right, rect.top + rect.width / 2),
    radius: Radius.circular(rect.width / 2),
  )
  ..lineTo(rect.right, rect.bottom)
  ..close();

/// Checkerboard tiles in perspective between [horizon] and the bottom.
void _tiledFloor(Art a, double horizon) {
  final w = a.size.width;
  final h = a.size.height;
  final top = h * horizon;
  a.fill(Rect.fromLTRB(0, top, w, h), _tileA);
  final vp = Offset(w / 2, h * (horizon - 0.25));
  for (var i = -8; i <= 8; i++) {
    final x = w / 2 + i * w * 0.12;
    final dir = Offset(x, h) - vp;
    final t = (top - vp.dy) / dir.dy;
    a.line(vp + dir * t, Offset(x, h), _tileB, width: 0.4);
  }
  for (var k = 1; k < 6; k++) {
    final y = top + (h - top) * math.pow(k / 6, 1.6);
    a.line(Offset(0, y), Offset(w, y), _tileB, width: 0.4);
  }
  a.fade(
    Rect.fromLTRB(0, top, w, h),
    const Color(0x99000000),
    const Color(0x00000000),
  );
}

void _plainWall(Art a, Rect rect, {Color base = _wall}) {
  a
    ..fill(rect, base)
    ..fill(
      Rect.fromLTWH(
        rect.left,
        rect.bottom - rect.height * 0.08,
        rect.width,
        rect.height * 0.08,
      ),
      _wallPale,
    )
    ..stain(
      Offset(rect.left + rect.width * 0.2, rect.top + rect.height * 0.3),
      rect.width * 0.06,
    )
    ..stain(
      Offset(rect.left + rect.width * 0.85, rect.top + rect.height * 0.55),
      rect.width * 0.05,
    );
}

// ---------------------------------------------------------------------------
// Scenes

void _landing(Art a) {
  _plainWall(a, a.r(0, 0, 1, 0.78));
  // The great arch around the stained glass.
  final arch = a.r(0.35, 0.03, 0.30, 0.47);
  a
    ..path(_archPath(arch), _wallPale)
    ..path(_archPath(arch.deflate(a.u * 1.5)), const Color(0xFF151A18))
    // Side archways into the corridors.
    ..path(_archPath(a.r(-0.04, 0.18, 0.12, 0.6)), const Color(0xFF0B0E0D))
    ..path(_archPath(a.r(0.92, 0.18, 0.12, 0.6)), const Color(0xFF0B0E0D))
    // Cornice.
    ..fill(a.r(0, 0.0, 1, 0.025), _plaster)
    ..fade(a.r(0, 0, 1, 0.3), const Color(0xCC000000), const Color(0x00000000));
  _tiledFloor(a, 0.78);
}

void _corridor(Art a) {
  final w = a.size.width;
  final h = a.size.height;
  final vp = Offset(w / 2, h * 0.45);
  a.fill(Offset.zero & a.size, _wall);
  // Receding arches along the corridor.
  for (var i = 0; i < 9; i++) {
    final t = math.pow(0.72, i).toDouble();
    final rw = w * 0.96 * t;
    final rh = h * 1.05 * t;
    final rect = Rect.fromCenter(
      center: vp.translate(0, rh * 0.06),
      width: rw,
      height: rh,
    );
    a.strokePath(
      _archPath(rect),
      Color.lerp(_plaster, _wall, 1 - t)!,
      width: 1.2 * t + 0.2,
    );
    // Door outlines on the side walls, getting smaller (the nearest ones
    // are the door layers themselves).
    for (final side in i == 0 ? const <int>[] : [-1, 1]) {
      final cx = vp.dx + side * rw * 0.42;
      a.box(
        Rect.fromCenter(
          center: Offset(cx, vp.dy + rh * 0.08),
          width: rw * 0.07,
          height: rh * 0.34,
        ),
        Color.lerp(_teakDark, _wall, 1 - t)!,
        line: 0.3,
      );
    }
  }
  a
    ..glow(vp, w * 0.08, StillroomPalette.fog, strength: 0.25)
    ..fade(a.r(0, 0, 1, 0.3), const Color(0xCC000000), const Color(0x00000000));
  _tiledFloor(a, 0.72);
}

void _office(Art a) {
  a
    ..fill(Offset.zero & a.size, _sepia)
    ..fill(a.r(0, 0.62, 1, 0.38), _sepiaLight)
    ..floorboards(a.r(0, 0.86, 1, 0.14))
    // A tall window with 1907 daylight.
    ..path(_archPath(a.r(0.38, 0.06, 0.12, 0.5)), const Color(0xFFCDB789))
    ..glow(
      a.p(0.44, 0.4),
      a.size.width * 0.25,
      const Color(0xFFF2D59A),
      strength: 0.25,
    )
    ..strokePath(_archPath(a.r(0.38, 0.06, 0.12, 0.5)), _teakDark, width: 1.2)
    ..line(a.p(0.44, 0.1), a.p(0.44, 0.56), _teakDark, width: 0.8)
    ..line(a.p(0.38, 0.34), a.p(0.5, 0.34), _teakDark, width: 0.8)
    ..fade(a.r(0, 0, 1, 0.2), const Color(0x88000000), const Color(0x00000000));
}

void _window1945(Art a) {
  a.fill(Offset.zero & a.size, _wall);
  final glass = a.r(0.06, 0.06, 0.56, 0.62);
  // Everything seen through the window stays inside its arch.
  a.canvas
    ..save()
    ..clipPath(_archPath(glass));
  a
    ..fade(glass, const Color(0xFF1C1512), const Color(0xFF4A2A18))
    // Smoke and distant fire over the square.
    ..glow(a.p(0.3, 0.6), a.size.width * 0.3, _ember, strength: 0.35)
    ..glow(
      a.p(0.5, 0.45),
      a.size.width * 0.18,
      StillroomPalette.fog,
      strength: 0.3,
    )
    // Trees and rooftops across the road.
    ..path(
      a.poly([
        a.p(0.06, 0.6),
        a.p(0.12, 0.5),
        a.p(0.16, 0.56),
        a.p(0.22, 0.46),
        a.p(0.3, 0.55),
        a.p(0.4, 0.5),
        a.p(0.48, 0.56),
        a.p(0.56, 0.48),
        a.p(0.62, 0.55),
        a.p(0.62, 0.68),
        a.p(0.06, 0.68),
      ]),
      const Color(0xFF0E0A08),
      line: 0,
    )
    ..fill(a.r(0.335, 0.06, 0.012, 0.62), _teakDark)
    ..fill(a.r(0.06, 0.4, 0.56, 0.012), _teakDark);
  a.canvas.restore();
  a
    ..strokePath(_archPath(glass), _teakDark, width: 2)
    ..path(_archPath(glass), const Color(0x00000000), line: 1.2)
    ..wood(a.r(0.02, 0.68, 0.64, 0.05), base: _teak, grain: 1)
    ..fade(
      a.r(0, 0.73, 1, 0.27),
      const Color(0xFF151816),
      const Color(0xFF0A0C0B),
    );
}

void _cellar(Art a) {
  a.fill(Offset.zero & a.size, const Color(0xFF151B1A));
  // Low vaults.
  for (final (x, w) in [(-0.1, 0.5), (0.3, 0.4), (0.62, 0.5)]) {
    a.strokePath(
      _archPath(a.r(x, 0.05, w, 0.9)),
      const Color(0xFF2C3634),
      width: 2,
    );
  }
  // Still water with reflections.
  a
    ..fade(
      a.r(0, 0.62, 1, 0.38),
      const Color(0xFF1E2A2A),
      const Color(0xFF0B1010),
    )
    ..line(a.p(0.1, 0.7), a.p(0.35, 0.7), const Color(0x334E5A52), width: 0.6)
    ..line(a.p(0.5, 0.78), a.p(0.9, 0.78), const Color(0x334E5A52), width: 0.6)
    ..line(a.p(0.2, 0.88), a.p(0.6, 0.88), const Color(0x224E5A52), width: 0.6)
    ..glow(
      a.p(0.5, 0.5),
      a.size.width * 0.35,
      StillroomPalette.gaslight,
      strength: 0.08,
    );
}

void _lockerRoom(Art a) {
  // White tiles gone grey.
  a.fill(Offset.zero & a.size, const Color(0xFF39413D));
  for (var x = 0.0; x < 1; x += 0.04) {
    a.line(a.p(x, 0), a.p(x, 0.86), const Color(0xFF2C3330), width: 0.3);
  }
  for (var y = 0.0; y < 0.86; y += 0.06) {
    a.line(a.p(0, y), a.p(1, y), const Color(0xFF2C3330), width: 0.3);
  }
  a
    ..fade(a.r(0, 0, 1, 0.4), const Color(0xCC000000), const Color(0x00000000))
    ..floorboards(a.r(0, 0.86, 1, 0.14));
}

// ---------------------------------------------------------------------------
// Puzzle boards

void _timetableBoard(Art a) {
  a
    ..wood(Offset.zero & a.size, base: _sepia, grain: 6)
    ..box(a.r(0.03, 0.08, 0.94, 0.84), const Color(0xFF14110E), line: 0.8)
    ..label('1867', a.p(0.5, 0.2), a.size.height * 0.08, _enamel)
    ..line(a.p(0.08, 0.3), a.p(0.92, 0.3), const Color(0x55D7D1C1), width: 0.4)
    ..line(a.p(0.08, 0.7), a.p(0.92, 0.7), const Color(0x55D7D1C1), width: 0.4);
}

void _telegraphBoard(Art a) {
  a
    ..fill(Offset.zero & a.size, _sepia)
    ..wood(a.r(0, 0.62, 1, 0.38), base: _sepiaLight, grain: 3)
    ..glow(
      a.p(0.5, 0.5),
      a.size.width * 0.35,
      const Color(0xFFF2D59A),
      strength: 0.12,
    )
    // Brass sounder behind the keys.
    ..rbox(a.r(0.4, 0.12, 0.2, 0.16), a.u * 2, StillroomPalette.brass)
    ..fill(a.r(0.42, 0.2, 0.16, 0.03), _teakDark);
}

void _clockBoard(Art a) {
  a.fill(Offset.zero & a.size, _wall);
  final c = a.p(0.5, 0.5);
  final r = a.size.height * 0.46;
  a
    ..circle(c, r, const Color(0xFF1B211F), line: 1)
    ..circle(c, r * 0.94, _enamel, line: 0.6)
    ..circle(c, r * 0.72, const Color(0xFFE3DDCE), line: 0);
  for (var h = 0; h < 12; h++) {
    final angle = h * math.pi / 6;
    final dir = Offset(math.sin(angle), -math.cos(angle));
    a.line(
      c + dir * r * 0.8,
      c + dir * r * 0.9,
      Art.outline,
      width: h % 3 == 0 ? 1.4 : 0.6,
    );
  }
}

void _lockerDoorBoard(Art a) {
  a
    ..fill(Offset.zero & a.size, _iron)
    ..box(a.r(0.04, 0.05, 0.92, 0.9), const Color(0xFF333A3D), line: 0.8);
  for (var y = 0.1; y < 0.95; y += 0.1) {
    a.circle(a.p(0.07, y), a.u * 0.8, const Color(0xFF4A5256), line: 0);
    a.circle(a.p(0.93, y), a.u * 0.8, const Color(0xFF4A5256), line: 0);
  }
  a.rbox(a.r(0.3, 0.25, 0.4, 0.5), a.u * 3, StillroomPalette.brass, line: 0.6);
}

void _lockersBoard(Art a) {
  _lockerRoom(a);
  // Frames around the puzzle's slot rects (x, 0.18, 0.12, 0.40).
  for (var k = 0; k < 5; k++) {
    final x = 0.08 + k * 0.18;
    a
      ..box(a.r(x - 0.02, 0.1, 0.16, 0.62), _iron, line: 0.8)
      ..box(a.r(x, 0.18, 0.12, 0.40), const Color(0xFF15191A), line: 0.5)
      ..rbox(a.r(x + 0.02, 0.63, 0.08, 0.05), a.u, _enamel, line: 0.3);
  }
}

void _glassBoard(Art a) {
  a
    ..fill(Offset.zero & a.size, _wall)
    ..path(_archPath(a.r(0.2, -0.05, 0.6, 1.1)), const Color(0xFF111614))
    ..glow(a.p(0.5, 0.5), a.size.height * 0.6, _amber, strength: 0.08);
}

// ---------------------------------------------------------------------------
// Objects

void _staircase(Art a) {
  for (var i = 0; i < 8; i++) {
    final t = i / 8;
    final inset = 0.18 * (1 - t);
    a.box(
      a.r(inset, t, 1 - inset * 2, 1 / 8),
      Color.lerp(const Color(0xFF1A1E1C), _wallPale, t)!,
      line: 0.4,
    );
  }
  // Balustrades.
  for (final left in [true, false]) {
    final x0 = left ? 0.0 : 1.0;
    final x1 = left ? 0.18 : 0.82;
    a
      ..line(a.p(x1, 0), a.p(x0, 1), _teakDark, width: 2.4)
      ..line(a.p(x1, -0.04), a.p(x0, 0.96), _teak, width: 1);
  }
}

void _stainedGlass(Art a, {required bool lit}) {
  final frame = Offset.zero & a.size;
  final colors = lit
      ? [_amber, _ruby, _cobalt, _emerald]
      : [
          const Color(0xFF3A3A33),
          const Color(0xFF332827),
          const Color(0xFF26303A),
          const Color(0xFF263229),
        ];
  final arch = _archPath(frame.deflate(a.u * 1.5));
  a.canvas
    ..save()
    ..clipPath(arch);
  // Panes: four columns of coloured glass, lead lines between.
  for (var col = 0; col < 4; col++) {
    for (var row = 0; row < 6; row++) {
      a.fill(
        a.r(col * 0.25, row / 6, 0.25, 1 / 6),
        colors[(col + row) % 4].withValues(alpha: lit ? 0.9 : 0.8),
      );
    }
  }
  // The winged wheel at the centre.
  final c = a.p(0.5, 0.6);
  final r = a.size.shortestSide * 0.16;
  a
    ..circle(c, r, lit ? _amber : const Color(0xFF45402F), line: 0.8)
    ..circle(c, r * 0.3, lit ? _enamel : const Color(0xFF4A4A40), line: 0.5);
  for (final side in [-1, 1]) {
    a.path(
      a.poly([
        c.translate(side * r * 0.9, -r * 0.2),
        c.translate(side * r * 2.6, -r * 1.2),
        c.translate(side * r * 2.2, r * 0.3),
      ]),
      lit ? _enamel : const Color(0xFF4D4D45),
    );
  }
  if (lit) a.glow(c, r * 4, _amber, strength: 0.35);
  a.canvas.restore();
  // Lead cames.
  for (var col = 1; col < 4; col++) {
    a.line(a.p(col * 0.25, 0), a.p(col * 0.25, 1), Art.outline, width: 0.6);
  }
  for (var row = 1; row < 6; row++) {
    a.line(a.p(0, row / 6), a.p(1, row / 6), Art.outline, width: 0.6);
  }
  a.strokePath(arch, _teakDark, width: 2.4);
}

void _stationClock(Art a, {required bool running}) {
  final c = a.p(0.5, 0.42);
  final r = a.size.shortestSide * 0.38;
  a
    ..line(a.p(0.5, 0), a.p(0.5, 0.06), _iron, width: 2)
    ..circle(c, r, const Color(0xFF1B211F), line: 0.8)
    ..circle(c, r * 0.9, _enamel, line: 0.4);
  for (var h = 0; h < 12; h++) {
    final angle = h * math.pi / 6;
    final dir = Offset(math.sin(angle), -math.cos(angle));
    a.line(c + dir * r * 0.72, c + dir * r * 0.84, Art.outline, width: 0.6);
  }
  // Date windows: day and month.
  final day = Rect.fromCenter(
    center: c.translate(-r * 0.22, r * 0.4),
    width: r * 0.36,
    height: r * 0.22,
  );
  final month = Rect.fromCenter(
    center: c.translate(r * 0.22, r * 0.4),
    width: r * 0.36,
    height: r * 0.22,
  );
  a
    ..box(day, const Color(0xFF1A1714), line: 0.3)
    ..box(month, const Color(0xFF1A1714), line: 0.3);
  if (running) {
    a
      ..label('15', day.center, day.height * 0.8, _enamel)
      ..label('10', month.center, month.height * 0.8, _enamel);
  }
  Offset hand(double turns, double length) {
    final angle = turns * 2 * math.pi;
    return c + Offset(math.sin(angle), -math.cos(angle)) * r * length;
  }

  final minutes = running ? 0.25 : 0.0;
  final hours = running ? 0.52 : 0.0;
  a
    ..line(c, hand(minutes, 0.7), Art.outline, width: 1)
    ..line(c, hand(hours, 0.45), Art.outline, width: 1.6)
    ..circle(c, a.u * 1.5, StillroomPalette.brass, line: 0.3);
}

void _niche(Art a) => a
  ..box(Offset.zero & a.size, const Color(0xFF0E1110), line: 0.8)
  ..fill(a.r(0, 0, 0.12, 1), _teakDark)
  ..fill(a.r(0.88, 0, 0.12, 1), _teakDark);

void _lantern(Art a, {required bool lit}) {
  final body = a.r(0.28, 0.25, 0.44, 0.55);
  if (lit) {
    a.glow(
      body.center,
      a.size.shortestSide * 0.8,
      StillroomPalette.gaslight,
      strength: 0.5,
    );
  }
  a
    ..strokePath(
      Path()..addArc(a.r(0.35, 0.02, 0.3, 0.26), math.pi, math.pi),
      _iron,
      width: 3,
    )
    ..box(a.r(0.24, 0.2, 0.52, 0.07), _iron)
    ..box(
      body,
      lit ? const Color(0xFFF2C66A) : const Color(0x553A4440),
      line: 0.6,
    )
    ..box(a.r(0.24, 0.8, 0.52, 0.1), _iron);
  for (final x in [0.28, 0.72]) {
    a.line(a.p(x, 0.25), a.p(x, 0.8), _iron, width: 1.6);
  }
  if (lit) a.flame(a.p(0.5, 0.7), a.size.height * 0.25);
}

void _door(Art a, String? year, {bool dial = false}) {
  a
    ..fill(Offset.zero & a.size, _teakDark)
    // Fanlight.
    ..path(_archPath(a.r(0.08, 0.02, 0.84, 0.3)), const Color(0xFF1A2220))
    ..strokePath(_archPath(a.r(0.08, 0.02, 0.84, 0.3)), _teak, width: 1.2)
    ..line(a.p(0.5, 0.02), a.p(0.5, 0.32), _teak, width: 0.8);
  // Two leaves with raised panels.
  for (final x in [0.08, 0.5]) {
    a.wood(a.r(x, 0.32, 0.42, 0.68), base: _teak, grain: 2, vertical: true);
    for (final (y, h) in [(0.36, 0.26), (0.66, 0.3)]) {
      a.box(a.r(x + 0.06, y, 0.3, h), _teakDark, line: 0.4);
    }
  }
  a.circle(a.p(0.46, 0.64), a.u * 2.5, StillroomPalette.brass, line: 0.3);
  if (year != null) {
    a
      ..rbox(a.r(0.3, 0.26, 0.4, 0.06), a.u, _enamel, line: 0.3)
      ..label(year, a.p(0.5, 0.29), a.size.height * 0.035, _enamelBlue);
  }
  if (dial) {
    a
      ..circle(
        a.p(0.5, 0.29),
        a.size.width * 0.12,
        StillroomPalette.brass,
        line: 0.5,
      )
      ..circle(
        a.p(0.5, 0.29),
        a.size.width * 0.05,
        const Color(0xFF6E5A30),
        line: 0.3,
      );
  }
}

void _officeDesk(Art a) {
  a
    ..wood(a.r(0, 0.1, 1, 0.14), base: _sepiaLight, grain: 1)
    ..wood(a.r(0.04, 0.24, 0.92, 0.4), base: _sepia, grain: 3)
    ..box(a.r(0.1, 0.3, 0.3, 0.26), _sepiaLight, line: 0.4)
    ..box(a.r(0.6, 0.3, 0.3, 0.26), _sepiaLight, line: 0.4)
    ..circle(a.p(0.25, 0.43), a.u * 1.8, StillroomPalette.brass, line: 0.3)
    ..circle(a.p(0.75, 0.43), a.u * 1.8, StillroomPalette.brass, line: 0.3)
    ..wood(a.r(0.06, 0.64, 0.06, 0.36), base: _sepia, grain: 0)
    ..wood(a.r(0.88, 0.64, 0.06, 0.36), base: _sepia, grain: 0);
}

void _timetable(Art a) {
  a
    ..wood(Offset.zero & a.size, base: _teak, grain: 0)
    ..box(a.r(0.04, 0.06, 0.92, 0.88), const Color(0xFF14110E), line: 0.5)
    ..label('1867', a.p(0.5, 0.16), a.size.height * 0.1, _enamel);
  for (var i = 0; i < 4; i++) {
    a
      ..rbox(a.r(0.1, 0.28 + i * 0.16, 0.5, 0.1), a.u, _enamel, line: 0.3)
      ..line(
        a.p(0.66, 0.33 + i * 0.16),
        a.p(0.9, 0.33 + i * 0.16),
        const Color(0x88D7D1C1),
        width: 0.4,
      );
  }
}

void _telegraph(Art a) {
  a
    ..wood(a.r(0.05, 0.55, 0.9, 0.4), base: _teak, grain: 1)
    ..rbox(a.r(0.1, 0.1, 0.36, 0.45), a.u * 2, StillroomPalette.brass)
    ..fill(a.r(0.14, 0.26, 0.28, 0.06), _teakDark)
    ..line(a.p(0.55, 0.55), a.p(0.88, 0.42), StillroomPalette.brass, width: 2.2)
    ..circle(a.p(0.88, 0.42), a.u * 5, const Color(0xFF1B1511), line: 0.5);
}

void _oilCan(Art a) => a
  ..rbox(a.r(0.2, 0.3, 0.6, 0.62), a.u * 3, const Color(0xFF5A4A2A))
  ..box(a.r(0.24, 0.5, 0.52, 0.2), StillroomPalette.paperShade, line: 0.3)
  ..box(a.r(0.42, 0.14, 0.16, 0.16), const Color(0xFF3D3220))
  ..line(a.p(0.58, 0.2), a.p(0.82, 0.08), const Color(0xFF3D3220), width: 2);

void _calendar(Art a) {
  a
    ..paper(Offset.zero & a.size, lines: 0, color: const Color(0xFFD8CDB1))
    ..fill(a.r(0, 0, 1, 0.16), _ruby)
    ..label(
      '15',
      a.p(0.5, 0.45),
      a.size.height * 0.34,
      StillroomPalette.inkOnPaper,
    )
    ..label(
      'X · 1945',
      a.p(0.5, 0.78),
      a.size.height * 0.1,
      StillroomPalette.inkOnPaper,
    )
    ..circle(a.p(0.5, 0.04), a.u * 3, _iron, line: 0.3);
}

void _cap(Art a) {
  a
    ..path(
      a.poly([a.p(0.1, 0.62), a.p(0.2, 0.2), a.p(0.8, 0.14), a.p(0.92, 0.55)]),
      const Color(0xFF1E2426),
    )
    ..oval(a.r(0.02, 0.55, 0.62, 0.3), const Color(0xFF0F1213))
    ..fill(a.r(0.2, 0.5, 0.6, 0.08), const Color(0xFF2B2014))
    ..circle(a.p(0.5, 0.36), a.u * 4, StillroomPalette.brass, line: 0.3);
}

void _darkness(Art a) {
  a
    ..fill(Offset.zero & a.size, const Color(0xFF040505))
    // Barely there: the arch you can't see, and the water's sheen.
    ..strokePath(
      _archPath(a.r(0.3, 0.05, 0.4, 0.9)),
      const Color(0xFF0D1110),
      width: 1.5,
    )
    ..line(a.p(0.3, 0.8), a.p(0.7, 0.8), const Color(0xFF0E1413), width: 0.6);
}

void _tally(Art a) {
  const scratch = Color(0xFF8C9690);
  for (var g = 0; g < 6; g++) {
    final gx = 0.05 + (g % 3) * 0.32;
    final gy = 0.1 + (g ~/ 3) * 0.48;
    final marks = g == 5 ? 3 : 5;
    for (var m = 0; m < math.min(4, marks); m++) {
      a.line(
        a.p(gx + m * 0.05, gy),
        a.p(gx + m * 0.05, gy + 0.32),
        scratch,
        width: 0.7,
      );
    }
    if (marks == 5) {
      a.line(
        a.p(gx - 0.02, gy + 0.28),
        a.p(gx + 0.2, gy + 0.04),
        scratch,
        width: 0.7,
      );
    }
  }
}

void _chair(Art a) {
  const wood = Color(0xFF3A2C20);
  a
    ..box(a.r(0.15, 0.0, 0.7, 0.08), wood)
    ..line(a.p(0.2, 0.0), a.p(0.2, 1), wood, width: 3)
    ..line(a.p(0.8, 0.0), a.p(0.8, 1), wood, width: 3)
    ..box(a.r(0.1, 0.5, 0.8, 0.07), wood)
    ..line(a.p(0.14, 0.57), a.p(0.14, 1), wood, width: 2.4)
    ..line(a.p(0.86, 0.57), a.p(0.86, 1), wood, width: 2.4)
    ..fill(a.r(0, 0.86, 1, 0.14), const Color(0x661E2A2A));
}

void _whistle(Art a, {required bool glint}) {
  if (glint) {
    a.glow(
      a.p(0.5, 0.5),
      a.size.shortestSide,
      StillroomPalette.gaslight,
      strength: 0.4,
    );
  }
  a
    ..rbox(a.r(0.1, 0.35, 0.55, 0.3), a.u * 6, StillroomPalette.brass)
    ..circle(a.p(0.7, 0.5), a.size.shortestSide * 0.24, StillroomPalette.brass)
    ..circle(
      a.p(0.7, 0.5),
      a.size.shortestSide * 0.1,
      const Color(0xFF6E5A30),
      line: 0.2,
    );
}

void _lockerRow(Art a, {required bool filled}) {
  for (var k = 0; k < 5; k++) {
    final x = 0.01 + k * 0.2;
    final door = a.r(x, 0.02, 0.17, 0.96);
    a.box(door, _iron, line: 0.8);
    for (var v = 0; v < 3; v++) {
      a.line(
        a.p(x + 0.03, 0.1 + v * 0.03),
        a.p(x + 0.14, 0.1 + v * 0.03),
        const Color(0xFF1A1E20),
        width: 0.6,
      );
    }
    a
      ..rbox(a.r(x + 0.04, 0.3, 0.09, 0.07), a.u, _enamel, line: 0.3)
      ..circle(
        a.p(x + 0.14, 0.55),
        a.u * 1.4,
        StillroomPalette.brass,
        line: 0.2,
      );
    if (filled) {
      a
        ..glow(
          Offset(door.center.dx, door.bottom - door.height * 0.25),
          door.width,
          StillroomPalette.gaslight,
          strength: 0.2,
        )
        ..fill(
          Rect.fromLTWH(door.left, door.top, a.u * 1.5, door.height),
          StillroomPalette.gaslight.withValues(alpha: 0.6),
        );
    }
  }
}

void _stationPlate(Art a) => a
  ..rbox(Offset.zero & a.size, a.u * 6, _enamelBlue)
  ..rbox(a.r(0.06, 0.12, 0.88, 0.76), a.u * 4, _enamel, line: 0.3);

void _morseKey(Art a, {required bool dash}) {
  final c = a.p(0.5, 0.55);
  final r = a.size.shortestSide * 0.36;
  a
    ..oval(a.r(0.1, 0.72, 0.8, 0.2), _teakDark, line: 0.4)
    ..line(c, a.p(0.5, 0.82), StillroomPalette.brass, width: 3)
    ..circle(c, r, const Color(0xFF1B1511), line: 0.8)
    ..circle(c, r * 0.82, const Color(0xFF2A211A), line: 0);
  if (dash) {
    a.fill(
      Rect.fromCenter(center: c, width: r * 1.1, height: r * 0.22),
      _enamel,
    );
  } else {
    a.circle(c, r * 0.18, _enamel, line: 0);
  }
}

enum _Ring { flora, cities, wheel }

/// A stained-glass ring as a full circle (see RotaryAlignView): outer flora
/// (edge → 0.72 of the radius), middle cities (→ 0.615), inner winged wheel
/// (→ 0.375). The mark at the top is the ring's "true" position.
void _glassRing(Art a, _Ring ring) {
  final c = a.p(0.5, 0.5);
  final outer = a.size.shortestSide / 2;
  final inner =
      outer *
      switch (ring) {
        _Ring.flora => 0.72,
        _Ring.cities => 0.615,
        _Ring.wheel => 0.375,
      };
  final base = switch (ring) {
    _Ring.flora => _emerald,
    _Ring.cities => _cobalt,
    _Ring.wheel => _amber,
  };
  final band = Path()
    ..addOval(Rect.fromCircle(center: c, radius: outer))
    ..addOval(Rect.fromCircle(center: c, radius: inner))
    ..fillType = PathFillType.evenOdd;
  a.canvas.drawPath(band, Paint()..color = base.withValues(alpha: 0.9));
  // Segments of glass with lead between them.
  const segments = 16;
  for (var i = 0; i < segments; i++) {
    final angle = 2 * math.pi * i / segments;
    final dir = Offset(math.sin(angle), -math.cos(angle));
    a.line(c + dir * inner, c + dir * outer, Art.outline, width: 0.5);
    if (i.isOdd) {
      final mid = c + dir * (inner + outer) / 2;
      final motif = switch (ring) {
        _Ring.flora => _emerald.withValues(alpha: 1),
        _Ring.cities => _enamel.withValues(alpha: 0.5),
        _Ring.wheel => _ruby,
      };
      a.circle(mid, (outer - inner) * 0.18, motif, line: 0.2);
    }
  }
  a.canvas
    ..drawCircle(
      c,
      outer * 0.995,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = a.u * 0.8
        ..color = Art.outline,
    )
    ..drawCircle(
      c,
      inner,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = a.u * 0.8
        ..color = Art.outline,
    );
  // The mark: a gold leaf (flora), a gold star (cities), fire and water
  // meeting (wheel).
  final width = outer - inner;
  final top = c.translate(0, -outer + width / 2);
  switch (ring) {
    case _Ring.wheel:
      a
        ..circle(
          top.translate(-width * 0.18, 0),
          width * 0.16,
          _ruby,
          line: 0.3,
        )
        ..circle(
          top.translate(width * 0.18, 0),
          width * 0.16,
          _cobalt,
          line: 0.3,
        )
        ..circle(c, inner * 0.35, _enamel, line: 0.5);
    case _Ring.flora || _Ring.cities:
      a.path(
        a.poly([
          top.translate(0, -width * 0.32),
          top.translate(width * 0.18, 0),
          top.translate(0, width * 0.32),
          top.translate(-width * 0.18, 0),
        ]),
        _amber,
        line: 0.3,
      );
  }
}

// ---------------------------------------------------------------------------
// Items

void _closedBook(Art a) => a
  ..rbox(a.r(0.16, 0.14, 0.68, 0.74), a.u * 2, const Color(0xFF3A2416))
  ..fill(a.r(0.2, 0.14, 0.06, 0.74), const Color(0xFF26170E))
  ..rbox(
    a.r(0.38, 0.36, 0.34, 0.14),
    a.u,
    StillroomPalette.paperShade,
    line: 0.3,
  );

void _openBook(Art a, {required bool small}) {
  if (!small) a.fill(Offset.zero & a.size, const Color(0xFF15110E));
  final book = small ? Offset.zero & a.size : a.r(0.04, 0.04, 0.92, 0.92);
  a
    ..rbox(book, a.u * 2, const Color(0xFF3A2416))
    ..box(
      Rect.fromLTRB(
        book.left + book.width * 0.03,
        book.top + book.height * 0.04,
        book.center.dx,
        book.bottom - book.height * 0.04,
      ),
      const Color(0xFFD6C9A8),
      line: 0.3,
    )
    ..box(
      Rect.fromLTRB(
        book.center.dx,
        book.top + book.height * 0.04,
        book.right - book.width * 0.03,
        book.bottom - book.height * 0.04,
      ),
      const Color(0xFFCFC2A0),
      line: 0.3,
    )
    ..line(
      book.topCenter,
      book.bottomCenter,
      const Color(0x55000000),
      width: 1.2,
    );
}

/// One spread of the ledger, drawn over the open book (layer rect 0.06–0.94).
void _page(Art a, int n) {
  _openBook(a, small: true);
  const inkColor = Color(0xAA2A1F17);
  final left = a.r(0.08, 0.1, 0.36, 0.8);
  switch (n) {
    case 0:
      // The 1867 line: four stations along a track.
      final pts = [
        a.p(0.12, 0.8),
        a.p(0.2, 0.62),
        a.p(0.3, 0.46),
        a.p(0.4, 0.22),
      ];
      for (var i = 0; i < pts.length - 1; i++) {
        a.line(pts[i], pts[i + 1], inkColor, width: 0.8);
      }
      for (final p in pts) {
        a.circle(p, a.u * 1.6, _ruby, line: 0.3);
      }
      a.label('1867', a.p(0.26, 0.14), a.size.height * 0.06, inkColor);
    case 1:
      // A Morse crib: N, I, S.
      for (final (row, letter, code) in [
        (0, 'N', '–·'),
        (1, 'I', '··'),
        (2, 'S', '···'),
      ]) {
        final y = 0.24 + row * 0.18;
        a
          ..label(letter, a.p(0.14, y), a.size.height * 0.08, inkColor)
          ..label(code, a.p(0.3, y), a.size.height * 0.08, inkColor);
      }
    case 2:
      // A floor plan and the count in the margin.
      a
        ..strokePath(
          Path()..addRect(left.deflate(a.u * 3)),
          inkColor,
          width: 0.5,
        )
        ..line(
          Offset(left.center.dx, left.top + a.u * 3),
          Offset(left.center.dx, left.bottom - a.u * 3),
          inkColor,
          width: 0.4,
        )
        ..label('928', a.p(0.26, 0.86), a.size.height * 0.07, _ruby);
    case 3:
      // The glass: a winged wheel, fire and water at the top.
      final c = a.p(0.26, 0.52);
      final r = a.size.shortestSide * 0.1;
      a
        ..strokePath(
          Path()..addOval(Rect.fromCircle(center: c, radius: r)),
          inkColor,
          width: 0.6,
        )
        ..circle(c.translate(-r * 0.3, -r), r * 0.22, _ruby, line: 0.2)
        ..circle(c.translate(r * 0.3, -r), r * 0.22, _cobalt, line: 0.2)
        ..line(
          c.translate(-r, 0),
          c.translate(-r * 2.2, -r * 0.8),
          inkColor,
          width: 0.5,
        )
        ..line(
          c.translate(r, 0),
          c.translate(r * 2.2, -r * 0.8),
          inkColor,
          width: 0.5,
        );
  }
  // Writing on the right page, and a corner to turn.
  for (var i = 0; i < 8; i++) {
    final y = 0.18 + i * 0.08;
    a.line(
      a.p(0.56, y),
      a.p(i.isOdd ? 0.84 : 0.9, y),
      const Color(0x552A1F17),
      width: 0.3,
    );
  }
  a.path(
    a.poly([a.p(0.97, 0.86), a.p(0.97, 0.96), a.p(0.87, 0.96)]),
    const Color(0xFFB8AA86),
    line: 0.3,
  );
}

void _ticketPunch(Art a) => a
  ..line(a.p(0.2, 0.8), a.p(0.62, 0.3), _iron, width: 4)
  ..line(a.p(0.4, 0.86), a.p(0.72, 0.4), _iron, width: 4)
  ..circle(a.p(0.66, 0.34), a.u * 6, const Color(0xFF4A5256), line: 0.5)
  ..rbox(a.r(0.62, 0.12, 0.26, 0.2), a.u * 3, const Color(0xFF4A5256))
  ..rbox(a.r(0.66, 0.16, 0.12, 0.1), a.u, StillroomPalette.paper, line: 0.2);

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
  // Inside: a tall arched window of coloured glass, glowing in the dark.
  a
    ..fill(a.r(0, 0.16, 1, 0.84), const Color(0xFF1A201E))
    ..glow(a.p(0.5, 0.52), w * 0.6, _amber, strength: 0.35);
  final window = a.r(0.3, 0.3, 0.4, 0.5);
  a.canvas
    ..save()
    ..clipPath(_archPath(window));
  for (var i = 0; i < 4; i++) {
    a.fill(
      a.r(0.3 + i * 0.1, 0.3, 0.1, 0.5),
      [_amber, _ruby, _cobalt, _emerald][i],
    );
  }
  a.canvas.restore();
  a
    ..strokePath(_archPath(window), Art.outline, width: 1.2)
    ..fill(a.r(0, 0.8, 1, 0.2), const Color(0xFF111513));
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
