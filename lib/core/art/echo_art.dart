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

  /// A tomb keeper in a padded winter coat and a hat with flaps, a lantern
  /// in hand.
  tombKeeper,

  /// A scientist in a knee-length lab coat, a clipboard held to the chest.
  scientist,

  /// A castle guard in a long quilted coat and a pointed cap, a spear
  /// over the shoulder, going down.
  garrison,

  /// A librarian in a long robe and a wound turban, a small oil lamp held
  /// out in one hand.
  librarian,

  /// A builder in a cloth wrapped at the waist, a granite block carried on
  /// one shoulder.
  builder,

  /// A hunter in a wide-brimmed hat and a long coat, a rifle over the
  /// shoulder.
  hunter,

  /// A searcher in a padded coat and a fur hat, a long avalanche probe
  /// held upright.
  searcher,

  /// An investigator in shirtsleeves under a red lamp, a print held up to
  /// the light.
  investigator,

  /// An excavator in a hard hat and work clothes, a trowel in hand.
  excavator,

  /// A temple monk in a work robe, sweeping with a bamboo broom.
  sweeper,
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
    case EchoFigure.tombKeeper:
      a.canvas
        // The hat, its flaps down over the ears.
        ..drawPath(
          shape([(0.32, 0.12), (0.34, 0.03), (0.66, 0.03), (0.68, 0.12)]),
          body,
        )
        // The padded coat, wide and to the knees.
        ..drawPath(
          shape([(0.26, 0.2), (0.74, 0.2), (0.86, 0.82), (0.14, 0.82)]),
          body,
        )
        ..drawPath(
          shape([(0.32, 0.8), (0.46, 0.8), (0.45, 0.99), (0.33, 0.99)]),
          body,
        )
        ..drawPath(
          shape([(0.54, 0.8), (0.68, 0.8), (0.67, 0.99), (0.55, 0.99)]),
          body,
        );
      a.glow(a.p(0.86, 0.62), w * 0.4, const Color(0xFFE0A84A), strength: 0.6);
    case EchoFigure.garrison:
      a.canvas
        // The pointed cap.
        ..drawPath(shape([(0.36, 0.1), (0.5, -0.02), (0.64, 0.1)]), body)
        // The quilted coat, long, flaring a little.
        ..drawPath(
          shape([(0.3, 0.2), (0.7, 0.2), (0.82, 0.8), (0.18, 0.8)]),
          body,
        )
        ..drawPath(
          shape([(0.32, 0.78), (0.46, 0.78), (0.44, 0.99), (0.34, 0.99)]),
          body,
        )
        ..drawPath(
          shape([(0.54, 0.78), (0.68, 0.78), (0.66, 0.99), (0.56, 0.99)]),
          body,
        )
        // The spear over the shoulder.
        ..drawLine(
          a.p(0.78, 0.02),
          a.p(0.3, 0.7),
          Paint()
            ..color = _mist
            ..strokeWidth = w * 0.05
            ..maskFilter = blur,
        );
    case EchoFigure.librarian:
      a.canvas
        // The turban, wound wide.
        ..drawOval(a.r(0.3, 0.02, 0.4, 0.12), body)
        // The long robe, to the ground.
        ..drawPath(
          shape([(0.3, 0.2), (0.7, 0.2), (0.8, 0.99), (0.2, 0.99)]),
          body,
        )
        // The arm held out with the lamp.
        ..drawPath(
          shape([(0.66, 0.3), (0.88, 0.46), (0.84, 0.5), (0.64, 0.38)]),
          body,
        );
      a.glow(a.p(0.9, 0.5), w * 0.35, const Color(0xFFE0A84A), strength: 0.7);
    case EchoFigure.builder:
      a.canvas
        // The block on the shoulder, steadied by a raised arm.
        ..drawRect(a.r(0.5, 0.0, 0.42, 0.12), body)
        ..drawPath(
          shape([(0.62, 0.12), (0.7, 0.1), (0.66, 0.24), (0.6, 0.24)]),
          body,
        )
        // Bare shoulders and chest, then the wrapped cloth to the knee.
        ..drawPath(
          shape([(0.32, 0.2), (0.68, 0.2), (0.64, 0.5), (0.36, 0.5)]),
          body,
        )
        ..drawPath(
          shape([(0.33, 0.48), (0.67, 0.48), (0.7, 0.72), (0.3, 0.72)]),
          body,
        )
        ..drawPath(
          shape([(0.36, 0.7), (0.47, 0.7), (0.45, 0.99), (0.37, 0.99)]),
          body,
        )
        ..drawPath(
          shape([(0.53, 0.7), (0.64, 0.7), (0.63, 0.99), (0.55, 0.99)]),
          body,
        );
    case EchoFigure.hunter:
      a.canvas
        // The wide brim of the hat.
        ..drawPath(
          shape([(0.22, 0.1), (0.78, 0.1), (0.66, 0.05), (0.34, 0.05)]),
          body,
        )
        ..drawPath(
          shape([(0.3, 0.2), (0.7, 0.2), (0.78, 0.78), (0.22, 0.78)]),
          body,
        )
        ..drawPath(
          shape([(0.33, 0.76), (0.46, 0.76), (0.45, 0.99), (0.34, 0.99)]),
          body,
        )
        ..drawPath(
          shape([(0.54, 0.76), (0.67, 0.76), (0.66, 0.99), (0.55, 0.99)]),
          body,
        )
        // The rifle, barrel up over the shoulder.
        ..drawLine(
          a.p(0.72, 0.0),
          a.p(0.5, 0.6),
          Paint()
            ..color = _mist
            ..strokeWidth = w * 0.06
            ..maskFilter = blur,
        );
    case EchoFigure.searcher:
      a.canvas
        // The fur hat.
        ..drawOval(a.r(0.32, 0.02, 0.36, 0.1), body)
        ..drawPath(
          shape([(0.26, 0.2), (0.74, 0.2), (0.8, 0.7), (0.2, 0.7)]),
          body,
        )
        ..drawPath(
          shape([(0.32, 0.68), (0.47, 0.68), (0.46, 0.99), (0.33, 0.99)]),
          body,
        )
        ..drawPath(
          shape([(0.53, 0.68), (0.68, 0.68), (0.67, 0.99), (0.54, 0.99)]),
          body,
        )
        // The long probe, upright beside him.
        ..drawLine(
          a.p(0.88, 0.0),
          a.p(0.86, 0.99),
          Paint()
            ..color = _mist
            ..strokeWidth = w * 0.05
            ..maskFilter = blur,
        );
    case EchoFigure.excavator:
      a.canvas
        // The hard hat, its brim.
        ..drawPath(
          shape([
            (0.32, 0.1),
            (0.36, 0.03),
            (0.5, 0.0),
            (0.64, 0.03),
            (0.68, 0.1),
            (0.74, 0.12),
            (0.26, 0.12),
          ]),
          body,
        )
        ..drawPath(
          shape([(0.28, 0.2), (0.72, 0.2), (0.76, 0.58), (0.24, 0.58)]),
          body,
        )
        ..drawPath(
          shape([(0.3, 0.56), (0.48, 0.56), (0.46, 0.99), (0.32, 0.99)]),
          body,
        )
        ..drawPath(
          shape([(0.52, 0.56), (0.7, 0.56), (0.68, 0.99), (0.54, 0.99)]),
          body,
        )
        // The arm down, a trowel's blade in the hand.
        ..drawPath(
          shape([(0.7, 0.24), (0.8, 0.5), (0.74, 0.52), (0.66, 0.3)]),
          body,
        )
        ..drawPath(shape([(0.74, 0.52), (0.86, 0.6), (0.76, 0.64)]), body);
    case EchoFigure.sweeper:
      final stroke = Paint()
        ..color = _mist
        ..strokeWidth = w * 0.05
        ..maskFilter = blur;
      a.canvas
        // The robe to the ankles, sleeves wide.
        ..drawPath(
          shape([
            (0.3, 0.2),
            (0.7, 0.2),
            (0.82, 0.46),
            (0.74, 0.5),
            (0.76, 0.95),
            (0.24, 0.95),
            (0.28, 0.5),
            (0.18, 0.46),
          ]),
          body,
        )
        // The broom: a long handle slanting down, a fan of twigs.
        ..drawLine(a.p(0.66, 0.3), a.p(0.1, 0.9), stroke)
        ..drawPath(shape([(0.16, 0.84), (0.0, 0.99), (0.24, 0.99)]), body);
    case EchoFigure.investigator:
      a.canvas
        ..drawPath(
          shape([(0.3, 0.2), (0.7, 0.2), (0.72, 0.62), (0.28, 0.62)]),
          body,
        )
        ..drawPath(
          shape([(0.3, 0.6), (0.7, 0.6), (0.68, 0.99), (0.32, 0.99)]),
          body,
        )
        // The arm raised, a print held up.
        ..drawPath(
          shape([(0.64, 0.24), (0.84, 0.08), (0.88, 0.12), (0.7, 0.3)]),
          body,
        )
        ..drawRect(a.r(0.78, -0.02, 0.2, 0.12), body);
      a.glow(a.p(0.5, 0.3), w * 0.6, const Color(0xFFC0302A), strength: 0.3);
    case EchoFigure.scientist:
      a.canvas
        // The lab coat, open, to the knees.
        ..drawPath(
          shape([(0.28, 0.2), (0.72, 0.2), (0.8, 0.76), (0.2, 0.76)]),
          Paint()
            ..color = const Color(0xFFF0F2F2)
            ..maskFilter = blur,
        )
        ..drawPath(
          shape([(0.33, 0.74), (0.46, 0.74), (0.45, 0.99), (0.34, 0.99)]),
          body,
        )
        ..drawPath(
          shape([(0.54, 0.74), (0.67, 0.74), (0.66, 0.99), (0.55, 0.99)]),
          body,
        )
        // The clipboard, held to the chest.
        ..drawRect(
          a.r(0.36, 0.3, 0.26, 0.2),
          Paint()
            ..color = const Color(0xCC8A7A60)
            ..maskFilter = blur,
        );
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
