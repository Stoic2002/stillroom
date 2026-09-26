import '../json/json_reader.dart';
import '../model/content_ref.dart';
import '../state/game_state.dart';
import 'puzzle_type.dart';

/// `deduction`: distil the tale. Sentences with blanks are filled from the
/// words the player has noted down (`words` in `game.json`, noted by tapping
/// `[[id]]` in texts), in the spirit of *The Case of the Golden Idol*.
///
/// ```json
/// "config": {
///   "sentences": [
///     { "textKey": "whitechapel_1888.label.s1", "blanks": ["nichols", "bucks_row"] }
///   ],
///   "words": ["nichols", "chapman", "bucks_row", "hanbury_street"],
///   "nearMiss": 2
/// }
/// ```
/// - A sentence's text marks its blanks `{1}`, `{2}`, … in the order of
///   `blanks`; each language may place them anywhere.
/// - `words` is the bank: every blank's answer plus any decoys. Only noted
///   words appear in it; a word can fill several blanks.
/// - When the player checks and at most `nearMiss` blanks are wrong (default
///   2), they are told how many; otherwise only that it is not right.
final class DeductionType implements PuzzleType {
  const DeductionType();

  static const typeId = 'deduction';

  @override
  String get id => typeId;

  @override
  DeductionConfig parseConfig(JsonReader json) {
    json.allowOnly({'sentences', 'words', 'nearMiss'});
    final sentences = [
      for (final s in json.objects('sentences')) DeductionSentence._fromJson(s),
    ];
    if (sentences.isEmpty) json.fail('need at least one sentence', 'sentences');
    final words = json.strings('words');
    if (words.toSet().length != words.length) {
      json.fail('words must be unique', 'words');
    }
    for (final (i, s) in sentences.indexed) {
      for (final (j, answer) in s.blanks.indexed) {
        if (!words.contains(answer)) {
          json.fail('"$answer" is not in words', 'sentences[$i].blanks[$j]');
        }
      }
    }
    final nearMiss = json.optionalInt('nearMiss') ?? 2;
    if (nearMiss < 0) json.fail('must be >= 0', 'nearMiss');
    return DeductionConfig(
      sentences: sentences,
      words: words,
      nearMiss: nearMiss,
    );
  }
}

final class DeductionSentence {
  DeductionSentence({required this.textKey, required List<String> blanks})
    : blanks = List.unmodifiable(blanks);

  factory DeductionSentence._fromJson(JsonReader json) {
    json.allowOnly({'textKey', 'blanks'});
    final blanks = json.strings('blanks');
    if (blanks.isEmpty) json.fail('need at least one blank', 'blanks');
    return DeductionSentence(textKey: json.string('textKey'), blanks: blanks);
  }

  final String textKey;

  /// The right word for each placeholder: `{1}` is `blanks[0]`, ...
  final List<String> blanks;
}

final class DeductionConfig implements PuzzleConfig {
  DeductionConfig({
    required List<DeductionSentence> sentences,
    required List<String> words,
    this.nearMiss = 2,
  }) : sentences = List.unmodifiable(sentences),
       words = List.unmodifiable(words),
       answers = List.unmodifiable([for (final s in sentences) ...s.blanks]);

  final List<DeductionSentence> sentences;

  /// The word bank: answers and decoys.
  final List<String> words;
  final int nearMiss;

  /// The right word for every blank, all sentences in order.
  final List<String> answers;

  /// Index of the first blank of sentence [sentence] in [answers].
  int firstBlankOf(int sentence) {
    var index = 0;
    for (var i = 0; i < sentence; i++) {
      index += sentences[i].blanks.length;
    }
    return index;
  }

  /// Starts with the bank words the player has noted.
  DeductionState start(GameState game) => DeductionState(
    this,
    available: [
      for (final w in words)
        if (game.words.contains(w)) w,
    ],
    filled: const {},
  );

  @override
  Iterable<ContentRef> get references => [
    for (final s in sentences) ContentRef.template(s.textKey, s.blanks.length),
    for (final w in words) ContentRef.word(w),
  ];
}

/// The verdict when the player asks whether the sentences are right.
sealed class DeductionVerdict {
  const DeductionVerdict();
}

final class DeductionSolved extends DeductionVerdict {
  const DeductionSolved();
}

/// Some blanks are empty.
final class DeductionIncomplete extends DeductionVerdict {
  const DeductionIncomplete(this.empty);

  final int empty;
}

/// Wrong; [wrong] is the number of wrong blanks when it is at most
/// [DeductionConfig.nearMiss], else `null` (not told).
final class DeductionWrong extends DeductionVerdict {
  const DeductionWrong(this.wrong);

  final int? wrong;
}

final class DeductionState {
  DeductionState(
    this.config, {
    required List<String> available,
    required Map<int, String> filled,
  }) : available = List.unmodifiable(available),
       filled = Map.unmodifiable(filled);

  final DeductionConfig config;

  /// Bank words the player can use, in bank order.
  final List<String> available;

  /// Word placed in each blank (global blank index).
  final Map<int, String> filled;

  int get blankCount => config.answers.length;

  /// Puts [wordId] into [blank]; a word that is not available is ignored.
  DeductionState fill(int blank, String wordId) {
    if (blank < 0 || blank >= blankCount || !available.contains(wordId)) {
      return this;
    }
    return DeductionState(
      config,
      available: available,
      filled: {...filled, blank: wordId},
    );
  }

  DeductionState clear(int blank) => DeductionState(
    config,
    available: available,
    filled: {...filled}..remove(blank),
  );

  bool get isSolved => check() is DeductionSolved;

  DeductionVerdict check() {
    final empty = blankCount - filled.length;
    if (empty > 0) return DeductionIncomplete(empty);
    var wrong = 0;
    for (var i = 0; i < blankCount; i++) {
      if (filled[i] != config.answers[i]) wrong++;
    }
    if (wrong == 0) return const DeductionSolved();
    return DeductionWrong(wrong <= config.nearMiss ? wrong : null);
  }
}
