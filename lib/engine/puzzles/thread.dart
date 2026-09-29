import '../json/json_reader.dart';
import '../model/content_ref.dart';
import 'puzzle_type.dart';

/// `thread`: stretch a red thread from pin to pin on a map, in the right
/// order, like a detective's board.
///
/// ```json
/// "config": {
///   "pins": [
///     { "id": "bucks_row", "at": [0.3, 0.4], "labelKey": "..." }
///   ],
///   "solution": ["bucks_row", "hanbury_street", "..."]
/// }
/// ```
/// The player drags the thread from the last pin reached to the next one
/// (or taps the pins in turn). The first pin of `solution` starts it. A
/// wrong pin snaps the thread, and it starts again. Solved when the thread
/// has run through `solution` in order. `at` is where a pin is on the
/// board, normalized; `labelKey` (optional) is written beside it.
final class ThreadType implements PuzzleType {
  const ThreadType();

  static const typeId = 'thread';

  @override
  String get id => typeId;

  @override
  ThreadConfig parseConfig(JsonReader json) {
    json.allowOnly({'pins', 'solution'});
    final pins = [for (final p in json.objects('pins')) ThreadPin._fromJson(p)];
    final ids = {for (final p in pins) p.id};
    if (ids.length != pins.length) json.fail('pin ids must be unique', 'pins');
    final solution = json.strings('solution');
    if (solution.length < 2) json.fail('need at least two pins', 'solution');
    for (final (i, id) in solution.indexed) {
      if (!ids.contains(id)) json.fail('unknown pin "$id"', 'solution[$i]');
      if (i > 0 && solution[i - 1] == id) {
        json.fail('a thread cannot run from a pin to itself', 'solution[$i]');
      }
    }
    return ThreadConfig(pins: pins, solution: solution);
  }
}

final class ThreadPin {
  const ThreadPin({
    required this.id,
    required this.x,
    required this.y,
    this.labelKey,
  });

  factory ThreadPin._fromJson(JsonReader json) {
    json.allowOnly({'id', 'at', 'labelKey'});
    final at = json.numbers('at', length: 2);
    if (at.any((v) => v < 0 || v > 1)) json.fail('must be within 0–1', 'at');
    return ThreadPin(
      id: json.string('id'),
      x: at[0],
      y: at[1],
      labelKey: json.optionalString('labelKey'),
    );
  }

  final String id;
  final double x;
  final double y;
  final String? labelKey;
}

final class ThreadConfig implements PuzzleConfig {
  ThreadConfig({required List<ThreadPin> pins, required List<String> solution})
    : pins = List.unmodifiable(pins),
      solution = List.unmodifiable(solution);

  final List<ThreadPin> pins;
  final List<String> solution;

  ThreadPin pin(String id) => pins.firstWhere((p) => p.id == id);

  ThreadState start() => ThreadState(this, const []);

  @override
  Iterable<ContentRef> get references => [
    for (final p in pins)
      if (p.labelKey case final key?) ContentRef.text(key),
  ];
}

final class ThreadState {
  ThreadState(this.config, List<String> path) : path = List.unmodifiable(path);

  final ThreadConfig config;

  /// The pins the thread runs through so far.
  final List<String> path;

  bool get isSolved => path.length == config.solution.length;

  /// The thread reaches pin [pinId]: the next pin in order extends it; the
  /// pin it is already at changes nothing; any other pin snaps it.
  ThreadState reach(String pinId) {
    if (isSolved) return this;
    if (path.isNotEmpty && path.last == pinId) return this;
    if (config.solution[path.length] == pinId) {
      return ThreadState(config, [...path, pinId]);
    }
    // A wrong pin snaps the thread; it may start again from here.
    return ThreadState(config, [if (config.solution.first == pinId) pinId]);
  }
}
