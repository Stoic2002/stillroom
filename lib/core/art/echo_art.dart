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

  /// A digger of 1863, a basket of earth on one shoulder.
  digger,

  /// A townsperson of Pompeii in a knee-length tunic and a draped cloak.
  citizen,

  /// A grown-up fleeing, a cushion tied on the head with cloth.
  cushioned,

  /// A child fleeing, a cushion tied on the head, a stick of charcoal in hand.
  child,

  /// A small child at play, bareheaded.
  girl,

  /// A turnkey of the Bastille in a long coat, a lantern in hand.
  turnkey,

  /// A prisoner in a long coat; a dark band where the mask was.
  prisoner,

  /// A Silla bell founder in a short jacket, a long ladle in hand.
  founder,

  /// A monk in a long robe, a stole across one shoulder.
  monk,

  /// A compositor in shirtsleeves and a long apron, a composing stick in
  /// hand.
  compositor,
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
  if (figure != EchoFigure.child && figure != EchoFigure.girl) {
    a.canvas.drawOval(a.r(0.36, 0.06, 0.28, 0.13), body);
  }

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
    case EchoFigure.digger:
      a.canvas
        // The basket on the shoulder.
        ..drawOval(a.r(0.55, 0.1, 0.4, 0.16), body)
        ..drawPath(
          shape([(0.3, 0.2), (0.7, 0.2), (0.74, 0.58), (0.26, 0.58)]),
          body,
        )
        ..drawPath(
          shape([(0.3, 0.57), (0.47, 0.57), (0.44, 0.98), (0.32, 0.98)]),
          body,
        )
        ..drawPath(
          shape([(0.53, 0.57), (0.7, 0.57), (0.68, 0.98), (0.56, 0.98)]),
          body,
        );
    case EchoFigure.citizen:
      a.canvas
        ..drawPath(
          shape([(0.26, 0.2), (0.74, 0.2), (0.8, 0.7), (0.2, 0.7)]),
          body,
        )
        // The cloak falling from one shoulder.
        ..drawPath(shape([(0.62, 0.2), (0.82, 0.3), (0.76, 0.66)]), body)
        ..drawPath(
          shape([(0.34, 0.68), (0.46, 0.68), (0.45, 0.99), (0.35, 0.99)]),
          body,
        )
        ..drawPath(
          shape([(0.54, 0.68), (0.66, 0.68), (0.65, 0.99), (0.55, 0.99)]),
          body,
        );
    case EchoFigure.cushioned:
      a.canvas
        ..drawRRect(
          RRect.fromRectAndRadius(
            a.r(0.26, -0.01, 0.48, 0.09),
            Radius.circular(w * 0.08),
          ),
          body,
        )
        ..drawPath(
          shape([(0.28, 0.2), (0.72, 0.2), (0.8, 0.8), (0.2, 0.8)]),
          body,
        )
        ..drawPath(
          shape([(0.33, 0.78), (0.46, 0.78), (0.45, 0.99), (0.34, 0.99)]),
          body,
        )
        ..drawPath(
          shape([(0.54, 0.78), (0.67, 0.78), (0.66, 0.99), (0.55, 0.99)]),
          body,
        );
    case EchoFigure.child:
      a.canvas
        ..drawOval(a.r(0.36, 0.3, 0.28, 0.12), body)
        ..drawRRect(
          RRect.fromRectAndRadius(
            a.r(0.28, 0.24, 0.44, 0.08),
            Radius.circular(w * 0.08),
          ),
          body,
        )
        ..drawPath(
          shape([(0.3, 0.44), (0.7, 0.44), (0.76, 0.84), (0.24, 0.84)]),
          body,
        )
        ..drawPath(
          shape([(0.34, 0.82), (0.46, 0.82), (0.45, 0.99), (0.35, 0.99)]),
          body,
        )
        ..drawPath(
          shape([(0.54, 0.82), (0.66, 0.82), (0.65, 0.99), (0.55, 0.99)]),
          body,
        );
    case EchoFigure.turnkey:
      a.canvas
        // A tricorne's brim.
        ..drawPath(
          shape([(0.28, 0.09), (0.72, 0.09), (0.64, 0.03), (0.36, 0.03)]),
          body,
        )
        ..drawPath(
          shape([(0.3, 0.2), (0.7, 0.2), (0.8, 0.84), (0.2, 0.84)]),
          body,
        )
        ..drawPath(
          shape([(0.33, 0.82), (0.46, 0.82), (0.45, 0.99), (0.34, 0.99)]),
          body,
        )
        ..drawPath(
          shape([(0.54, 0.82), (0.67, 0.82), (0.66, 0.99), (0.55, 0.99)]),
          body,
        );
      a.glow(a.p(0.82, 0.58), w * 0.4, const Color(0xFFE0A84A), strength: 0.6);
    case EchoFigure.prisoner:
      a.canvas
        ..drawPath(
          shape([(0.3, 0.2), (0.7, 0.2), (0.76, 0.86), (0.24, 0.86)]),
          body,
        )
        ..drawPath(
          shape([(0.34, 0.84), (0.46, 0.84), (0.45, 0.99), (0.35, 0.99)]),
          body,
        )
        ..drawPath(
          shape([(0.54, 0.84), (0.66, 0.84), (0.65, 0.99), (0.55, 0.99)]),
          body,
        )
        // The mask: a dark band across the blank face, never a face.
        ..drawRRect(
          RRect.fromRectAndRadius(
            a.r(0.36, 0.09, 0.28, 0.08),
            Radius.circular(w * 0.04),
          ),
          Paint()
            ..color = const Color(0xCC141114)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.02),
        );
    case EchoFigure.founder:
      a.canvas
        ..drawPath(
          shape([(0.3, 0.2), (0.7, 0.2), (0.74, 0.52), (0.26, 0.52)]),
          body,
        )
        ..drawPath(
          shape([(0.3, 0.5), (0.47, 0.5), (0.45, 0.98), (0.32, 0.98)]),
          body,
        )
        ..drawPath(
          shape([(0.53, 0.5), (0.7, 0.5), (0.68, 0.98), (0.55, 0.98)]),
          body,
        )
        // The ladle: a long handle held low, its cup near the ground.
        ..drawLine(
          a.p(0.7, 0.36),
          a.p(0.98, 0.9),
          Paint()
            ..color = _mist
            ..strokeWidth = w * 0.05
            ..maskFilter = blur,
        )
        ..drawOval(a.r(0.84, 0.86, 0.18, 0.08), body);
      a.glow(a.p(0.92, 0.92), w * 0.3, const Color(0xFFE08A3A), strength: 0.5);
    case EchoFigure.monk:
      a.canvas
        ..drawPath(
          shape([(0.3, 0.2), (0.7, 0.2), (0.82, 0.96), (0.18, 0.96)]),
          body,
        )
        // The stole, a band from one shoulder across the robe.
        ..drawPath(
          shape([(0.6, 0.2), (0.72, 0.24), (0.36, 0.7), (0.26, 0.64)]),
          Paint()
            ..color = const Color(0xCCB08A70)
            ..maskFilter = blur,
        );
    case EchoFigure.compositor:
      a.canvas
        ..drawPath(
          shape([(0.3, 0.2), (0.7, 0.2), (0.72, 0.56), (0.28, 0.56)]),
          body,
        )
        // The apron, down to the shins.
        ..drawPath(
          shape([(0.32, 0.4), (0.68, 0.4), (0.7, 0.86), (0.3, 0.86)]),
          Paint()
            ..color = const Color(0xCCB8B0A0)
            ..maskFilter = blur,
        )
        ..drawPath(
          shape([(0.33, 0.84), (0.46, 0.84), (0.45, 0.99), (0.34, 0.99)]),
          body,
        )
        ..drawPath(
          shape([(0.54, 0.84), (0.67, 0.84), (0.66, 0.99), (0.55, 0.99)]),
          body,
        )
        // The composing stick, held out in the left hand.
        ..drawRect(a.r(0.04, 0.4, 0.26, 0.05), body);
    case EchoFigure.girl:
      a.canvas
        ..drawOval(a.r(0.36, 0.3, 0.28, 0.12), body)
        ..drawPath(
          shape([(0.3, 0.44), (0.7, 0.44), (0.78, 0.86), (0.22, 0.86)]),
          body,
        )
        ..drawPath(
          shape([(0.34, 0.84), (0.46, 0.84), (0.45, 0.99), (0.35, 0.99)]),
          body,
        )
        ..drawPath(
          shape([(0.54, 0.84), (0.66, 0.84), (0.65, 0.99), (0.55, 0.99)]),
          body,
        );
  }
}
