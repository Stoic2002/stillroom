import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../content/content_strings.dart';
import '../core/services/hint_gate.dart';
import '../engine/engine.dart';
import 'content_providers.dart';
import 'save_repository.dart';
import 'services_providers.dart';

part 'game_session.g.dart';

/// A running episode: the engine, the saved [GameState], and transient
/// interaction state (selected item, examine view, open puzzle, queued text).
final class GameSessionState {
  const GameSessionState({
    required this.episode,
    required this.engine,
    required this.game,
    this.selectedItem,
    this.examinedItem,
    this.openPuzzle,
    this.texts = const [],
    this.events = const [],
    this.revision = 0,
  });

  final LoadedEpisode episode;
  final GameEngine engine;
  final GameState game;

  /// Inventory item the player picked to use or combine. Always held.
  final String? selectedItem;

  /// Item whose close-up view is open.
  final String? examinedItem;

  /// Puzzle whose screen is open.
  final String? openPuzzle;

  /// Text keys waiting to be shown; the first one is on screen.
  final List<String> texts;

  /// Events from the update that produced this state, to be played back
  /// once. Listeners compare [revision] to tell updates apart.
  final List<GameEvent> events;
  final int revision;

  String? get currentText => texts.firstOrNull;

  /// How word [wordId] reads in [languageCode].
  String wordLabel(String languageCode, String wordId) {
    final key = engine.content.config.words[wordId]?.labelKey;
    return key == null
        ? wordId
        : contentText(episode.strings, languageCode, key);
  }

  GameSessionState _next({
    GameState? game,
    String? Function()? selectedItem,
    String? Function()? examinedItem,
    String? Function()? openPuzzle,
    List<String>? texts,
    List<GameEvent> events = const [],
  }) {
    final nextGame = game ?? this.game;
    final selected = selectedItem != null ? selectedItem() : this.selectedItem;
    return GameSessionState(
      episode: episode,
      engine: engine,
      game: nextGame,
      // An item that left the inventory cannot stay selected.
      selectedItem: selected != null && nextGame.hasItem(selected)
          ? selected
          : null,
      examinedItem: examinedItem != null ? examinedItem() : this.examinedItem,
      openPuzzle: openPuzzle != null ? openPuzzle() : this.openPuzzle,
      texts: texts ?? this.texts,
      events: events,
      revision: revision + 1,
    );
  }
}

/// Wraps [GameEngine] for the UI and owns the interaction rules: what a tap
/// means depends on whether text is showing, a puzzle or examine view is
/// open, or an item is selected. Widgets and Flame components only send input here.
@riverpod
class GameSession extends _$GameSession {
  /// Resumes the episode from the save slot, or starts it fresh. Callers
  /// starting a new game clear the episode's save first
  /// ([SaveRepository.startNew]).
  @override
  Future<GameSessionState> build(String episodeId) async {
    final episode = await ref.watch(loadedEpisodeProvider(episodeId).future);
    final engine = GameEngine(episode.content);
    final saved = ref.read(saveRepositoryProvider).episode(episodeId);
    GameState game;
    try {
      game = saved == null || saved.completed
          ? engine.newGame()
          : engine.reconcile(saved);
    } on EngineException {
      game = engine.newGame();
    }
    return GameSessionState(episode: episode, engine: engine, game: game);
  }

  /// A tap on the scene at normalized coordinates. [minWidth]/[minHeight]
  /// are the minimum tap area, normalized (NFR-05).
  ///
  /// With an item selected, tapping a hotspot uses the item on it. A
  /// successful use clears the selection; a rejected one keeps it so the
  /// player can try elsewhere.
  void tapScene(
    double x,
    double y, {
    double minWidth = 0,
    double minHeight = 0,
  }) {
    final session = _ready;
    if (session == null) return;
    if (session.currentText != null ||
        session.examinedItem != null ||
        session.openPuzzle != null) {
      return;
    }
    final engine = session.engine;
    final hit = engine.hitTest(
      session.game,
      x,
      y,
      minWidth: minWidth,
      minHeight: minHeight,
    );
    switch (hit) {
      case HotspotHit(:final hotspot):
        final selected = session.selectedItem;
        if (selected == null) {
          _apply(session, engine.tapHotspot(session.game, hotspot.id));
        } else {
          final result = engine.useItemOnHotspot(
            session.game,
            hotspot.id,
            selected,
          );
          final rejected = result.events.any((e) => e is ItemRejectedEvent);
          _apply(session, result, selectedItem: rejected ? null : () => null);
        }
      case ExitHit(:final exit):
        _apply(session, engine.takeExit(session.game, exit.id));
      case null:
        break;
    }
  }

  void takeExit(String exitId) {
    final session = _ready;
    if (session == null ||
        session.currentText != null ||
        session.examinedItem != null ||
        session.openPuzzle != null) {
      return;
    }
    _apply(session, session.engine.takeExit(session.game, exitId));
  }

  /// A tap on an inventory slot: selects it, deselects it when already
  /// selected, or combines it with the selected item. A failed combination
  /// selects the tapped item instead.
  void tapInventoryItem(String itemId) {
    final session = _ready;
    if (session == null ||
        session.currentText != null ||
        session.openPuzzle != null) {
      return;
    }
    final selected = session.selectedItem;
    if (selected == null || selected == itemId) {
      state = AsyncData(
        session._next(selectedItem: () => selected == null ? itemId : null),
      );
      return;
    }
    final result = session.engine.combineItems(session.game, selected, itemId);
    final failed = result.events.any((e) => e is CombinationFailedEvent);
    _apply(session, result, selectedItem: () => failed ? itemId : null);
  }

  void deselectItem() {
    final session = _ready;
    if (session == null || session.selectedItem == null) return;
    state = AsyncData(session._next(selectedItem: () => null));
  }

  void examineItem(String itemId) {
    final session = _ready;
    if (session == null) return;
    session.engine.content.requireItem(itemId);
    state = AsyncData(session._next(examinedItem: () => itemId));
  }

  void closeExamine() {
    final session = _ready;
    if (session == null || session.examinedItem == null) return;
    state = AsyncData(session._next(examinedItem: () => null));
  }

  /// A tap inside the examine view, normalized to the examine image.
  void tapExamine(
    double x,
    double y, {
    double minWidth = 0,
    double minHeight = 0,
  }) {
    final session = _ready;
    final itemId = session?.examinedItem;
    if (session == null || itemId == null || session.currentText != null) {
      return;
    }
    final hotspot = session.engine.hitTestExamine(
      session.game,
      itemId,
      x,
      y,
      minWidth: minWidth,
      minHeight: minHeight,
    );
    if (hotspot == null) return;
    _apply(
      session,
      session.engine.tapExamineHotspot(session.game, itemId, hotspot.id),
    );
  }

  /// The puzzle screen reports the open puzzle as solved: marks it solved,
  /// runs its `onSolved`, and closes the screen.
  void solvePuzzle(String puzzleId) {
    final session = _ready;
    if (session == null || session.openPuzzle != puzzleId) return;
    final result = session.engine.solvePuzzle(session.game, puzzleId);
    _apply(session, result, openPuzzle: () => null);
  }

  void closePuzzle() {
    final session = _ready;
    if (session == null || session.openPuzzle == null) return;
    state = AsyncData(session._next(openPuzzle: () => null));
  }

  /// The hints relevant now: the open puzzle's, else the current stage's.
  HintGroup? currentHints() {
    final session = _ready;
    if (session == null) return null;
    return session.engine.hintGroup(session.game, puzzleId: session.openPuzzle);
  }

  /// Asks the [HintGate] for the next hint and reveals it when allowed.
  /// Returns whether a new hint was revealed.
  Future<bool> revealNextHint() async {
    final group = currentHints();
    if (group == null || !group.canRevealMore) return false;
    final allowed = await ref
        .read(hintGateProvider)
        .unlock(
          HintUnlockRequest(
            episodeId: episodeId,
            groupKey: group.key,
            level: group.revealed + 1,
          ),
        );
    final session = _ready;
    if (!allowed || session == null) return false;
    final game = session.engine.revealNextHint(session.game, group);
    if (game == session.game) return false;
    _autosave(game);
    state = AsyncData(session._next(game: game));
    return true;
  }

  /// Notes down a word the player tapped in a text (`[[id]]`). Works while
  /// the text is showing.
  void noteWord(String wordId) {
    final session = _ready;
    if (session == null) return;
    _apply(session, session.engine.noteWord(session.game, wordId));
  }

  /// Closes the text box on screen and shows the next queued one, if any.
  void dismissText() {
    final session = _ready;
    if (session == null || session.texts.isEmpty) return;
    state = AsyncData(session._next(texts: session.texts.sublist(1)));
  }

  /// Debug tool: jump straight to any scene.
  void debugJumpToScene(String sceneId) {
    final session = _ready;
    if (session == null) return;
    _apply(
      session,
      session.engine.runActions(session.game, [GoToSceneAction(sceneId)]),
    );
  }

  /// Debug tool: start the episode over.
  void debugRestart() {
    final session = _ready;
    if (session == null) return;
    final game = session.engine.newGame();
    _autosave(game);
    state = AsyncData(
      session._next(
        game: game,
        selectedItem: () => null,
        examinedItem: () => null,
        openPuzzle: () => null,
        texts: const [],
      ),
    );
  }

  GameSessionState? get _ready => state.value;

  /// Every change to [GameState] is meaningful (item, flag, puzzle, scene),
  /// so each one is saved (PRD FR-09).
  void _autosave(GameState game) =>
      ref.read(saveRepositoryProvider.notifier).saveEpisode(game);

  /// Applies an engine result and turns its presentation events into
  /// interaction state (queued text, examine view, puzzle screen).
  void _apply(
    GameSessionState session,
    EngineResult result, {
    String? Function()? selectedItem,
    String? Function()? openPuzzle,
  }) {
    if (identical(result.state, session.game) &&
        result.events.isEmpty &&
        selectedItem == null &&
        openPuzzle == null) {
      return;
    }
    final texts = [...session.texts];
    String? Function()? examined;
    var puzzle = openPuzzle;
    for (final event in result.events) {
      switch (event) {
        case ShowTextEvent(:final textKey):
          texts.add(textKey);
        case ExamineItemEvent(:final itemId):
          examined = () => itemId;
        case OpenPuzzleEvent(:final puzzleId):
          puzzle = () => puzzleId;
        case SecretFoundEvent(:final noteKey):
          ref
              .read(saveRepositoryProvider.notifier)
              .recordKeeperNote(episodeId, noteKey);
        default:
          break;
      }
    }
    if (result.state != session.game) _autosave(result.state);
    state = AsyncData(
      session._next(
        game: result.state,
        selectedItem: selectedItem,
        examinedItem: examined,
        openPuzzle: puzzle,
        texts: texts,
        events: result.events,
      ),
    );
  }
}
