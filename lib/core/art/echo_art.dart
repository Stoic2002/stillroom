import 'dart:ui';

import 'art_kit.dart';
import 'figure_kit.dart';

/// Echoes: figures of memory, the anonymous people who worked and waited in
/// each place. Since 2026-10-08 they have a body and a face, dressed for
/// their time, a little translucent and cool so they read as the past
/// (`figure_kit.dart`). They never get names; the Bastille's prisoner
/// keeps his mask.
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

  /// A sailor of 1590 in a short jacket and wide breeches, a trumpet
  /// raised to the lips.
  trumpeter,

  /// A sailor of 1590 in a short jacket and wide breeches, digging with a
  /// spade.
  shoveller,

  /// A man of 1848 in a long coat and a cap with flaps, leaning into the
  /// drag-rope of a sledge behind him.
  hauler,

  /// A surveyor of 2014 in a hooded float coat, a tablet in hand.
  surveyor,

  /// A pilgrim in a long wrapped cloth, walking with hands joined.
  pilgrim,

  /// A villager of 1890 in a headcloth and a short sarong, a casing stone
  /// carried on one shoulder.
  carrier,
}

// Skin and hair, a few to choose from.
const _fair = Color(0xFFE2BC9C);
const _olive = Color(0xFFC8A07E);
const _brown = Color(0xFF9A6E4E);
const _deep = Color(0xFF7A5238);
const _black = Color(0xFF1E1814);
const _grey = Color(0xFF8A8478);

/// Each echo's look.
Figure echoFigure(EchoFigure figure) => switch (figure) {
  EchoFigure.constable => const Figure(
    top: Color(0xFF1E2434),
    cape: Color(0xFF242A3A),
    hat: Hat.helmet,
    hatColor: Color(0xFF1A2030),
    legs: Color(0xFF1E2434),
    buttons: Color(0xFFB8BCC0),
    right: Pose.out,
    props: [Prop.lantern],
    skin: _fair,
  ),
  EchoFigure.worker => const Figure(
    top: Color(0xFF5A5048),
    hem: 0.5,
    inner: Color(0xFFB8B0A0),
    hat: Hat.flatCap,
    hatColor: Color(0xFF4A4038),
    legs: Color(0xFF3E3A36),
    skin: _brown,
  ),
  EchoFigure.clerk => const Figure(
    top: Color(0xFF3A3A40),
    sleeves: Color(0xFFE6E2D8),
    inner: Color(0xFFE6E2D8),
    hem: 0.5,
    legs: Color(0xFF2E2E32),
    skin: _olive,
    left: Pose.chest,
  ),
  EchoFigure.passerby => const Figure(
    top: Color(0xFF2E2C2E),
    hem: 0.78,
    hat: Hat.bowler,
    hatColor: Color(0xFF1A1818),
    skin: _fair,
  ),
  EchoFigure.keeper => const Figure(
    top: Color(0xFFB08A2E),
    hat: Hat.souwester,
    hatColor: Color(0xFFB8922E),
    legs: Color(0xFF2E2A28),
    right: Pose.out,
    props: [Prop.lantern],
    hair: _grey,
  ),
  EchoFigure.digger => const Figure(
    top: Color(0xFFC8BCA4),
    hem: 0.5,
    legs: Color(0xFF6A5A48),
    hat: Hat.flatCap,
    hatColor: Color(0xFF6A5A48),
    right: Pose.shoulder,
    props: [Prop.basket],
    skin: _olive,
  ),
  EchoFigure.citizen => const Figure(
    top: Color(0xFFE2D8C4),
    hem: 0.7,
    cape: Color(0xFF9A5E4C),
    legs: _olive,
    shoes: Color(0xFF6A4A30),
    skin: _olive,
  ),
  EchoFigure.cushioned => const Figure(
    top: Color(0xFF6E7A5A),
    hem: 0.92,
    longHair: true,
    hat: Hat.cushion,
    hatColor: Color(0xFFC8B48A),
    shoes: Color(0xFF6A4A30),
    right: Pose.shoulder,
    skin: _olive,
  ),
  EchoFigure.child => const Figure(
    top: Color(0xFFD8CCB0),
    hem: 0.72,
    hat: Hat.cushion,
    hatColor: Color(0xFFB89A6A),
    legs: _olive,
    shoes: Color(0xFF6A4A30),
    props: [Prop.charcoal],
    child: true,
    skin: _olive,
  ),
  EchoFigure.girl => const Figure(
    top: Color(0xFFE2D2B4),
    hem: 0.74,
    legs: _olive,
    shoes: null,
    longHair: true,
    child: true,
    skin: _olive,
  ),
  EchoFigure.turnkey => const Figure(
    top: Color(0xFF5A4232),
    hat: Hat.tricorn,
    hatColor: Color(0xFF1E1A18),
    inner: Color(0xFF7A3A2A),
    legs: Color(0xFF4A3A2E),
    stockings: Color(0xFFB8AE9A),
    buttons: Color(0xFFB08A3A),
    right: Pose.out,
    props: [Prop.lantern, Prop.keys],
    hair: _grey,
    skin: _fair,
  ),
  EchoFigure.prisoner => const Figure(
    top: Color(0xFF4A4440),
    hem: 0.8,
    legs: Color(0xFF3A3430),
    stockings: Color(0xFF8A8478),
    mask: true,
    skin: _fair,
  ),
  EchoFigure.founder => const Figure(
    top: Color(0xFFC8B896),
    hem: 0.5,
    belt: Color(0xFF5A4A36),
    legs: Color(0xFFD8CCB0),
    hat: Hat.headband,
    hatColor: Color(0xFFE8E0D0),
    shoes: Color(0xFF6A5A44),
    right: Pose.grip,
    left: Pose.low,
    props: [Prop.ladle],
    skin: _olive,
  ),
  EchoFigure.monk => const Figure(
    top: Color(0xFF7A7670),
    hem: 0.92,
    stole: Color(0xFF8A5A3A),
    hair: _olive,
    left: Pose.chest,
    right: Pose.chest,
    shoes: Color(0xFFD8D0C0),
    skin: _olive,
  ),
  EchoFigure.compositor => const Figure(
    top: Color(0xFF4A4440),
    sleeves: Color(0xFFE6E2D8),
    inner: Color(0xFFE6E2D8),
    apron: Color(0xFF2E2A28),
    hem: 0.5,
    legs: Color(0xFF2E2E32),
    left: Pose.chest,
    props: [Prop.composingStick],
    skin: _fair,
  ),
  EchoFigure.tombKeeper => const Figure(
    top: Color(0xFF2A3448),
    hem: 0.76,
    hat: Hat.flapCap,
    hatColor: Color(0xFF6A5040),
    legs: Color(0xFF2A2E38),
    right: Pose.out,
    props: [Prop.lantern],
    skin: _olive,
  ),
  EchoFigure.scientist => const Figure(
    top: Color(0xFFE8ECEE),
    inner: Color(0xFF4A5A6A),
    hem: 0.74,
    legs: Color(0xFF3A3E46),
    left: Pose.chest,
    right: Pose.chest,
    props: [Prop.clipboard],
    skin: _olive,
  ),
  EchoFigure.garrison => const Figure(
    top: Color(0xFF7A4A34),
    hem: 0.86,
    belt: Color(0xFF3A2A1E),
    hat: Hat.pointedCap,
    hatColor: Color(0xFF5A4A3A),
    legs: Color(0xFF4A3A30),
    right: Pose.shoulder,
    props: [Prop.spear],
    skin: _olive,
  ),
  EchoFigure.librarian => const Figure(
    top: Color(0xFF2A3452),
    hem: 0.92,
    hat: Hat.turban,
    hatColor: Color(0xFFE6E0D0),
    right: Pose.out,
    props: [Prop.oilLamp],
    hair: _black,
    skin: _olive,
  ),
  EchoFigure.builder => const Figure(
    top: Color(0xFFB08A50),
    bareChest: true,
    wrap: Color(0xFFB08A50),
    hem: 0.7,
    legs: _deep,
    shoes: null,
    right: Pose.shoulder,
    props: [Prop.block],
    hair: _black,
    skin: _deep,
  ),
  EchoFigure.hunter => const Figure(
    top: Color(0xFF8A7A56),
    hem: 0.74,
    hat: Hat.wideBrim,
    hatColor: Color(0xFF6A5A40),
    legs: Color(0xFF5A4A36),
    right: Pose.shoulder,
    props: [Prop.rifle],
    hair: Color(0xFF8A6A44),
    skin: _fair,
  ),
  EchoFigure.searcher => const Figure(
    top: Color(0xFF3A4A3A),
    hem: 0.7,
    hat: Hat.furHat,
    hatColor: Color(0xFF5A4636),
    legs: Color(0xFF2E3238),
    right: Pose.grip,
    props: [Prop.probe],
    skin: _fair,
  ),
  EchoFigure.investigator => const Figure(
    top: Color(0xFF4A4440),
    sleeves: Color(0xFFE6E2D8),
    inner: Color(0xFFE6E2D8),
    hem: 0.5,
    legs: Color(0xFF2E2E32),
    right: Pose.high,
    props: [Prop.print],
    skin: _fair,
  ),
  EchoFigure.excavator => const Figure(
    top: Color(0xFF3A5A7A),
    hem: 0.5,
    hat: Hat.hardHat,
    hatColor: Color(0xFFE0B020),
    legs: Color(0xFF3A4048),
    props: [Prop.trowel],
    skin: _olive,
  ),
  EchoFigure.sweeper => const Figure(
    top: Color(0xFF6A665E),
    hem: 0.9,
    hair: _olive,
    shoes: Color(0xFFD8D0C0),
    right: Pose.grip,
    left: Pose.low,
    props: [Prop.broom],
    skin: _olive,
  ),
  EchoFigure.trumpeter => const Figure(
    top: Color(0xFF6A4A30),
    hem: 0.5,
    breeches: true,
    legs: Color(0xFF4A3A2E),
    stockings: Color(0xFFB8AE9A),
    hat: Hat.roundCap,
    hatColor: Color(0xFF8A2E22),
    right: Pose.mouth,
    props: [Prop.trumpet],
    hair: Color(0xFF6A4A2E),
    skin: _fair,
  ),
  EchoFigure.shoveller => const Figure(
    top: Color(0xFF5A5040),
    hem: 0.5,
    breeches: true,
    legs: Color(0xFF4A3A2E),
    stockings: Color(0xFFB8AE9A),
    hat: Hat.roundCap,
    hatColor: Color(0xFF3A4A5A),
    right: Pose.grip,
    left: Pose.low,
    props: [Prop.spade],
    skin: _fair,
  ),
  EchoFigure.hauler => const Figure(
    top: Color(0xFF2E3238),
    hem: 0.76,
    hat: Hat.flapCap,
    hatColor: Color(0xFF3A3028),
    legs: Color(0xFF3A3632),
    left: Pose.chest,
    right: Pose.chest,
    props: [Prop.rope],
    lean: 0.14,
    hair: Color(0xFF6A4A2E),
    skin: _fair,
  ),
  EchoFigure.surveyor => const Figure(
    top: Color(0xFFD86A2A),
    hem: 0.52,
    hat: Hat.hood,
    hatColor: Color(0xFFC85E22),
    legs: Color(0xFF2A2E36),
    left: Pose.chest,
    right: Pose.chest,
    props: [Prop.tablet],
    skin: _fair,
  ),
  EchoFigure.pilgrim => const Figure(
    top: Color(0xFFE8E2D4),
    hem: 0.92,
    left: Pose.chest,
    right: Pose.chest,
    shoes: null,
    hair: _black,
    skin: _brown,
  ),
  EchoFigure.carrier => const Figure(
    top: Color(0xFFD8CCB0),
    hem: 0.5,
    wrap: Color(0xFF6A4A30),
    legs: _brown,
    shoes: null,
    hat: Hat.headcloth,
    hatColor: Color(0xFF5A3A26),
    right: Pose.shoulder,
    props: [Prop.stone],
    hair: _black,
    skin: _brown,
  ),
};

/// Draws [figure] as an echo standing in [a]'s rect.
void paintEcho(Art a, EchoFigure figure) {
  if (figure == EchoFigure.investigator) {
    // The darkroom's red light on him.
    a.glow(
      a.p(0.5, 0.3),
      a.size.width * 0.6,
      const Color(0xFFC0302A),
      strength: 0.3,
    );
  }
  paintFigure(a, echoFigure(figure));
}
