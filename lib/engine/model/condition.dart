import '../engine_exception.dart';
import '../json/json_reader.dart';
import '../state/game_state.dart';
import 'content_ref.dart';

/// A single test against [GameState]. A list of conditions is combined with
/// AND; an empty list is always met.
sealed class Condition {
  const Condition();

  /// Parses one condition object. Exactly one subject key must be present:
  ///
  /// - `{ "flag": "name", "equals": true | 3 }`
  /// - `{ "hasItem": "id", "equals": true }` (currently held)
  /// - `{ "everHadItem": "id", "equals": true }` (ever picked up)
  /// - `{ "puzzleSolved": "id", "equals": true }`
  ///
  /// `equals` is required for `flag` and defaults to `true` otherwise.
  factory Condition.fromJson(JsonReader json) {
    final subjects = _subjectKeys.where(json.has).toList();
    if (subjects.length != 1) {
      json.fail('expected exactly one of ${_subjectKeys.join(', ')}');
    }
    json.allowOnly({subjects.single, 'equals'});
    final subject = subjects.single;
    final id = json.string(subject);
    if (subject == 'flag') {
      final expected = json.value('equals');
      if (expected is! bool && expected is! int) {
        json.fail('expected true, false, or an integer', 'equals');
      }
      return FlagCondition(id, expected);
    }
    final expected = json.optionalBool('equals') ?? true;
    return switch (subject) {
      'hasItem' => HasItemCondition(id, expected: expected),
      'everHadItem' => EverHadItemCondition(id, expected: expected),
      _ => PuzzleSolvedCondition(id, expected: expected),
    };
  }

  static const _subjectKeys = [
    'flag',
    'hasItem',
    'everHadItem',
    'puzzleSolved',
  ];

  static List<Condition> listFromJson(JsonReader parent, String key) => [
    for (final c in parent.objects(key, optional: true)) Condition.fromJson(c),
  ];

  bool isMet(GameState state);

  ContentRef get reference;
}

final class FlagCondition extends Condition {
  const FlagCondition(this.flag, this.expected);

  final String flag;

  /// `bool` or `int`.
  final Object expected;

  @override
  ContentRef get reference => ContentRef.flag(flag, expected);

  @override
  bool isMet(GameState state) {
    final value = state.flags[flag];
    if (value == null) throw EngineException('undeclared flag "$flag"');
    return value == expected;
  }
}

final class HasItemCondition extends Condition {
  const HasItemCondition(this.itemId, {this.expected = true});

  final String itemId;
  final bool expected;

  @override
  ContentRef get reference => ContentRef.item(itemId);

  @override
  bool isMet(GameState state) => state.hasItem(itemId) == expected;
}

final class EverHadItemCondition extends Condition {
  const EverHadItemCondition(this.itemId, {this.expected = true});

  final String itemId;
  final bool expected;

  @override
  ContentRef get reference => ContentRef.item(itemId);

  @override
  bool isMet(GameState state) =>
      state.everHadItems.contains(itemId) == expected;
}

final class PuzzleSolvedCondition extends Condition {
  const PuzzleSolvedCondition(this.puzzleId, {this.expected = true});

  final String puzzleId;
  final bool expected;

  @override
  ContentRef get reference => ContentRef.puzzle(puzzleId);

  @override
  bool isMet(GameState state) =>
      state.solvedPuzzles.contains(puzzleId) == expected;
}

extension ConditionListX on List<Condition> {
  bool allMet(GameState state) => every((c) => c.isMet(state));
}
