import '../json/json_reader.dart';
import '../model/content_ref.dart';
import '../model/normalized_rect.dart';
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
/// - `form` sets how the label looks, so every tale writes its own
///   ([DeductionForm]). The check is the same for all.
final class DeductionType implements PuzzleType {
  const DeductionType();

  static const typeId = 'deduction';

  @override
  String get id => typeId;

  @override
  DeductionConfig parseConfig(JsonReader json) {
    json.allowOnly({'sentences', 'words', 'nearMiss', 'form', 'columns'});
    final formName =
        json.optionalString('form') ?? DeductionForm.sentences.name;
    final form =
        DeductionForm.values.asNameMap()[formName] ??
        json.fail(
          'expected one of ${DeductionForm.values.map((f) => f.name).join(', ')}',
          'form',
        );
    final sentences = [
      for (final s in json.objects('sentences')) DeductionSentence._fromJson(s),
    ];
    final columns = json.has('columns') ? json.strings('columns') : <String>[];
    if (form == DeductionForm.table) {
      if (columns.isEmpty) json.fail('a table needs columns', 'columns');
    } else if (columns.isNotEmpty) {
      json.fail('only a table has columns', 'columns');
    }
    for (final (i, s) in sentences.indexed) {
      final at = 'sentences[$i]';
      if (form == DeductionForm.table && s.blanks.length != columns.length) {
        json.fail('a row needs one blank per column', '$at.blanks');
      }
      if ((form == DeductionForm.board) != (s.rect != null)) {
        json.fail(
          form == DeductionForm.board
              ? 'every sentence on a board needs a rect'
              : 'only a board places sentences',
          '$at.rect',
        );
      }
      if ((form == DeductionForm.correction) != (s.initial != null)) {
        json.fail(
          form == DeductionForm.correction
              ? 'a correction starts with every blank filled: needs initial'
              : 'only a correction starts filled',
          '$at.initial',
        );
      }
      if (s.initial case final initial?
          when initial.length != s.blanks.length) {
        json.fail('one word per blank', '$at.initial');
      }
    }
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
      for (final (j, word) in (s.initial ?? const <String>[]).indexed) {
        if (!words.contains(word)) {
          json.fail('"$word" is not in words', 'sentences[$i].initial[$j]');
        }
      }
    }
    if (form == DeductionForm.correction &&
        sentences.every((s) => _listEquals(s.initial!, s.blanks))) {
      json.fail('the label starts right: nothing to correct', 'sentences');
    }
    final nearMiss = json.optionalInt('nearMiss') ?? 2;
    if (nearMiss < 0) json.fail('must be >= 0', 'nearMiss');
    return DeductionConfig(
      sentences: sentences,
      words: words,
      nearMiss: nearMiss,
      form: form,
      columns: columns,
    );
  }
}

bool _listEquals(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// How a jar's label looks: every tale writes its own.
enum DeductionForm {
  /// Sentences on the label, their blanks filled in.
  sentences,

  /// A ledger: each sentence is a row, its text the row's heading (no
  /// placeholders), one blank per column; `columns` holds the headings.
  table,

  /// A telegram form: the sentences in capitals, STOP between them.
  telegram,

  /// A text that is already written, and wrong in places: every blank starts
  /// with the sentence's `initial` word, and the player corrects it.
  correction,

  /// Sentences pinned to places on the picture: each sentence's `rect` on
  /// the puzzle background.
  board,

  /// A royal order under the king's seal ("De par le Roy"): the sentences
  /// set out as its text.
  order,

  /// An ink rubbing taken from a cast inscription: black paper, the
  /// sentences left pale.
  rubbing,

  /// The cover sheet of a police file: printed headings, a register stamp,
  /// and the entry written in by hand.
  docket,

  /// A sheet of imperial yellow written in vermilion, the emperor's own
  /// ink.
  vermilion,

  /// A manuscript's colophon: the closing lines where the scribe says what
  /// the book is and when it was finished, the text narrowing to a point.
  colophon,

  /// The title cartouche of an old map: an ornamented panel where the map
  /// once named the land wrongly.
  cartouche,

  /// A sports-club party's route book: a ruled page with stamped
  /// headings, its last entry still to be written.
  routebook,

  /// A city's stone site marker: grey granite, the words cut into it.
  marker,

  /// A palisade post, the bark stripped from a band of pale wood, the
  /// words cut into it in capitals.
  post,

  /// A printed Admiralty form of the kind left in cairns: its heading in
  /// print, the words written into its blanks by hand.
  admiralty,

  /// Palm-leaf strips bound on a cord, the letters incised and blackened.
  lontar,

  /// A page of a household receipt book: a heading, a short receipt in a
  /// careful hand, the blanks in its lines.
  receipt,
}

final class DeductionSentence {
  DeductionSentence({
    required this.textKey,
    required List<String> blanks,
    this.rect,
    List<String>? initial,
  }) : blanks = List.unmodifiable(blanks),
       initial = initial == null ? null : List.unmodifiable(initial);

  factory DeductionSentence._fromJson(JsonReader json) {
    json.allowOnly({'textKey', 'blanks', 'rect', 'initial'});
    final blanks = json.strings('blanks');
    if (blanks.isEmpty) json.fail('need at least one blank', 'blanks');
    return DeductionSentence(
      textKey: json.string('textKey'),
      blanks: blanks,
      rect: json.has('rect') ? NormalizedRect.fromJson(json, 'rect') : null,
      initial: json.has('initial') ? json.strings('initial') : null,
    );
  }

  final String textKey;

  /// The right word for each placeholder: `{1}` is `blanks[0]`, ...
  final List<String> blanks;

  /// Where the sentence sits on the picture (`board` labels).
  final NormalizedRect? rect;

  /// The words the text starts with (`correction` labels).
  final List<String>? initial;
}

final class DeductionConfig implements PuzzleConfig {
  DeductionConfig({
    required List<DeductionSentence> sentences,
    required List<String> words,
    this.nearMiss = 2,
    this.form = DeductionForm.sentences,
    List<String> columns = const [],
  }) : columns = List.unmodifiable(columns),
       sentences = List.unmodifiable(sentences),
       words = List.unmodifiable(words),
       answers = List.unmodifiable([for (final s in sentences) ...s.blanks]);

  final List<DeductionSentence> sentences;
  final DeductionForm form;

  /// Column headings (text keys) of a `table` label.
  final List<String> columns;

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

  /// Starts with the bank words the player has noted; a `correction` label
  /// starts with its text as written.
  DeductionState start(GameState game) => DeductionState(
    this,
    available: [
      for (final w in words)
        if (game.words.contains(w)) w,
    ],
    filled: {
      for (final (i, s) in sentences.indexed)
        for (final (j, word) in (s.initial ?? const <String>[]).indexed)
          firstBlankOf(i) + j: word,
    },
  );

  @override
  Iterable<ContentRef> get references => [
    for (final s in sentences)
      form == DeductionForm.table
          // A row's heading has no placeholders.
          ? ContentRef.template(s.textKey, 0)
          : ContentRef.template(s.textKey, s.blanks.length),
    for (final c in columns) ContentRef.text(c),
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
