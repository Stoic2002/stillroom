import '../json/json_reader.dart';
import '../model/content_ref.dart';
import 'puzzle_type.dart';

/// `snowpit`: a pit dug through the snowpack, its layers from the surface
/// down. Push a fist, four fingers, one finger, a pencil or a knife into a
/// layer: the largest that goes in gives its hardness. Mark the weak layer,
/// softer than the one above it; a column is cut down to just below it and
/// tapped with the shovel, ten taps from the wrist, ten from the elbow,
/// ten from the shoulder. Solved when the column breaks on the layer
/// marked.
///
/// ```json
/// "config": {
///   "layers": [
///     { "thickness": 12, "hardness": "fist" },
///     { "thickness": 35, "hardness": "oneFinger" },
///     { "thickness": 6, "hardness": "fist" }
///   ],
///   "weak": 2,
///   "breakTap": 14
/// }
/// ```
/// 3 to 8 layers, each 2 to 80 cm thick. The `weak` layer is softer than
/// the one above it; a column that reaches it breaks there at tap
/// `breakTap` (1 to 30). A column that stops above it never breaks.
final class SnowpitType implements PuzzleType {
  const SnowpitType();

  static const typeId = 'snowpit';

  /// Taps in a full test: ten each from the wrist, the elbow, the
  /// shoulder.
  static const taps = 30;

  @override
  String get id => typeId;

  @override
  SnowpitConfig parseConfig(JsonReader json) {
    json.allowOnly({'layers', 'weak', 'breakTap'});
    final layers = [
      for (final l in json.objects('layers'))
        () {
          l.allowOnly({'thickness', 'hardness'});
          final thickness = l.integer('thickness');
          if (thickness < 2 || thickness > 80) {
            l.fail('from 2 to 80', 'thickness');
          }
          final hardness =
              SnowHardness.values.asNameMap()[l.string('hardness')] ??
              l.fail(
                'expected one of '
                    '${SnowHardness.values.map((h) => h.name).join(', ')}',
                'hardness',
              );
          return SnowLayer(thickness: thickness, hardness: hardness);
        }(),
    ];
    if (layers.length < 3 || layers.length > 8) {
      json.fail('need 3 to 8 layers', 'layers');
    }
    final weak = json.integer('weak');
    if (weak < 1 || weak >= layers.length) {
      json.fail('a layer below the first', 'weak');
    }
    if (layers[weak].hardness.index >= layers[weak - 1].hardness.index) {
      json.fail('must be softer than the layer above it', 'weak');
    }
    final breakTap = json.integer('breakTap');
    if (breakTap < 1 || breakTap > taps) {
      json.fail('from 1 to $taps', 'breakTap');
    }
    return SnowpitConfig(layers: layers, weak: weak, breakTap: breakTap);
  }
}

/// Hand hardness, softest first; also the object pushed in, largest first.
enum SnowHardness { fist, fourFingers, oneFinger, pencil, knife }

final class SnowLayer {
  const SnowLayer({required this.thickness, required this.hardness});

  /// In centimetres.
  final int thickness;
  final SnowHardness hardness;
}

final class SnowpitConfig implements PuzzleConfig {
  SnowpitConfig({
    required List<SnowLayer> layers,
    required this.weak,
    required this.breakTap,
  }) : layers = List.unmodifiable(layers);

  /// From the surface down.
  final List<SnowLayer> layers;
  final int weak;
  final int breakTap;

  /// Whether [tool] goes into layer [i]: a smaller object goes into harder
  /// snow.
  bool goesIn(int i, SnowHardness tool) =>
      tool.index >= layers[i].hardness.index;

  SnowpitState start() => SnowpitState(this, const {}, null, 0, null, 0);

  @override
  Iterable<ContentRef> get references => const [];
}

/// What marking a layer came to.
enum SnowpitMark { marked, untested, notSofter, none }

final class SnowpitState {
  SnowpitState(
    this.config,
    Map<int, Set<SnowHardness>> tried,
    this.marked,
    this.taps,
    this.broken,
    this.mistakes,
  ) : tried = Map.unmodifiable({
        for (final e in tried.entries) e.key: Set.unmodifiable(e.value),
      });

  final SnowpitConfig config;

  /// The objects pushed into each layer.
  final Map<int, Set<SnowHardness>> tried;

  /// The layer marked as weak; the column is cut to just below it.
  final int? marked;

  /// Taps on the column so far.
  final int taps;

  /// The layer the column broke on, if it has.
  final int? broken;
  final int mistakes;

  bool get isSolved => broken != null && broken == marked;

  /// Whether layer [i]'s hardness is known: the object that gives it went
  /// in, and the next larger one, if any, did not.
  bool known(int i) {
    final h = config.layers[i].hardness;
    final t = tried[i] ?? const {};
    return t.contains(h) &&
        (h.index == 0 || t.contains(SnowHardness.values[h.index - 1]));
  }

  bool get allKnown =>
      [for (var i = 0; i < config.layers.length; i++) known(i)].every((k) => k);

  /// Pushes [tool] into layer [i].
  SnowpitState push(int i, SnowHardness tool) {
    if (isSolved) return this;
    return SnowpitState(
      config,
      {
        ...tried,
        i: {...?tried[i], tool},
      },
      marked,
      taps,
      broken,
      mistakes,
    );
  }

  /// What marking layer [i] as weak would come to.
  SnowpitMark judge(int i) {
    if (isSolved || i == 0) return SnowpitMark.none;
    if (!known(i) || !known(i - 1)) return SnowpitMark.untested;
    final layers = config.layers;
    if (layers[i].hardness.index >= layers[i - 1].hardness.index) {
      return SnowpitMark.notSofter;
    }
    return SnowpitMark.marked;
  }

  /// Marks layer [i] as the weak layer, and cuts a fresh column below it.
  SnowpitState mark(int i) => switch (judge(i)) {
    SnowpitMark.marked => SnowpitState(config, tried, i, 0, null, mistakes),
    SnowpitMark.notSofter => SnowpitState(
      config,
      tried,
      marked,
      taps,
      broken,
      mistakes + 1,
    ),
    SnowpitMark.untested || SnowpitMark.none => this,
  };

  /// Whether the full test is done without a break.
  bool get spent =>
      marked != null && broken == null && taps >= SnowpitType.taps;

  /// Taps the shovel on the column once.
  SnowpitState tap() {
    final m = marked;
    if (m == null || isSolved || broken != null || spent) return this;
    final next = taps + 1;
    if (config.weak <= m && next == config.breakTap) {
      final right = config.weak == m;
      return SnowpitState(
        config,
        tried,
        m,
        next,
        config.weak,
        right ? mistakes : mistakes + 1,
      );
    }
    return SnowpitState(config, tried, m, next, null, mistakes);
  }
}
