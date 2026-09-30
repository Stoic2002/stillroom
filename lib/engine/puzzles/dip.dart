import '../json/json_reader.dart';
import '../model/content_ref.dart';
import 'puzzle_type.dart';

/// `dip`: tanks cut into the rock, too dark to see into. A reed is lowered
/// into each until it meets the surface (how full the tank is), and drawn
/// out to see how it drips (what is in it). Name every tank, then say
/// whether the stores were running low or full.
///
/// ```json
/// "config": {
///   "tanks": [
///     { "liquid": "honey", "level": 0.82 },
///     { "liquid": "vinegar", "level": 0.9 }
///   ],
///   "names": [
///     { "liquid": "honey", "labelKey": "ep.dip.honey" },
///     { "liquid": "vinegar", "labelKey": "ep.dip.vinegar" },
///     { "liquid": "milk", "labelKey": "ep.dip.milk" }
///   ]
/// }
/// ```
/// Each tank holds one [DipLiquid] (each at most once) at a `level` from
/// 0.1 to 0.95 of its depth. `names` are the names offered, each liquid
/// once; every tank's liquid must be among them, and at least one more
/// to mislead. A tank can be named only once it has been dipped; a wrong
/// name is a mistake. The stores were full when every tank stands at
/// least [DipType.full] deep.
final class DipType implements PuzzleType {
  const DipType();

  static const typeId = 'dip';

  /// The level every tank must reach for the stores to count as full.
  static const full = 0.6;

  @override
  String get id => typeId;

  static DipLiquid _liquid(JsonReader json) =>
      DipLiquid.values.asNameMap()[json.string('liquid')] ??
      json.fail(
        'expected one of ${DipLiquid.values.map((l) => l.name).join(', ')}',
        'liquid',
      );

  @override
  DipConfig parseConfig(JsonReader json) {
    json.allowOnly({'tanks', 'names'});
    final tanks = [
      for (final t in json.objects('tanks'))
        () {
          t.allowOnly({'liquid', 'level'});
          final level = t.number('level');
          if (level < 0.1 || level > 0.95) t.fail('from 0.1 to 0.95', 'level');
          return DipTank(liquid: _liquid(t), level: level);
        }(),
    ];
    if (tanks.length < 2 || tanks.length > 5) {
      json.fail('need 2 to 5 tanks', 'tanks');
    }
    if (tanks.map((t) => t.liquid).toSet().length != tanks.length) {
      json.fail('each liquid in one tank only', 'tanks');
    }
    final names = [
      for (final n in json.objects('names'))
        () {
          n.allowOnly({'liquid', 'labelKey'});
          return DipName(liquid: _liquid(n), labelKey: n.string('labelKey'));
        }(),
    ];
    final offered = names.map((n) => n.liquid).toSet();
    if (offered.length != names.length) {
      json.fail('each liquid named once', 'names');
    }
    if (!tanks.every((t) => offered.contains(t.liquid))) {
      json.fail("every tank's liquid must be named", 'names');
    }
    if (names.length <= tanks.length) {
      json.fail('need at least one name to mislead', 'names');
    }
    return DipConfig(tanks: tanks, names: names);
  }
}

/// What a tank can hold; each drips its own way.
enum DipLiquid { water, wine, vinegar, honey, milk, oil }

final class DipTank {
  const DipTank({required this.liquid, required this.level});

  final DipLiquid liquid;

  /// How full the tank is, from 0 (empty) to 1 (brim).
  final double level;
}

final class DipName {
  const DipName({required this.liquid, required this.labelKey});

  final DipLiquid liquid;
  final String labelKey;
}

final class DipConfig implements PuzzleConfig {
  DipConfig({required List<DipTank> tanks, required List<DipName> names})
    : tanks = List.unmodifiable(tanks),
      names = List.unmodifiable(names);

  final List<DipTank> tanks;
  final List<DipName> names;

  /// Whether the stores were full: every tank at least [DipType.full].
  bool get storesFull => tanks.every((t) => t.level >= DipType.full);

  DipState start() => DipState(this, const {}, const {}, 0, answered: false);

  @override
  Iterable<ContentRef> get references => [
    for (final n in names) ContentRef.text(n.labelKey),
  ];
}

final class DipState {
  DipState(
    this.config,
    Set<int> dipped,
    Map<int, DipLiquid> named,
    this.mistakes, {
    required this.answered,
  }) : dipped = Set.unmodifiable(dipped),
       named = Map.unmodifiable(named);

  final DipConfig config;

  /// Tanks the reed has been in.
  final Set<int> dipped;

  /// Tanks named rightly.
  final Map<int, DipLiquid> named;
  final int mistakes;

  /// Whether the stores have been judged rightly.
  final bool answered;

  bool get allNamed => named.length == config.tanks.length;

  bool get isSolved => answered;

  DipState _with({
    Set<int>? dipped,
    Map<int, DipLiquid>? named,
    int? mistakes,
    bool? answered,
  }) => DipState(
    config,
    dipped ?? this.dipped,
    named ?? this.named,
    mistakes ?? this.mistakes,
    answered: answered ?? this.answered,
  );

  /// The reed has been lowered into tank [t] and drawn out.
  DipState dip(int t) =>
      answered || dipped.contains(t) ? this : _with(dipped: {...dipped, t});

  /// Names tank [t] as holding [liquid].
  DipState name(int t, DipLiquid liquid) {
    if (answered || !dipped.contains(t) || named.containsKey(t)) return this;
    return config.tanks[t].liquid == liquid
        ? _with(named: {...named, t: liquid})
        : _with(mistakes: mistakes + 1);
  }

  /// Says whether the stores were [full].
  DipState judge({required bool full}) {
    if (answered || !allNamed) return this;
    return full == config.storesFull
        ? _with(answered: true)
        : _with(mistakes: mistakes + 1);
  }
}
