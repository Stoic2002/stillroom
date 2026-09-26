import 'actions/game_action.dart';
import 'engine_exception.dart';
import 'game_event.dart';
import 'model/condition.dart';
import 'model/episode_content.dart';
import 'model/item.dart';
import 'model/normalized_rect.dart';
import 'model/puzzle.dart';
import 'model/scene.dart';
import 'state/game_state.dart';

/// The state after an engine operation, plus the effects to present.
final class EngineResult {
  const EngineResult(this.state, [this.events = const []]);

  final GameState state;
  final List<GameEvent> events;
}

/// The hints on offer for one puzzle or one episode stage.
final class HintGroup {
  const HintGroup({
    required this.key,
    required this.available,
    required this.revealed,
  });

  /// Key in [GameState.revealedHints]: `puzzle:<id>` or `stage:<id>`.
  final String key;

  /// Hints whose conditions are met, in order.
  final List<Hint> available;

  /// How many of [available] the player has revealed.
  final int revealed;

  List<Hint> get shown => available.take(revealed).toList();

  bool get canRevealMore => revealed < available.length;
}

/// What sits under a tap point in the current scene.
sealed class HitTarget {
  const HitTarget();
}

final class HotspotHit extends HitTarget {
  const HotspotHit(this.hotspot);

  final Hotspot hotspot;
}

final class ExitHit extends HitTarget {
  const ExitHit(this.exit);

  final SceneExit exit;
}

/// Pure game rules for one episode. Every operation takes a [GameState] and
/// returns a new one; nothing is mutated and nothing is rendered.
///
/// Tapping something that is currently hidden (its `when` is not met) is a
/// no-op, because the presentation may lag one frame behind the state.
/// Referring to ids that do not exist at all throws [EngineException].
final class GameEngine {
  const GameEngine(this.content);

  final EpisodeContent content;

  GameState newGame() {
    content.requireScene(content.config.startScene);
    return GameState(
      episodeId: content.id,
      sceneId: content.config.startScene,
      flags: content.config.flags,
      words: _givenWords,
    );
  }

  Set<String> get _givenWords => {
    for (final w in content.config.words.values)
      if (w.given) w.id,
  };

  /// Adapts a loaded save to the current content, so a content update never
  /// leaves the state pointing at things that no longer exist: unknown ids are
  /// dropped, new flags get their defaults, and flags whose type changed are
  /// reset.
  GameState reconcile(GameState saved) {
    if (saved.episodeId != content.id) {
      throw EngineException(
        'save belongs to episode "${saved.episodeId}", not "${content.id}"',
      );
    }
    return saved.copyWith(
      sceneId: content.scenes.containsKey(saved.sceneId)
          ? saved.sceneId
          : content.config.startScene,
      inventory: saved.inventory.where(content.items.containsKey).toList(),
      everHadItems: saved.everHadItems.where(content.items.containsKey).toSet(),
      flags: {
        for (final MapEntry(key: name, value: fallback)
            in content.config.flags.entries)
          name: switch (saved.flags[name]) {
            final bool v when fallback is bool => v,
            final int v when fallback is int => v,
            _ => fallback,
          },
      },
      solvedPuzzles: saved.solvedPuzzles
          .where(content.puzzles.containsKey)
          .toSet(),
      revealedHints: {
        for (final MapEntry(:key, :value) in saved.revealedHints.entries)
          if (_hintGroupExists(key)) key: value,
      },
      words: {
        ...saved.words.where(content.config.words.containsKey),
        ..._givenWords,
      },
    );
  }

  bool _hintGroupExists(String key) {
    if (key.startsWith('puzzle:')) {
      return content.puzzles.containsKey(key.substring('puzzle:'.length));
    }
    final stage = key.startsWith('stage:')
        ? key.substring('stage:'.length)
        : null;
    return content.config.hintStages.any((s) => s.id == stage);
  }

  Scene currentScene(GameState state) => content.requireScene(state.sceneId);

  List<ItemDef> inventoryItems(GameState state) => [
    for (final id in state.inventory) content.requireItem(id),
  ];

  List<Hotspot> visibleHotspots(GameState state) => [
    for (final h in currentScene(state).hotspots)
      if (h.when.allMet(state)) h,
  ];

  List<SceneExit> visibleExits(GameState state) => [
    for (final e in currentScene(state).exits)
      if (e.when.allMet(state)) e,
  ];

  /// The darkness of the current scene, if it is dark right now.
  SceneDarkness? darkness(GameState state) {
    final dark = currentScene(state).dark;
    return dark != null && dark.when.allMet(state) ? dark : null;
  }

  /// Echoes that may appear in the current scene right now.
  List<SceneEcho> possibleEchoes(GameState state) => [
    for (final e in currentScene(state).echoes)
      if (e.when.allMet(state)) e,
  ];

  List<SceneLayer> visibleLayers(GameState state) => [
    for (final l in currentScene(state).layers)
      if (l.when.allMet(state)) l,
  ];

  /// Finds what is under the normalized point ([x], [y]) in the current
  /// scene. Hotspots win over exit areas; among hotspots the last one listed
  /// (topmost) wins.
  ///
  /// Areas smaller than [minWidth] × [minHeight] (normalized) are grown
  /// around their center for hit testing, so small objects stay tappable on
  /// small screens (NFR-05).
  HitTarget? hitTest(
    GameState state,
    double x,
    double y, {
    double minWidth = 0,
    double minHeight = 0,
  }) {
    bool hits(NormalizedRect rect) =>
        rect.expandedTo(minWidth, minHeight).contains(x, y);
    for (final h in visibleHotspots(state).reversed) {
      if (hits(h.rect)) return HotspotHit(h);
    }
    for (final e in visibleExits(state).reversed) {
      final rect = e.rect;
      if (rect != null && hits(rect)) return ExitHit(e);
    }
    return null;
  }

  EngineResult tapHotspot(GameState state, String hotspotId) {
    final hotspot = _sceneHotspot(state, hotspotId);
    if (!hotspot.when.allMet(state)) return EngineResult(state);
    return runActions(state, hotspot.onTap);
  }

  /// Uses held item [itemId] on a hotspot in the current scene. Emits
  /// [ItemRejectedEvent] when the hotspot does not accept that item.
  EngineResult useItemOnHotspot(
    GameState state,
    String hotspotId,
    String itemId,
  ) {
    final hotspot = _sceneHotspot(state, hotspotId);
    _requireHeld(state, itemId);
    if (!hotspot.when.allMet(state)) return EngineResult(state);
    final use = hotspot.useFor(itemId);
    if (use == null) {
      return EngineResult(state, [
        ItemRejectedEvent(hotspotId: hotspotId, itemId: itemId),
      ]);
    }
    return runActions(state, use.actions);
  }

  /// Taps a hotspot inside the examine view of item [itemId].
  EngineResult tapExamineHotspot(
    GameState state,
    String itemId,
    String hotspotId,
  ) {
    final examine =
        content.requireItem(itemId).examine ??
        (throw EngineException('item "$itemId" has no examine view'));
    final hotspot =
        examine.hotspot(hotspotId) ??
        (throw EngineException(
          'unknown hotspot "$hotspotId" on item "$itemId"',
        ));
    if (!hotspot.when.allMet(state)) return EngineResult(state);
    return runActions(state, hotspot.onTap);
  }

  List<Hotspot> visibleExamineHotspots(GameState state, String itemId) => [
    for (final h
        in content.requireItem(itemId).examine?.hotspots ?? const <Hotspot>[])
      if (h.when.allMet(state)) h,
  ];

  List<SceneLayer> visibleExamineLayers(GameState state, String itemId) => [
    for (final l
        in content.requireItem(itemId).examine?.layers ?? const <SceneLayer>[])
      if (l.when.allMet(state)) l,
  ];

  /// Like [hitTest], for the examine view of [itemId]: the topmost visible
  /// hotspot under the normalized point, or `null`.
  Hotspot? hitTestExamine(
    GameState state,
    String itemId,
    double x,
    double y, {
    double minWidth = 0,
    double minHeight = 0,
  }) {
    for (final h in visibleExamineHotspots(state, itemId).reversed) {
      if (h.rect.expandedTo(minWidth, minHeight).contains(x, y)) return h;
    }
    return null;
  }

  EngineResult takeExit(GameState state, String exitId) {
    final exit =
        currentScene(state).exit(exitId) ??
        (throw EngineException(
          'unknown exit "$exitId" in scene "${state.sceneId}"',
        ));
    if (!exit.when.allMet(state)) return EngineResult(state);
    return _finish(ActionContext(content, state)..goToScene(exit.to));
  }

  /// Combines two held items. Emits [CombinationFailedEvent] when no
  /// combination matches.
  EngineResult combineItems(GameState state, String first, String second) {
    _requireHeld(state, first);
    _requireHeld(state, second);
    final combination = first == second
        ? null
        : content.combinationFor(first, second);
    if (combination == null) {
      return EngineResult(state, [
        CombinationFailedEvent(first: first, second: second),
      ]);
    }
    final context = ActionContext(content, state)
      ..removeItem(first)
      ..removeItem(second)
      ..addItem(combination.result)
      ..emit(
        ItemsCombinedEvent(
          first: first,
          second: second,
          result: combination.result,
        ),
      );
    return _finish(context);
  }

  /// Marks a puzzle solved and runs its `onSolved`. Solving an already solved
  /// puzzle does nothing, so `onSolved` runs at most once.
  EngineResult solvePuzzle(GameState state, String puzzleId) {
    final puzzle = content.requirePuzzle(puzzleId);
    if (state.solvedPuzzles.contains(puzzleId)) return EngineResult(state);
    final context = ActionContext(content, state)
      ..markPuzzleSolved(puzzleId)
      ..run(puzzle.onSolved);
    return _finish(context);
  }

  /// Notes down word [wordId] (tapped in a text). Noting a word twice does
  /// nothing.
  EngineResult noteWord(GameState state, String wordId) {
    if (!content.config.words.containsKey(wordId)) {
      throw EngineException('unknown word "$wordId"');
    }
    if (state.words.contains(wordId)) return EngineResult(state);
    final context = ActionContext(content, state)
      ..update((s) => s.copyWith(words: {...s.words, wordId}))
      ..emit(WordNotedEvent(wordId));
    return _finish(context);
  }

  /// Hints currently offered for [puzzleId], in order.
  List<Hint> availableHints(GameState state, String puzzleId) => [
    for (final h in content.requirePuzzle(puzzleId).hints)
      if (h.when.allMet(state)) h,
  ];

  /// The hints relevant right now: those of [puzzleId] when a puzzle is
  /// open, otherwise those of the current episode stage (the first
  /// `hintStages` entry whose `when` is met). `null` when there are none.
  HintGroup? hintGroup(GameState state, {String? puzzleId}) {
    final String key;
    final List<Hint> hints;
    if (puzzleId != null) {
      key = 'puzzle:$puzzleId';
      hints = content.requirePuzzle(puzzleId).hints;
    } else {
      final stage = content.config.hintStages
          .where((s) => s.when.allMet(state))
          .firstOrNull;
      if (stage == null) return null;
      key = 'stage:${stage.id}';
      hints = stage.hints;
    }
    final available = [
      for (final h in hints)
        if (h.when.allMet(state)) h,
    ];
    if (available.isEmpty) return null;
    final revealed = state.revealedHints[key] ?? 0;
    return HintGroup(
      key: key,
      available: available,
      revealed: revealed.clamp(0, available.length),
    );
  }

  /// Reveals the next hint of [group]. No-op when all are shown.
  GameState revealNextHint(GameState state, HintGroup group) {
    if (!group.canRevealMore) return state;
    return state.copyWith(
      revealedHints: {...state.revealedHints, group.key: group.revealed + 1},
    );
  }

  /// Music id for the current scene: its own, else the episode's.
  String? currentMusic(GameState state) =>
      currentScene(state).music ?? content.config.music;

  /// Runs an arbitrary action list, e.g. from debug tools.
  EngineResult runActions(GameState state, List<GameAction> actions) =>
      _finish(ActionContext(content, state)..run(actions));

  /// Ends an operation: finds the secret the moment its conditions hold.
  EngineResult _finish(ActionContext context) {
    final secret = content.config.secret;
    if (secret != null &&
        !context.state.secretFound &&
        secret.when.allMet(context.state)) {
      context
        ..update((s) => s.copyWith(secretFound: true))
        ..emit(SecretFoundEvent(secret.noteKey));
    }
    return EngineResult(context.state, context.events);
  }

  Hotspot _sceneHotspot(GameState state, String hotspotId) =>
      currentScene(state).hotspot(hotspotId) ??
      (throw EngineException(
        'unknown hotspot "$hotspotId" in scene "${state.sceneId}"',
      ));

  void _requireHeld(GameState state, String itemId) {
    content.requireItem(itemId);
    if (!state.hasItem(itemId)) {
      throw EngineException('item "$itemId" is not in the inventory');
    }
  }
}
