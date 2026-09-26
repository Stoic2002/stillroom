import '../json/json_reader.dart';
import '../model/content_ref.dart';

/// Parsed, type-specific puzzle configuration (the `config` object in JSON).
///
/// Each puzzle type owns its answer-checking logic here, so widgets only
/// collect input and ask the config whether it is correct.
abstract interface class PuzzleConfig {
  /// Items, text keys, images, ... the config points at, for the validator.
  Iterable<ContentRef> get references;
}

/// A puzzle type such as `codeLock`. Adding a type means implementing this,
/// registering it in [PuzzleTypeRegistry], and registering a matching widget
/// in the presentation layer; the engine core does not change.
abstract interface class PuzzleType {
  /// The `type` value used in JSON.
  String get id;

  PuzzleConfig parseConfig(JsonReader config);
}

final class PuzzleTypeRegistry {
  PuzzleTypeRegistry();

  final Map<String, PuzzleType> _types = {};

  Iterable<String> get types => _types.keys;

  void register(PuzzleType type) {
    if (_types.containsKey(type.id)) {
      throw ArgumentError.value(
        type.id,
        'type',
        'puzzle type already registered',
      );
    }
    _types[type.id] = type;
  }

  /// Parses `config` of [puzzle] using the type named in its `type` field.
  PuzzleConfig parseConfig(JsonReader puzzle) {
    final typeId = puzzle.string('type');
    final type =
        _types[typeId] ?? puzzle.fail('unknown puzzle type "$typeId"', 'type');
    return type.parseConfig(puzzle.object('config'));
  }
}
