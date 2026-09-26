import '../actions/game_action.dart';
import '../json/json_reader.dart';
import '../puzzles/puzzle_type.dart';
import 'condition.dart';

final class Puzzle {
  const Puzzle({
    required this.id,
    required this.type,
    required this.config,
    this.background,
    this.onSolved = const [],
    this.hints = const [],
  });

  factory Puzzle.fromJson(
    JsonReader json,
    ActionRegistry actions,
    PuzzleTypeRegistry puzzleTypes,
  ) {
    json.allowOnly({'id', 'type', 'background', 'config', 'onSolved', 'hints'});
    final hints = [
      for (final h in json.objects('hints', optional: true)) Hint.fromJson(h),
    ];
    if (hints.length > maxHints) json.fail('at most $maxHints hints', 'hints');
    return Puzzle(
      id: json.string('id'),
      type: json.string('type'),
      config: puzzleTypes.parseConfig(json),
      background: json.optionalString('background'),
      onSolved: actions.parseList(json, 'onSolved'),
      hints: hints,
    );
  }

  static const maxHints = 3;

  final String id;
  final String type;
  final PuzzleConfig config;

  /// Board image behind the puzzle (same aspect as scenes). Optional.
  final String? background;
  final List<GameAction> onSolved;

  /// Ordered vague → explicit → solution (PRD FR-08).
  final List<Hint> hints;
}

final class Hint {
  const Hint({required this.textKey, this.when = const []});

  factory Hint.fromJson(JsonReader json) {
    json.allowOnly({'key', 'when'});
    return Hint(
      textKey: json.string('key'),
      when: Condition.listFromJson(json, 'when'),
    );
  }

  final String textKey;

  /// The hint is offered only while all are met.
  final List<Condition> when;
}
