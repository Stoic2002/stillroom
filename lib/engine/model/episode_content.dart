import '../actions/built_in_actions.dart';
import '../actions/game_action.dart';
import '../engine_exception.dart';
import '../json/json_reader.dart';
import '../puzzles/built_in_puzzles.dart';
import '../puzzles/puzzle_type.dart';
import 'game_config.dart';
import 'item.dart';
import 'puzzle.dart';
import 'scene.dart';

/// Parsers used while reading content. Extend these to add action or puzzle
/// types without touching the engine core.
final class ContentRegistries {
  ContentRegistries({required this.actions, required this.puzzleTypes});

  /// The v1 actions and puzzle types.
  factory ContentRegistries.withBuiltIns() {
    final actions = ActionRegistry();
    registerBuiltInActions(actions);
    final puzzleTypes = PuzzleTypeRegistry();
    registerBuiltInPuzzleTypes(puzzleTypes);
    return ContentRegistries(actions: actions, puzzleTypes: puzzleTypes);
  }

  final ActionRegistry actions;
  final PuzzleTypeRegistry puzzleTypes;
}

/// Everything that makes up one episode, parsed and indexed by id.
final class EpisodeContent {
  EpisodeContent({
    required this.id,
    required this.config,
    required Map<String, Scene> scenes,
    required Map<String, ItemDef> items,
    required this.combinations,
    required Map<String, Puzzle> puzzles,
  }) : scenes = Map.unmodifiable(scenes),
       items = Map.unmodifiable(items),
       puzzles = Map.unmodifiable(puzzles);

  /// Builds an episode from decoded JSON documents: `game.json`, `items.json`,
  /// and one document per scene and puzzle.
  factory EpisodeContent.parse({
    required String id,
    required JsonReader game,
    required JsonReader items,
    required List<JsonReader> scenes,
    required List<JsonReader> puzzles,
    required ContentRegistries registries,
  }) {
    items.allowOnly({'items', 'combinations'});
    final combinations = [
      for (final c in items.objects('combinations', optional: true))
        Combination.fromJson(c),
    ];
    for (var i = 0; i < combinations.length; i++) {
      for (var j = 0; j < i; j++) {
        if (combinations[j].matches(combinations[i].a, combinations[i].b)) {
          items.fail('duplicate combination', 'combinations[$i]');
        }
      }
    }
    return EpisodeContent(
      id: id,
      config: GameConfig.fromJson(game),
      scenes: _indexById(
        scenes,
        (json) => Scene.fromJson(json, registries.actions),
        (s) => s.id,
      ),
      items: _indexById(
        items.objects('items'),
        (json) => ItemDef.fromJson(json, registries.actions),
        (i) => i.id,
      ),
      combinations: List.unmodifiable(combinations),
      puzzles: _indexById(
        puzzles,
        (json) =>
            Puzzle.fromJson(json, registries.actions, registries.puzzleTypes),
        (p) => p.id,
      ),
    );
  }

  final String id;
  final GameConfig config;
  final Map<String, Scene> scenes;
  final Map<String, ItemDef> items;
  final List<Combination> combinations;
  final Map<String, Puzzle> puzzles;

  Scene requireScene(String id) =>
      scenes[id] ?? (throw EngineException('unknown scene "$id"'));

  ItemDef requireItem(String id) =>
      items[id] ?? (throw EngineException('unknown item "$id"'));

  Puzzle requirePuzzle(String id) =>
      puzzles[id] ?? (throw EngineException('unknown puzzle "$id"'));

  Combination? combinationFor(String a, String b) {
    for (final c in combinations) {
      if (c.matches(a, b)) return c;
    }
    return null;
  }
}

Map<String, T> _indexById<T>(
  List<JsonReader> docs,
  T Function(JsonReader json) parse,
  String Function(T value) idOf,
) {
  final result = <String, T>{};
  for (final json in docs) {
    final value = parse(json);
    final id = idOf(value);
    if (result.containsKey(id)) json.fail('duplicate id "$id"', 'id');
    result[id] = value;
  }
  return result;
}
