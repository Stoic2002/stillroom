import '../json/json_reader.dart';
import '../model/content_ref.dart';
import 'puzzle_type.dart';

/// `margins`: one sheet written all round, its passages set at quarter
/// turns to one another (round the margins, up the sides, upside down).
/// Turn the sheet until a passage stands upright and can be read, and tap
/// the one that answers the question at hand; the next question follows.
///
/// ```json
/// "config": {
///   "passages": [
///     { "textKey": "ep.note.all_well", "rect": [0.1, 0.3, 0.8, 0.3], "turn": 0 },
///     { "textKey": "ep.note.deserted", "rect": [0.85, 0.1, 0.12, 0.8], "turn": 1 }
///   ],
///   "questions": [ { "questionKey": "ep.note.q_deserted", "passage": 1 } ],
///   "startTurn": 0
/// }
/// ```
/// A passage's `rect` is its place on the square sheet (0 to 1 across and
/// down, as the sheet lies unturned); `turn` (0 to 3) is how many quarter
/// turns clockwise the sheet must be turned for it to stand upright. 3 to
/// 8 passages, 1 to 4 questions, each answered by a different passage.
/// A passage may be `printed` (the form's own type) rather than written.
final class MarginsType implements PuzzleType {
  const MarginsType();

  static const typeId = 'margins';

  @override
  String get id => typeId;

  @override
  MarginsConfig parseConfig(JsonReader json) {
    json.allowOnly({'passages', 'questions', 'startTurn'});
    final passages = [
      for (final p in json.objects('passages'))
        () {
          p.allowOnly({'textKey', 'rect', 'turn', 'printed'});
          final r = p.numbers('rect', length: 4);
          if (r.any((v) => v < 0 || v > 1) ||
              r[0] + r[2] > 1 ||
              r[1] + r[3] > 1) {
            p.fail('must lie on the sheet', 'rect');
          }
          final turn = p.integer('turn');
          if (turn < 0 || turn > 3) p.fail('0 to 3', 'turn');
          return MarginsPassage(
            textKey: p.string('textKey'),
            rect: (r[0], r[1], r[2], r[3]),
            turn: turn,
            printed: p.optionalBool('printed') ?? false,
          );
        }(),
    ];
    if (passages.length < 3 || passages.length > 8) {
      json.fail('need 3 to 8 passages', 'passages');
    }
    final questions = [
      for (final q in json.objects('questions'))
        () {
          q.allowOnly({'questionKey', 'passage'});
          final passage = q.integer('passage');
          if (passage < 0 || passage >= passages.length) {
            q.fail('not a passage', 'passage');
          }
          return MarginsQuestion(
            questionKey: q.string('questionKey'),
            passage: passage,
          );
        }(),
    ];
    if (questions.isEmpty || questions.length > 4) {
      json.fail('need 1 to 4 questions', 'questions');
    }
    if (questions.map((q) => q.passage).toSet().length != questions.length) {
      json.fail('each question a different passage', 'questions');
    }
    final start = json.optionalInt('startTurn') ?? 0;
    if (start < 0 || start > 3) json.fail('0 to 3', 'startTurn');
    return MarginsConfig(
      passages: passages,
      questions: questions,
      startTurn: start,
    );
  }
}

final class MarginsPassage {
  const MarginsPassage({
    required this.textKey,
    required this.rect,
    required this.turn,
    this.printed = false,
  });

  final String textKey;

  /// Set in print (the form itself), not written by hand.
  final bool printed;

  /// Left, top, width, height on the unturned sheet.
  final (double, double, double, double) rect;
  final int turn;
}

final class MarginsQuestion {
  const MarginsQuestion({required this.questionKey, required this.passage});

  final String questionKey;
  final int passage;
}

final class MarginsConfig implements PuzzleConfig {
  MarginsConfig({
    required List<MarginsPassage> passages,
    required List<MarginsQuestion> questions,
    required this.startTurn,
  }) : passages = List.unmodifiable(passages),
       questions = List.unmodifiable(questions);

  final List<MarginsPassage> passages;
  final List<MarginsQuestion> questions;
  final int startTurn;

  MarginsState start() => MarginsState(this, startTurn, 0, 0);

  @override
  Iterable<ContentRef> get references => [
    for (final p in passages) ContentRef.text(p.textKey),
    for (final q in questions) ContentRef.text(q.questionKey),
  ];
}

/// What tapping a passage came to.
enum MarginsAnswer { right, wrong, unreadable, none }

final class MarginsState {
  const MarginsState(this.config, this.turn, this.answered, this.mistakes);

  final MarginsConfig config;

  /// Quarter turns clockwise the sheet is turned now (0 to 3).
  final int turn;

  /// Questions answered so far, in order.
  final int answered;
  final int mistakes;

  bool get isSolved => answered == config.questions.length;

  MarginsQuestion? get current => isSolved ? null : config.questions[answered];

  /// Turns the sheet [by] quarter turns clockwise (negative: back).
  MarginsState rotate(int by) =>
      MarginsState(config, (turn + by) % 4, answered, mistakes);

  /// Whether passage [i] stands upright now.
  bool readable(int i) => config.passages[i].turn == turn;

  MarginsAnswer judge(int i) {
    final q = current;
    if (q == null) return MarginsAnswer.none;
    if (!readable(i)) return MarginsAnswer.unreadable;
    return q.passage == i ? MarginsAnswer.right : MarginsAnswer.wrong;
  }

  /// Taps passage [i] as the answer to the current question.
  MarginsState answer(int i) => switch (judge(i)) {
    MarginsAnswer.right => MarginsState(config, turn, answered + 1, mistakes),
    MarginsAnswer.wrong => MarginsState(config, turn, answered, mistakes + 1),
    MarginsAnswer.unreadable || MarginsAnswer.none => this,
  };
}
