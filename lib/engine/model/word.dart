import '../json/json_reader.dart';
import 'condition.dart';
import 'content_ref.dart';

/// What a word stands for; the deduction screen groups and colors by kind.
enum WordKind { name, place, date, number, thing }

/// A word the player can note down: a name, place, date, ... (`words` in
/// `game.json`). Texts mark where it can be noted with `[[id]]`; deduction
/// puzzles ask for it.
final class WordDef {
  const WordDef({
    required this.id,
    required this.labelKey,
    required this.kind,
    this.given = false,
  });

  factory WordDef.fromJson(JsonReader json) {
    json.allowOnly({'id', 'labelKey', 'kind', 'given'});
    final kindName = json.string('kind');
    return WordDef(
      id: json.string('id'),
      labelKey: json.string('labelKey'),
      kind:
          WordKind.values.asNameMap()[kindName] ??
          json.fail(
            'expected one of ${WordKind.values.map((k) => k.name).join(', ')}',
            'kind',
          ),
      given: json.optionalBool('given') ?? false,
    );
  }

  final String id;

  /// How the word reads, in every language. Also what `[[id]]` shows.
  final String labelKey;
  final WordKind kind;

  /// Known from the start (e.g. common words a deduction needs).
  final bool given;
}

/// The episode's optional secret (`secret` in `game.json`): found the moment
/// every `when` condition holds, it earns the jar the keeper's mark and
/// keeps `noteKey` on the shelf.
final class SecretDef {
  const SecretDef({required this.when, required this.noteKey});

  factory SecretDef.fromJson(JsonReader json) {
    json.allowOnly({'when', 'noteKey'});
    final when = Condition.listFromJson(json, 'when');
    if (when.isEmpty) json.fail('need at least one condition', 'when');
    return SecretDef(when: when, noteKey: json.string('noteKey'));
  }

  final List<Condition> when;
  final String noteKey;

  Iterable<ContentRef> get references => [
    for (final c in when) c.reference,
    ContentRef.text(noteKey),
  ];
}
