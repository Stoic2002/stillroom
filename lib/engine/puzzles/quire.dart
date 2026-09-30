import '../json/json_reader.dart';
import '../model/content_ref.dart';
import 'puzzle_type.dart';

/// `quire`: the loose sheets of a manuscript gathering. Each sheet is
/// folded once into two leaves, and the sheets nest one inside another,
/// so a sheet holds one leaf near the front and its partner near the back.
/// At the foot of each leaf the scribe wrote the catchword: the first word
/// of the next. Nest the sheets in order, and turn over any that lie the
/// wrong way, until every catchword meets its page.
///
/// ```json
/// "config": {
///   "leaves": ["ep.quire.l1", "ep.quire.l2", "ep.quire.l3", "ep.quire.l4"],
///   "start": [
///     { "sheet": 1, "turned": true },
///     { "sheet": 0, "turned": false }
///   ]
/// }
/// ```
/// `leaves` are the leaves' text keys in reading order (4 to 12, an even
/// number); sheet `k` is folded from leaves `k` and `n - 1 - k`, `n` the
/// number of leaves. `start` lays the sheets from the outermost in: which
/// sheet lies at each depth, and whether it is turned over (its back leaf
/// in front). The start must not already read through.
final class QuireType implements PuzzleType {
  const QuireType();

  static const typeId = 'quire';

  @override
  String get id => typeId;

  @override
  QuireConfig parseConfig(JsonReader json) {
    json.allowOnly({'leaves', 'start'});
    final leaves = json.strings('leaves');
    if (leaves.length < 4 || leaves.length > 12 || leaves.length.isOdd) {
      json.fail('need 4 to 12 leaves, an even number', 'leaves');
    }
    if (leaves.toSet().length != leaves.length) {
      json.fail('leaves must differ', 'leaves');
    }
    final sheets = leaves.length ~/ 2;
    final start = json.objects('start');
    if (start.length != sheets) json.fail('need $sheets sheets', 'start');
    final order = <int>[];
    final turned = List.filled(sheets, false);
    for (final s in start) {
      s.allowOnly({'sheet', 'turned'});
      final sheet = s.integer('sheet');
      if (sheet < 0 || sheet >= sheets) s.fail('0 to ${sheets - 1}', 'sheet');
      if (order.contains(sheet)) s.fail('each sheet once', 'sheet');
      order.add(sheet);
      turned[sheet] = s.boolean('turned');
    }
    final config = QuireConfig(
      leaves: leaves,
      startOrder: order,
      startTurned: turned,
    );
    if (config.start().isSolved) json.fail('already reads through', 'start');
    return config;
  }
}

final class QuireConfig implements PuzzleConfig {
  QuireConfig({
    required List<String> leaves,
    required List<int> startOrder,
    required List<bool> startTurned,
  }) : leaves = List.unmodifiable(leaves),
       startOrder = List.unmodifiable(startOrder),
       startTurned = List.unmodifiable(startTurned);

  /// The leaves' text keys, in reading order.
  final List<String> leaves;

  /// The sheet at each depth at the start, outermost first.
  final List<int> startOrder;

  /// Whether each sheet starts turned over.
  final List<bool> startTurned;

  int get sheets => leaves.length ~/ 2;

  QuireState start() => QuireState(this, startOrder, startTurned, 0);

  @override
  Iterable<ContentRef> get references => [
    for (final key in leaves) ContentRef.text(key),
  ];
}

final class QuireState {
  QuireState(this.config, List<int> order, List<bool> turned, this.moves)
    : order = List.unmodifiable(order),
      turned = List.unmodifiable(turned);

  final QuireConfig config;

  /// The sheet at each depth, outermost first.
  final List<int> order;

  /// Whether each sheet is turned over.
  final List<bool> turned;

  /// Sheets moved or turned so far.
  final int moves;

  int get length => config.leaves.length;

  /// The depth (0 outermost) of the sheet that holds place [p].
  int depthOf(int p) => p < config.sheets ? p : length - 1 - p;

  /// The sheet that holds place [p] in the gathering.
  int sheetAt(int p) => order[depthOf(p)];

  /// The leaf (its index in reading order) at place [p].
  int leafAt(int p) {
    final sheet = sheetAt(p);
    final front = p < config.sheets;
    return front != turned[sheet] ? sheet : length - 1 - sheet;
  }

  /// Whether the catchword at the foot of place [p] meets the page at
  /// place `p + 1`.
  bool linked(int p) => leafAt(p) + 1 == leafAt(p + 1);

  /// Catchwords that meet their pages.
  int get links => [
    for (var p = 0; p < length - 1; p++)
      if (linked(p)) p,
  ].length;

  bool get isSolved => links == length - 1;

  /// Swaps the sheets at depths [a] and [b].
  QuireState swap(int a, int b) {
    if (isSolved || a == b) return this;
    final next = [...order];
    next[a] = order[b];
    next[b] = order[a];
    return QuireState(config, next, turned, moves + 1);
  }

  /// Turns [sheet] over.
  QuireState turn(int sheet) {
    if (isSolved) return this;
    return QuireState(config, order, [
      for (final (k, t) in turned.indexed) k == sheet ? !t : t,
    ], moves + 1);
  }
}

/// The catchword for a leaf that begins with [text]: its first word
/// (leading quotes and marks skipped), or, in a script written without
/// spaces, its first two characters.
String catchword(String text) {
  final word = RegExp(
    r"[\p{L}\p{N}][\p{L}\p{N}'’-]*",
    unicode: true,
  ).stringMatch(text);
  if (word == null) return '';
  // Kana and CJK ideographs.
  final unspaced = RegExp('[\u3040-\u30ff\u3400-\u9fff]');
  if (unspaced.hasMatch(word[0])) {
    return String.fromCharCodes(word.runes.take(2));
  }
  return word;
}
