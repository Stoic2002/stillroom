import '../json/json_reader.dart';
import '../model/content_ref.dart';
import 'puzzle_type.dart';

/// `codeLock`: N dials, each cycling through the same symbols.
///
/// ```json
/// "config": {
///   "slots": 4,
///   "symbols": ["0","1","2","3","4","5","6","7","8","9"],
///   "solution": ["3","1","4","1"],
///   "initial": ["0","0","0","0"]
/// }
/// ```
/// `initial` is optional (defaults to the first symbol on every dial).
/// Symbols are shown as-is, so use digits or glyphs, not words.
final class CodeLockType implements PuzzleType {
  const CodeLockType();

  static const typeId = 'codeLock';

  @override
  String get id => typeId;

  @override
  CodeLockConfig parseConfig(JsonReader json) {
    json.allowOnly({'slots', 'symbols', 'solution', 'initial'});
    final slots = json.integer('slots');
    if (slots < 1) json.fail('must be >= 1', 'slots');
    final symbols = json.strings('symbols');
    if (symbols.length < 2) json.fail('need at least 2 symbols', 'symbols');
    if (symbols.toSet().length != symbols.length) {
      json.fail('symbols must be unique', 'symbols');
    }
    List<int> indices(String key) {
      final values = json.strings(key);
      if (values.length != slots) json.fail('expected $slots symbols', key);
      return [
        for (final (i, v) in values.indexed)
          if (symbols.indexOf(v) case final index when index >= 0)
            index
          else
            json.fail('"$v" is not in symbols', '$key[$i]'),
      ];
    }

    return CodeLockConfig(
      symbols: symbols,
      solution: indices('solution'),
      initial: json.has('initial') ? indices('initial') : List.filled(slots, 0),
    );
  }
}

final class CodeLockConfig implements PuzzleConfig {
  CodeLockConfig({
    required List<String> symbols,
    required List<int> solution,
    required List<int> initial,
  }) : symbols = List.unmodifiable(symbols),
       solution = List.unmodifiable(solution),
       initial = List.unmodifiable(initial);

  final List<String> symbols;

  /// Symbol index per dial.
  final List<int> solution;
  final List<int> initial;

  int get slots => solution.length;

  CodeLockState start() => CodeLockState(this, initial);

  @override
  Iterable<ContentRef> get references => const [];
}

/// Dial positions while the player works on the lock.
final class CodeLockState {
  CodeLockState(this.config, List<int> positions)
    : positions = List.unmodifiable(positions);

  final CodeLockConfig config;

  /// Symbol index shown on each dial.
  final List<int> positions;

  String symbolAt(int slot) => config.symbols[positions[slot]];

  /// Turns dial [slot] by [delta] symbols, wrapping around.
  CodeLockState rotate(int slot, int delta) {
    final count = config.symbols.length;
    return CodeLockState(config, [
      for (final (i, p) in positions.indexed)
        i == slot ? (p + delta) % count : p,
    ]);
  }

  bool get isSolved {
    for (var i = 0; i < positions.length; i++) {
      if (positions[i] != config.solution[i]) return false;
    }
    return true;
  }
}
