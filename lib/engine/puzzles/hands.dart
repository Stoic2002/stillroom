import '../json/json_reader.dart';
import '../model/content_ref.dart';
import 'puzzle_type.dart';

/// `hands`: a household receipt book written over the years by several
/// hands. Each hand has its tells: how it makes its g ([HandTells.g]), its
/// long s ([HandTells.s]), its ampersand ([HandTells.amp]), and its slant.
/// Exemplars of every hand head the page; sort each receipt to the hand
/// that wrote it.
///
/// ```json
/// "config": {
///   "hands": [
///     { "labelKey": "ep.hand.mistress", "g": 0, "s": 1, "amp": 0, "slant": 1 }
///   ],
///   "receipts": [
///     { "labelKey": "ep.receipt.rosewater", "hand": 0, "lacks": ["amp"] }
///   ]
/// }
/// ```
/// 2 to 5 hands, no two with the same tells; 4 to 12 receipts, every hand
/// writing at least one. `g`, `s` and `amp` are 0 to 2, `slant` -1 to 1.
/// A receipt may lack a letter (`lacks`: some of `g`, `s`, `amp`): it has
/// no "and" in it, say. What it shows, with its slant, must still fit only
/// the hand that wrote it.
final class HandsType implements PuzzleType {
  const HandsType();

  static const typeId = 'hands';

  @override
  String get id => typeId;

  @override
  HandsConfig parseConfig(JsonReader json) {
    json.allowOnly({'hands', 'receipts'});
    int tell(JsonReader j, String key, int lo, int hi) {
      final v = j.integer(key);
      if (v < lo || v > hi) j.fail('$lo to $hi', key);
      return v;
    }

    final hands = [
      for (final h in json.objects('hands'))
        () {
          h.allowOnly({'labelKey', 'g', 's', 'amp', 'slant'});
          return HandTells(
            labelKey: h.string('labelKey'),
            g: tell(h, 'g', 0, 2),
            s: tell(h, 's', 0, 2),
            amp: tell(h, 'amp', 0, 2),
            slant: tell(h, 'slant', -1, 1),
          );
        }(),
    ];
    if (hands.length < 2 || hands.length > 5) {
      json.fail('need 2 to 5 hands', 'hands');
    }
    final seen = <(int, int, int, int)>{};
    for (final h in hands) {
      if (!seen.add((h.g, h.s, h.amp, h.slant))) {
        json.fail('two hands with the same tells', 'hands');
      }
    }
    final receipts = [
      for (final r in json.objects('receipts'))
        () {
          r.allowOnly({'labelKey', 'hand', 'lacks'});
          final hand = r.integer('hand');
          if (hand < 0 || hand >= hands.length) r.fail('no such hand', 'hand');
          final lacks = <Tell>{
            for (final name in r.strings('lacks', optional: true))
              Tell.values.asNameMap()[name] ??
                  r.fail('one of g, s, amp', 'lacks'),
          };
          if (lacks.length == Tell.values.length) {
            r.fail('a receipt shows at least one letter', 'lacks');
          }
          final receipt = HandReceipt(
            labelKey: r.string('labelKey'),
            hand: hand,
            lacks: lacks,
          );
          final fitting = [
            for (final (i, h) in hands.indexed)
              if (receipt.fits(h, hands[hand])) i,
          ];
          if (fitting.length != 1) {
            r.fail('what it shows fits more than one hand', 'lacks');
          }
          return receipt;
        }(),
    ];
    if (receipts.length < 4 || receipts.length > 12) {
      json.fail('need 4 to 12 receipts', 'receipts');
    }
    for (var i = 0; i < hands.length; i++) {
      if (!receipts.any((r) => r.hand == i)) {
        json.fail('hand $i writes no receipt', 'receipts');
      }
    }
    return HandsConfig(hands: hands, receipts: receipts);
  }
}

/// One hand: who it is, and how it writes.
final class HandTells {
  const HandTells({
    required this.labelKey,
    required this.g,
    required this.s,
    required this.amp,
    required this.slant,
  });

  final String labelKey;

  /// The g's tail: 0 open, 1 looped, 2 straight down.
  final int g;

  /// The s: 0 a long s with a hook, 1 a round s, 2 a long s crossed.
  final int s;

  /// The and: 0 an ampersand, 1 a joined "et", 2 a plain cross.
  final int amp;

  /// The slant: -1 back, 0 upright, 1 forward.
  final int slant;
}

/// The letters a receipt can show.
enum Tell { g, s, amp }

final class HandReceipt {
  const HandReceipt({
    required this.labelKey,
    required this.hand,
    this.lacks = const {},
  });

  final String labelKey;

  /// The index of the hand that wrote it.
  final int hand;

  /// The letters the receipt has none of.
  final Set<Tell> lacks;

  /// Whether [other] could have written it, judged by what it shows of
  /// [writer]'s hand.
  bool fits(HandTells other, HandTells writer) =>
      other.slant == writer.slant &&
      (lacks.contains(Tell.g) || other.g == writer.g) &&
      (lacks.contains(Tell.s) || other.s == writer.s) &&
      (lacks.contains(Tell.amp) || other.amp == writer.amp);
}

final class HandsConfig implements PuzzleConfig {
  HandsConfig({
    required List<HandTells> hands,
    required List<HandReceipt> receipts,
  }) : hands = List.unmodifiable(hands),
       receipts = List.unmodifiable(receipts);

  final List<HandTells> hands;
  final List<HandReceipt> receipts;

  HandsState start() => HandsState(this, const {}, 0);

  @override
  Iterable<ContentRef> get references => [
    for (final h in hands) ContentRef.text(h.labelKey),
    for (final r in receipts) ContentRef.text(r.labelKey),
  ];
}

final class HandsState {
  HandsState(this.config, Map<int, int> assigned, this.mistakes)
    : assigned = Map.unmodifiable(assigned);

  final HandsConfig config;

  /// Receipt index → the hand the player put it to.
  final Map<int, int> assigned;
  final int mistakes;

  bool get complete => assigned.length == config.receipts.length;

  /// Receipts put to the wrong hand.
  Set<int> get wrong => {
    for (final MapEntry(:key, :value) in assigned.entries)
      if (config.receipts[key].hand != value) key,
  };

  bool get isSolved => complete && wrong.isEmpty;

  /// Puts receipt [receipt] to hand [hand].
  HandsState assign(int receipt, int hand) =>
      HandsState(config, {...assigned, receipt: hand}, mistakes);

  /// Takes receipt [receipt] back off its hand.
  HandsState unassign(int receipt) =>
      HandsState(config, {...assigned}..remove(receipt), mistakes);

  /// Checks the sorting: the receipts put to the wrong hand come back.
  HandsState check() {
    final w = wrong;
    if (w.isEmpty) return this;
    return HandsState(config, {
      for (final MapEntry(:key, :value) in assigned.entries)
        if (!w.contains(key)) key: value,
    }, mistakes + 1);
  }
}
