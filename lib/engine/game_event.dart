/// Effects the engine asks the presentation layer to perform.
///
/// The engine applies all state changes immediately and returns events in the
/// order they happened; the presentation layer plays them back in that order
/// (e.g. queueing text boxes). Custom actions may define their own events by
/// extending [GameEvent].
library;

abstract class GameEvent {
  const GameEvent();
}

final class SceneChangedEvent extends GameEvent {
  const SceneChangedEvent({required this.from, required this.to});

  final String from;
  final String to;
}

final class ItemPickedEvent extends GameEvent {
  const ItemPickedEvent(this.itemId);

  final String itemId;
}

final class ItemRemovedEvent extends GameEvent {
  const ItemRemovedEvent(this.itemId);

  final String itemId;
}

final class ItemsCombinedEvent extends GameEvent {
  const ItemsCombinedEvent({
    required this.first,
    required this.second,
    required this.result,
  });

  final String first;
  final String second;
  final String result;
}

/// Two items were combined but no combination exists for them.
final class CombinationFailedEvent extends GameEvent {
  const CombinationFailedEvent({required this.first, required this.second});

  final String first;
  final String second;
}

/// An item was used on a hotspot that has no `onUseItem` entry for it.
final class ItemRejectedEvent extends GameEvent {
  const ItemRejectedEvent({required this.hotspotId, required this.itemId});

  final String hotspotId;
  final String itemId;
}

final class ShowTextEvent extends GameEvent {
  const ShowTextEvent(this.textKey);

  final String textKey;
}

final class OpenPuzzleEvent extends GameEvent {
  const OpenPuzzleEvent(this.puzzleId);

  final String puzzleId;
}

final class PuzzleSolvedEvent extends GameEvent {
  const PuzzleSolvedEvent(this.puzzleId);

  final String puzzleId;
}

final class ExamineItemEvent extends GameEvent {
  const ExamineItemEvent(this.itemId);

  final String itemId;
}

final class PlaySoundEvent extends GameEvent {
  const PlaySoundEvent(this.soundId);

  final String soundId;
}

final class ShakeEvent extends GameEvent {
  const ShakeEvent({required this.durationMs, required this.strength});

  final int durationMs;

  /// 0–1, scaled by the presentation layer.
  final double strength;
}

final class EpisodeEndedEvent extends GameEvent {
  const EpisodeEndedEvent();
}
