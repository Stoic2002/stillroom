import '../json/json_reader.dart';
import 'condition.dart';
import 'puzzle.dart';
import 'word.dart';

enum ScreenOrientation { landscape, portrait }

/// Episode-wide declarations from `game.json`.
final class GameConfig {
  const GameConfig({
    required this.startScene,
    required this.flags,
    required this.logicalWidth,
    required this.logicalHeight,
    this.orientation = ScreenOrientation.landscape,
    this.sceneTransitionMs = defaultSceneTransitionMs,
    this.music,
    this.hintStages = const [],
    this.words = const {},
    this.secret,
    this.lensHours,
  });

  factory GameConfig.fromJson(JsonReader json) {
    json.allowOnly({
      'startScene',
      'flags',
      'logicalResolution',
      'orientation',
      'sceneTransitionMs',
      'music',
      'hintStages',
      'words',
      'secret',
      'lensHours',
    });
    final flagsJson = json.object('flags');
    final flags = <String, Object>{};
    for (final MapEntry(:key, :value) in flagsJson.json.entries) {
      flags[key] = switch (value) {
        final bool v => v,
        final int v => v,
        _ => flagsJson.fail(
          'flag default must be true, false, or an integer',
          key,
        ),
      };
    }
    final resolution = json.numbers('logicalResolution', length: 2);
    if (resolution.any((v) => v <= 0 || v != v.roundToDouble())) {
      json.fail('expected two positive integers', 'logicalResolution');
    }
    final orientationName = json.optionalString('orientation');
    final orientation = orientationName == null
        ? ScreenOrientation.landscape
        : ScreenOrientation.values.asNameMap()[orientationName] ??
              json.fail('expected landscape or portrait', 'orientation');
    final transitionMs =
        json.optionalInt('sceneTransitionMs') ?? defaultSceneTransitionMs;
    if (transitionMs < 0) json.fail('must be >= 0', 'sceneTransitionMs');
    final stages = [
      for (final s in json.objects('hintStages', optional: true))
        HintStage.fromJson(s),
    ];
    final stageIds = <String>{};
    for (final s in stages) {
      if (!stageIds.add(s.id)) {
        json.fail('duplicate id "${s.id}"', 'hintStages');
      }
    }
    final words = <String, WordDef>{};
    for (final w in json.objects('words', optional: true)) {
      final word = WordDef.fromJson(w);
      if (words.containsKey(word.id)) {
        json.fail('duplicate id "${word.id}"', 'words');
      }
      words[word.id] = word;
    }
    final secret = json.optionalObject('secret');
    final lensHours = json.optionalObject('lensHours');
    return GameConfig(
      startScene: json.string('startScene'),
      flags: Map.unmodifiable(flags),
      logicalWidth: resolution[0].toInt(),
      logicalHeight: resolution[1].toInt(),
      orientation: orientation,
      sceneTransitionMs: transitionMs,
      music: json.optionalString('music'),
      hintStages: List.unmodifiable(stages),
      words: Map.unmodifiable(words),
      secret: secret == null ? null : SecretDef.fromJson(secret),
      lensHours: lensHours == null ? null : LensHours.fromJson(lensHours),
    );
  }

  final String startScene;

  /// Every flag the episode uses, with its default value (`bool` or `int`).
  final Map<String, Object> flags;
  final int logicalWidth;
  final int logicalHeight;
  final ScreenOrientation orientation;

  /// Total fade time between scenes (out + in). 0 switches instantly.
  final int sceneTransitionMs;

  static const defaultSceneTransitionMs = 400;

  /// Background music id for the episode (`audio/music/<id>.<ext>`); scenes
  /// may override it.
  final String? music;

  /// Hints outside puzzles, by stage of the episode. The first stage whose
  /// `when` is met is the current one.
  final List<HintStage> hintStages;

  /// Words the player can note down, by id, in declaration order.
  final Map<String, WordDef> words;

  /// The episode's optional secret.
  final SecretDef? secret;

  /// The hours a lens between eras can be turned to, if any.
  final LensHours? lensHours;
}

/// The hours of the other era a lens can look at (`lensHours` in
/// `game.json`):
///
/// ```json
/// "lensHours": { "flag": "lens_hour",
///   "labels": ["pompeii_79.hour.morning", "pompeii_79.hour.noon"] }
/// ```
/// The int `flag` holds the hour the lens is turned to (0 = the first
/// label), so conditions can use it; turning the lens moves it on, round
/// to the first again.
final class LensHours {
  const LensHours({required this.flag, required this.labels});

  factory LensHours.fromJson(JsonReader json) {
    json.allowOnly({'flag', 'labels'});
    final labels = json.strings('labels');
    if (labels.length < 2) json.fail('need at least two hours', 'labels');
    return LensHours(
      flag: json.string('flag'),
      labels: List.unmodifiable(labels),
    );
  }

  final String flag;

  /// Text keys naming each hour, in order.
  final List<String> labels;
}

/// A step of the episode with its own hints (PRD FR-08: "tahap").
final class HintStage {
  const HintStage({
    required this.id,
    required this.hints,
    this.when = const [],
  });

  factory HintStage.fromJson(JsonReader json) {
    json.allowOnly({'id', 'when', 'hints'});
    final hints = [for (final h in json.objects('hints')) Hint.fromJson(h)];
    if (hints.isEmpty) json.fail('need at least one hint', 'hints');
    if (hints.length > Puzzle.maxHints) {
      json.fail('at most ${Puzzle.maxHints} hints', 'hints');
    }
    return HintStage(
      id: json.string('id'),
      when: Condition.listFromJson(json, 'when'),
      hints: hints,
    );
  }

  final String id;
  final List<Condition> when;

  /// Ordered vague → explicit → solution.
  final List<Hint> hints;
}
