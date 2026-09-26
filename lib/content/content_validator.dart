import '../engine/engine.dart';
import 'audio_paths.dart';
import 'content_loader.dart';

enum IssueSeverity {
  /// Broken content: the game may crash or misbehave.
  error,

  /// Allowed while content is unfinished, e.g. art not delivered yet
  /// (a placeholder is drawn instead).
  warning,
}

final class ContentIssue {
  const ContentIssue(this.severity, this.location, this.message);

  final IssueSeverity severity;

  /// Human-readable position, e.g. `scene desk › hotspot music_box › onTap[0]`.
  final String location;
  final String message;

  bool get isError => severity == IssueSeverity.error;

  @override
  String toString() => '[${severity.name}] $location: $message';
}

/// Thrown in debug builds when content has validation errors.
final class ContentValidationException implements Exception {
  const ContentValidationException(this.issues);

  final List<ContentIssue> issues;

  @override
  String toString() =>
      'ContentValidationException:\n${issues.map((i) => '  $i').join('\n')}';
}

/// Checks an episode for broken references (PRD §9):
///
/// - scenes, items, and puzzles that are referenced exist
/// - flags are declared, and compared/assigned values match their type
/// - every text key exists in every language, and all languages have the
///   same keys
/// - every `rect` lies within 0–1
/// - words: marked words (`[[id]]`) are declared and marked in every
///   language alike; deduction texts hold their placeholders; every answer
///   of a deduction can be noted somewhere
/// - images and sounds exist (missing ones are warnings: placeholders are used)
///
/// [assets] are full asset paths (`assets/...`).
List<ContentIssue> validateEpisode(
  EpisodeContent content, {
  required Set<String> assets,
  required StringTables strings,
}) => _Validator(content, assets, strings).run();

final class _Validator {
  _Validator(this.content, this.assets, this.strings);

  final EpisodeContent content;
  final Set<String> assets;
  final StringTables strings;
  final List<ContentIssue> issues = [];

  /// Words marked in the texts this episode shows.
  final Set<String> _notable = {};

  List<ContentIssue> run() {
    final episode = 'episode ${content.id}';
    if (!content.scenes.containsKey(content.config.startScene)) {
      _error(
        '$episode › game.json',
        'startScene "${content.config.startScene}" does not exist',
      );
    }
    if (strings.isEmpty) _error(episode, 'no content string tables found');
    if (content.config.music case final music?) {
      _ref('$episode › game.json', ContentRef.music(music));
    }
    for (final stage in content.config.hintStages) {
      final at = 'game.json › hintStages ${stage.id}';
      _conditions(at, stage.when);
      for (final (i, hint) in stage.hints.indexed) {
        _ref('$at › hints[$i]', ContentRef.text(hint.textKey));
        _conditions('$at › hints[$i]', hint.when);
      }
    }
    _checkStringTablesMatch();
    for (final word in content.config.words.values) {
      _ref('game.json › words ${word.id}', ContentRef.text(word.labelKey));
    }
    if (content.config.secret case final secret?) {
      for (final ref in secret.references) {
        _ref('game.json › secret', ref);
      }
    }

    for (final scene in content.scenes.values) {
      final at = 'scene ${scene.id}';
      _ref(at, ContentRef.image(scene.background));
      if (scene.music case final music?) _ref(at, ContentRef.music(music));
      for (final exit in scene.exits) {
        final exitAt = '$at › exit ${exit.id}';
        _ref(exitAt, ContentRef.scene(exit.to));
        if (exit.rect case final rect?) _rect(exitAt, rect);
        _conditions(exitAt, exit.when);
      }
      for (final hotspot in scene.hotspots) {
        _hotspot('$at › hotspot ${hotspot.id}', hotspot);
      }
      for (final layer in scene.layers) {
        _layer('$at › layer ${layer.id}', layer);
      }
      if (scene.dark case final dark?) _conditions('$at › dark', dark.when);
      for (final creature in scene.creatures) {
        final creatureAt = '$at › creature ${creature.id}';
        _rect(creatureAt, creature.rect);
        _conditions(creatureAt, creature.when);
      }
      for (final echo in scene.echoes) {
        final echoAt = '$at › echo ${echo.id}';
        _ref(echoAt, ContentRef.image(echo.image));
        _rect(echoAt, echo.rect);
        _conditions(echoAt, echo.when);
      }
    }

    for (final item in content.items.values) {
      final at = 'item ${item.id}';
      _ref(at, ContentRef.text(item.nameKey));
      _ref(at, ContentRef.text(item.descKey));
      _ref(at, ContentRef.image(item.icon));
      if (item.examine case final examine?) {
        _ref('$at › examine', ContentRef.image(examine.image));
        for (final hotspot in examine.hotspots) {
          _hotspot('$at › examine › hotspot ${hotspot.id}', hotspot);
        }
        for (final layer in examine.layers) {
          _layer('$at › examine › layer ${layer.id}', layer);
        }
      }
    }

    for (final (i, c) in content.combinations.indexed) {
      final at = 'items.json › combinations[$i]';
      for (final id in [c.a, c.b, c.result]) {
        _ref(at, ContentRef.item(id));
      }
    }

    for (final puzzle in content.puzzles.values) {
      final at = 'puzzle ${puzzle.id}';
      if (puzzle.background case final background?) {
        _ref(at, ContentRef.image(background));
      }
      for (final ref in puzzle.config.references) {
        _ref('$at › config', ref);
      }
      _actions('$at › onSolved', puzzle.onSolved);
      for (final (i, hint) in puzzle.hints.indexed) {
        _ref('$at › hints[$i]', ContentRef.text(hint.textKey));
        _conditions('$at › hints[$i]', hint.when);
      }
    }
    _checkWordsNotable();
    return issues;
  }

  /// A deduction is unsolvable if one of its answers can never be noted.
  void _checkWordsNotable() {
    final answers = {
      for (final p in content.puzzles.values)
        if (p.config case final DeductionConfig c) ...c.answers,
    };
    for (final word in content.config.words.values) {
      if (word.given || _notable.contains(word.id)) continue;
      const why = 'is neither given nor marked [[id]] in any text';
      if (answers.contains(word.id)) {
        _error('game.json › words ${word.id}', 'a deduction answer that $why');
      } else {
        _warning('game.json › words ${word.id}', 'word $why');
      }
    }
  }

  /// Marked words of text [key] exist and are the same in every language.
  void _markup(String at, String key) {
    Set<String>? first;
    for (final MapEntry(key: locale, value: table) in strings.entries) {
      final text = table[key];
      if (text == null) continue;
      final marked = markedWords(text);
      for (final id in marked) {
        if (!content.config.words.containsKey(id)) {
          _error(at, 'text "$key" ($locale) marks unknown word "$id"');
        }
      }
      _notable.addAll(marked);
      if (first == null) {
        first = marked;
      } else if (!_sameSet(first, marked)) {
        _error(
          at,
          'text "$key" marks different words in $locale '
          '(${marked.join(', ')}) than in other languages (${first.join(', ')})',
        );
      }
    }
  }

  void _template(String at, ContentRef ref) {
    final slots = ref.slots ?? 0;
    final placeholder = RegExp(r'\{(\d+)\}');
    for (final MapEntry(key: locale, value: table) in strings.entries) {
      final text = table[ref.id];
      if (text == null || text.startsWith('TODO_TEXT')) continue;
      final found = [
        for (final m in placeholder.allMatches(text)) int.parse(m.group(1)!),
      ]..sort();
      final expected = [for (var i = 1; i <= slots; i++) i];
      if (found.join(',') != expected.join(',')) {
        _error(
          at,
          'text "${ref.id}" ($locale) must hold {1}…{$slots} once each; '
          'has ${found.map((n) => '{$n}').join(' ')}',
        );
      }
    }
  }

  static bool _sameSet(Set<String> a, Set<String> b) =>
      a.length == b.length && a.containsAll(b);

  void _hotspot(String at, Hotspot hotspot) {
    _rect(at, hotspot.rect);
    _conditions(at, hotspot.when);
    _actions('$at › onTap', hotspot.onTap);
    for (final use in hotspot.onUseItem) {
      final useAt = '$at › onUseItem ${use.itemId}';
      _ref(useAt, ContentRef.item(use.itemId));
      _actions(useAt, use.actions);
    }
  }

  void _layer(String at, SceneLayer layer) {
    _ref(at, ContentRef.image(layer.image));
    _rect(at, layer.rect);
    _conditions(at, layer.when);
  }

  void _conditions(String at, List<Condition> conditions) {
    for (final (i, c) in conditions.indexed) {
      _ref('$at › when[$i]', c.reference);
    }
  }

  void _actions(String at, List<GameAction> actions) {
    for (final (i, action) in actions.indexed) {
      for (final ref in action.references) {
        _ref('$at[$i] ${action.type}', ref);
      }
    }
  }

  void _rect(String at, NormalizedRect rect) {
    if (!rect.isWithinUnit) _error(at, 'rect $rect is outside 0–1');
  }

  void _ref(String at, ContentRef ref) {
    switch (ref.kind) {
      case RefKind.scene:
        if (!content.scenes.containsKey(ref.id)) {
          _error(at, 'unknown scene "${ref.id}"');
        }
      case RefKind.item:
        if (!content.items.containsKey(ref.id)) {
          _error(at, 'unknown item "${ref.id}"');
        }
      case RefKind.puzzle:
        if (!content.puzzles.containsKey(ref.id)) {
          _error(at, 'unknown puzzle "${ref.id}"');
        }
      case RefKind.flag:
        _flag(at, ref);
      case RefKind.word:
        if (!content.config.words.containsKey(ref.id)) {
          _error(at, 'unknown word "${ref.id}"');
        }
      case RefKind.template:
        _ref(at, ContentRef.text(ref.id));
        _template(at, ref);
      case RefKind.text:
        _markup(at, ref.id);
        final missing = [
          for (final MapEntry(key: locale, value: table) in strings.entries)
            if (!table.containsKey(ref.id)) locale,
        ];
        if (missing.isNotEmpty) {
          _error(at, 'text key "${ref.id}" missing in ${missing.join(', ')}');
        }
      case RefKind.image:
        if (!assets.contains('assets/${ref.id}')) {
          _warning(at, 'image "${ref.id}" not found; placeholder is drawn');
        }
      case RefKind.sound:
        if (resolveSfx(ref.id, assets) == null) {
          _warning(
            at,
            'sound "${ref.id}" not found '
            '(${sfxAssetPath(ref.id, '{${audioExtensions.join(',')}}')}); '
            'plays silently',
          );
        }
      case RefKind.music:
        if (resolveMusic(ref.id, assets) == null) {
          _warning(
            at,
            'music "${ref.id}" not found '
            '(${musicAssetPath(ref.id, '{${audioExtensions.join(',')}}')}); '
            'plays silently',
          );
        }
    }
  }

  void _flag(String at, ContentRef ref) {
    final declared = content.config.flags[ref.id];
    if (declared == null) {
      _error(at, 'flag "${ref.id}" is not declared in game.json');
      return;
    }
    final value = ref.flagValue;
    if (value != null && (declared is bool) != (value is bool)) {
      _error(
        at,
        'flag "${ref.id}" is ${declared is bool ? 'bool' : 'int'} '
        'but is used with $value',
      );
    }
  }

  void _checkStringTablesMatch() {
    final allKeys = {for (final table in strings.values) ...table.keys};
    for (final MapEntry(key: locale, value: table) in strings.entries) {
      final missing = allKeys.difference(table.keys.toSet()).toList()..sort();
      if (missing.isNotEmpty) {
        _error(
          'strings/$locale.json',
          'missing keys present in other languages: ${missing.join(', ')}',
        );
      }
    }
  }

  void _error(String at, String message) =>
      issues.add(ContentIssue(IssueSeverity.error, at, message));

  void _warning(String at, String message) =>
      issues.add(ContentIssue(IssueSeverity.warning, at, message));
}
