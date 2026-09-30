import '../json/json_reader.dart';
import '../model/content_ref.dart';
import 'puzzle_type.dart';

/// `roster`: a board with a row for each person and a column for each thing
/// to be worked out about them. Every cell takes one of its column's
/// options; the clues are spread through the tale.
///
/// ```json
/// "config": {
///   "rows": [ { "id": "ducat", "labelKey": "..." } ],
///   "columns": [
///     {
///       "id": "wore",
///       "labelKey": "...",
///       "options": [ { "id": "oilskins", "labelKey": "..." } ]
///     }
///   ],
///   "solution": { "ducat": { "wore": "oilskins" } }
/// }
/// ```
/// Tapping a cell steps through its column's options. Once every cell is
/// filled, the board is checked: solved when every row matches `solution`;
/// otherwise the player learns how many rows are still wrong.
final class RosterType implements PuzzleType {
  const RosterType();

  static const typeId = 'roster';

  @override
  String get id => typeId;

  @override
  RosterConfig parseConfig(JsonReader json) {
    json.allowOnly({'rows', 'columns', 'solution'});
    final rows = [for (final r in json.objects('rows')) RosterRow._fromJson(r)];
    if (rows.length < 2) json.fail('need at least two rows', 'rows');
    if ({for (final r in rows) r.id}.length != rows.length) {
      json.fail('row ids must be unique', 'rows');
    }
    final columns = [
      for (final c in json.objects('columns')) RosterColumn._fromJson(c),
    ];
    if (columns.isEmpty) json.fail('need at least one column', 'columns');
    if ({for (final c in columns) c.id}.length != columns.length) {
      json.fail('column ids must be unique', 'columns');
    }
    final solutionJson = json.object('solution');
    solutionJson.allowOnly({for (final r in rows) r.id});
    final solution = <String, Map<String, String>>{};
    for (final row in rows) {
      final cells = solutionJson.object(row.id);
      cells.allowOnly({for (final c in columns) c.id});
      solution[row.id] = {
        for (final column in columns)
          column.id: () {
            final option = cells.string(column.id);
            if (!column.options.any((o) => o.id == option)) {
              cells.fail('unknown option "$option"', column.id);
            }
            return option;
          }(),
      };
    }
    return RosterConfig(rows: rows, columns: columns, solution: solution);
  }
}

final class RosterRow {
  const RosterRow({required this.id, required this.labelKey});

  factory RosterRow._fromJson(JsonReader json) {
    json.allowOnly({'id', 'labelKey'});
    return RosterRow(id: json.string('id'), labelKey: json.string('labelKey'));
  }

  final String id;
  final String labelKey;
}

final class RosterOption {
  const RosterOption({required this.id, required this.labelKey});

  final String id;
  final String labelKey;
}

final class RosterColumn {
  RosterColumn({
    required this.id,
    required this.labelKey,
    required List<RosterOption> options,
  }) : options = List.unmodifiable(options);

  factory RosterColumn._fromJson(JsonReader json) {
    json.allowOnly({'id', 'labelKey', 'options'});
    final options = [
      for (final o in json.objects('options'))
        () {
          o.allowOnly({'id', 'labelKey'});
          return RosterOption(
            id: o.string('id'),
            labelKey: o.string('labelKey'),
          );
        }(),
    ];
    if (options.length < 2) json.fail('need at least two options', 'options');
    if ({for (final o in options) o.id}.length != options.length) {
      json.fail('option ids must be unique', 'options');
    }
    return RosterColumn(
      id: json.string('id'),
      labelKey: json.string('labelKey'),
      options: options,
    );
  }

  final String id;
  final String labelKey;
  final List<RosterOption> options;
}

final class RosterConfig implements PuzzleConfig {
  RosterConfig({
    required List<RosterRow> rows,
    required List<RosterColumn> columns,
    required Map<String, Map<String, String>> solution,
  }) : rows = List.unmodifiable(rows),
       columns = List.unmodifiable(columns),
       solution = Map.unmodifiable(solution);

  final List<RosterRow> rows;
  final List<RosterColumn> columns;

  /// Row id → column id → option id.
  final Map<String, Map<String, String>> solution;

  RosterState start() => RosterState(this, const {});

  @override
  Iterable<ContentRef> get references => [
    for (final r in rows) ContentRef.text(r.labelKey),
    for (final c in columns) ...[
      ContentRef.text(c.labelKey),
      for (final o in c.options) ContentRef.text(o.labelKey),
    ],
  ];
}

final class RosterState {
  RosterState(this.config, Map<(String, String), String> picks)
    : picks = Map.unmodifiable(picks);

  final RosterConfig config;

  /// (row id, column id) → the option picked there.
  final Map<(String, String), String> picks;

  String? pick(String row, String column) => picks[(row, column)];

  bool get isComplete =>
      picks.length == config.rows.length * config.columns.length;

  /// Rows that do not yet match the solution (counted once complete).
  int get wrongRows => [
    for (final row in config.rows)
      if (config.columns.any(
        (c) => pick(row.id, c.id) != config.solution[row.id]![c.id],
      ))
        row,
  ].length;

  bool get isSolved => isComplete && wrongRows == 0;

  /// The cell at ([row], [column]) moves on to its column's next option,
  /// from blank to the first, and round again after the last.
  RosterState cycle(String row, String column) {
    if (isSolved) return this;
    final options = config.columns.firstWhere((c) => c.id == column).options;
    final current = options.indexWhere((o) => o.id == pick(row, column));
    final next = options[(current + 1) % options.length].id;
    return RosterState(config, {...picks, (row, column): next});
  }
}
