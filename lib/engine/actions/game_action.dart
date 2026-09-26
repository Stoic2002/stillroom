import '../engine_exception.dart';
import '../game_event.dart';
import '../json/json_reader.dart';
import '../model/content_ref.dart';
import '../model/episode_content.dart';
import '../state/game_state.dart';

/// One step of an action list (`onTap`, `onSolved`, ...).
///
/// New action types implement this interface and register a parser in
/// [ActionRegistry]; the engine core does not change.
abstract interface class GameAction {
  /// The `type` value used in JSON.
  String get type;

  /// Everything this action points at, for the content validator.
  Iterable<ContentRef> get references;

  void apply(ActionContext context);
}

typedef ActionParser = GameAction Function(JsonReader json);

/// Maps JSON `type` values to action parsers.
final class ActionRegistry {
  ActionRegistry();

  final Map<String, ActionParser> _parsers = {};

  Iterable<String> get types => _parsers.keys;

  void register(String type, ActionParser parser) {
    if (_parsers.containsKey(type)) {
      throw ArgumentError.value(type, 'type', 'action type already registered');
    }
    _parsers[type] = parser;
  }

  GameAction parse(JsonReader json) {
    final type = json.string('type');
    final parser =
        _parsers[type] ?? json.fail('unknown action type "$type"', 'type');
    return parser(json);
  }

  /// Parses the optional action list at [key] of [parent].
  List<GameAction> parseList(JsonReader parent, String key) => [
    for (final a in parent.objects(key, optional: true)) parse(a),
  ];
}

/// Mutable workspace for one engine operation: actions read and update the
/// state here and emit presentation events.
final class ActionContext {
  ActionContext(this.content, this._state);

  final EpisodeContent content;
  GameState _state;
  final List<GameEvent> _events = [];

  GameState get state => _state;
  List<GameEvent> get events => List.unmodifiable(_events);

  void emit(GameEvent event) => _events.add(event);

  void update(GameState Function(GameState state) change) {
    _state = change(_state);
  }

  void run(List<GameAction> actions) {
    for (final action in actions) {
      action.apply(this);
    }
  }

  // Shared state operations used by built-in actions and the engine.

  void goToScene(String sceneId) {
    content.requireScene(sceneId);
    final from = _state.sceneId;
    if (from == sceneId) return;
    update((s) => s.copyWith(sceneId: sceneId));
    emit(SceneChangedEvent(from: from, to: sceneId));
  }

  void addItem(String itemId) {
    content.requireItem(itemId);
    if (_state.hasItem(itemId)) return;
    update(
      (s) => s.copyWith(
        inventory: [...s.inventory, itemId],
        everHadItems: {...s.everHadItems, itemId},
      ),
    );
    emit(ItemPickedEvent(itemId));
  }

  void removeItem(String itemId) {
    content.requireItem(itemId);
    if (!_state.hasItem(itemId)) return;
    update(
      (s) => s.copyWith(
        inventory: [
          for (final id in s.inventory)
            if (id != itemId) id,
        ],
      ),
    );
    emit(ItemRemovedEvent(itemId));
  }

  void setFlag(String flag, Object value) {
    final declared = content.config.flags[flag];
    if (declared == null) throw EngineException('undeclared flag "$flag"');
    if ((declared is bool) != (value is bool)) {
      throw EngineException(
        'flag "$flag" is ${declared is bool ? 'bool' : 'int'}, got $value',
      );
    }
    update((s) => s.copyWith(flags: {...s.flags, flag: value}));
  }

  void markPuzzleSolved(String puzzleId) {
    content.requirePuzzle(puzzleId);
    update((s) => s.copyWith(solvedPuzzles: {...s.solvedPuzzles, puzzleId}));
    emit(PuzzleSolvedEvent(puzzleId));
  }
}
