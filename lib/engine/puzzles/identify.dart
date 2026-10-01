import '../json/json_reader.dart';
import '../model/content_ref.dart';
import 'puzzle_type.dart';

/// `identify`: a specimen and a key to name it. The key is a tree of
/// couplets: two statements, of which the player picks the one true of the
/// specimen. Each statement leads to another couplet or to a name. A name
/// other than the answer is a wrong end: a mistake, and the key goes back
/// to the couplet where the path left the answer's.
///
/// ```json
/// "config": {
///   "start": "pores",
///   "couplets": [
///     { "id": "pores", "choices": [
///       { "textKey": "ep.key.pores", "to": "scent" },
///       { "textKey": "ep.key.no_pores", "to": "cedar" } ] }
///   ],
///   "names": [
///     { "id": "cedar", "nameKey": "ep.key.cedar", "noteKey": "ep.key.cedar_note" }
///   ],
///   "answer": "tambootie"
/// }
/// ```
/// Every couplet has exactly two choices; every couplet and name is
/// reached from `start` exactly once (a tree, no loops); couplet and name
/// ids differ; the `answer` is a name.
final class IdentifyType implements PuzzleType {
  const IdentifyType();

  static const typeId = 'identify';

  @override
  String get id => typeId;

  @override
  IdentifyConfig parseConfig(JsonReader json) {
    json.allowOnly({'start', 'couplets', 'names', 'answer'});
    final couplets = <String, List<IdentifyChoice>>{};
    for (final c in json.objects('couplets')) {
      c.allowOnly({'id', 'choices'});
      final id = c.string('id');
      final choices = [
        for (final ch in c.objects('choices'))
          () {
            ch.allowOnly({'textKey', 'to'});
            return IdentifyChoice(
              textKey: ch.string('textKey'),
              to: ch.string('to'),
            );
          }(),
      ];
      if (choices.length != 2) c.fail('need exactly 2 choices', 'choices');
      if (couplets.containsKey(id)) c.fail('ids must differ', 'id');
      couplets[id] = choices;
    }
    final names = <String, IdentifyName>{};
    for (final n in json.objects('names')) {
      n.allowOnly({'id', 'nameKey', 'noteKey'});
      final id = n.string('id');
      if (couplets.containsKey(id) || names.containsKey(id)) {
        n.fail('ids must differ', 'id');
      }
      names[id] = IdentifyName(
        nameKey: n.string('nameKey'),
        noteKey: n.string('noteKey'),
      );
    }
    final start = json.string('start');
    if (!couplets.containsKey(start)) json.fail('not a couplet', 'start');
    final answer = json.string('answer');
    if (!names.containsKey(answer)) json.fail('not a name', 'answer');
    // A tree: every couplet and name reached once from the start.
    final reached = <String>[start];
    final total = couplets.length + names.length;
    for (var k = 0; k < reached.length && reached.length <= total; k++) {
      for (final ch in couplets[reached[k]] ?? const <IdentifyChoice>[]) {
        if (!couplets.containsKey(ch.to) && !names.containsKey(ch.to)) {
          json.fail('"${ch.to}" is neither a couplet nor a name', 'couplets');
        }
        reached.add(ch.to);
      }
    }
    if (reached.length != reached.toSet().length ||
        reached.length != couplets.length + names.length) {
      json.fail('the key must be a tree reaching everything once', 'couplets');
    }
    return IdentifyConfig(
      start: start,
      couplets: couplets,
      names: names,
      answer: answer,
    );
  }
}

final class IdentifyChoice {
  const IdentifyChoice({required this.textKey, required this.to});

  final String textKey;

  /// The couplet or name this statement leads to.
  final String to;
}

final class IdentifyName {
  const IdentifyName({required this.nameKey, required this.noteKey});

  final String nameKey;

  /// What the key says of it: shown when the path ends there.
  final String noteKey;
}

final class IdentifyConfig implements PuzzleConfig {
  IdentifyConfig({
    required this.start,
    required Map<String, List<IdentifyChoice>> couplets,
    required Map<String, IdentifyName> names,
    required this.answer,
  }) : couplets = Map.unmodifiable({
         for (final e in couplets.entries)
           e.key: List<IdentifyChoice>.unmodifiable(e.value),
       }),
       names = Map.unmodifiable(names);

  final String start;
  final Map<String, List<IdentifyChoice>> couplets;
  final Map<String, IdentifyName> names;
  final String answer;

  /// The couplets from the start to [target], in order.
  List<String> pathTo(String target) {
    List<String>? walk(String at) {
      if (at == target) return [];
      final choices = couplets[at];
      if (choices == null) return null;
      for (final ch in choices) {
        final rest = walk(ch.to);
        if (rest != null) return [at, ...rest];
      }
      return null;
    }

    return walk(start)!;
  }

  IdentifyState begin() => IdentifyState(this, [start], null, 0);

  @override
  Iterable<ContentRef> get references => [
    for (final choices in couplets.values)
      for (final ch in choices) ContentRef.text(ch.textKey),
    for (final n in names.values) ...[
      ContentRef.text(n.nameKey),
      ContentRef.text(n.noteKey),
    ],
  ];
}

final class IdentifyState {
  IdentifyState(
    this.config,
    List<String> path,
    this.wrongEnd,
    this.mistakes, {
    this.isSolved = false,
  }) : path = List.unmodifiable(path);

  final IdentifyConfig config;

  /// The couplets walked from the start, the one now asked last.
  final List<String> path;

  /// The wrong name the last path ended at, until the player goes on.
  final String? wrongEnd;
  final int mistakes;
  final bool isSolved;

  /// The couplet now asked.
  String get couplet => path.last;

  /// Picks choice [k] (0 or 1) of the current couplet.
  IdentifyState choose(int k) {
    if (isSolved) return this;
    final to = config.couplets[couplet]![k].to;
    if (config.couplets.containsKey(to)) {
      return IdentifyState(config, [...path, to], null, mistakes);
    }
    if (to == config.answer) {
      return IdentifyState(config, path, null, mistakes, isSolved: true);
    }
    // A wrong end: back to the last couplet this path shares with the
    // answer's, where it turned wrong.
    final right = config.pathTo(config.answer);
    var shared = 0;
    while (shared < path.length &&
        shared < right.length &&
        path[shared] == right[shared]) {
      shared++;
    }
    return IdentifyState(config, path.sublist(0, shared), to, mistakes + 1);
  }
}
