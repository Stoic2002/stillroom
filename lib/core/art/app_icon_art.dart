import 'dart:math' as math;
import 'dart:ui';

import '../theme/stillroom_palette.dart';

/// The app icon (launcher icon): a stoppered glass jar on the Stillroom's
/// dark wall, a small flame of a tale burning inside it. Drawn in code and
/// rendered to PNGs by `tool/icon/render_icon_test.dart`.
///
/// [layer] picks what to draw: the whole icon, or one layer of the Android
/// adaptive icon (background, foreground, or a flat monochrome silhouette).
enum AppIconLayer { full, background, foreground, monochrome }

void paintAppIcon(
  Canvas canvas,
  Size size, {
  AppIconLayer layer = AppIconLayer.full,
}) {
  final s = size.shortestSide;
  if (layer == AppIconLayer.full || layer == AppIconLayer.background) {
    _background(canvas, size);
  }
  if (layer == AppIconLayer.background) return;
  // The adaptive icon's foreground must keep to the inner 66%; the full
  // icon can fill more.
  final scale = layer == AppIconLayer.full ? 0.8 : 0.62;
  canvas
    ..save()
    ..translate(size.width / 2, size.height / 2)
    ..scale(s * scale / 100);
  _jar(canvas, monochrome: layer == AppIconLayer.monochrome);
  canvas.restore();
}

void _background(Canvas canvas, Size size) {
  final rect = Offset.zero & size;
  canvas
    ..drawRect(rect, Paint()..color = StillroomPalette.ink)
    ..drawRect(
      rect,
      Paint()
        ..shader = Gradient.radial(
          rect.center.translate(0, size.height * 0.05),
          size.shortestSide * 0.62,
          [
            const Color(0xFF3A2A1C),
            const Color(0xFF1A130E),
            StillroomPalette.ink,
          ],
          [0, 0.55, 1],
        ),
    );
}

/// The jar, in a 100 × 100 box centred on the origin.
void _jar(Canvas canvas, {required bool monochrome}) {
  const white = Color(0xFFFFFFFF);
  final body = RRect.fromLTRBAndCorners(
    -30,
    -26,
    30,
    44,
    topLeft: const Radius.circular(16),
    topRight: const Radius.circular(16),
    bottomLeft: const Radius.circular(9),
    bottomRight: const Radius.circular(9),
  );
  final neck = RRect.fromLTRBR(-17, -36, 17, -24, const Radius.circular(3));
  final cork = RRect.fromLTRBR(-14, -48, 14, -34, const Radius.circular(3));

  if (monochrome) {
    final paint = Paint()..color = white;
    canvas
      ..drawRRect(body, paint)
      ..drawRRect(neck, paint)
      ..drawRRect(cork, paint);
    return;
  }

  // The glow of the tale inside, spilling out through the glass.
  canvas.drawCircle(
    const Offset(0, 14),
    46,
    Paint()
      ..shader = Gradient.radial(const Offset(0, 14), 46, [
        StillroomPalette.gaslight.withValues(alpha: 0.45),
        StillroomPalette.gaslight.withValues(alpha: 0),
      ]),
  );

  // Inside: murky amber smoke and a single flame.
  canvas
    ..save()
    ..clipRRect(body)
    ..drawRect(
      body.outerRect,
      Paint()
        ..shader = Gradient.linear(const Offset(0, -26), const Offset(0, 44), [
          const Color(0xFF2A1F17),
          const Color(0xFF5A3A1E),
        ]),
    );
  for (var i = 0; i < 5; i++) {
    final a = i * math.pi * 0.4;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(math.cos(a) * 9, 22 + math.sin(a) * 6),
        width: 36,
        height: 14,
      ),
      Paint()
        ..color = StillroomPalette.gaslight.withValues(alpha: 0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
  }
  canvas
    ..drawCircle(
      const Offset(0, 12),
      20,
      Paint()
        ..shader = Gradient.radial(const Offset(0, 12), 20, [
          const Color(0xFFFFE3A0),
          StillroomPalette.gaslight.withValues(alpha: 0),
        ]),
    )
    ..drawPath(
      Path()
        ..moveTo(0, 24)
        ..quadraticBezierTo(-7, 13, 0, -2)
        ..quadraticBezierTo(7, 13, 0, 24)
        ..close(),
      Paint()..color = const Color(0xFFFFD27A),
    )
    ..drawPath(
      Path()
        ..moveTo(0, 23)
        ..quadraticBezierTo(-3, 16, 0, 9)
        ..quadraticBezierTo(3, 16, 0, 23)
        ..close(),
      Paint()..color = const Color(0xFFFFF6DC),
    )
    ..restore();

  // Glass, highlight, paper label.
  canvas
    ..drawRRect(body, Paint()..color = const Color(0x18D8C9A8))
    ..drawRRect(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..color = const Color(0xFFD8C9A8),
    )
    ..drawLine(
      const Offset(-21, -14),
      const Offset(-21, 30),
      Paint()
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round
        ..color = const Color(0x66FFFFFF),
    )
    ..drawRect(
      const Rect.fromLTRB(-19, 28, 19, 38),
      Paint()..color = StillroomPalette.paper,
    )
    ..drawLine(
      const Offset(-12, 33),
      const Offset(12, 33),
      Paint()
        ..strokeWidth = 1.2
        ..color = StillroomPalette.inkOnPaper,
    )
    // Neck and cork, with a brass band.
    ..drawRRect(neck, Paint()..color = const Color(0x30D8C9A8))
    ..drawRRect(
      neck,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..color = const Color(0xFFD8C9A8),
    )
    ..drawRRect(cork, Paint()..color = const Color(0xFF8A6440))
    ..drawRect(
      const Rect.fromLTRB(-18, -27, 18, -23),
      Paint()..color = StillroomPalette.brass,
    );
}
