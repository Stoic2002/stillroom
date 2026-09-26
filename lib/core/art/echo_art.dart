import 'dart:ui';

import 'art_kit.dart';

/// Echoes: faceless figures of memory, drawn pale like breath on glass.
/// They never get faces or names (docs/stillroom_frame.md, tone guardrails).
enum EchoFigure {
  /// A beat constable in a helmet and cape, a lantern at his side.
  constable,

  /// A railway worker in a flat cap and jacket.
  worker,

  /// A clerk in shirtsleeves and waistcoat, bareheaded.
  clerk,

  /// A passer-by in a bowler hat and overcoat.
  passerby,

  /// A lighthouse keeper in a sou'wester and a long oilskin.
  keeper,
}

const _mist = Color(0xFFD5DEE2);

void paintEcho(Art a, EchoFigure figure) {
  final blur = MaskFilter.blur(BlurStyle.normal, a.size.width * 0.04);
  final body = Paint()
    ..color = _mist
    ..maskFilter = blur;
  final w = a.size.width;
  final h = a.size.height;
  Path shape(List<(double, double)> points) =>
      Path()
        ..addPolygon([for (final (x, y) in points) Offset(x * w, y * h)], true);

  // Head: a plain oval, no features.
  a.canvas.drawOval(a.r(0.36, 0.06, 0.28, 0.13), body);

  switch (figure) {
    case EchoFigure.constable:
      a.canvas
        ..drawPath(shape([(0.38, 0.08), (0.5, -0.02), (0.62, 0.08)]), body)
        ..drawPath(
          shape([(0.3, 0.2), (0.7, 0.2), (0.88, 0.62), (0.12, 0.62)]),
          body,
        )
        ..drawPath(
          shape([(0.34, 0.6), (0.48, 0.6), (0.46, 0.98), (0.36, 0.98)]),
          body,
        )
        ..drawPath(
          shape([(0.52, 0.6), (0.66, 0.6), (0.64, 0.98), (0.54, 0.98)]),
          body,
        );
      a.glow(a.p(0.84, 0.6), w * 0.4, const Color(0xFFE0A84A), strength: 0.6);
    case EchoFigure.worker:
      a.canvas
        ..drawPath(
          shape([(0.32, 0.08), (0.7, 0.06), (0.74, 0.1), (0.3, 0.12)]),
          body,
        )
        ..drawPath(
          shape([(0.28, 0.2), (0.72, 0.2), (0.78, 0.56), (0.22, 0.56)]),
          body,
        )
        ..drawPath(
          shape([(0.3, 0.55), (0.48, 0.55), (0.46, 0.98), (0.32, 0.98)]),
          body,
        )
        ..drawPath(
          shape([(0.52, 0.55), (0.7, 0.55), (0.68, 0.98), (0.54, 0.98)]),
          body,
        );
    case EchoFigure.passerby:
      a.canvas
        ..drawPath(
          shape([(0.3, 0.07), (0.7, 0.07), (0.66, -0.01), (0.34, -0.01)]),
          body,
        )
        ..drawPath(
          shape([(0.28, 0.2), (0.72, 0.2), (0.8, 0.8), (0.2, 0.8)]),
          body,
        )
        ..drawPath(
          shape([(0.32, 0.78), (0.46, 0.78), (0.45, 0.99), (0.33, 0.99)]),
          body,
        )
        ..drawPath(
          shape([(0.54, 0.78), (0.68, 0.78), (0.67, 0.99), (0.55, 0.99)]),
          body,
        );
    case EchoFigure.clerk:
      a.canvas
        ..drawPath(
          shape([(0.3, 0.2), (0.7, 0.2), (0.74, 0.55), (0.26, 0.55)]),
          body,
        )
        ..drawPath(
          shape([(0.32, 0.54), (0.68, 0.54), (0.66, 0.98), (0.34, 0.98)]),
          body,
        );
    case EchoFigure.keeper:
      a.canvas
        ..drawPath(
          shape([
            (0.3, 0.1),
            (0.5, 0.02),
            (0.7, 0.1),
            (0.78, 0.2),
            (0.22, 0.2),
          ]),
          body,
        )
        ..drawPath(
          shape([(0.28, 0.2), (0.72, 0.2), (0.82, 0.88), (0.18, 0.88)]),
          body,
        )
        ..drawPath(
          shape([(0.3, 0.86), (0.46, 0.86), (0.46, 0.99), (0.3, 0.99)]),
          body,
        )
        ..drawPath(
          shape([(0.54, 0.86), (0.7, 0.86), (0.7, 0.99), (0.54, 0.99)]),
          body,
        );
  }
}
