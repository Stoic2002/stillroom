import '../json/json_reader.dart';
import '../model/content_ref.dart';
import 'puzzle_type.dart';

/// `sonar`: a survey area as a grid, its rows the lanes a launch can run
/// with side-scan sonar, north to south. Each lane run costs an hour from
/// a small budget and draws the echoes of the seabed under it: rocks,
/// ice scours, and the wreck, a long shape. Mark the wreck on a lane that
/// has been run. When the hours are spent with nothing found, the season
/// ends and the survey starts again (a mistake).
///
/// ```json
/// "config": {
///   "columns": 12,
///   "rows": 8,
///   "hours": 3,
///   "wreck": { "column": 6, "row": 5, "length": 2 },
///   "rocks": [ [2, 1], [9, 5] ],
///   "scours": [ [4, 2], [7, 6] ],
///   "marks": [ { "labelKey": "ep.sonar.grant_point", "at": [11, 3] } ]
/// }
/// ```
/// 6 to 16 columns and 4 to 12 rows; 1 to `rows` hours; the wreck and
/// every rock and scour inside the grid and none on another; `marks` (up
/// to 8) are named places drawn on the chart at a cell.
final class SonarType implements PuzzleType {
  const SonarType();

  static const typeId = 'sonar';

  @override
  String get id => typeId;

  @override
  SonarConfig parseConfig(JsonReader json) {
    json.allowOnly({
      'columns',
      'rows',
      'hours',
      'wreck',
      'rocks',
      'scours',
      'marks',
    });
    final columns = json.integer('columns');
    final rows = json.integer('rows');
    if (columns < 6 || columns > 16) json.fail('6 to 16', 'columns');
    if (rows < 4 || rows > 12) json.fail('4 to 12', 'rows');
    final hours = json.integer('hours');
    if (hours < 1 || hours > rows) json.fail('1 to $rows', 'hours');
    bool inside(int c, int r) => c >= 0 && c < columns && r >= 0 && r < rows;
    final w = json.object('wreck');
    w.allowOnly({'column', 'row', 'length'});
    final wreck = (
      column: w.integer('column'),
      row: w.integer('row'),
      length: w.integer('length'),
    );
    if (wreck.length < 1 ||
        !inside(wreck.column, wreck.row) ||
        !inside(wreck.column + wreck.length - 1, wreck.row)) {
      json.fail('must lie inside the grid', 'wreck');
    }
    final taken = <(int, int)>{
      for (var c = wreck.column; c < wreck.column + wreck.length; c++)
        (c, wreck.row),
    };
    List<(int, int)> cells(String key) {
      final list = json.json[key];
      if (list == null) return const [];
      if (list is! List<Object?>) json.fail('expected a list', key);
      return [
        for (var i = 0; i < list.length; i++)
          switch (list[i]) {
            [final int c, final int r] when inside(c, r) && taken.add((c, r)) =>
              (c, r),
            _ => json.fail('a free cell [column, row] in the grid', '$key[$i]'),
          },
      ];
    }

    final rocks = cells('rocks');
    final scours = cells('scours');
    final marks = [
      for (final m in json.objects('marks', optional: true))
        () {
          m.allowOnly({'labelKey', 'at'});
          final at = m.numbers('at', length: 2);
          return SonarMark(
            labelKey: m.string('labelKey'),
            column: at[0],
            row: at[1],
          );
        }(),
    ];
    if (marks.length > 8) json.fail('at most 8 marks', 'marks');
    return SonarConfig(
      columns: columns,
      rows: rows,
      hours: hours,
      wreckColumn: wreck.column,
      wreckRow: wreck.row,
      wreckLength: wreck.length,
      rocks: rocks,
      scours: scours,
      marks: marks,
    );
  }
}

/// A named place drawn on the survey chart, at a cell (fractions allowed).
final class SonarMark {
  const SonarMark({
    required this.labelKey,
    required this.column,
    required this.row,
  });

  final String labelKey;
  final double column;
  final double row;
}

/// What the sonar shows at a cell of a lane that has been run.
enum SonarEcho { none, rock, scour, wreck }

/// What marking a cell came to.
enum SonarJudge { found, rock, scour, nothing, unrun }

final class SonarConfig implements PuzzleConfig {
  SonarConfig({
    required this.columns,
    required this.rows,
    required this.hours,
    required this.wreckColumn,
    required this.wreckRow,
    required this.wreckLength,
    required List<(int, int)> rocks,
    required List<(int, int)> scours,
    required List<SonarMark> marks,
  }) : rocks = Set.unmodifiable(rocks),
       scours = Set.unmodifiable(scours),
       marks = List.unmodifiable(marks);

  final int columns;
  final int rows;
  final int hours;
  final int wreckColumn;
  final int wreckRow;
  final int wreckLength;
  final Set<(int, int)> rocks;
  final Set<(int, int)> scours;
  final List<SonarMark> marks;

  SonarEcho echoAt(int c, int r) {
    if (r == wreckRow && c >= wreckColumn && c < wreckColumn + wreckLength) {
      return SonarEcho.wreck;
    }
    if (rocks.contains((c, r))) return SonarEcho.rock;
    if (scours.contains((c, r))) return SonarEcho.scour;
    return SonarEcho.none;
  }

  SonarState start() => SonarState(this, const {}, 0, found: false, seasons: 1);

  @override
  Iterable<ContentRef> get references => [
    for (final m in marks) ContentRef.text(m.labelKey),
  ];
}

final class SonarState {
  SonarState(
    this.config,
    Set<int> run,
    this.mistakes, {
    required this.found,
    required this.seasons,
  }) : run = Set.unmodifiable(run);

  final SonarConfig config;

  /// The lanes (rows) run this season.
  final Set<int> run;
  final int mistakes;
  final bool found;

  /// Which season of searching this is, from 1.
  final int seasons;

  bool get isSolved => found;

  int get hoursLeft => config.hours - run.length;

  /// Whether the season is spent with the wreck not found.
  bool get spent => !found && hoursLeft == 0;

  /// Runs lane [row], if there are hours left and it was not run.
  SonarState runLane(int row) {
    if (found || hoursLeft == 0 || run.contains(row)) return this;
    if (row < 0 || row >= config.rows) return this;
    return SonarState(
      config,
      {...run, row},
      mistakes,
      found: false,
      seasons: seasons,
    );
  }

  /// What the sonar shows at a cell, if its lane was run.
  SonarEcho? echoAt(int c, int r) =>
      run.contains(r) ? config.echoAt(c, r) : null;

  SonarJudge judge(int c, int r) => switch (echoAt(c, r)) {
    null => SonarJudge.unrun,
    SonarEcho.wreck => SonarJudge.found,
    SonarEcho.rock => SonarJudge.rock,
    SonarEcho.scour => SonarJudge.scour,
    SonarEcho.none => SonarJudge.nothing,
  };

  /// Marks the cell as the wreck.
  SonarState mark(int c, int r) {
    if (found) return this;
    return switch (judge(c, r)) {
      SonarJudge.found => SonarState(
        config,
        run,
        mistakes,
        found: true,
        seasons: seasons,
      ),
      SonarJudge.unrun => this,
      _ => SonarState(
        config,
        run,
        mistakes + 1,
        found: false,
        seasons: seasons,
      ),
    };
  }

  /// Ends a spent season: the lanes are cleared and the hours come back.
  SonarState nextSeason() => spent
      ? SonarState(
          config,
          const {},
          mistakes + 1,
          found: false,
          seasons: seasons + 1,
        )
      : this;
}
