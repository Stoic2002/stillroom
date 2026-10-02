import '../json/json_reader.dart';
import '../model/content_ref.dart';
import 'puzzle_type.dart';

/// `strata`: a section through layers of earth, from the top down, each
/// with what was found in it. A find gives the earliest year it could have
/// been dropped. A layer is no older than its youngest find, and no older
/// than the layer beneath it (it was laid on top). Date every layer by the
/// earliest year it can be; then mark the layer of the fire being looked
/// for: one that burned, and that can be as old as that fire.
///
/// ```json
/// "config": {
///   "layers": [
///     { "labelKey": "ep.strata.topsoil",
///       "finds": [ { "labelKey": "ep.find.yen", "year": 1951 } ] },
///     { "labelKey": "ep.strata.ash", "burnt": true,
///       "finds": [ { "labelKey": "ep.find.eiraku", "year": 1408 } ] }
///   ],
///   "fireYear": 1582,
///   "fire": 1
/// }
/// ```
/// 3 to 8 layers, each with 1 to 4 finds (years 1 to 2100). The `fire`
/// layer is burnt and can be as old as `fireYear`; no other burnt layer
/// can.
final class StrataType implements PuzzleType {
  const StrataType();

  static const typeId = 'strata';

  @override
  String get id => typeId;

  @override
  StrataConfig parseConfig(JsonReader json) {
    json.allowOnly({'layers', 'fireYear', 'fire'});
    final layers = [
      for (final l in json.objects('layers'))
        () {
          l.allowOnly({'labelKey', 'burnt', 'finds'});
          final finds = [
            for (final f in l.objects('finds'))
              () {
                f.allowOnly({'labelKey', 'year'});
                final year = f.integer('year');
                if (year < 1 || year > 2100) f.fail('from 1 to 2100', 'year');
                return StrataFind(labelKey: f.string('labelKey'), year: year);
              }(),
          ];
          if (finds.isEmpty || finds.length > 4) {
            l.fail('need 1 to 4 finds', 'finds');
          }
          return StrataLayer(
            labelKey: l.string('labelKey'),
            burnt: l.optionalBool('burnt') ?? false,
            finds: finds,
          );
        }(),
    ];
    if (layers.length < 3 || layers.length > 8) {
      json.fail('need 3 to 8 layers', 'layers');
    }
    final fireYear = json.integer('fireYear');
    final fire = json.integer('fire');
    if (fire < 0 || fire >= layers.length) json.fail('not a layer', 'fire');
    final config = StrataConfig(layers: layers, fireYear: fireYear, fire: fire);
    if (!layers[fire].burnt || config.earliest(fire) > fireYear) {
      json.fail('must be burnt and can be as old as $fireYear', 'fire');
    }
    for (var i = 0; i < layers.length; i++) {
      if (i != fire && layers[i].burnt && config.earliest(i) <= fireYear) {
        json.fail('another burnt layer could be the fire', 'layers[$i]');
      }
    }
    return config;
  }
}

final class StrataFind {
  const StrataFind({required this.labelKey, required this.year});

  final String labelKey;

  /// The earliest year it could have been dropped.
  final int year;
}

final class StrataLayer {
  StrataLayer({
    required this.labelKey,
    required this.burnt,
    required List<StrataFind> finds,
  }) : finds = List.unmodifiable(finds);

  final String labelKey;
  final bool burnt;
  final List<StrataFind> finds;
}

final class StrataConfig implements PuzzleConfig {
  StrataConfig({
    required List<StrataLayer> layers,
    required this.fireYear,
    required this.fire,
  }) : layers = List.unmodifiable(layers);

  /// From the top down.
  final List<StrataLayer> layers;
  final int fireYear;
  final int fire;

  /// The earliest year layer [i] can be: its youngest find, or the layer
  /// beneath it, whichever is later.
  int earliest(int i) {
    final own = layers[i].finds
        .map((f) => f.year)
        .reduce((a, b) => a > b ? a : b);
    if (i == layers.length - 1) return own;
    final below = earliest(i + 1);
    return own > below ? own : below;
  }

  /// The years to choose from: every find's, once, in order.
  List<int> get years => {
    for (final l in layers)
      for (final f in l.finds) f.year,
  }.toList()..sort();

  StrataState start() => StrataState(this, const {}, 0, fireFound: false);

  @override
  Iterable<ContentRef> get references => [
    for (final l in layers) ...[
      ContentRef.text(l.labelKey),
      for (final f in l.finds) ContentRef.text(f.labelKey),
    ],
  ];
}

/// What marking a layer as the fire came to.
enum StrataFire { found, notBurnt, tooLate, undated, none }

final class StrataState {
  StrataState(
    this.config,
    Map<int, int> dated,
    this.mistakes, {
    required this.fireFound,
  }) : dated = Map.unmodifiable(dated);

  final StrataConfig config;

  /// Layers dated rightly: their earliest year.
  final Map<int, int> dated;
  final int mistakes;
  final bool fireFound;

  bool get allDated => dated.length == config.layers.length;

  bool get isSolved => allDated && fireFound;

  /// Dates layer [i] as no older than [year].
  StrataState date(int i, int year) {
    if (isSolved || dated.containsKey(i)) return this;
    return year == config.earliest(i)
        ? StrataState(config, {...dated, i: year}, mistakes, fireFound: false)
        : StrataState(config, dated, mistakes + 1, fireFound: false);
  }

  /// What marking layer [i] as the fire would come to.
  StrataFire judgeFire(int i) {
    if (isSolved) return StrataFire.none;
    if (!allDated) return StrataFire.undated;
    if (!config.layers[i].burnt) return StrataFire.notBurnt;
    if (config.earliest(i) > config.fireYear) return StrataFire.tooLate;
    return StrataFire.found;
  }

  /// Marks layer [i] as the layer of the fire.
  StrataState markFire(int i) => switch (judgeFire(i)) {
    StrataFire.found => StrataState(config, dated, mistakes, fireFound: true),
    StrataFire.notBurnt || StrataFire.tooLate => StrataState(
      config,
      dated,
      mistakes + 1,
      fireFound: false,
    ),
    StrataFire.undated || StrataFire.none => this,
  };
}
