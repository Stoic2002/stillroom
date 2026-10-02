import '../json/json_reader.dart';
import '../model/content_ref.dart';
import 'puzzle_type.dart';

/// `streets`: a city's grid of named streets, and addresses read from it.
/// Each address names one block (between two neighbouring streets each
/// way); the player marks the block each address names, in turn.
///
/// ```json
/// "config": {
///   "columns": [ { "labelKey": "ep.st.horikawa" }, { "labelKey": "…" } ],
///   "rows": [ { "labelKey": "ep.st.oike" }, { "labelKey": "…" } ],
///   "targets": [ { "clueKey": "ep.st.old", "block": [1, 3] } ]
/// }
/// ```
/// `columns` run west to east, `rows` north to south (2 to 14 and 2 to 10
/// streets). Block `[c, r]` lies east of column `c` and west of `c + 1`,
/// south of row `r` and north of `r + 1`. 1 to 4 targets, each a
/// different block.
final class StreetsType implements PuzzleType {
  const StreetsType();

  static const typeId = 'streets';

  @override
  String get id => typeId;

  @override
  StreetsConfig parseConfig(JsonReader json) {
    json.allowOnly({'columns', 'rows', 'targets'});
    List<String> streets(String key, int least, int most) {
      final list = [
        for (final s in json.objects(key))
          () {
            s.allowOnly({'labelKey'});
            return s.string('labelKey');
          }(),
      ];
      if (list.length < least || list.length > most) {
        json.fail('need $least to $most streets', key);
      }
      return list;
    }

    final columns = streets('columns', 2, 14);
    final rows = streets('rows', 2, 10);
    final targets = [
      for (final t in json.objects('targets'))
        () {
          t.allowOnly({'clueKey', 'block'});
          final block = t.numbers('block', length: 2);
          final c = block[0].toInt();
          final r = block[1].toInt();
          if (c < 0 ||
              c >= columns.length - 1 ||
              r < 0 ||
              r >= rows.length - 1) {
            t.fail('not a block between the streets', 'block');
          }
          return StreetsTarget(clueKey: t.string('clueKey'), column: c, row: r);
        }(),
    ];
    if (targets.isEmpty || targets.length > 4) {
      json.fail('need 1 to 4 targets', 'targets');
    }
    if (targets.map((t) => (t.column, t.row)).toSet().length !=
        targets.length) {
      json.fail('each target a different block', 'targets');
    }
    return StreetsConfig(columns: columns, rows: rows, targets: targets);
  }
}

final class StreetsTarget {
  const StreetsTarget({
    required this.clueKey,
    required this.column,
    required this.row,
  });

  final String clueKey;
  final int column;
  final int row;
}

final class StreetsConfig implements PuzzleConfig {
  StreetsConfig({
    required List<String> columns,
    required List<String> rows,
    required List<StreetsTarget> targets,
  }) : columns = List.unmodifiable(columns),
       rows = List.unmodifiable(rows),
       targets = List.unmodifiable(targets);

  /// Street names west to east, then north to south (text keys).
  final List<String> columns;
  final List<String> rows;
  final List<StreetsTarget> targets;

  StreetsState start() => StreetsState(this, 0, 0);

  @override
  Iterable<ContentRef> get references => [
    for (final k in [...columns, ...rows]) ContentRef.text(k),
    for (final t in targets) ContentRef.text(t.clueKey),
  ];
}

final class StreetsState {
  const StreetsState(this.config, this.found, this.mistakes);

  final StreetsConfig config;

  /// Targets marked so far, in order.
  final int found;
  final int mistakes;

  bool get isSolved => found == config.targets.length;

  /// The address being read now.
  StreetsTarget? get current => isSolved ? null : config.targets[found];

  /// Marks block ([column], [row]) for the current address.
  StreetsState mark(int column, int row) {
    final t = current;
    if (t == null) return this;
    return t.column == column && t.row == row
        ? StreetsState(config, found + 1, mistakes)
        : StreetsState(config, found, mistakes + 1);
  }
}
