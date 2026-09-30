import '../json/json_reader.dart';
import '../model/content_ref.dart';
import 'puzzle_type.dart';

/// `compose`: set a line of type by hand. Every sort (piece of type) has its
/// letter cut in mirror, as real type is, so the letter on the sort reads
/// backwards and prints the right way round. Some sorts in the case are
/// cut the wrong way: they look right on the sort, and print backwards.
///
/// ```json
/// "config": { "text": "FRANCES COLES", "reversed": ["R", "N", "S"],
///             "extra": ["P", "D"] }
/// ```
/// `text` is the line to set: capital letters A–Z and spaces. The case
/// holds one sort for each letter in `text` and in `extra`, plus, for each
/// letter in `reversed`, a sort cut the wrong way. Spaces are set with a
/// blank sort (a quad). Solved when the stick holds the whole line, each
/// letter from a rightly cut sort.
final class ComposeType implements PuzzleType {
  const ComposeType();

  static const typeId = 'compose';

  /// Capitals that look the same in a mirror: a wrongly cut sort of one
  /// could not be told apart, so none may be `reversed`.
  static const symmetric = 'AHIMOTUVWXY';

  @override
  String get id => typeId;

  @override
  ComposeConfig parseConfig(JsonReader json) {
    json.allowOnly({'text', 'reversed', 'extra'});
    final text = json.string('text');
    if (!RegExp(r'^[A-Z ]{3,24}$').hasMatch(text) || text.trim() != text) {
      json.fail('3 to 24 capitals A–Z and single spaces', 'text');
    }
    List<String> letters(String key, {bool optional = false}) {
      final list = json.strings(key, optional: optional);
      for (final (i, l) in list.indexed) {
        if (!RegExp(r'^[A-Z]$').hasMatch(l)) {
          json.fail('one capital letter', '$key[$i]');
        }
      }
      if (list.toSet().length != list.length) json.fail('listed twice', key);
      return list;
    }

    final reversed = letters('reversed');
    if (reversed.isEmpty) json.fail('need at least one', 'reversed');
    for (final (i, l) in reversed.indexed) {
      if (!text.contains(l)) {
        json.fail('"$l" is not in the text', 'reversed[$i]');
      }
      if (symmetric.contains(l)) {
        json.fail('"$l" looks the same in a mirror', 'reversed[$i]');
      }
    }
    final extra = letters('extra', optional: true);
    for (final (i, l) in extra.indexed) {
      if (text.contains(l)) json.fail('"$l" is in the text', 'extra[$i]');
    }
    return ComposeConfig(text: text, reversed: reversed, extra: extra);
  }
}

/// One piece of type: a letter (or a blank quad, ' '), cut the right way
/// or the wrong way.
final class Sort {
  const Sort(this.letter, {this.wrongWay = false});

  final String letter;
  final bool wrongWay;

  @override
  bool operator ==(Object other) =>
      other is Sort && other.letter == letter && other.wrongWay == wrongWay;

  @override
  int get hashCode => Object.hash(letter, wrongWay);
}

final class ComposeConfig implements PuzzleConfig {
  ComposeConfig({
    required this.text,
    required List<String> reversed,
    required List<String> extra,
  }) : reversed = List.unmodifiable(reversed),
       extra = List.unmodifiable(extra);

  final String text;
  final List<String> reversed;
  final List<String> extra;

  /// The case, in a fixed jumble so it has to be searched.
  List<Sort> get sortCase {
    final letters = {...text.replaceAll(' ', '').split(''), ...extra}.toList()
      ..sort();
    final sorts = [
      for (final l in letters) Sort(l),
      for (final l in reversed) Sort(l, wrongWay: true),
    ];
    // Deal them out by a step coprime with the count, so every sort has a
    // fixed place and the wrong-way ones do not sit by their twins.
    final n = sorts.length;
    var step = 5;
    while (_gcd(step, n) != 1) {
      step++;
    }
    return [for (var i = 0; i < n; i++) sorts[(i * step) % n]];
  }

  bool get hasSpace => text.contains(' ');

  ComposeState start() => ComposeState(this, const []);

  static int _gcd(int a, int b) => b == 0 ? a : _gcd(b, a % b);

  @override
  Iterable<ContentRef> get references => const [];
}

final class ComposeState {
  ComposeState(this.config, List<Sort> stick)
    : stick = List.unmodifiable(stick);

  final ComposeConfig config;

  /// The sorts set so far, in reading order.
  final List<Sort> stick;

  bool get isFull => stick.length >= config.text.length;

  bool get isSolved =>
      isFull &&
      [
        for (var i = 0; i < config.text.length; i++)
          stick[i] == Sort(config.text[i]),
      ].every((ok) => ok);

  /// Places in the stick that print wrong: the wrong letter, or a letter
  /// from a wrongly cut sort.
  Set<int> get wrong => {
    for (var i = 0; i < stick.length && i < config.text.length; i++)
      if (stick[i] != Sort(config.text[i])) i,
  };

  ComposeState set(Sort sort) =>
      isSolved || isFull ? this : ComposeState(config, [...stick, sort]);

  ComposeState takeOut() => isSolved || stick.isEmpty
      ? this
      : ComposeState(config, stick.sublist(0, stick.length - 1));
}
