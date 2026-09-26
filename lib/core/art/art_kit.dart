import 'dart:math' as math;

import 'package:flutter/painting.dart';

import '../theme/stillroom_palette.dart';

/// Draws one picture into [size]; coordinates are the painter's to choose.
typedef ArtPainter = void Function(Canvas canvas, Size size);

/// Drawing helpers for code-drawn art: normalized coordinates (0–1 of the
/// canvas), flat fills, and thin dark ink outlines, following
/// docs/art_style_guide.md.
final class Art {
  Art(this.canvas, this.size);

  final Canvas canvas;
  final Size size;

  static const outline = Color(0xFF070504);

  /// Stroke unit: 1% of the shorter side.
  double get u => size.shortestSide / 100;

  Rect r(double x, double y, double w, double h) => Rect.fromLTWH(
    x * size.width,
    y * size.height,
    w * size.width,
    h * size.height,
  );

  Offset p(double x, double y) => Offset(x * size.width, y * size.height);

  Paint _fill(Color color) => Paint()..color = color;

  Paint _stroke(Color color, double width) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round
    ..color = color;

  void fill(Rect rect, Color color) => canvas.drawRect(rect, _fill(color));

  void ink(Rect rect, {double width = 0.6}) =>
      canvas.drawRect(rect, _stroke(outline, width * u));

  /// Filled rect with an ink outline.
  void box(Rect rect, Color color, {double line = 0.6}) {
    fill(rect, color);
    if (line > 0) ink(rect, width: line);
  }

  void rbox(Rect rect, double radius, Color color, {double line = 0.6}) {
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    canvas.drawRRect(rr, _fill(color));
    if (line > 0) canvas.drawRRect(rr, _stroke(outline, line * u));
  }

  void oval(Rect rect, Color color, {double line = 0.6}) {
    canvas.drawOval(rect, _fill(color));
    if (line > 0) canvas.drawOval(rect, _stroke(outline, line * u));
  }

  void circle(Offset c, double radius, Color color, {double line = 0.6}) =>
      oval(
        Rect.fromCircle(center: c, radius: radius),
        color,
        line: line,
      );

  void line(Offset a, Offset b, Color color, {double width = 0.5}) =>
      canvas.drawLine(a, b, _stroke(color, width * u));

  void path(Path path, Color color, {double line = 0.6}) {
    canvas.drawPath(path, _fill(color));
    if (line > 0) canvas.drawPath(path, _stroke(outline, line * u));
  }

  void strokePath(Path path, Color color, {double width = 0.5}) =>
      canvas.drawPath(path, _stroke(color, width * u));

  Path poly(List<Offset> points) => Path()..addPolygon(points, true);

  /// Soft light: a radial fade from [color] to transparent.
  void glow(
    Offset center,
    double radius,
    Color color, {
    double strength = 0.5,
  }) {
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            color.withValues(alpha: strength),
            color.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
  }

  /// Vertical fade inside [rect], e.g. shadow under a ceiling.
  void fade(Rect rect, Color top, Color bottom) => canvas.drawRect(
    rect,
    Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [top, bottom],
      ).createShader(rect),
  );

  /// Wood: base fill, grain lines, ink outline.
  void wood(
    Rect rect, {
    Color base = StillroomPalette.walnut,
    bool vertical = false,
    int grain = 5,
    double line = 0.6,
  }) {
    fill(rect, base);
    final dark = Color.lerp(base, outline, 0.35)!;
    final random = math.Random(rect.left.round() * 31 + rect.top.round());
    for (var i = 1; i <= grain; i++) {
      final t = i / (grain + 1) + (random.nextDouble() - 0.5) * 0.05;
      if (vertical) {
        final x = rect.left + rect.width * t;
        hairline(Offset(x, rect.top), Offset(x, rect.bottom), dark, 0.25);
      } else {
        final y = rect.top + rect.height * t;
        hairline(Offset(rect.left, y), Offset(rect.right, y), dark, 0.25);
      }
    }
    if (line > 0) ink(rect, width: line);
  }

  void hairline(Offset a, Offset b, Color color, double width) =>
      canvas.drawLine(a, b, _stroke(color, width * u));

  /// Striped wallpaper with small damask dots.
  void wallpaper(Rect rect, Color base, Color stripe, {double every = 0.05}) {
    fill(rect, base);
    final step = size.width * every;
    for (var x = rect.left; x < rect.right; x += step) {
      fill(Rect.fromLTWH(x, rect.top, step * 0.18, rect.height), stripe);
      for (var y = rect.top + step * 0.6; y < rect.bottom; y += step * 1.2) {
        canvas.drawCircle(
          Offset(x + step * 0.6, y),
          step * 0.07,
          _fill(stripe.withValues(alpha: 0.7)),
        );
      }
    }
  }

  /// Floorboards seen at a low angle.
  void floorboards(Rect rect) {
    fill(rect, StillroomPalette.walnut);
    final dark = Color.lerp(StillroomPalette.walnut, outline, 0.5)!;
    for (var i = 1; i < 4; i++) {
      final y = rect.top + rect.height * (i / 4);
      hairline(Offset(rect.left, y), Offset(rect.right, y), dark, 0.3);
    }
    for (var i = 0; i < 12; i++) {
      final x = rect.left + rect.width * ((i * 0.37) % 1);
      final row = i % 4;
      hairline(
        Offset(x, rect.top + rect.height * row / 4),
        Offset(x, rect.top + rect.height * (row + 1) / 4),
        dark,
        0.3,
      );
    }
  }

  /// A damp stain on a wall.
  void stain(Offset center, double radius) {
    for (var i = 0; i < 3; i++) {
      canvas.drawOval(
        Rect.fromCenter(
          center: center.translate(i * radius * 0.2, i * radius * 0.35),
          width: radius * (2 - i * 0.4),
          height: radius * (1.4 - i * 0.3),
        ),
        _fill(outline.withValues(alpha: 0.08)),
      );
    }
  }

  /// A paper sheet with faint writing lines.
  void paper(
    Rect rect, {
    int lines = 5,
    double angle = 0,
    Color color = StillroomPalette.paper,
    double ink = 0.35,
  }) {
    canvas
      ..save()
      ..translate(rect.center.dx, rect.center.dy)
      ..rotate(angle);
    final local = Rect.fromCenter(
      center: Offset.zero,
      width: rect.width,
      height: rect.height,
    );
    box(local, color, line: 0.4);
    final lineColor = StillroomPalette.inkOnPaper.withValues(alpha: ink);
    for (var i = 0; i < lines; i++) {
      final y =
          local.top + local.height * (0.2 + 0.65 * i / math.max(1, lines - 1));
      final end = local.right - local.width * (i.isOdd ? 0.25 : 0.12);
      hairline(
        Offset(local.left + local.width * 0.12, y),
        Offset(end, y),
        lineColor,
        0.3,
      );
    }
    canvas.restore();
  }

  /// A candle flame with a warm glow; [base] is the wick tip.
  void flame(Offset base, double height) {
    glow(
      base.translate(0, -height * 0.4),
      height * 2.2,
      StillroomPalette.gaslight,
      strength: 0.35,
    );
    final w = height * 0.32;
    final outer = Path()
      ..moveTo(base.dx, base.dy)
      ..quadraticBezierTo(
        base.dx - w,
        base.dy - height * 0.35,
        base.dx,
        base.dy - height,
      )
      ..quadraticBezierTo(
        base.dx + w,
        base.dy - height * 0.35,
        base.dx,
        base.dy,
      )
      ..close();
    canvas.drawPath(outer, _fill(StillroomPalette.gaslight));
    final inner = Path()
      ..moveTo(base.dx, base.dy)
      ..quadraticBezierTo(
        base.dx - w * 0.45,
        base.dy - height * 0.25,
        base.dx,
        base.dy - height * 0.55,
      )
      ..quadraticBezierTo(
        base.dx + w * 0.45,
        base.dy - height * 0.25,
        base.dx,
        base.dy,
      )
      ..close();
    canvas.drawPath(inner, _fill(const Color(0xFFF6E3B4)));
  }

  /// A candle in a brass holder; [bottom] is the holder's base centre.
  void candle(Offset bottom, double height, {bool lit = false}) {
    final w = height * 0.2;
    final holder = Rect.fromCenter(
      center: bottom.translate(0, -height * 0.05),
      width: w * 2.2,
      height: height * 0.1,
    );
    final wax = Rect.fromLTWH(
      bottom.dx - w / 2,
      bottom.dy - height * 0.9,
      w,
      height * 0.8,
    );
    box(wax, const Color(0xFFE6DCC4), line: 0.5);
    // Drips.
    fill(
      Rect.fromLTWH(wax.left, wax.top, w * 0.25, height * 0.15),
      const Color(0xFFD4C8AC),
    );
    oval(holder, StillroomPalette.brass, line: 0.5);
    final wickTop = Offset(bottom.dx, wax.top - height * 0.05);
    line(Offset(bottom.dx, wax.top), wickTop, outline, width: 0.5);
    if (lit) flame(wickTop, height * 0.35);
  }

  /// Small caps text in IM FELL, centred at [center].
  void label(String text, Offset center, double fontSize, Color color) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontFamily: 'IMFellSC',
          fontSize: fontSize,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      center - Offset(painter.width / 2, painter.height / 2),
    );
  }
}
