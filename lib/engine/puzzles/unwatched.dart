import '../json/json_reader.dart';
import '../model/content_ref.dart';
import 'puzzle_type.dart';

/// `unwatched`: a shelf that changes while no one is looking. Look away and
/// back: a new thing has appeared on it (and others may have moved). Find
/// the new one, round after round.
///
/// ```json
/// "config": {
///   "items": [
///     { "id": "nichols", "labelKey": "…", "dateKey": "…" },
///     { "id": "smith", "labelKey": "…", "dateKey": "…" }
///   ],
///   "start": ["nichols"],
///   "rounds": [
///     { "add": "smith", "at": 0, "move": [1, 0] }
///   ]
/// }
/// ```
/// `items` defines every thing that can stand on the shelf (a label and a
/// small second line). `start` is the shelf at first, left to right. Each
/// round, when the player looks away, puts `add` at index `at`, then, if
/// `move` is given, moves the thing at index `move[0]` to `move[1]`. The
/// player must then tap the one added; tapping any other is a mistake.
/// Solved once every round's addition is found.
final class UnwatchedType implements PuzzleType {
  const UnwatchedType();

  static const typeId = 'unwatched';

  @override
  String get id => typeId;

  @override
  UnwatchedConfig parseConfig(JsonReader json) {
    json.allowOnly({'items', 'start', 'rounds'});
    final items = [
      for (final i in json.objects('items'))
        () {
          i.allowOnly({'id', 'labelKey', 'dateKey'});
          return UnwatchedItem(
            id: i.string('id'),
            labelKey: i.string('labelKey'),
            dateKey: i.optionalString('dateKey'),
          );
        }(),
    ];
    final known = {for (final i in items) i.id};
    if (known.length != items.length) {
      json.fail('item ids must be unique', 'items');
    }
    final start = json.strings('start');
    for (final (i, id) in start.indexed) {
      if (!known.contains(id)) json.fail('unknown item "$id"', 'start[$i]');
    }
    if (start.toSet().length != start.length) {
      json.fail('an item stands on the shelf once', 'start');
    }
    final shelf = [...start];
    final rounds = <UnwatchedRound>[];
    for (final r in json.objects('rounds')) {
      r.allowOnly({'add', 'at', 'move'});
      final add = r.string('add');
      if (!known.contains(add)) r.fail('unknown item "$add"', 'add');
      if (shelf.contains(add)) r.fail('"$add" is already on the shelf', 'add');
      final at = r.integer('at');
      if (at < 0 || at > shelf.length) {
        r.fail('an index 0 to ${shelf.length}', 'at');
      }
      List<int>? move;
      if (r.has('move')) {
        final m = r.numbers('move', length: 2);
        move = [for (final v in m) v.toInt()];
        for (final (k, v) in move.indexed) {
          if (v != m[k] || v < 0 || v > shelf.length) {
            r.fail('indexes 0 to ${shelf.length}', 'move');
          }
        }
      }
      final round = UnwatchedRound(add: add, at: at, move: move);
      round.apply(shelf);
      rounds.add(round);
    }
    if (rounds.isEmpty) json.fail('need at least one round', 'rounds');
    return UnwatchedConfig(items: items, start: start, rounds: rounds);
  }
}

final class UnwatchedItem {
  const UnwatchedItem({required this.id, required this.labelKey, this.dateKey});

  final String id;
  final String labelKey;

  /// A second, smaller line (a date), if any.
  final String? dateKey;
}

final class UnwatchedRound {
  UnwatchedRound({required this.add, required this.at, List<int>? move})
    : move = move == null ? null : List.unmodifiable(move);

  final String add;
  final int at;

  /// [from, to]: an item moved after the addition.
  final List<int>? move;

  /// Changes [shelf] in place as this round does.
  void apply(List<String> shelf) {
    shelf.insert(at, add);
    final m = move;
    if (m != null) {
      final item = shelf.removeAt(m[0]);
      shelf.insert(m[1].clamp(0, shelf.length), item);
    }
  }
}

final class UnwatchedConfig implements PuzzleConfig {
  UnwatchedConfig({
    required List<UnwatchedItem> items,
    required List<String> start,
    required List<UnwatchedRound> rounds,
  }) : items = List.unmodifiable(items),
       start = List.unmodifiable(start),
       rounds = List.unmodifiable(rounds);

  final List<UnwatchedItem> items;
  final List<String> start;
  final List<UnwatchedRound> rounds;

  UnwatchedItem item(String id) => items.firstWhere((i) => i.id == id);

  UnwatchedState startState() =>
      UnwatchedState(this, start, round: 0, looking: true, mistakes: 0);

  @override
  Iterable<ContentRef> get references => [
    for (final i in items) ...[
      ContentRef.text(i.labelKey),
      if (i.dateKey case final d?) ContentRef.text(d),
    ],
  ];
}

final class UnwatchedState {
  UnwatchedState(
    this.config,
    List<String> shelf, {
    required this.round,
    required this.looking,
    required this.mistakes,
  }) : shelf = List.unmodifiable(shelf);

  final UnwatchedConfig config;

  /// What stands on the shelf now, left to right.
  final List<String> shelf;

  /// Rounds whose addition has been found.
  final int round;

  /// True while nothing new waits to be found: the player may look away.
  final bool looking;
  final int mistakes;

  bool get isSolved => round >= config.rounds.length;

  /// The addition waiting to be found, if the shelf has just changed.
  String? get added => looking || isSolved ? null : config.rounds[round].add;

  /// Looks away and back: the next round changes the shelf.
  UnwatchedState lookAway() {
    if (!looking || isSolved) return this;
    final next = [...shelf];
    config.rounds[round].apply(next);
    return UnwatchedState(
      config,
      next,
      round: round,
      looking: false,
      mistakes: mistakes,
    );
  }

  /// Taps [id] on the shelf as the new one.
  UnwatchedState tap(String id) {
    final wanted = added;
    if (wanted == null) return this;
    if (id == wanted) {
      return UnwatchedState(
        config,
        shelf,
        round: round + 1,
        looking: true,
        mistakes: mistakes,
      );
    }
    return UnwatchedState(
      config,
      shelf,
      round: round,
      looking: false,
      mistakes: mistakes + 1,
    );
  }
}
