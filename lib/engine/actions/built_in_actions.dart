import '../game_event.dart';
import '../json/json_reader.dart';
import '../model/content_ref.dart';
import 'game_action.dart';

/// Registers the v1 action set (PRD FR-06) into [registry].
void registerBuiltInActions(ActionRegistry registry) {
  registry
    ..register(GoToSceneAction.typeName, GoToSceneAction.fromJson)
    ..register(PickItemAction.typeName, PickItemAction.fromJson)
    ..register(RemoveItemAction.typeName, RemoveItemAction.fromJson)
    ..register(SetFlagAction.typeName, SetFlagAction.fromJson)
    ..register(ShowTextAction.typeName, ShowTextAction.fromJson)
    ..register(OpenPuzzleAction.typeName, OpenPuzzleAction.fromJson)
    ..register(ExamineItemAction.typeName, ExamineItemAction.fromJson)
    ..register(PlaySoundAction.typeName, PlaySoundAction.fromJson)
    ..register(ShakeAction.typeName, ShakeAction.fromJson)
    ..register(EndEpisodeAction.typeName, EndEpisodeAction.fromJson);
}

/// `{ "type": "goToScene", "scene": "desk" }`
final class GoToSceneAction implements GameAction {
  const GoToSceneAction(this.sceneId);

  factory GoToSceneAction.fromJson(JsonReader json) {
    json.allowOnly({'type', 'scene'});
    return GoToSceneAction(json.string('scene'));
  }

  static const typeName = 'goToScene';

  final String sceneId;

  @override
  String get type => typeName;

  @override
  Iterable<ContentRef> get references => [ContentRef.scene(sceneId)];

  @override
  void apply(ActionContext context) => context.goToScene(sceneId);
}

/// `{ "type": "pickItem", "item": "small_key" }`. No-op if already held.
final class PickItemAction implements GameAction {
  const PickItemAction(this.itemId);

  factory PickItemAction.fromJson(JsonReader json) {
    json.allowOnly({'type', 'item'});
    return PickItemAction(json.string('item'));
  }

  static const typeName = 'pickItem';

  final String itemId;

  @override
  String get type => typeName;

  @override
  Iterable<ContentRef> get references => [ContentRef.item(itemId)];

  @override
  void apply(ActionContext context) => context.addItem(itemId);
}

/// `{ "type": "removeItem", "item": "small_key" }`. No-op if not held.
final class RemoveItemAction implements GameAction {
  const RemoveItemAction(this.itemId);

  factory RemoveItemAction.fromJson(JsonReader json) {
    json.allowOnly({'type', 'item'});
    return RemoveItemAction(json.string('item'));
  }

  static const typeName = 'removeItem';

  final String itemId;

  @override
  String get type => typeName;

  @override
  Iterable<ContentRef> get references => [ContentRef.item(itemId)];

  @override
  void apply(ActionContext context) => context.removeItem(itemId);
}

/// `{ "type": "setFlag", "flag": "drawer_open", "value": true }`
final class SetFlagAction implements GameAction {
  const SetFlagAction(this.flag, this.value);

  factory SetFlagAction.fromJson(JsonReader json) {
    json.allowOnly({'type', 'flag', 'value'});
    final value = json.value('value');
    if (value is! bool && value is! int) {
      json.fail('expected true, false, or an integer', 'value');
    }
    return SetFlagAction(json.string('flag'), value);
  }

  static const typeName = 'setFlag';

  final String flag;

  /// `bool` or `int`, matching the flag's declared type.
  final Object value;

  @override
  String get type => typeName;

  @override
  Iterable<ContentRef> get references => [ContentRef.flag(flag, value)];

  @override
  void apply(ActionContext context) => context.setFlag(flag, value);
}

/// `{ "type": "showText", "key": "desk.music_box.look" }`
final class ShowTextAction implements GameAction {
  const ShowTextAction(this.textKey);

  factory ShowTextAction.fromJson(JsonReader json) {
    json.allowOnly({'type', 'key'});
    return ShowTextAction(json.string('key'));
  }

  static const typeName = 'showText';

  final String textKey;

  @override
  String get type => typeName;

  @override
  Iterable<ContentRef> get references => [ContentRef.text(textKey)];

  @override
  void apply(ActionContext context) => context.emit(ShowTextEvent(textKey));
}

/// `{ "type": "openPuzzle", "puzzle": "drawer_lock" }`
final class OpenPuzzleAction implements GameAction {
  const OpenPuzzleAction(this.puzzleId);

  factory OpenPuzzleAction.fromJson(JsonReader json) {
    json.allowOnly({'type', 'puzzle'});
    return OpenPuzzleAction(json.string('puzzle'));
  }

  static const typeName = 'openPuzzle';

  final String puzzleId;

  @override
  String get type => typeName;

  @override
  Iterable<ContentRef> get references => [ContentRef.puzzle(puzzleId)];

  @override
  void apply(ActionContext context) {
    context.content.requirePuzzle(puzzleId);
    context.emit(OpenPuzzleEvent(puzzleId));
  }
}

/// `{ "type": "examineItem", "item": "music_box" }`
final class ExamineItemAction implements GameAction {
  const ExamineItemAction(this.itemId);

  factory ExamineItemAction.fromJson(JsonReader json) {
    json.allowOnly({'type', 'item'});
    return ExamineItemAction(json.string('item'));
  }

  static const typeName = 'examineItem';

  final String itemId;

  @override
  String get type => typeName;

  @override
  Iterable<ContentRef> get references => [ContentRef.item(itemId)];

  @override
  void apply(ActionContext context) {
    context.content.requireItem(itemId);
    context.emit(ExamineItemEvent(itemId));
  }
}

/// `{ "type": "playSound", "sound": "music_box" }`
final class PlaySoundAction implements GameAction {
  const PlaySoundAction(this.soundId);

  factory PlaySoundAction.fromJson(JsonReader json) {
    json.allowOnly({'type', 'sound'});
    return PlaySoundAction(json.string('sound'));
  }

  static const typeName = 'playSound';

  final String soundId;

  @override
  String get type => typeName;

  @override
  Iterable<ContentRef> get references => [ContentRef.sound(soundId)];

  @override
  void apply(ActionContext context) => context.emit(PlaySoundEvent(soundId));
}

/// `{ "type": "shake", "durationMs": 300, "strength": 0.5 }`. Both optional.
final class ShakeAction implements GameAction {
  const ShakeAction({
    this.durationMs = defaultDurationMs,
    this.strength = defaultStrength,
  });

  factory ShakeAction.fromJson(JsonReader json) {
    json.allowOnly({'type', 'durationMs', 'strength'});
    final durationMs = json.optionalInt('durationMs') ?? defaultDurationMs;
    if (durationMs <= 0) json.fail('must be > 0', 'durationMs');
    final strength = json.optionalNumber('strength') ?? defaultStrength;
    if (strength < 0 || strength > 1) {
      json.fail('must be within 0–1', 'strength');
    }
    return ShakeAction(durationMs: durationMs, strength: strength);
  }

  static const typeName = 'shake';
  static const defaultDurationMs = 300;
  static const defaultStrength = 0.5;

  final int durationMs;
  final double strength;

  @override
  String get type => typeName;

  @override
  Iterable<ContentRef> get references => const [];

  @override
  void apply(ActionContext context) =>
      context.emit(ShakeEvent(durationMs: durationMs, strength: strength));
}

/// `{ "type": "endEpisode" }`
final class EndEpisodeAction implements GameAction {
  const EndEpisodeAction();

  factory EndEpisodeAction.fromJson(JsonReader json) {
    json.allowOnly({'type'});
    return const EndEpisodeAction();
  }

  static const typeName = 'endEpisode';

  @override
  String get type => typeName;

  @override
  Iterable<ContentRef> get references => const [];

  @override
  void apply(ActionContext context) {
    context.update((s) => s.copyWith(completed: true));
    context.emit(const EpisodeEndedEvent());
  }
}
