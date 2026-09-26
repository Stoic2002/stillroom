import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../core/art/art_kit.dart';
import '../../../core/theme/stillroom_palette.dart';

/// The Stillroom itself, behind the main menu (docs/stillroom_frame.md): a
/// shelf of faintly glowing jars, a tall clock whose pendulum swings while
/// its hands never move, drying herbs, and a candle whose light makes the
/// dust visible. Now and then one jar rattles, as if its tale stirred.
///
/// Drawn in code until real art exists. Motion stops when the device asks
/// for reduced motion, and while another screen covers the menu.
class LobbyScene extends StatefulWidget {
  const LobbyScene({super.key});

  @override
  State<LobbyScene> createState() => _LobbySceneState();
}

class _LobbySceneState extends State<LobbyScene>
    with SingleTickerProviderStateMixin {
  final _time = ValueNotifier<double>(0);
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(
      (elapsed) => _time.value = elapsed.inMicroseconds / 1e6,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = MediaQuery.disableAnimationsOf(context);
    if (still && _ticker.isActive) _ticker.stop();
    if (!still && !_ticker.isActive) _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _time.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const RepaintBoundary(child: CustomPaint(painter: _RoomPainter())),
        RepaintBoundary(child: CustomPaint(painter: _LifePainter(_time))),
      ],
    );
  }
}

/// Where everything stands, for a given screen size. Sizes follow [s] so
/// the furniture keeps its shape on any aspect ratio.
final class _Layout {
  factory _Layout(Size size) {
    final w = size.width;
    final h = size.height;
    final s = math.min(h, w * 0.55);
    final floor = h * 0.93;

    final shelf = Rect.fromLTWH(w * 0.03, h * 0.08, s * 0.62, floor - h * 0.08);
    final boards = [
      for (final f in [0.3, 0.56, 0.82]) h * f,
    ];

    final clockW = s * 0.24;
    final clock = Rect.fromLTRB(
      w - w * 0.04 - clockW,
      h * 0.07,
      w - w * 0.04,
      floor,
    );

    final table = Rect.fromLTWH(
      clock.left - s * 0.08 - s * 0.26,
      h * 0.74,
      s * 0.26,
      floor - h * 0.74,
    );

    final jars = <_Jar>[];
    const colors = [
      StillroomPalette.gaslight,
      StillroomPalette.fog,
      StillroomPalette.oxbloodBright,
      Color(0xFF4F6A8A),
      StillroomPalette.paperShade,
      Color(0xFF6E7F4A),
    ];
    var n = 0;
    for (final (row, y) in boards.indexed) {
      var x = shelf.left + s * 0.05;
      final count = row == 1 ? 3 : 4;
      for (var i = 0; i < count; i++) {
        final jh = s * (0.1 + 0.06 * _hash(n * 7.1 + 3));
        final jw = jh * (0.62 + 0.18 * _hash(n * 3.3 + 1));
        final room = (shelf.width - s * 0.1) / count;
        jars.add(
          _Jar(
            bottom: Offset(x + room / 2, y),
            size: Size(jw, jh),
            color: colors[n % colors.length],
            phase: n * 1.7,
          ),
        );
        x += room;
        n++;
      }
    }

    return _Layout._(
      s: s,
      floor: floor,
      shelf: shelf,
      boards: boards,
      jars: jars,
      clock: clock,
      table: table,
      candle: Offset(table.left + table.width * 0.3, table.top),
      herbs: [clock.left - s * 0.3, clock.left - s * 0.12],
    );
  }

  _Layout._({
    required this.s,
    required this.floor,
    required this.shelf,
    required this.boards,
    required this.jars,
    required this.clock,
    required this.table,
    required this.candle,
    required this.herbs,
  });

  final double s;
  final double floor;
  final Rect shelf;
  final List<double> boards;
  final List<_Jar> jars;
  final Rect clock;
  final Rect table;

  /// Bottom of the candle holder, on the table.
  final Offset candle;
  double get candleHeight => s * 0.16;
  Offset get wick => candle.translate(0, -candleHeight * 0.95);

  /// X positions of the herb bundles hanging from the ceiling.
  final List<double> herbs;

  Rect get clockFace => Rect.fromCircle(
    center: Offset(clock.center.dx, clock.top + clock.width * 0.6),
    radius: clock.width * 0.34,
  );

  Rect get pendulumWindow => Rect.fromLTRB(
    clock.left + clock.width * 0.24,
    clock.top + clock.width * 1.2,
    clock.right - clock.width * 0.24,
    clock.bottom - s * 0.16,
  );
}

final class _Jar {
  const _Jar({
    required this.bottom,
    required this.size,
    required this.color,
    required this.phase,
  });

  final Offset bottom;
  final Size size;
  final Color color;
  final double phase;
}

/// 0–1, stable for a given seed.
double _hash(double seed) {
  final v = math.sin(seed * 12.9898) * 43758.5453;
  return v - v.floorToDouble();
}

/// The still parts: walls, shelf, clock case, table.
class _RoomPainter extends CustomPainter {
  const _RoomPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final a = Art(canvas, size);
    final l = _Layout(size);
    final w = size.width;
    final h = size.height;

    a
      ..wallpaper(
        Offset.zero & size,
        const Color(0xFF19130F),
        const Color(0xFF1F1812),
        every: 0.035,
      )
      ..fade(
        Rect.fromLTWH(0, 0, w, h * 0.25),
        Art.outline,
        const Color(0x00000000),
      );

    // Wainscot panels and floor.
    final wainscot = Rect.fromLTRB(0, h * 0.68, w, l.floor);
    a.wood(wainscot, base: const Color(0xFF1E150F), grain: 3, line: 0);
    for (var x = 0.0; x < w; x += l.s * 0.3) {
      a.ink(
        Rect.fromLTWH(
          x + l.s * 0.03,
          wainscot.top + l.s * 0.03,
          l.s * 0.24,
          wainscot.height - l.s * 0.06,
        ),
        width: 0.4,
      );
    }
    a
      ..hairline(
        Offset(0, wainscot.top),
        Offset(w, wainscot.top),
        StillroomPalette.walnutLight,
        0.6,
      )
      ..floorboards(Rect.fromLTRB(0, l.floor, w, h))
      ..fade(
        Rect.fromLTRB(0, l.floor, w, h),
        const Color(0x00000000),
        Art.outline,
      );

    // A beam across the ceiling, for the herbs.
    a.wood(
      Rect.fromLTWH(0, 0, w, l.s * 0.045),
      base: const Color(0xFF231911),
      grain: 2,
    );

    // Shelf: back, uprights, boards.
    final shelf = l.shelf;
    a.fill(shelf, const Color(0xFF140F0B));
    for (final x in [shelf.left, shelf.right - l.s * 0.03]) {
      a.wood(
        Rect.fromLTWH(x, shelf.top, l.s * 0.03, shelf.height),
        vertical: true,
        grain: 2,
      );
    }
    a.wood(
      Rect.fromLTWH(
        shelf.left - l.s * 0.02,
        shelf.top - l.s * 0.03,
        shelf.width + l.s * 0.04,
        l.s * 0.035,
      ),
    );
    for (final y in l.boards) {
      a
        ..fade(
          Rect.fromLTWH(shelf.left, y - l.s * 0.12, shelf.width, l.s * 0.12),
          const Color(0x00000000),
          const Color(0x33000000),
        )
        ..wood(
          Rect.fromLTWH(
            shelf.left - l.s * 0.01,
            y,
            shelf.width + l.s * 0.02,
            l.s * 0.025,
          ),
          grain: 1,
        );
    }

    // Clock case (face and pendulum are drawn by the living layer).
    final c = l.clock;
    final hood = Rect.fromLTRB(c.left, c.top, c.right, c.top + c.width * 1.15);
    final trunk = Rect.fromLTRB(
      c.left + c.width * 0.1,
      hood.bottom,
      c.right - c.width * 0.1,
      c.bottom - l.s * 0.1,
    );
    final plinth = Rect.fromLTRB(
      c.left - c.width * 0.02,
      trunk.bottom,
      c.right + c.width * 0.02,
      c.bottom,
    );
    a
      ..wood(trunk, vertical: true, grain: 3)
      ..wood(plinth, grain: 2)
      ..wood(hood, base: StillroomPalette.walnutLight, grain: 2);
    final pediment = Path()
      ..moveTo(c.left - c.width * 0.04, c.top)
      ..quadraticBezierTo(
        c.center.dx,
        c.top - c.width * 0.35,
        c.right + c.width * 0.04,
        c.top,
      )
      ..close();
    a.path(pediment, StillroomPalette.walnut);
    final window = l.pendulumWindow;
    a
      ..fill(window, const Color(0xFF0B0806))
      ..box(window.inflate(l.s * 0.006), const Color(0x00000000), line: 0.5)
      ..circle(
        l.clockFace.center,
        l.clockFace.width / 2 + l.s * 0.012,
        StillroomPalette.brass,
      )
      ..circle(
        l.clockFace.center,
        l.clockFace.width / 2,
        StillroomPalette.paperShade,
        line: 0.4,
      );
    for (var i = 0; i < 12; i++) {
      final angle = i * math.pi / 6;
      final r = l.clockFace.width / 2;
      a.hairline(
        l.clockFace.center +
            Offset(math.sin(angle), -math.cos(angle)) * r * 0.82,
        l.clockFace.center +
            Offset(math.sin(angle), -math.cos(angle)) * r * 0.95,
        StillroomPalette.inkOnPaper,
        0.5,
      );
    }
    // The hands never move.
    void hand(double turns, double length, double width) {
      final angle = turns * 2 * math.pi;
      a.line(
        l.clockFace.center,
        l.clockFace.center + Offset(math.sin(angle), -math.cos(angle)) * length,
        StillroomPalette.inkOnPaper,
        width: width,
      );
    }

    hand(11.95 / 12, l.clockFace.width * 0.28, 0.9);
    hand(59 / 60, l.clockFace.width * 0.4, 0.5);

    // Side table with a book; the candle is part of the living layer.
    final t = l.table;
    final top = Rect.fromLTWH(
      t.left - l.s * 0.02,
      t.top,
      t.width + l.s * 0.04,
      l.s * 0.025,
    );
    a
      ..wood(
        Rect.fromLTWH(
          t.left + t.width * 0.12,
          top.bottom,
          l.s * 0.018,
          t.height,
        ),
        vertical: true,
        grain: 1,
      )
      ..wood(
        Rect.fromLTWH(
          t.right - t.width * 0.12 - l.s * 0.018,
          top.bottom,
          l.s * 0.018,
          t.height,
        ),
        vertical: true,
        grain: 1,
      )
      ..wood(top, base: StillroomPalette.walnutLight, grain: 1)
      ..paper(
        Rect.fromCenter(
          center: Offset(t.left + t.width * 0.72, t.top - l.s * 0.012),
          width: t.width * 0.42,
          height: l.s * 0.022,
        ),
        lines: 0,
        color: StillroomPalette.paperShade,
      )
      ..box(
        Rect.fromCenter(
          center: Offset(t.left + t.width * 0.72, t.top - l.s * 0.03),
          width: t.width * 0.38,
          height: l.s * 0.018,
        ),
        StillroomPalette.oxblood,
        line: 0.4,
      );
  }

  @override
  bool shouldRepaint(_RoomPainter oldDelegate) => false;
}

/// What moves: candlelight, dust, jars, pendulum, herbs, floor mist.
class _LifePainter extends CustomPainter {
  _LifePainter(this.time) : super(repaint: time);

  final ValueNotifier<double> time;

  /// Seconds between two jars stirring.
  static const stirEvery = 9.0;

  @override
  void paint(Canvas canvas, Size size) {
    final t = time.value;
    final a = Art(canvas, size);
    final l = _Layout(size);
    final flicker =
        0.86 +
        0.07 * math.sin(t * 9.1) +
        0.04 * math.sin(t * 23.7 + 1) +
        0.03 * math.sin(t * 3.3);

    // Candlelight on the room.
    a
      ..glow(
        l.wick,
        l.s * 1.4 * flicker,
        StillroomPalette.gaslight,
        strength: 0.12 * flicker,
      )
      ..glow(
        l.wick,
        l.s * 0.5 * flicker,
        StillroomPalette.gaslight,
        strength: 0.16 * flicker,
      );

    _jars(a, l, t);
    _pendulum(a, l, t);
    _herbs(a, l, t);

    // The candle, its flame swaying a little.
    a.candle(l.candle, l.candleHeight);
    canvas
      ..save()
      ..translate(l.wick.dx, l.wick.dy)
      ..skew(0.08 * math.sin(t * 1.9) + 0.03 * math.sin(t * 7.3), 0)
      ..translate(-l.wick.dx, -l.wick.dy);
    a.flame(
      l.wick,
      l.candleHeight * 0.35 * (0.94 + 0.12 * (flicker - 0.86) / 0.14),
    );
    canvas.restore();

    _moth(a, l, t);
    _dust(a, l, t, size);
    _mist(a, l, t, size);
  }

  void _jars(Art a, _Layout l, double t) {
    final stirring = (t / stirEvery).floor() % l.jars.length;
    final since = t % stirEvery;
    for (final (i, jar) in l.jars.indexed) {
      final stir = i == stirring && t > 1 && since < 0.8
          ? 1 - since / 0.8
          : 0.0;
      final pulse = 0.5 + 0.5 * math.sin(t * 0.55 + jar.phase);
      final canvas = a.canvas
        ..save()
        ..translate(jar.bottom.dx, jar.bottom.dy)
        ..rotate(stir * 0.07 * math.sin(since * 48))
        ..translate(-jar.bottom.dx, -jar.bottom.dy);

      final w = jar.size.width;
      final h = jar.size.height;
      final body = RRect.fromRectAndCorners(
        Rect.fromLTWH(
          jar.bottom.dx - w / 2,
          jar.bottom.dy - h * 0.86,
          w,
          h * 0.86,
        ),
        topLeft: Radius.circular(w * 0.28),
        topRight: Radius.circular(w * 0.28),
        bottomLeft: Radius.circular(w * 0.12),
        bottomRight: Radius.circular(w * 0.12),
      );
      final level = body.outerRect.top + h * (0.22 + 0.1 * _hash(jar.phase));
      final contents = Rect.fromLTRB(body.left, level, body.right, body.bottom);

      a.glow(
        contents.center,
        w * 1.1,
        jar.color,
        strength: 0.08 + 0.1 * pulse + 0.35 * stir,
      );
      canvas
        ..save()
        ..clipRRect(body)
        ..drawRect(
          contents,
          Paint()
            ..color = jar.color.withValues(
              alpha: 0.22 + 0.14 * pulse + 0.3 * stir,
            ),
        )
        ..restore()
        ..drawRRect(body, Paint()..color = const Color(0x1AD8C9A8))
        ..drawRRect(
          body,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = a.u * 0.35
            ..color = StillroomPalette.paperShade.withValues(alpha: 0.45),
        );
      // A highlight on the glass.
      a
        ..hairline(
          Offset(body.left + w * 0.2, body.top + h * 0.15),
          Offset(body.left + w * 0.2, body.bottom - h * 0.15),
          const Color(0x33FFFFFF),
          0.6,
        )
        // Cork and label.
        ..box(
          Rect.fromLTWH(
            jar.bottom.dx - w * 0.3,
            body.top - h * 0.12,
            w * 0.6,
            h * 0.14,
          ),
          const Color(0xFF7A5A3A),
          line: 0.3,
        )
        ..box(
          Rect.fromCenter(
            center: Offset(jar.bottom.dx, jar.bottom.dy - h * 0.3),
            width: w * 0.62,
            height: h * 0.18,
          ),
          StillroomPalette.paperShade,
          line: 0.3,
        );
      canvas.restore();
    }
  }

  /// A moth circling the flame, never quite reaching it.
  void _moth(Art a, _Layout l, double t) {
    final centre = l.wick.translate(0, -l.s * 0.07);
    final p =
        centre +
        Offset(
          math.cos(t * 1.3) * l.s * 0.11 + math.sin(t * 3.1) * l.s * 0.015,
          math.sin(t * 2.2) * l.s * 0.05,
        );
    final beat = 0.35 + 0.65 * math.sin(t * 38).abs();
    final wing = l.s * 0.013;
    a.canvas
      ..save()
      ..translate(p.dx, p.dy)
      ..scale(1, beat);
    for (final side in [-1.0, 1.0]) {
      a.canvas.drawOval(
        Rect.fromCenter(
          center: Offset(side * wing * 0.7, 0),
          width: wing * 1.4,
          height: wing * 1.8,
        ),
        Paint()..color = const Color(0xCC3A2E24),
      );
    }
    a.canvas.restore();
  }

  void _pendulum(Art a, _Layout l, double t) {
    final window = l.pendulumWindow;
    final pivot = Offset(window.center.dx, window.top + l.s * 0.01);
    final length = window.height * 0.82;
    // One swing per second: the tick you would hear.
    final angle = 0.16 * math.sin(t * math.pi);
    final bob = pivot + Offset(math.sin(angle), math.cos(angle)) * length;
    a.canvas
      ..save()
      ..clipRect(window);
    a
      ..line(pivot, bob, StillroomPalette.brass, width: 0.6)
      ..glow(bob, window.width * 0.5, StillroomPalette.gaslight, strength: 0.08)
      ..circle(bob, window.width * 0.22, StillroomPalette.brass, line: 0.4);
    a.canvas.restore();
  }

  void _herbs(Art a, _Layout l, double t) {
    for (final (i, x) in l.herbs.indexed) {
      final top = Offset(x, l.s * 0.045);
      final length = l.s * (0.16 + 0.05 * i);
      a.canvas
        ..save()
        ..translate(top.dx, top.dy)
        ..rotate(0.035 * math.sin(t * 0.7 + i * 2.1))
        ..translate(-top.dx, -top.dy);
      final tie = top.translate(0, length);
      a.line(top, tie, StillroomPalette.faded, width: 0.3);
      for (var k = 0; k < 7; k++) {
        final spread = (k - 3) * 0.12;
        final end =
            tie +
            Offset(math.sin(spread), math.cos(spread)) *
                l.s *
                (0.1 + 0.02 * (k % 3));
        a.line(
          tie,
          end,
          Color.lerp(const Color(0xFF4A5A36), StillroomPalette.faded, k / 7)!,
          width: 0.7,
        );
        a.circle(end, l.s * 0.006, const Color(0xFF5C4A6A), line: 0);
      }
      a.box(
        Rect.fromCenter(center: tie, width: l.s * 0.02, height: l.s * 0.012),
        StillroomPalette.oxblood,
        line: 0,
      );
      a.canvas.restore();
    }
  }

  void _dust(Art a, _Layout l, double t, Size size) {
    for (var i = 0; i < 40; i++) {
      final speed = 0.008 + 0.018 * _hash(i + 0.3);
      final rise = (_hash(i + 0.7) + t * speed) % 1.0;
      final p = Offset(
        _hash(i + 0.1) * size.width + math.sin(t * 0.4 + i) * l.s * 0.03,
        size.height * (1 - rise),
      );
      final near = 1 - ((p - l.wick).distance / (l.s * 1.1)).clamp(0.0, 1.0);
      final twinkle = 0.6 + 0.4 * math.sin(t * 1.3 + i * 2.7);
      a.canvas.drawCircle(
        p,
        l.s * (0.002 + 0.003 * _hash(i + 0.9)),
        Paint()
          ..color = StillroomPalette.paper.withValues(
            alpha: (0.06 + 0.5 * near) * twinkle,
          ),
      );
    }
  }

  void _mist(Art a, _Layout l, double t, Size size) {
    for (var i = 0; i < 3; i++) {
      final span = size.width * 1.8;
      final x =
          (i * 0.37 + t * (0.006 + 0.003 * i)) % 1.0 * span - size.width * 0.4;
      // A soft-edged gradient, not a blur: blurs are costly every frame.
      final oval = Rect.fromCenter(
        center: Offset(x, l.floor - l.s * 0.02 * i),
        width: size.width * 0.7,
        height: l.s * 0.2,
      );
      a.canvas.drawOval(
        oval,
        Paint()
          ..shader = RadialGradient(
            colors: [
              StillroomPalette.fog.withValues(alpha: 0.09),
              StillroomPalette.fog.withValues(alpha: 0),
            ],
          ).createShader(oval),
      );
    }
  }

  @override
  bool shouldRepaint(_LifePainter oldDelegate) => oldDelegate.time != time;
}
