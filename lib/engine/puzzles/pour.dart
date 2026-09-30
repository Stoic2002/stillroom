import '../json/json_reader.dart';
import '../model/content_ref.dart';
import 'puzzle_type.dart';

/// `pour`: clay channels between furnaces and a mould's pouring cups. Each
/// channel piece can be turned; route the bronze so every cup fills and
/// none spills into the sand.
///
/// ```json
/// "config": {
///   "columns": 4,
///   "furnaces": [0, 3],
///   "cups": [1, 2],
///   "tiles": ["bend:1", "straight:1", "tee:2", "bend:2",
///             "straight:0", "empty", "empty", "straight:0"],
///   "start": [2, 0, 1, 3, 1, 0, 0, 1]
/// }
/// ```
/// `tiles` lists the grid row by row, top to bottom, each as `kind:turns`
/// with the turns (clockwise quarter turns, 0–3) it has when solved.
/// Kinds: `straight` (top and bottom open), `bend` (top and right), `tee`
/// (top, right, bottom), `cross` (all four; cannot turn) and `empty` (sand;
/// cannot turn). Bronze enters the top row below each column in
/// `furnaces`, and must leave the bottom row into each column in `cups`.
/// `start` adds quarter turns to each tile, to scramble it.
///
/// Solved when every furnace feeds the channels, every cup is reached, and
/// no reached channel is open to sand, air or a piece that does not meet it.
final class PourType implements PuzzleType {
  const PourType();

  static const typeId = 'pour';

  @override
  String get id => typeId;

  @override
  PourConfig parseConfig(JsonReader json) {
    json.allowOnly({'columns', 'furnaces', 'cups', 'tiles', 'start'});
    final columns = json.integer('columns');
    if (columns < 2 || columns > 8) json.fail('need 2 to 8 columns', 'columns');
    final raw = json.strings('tiles');
    if (raw.isEmpty || raw.length % columns != 0) {
      json.fail('tiles must fill whole rows of $columns', 'tiles');
    }
    final tiles = [
      for (final (i, t) in raw.indexed)
        () {
          final parts = t.split(':');
          final kind = PourTileKind.values.asNameMap()[parts.first];
          if (kind == null) {
            json.fail(
              'unknown kind "${parts.first}" (expected '
                  '${PourTileKind.values.map((k) => k.name).join(', ')})',
              'tiles[$i]',
            );
          }
          final turns = parts.length > 1 ? int.tryParse(parts[1]) : 0;
          if (parts.length > 2 || turns == null || turns < 0 || turns > 3) {
            json.fail('expected "kind" or "kind:0" to "kind:3"', 'tiles[$i]');
          }
          return PourTile(kind, turns);
        }(),
    ];
    List<int> edge(String key) {
      final values = json.numbers(key);
      if (values.isEmpty) json.fail('need at least one', key);
      final out = [
        for (final (i, v) in values.indexed)
          if (v == v.roundToDouble() && v >= 0 && v < columns)
            v.toInt()
          else
            json.fail(
              'columns are whole numbers 0 to ${columns - 1}',
              '$key[$i]',
            ),
      ];
      if (out.toSet().length != out.length) json.fail('listed twice', key);
      return out;
    }

    final furnaces = edge('furnaces');
    final cups = edge('cups');
    final start = json.numbers('start', length: tiles.length);
    final scramble = [
      for (final (i, v) in start.indexed)
        if (v == v.roundToDouble() && v >= 0 && v <= 3)
          v.toInt()
        else
          json.fail('quarter turns are whole numbers 0 to 3', 'start[$i]'),
    ];
    final config = PourConfig(
      columns: columns,
      furnaces: furnaces,
      cups: cups,
      tiles: tiles,
      scramble: scramble,
    );
    if (!config.flow([for (final t in tiles) t.turns]).isSolved) {
      json.fail('the tiles as given (their solved turns) do not pour', 'tiles');
    }
    if (config.start().flow.isSolved) {
      json.fail('already poured before a tile is turned', 'start');
    }
    return config;
  }
}

enum PourTileKind {
  straight(0x5),
  bend(0x3),
  tee(0x7),
  cross(0xF),
  empty(0);

  const PourTileKind(this.openings);

  /// Open sides with no turn: top 1, right 2, bottom 4, left 8.
  final int openings;

  bool get turns => this != cross && this != empty;
}

final class PourTile {
  const PourTile(this.kind, this.turns);

  final PourTileKind kind;

  /// Clockwise quarter turns when solved.
  final int turns;
}

/// Sides: 0 top, 1 right, 2 bottom, 3 left.
int pourOpenings(PourTileKind kind, int turns) {
  var bits = kind.openings;
  for (var i = 0; i < turns % 4; i++) {
    bits = ((bits << 1) | (bits >> 3)) & 0xF;
  }
  return bits;
}

bool _open(int bits, int side) => bits & (1 << side) != 0;

final class PourConfig implements PuzzleConfig {
  PourConfig({
    required this.columns,
    required List<int> furnaces,
    required List<int> cups,
    required List<PourTile> tiles,
    required List<int> scramble,
  }) : furnaces = List.unmodifiable(furnaces),
       cups = List.unmodifiable(cups),
       tiles = List.unmodifiable(tiles),
       scramble = List.unmodifiable(scramble);

  final int columns;
  final List<int> furnaces;
  final List<int> cups;
  final List<PourTile> tiles;
  final List<int> scramble;

  int get rows => tiles.length ~/ columns;

  PourState start() => PourState(this, [
    for (final (i, t) in tiles.indexed)
      t.kind.turns ? (t.turns + scramble[i]) % 4 : 0,
  ], 0);

  /// Where bronze runs with the tiles turned [turns] times each.
  PourFlow flow(List<int> turns) {
    final open = [
      for (final (i, t) in tiles.indexed) pourOpenings(t.kind, turns[i]),
    ];
    final reached = <int>{};
    final leaks = <(int, int)>{};
    final queue = <int>[];
    var fed = true;
    for (final c in furnaces) {
      if (!_open(open[c], 0)) {
        fed = false;
        leaks.add((c, 0));
        continue;
      }
      if (reached.add(c)) queue.add(c);
    }
    while (queue.isNotEmpty) {
      final i = queue.removeLast();
      final row = i ~/ columns;
      final col = i % columns;
      for (var side = 0; side < 4; side++) {
        if (!_open(open[i], side)) continue;
        final (dr, dc) = switch (side) {
          0 => (-1, 0),
          1 => (0, 1),
          2 => (1, 0),
          _ => (0, -1),
        };
        final r = row + dr;
        final c = col + dc;
        if (r < 0) {
          if (!furnaces.contains(col)) leaks.add((i, side));
          continue;
        }
        if (r >= rows) {
          if (!cups.contains(col)) leaks.add((i, side));
          continue;
        }
        if (c < 0 || c >= columns) {
          leaks.add((i, side));
          continue;
        }
        final j = r * columns + c;
        if (!_open(open[j], (side + 2) % 4)) {
          leaks.add((i, side));
          continue;
        }
        if (reached.add(j)) queue.add(j);
      }
    }
    final filled = {
      for (final c in cups)
        if (reached.contains((rows - 1) * columns + c) &&
            _open(open[(rows - 1) * columns + c], 2))
          c,
    };
    return PourFlow(
      reached: reached,
      leaks: leaks,
      filled: filled,
      isSolved: fed && leaks.isEmpty && filled.length == cups.length,
    );
  }

  @override
  Iterable<ContentRef> get references => const [];
}

final class PourFlow {
  const PourFlow({
    required this.reached,
    required this.leaks,
    required this.filled,
    required this.isSolved,
  });

  /// Tiles the bronze runs through.
  final Set<int> reached;

  /// (tile, side) where it runs out into sand or air.
  final Set<(int, int)> leaks;

  /// Cup columns that fill.
  final Set<int> filled;
  final bool isSolved;
}

final class PourState {
  PourState(this.config, List<int> turns, this.pours, {this.poured = false})
    : turns = List.unmodifiable(turns);

  final PourConfig config;

  /// Each tile's quarter turns now.
  final List<int> turns;

  /// Furnaces opened so far.
  final int pours;

  /// Whether the last pour filled the mould.
  final bool poured;

  bool get isSolved => poured;

  PourFlow get flow => config.flow(turns);

  /// Turns tile [index] a quarter clockwise, if it can turn.
  PourState turn(int index) {
    if (poured || !config.tiles[index].kind.turns) return this;
    final next = [...turns];
    next[index] = (next[index] + 1) % 4;
    return PourState(config, next, pours);
  }

  /// Opens the furnaces: poured if the channels hold.
  PourState pour() {
    if (poured) return this;
    return PourState(config, turns, pours + 1, poured: flow.isSolved);
  }
}
