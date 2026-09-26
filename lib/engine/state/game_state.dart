import 'package:freezed_annotation/freezed_annotation.dart';

part 'game_state.freezed.dart';
part 'game_state.g.dart';

/// Progress within one episode. Everything here is persisted in the save.
///
/// Transient interaction state (selected inventory item, open overlays) is not
/// part of [GameState]; it belongs to the presentation layer.
@freezed
abstract class GameState with _$GameState {
  const factory GameState({
    required String episodeId,
    required String sceneId,

    /// Items currently held, in pickup order. Never contains duplicates.
    @Default(<String>[]) List<String> inventory,

    /// Every item that has ever been picked up, including ones since removed
    /// or combined. Lets content hide a pickup spot for good.
    @Default(<String>{}) Set<String> everHadItems,

    /// Current value of every declared flag. Values are `bool` or `int`.
    @Default(<String, Object>{}) Map<String, Object> flags,
    @Default(<String>{}) Set<String> solvedPuzzles,

    /// How many hints the player has revealed per hint group
    /// ([HintGroup.key]).
    @Default(<String, int>{}) Map<String, int> revealedHints,

    /// Words the player has noted down ([WordDef] ids).
    @Default(<String>{}) Set<String> words,

    /// Whether the episode's secret has been found.
    @Default(false) bool secretFound,
    @Default(false) bool completed,
  }) = _GameState;

  const GameState._();

  factory GameState.fromJson(Map<String, dynamic> json) =>
      _$GameStateFromJson(json);

  bool hasItem(String itemId) => inventory.contains(itemId);
}
