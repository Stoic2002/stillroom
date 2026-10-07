import '../json/json_reader.dart';
import '../model/content_ref.dart';
import 'puzzle_type.dart';

/// `casing`: a stretch of stone casing over hidden reliefs, stone by
/// stone; behind each stone a panel, a deed or its fruit. Lift a stone to
/// see what is behind it; only two may stand out at once. Two that are a
/// deed and its fruit are kept (photographed); two that are not go back
/// when the next stone is lifted. Keep every pair.
///
/// ```json
/// "config": {
///   "columns": 4,
///   "panels": [
///     { "labelKey": "ep.karma.killing", "pair": 0 },
///     { "labelKey": "ep.karma.short_life", "pair": 0, "fruit": true }
///   ]
/// }
/// ```
/// Panels in stone order, row by row, `columns` across (2 to 6). 4 to 16
/// panels; every `pair` has exactly one deed and one fruit.
final class CasingType implements PuzzleType {
  const CasingType();

  static const typeId = 'casing';

  @override
  String get id => typeId;

  @override
  CasingConfig parseConfig(JsonReader json) {
    json.allowOnly({'columns', 'panels'});
    final columns = json.integer('columns');
    if (columns < 2 || columns > 6) json.fail('2 to 6', 'columns');
    final panels = [
      for (final p in json.objects('panels'))
        () {
          p.allowOnly({'labelKey', 'pair', 'fruit'});
          return CasingPanel(
            labelKey: p.string('labelKey'),
            pair: p.integer('pair'),
            fruit: p.optionalBool('fruit') ?? false,
          );
        }(),
    ];
    if (panels.length < 4 || panels.length > 16) {
      json.fail('need 4 to 16 panels', 'panels');
    }
    final pairs = {for (final p in panels) p.pair};
    for (final pair in pairs) {
      final of = panels.where((p) => p.pair == pair).toList();
      if (of.length != 2 || of.where((p) => p.fruit).length != 1) {
        json.fail('pair $pair needs one deed and one fruit', 'panels');
      }
    }
    return CasingConfig(columns: columns, panels: panels);
  }
}

final class CasingPanel {
  const CasingPanel({
    required this.labelKey,
    required this.pair,
    required this.fruit,
  });

  final String labelKey;
  final int pair;

  /// The fruit of a deed, rather than the deed.
  final bool fruit;
}

final class CasingConfig implements PuzzleConfig {
  CasingConfig({required this.columns, required List<CasingPanel> panels})
    : panels = List.unmodifiable(panels);

  final int columns;
  final List<CasingPanel> panels;

  int get rows => (panels.length / columns).ceil();

  CasingState start() => CasingState(this, const [], const {}, 0);

  @override
  Iterable<ContentRef> get references => [
    for (final p in panels) ContentRef.text(p.labelKey),
  ];
}

/// What lifting a stone came to.
enum CasingLift { first, pair, noPair, none }

final class CasingState {
  CasingState(this.config, List<int> open, Set<int> kept, this.mismatches)
    : open = List.unmodifiable(open),
      kept = Set.unmodifiable(kept);

  final CasingConfig config;

  /// The stones standing out now (at most two), not yet kept.
  final List<int> open;

  /// Panels kept: a deed with its fruit, photographed.
  final Set<int> kept;
  final int mismatches;

  bool get isSolved => kept.length == config.panels.length;

  bool shows(int i) => kept.contains(i) || open.contains(i);

  /// What lifting stone [i] would come to.
  CasingLift judge(int i) {
    if (shows(i)) return CasingLift.none;
    final standing = open.length == 2 ? <int>[] : open;
    if (standing.isEmpty) return CasingLift.first;
    final a = config.panels[standing.first];
    final b = config.panels[i];
    return a.pair == b.pair ? CasingLift.pair : CasingLift.noPair;
  }

  /// Lifts stone [i]; two out already go back first.
  CasingState lift(int i) {
    final judged = judge(i);
    if (judged == CasingLift.none) return this;
    final standing = open.length == 2 ? <int>[] : open;
    return switch (judged) {
      CasingLift.first => CasingState(config, [i], kept, mismatches),
      CasingLift.pair => CasingState(config, const [], {
        ...kept,
        standing.first,
        i,
      }, mismatches),
      CasingLift.noPair => CasingState(
        config,
        [standing.first, i],
        kept,
        mismatches + 1,
      ),
      CasingLift.none => this,
    };
  }

  /// Puts the stones standing out back.
  CasingState putBack() => CasingState(config, const [], kept, mismatches);
}
